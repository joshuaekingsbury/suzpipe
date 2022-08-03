#!/usr/bin/env bash

# obs=$1
# dye=$2
# dyeDir=$3
# scriptPath=$4
# evtPath=$5
inFile=$1
outFile=$2
regPath=$3
sessionname=${4:-$(date +'%y%m%d')}

#numRegions=$(( $(wc -l < $regPath) - 2 ))
#echo $numRegions as number of regions

echo "Event Path: $evtPath"
echo "File Path?: $evtPath/$inFile"

if [ ! -f $evtPath/$inFile ]; then

	echo "No GTI file: $inFile found; cannot extract spectrum: $outFile"
	
	return 1 2> /dev/null || exit 1
fi

#[[ $numRegions -ne 0 ]] && echo true

pushd ${dyeDir}/${dye}_dye/ >& /dev/null

#[[ $numRegions -ne 0 ]] && xselect @${scriptPath}/extract_all.xco $obs $dye $evtPath $regPath $sessionname

#[[ ! $numRegions -ne 0 ]] && xselect @${scriptPath}/extract_all_no_reg.xco $obs $dye $evtPath $regPath $sessionname

if [ ! -f $outFile ]; then

	echo
	echo "No hist/spectrum $outFile found; Creating."

	xselect @${scriptPath}/extract_all.xco $obs $dye $evtPath $inFile $regPath $sessionname


	if [ ! -f $outFile ]; then
		echo
		echo "Failed to create: $outFile"
	else
		echo
		echo "Hist/spectrum file created: $outFile"
	fi

else
	echo
	echo "Hist/spectrum file already exists: $outFile"

fi

popd >& /dev/null
