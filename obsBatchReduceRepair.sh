##!/usr/bin/env sh
#!/usr/bin/osascript

#heainit
#caldbinit
# for getting thses to register in a script (?)
# https://unix.stackexchange.com/questions/430255/command-not-available-in-bash-script

obsListFile=${1:-obsList.txt}
#autoRegionGen=${2:-false}

if [ ! -f $obsListFile ]; then
    echo "Observation ID list file: $obsListFile not found. Aborting."
    return 1 2> /dev/null || exit 1
fi


# script and file may require permissions given
# chmod 777 ./obsRetrieveReduce.sh
# chmod 777 ./testMultiTerm.shw
#xargs -0 -n1 ./obsRetrieveReduce.sh <npmTestList.txt

# Breaks inside script as it returns script instead of shell
#_shell="$( echo $0 | tr -d '-' )"



# Determine what (Bourne compatible) shell we are running under. Put the result
# in $_shell (not $SHELL) so further code can depend on the shell type.

if test -n "$ZSH_VERSION"; then
  _shell=zsh
elif test -n "$BASH_VERSION"; then
  _shell=bash
elif test -n "$KSH_VERSION"; then
  _shell=ksh
elif test -n "$FCEDIT"; then
  _shell=ksh
elif test -n "$PS3"; then
  _shell=unknown
else
  _shell=sh
fi

## Shell Check Above Borrowed from
# https://unix.stackexchange.com/a/72475


# bashinit includes heainit, caldbinit, condainit (for wget); batch processing requires being run in a bash shell

if [[ $_shell == "zsh" ]]; then

    ## Check if zsh, otherwise go old bash route
    #!/bin/zsh
    for line in "${(f)"$(<$obsListFile)"}"
    {
        echo $line

        osascript -e "on run argv
            tell application \"Terminal\"
                activate

                tell application \"System Events\" to keystroke \"t\" using command down
                    repeat
                        delay 0.1
                        if not busy of window 1 then exit repeat
                    end repeat

                tell application \"Terminal\" to do script \"exec bash;\" in selected tab of the front window
                repeat
                    delay 0.1
                    if not busy of window 1 then exit repeat
                end repeat
                
                # tell application \"Terminal\" to do script \"echo \" & quoted form of item 1 of argv & \";\" in selected tab of the front window
                #tell application \"Terminal\" to do script \"condainit; heainit; caldbinit;. obsRetrieveReduce.sh \" & quoted form of item 1 of argv & \";\" in selected tab of the front window
                #tell application \"Terminal\" to do script \"batchinit;. obsRetrieveReduce.sh \" & quoted form of item 1 of argv & \";\" in selected tab of the front window


                tell application \"Terminal\" to do script \"condainit\" in selected tab of the front window
                repeat
                    delay 0.1
                    if not busy of window 1 then exit repeat
                end repeat

                tell application \"Terminal\" to do script \"heainit\" in selected tab of the front window
                repeat
                    delay 0.1
                    if not busy of window 1 then exit repeat
                end repeat

                tell application \"Terminal\" to do script \"caldbinit\" in selected tab of the front window
                repeat
                    delay 0.1
                    if not busy of window 1 then exit repeat
                end repeat

                # tell application \"Terminal\" to do script \". obsRetrieveReduce.sh \" & item 1 of argv & \";\" in selected tab of the front window
                tell application \"Terminal\" to do script \". obsRetrieveReduceRepair.sh \" & item 1 of argv in selected tab of the front window

            end tell
        end run" $line

    }
else

    # Working version on linux
    #xargs -t -n1 -P4 -a $obsListFile . testMultiTerm.sh
    
    #echo $_shell
    while read -r line
    do
      gnome-terminal -- bash -c '. obsRetrieveReduceRepair.sh '$line'; exec bash'
    done < "$obsListFile"

fi



# <$obsListFile xargs -I {} -t -n1 -P5 $(. testMultiTerm.sh {})
# <$obsListFile xargs -t -n1 -P5 tester


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
