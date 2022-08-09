#!/usr/bin/env bash

#obs=$1

function xi(){

    fittingPath=$PWD/$1/xspec

    initFile=_xspecinit.xcm
    nhFile=_getnh.sh



    pushd $fittingPath

    #chmod 777 $nhFile

    echo
    echo "GRPPHA Files:"
    echo
    #pwd
    ls -1a *grppha*

    echo

    read -e -p $'Enter grppha name in current directory: \n\n' inFile

    obsDate=$(gethead DATE-OBS ${inFile})

    echo
    echo "Observation Date (${1%"/"}): $obsDate"
    echo

    if [ ! -f $initFile ]; then
        echo "No xspec init file found"
    else
        #cp $initFile "_$initFile"

        sed -i '' 's/%1%/'"$inFile"'/' "_$initFile"

        xspec - "_$initFile"

    fi



    if [ ! -f $nhFile ]; then
        echo "No getnh file found"
    else
        ./$nhFile
    fi

    popd >& /dev/null

}

# How to get autocomplete of file and directory in user prompt
# https://stackoverflow.com/questions/4819819/get-autocompletion-when-invoking-a-read-inside-a-bash-script
