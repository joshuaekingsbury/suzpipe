#!/usr/bin/env bash

dyePath=$1
inFile=$2
outFile=$3
attFilePath=$4

pushd $dyePath >& /dev/null

if [ -f $outFile ]; then

	echo "expmap file already made"
	
else

	xisexpmapgen $outFile $inFile $attFilePath
	
fi

popd >& /dev/null
