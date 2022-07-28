#!/usr/bin/env bash


# run this file with:
# ./heasoftPrereqTest.sh

# if permission is denied you may have to first run:
# chmod 777 heasoftPrereqTest.sh


####
#
####

brewPath=$(which brew)

[ -z $brewPath ] && echo "No brew found."; echo
[ ! -z $brewPath ] && brew --version; echo

####
#
####

xquartzPath=$(which xquartz)

[ -z $xquartzPath ] && echo "No xquartz found."; echo
[ ! -z $xquartzPath ] && xquartz --version; echo

####
#
####

XQuartzPath=$(which XQuartz)

[ -z $XQuartzPath ] && echo "No XQuartz found."; echo
[ ! -z $XQuartzPath ] && XQuartz --version; echo

####
#
####

gccPath=$(which gcc)

[ -z $gccPath ] && echo "No gcc found."; echo
[ ! -z $gccPath ] && gcc --version; echo


####
#
####

gppPath=$(which g++)

[ -z $gppPath ] && echo "No g++ found."; echo
[ ! -z $gppPath ] && g++ --version; echo


####
#
####

gfortranPath=$(which gfortran)

[ -z $gfortranPath ] && echo "No gfortran found."; echo
[ ! -z $gfortranPath ] && gfortran --version; echo

####
#
####

perlPath=$(which perl)

[ -z $perlPath ] && echo "No perl found."; echo
[ ! -z $perlPath ] && perl --version; echo

####
#
####

python3Path=$(which python3)

[ -z $python3Path ] && echo "No python3 found."; echo
[ ! -z $python3Path ] && python3 --version; echo
