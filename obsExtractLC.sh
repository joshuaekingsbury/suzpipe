#!/usr/bin/env bash

# obs=$1
# dye=$2
# dyeDir=$3
# scriptPath=$4
# Need full path to event file
# evtPath=$5


inFile=$1

outUnmasked=$2
outFullUnmasked=$3
outMasked=$4
outFullMasked=$5

sessionname=${6:-$(date +'%y%m%d')}

#251201 does not find because there was a reason I don't remember why I hesitated moving or copying the 
# xi1_events_GTI_100038010.fits file into the root obs directory

## commenting this out of obsRetrieveReduce.sh for now
if [ ! -f ${inFile} ]; then

	echo
	echo "No clean event file: ${inFile} found; cannot extract light curve(s)"
	
	return 1 2> /dev/null || exit 1
fi




#outUnmasked
outFile=${outUnmasked}
if [ ! -f ${outFile} ]; then

	echo
	echo "No pre-region light curve file found: $outFile; Creating."

	pilo=$(echo "$elo/3.65" | bc -q) # PI-energy relation; PI=eV/3.65
	pihi=$(echo "$ehi/3.65" | bc -q)

	xselect @${scriptPath}/extract_light_curve_prereg_400_2000.xco $obs $dye $obsPath $sessionname $inFile $pilo $pihi $outFile

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
