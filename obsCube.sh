#!/usr/bin/env bash

######
#
    # Can be called from terminal with obs# as first argument and optional false to allow for manual region selection
#
######

#### wcstools is pre-req for the gethead tool so date can be obtained from fits file

#heainit
#caldbinit

# Path to suzaku working directory
#SUZ=/home/jokingspace/suzaku

# Path for current working observations; for download and reduction
#obsPath=$SUZ/SURP21/obs
#obsPath=$SUZ/eb_external/partial18
obs=$1
elo=${2:-400}	  # Preview image lower bound; eV
ehi=${3:-2000}  # Preview image upper bound; eV


workingDir=$PWD
export obsPath=$workingDir/$obs
evtPath=$obsPath/xis/event_cl


# Path to CALDB; /home/joking/suzaku/caldb
CALDB=$CALDB
bcfPath=$CALDB/data/suzaku/xis/bcf/


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


# Path to scripts
scriptPath=$DIR


if [ -z "$1" ]; then
    echo
    echo "No observation id provided to begin processing. Try again. ;)"
    echo
    return 1 2> /dev/null || exit 1
fi


## Expecting clean events file already run through xselect and copied into top level of obs dir
##     with select mkf; SAA==0 && T_SAA>436 && COR>8 && ELV>10 && DYE_ELV>20


post_selmkf_file=clean_events_${obs}_dye20.fits

########################### Check here if file exists


####
#   If CIAO is available, create data cubes by PI (energy) and by TIME (seconds)

if ((${#ASCDS_INSTALL[@]})); then

	echo
	echo "env variable ASCDS_INSTALL is assigned. Assuming CIAO is active."
	echo "Creating data cubes."

	dmlist "${obsPath}/${post_selmkf_file}[PI=110:548][bin X=::8,Y=::8,PI=::27]" cols
	dmcopy "${obsPath}/${post_selmkf_file}[PI=110:548][bin X=::8,Y=::8,PI=::27]" ${obsPath}/clean_events_dye20_cube_${obs}_400_2000_bin100eV.fits

	dmlist "${obsPath}/${post_selmkf_file}[PI=110:548][bin X=::8,Y=::8,TIME=::3600]" cols
	dmcopy "${obsPath}/${post_selmkf_file}[PI=110:548][bin X=::8,Y=::8,TIME=::3600]" ${obsPath}/clean_events_dye20_cube_${obs}_400_2000_bin3600s.fits

	dmlist "${obsPath}/${post_selmkf_file}[bin X=::8,Y=::8,TIME=::3600]" cols
	dmcopy "${obsPath}/${post_selmkf_file}[bin X=::8,Y=::8,TIME=::3600]" ${obsPath}/clean_events_dye20_cube_${obs}_full_band_bin3600s.fits

else

	echo
	echo "env variable ASCDS_INSTALL either not assigned or not declared. Assuming CIAO is inactive."
	echo "Not creating data cubes."

fi

