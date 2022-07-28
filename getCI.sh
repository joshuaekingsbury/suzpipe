#!/usr/bin/env bash

obs=$1

shopt -s nullglob

evtFiles=( ${obs}/xis/event_cl/ae${obs}*3x3*_cl.evt )
oneEvtFile=${evtFiles[0]}

shopt -u nullglob

obsDate=$(gethead DATE-OBS ${oneEvtFile})
# For a date formatted YYYY-MM-DDThh:mm:ss
# Get the YYYY-MM-DD, first 10 characters
obsDate=${obsDate:0:10}

# How to determine ci states
# https://heasarc.gsfc.nasa.gov/docs/suzaku/analysis/abc/node8.html#SECTION00826100000000000000


ciState=$(gethead CI ${oneEvtFile})

ciSelection=""

scion2v6encodeSwitchDate=2011-04-01
## I checked, only one observation of this time; 505092070; 3-29 to 4-02
## obs before and after also have 069 microcode and "b" submode ID
# So, this date works for either 2v6 determination criteria and both methods work relative to this date


if [[ $ciState == 0 ]]; then
	#echo "CI state was inactive."
	ciSelection=of
else
	#echo "CI state was active."
## Assume CI=2 and we're determining 2keV or 6keV

	if [[ "$obsDate" < "$scion2v6encodeSwitchDate" ]]; then
	
		#echo "ObsDate: $obsDate was before $scion2v6encodeSwitchDate"
		#echo "Checking file name for submode ID; b=2keV, u=6keV"
	
		shopt -s nullglob
	
		containsb=( ${obs}/xis/event_cl/ae${obs}*3x3*b*_cl.evt ) # 2keV
		containsu=( ${obs}/xis/event_cl/ae${obs}*3x3*u*_cl.evt ) # 6keV
		
		shopt -u nullglob
		
		if [[ ! -z "$containsb" ]]; then
			ciSelection=on
			#echo "Submode ID = b"
		fi
		
		if [[ ! -z "$containsu" ]]; then
			ciSelection=6
			#echo "Submode ID = u"
		fi
		
		if [[ -z "$containsb" ]] && [[ -z "$containsu" ]]; then
			#echo "Unable to determine CI state from submode ID"
			:
		fi
		
	
	else
		microCode=$(gethead CODE_ID ${oneEvtFile})

		if [[ "$microCode" > 129 ]] && [[ $microCode < 139 ]]; then
			ciSelection=6
			#echo "Microcode: $microCode means CI=6keV"
		else
			ciSelection=on
			#echo "Microcode: $microCode not within range identifying 6keV."
			#echo "CI=2keV determined"
		fi
	fi
fi

#echo "For obs: $obs with event file name: $oneEvtFile,"
#echo "CI state determined to be: $ciSelection"

echo $ciSelection
