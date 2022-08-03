#!/usr/bin/env bash

outFile=$1
xspecPath=$2
inRelativePath=$3
histFile_dye=$4
arfFile_dye=$5
rmfFile_dye=$6
nxbFile_dye=$7
productPrefix=$8

irp=$inRelativePath
pp=$productPrefix

#GRPPHA can be  run  in  non-interactive  mode  by  separating commands  with  an  ampersand "&".

pushd $xspecPath >& /dev/null

pwd

echo ./$irp/${histFile_dye}

grppha infile=./$irp/${pp}${histFile_dye} outfile=${pp}${outFile} clobber=yes comm="chkey ANCRFILE ./$irp/${pp}$arfFile_dye & chkey RESPFILE ./$irp/${pp}$rmfFile_dye & chkey BACKFILE ./$irp/${pp}$nxbFile_dye & group min 25 & exit"

grppha infile=${pp}${outFile} outfile=${pp}${outFile} clobber=yes comm="show all & exit"

popd >& /dev/null
