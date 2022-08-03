#!/usr/bin/env bash

dyePath=$1
regFile=$2
outFile=$3
histFile_dye=$4
attFile=$5
orbFile=$6
nxbEvent=$7

#pset xisnxbgen nxbevent=${nxbEvent}

pushd ${dyePath} >& /dev/null

if [ -f $outFile ]; then

	echo "nxb file already exists."
else

	xisnxbgen \
	outfile=${outFile} \
	phafile=${histFile_dye} \
	region_mode=SKYREG \
	regfile=${regFile} \
	orbit=${orbFile} \
	attitude=${attFile} \
	nxbevent=${nxbEvent}
	
fi

popd >& /dev/null
