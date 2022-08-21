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
        cp $initFile "_${initFile}"


	# bashinit includes heainit, caldbinit, condainit (for wget); batch processing requires being run in a bash shell
	
	echo "$OSTYPE"
	if [[ "$OSTYPE" == "darwin"* ]]; then

            sed -i '' 's/%1%/'"${inFile}"'/' "_${initFile}"
        else
            
            sed -i 's/%1%/'"${inFile}"'/' "_${initFile}"
	fi
	
        xspec - "_$initFile"

    fi



    if [ ! -f $nhFile ]; then
        echo "No getnh file found"
    else
        ./$nhFile
    fi

    popd >& /dev/null

}

export -f xi

# How to get autocomplete of file and directory in user prompt
# https://stackoverflow.com/questions/4819819/get-autocompletion-when-invoking-a-read-inside-a-bash-script
