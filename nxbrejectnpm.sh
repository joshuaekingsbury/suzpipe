#!/usr/bin/env bash


bcfPath=$1
outFile=$2
nxbID=$3
npmFile=$4
nxbFile=$5


# to return reject file
#? https://stackoverflow.com/questions/16338086/bash-return-value-from-subscript-to-parent-script

pushd ${bcfPath}
#echo $PWD
#check if reject file exists

if [[ -f $outFile ]]
then
	echo "nxb_rejectnpm file already exists: $outFile"

else

	echo "nxb_rejectnpm file: $outFile not found. Creating."
	
	
	tempFile=ae_xi1_nxbsci${nxbID}_badcolum.fits
	pset xisputpixelquality badcolumfile=${bcfPath}/${npmFile}
	xisputpixelquality ${nxbFile} ${tempFile}
	ftcopy "$tempFile[EVENTS][STATUS=0:524287]" ${outFile}
	rm ${tempFile}
	
	if [ -f $outFile ]
	then
		echo "nxb_rejectnpm file: $outFile created successfully."
	else
		echo "nxb_rejectnpm file: $outFile creation failed."
	fi
	
	
fi

popd
