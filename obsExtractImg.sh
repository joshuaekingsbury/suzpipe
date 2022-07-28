#!/usr/bin/env bash

obs=$1
dye=$2
dyeDir=$3
scriptPath=$4
# Need full path to event file
evtPath=$5
inFile=$6
outFile=$7
sessionname=${8:-$(date +'%y%m%d')}


if [ ! -f ${evtPath}/${inFile} ]; then

	echo "No GTI file: ${evtPath}/${inFile} found; cannot extract image: $outFile"
	
	exit
fi

pushd ${dyeDir}/${dye}_dye/

if [ ! -f ${outFile} ]; then

	echo "No pre-region image file found: $outFile; Creating."

	xselect @${scriptPath}/extract_image.xco $obs $dye $evtPath $sessionname $inFile $outFile

	if [ ! -f ${outFile} ]; then
		echo "Failed to create: $outFile"
	else
		echo "Pre-region image file created: $outFile"
	fi

else

	echo "Pre-region image file already exists: $outFile"

fi

popd
