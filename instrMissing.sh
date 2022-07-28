#!/usr/bin/env bash

# Check if XIS1 instrument collected any data (if xis1 files were downloaded)

obs=$1
evtPath=/xis/event_cl

pushd ${obs}/${evtPath}

shopt -s nullglob

xi1=(*xi1*)

shopt -u nullglob

popd
	
if [ -z "$xi1" ];
then
	exit 1
fi
