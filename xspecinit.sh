#!/usr/bin/env bash

obs=$1

fittingPath=${obs}/xspec/source

initFile=xspecinit.xcm
nhFile=getnh.sh

cp ./$initFile ./$fittingPath
cp ./$nhFile ./$fittingPath

pushd $fittingPath

chmod 777 $nhFile

echo
echo "GRPPHA Files:"
echo

ls -1a *grppha*

echo

read -e -p $'Enter grppha name in current directory: \n\n' inFile

obsDate=$(gethead DATE-OBS ${inFile})

echo
echo "Observation Date ($obs): $obsDate"
echo

sed -i 's/%1%/'"$inFile"'/' $initFile

xspec - xspecinit.xcm

./$nhFile

popd

# How to get autocomplete of file and directory in user prompt
# https://stackoverflow.com/questions/4819819/get-autocompletion-when-invoking-a-read-inside-a-bash-script
