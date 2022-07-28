#!/usr/bin/env bash

obs=$1
dye=$2
dyeDir=$3
scriptPath=$4
evtPath=$5
inFile=$6
outFile=$7
regPath=$8
sessionname=${9:-$(date +'%y%m%d')}

#numRegions=$(( $(wc -l < $regPath) - 2 ))
#echo $numRegions as number of regions


if [ ! -f $evtPath/$inFile ]; then

	echo "No GTI file: $inFile found; cannot extract spectrum: $outFile"
	
	exit
fi

#[[ $numRegions -ne 0 ]] && echo true

pushd ${dyeDir}/${dye}_dye/

#[[ $numRegions -ne 0 ]] && xselect @${scriptPath}/extract_all.xco $obs $dye $evtPath $regPath $sessionname

#[[ ! $numRegions -ne 0 ]] && xselect @${scriptPath}/extract_all_no_reg.xco $obs $dye $evtPath $regPath $sessionname

if [ ! -f $outFile ]; then

	echo "No hist/spectrum $outFile found; Creating."

xselect @${scriptPath}/extract_all.xco $obs $dye $evtPath $inFile $regPath $sessionname


	if [ ! -f $outFile ]; then
		echo "Failed to create: $outFile"
	else
		echo "Hist/spectrum file created: $outFile"
	fi

else

	echo "Hist/spectrum file already exists: $outFile"

fi

popd
