#!/bin/bash


# read from central location
version=$(<version.txt)
title="UnRen for Linux v$version"


path_check() {
    base_pth=$(cd `dirname $0` && pwd)

    if [ -d "game" ] && [ -d "lib" ] && [ -d "renpy" ]; then
        path_check2
    elif [ -d "../game" ] && [ -d "../lib" ] && [ -d "../renpy" ]; then
        base_pth=$(cd `dirname $base_pth` && pwd)
        path_check2
    else
        echo "Error: The location of UnRen appears to be wrong. It should
              be in the game's base directory.
              (dirs 'game', 'lib', 'renpy' are present)"
        error
    fi
}


path_check2() {
    os_arch=$(uname -m)
    
    if [ *"x64"* in $os_arch ]; then
        python_pth=$base_pth"/lib/linux-x86_64"
    elif [ *"i686"* in $os_arch ]; then
        python_pth=$base_pth"/lib/linux-i686"
    else
        echo "Could not identify OS architecture to set python." 
        error
    fi
    game_pth=$base_pth"/game"
    renpy_pth=$base_pth"/renpy"

    if [ -f $python_pth"/python" ]; then
        echo "python found"
    else
        echo "Error: Cannot locate python, unable to continue.
              Is the correct python version for your computer in the
              $base_pth/lib directory?"
        error
    fi
}


# Lets go
run_py() {
    # This does not work.
    # From the look of it the whole path stuff and environment needs be configured -> Nonsense for lx and mac where py runs already
    $python_pth"/python" <<EOF
    # print("Here should be a hunk of UnRen_py code.")
EOF
}


end() {
    echo "Regular program exit."
    exit 0
}


error() {
    echo "A error occured!" 
    echo "Terminating."
    exit 1
}

path_check
run_py
end