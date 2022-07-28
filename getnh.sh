

# In xspec, use:
# syscall ./getnh.sh

# To get nH info without leaving xspec

files=$( ls {*.xsl,*.fits} | head -1 )

obsRA=$(gethead RA_PNT ${files})
obsDEC=$(gethead DEC_PNT ${files})
obsID=$(gethead OBS_ID ${files})
obsDATE=$(gethead DATE-OBS ${files})

echo
echo "ObsID: $obsID"
echo "RA: $obsRA"
echo "DEC: $obsDEC"
echo "Date: $obsDATE"

nhWeightedString=$( nh 2000 $obsRA $obsDEC | tail -1 )
nhVal=${nhWeightedString##*' '}


echo
echo "Observation info retrieved from: $files"
echo
echo "nH Column Density (weighted): ${nhVal}"

outfile="nh.txt"

# Create or clear outfile
{ printf '%s' ""; } > $outfile

# 
{ printf '%s\n' "ObsID: $obsID"; } >> $outfile
{ printf '%s\n' "RA: $obsRA"; } >> $outfile
{ printf '%s\n' "DEC: $obsDEC"; } >> $outfile
{ printf '%s\n' "Date: $obsDATE"; } >> $outfile
{ printf '%s\n' ""; } >> $outfile
{ printf '%s\n' "Observation info retrieved from: $files"; } >> $outfile
{ printf '%s\n' ""; } >> $outfile
{ printf '%s\n' "nH Column Density (weighted): ${nhVal}"; } >> $outfile
{ printf '%s\n' ""; } >> $outfile
