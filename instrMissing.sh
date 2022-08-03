#!/usr/bin/env bash

# Check if XIS1 instrument collected any data (if xis1 files were downloaded)

pushd ${evtPath} >& /dev/null

shopt -s nullglob

xi1=(*xi1*)

shopt -u nullglob

popd >& /dev/null
	
if [ -z "$xi1" ]; then
	echo
	echo "No XIS1 files found at: ${evtPath}"
	echo
	return 1 2> /dev/null || exit 1

else
	echo
	echo "XIS1 files found at: ${evtPath}"

fi
