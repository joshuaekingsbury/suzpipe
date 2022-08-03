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
obsPath=$workingDir/$obs
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

wget -c -P ${obsPath} $obsqlimgURL
wget -c -P ${obsPath} $obsqlxisimgURL



####
#   If the observation directory doesn't exist, download it via FTP
#   (Works)
####
. getObs.sh # ${obs} &
wait $!



####
#   Script echos if no xis1 data file found; echo is assigned to xis1DataCheck and triggers exit of this script
####
#chmod 777 instrMissing.sh
. instrMissing.sh # ${obs} ${evtPath}
xis1DataCheck=$?
wait $!

if [ $xis1DataCheck != 0 ];
then
	echo
	echo "No XIS1 data found in relative working directory."
	echo "Exiting reduction procedures."
	return 1 2> /dev/null || exit 1
fi




####
#   Extract (gunzip) event files from gz files
####
#chmod 777 obsExtractEvt.sh
. obsExtractEvt.sh # ${obsPath}/${evtPath}
wait $!
echo
echo "Events extracted for $obs."
echo


####
#   Get observation date for time sensitive processing steps
####
#chmod 777 obsDate.sh
#obsDate=$( . obsDate.sh  )
. obsDate.sh
wait $!
echo
echo "$obsDate retrieved for $obs."
echo



####
#   
####
#chmod 777 getCI.sh
#sci=$( . getCI.sh ${obs} )
. getCI.sh
wait $!
echo
echo "sci state: $sci"
echo

####
#   
####

echo "Identifying appropriate NXB and NPM file names."

#chmod 777 getnxbDate.sh
# nxbDate=$( . getnxbDate.sh ${sci} )
. getnxbDate.sh
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
if [ ! -f $bcfPath/$npmbcfFile ]; then

	echo
	echo "Expecting NPM file: $npmbcfFile"
	echo "Not found at: $bcfPath"

	return 1 2> /dev/null || exit 1

fi

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

#chmod 777 merge5to3.sh
. merge5to3.sh # ${obs} ${bcfPath}/${npmbcfFile} ${evtPath} ${GTI_file}
wait $!
GTI_path=${evtPath}/${GTI_file}

########################### Check here if GTI file exists

####
#   Make extra working directories
#   Including directories for each dye for which obs will be reduced
#   Since num of DYEs is time sensitive, they are defined and checked,
#    inside mkPipelineDirs.sh; but could define them elsewhere for
#    for easier reference through rest of script
####

#chmod 777 mkPipelineDirs.sh
. mkPipelineDirs.sh # ${obs} ${obsDate} ${obsPath}
wait $!
####
#   Set path to DYE base dir where will be reduced
#   Create list of DYE dir(s)
#   Create list of DYE values
####



dyeDir=${obsPath}/reduced

pushd ${dyeDir} >& /dev/null
dyeDirList=( *_dye )
popd >& /dev/null
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



obsProductPath=${dyeDir}/20_dye
pushd $obsProductPath >& /dev/null
echo
echo $obsProductPath

shopt -s nullglob

histFiles=( *hist.xsl )
echo ${histFiles[@]}
oneHistFile=${histFiles[0]}

shopt -u nullglob

