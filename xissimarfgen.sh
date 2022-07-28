#!/usr/bin/env bash

dyePath=$1
regFile=$2
outFile=$3
histFile=$4
expmapFile=$5
attFile=$6
rmfFile=$7
badcolumfile=$8

pushd ${dyePath}

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
	phafile=${histFile} \
	detmask=${expmapFile} \
	gtifile=${histFile} \
	attitude=${attFile} \
	rmffile=${rmfFile} \
	estepfile=medium \
	badcolumfile=${badcolumfile}
	
fi

popd
