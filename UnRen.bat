@echo off
set "rpydevdir=%UserProfile%/Documents/GitHub/renpy/"
REM --------------------------------------------------------------------------------
REM Configuration:
REM   Set a Quick Save and Quick Load hotkey - http://www.pygame.org/docs/ref/key.html
REM --------------------------------------------------------------------------------
set "quicksavekey=K_F5"
set "quickloadkey=K_F9"
REM --------------------------------------------------------------------------------
REM !! END CONFIG !!
REM --------------------------------------------------------------------------------
REM The following variables are Base64 encoded strings for unrpyc and rpatool
REM Due to batch limitations on variable lengths, they need to be split into
REM multiple variables, and joined later using powershell.
REM --------------------------------------------------------------------------------
REM unrpyc by CensoredUsername
REM   https://github.com/CensoredUsername/unrpyc
REM Edited to remove multiprocessing and adjust output spacing [UNRPYC//SHA] [UNRPYC//DATE]
REM   https://github.com/F95Sam/unrpyc
REM --------------------------------------------------------------------------------
REM set unrpyccab01=
set "unrpycpy=%rpydevdir%unrpyc/unrpyc.py"
set "deobfuscate=%rpydevdir%unrpyc/deobfuscate.py"
REM --------------------------------------------------------------------------------
REM rpatool by Shizmob [RPATOOL//SHA] [RPATOOL//DATE]
REM   https://github.com/Shizmob/rpatool
REM --------------------------------------------------------------------------------
REM set rpatool01=
set "rpatool=%rpydevdir%rpatool/rpatool"
REM --------------------------------------------------------------------------------
REM !! DO NOT EDIT BELOW THIS LINE !!
REM --------------------------------------------------------------------------------
set "version=0.91 (includes Gideon.v5 mods) ([DEV//BUILD_DATE])"
title UnRen.bat v%version%
:init
REM --------------------------------------------------------------------------------
REM Splash screen
REM --------------------------------------------------------------------------------
cls
echo.
echo     __  __      ____               __          __
echo    / / / /___  / __ \___  ____    / /_  ____ _/ /_
echo   / / / / __ \/ /_/ / _ \/ __ \  / __ \/ __ ^`/ __/
echo  / /_/ / / / / _^, _/  __/ / / / / /_/ / /_/ / /_
echo  \____/_/ /_/_/ ^|_^|\___/_/ /_(_)_.___/\__^,_/\__/ v%version%
echo   Sam @ www.f95zone.to
echo.
echo  ----------------------------------------------------
echo.

REM --------------------------------------------------------------------------------
REM Set our paths, and make sure we can find python exe
REM --------------------------------------------------------------------------------
set "currentdir=%~dp0%"
set "pythondir=%currentdir%..\lib\windows-i686\"
set "renpydir=%currentdir%..\renpy\"
set "gamedir=%currentdir%"
if exist "game" if exist "lib" if exist "renpy" (
	set "pythondir=%currentdir%lib\windows-i686\"
	set "renpydir=%currentdir%renpy\"
	set "gamedir=%currentdir%game\"
)

if not exist "%pythondir%python.exe" (
	set "pythondir=%currentdir%..\lib\windows-x86_64\"
	set "renpydir=%currentdir%..\renpy\"
	set "gamedir=%currentdir%"
	if exist "game" if exist "lib" if exist "renpy" (
		set "pythondir=%currentdir%lib\windows-x86_64\"
		set "renpydir=%currentdir%renpy\"
		set "gamedir=%currentdir%game\"
	)
)

if not exist "%pythondir%python.exe" (
	echo    ! Error: Cannot locate python.exe, unable to continue.
	echo             Are you sure we're in the game's root or game directory?
	echo.
	pause>nul|set/p=.            Press any key to exit...
	exit
)

:menu
REM --------------------------------------------------------------------------------
REM Menu selection
REM --------------------------------------------------------------------------------
set exitoption=
set option=
echo   Available Options:
echo     1) Extract RPA packages (in game folder)
echo     2) Decompile rpyc files (in game folder)
echo.
echo     3) Enable Console and Developer Menu
echo     4) Enable Quick Save and Quick Load
echo     5) Force enable skipping of unseen content
echo     6) Force enable rollback (scroll wheel)
echo.
echo     8) Options 3-6
echo     9) Options 1-6
echo.
set /p option=.  Enter a number: 
echo.
echo  ----------------------------------------------------
echo.
if "%option%"=="1" goto extract
if "%option%"=="2" goto decompile
if "%option%"=="3" goto console
if "%option%"=="4" goto quick
if "%option%"=="5" goto skip
if "%option%"=="6" goto rollback
if "%option%"=="8" goto console
if "%option%"=="9" goto extract
goto init

:extract

REM --------------------------------------------------------------------------------
REM Check if rpatool is there.
REM --------------------------------------------------------------------------------
if not exist "%rpatool%" (
	echo    ! Error: %rpatool% is missing. Please check if UnRen and Powershell
	echo             are working correctly.
	echo/
	set err=1 & goto :error
)

REM --------------------------------------------------------------------------------
REM Unpack RPA
REM --------------------------------------------------------------------------------
echo   Searching for RPA packages
pushd "%gamedir%"
set "PYTHONPATH=%pythondir%Lib"
for %%f in (*.rpa) do (
	echo    + Unpacking "%%~nf%%~xf" - %%~zf bytes
	"%pythondir%python.exe" -O "%rpatool%" -x "%%f"
)
popd

echo.
if not "%option%" == "9" (
	goto finish
)

:decompile
REM --------------------------------------------------------------------------------
REM Write to temporary file first, then convert. Needed due to binary file
REM --------------------------------------------------------------------------------
@REM if not exist "%gamedir%*.rpyc" (
@REM 	echo No .rpyc files found in %gamedir%!
@REM 	echo.
@REM 	goto finish
@REM )


REM --------------------------------------------------------------------------------
REM Check if unrpyc is there
REM --------------------------------------------------------------------------------
if not exist "%unrpycpy%" (
	echo    ! Error: %unrpycpy% is missing. Please check if UnRen and Powershell
	echo              are working correctly.
	echo/
	set err=1 & goto :error
)

REM --------------------------------------------------------------------------------
REM Decompile rpyc files
REM --------------------------------------------------------------------------------
echo   Searching for rpyc files...
pushd "%gamedir%"
set "PYTHONPATH=%pythondir%Lib"
for /r %%f in (*.rpyc) do (
	if not %%~nf == un (
		echo    + Decompiling "%%~nf%%~xf" - %%~zf bytes
		"%pythondir%python.exe" -O "%unrpycpy%" -c --init-offset "%%f"
	)
)
popd

echo.
if not "%option%" == "9" (
	goto finish
)

:console
REM --------------------------------------------------------------------------------
REM Drop our console/dev mode enabler into the game folder
REM --------------------------------------------------------------------------------
echo   Creating Developer/Console file...
set "consolefile=%gamedir%unren-dev.rpy"
if exist "%consolefile%" (
	del "%consolefile%"
)

echo init 999 python:>> "%consolefile%"
echo   config.developer = True>> "%consolefile%"
echo   config.console = True>> "%consolefile%"

echo    + Console: SHIFT+O
echo    + Dev Menu: SHIFT+D
echo.

:consoleend
if "%option%" == "8" (
	goto quick
)
if "%option%" == "9" (
	goto quick
)
goto finish

:quick
REM --------------------------------------------------------------------------------
REM Drop our Quick Save/Load file into the game folder
REM --------------------------------------------------------------------------------
echo   Creating Quick Save/Quick Load file...
set "quickfile=%gamedir%unren-quick.rpy"
if exist "%quickfile%" (
	del "%quickfile%"
)

echo init 999 python:>> "%quickfile%"
echo   try:>> "%quickfile%"
echo     config.underlay[0].keymap['quickSave'] = QuickSave()>> "%quickfile%"
echo     config.keymap['quickSave'] = '%quicksavekey%'>> "%quickfile%"
echo     config.underlay[0].keymap['quickLoad'] = QuickLoad()>> "%quickfile%"
echo     config.keymap['quickLoad'] = '%quickloadkey%'>> "%quickfile%"
echo   except:>> "%quickfile%"
echo     pass>> "%quickfile%"

echo    Default hotkeys:
echo    + Quick Save: F5
echo    + Quick Load: F9
echo.

if "%option%" == "8" (
	goto skip
)
if "%option%" == "9" (
	goto skip
)
goto finish


:skip
REM --------------------------------------------------------------------------------
REM Drop our skip file into the game folder
REM --------------------------------------------------------------------------------
echo   Creating skip file...
set "skipfile=%gamedir%unren-skip.rpy"
if exist "%skipfile%" (
	del "%skipfile%"
)

echo init 999 python:>> "%skipfile%"
echo   _preferences.skip_unseen = True>> "%skipfile%"
echo   renpy.game.preferences.skip_unseen = True>> "%skipfile%"
echo   renpy.config.allow_skipping = True>> "%skipfile%"
echo   renpy.config.fast_skipping = True>> "%skipfile%"

echo    + You can now skip all text using TAB and CTRL keys
echo.

if "%option%" == "8" (
	goto rollback
)
if "%option%" == "9" (
	goto rollback
)
goto finish


:rollback
REM --------------------------------------------------------------------------------
REM Drop our rollback file into the game folder
REM --------------------------------------------------------------------------------
echo   Creating rollback file...
set "rollbackfile=%gamedir%unren-rollback.rpy"
if exist "%rollbackfile%" (
	del "%rollbackfile%"
)

echo init 999 python:>> "%rollbackfile%"
echo   renpy.config.rollback_enabled = True>> "%rollbackfile%"
echo   renpy.config.hard_rollback_limit = 256>> "%rollbackfile%"
echo   renpy.config.rollback_length = 256>> "%rollbackfile%"
echo   def unren_noblock( *args, **kwargs ):>> "%rollbackfile%"
echo     return>> "%rollbackfile%"
echo   renpy.block_rollback = unren_noblock>> "%rollbackfile%"
echo   try:>> "%rollbackfile%"
echo     config.keymap['rollback'] = [ 'K_PAGEUP', 'repeat_K_PAGEUP', 'K_AC_BACK', 'mousedown_4' ]>> "%rollbackfile%"
echo   except:>> "%rollbackfile%"
echo     pass>> "%rollbackfile%"

echo    + You can now rollback using the scrollwheel
echo.


:finish
REM --------------------------------------------------------------------------------
REM We are done
REM --------------------------------------------------------------------------------
echo  ----------------------------------------------------
echo.
echo    Finished!
echo.
echo    Enter "1" to go back to the menu, or any other
set /p exitoption=.   key to exit: 
echo.
echo  ----------------------------------------------------
echo.
if "%exitoption%"=="1" goto menu
exit 0

REM --------------------------------------------------------------------------------
REM Bad end
REM --------------------------------------------------------------------------------
:error
echo/
echo    Terminating.
echo    If a reason was stated correct the problem, if not check path
echo    and script for possible issues.
echo/
pause>nul|set/p=.            Press any key to exit...
exit 1
