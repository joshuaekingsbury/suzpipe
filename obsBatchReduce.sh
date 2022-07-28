#!/usr/bin/env bash

heainit
caldbinit
# for getting thses to register in a script (?)
# https://unix.stackexchange.com/questions/430255/command-not-available-in-bash-script

obsListFile=${1:-obsList.txt}
#autoRegionGen=${2:-false}

#Move root paths to here





# script and file may require permissions given
chmod 777 ./obsRetrieveReduce.sh
chmod 777 ./testMultiTerm.sh
#xargs -0 -n1 ./obsRetrieveReduce.sh <npmTestList.txt

# Working version
xargs -t -n1 -P4 -a $obsListFile ./testMultiTerm.sh

#Too pass a second argument aside from observation num
#xargs -t -n1 -I{} -P4 -a $obsListFile ./testMultiTerm.sh {} $autoRegionGen

# https://til.hashrocket.com/posts/mqglzlgqmy-two-arguments-in-a-command-with-xargs-and-bash-c



###### One-by-one Part 1

#Make functions to call parts or all
#obsList=()
#while IFS= read -r line || [[ "$line" ]]; do
#  obsList+=("$line")
#done <$obsListFile


###### One-by-one Part 2

#for obs in ${obsList[*]}
#do
#	echo "Beginning observation: $obs"
#	./obsRetrieveReduce.sh ${obs}
#	wait $!
#	echo "Completed observation: $obs"
#done


# https://stackoverflow.com/questions/30988586/creating-an-array-from-a-text-file-in-bash
