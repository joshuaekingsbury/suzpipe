#!/usr/bin/env bash

# obs=$1
# obsDate=$2
# obsPath=$3

pushd ${obsPath} >& /dev/null

mkdir reduced
mkdir xspec

echo
echo "Preparing directories according to obs date: ${obsDate}"

if [[ "$obsDate" < "2011-01-01" ]]
then
	mkdir reduced/20_dye
	mkdir xspec/20_dye

else
	mkdir reduced/20_dye
	mkdir reduced/40_dye
	mkdir reduced/60_dye

	mkdir xspec/20_dye
	mkdir xspec/40_dye
	mkdir xspec/60_dye
fi

echo reduced/*_dye

popd >& /dev/null
