#!/usr/bin/env bash

dyePath=$1
inFile=$2
outFile=$3

pushd $dyePath

if [ -f $outFile ]; then

	echo "rmf file already made"
	
else

	xisrmfgen $inFile $outFile
	
fi

popd