if [[ ! -z "$oneHistFile" ]] && [ -f "$oneHistFile" ];
then
	previouslyProcessedDate=${oneHistFile%%_hist.xsl}
	previouslyProcessedDate=${previouslyProcessedDate##*_}
	
	echo
	echo "Previously Processed Date: $previouslyProcessedDate"
	
	echo
	echo "Previous hist file(s) found: "
	echo ${histFiles[@]}
	
	#doesn't allow selection of second date or other complex stuff, need this now to quick repair files, can expand later
	read -e -p $'-Leave blank or y for first date \n-any other input to reduce from scratch \n\nEnter selection: \n\n' promptIn

	if [[ -z "$promptIn" ]] || [ "$promptIn" == "y" ]; then
		processedOn=$previouslyProcessedDate
	#elif [[ ! -z "$promptIn" ]];
	#then
	#	processedOn=$promptIn
	fi
	
	# Leave $processedOn assigned to today's date

else
	echo 
	echo "No previous hist files found."
fi

popd >& /dev/null
echo
echo "Processed on: $processedOn"


####
#   
####

#sessionID=${obs}_.DYE._${processedOn}

preRegImg=${elo}-${ehi}_image_${obs}_dye.NUM..fits





#chmod 777 obsExtractImg.sh
for dye in ${dyes[*]}
do
	# ./obsExtractImg.sh ${obs} ${dye} ${dyeDir} ${scriptPath} ${evtPath} ${GTI_file} ${preRegImg/.NUM./$dye} ${processedOn}
	. obsExtractImg.sh ${GTI_file} ${preRegImg/.NUM./$dye} ${processedOn}
	wait $!
done





#####
#exit
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

obsRegPath=${dyeDir}/${dyeMin}_dye
obsDS9=${obs}_${dyeMin}_${processedOn}..EXT.
obsReg=${obsDS9/.EXT./reg}

#chmod 777 genRegions.sh


##### Should check for region in top folder instead of lower folders...

echo ${preRegImg/.NUM./$dyeMin}
pushd ${obsRegPath} >& /dev/null
. genRegions.sh ${preRegImg/.NUM./$dyeMin}
popd >& /dev/null
wait $!

# copy dye 20 image to all reduced dye folders
for dye in ${dyes[*]}
do
	cp ${obsRegPath}/${obsDS9/.EXT./png} ${dyeDir}/${dye}_dye/${obsDS9/.EXT./png}
	wait $!
done

# copy dye image and region file to obs directory for easy reference/access

cp ${obsRegPath}/${obsDS9/.EXT./png} ${obsPath}/${obsDS9/.EXT./png}
cp ${obsRegPath}/${obsDS9/.EXT./reg} ${obsPath}/${obsDS9/.EXT./reg}

###################
# return 1 2> /dev/null || exit 1
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

#chmod 777 obsExtractAll.sh
for dye in ${dyes[*]}
do
	# Passing in evtPath (/xis/event_cl) only as it adds rest; NOT SAME as ABOVE ExtractIMG
	## No clue why yet, haven't troubleshot
	. obsExtractAll.sh ${GTI_file} ${histFile/DYE/$dye} ${obsPath}/${obsDS9/.EXT./reg} ${processedOn}
#	. obsExtractAll.sh ${obs} ${dye} ${dyeDir} ${scriptPath} ${obsPath}/${evtPath} ${GTI_file} ${histFile/DYE/$dye} ${obsPath}/${obsDS9/.EXT./reg} ${processedOn}
	wait $!
done

#return 1 2> /dev/null || exit 1

####
#   Obtain the rmf file; 
####

#chmod 777 xisrmfgen.sh
for dye in ${dyes[*]}
do
	. xisrmfgen.sh ${dyeDir}/${dye}_dye ${histFile/DYE/$dye} ${rmfFile/DYE/$dye}
	wait $!
done

####
#   Obtain the expmap file; 
####

#chmod 777 xisexpmapgen.sh
for dye in ${dyes[*]}
do
	. xisexpmapgen.sh ${dyeDir}/${dye}_dye ${histFile/DYE/$dye} ${expmapFile/DYE/$dye} ${obsPath}/auxil/ae${obs}.att.gz
	wait $!
done

####
#   Fetch proper bad colum file path (npm; noisy pixel file) from CALDB
#   Use observation date to determine which sci state of bcf is needed
####

rejectFile=ae_xi1_nxbsci${nxbID}_rejectnpm.fits

#chmod 777 nxbrejectnpm.sh
. nxbrejectnpm.sh ${rejectFile}
wait $!

if [ ! -f $bcfPath/$rejectFile ]; then

	echo
	echo "Expecting nxb_rejectnpm file: $rejectFile"
	echo "Not found at: $bcfPath"

	return 1 2> /dev/null || exit 1

fi



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
#chmod 777 xisnxbgen.sh
for dye in ${dyes[*]}
do
	. xisnxbgen.sh ${dyeDir}/${dye}_dye ${obsPath}/${obsDS9/.EXT./reg} ${nxbFile/DYE/$dye} ${histFile/DYE/$dye} ${obsPath}/auxil/ae${obs}.att.gz ${obsPath}/auxil/ae${obs}.orb.gz ${bcfPath}/${rejectFile}
	wait $!
done

####################
#exit
####################
####
#   Simulate/generate arf file; 
####

#chmod 777 xissimarfgen.sh
for dye in ${dyes[*]}
do
	. xissimarfgen.sh ${dyeDir}/${dye}_dye ${obsPath}/${obsDS9/.EXT./reg} ${arfFile/DYE/$dye} ${histFile/DYE/$dye} ${expmapFile/DYE/$dye} ${obsPath}/auxil/ae${obs}.att.gz ${rmfFile/DYE/$dye} ${bcfPath}/${npmbcfFile}
	wait $!
done



####
#   Copy reduced data products to xspec directory structure
#    for spectral fitting and easier sharing
#   Expecting to find ds9 region png in observation folder for wuick checking
####

#chmod 777 cpProductsToXspecPath.sh

for dye in ${dyes[*]}
do

	#toCopy=( ${histFile/DYE/$dye} ${arfFile/DYE/$dye} ${rmfFile/DYE/$dye} ${nxbFile/DYE/$dye} ./${obsRegPath}/${obsDS9/.EXT./png} )

	# Scrap this, can't pass array (except by reference which only works local(?)
	#toCopy=( ${histFile/DYE/$dye} ${obsDS9/.EXT./png} )

	echo $productPrefix

	. cpProductsToXspecPath.sh ${dyeDir}/${dye}_dye ${obs}/xspec/${dye}_dye "${productPrefix}" ${histFile/DYE/$dye} ${arfFile/DYE/$dye} ${rmfFile/DYE/$dye} ${nxbFile/DYE/$dye} ${obsDS9/.EXT./png} 
	wait $!
done

wait $!

pwd

####
#   Generate grppha file
####

#chmod 777 grpphaMake.sh

#return 1 2> /dev/null || exit 1


for dye in ${dyes[*]}
do

	pwd

	. grpphaMake.sh ${grpphaFile/DYE/$dye} ${obsPath}/xspec /${dye}_dye ${histFile/DYE/$dye} ${arfFile/DYE/$dye} ${rmfFile/DYE/$dye} ${nxbFile/DYE/$dye} ${productPrefix}
	wait $!
done

. xcessories.sh
