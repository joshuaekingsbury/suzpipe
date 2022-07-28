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
obsPath=$PWD

# Path to CALDB; /home/joking/suzaku/caldb
CALDB=$CALDB
bcfPath=$CALDB/data/suzaku/xis/bcf/
evtPath=/xis/event_cl

# Path to scripts
scriptPath=$obsPath

obs=$1
processedOn=${2:-""}
#productPrefix=${2:-""}
productPrefix=""
autoRegBool=${3:-false}
#autoRegBool=${2:-false}

echo ${productPrefix: -1}
echo "_____"

if [ "${productPrefix: -1}" != "_" ] && [ "$productPrefix" != "" ]; then
	productPrefix="${productPrefix}_"
	echo "Appended \"_\" to prefix of product files."
fi

echo "Prefix of product files: $productPrefix"

if [[ "$processedOn" -eq "" ]]; then
	processedOn=$(date +'%y%m%d')
fi

echo "Given this/these observations: ${obs[*]}"


####
#   Download the ql images for the observation
####
obsqlimgURL="https://data.darts.isas.jaxa.jp/pub/Astro_Browse/quick_look/suzaku/image/${obs}.png"
obsqlxisimgURL="https://data.darts.isas.jaxa.jp/pub/suzaku/ver2/${obs}/xis/products/ae${obs}xis_0_im.gif"

wget -c -P ${obsPath}/${obs} $obsqlimgURL
wget -c -P ${obsPath}/${obs} $obsqlxisimgURL


####
#   If the observation directory doesn't exist, download it via FTP
#   (Works)
####
. getObs.sh ${obs} &
wait $!


####
#   Script echos if no xis1 data file found; echo is assigned to xis1DataCheck and triggers exit of this script
####
#chmod 777 instrMissing.sh
. instrMissing.sh ${obs}
xis1DataCheck=$?
wait $!

if [ $xis1DataCheck != 0 ];
then
	echo "No XIS1 data found in relative working directory."
	echo "Exiting reduction procedures."
	exit
fi


####
#   Extract (gunzip) event files from gz files
####
#chmod 777 obsExtractEvt.sh
. obsExtractEvt.sh ${obs}/${evtPath}
wait $!
echo
echo "Events extracted for $obs."
echo

####
#   Get observation date for time sensitive processing steps
####
chmod 777 obsDate.sh
obsDate=$( . obsDate.sh ${obs} )
wait $!
echo
echo "$obsDate retrieved for $obs."
echo

####
#   
####
#chmod 777 getCI.sh
sci=$( . getCI.sh ${obs} )
wait $!

echo
echo "sci state: $sci"
echo

####
#   
####
chmod 777 getnxbDate.sh
nxbDate=$( . getnxbDate.sh ${sci} )
wait $!

nxbID=${sci}_${nxbDate}

echo
echo "nxb ID $nxbID retrieved for $obs observed $obsDate."
echo

nxbbcfFile=ae_xi1_nxbsci${nxbID}.fits

## Should check if file exists

####
#   Determine bad colum file (npm; noisy pixel file) from CALDB
#   Use observation date to determine which sci state of bcf is needed
####

npmDate=20160128
npmID=${sci}_${npmDate}
npmbcfFile=ae_xi1_npmsci${npmID}.fits

echo "npm file: ${npmbcfFile}"
echo "nxb file: ${nxbbcfFile}"

## Should check if file exists


########################
pset xisputpixelquality badcolumfile=${bcfPath}/${npmbcfFile}
wait $!

####
#   Combine the 5x5 and 3x3 event files
#   Use the bad colum file (npm; noisy pixel file) to 
#    remove noisy (suspect?) pixels while merging
#   Pass in name for final event file product; GTI_file
####

GTI_file=xi1_events_GTI_${obs}.fits

chmod 777 merge5to3.sh
. merge5to3.sh ${obs} ${bcfPath}/${npmbcfFile} ${GTI_file}
wait $!
GTI_path=${obsPath}/${obs}/${evtPath}/${GTI_file}


########################### Check here if GTI file exists

####
#   Make extra working directories
#   Including directories for each dye for which obs will be reduced
#   Since num of DYEs is time sensitive, they are defined and checked,
#    inside mkPipelineDirs.sh; but could define them elsewhere for
#    for easier reference through rest of script
####

#chmod 777 mkPipelineDirs.sh
. mkPipelineDirs.sh ${obs} ${obsDate}
wait $!
####
#   Set path to DYE base dir where will be reduced
#   Create list of DYE dir(s)
#   Create list of DYE values
####
dyeDir=${obs}/reduced/
pushd ${dyeDir}
dyeDirList=( *_dye )
popd
dyes=()

