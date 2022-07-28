obs=$1

shopt -s nullglob

evtFiles=(${obs}/xis/event_cl/ae${obs}*3x3*_cl.evt)
#echo ${evtFiles[@]}
oneEvtFile=${evtFiles[0]}

shopt -u nullglob

targ=$(gethead OBJECT ${oneEvtFile})

lower=$( echo "$targ" | awk '{print tolower($0)}' )
# https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash

nonalphanumToUnderscore=$( echo $lower | tr -c [:alnum:] _ )
# https://stackoverflow.com/questions/50876687/replace-all-non-alphanumeric-characters-in-a-string-with-an-underscore

echo $nonalphanumToUnderscore
