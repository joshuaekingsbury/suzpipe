#!/usr/bin/env bash

# obs=$1
# dye=$2
# dyeDir=$3
# scriptPath=$4
# Need full path to event file
# evtPath=$5
inFile=$1
outFile=$2
regPath=$3
sessionname=${4:-$(date +'%y%m%d')}


if [ ! -f ${evtPath}/${inFile} ]; then

	echo
	echo "No GTI file: ${evtPath}/${inFile} found; cannot extract image: $outFile"
	
	return 1 2> /dev/null || exit 1
fi

pushd ${dyeDir}/${dye}_dye/ >& /dev/null

if [ ! -f ${outFile} ]; then

	echo
	echo "No post-region [masked] image file found: $outFile; Creating."

	pilo=$(echo "$elo/3.65" | bc -q) # PI-energy relation; PI=ev/3.65
	pihi=$(echo "$ehi/3.65" | bc -q)

	xselect @${scriptPath}/extract_image_masked.xco $obs $dye $evtPath $sessionname $inFile $pilo $pihi $outFile $regPath

	if [ ! -f ${outFile} ]; then
		echo
		echo "Failed to create: $outFile"
	else
		echo
		echo "Post-region [masked] image file created: $outFile"
	fi

else
	echo
	echo "Post-region [masked] image file already exists: $outFile"

fi

popd >& /dev/null
