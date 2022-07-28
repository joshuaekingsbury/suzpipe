#!/usr/bin/env bash

ciState=$1

# Should these be switched to nxb file dates? They're newer than table

# Before; sciof
#lowerCut=2006-10-01
#lowerCut=2008-09-17
# Between; scion
#upperCut=2011-06-01
#upperCut=2011-06-02
# After; sci6

#caldb/data/suzaku/xis/bcf/

npmDate=20160128
#ae_xi1_npmsci6_20160128.fits
#ae_xi1_npmsciof_20160128.fits
#ae_xi1_npmscion_20160128.fits

nxbofDate=20080917
nxbonDate=20110602
nxb6Date=20160128

#ae_xi1_nxbscion_20110602.fits
#ae_xi1_nxbsciof_20080917.fits
#ae_xi1_nxbsci6_20160128.fits

#ae_xi1_nxbsci6_20160128_rejectnpm.fits
#ae_xi1_nxbscion_20110602_rejectnpm.fits


if [[ "$ciState" == "of" ]]
then
	nxbDate=${nxbofDate}
elif [[ "$ciState" == "on" ]]
then
	nxbDate=${nxbonDate}
else
	nxbDate=${nxb6Date}
fi

echo ${nxbDate}
