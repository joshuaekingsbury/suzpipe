#!/usr/bin/env bash


fromPath=$1
toPath=$2
productPrefix=$3
#toCopy=$3
#histFile=
#arfFile=
#rmfFile=
#nxbFile=
#regImgFile=

for sourceFile in "${@:4}"
do
	echo "to:: $productPrefix"
	echo "from $fromPath/$sourceFile"

	echo "to $toPath/$productPrefix$sourceFile"

	cp "$fromPath/$sourceFile" "$toPath/${productPrefix}${sourceFile}"

done


# Slice array of all input arguments
# https://unix.stackexchange.com/questions/82060/bash-slice-of-positional-parameters

# Terminal testing for loop one liner function for slicing all arguments
# https://www.cyberciti.biz/faq/linux-unix-bash-for-loop-one-line-command/

# working test to slice input arguments; starts at third argument
# re() { for i in "${@:3}"; do echo $i; done }




# Slice whole array variable
# https://stackoverflow.com/questions/1335815/how-to-slice-an-array-in-bash
