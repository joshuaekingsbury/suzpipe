#!/usr/bin/env bash

dyePath=$1
inFile=$2
outFile=$3

pushd $dyePath >& /dev/null

if [ -f $outFile ]; then

	echo "rmf file already made"
	
else

	xisrmfgen $inFile $outFile
	
fi

popd >& /dev/null
