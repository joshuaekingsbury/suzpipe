#!/usr/bin/env bash

outFile=$1
xspecPath=$2
inRelativePath=$3
histFile=$4
arfFile=$5
rmfFile=$6
nxbFile=$7
productPrefix=$8

irp=$inRelativePath
pp=$productPrefix

#GRPPHA can be  run  in  non-interactive  mode  by  separating commands  with  an  ampersand "&".

pushd $xspecPath

pwd

echo ./$irp/${histFile}

grppha infile=./$irp/${pp}${histFile} outfile=${pp}${outFile} clobber=yes comm="chkey ANCRFILE ./$irp/${pp}$arfFile & chkey RESPFILE ./$irp/${pp}$rmfFile & chkey BACKFILE ./$irp/${pp}$nxbFile & group min 25 & exit"

grppha infile=${pp}${outFile} outfile=${pp}${outFile} clobber=yes comm="show all & exit"

popd
