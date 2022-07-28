#!/usr/bin/env bash

obs=$1
obsDate=$2

pushd ${obs}/

mkdir reduced
mkdir xspec
mkdir xspec/models
mkdir xspec/source

echo ${obsDate}

if [[ "$obsDate" < "2011-01-01" ]]
then
	mkdir reduced/20_dye

	mkdir xspec/source/20_dye

else
	mkdir reduced/20_dye
	mkdir reduced/40_dye
	mkdir reduced/60_dye

	mkdir xspec/source/20_dye
	mkdir xspec/source/40_dye
	mkdir xspec/source/60_dye
fi

echo reduced/*_dye
