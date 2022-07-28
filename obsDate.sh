#!/usr/bin/env bash

#Get obs date and return/assign
# https://unix.stackexchange.com/questions/84381/how-to-compare-two-dates-in-a-shell

obs=$1

shopt -s nullglob

evtFiles=(${obs}/xis/event_cl/ae${obs}*3x3*_cl.evt)
#echo ${evtFiles[@]}
oneEvtFile=${evtFiles[0]}

shopt -u nullglob

obsDate=$(gethead DATE-OBS ${oneEvtFile})

# For a date formatted YYYY-MM-DDThh:mm:ss
# Get the YYYY-MM-DD, first 10 characters
obsDate=${obsDate:0:10}

echo $obsDate

