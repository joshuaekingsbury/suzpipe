#!/usr/bin/env bash

# Clean and merge 3x3 and 5x5

obs=$1
bcf=$2
GTI_file=${3:-xi1_events_GTI_${obs}.fits}
evtPath=/xis/event_cl
hkPath=/xis/hk

#need bad column file; GOT bcf

pushd ${obs}/${evtPath}

if [ ! -f $GTI_file ]; then

	echo "No GTI file found. Creating."

	shopt -s nullglob
	# https://stackoverflow.com/questions/33898250/glob-that-doesnt-match-anything-expands-to-itself-rather-than-to-nothing
	# -s:enable; -u:disable
	# set/unset


	x3=(ae${obs}xi1_0_3x3*_cl.evt)
	x5=(ae${obs}xi1_0_5x5*_cl.evt)
	
	echo "found(?) 5x5 -> ${x5[*]} <-"

	pset xisputpixelquality badcolumfile=${bcf}

	xisputpixelquality ${x3} badcolum_3x3_${obs}.fits
	ftcopy "badcolum_3x3_$obs.fits[EVENTS][STATUS=0:524287]" ftcopy_3x3_524287_${obs}.fits

	if [ ! -z "$x5" ] && [ -f $x5 ];
	then
		
		echo "5x5 ${x5[*]} found; merging."

		xisputpixelquality ${x5} badcolum_5x5_${obs}.fits
		ftcopy "badcolum_5x5_${obs}.fits[EVENTS][STATUS=0:524287]" ftcopy_5x5_524287_${obs}.fits

		####
		#
		####
		x5to3in=ftcopy_5x5_524287_${obs}.fits
		x5to3out=5x5to3x3_${obs}.fits
		x5to3hk=../hk/ae${obs}xi1_0.hk.gz

		xis5x5to3x3 ${x5to3in} ${x5to3out} ${x5to3hk}
		

		ftmerge "ftcopy_3x3_524287_${obs}.fits,${x5to3out}" merged_5to3_w_3_${obs}.fits

		ftmerge "merged_5to3_w_3_${obs}.fits[GTI],${x5to3out}[GTI]" merged_merged_5to3_w_3_${obs}.fits

		cp merged_merged_5to3_w_3_${obs}.fits ${GTI_file}

	else

		echo "No 5x5 found. Only 3x3 was used."

		cp ftcopy_3x3_524287_${obs}.fits ${GTI_file}

	fi

	shopt -u nullglob

	if [ -f $GTI_file ]; then
		echo "GTI file: $GTI_file created."
	else
		echo "Failed to create GTI file: $GTI_file."
	fi

	popd


else
	echo "GTI file already exists."
fi

