#!/usr/bin/env bash

dyePath=$1
regFile=$2
outFile=$3
histFile_dye=$4
expmapFile_dye=$5
attFile=$6
rmfFile_dye=$7
badcolumfile=$8

pushd ${dyePath} >& /dev/null

if [ -f $outFile ]; then

	echo "arf file already made."
	
else

	#pset xissimarfgen badcolumfile=${badcolumfile}

	xissimarfgen \
	instrume=XIS1 \
	pointing=AUTO \
	source_mode=J2000 \
	source_ra=148.833 \
	source_dec=69.85 \
	num_region=1 \
    region_mode=SKYREG \
	regfile1=${regFile} \
	arffile1=${outFile} \
	limit_mode=NUM_PHOTON \
	num_photon=400000 \
	phafile=${histFile_dye} \
	detmask=none \
	gtifile=${histFile_dye} \
	attitude=${attFile} \
	rmffile=${rmfFile_dye} \
	estepfile=medium \
	badcolumfile=${badcolumfile}
	
fi

popd >& /dev/null