for d in ${dyeDirList[*]}
do
	dyes+=(${d%_dye})
	echo ${dyes[*]}
done
wait $!

for d in ${dyes[*]}
do
	echo $d
done
wait $!

# https://stackoverflow.com/questions/20669033/how-to-get-wildcard-portion-of-filename-in-bash


####
#   Check to see if a hist file exists, if so what date, and if we want to try continuing using files from this date
#   basically only updates $processedOn variable, lets frun from there
####

obsProductPath=${dyeDir}/20_dye/
pushd "$obsProductPath"
echo
echo $obsProductPath

shopt -s nullglob

# #####
# exit
# #####
histFiles=( *hist.xsl )
echo ${histFiles[@]}
oneHistFile=${histFiles[0]}

echo ${histFiles[@]}

shopt -u nullglob

if [[ ! -z "$oneHistFile" ]] && [ -f "$oneHistFile" ];
then
	previouslyProcessedDate=${oneHistFile%%_hist.xsl}
	previouslyProcessedDate=${previouslyProcessedDate##*_}
	
	echo $previouslyProcessedDate
	
	echo "Previous hist file(s) found: "
	echo ${histFiles[@]}
	echo
	
	#doesn't allow selection of second date or other complex stuff, need this now to quick repair files, can expand later
	read -e -p $'-Leave blank or y for first date \n-any other input to reduce from scratch \n\nEnter selection: \n\n' promptIn

	if [[ -z "$promptIn" ]] || [ "$promptIn" == "y" ]; then
		processedOn=$previouslyProcessedDate
	#elif [[ ! -z "$promptIn" ]];
	#then
	#	processedOn=$promptIn
	fi
	
	# Leave $processedOn assigned to today's date
	
fi

popd
echo
echo $processedOn

####
#   
####

sessionID=${obs}_.DYE._${processedOn}

preRegImg=0_4-2_0_image_${obs}_dye.NUM..fits

#chmod 777 obsExtractImg.sh
for dye in ${dyes[*]}
do
	. obsExtractImg.sh ${obs} ${dye} ${dyeDir} ${scriptPath} ${obsPath}/${obs}/${evtPath} ${GTI_file} ${preRegImg/.NUM./$dye} ${processedOn}
	wait $!
done







#####
exit
#####






####
#   Generate a region file to exclude areas of unusually high emission,
#    suggesting unresolved point source contamination
#   Use lowest dye since it had more data;
#    this region file will be used to exclude for all other dye's
####

# I'm hardcoding the smallest dye; in future would want to get
#  dye list and find minimum
dyeMin=20

echo "Minimum DYE used to generate region file: $dyeMin. (Hardcoded for now)"

obsRegPath=${dyeDir}/${dyeMin}_dye/
obsDS9=${obs}_${dyeMin}_${processedOn}..EXT.
obsReg=${obsDS9/.EXT./reg}

#chmod 777 genRegions.sh

echo ${preRegImg/.NUM./$dyeMin}

./genRegions.sh ${obs} ${dyeMin} ${dyeDir}/${dyeMin}_dye ${preRegImg/.NUM./$dyeMin} ${obsDS9} ${autoRegBool}

wait $!

# copy dye 20 image to all reduced dye folders
for dye in ${dyes[*]}
do
	cp ./${obsRegPath}/${obsDS9/.EXT./png} ${dyeDir}/${dye}_dye/${obsDS9/.EXT./png}
	wait $!
done

# copy dye image and region file to obs directory for easy reference/access

cp ./${obsRegPath}/${obsDS9/.EXT./png} ./${obs}/${obsDS9/.EXT./png}
cp ./${obsRegPath}/${obsDS9/.EXT./reg} ./${obs}/${obsDS9/.EXT./reg}

###################
#exit
###################
# https://stackoverflow.com/questions/13210880/replace-one-substring-for-another-string-in-shell-script
# https://linuxhint.com/wait_command_linux/

productTemplate=${obs}_DYE_${processedOn}_PRODUCT.xsl
histFile=${productTemplate/PRODUCT/hist}
rmfFile=${productTemplate/PRODUCT/rmf}
expmapFile=${productTemplate/PRODUCT/expmap}
arfFile=${productTemplate/PRODUCT/arf}
nxbFile=${productTemplate/PRODUCT/nxb}
grpphaFile=${productTemplate/PRODUCT/grppha}


####
#   Obtain the hist file; 
####

chmod 777 obsExtractAll.sh
for dye in ${dyes[*]}
do
	./obsExtractAll.sh ${obs} ${dye} ${dyeDir} ${scriptPath} ${obsPath}/${obs}/${evtPath} ${GTI_file} ${histFile/DYE/$dye} ${obsPath}/${obs}/${obsDS9/.EXT./reg} ${processedOn}
	wait $!
done

####
#   Obtain the rmf file; 
####

chmod 777 xisrmfgen.sh
for dye in ${dyes[*]}
do
	./xisrmfgen.sh ${dyeDir}/${dye}_dye ${histFile/DYE/$dye} ${rmfFile/DYE/$dye}
	wait $!
done


####
#   Obtain the expmap file; 
####

chmod 777 xisexpmapgen.sh
for dye in ${dyes[*]}
do
	./xisexpmapgen.sh ${dyeDir}/${dye}_dye ${histFile/DYE/$dye} ${expmapFile/DYE/$dye} ${obsPath}/${obs}/auxil/ae${obs}.att.gz
	wait $!
done


####
#   Fetch proper bad colum file path (npm; noisy pixel file) from CALDB
#   Use observation date to determine which sci state of bcf is needed
####

rejectFile=ae_xi1_nxbsci${nxbID}_rejectnpm.fits

chmod 777 nxbrejectnpm.sh
./nxbrejectnpm.sh ${bcfPath} ${rejectFile} ${nxbID} ${npmbcfFile} ${nxbbcfFile}
wait $!


### Ignore this block
#nxbrejectnpmfile=$( ./nxbrejectnpm.sh ${obsDate} ${bcfPath} ${scriptPath} )
#nxbrejectnpmfile=${nxbrejectnpmfile[-1]}
#temp=${nxbrejectnpmfile#*.STARTRETURN.}
#nxbrejectnpmfile=${temp%.ENDRETURN.*}

echo
echo "Time sensitive nxbevent file located:"
echo ${rejectFile}
echo

## Should check if file exists

# https://reactgo.com/bash-get-last-element-of-array/#:~:text=To%20get%20the%20last%20element%20(5)%20from%20the%20array%2C,to%20access%20the%20last%20element.


####
#   Generate nxb file; Non-Xray Background(?)
#   Moved before simarfgen because this step can fail,
#    rendering !long! simarfgen time(s) wasted 
####
chmod 777 xisnxbgen.sh
for dye in ${dyes[*]}
do
	./xisnxbgen.sh ${dyeDir}/${dye}_dye ${obsPath}/${obs}/${obsDS9/.EXT./reg} ${nxbFile/DYE/$dye} ${histFile/DYE/$dye} ${obsPath}/${obs}/auxil/ae${obs}.att.gz ${obsPath}/${obs}/auxil/ae${obs}.orb.gz ${bcfPath}/${rejectFile}
	wait $!
done



####################
#exit
####################
####
#   Simulate/generate arf file; 
####

chmod 777 xissimarfgen.sh
for dye in ${dyes[*]}
do
	./xissimarfgen.sh ${dyeDir}/${dye}_dye ${obsPath}/${obs}/${obsDS9/.EXT./reg} ${arfFile/DYE/$dye} ${histFile/DYE/$dye} ${expmapFile/DYE/$dye} ${obsPath}/${obs}/auxil/ae${obs}.att.gz ${rmfFile/DYE/$dye} ${bcfPath}/${npmbcfFile}
	wait $!
done

####
#   Copy reduced data products to xspec directory structure
#    for spectral fitting and easier sharing
#   Expecting to find ds9 region png in observation folder for wuick checking
####

chmod 777 cpProductsToXspecPath.sh

for dye in ${dyes[*]}
do

	#toCopy=( ${histFile/DYE/$dye} ${arfFile/DYE/$dye} ${rmfFile/DYE/$dye} ${nxbFile/DYE/$dye} ./${obsRegPath}/${obsDS9/.EXT./png} )

	# Scrap this, can't pass array (except by reference which only works local(?)
	#toCopy=( ${histFile/DYE/$dye} ${obsDS9/.EXT./png} )

	echo $productPrefix

	./cpProductsToXspecPath.sh ${dyeDir}/${dye}_dye ${obs}/xspec/source/${dye}_dye "${productPrefix}" ${histFile/DYE/$dye} ${arfFile/DYE/$dye} ${rmfFile/DYE/$dye} ${nxbFile/DYE/$dye} ${obsDS9/.EXT./png} 
	wait $!
done

wait $!

pwd

####
#   Generate grppha file
####

chmod 777 grpphaMake.sh

for dye in ${dyes[*]}
do

	pwd

	./grpphaMake.sh ${grpphaFile/DYE/$dye} ./${obs}/xspec/source /${dye}_dye ${histFile/DYE/$dye} ${arfFile/DYE/$dye} ${rmfFile/DYE/$dye} ${nxbFile/DYE/$dye} ${productPrefix}
	wait $!
done


