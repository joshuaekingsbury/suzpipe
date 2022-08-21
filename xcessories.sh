#!/usr/bin/env bash

#######################################
##!/usr/bin/env bash
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
## https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
echo $DIR
#########################################


echo "obsPath: $obsPath"

if [ -z $obsPath ]; then
    obsPath=$PWD
fi

fittingPath=${obsPath}/xspec

echo "Fitting Path: $fittingPath"

initFile=_xspecinit.xcm
nhFile=_getnh.sh

if [ -f $DIR/$initFile ]; then
    cp $DIR/$initFile $fittingPath
fi

if [ -f $DIR/$nhFile ]; then
    cp $DIR/$nhFile $fittingPath
fi

. xspecinit.sh
