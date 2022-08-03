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
	source_mode=UNIFORM \
	source_rmin=0 \
	source_rmax=20 \
	num_region=1 \
        region_mode=SKYREG \
	regfile1=${regFile} \
	arffile1=${outFile} \
	limit_mode=MIXED \
	num_photon=2000000 \
	accuracy=0.005 \
	phafile=${histFile_dye} \
	detmask=${expmapFile_dye} \
	gtifile=${histFile_dye} \
	attitude=${attFile} \
	rmffile=${rmfFile_dye} \
	estepfile=medium \
	badcolumfile=${badcolumfile}
	
fi

popd >& /dev/null
