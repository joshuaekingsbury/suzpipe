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
_shell=$( echo $0 | tr -d '-' )

if[[ "$_shell" == "zsh" ]]; then

    ## Check if zsh, otherwise go old bash route
    #!/bin/zsh
    for line in "${(f)"$(<$obsListFile)"}"
    {
        num_tab=2
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
                
                item 1 of argv

                # tell application \"Terminal\" to do script \"echo \" & quoted form of item 1 of argv & \";\" in selected tab of the front window
                tell application \"Terminal\" to do script \"heainit;caldbinit;. obsRetrieveReduce.sh \" & quoted form of item 1 of argv & \";\" in selected tab of the front window

            end tell
        end run" $line

        num_tab=$num_tab+1

    }
else

    # Working version on linux
    xargs -t -n1 -P4 -a $obsListFile . testMultiTerm.sh

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
