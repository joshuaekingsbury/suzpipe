#!/usr/bin/env bash

obs=$1
obsTypeID=${obs:0:1}
obsBasePathFTP=https://heasarc.gsfc.nasa.gov/FTP/suzaku/data/obs/${obsTypeID}//${obs}/

#auxil="/auxil"
#xis="/xis"

#wget -q -nH --show-progress --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*'      -erobots=off --retr-symlinks      $obsBasePathFTP$xis

#echo "xis download for $obs complete."

#wget -q -nH --show-progress --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*'      -erobots=off --retr-symlinks      $obsBasePathFTP$auxil

#echo "auxil download for $obs complete."

#Check if obs dir exists
#if [[ -d ./${obs} ]]
#then
#	echo "$obs directory exists. Skipping download."
#else
	wget -q -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -np -nc -erobots=off --retr-symlinks --show-progress -A *.att.gz,*.hk.gz,*.orb.gz,*.evt.gz,*.gti.gz,*.mkf.gz -R 'index*',*_uf*,*xi0*,*xi2*,*xi3*,*hxd* $obsBasePathFTP
	echo "$obs downloaded."
#fi
