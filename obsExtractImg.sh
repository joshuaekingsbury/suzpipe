#!/usr/bin/env bash

# obs=$1
# dye=$2
# dyeDir=$3
# scriptPath=$4
# Need full path to event file
# evtPath=$5
inFile=$1
outFile=$2
sessionname=${3:-$(date +'%y%m%d')}


if [ ! -f ${evtPath}/${inFile} ]; then

	echo
	echo "No GTI file: ${evtPath}/${inFile} found; cannot extract image: $outFile"
	
	return 1 2> /dev/null || exit 1
fi

pushd ${dyeDir}/${dye}_dye/ >& /dev/null

if [ ! -f ${outFile} ]; then

	echo
	echo "No pre-region image file found: $outFile; Creating."

	pilo=$(echo "$elo/3.65" | bc -q) # PI-energy relation; PI=ev/3.65
	pihi=$(echo "$ehi/3.65" | bc -q)

	xselect @${scriptPath}/extract_image.xco $obs $dye $evtPath $sessionname $inFile $pilo $pihi $outFile

	if [ ! -f ${outFile} ]; then
		echo
		echo "Failed to create: $outFile"
	else
		echo
		echo "Pre-region image file created: $outFile"
	fi

else
	echo
	echo "Pre-region image file already exists: $outFile"

fi

popd >& /dev/null
