#!/usr/bin/env bash

obs=$1
dye=$2
dyeDir=$3
preRegImg=$4
obsDS9=$5
autoRegBool=${6:-false}

datedRegFile=${obsDS9/.EXT./reg}
dateSuffix=${obsDS9##*'_'}

pushd ${dyeDir}

shopt -s nullglob

xdim=$(gethead NAXIS1 ${preRegImg})
ydim=$(gethead NAXIS2 ${preRegImg})

#check for dated today file first, then expand to all regs

regFile=(*$dateSuffix)

if [[ -z "$regFile" ]] && [ ! -f "$regFile" ]; then

	regFile=(*.reg)

fi

if [[ ! -z "$regFile" ]] && [ -f "$regFile" ]; then
	
	echo "Region file found. Using existing region file: $regFile"
	cp $regFile $datedRegFile
	regFile=${datedRegFile}

else

regFile=${datedRegFile}

ds9 ${preRegImg} \
    -scale log -cmap rainbow -smooth yes -contour yes -contour method smooth -contour scale histequ -contour mode zscale -contour smooth 5 -contour nlevels 1 -contour color black -contour generate -contour save ${obsDS9/.EXT./ctr} -contour convert -regions select all -regions exclude -regions group excluded new -regions select none -regions include -regions command "image;polygon(0,0,$xdim,0,$xdim,$ydim,0,$ydim)" -regions group excluded moveback -regions save ${regFile} -exit &

PID=$!

echo "DS9 Process ID for initial region auto pass: $PID"

wait $PID

echo "DS9 @ Process ID: $PID closed. Initial region auto pass completed."

echo "Initial regions files generated."

fi

case $autoRegBool in 
    (false)

	# Use asinh scale to compare selection and manually exclude more/larger if needed
	# If adding regions; delete all, add, load others, move full square to front

	echo "Loading image and regions for review/edit."

	ds9 ${preRegImg} -scale log -cmap rainbow -smooth yes -zoom to fit -regions load ${regFile} &

	PID=$!

	echo "DS9 Process ID for review/edit: $PID"

	wait $PID

	echo "DS9 @ Process ID: $PID closed. Review/edit completed."

esac

# If the image is already made from the first pass, but the user will review reg file, it won't overwrite the image if changes are made

# So we wait to create the image until no more changes will be made to the region file

# If can't save image, need to update ds9, and place in usr/local/bin

#####
echo "Loading region file and saving image for reference."

ds9 ${preRegImg} -scale log -cmap rainbow -smooth yes -regions load ${regFile} -zoom to fit -saveimage png ${obsDS9/.EXT./png} -scale histequ -saveimage jpeg ${obsDS9/.EXT./jpeg} -exit &

PID=$!

echo "DS9 Process ID for reference image out: $PID"

wait $PID

echo "DS9 @ Process ID: $PID closed. Reference image save completed."
#####

shopt -u nullglob

popd

# http://ds9.si.edu/doc/ref/command.html
# https://web.archive.org/web/20190911122945/http://ds9.si.edu/doc/ref/command.html
# https://linuxhint.com/wait_command_linux/

#210527
#ds9 ${preRegImg} \
#    -scale log -cmap rainbow -smooth yes -contour yes -contour limits .4 100 -contour smooth 4 -contour nlevels 2 -contour color black -contour save ${obsDS9/.EXT./ctr} -contour convert -regions select all -regions exclude -regions group excluded new -regions select none -regions include -regions command "image; polygon 0 0 $xdim 0 $xdim $ydim 0 $ydim" -regions group excluded moveback -regions save ${obsDS9/.EXT./reg} -zoom to fit -saveimage png ${obsDS9/.EXT./png} -exit &
