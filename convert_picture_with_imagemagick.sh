#!/bin/bash

#usage
# ./convert_picture_with_imagemagick.sh 
# prerequisite
# need to be a SVG file with the suffix: _logo.*


function echoLine {
  echo "------------------------------------------------------------------------------"
}


imagestandardconfig=""

function generate_image {
        echo "Generation logo": $2
	#convert $imagestandardconfig -resize $3  $1 $2
	convert $imagestandardconfig -resize $3 -extent $4  $1 $2
}

# find and later use the same colorspace on the generate pictures
# implemented after finding out that the generated pictures had slightly differnet colors that the inputfile
function getColorspace {
	identify -format %[colorspace] $1
}

function setImagemagicConfig {
	config_sniplet_1="-density 300 -units PixelsPerInch -gravity center -background none  -colorspace"
	config_sniplet_2=" -flatten -quality 96 -depth 8"
	colorspace=$(getColorspace $1)
	imagestandardconfig="$config_sniplet_1 $colorspace $config_sniplet_2"
	echo "Imagemagick configuration is: "
	echo "("  $imagestandardconfig  ")"
}


#the result pictures are square, need to find out if the new canwas is limited by the height or weight of the orignal picture
limitedHeight=""
limitedWeight=""
function heightOrWeight {
	if (($1 < $2)); then
		limitedHeight="x"
		echo "Height is the limit:" $1 $limitedHeight 
	else
		limitedWeight="x"
		echo "Weight is the limit:" $limitedWeight $2  
	fi
}

#------------------------------------------------------------------------------
#    START SCRIPT
#------------------------------------------------------------------------------
#1 Does the input file exist?
echoLine
echo "---- START ----"
echoLine
prefix="./"
suffix="_logo.*"
LOGO_FIL=$(find -name '*'$suffix)

echo "Searching for file: " $LOGO_FIL
if [ -f $LOGO_FIL ]; then
	echo "Logofile "$LOGO_FIL" exists"
	
else 
	echo "File "$LOGO_FIL" does not exists"
	exit 0
fi 

AVSENDER_NAVN=${LOGO_FIL#$prefix}
AVSENDER_NAVN=${AVSENDER_NAVN%$suffix} 
echo "Name of organization: "$AVSENDER_NAVN
echo "Converting logo for "$AVSENDER_NAVN", using logofile "$LOGO_FIL

#2 is it the height or width that is biggest?
imageHeight=$(identify -format %h $LOGO_FIL )
imageWeight=$(identify -format %w $LOGO_FIL )
heightOrWeight $imageHeight $imageWeight
#3 set the configuration of the image magic script
setImagemagicConfig $LOGO_FIL 
echoLine
echoLine
echo "Generating logo in Digipost format"
generate_image $LOGO_FIL $AVSENDER_NAVN"_digipost_200_200.png" $limitedWeight"200"$limitedHeight "200x200"
echo "Generating logo in e-boks formats"
generate_image $LOGO_FIL $AVSENDER_NAVN"_eboks_16_16.png" $limitedWeight"16"$limitedHeight "16x16"
generate_image $LOGO_FIL $AVSENDER_NAVN"_eboks_500_500.png" $limitedWeight"500"$limitedHeight  "500x500"
generate_image $LOGO_FIL $AVSENDER_NAVN"_eboks_1000_1000.png" $limitedWeight"1000"$limitedHeight "1000x1000"
echo "Generating logo in Print format"
generate_image $LOGO_FIL $AVSENDER_NAVN"_utskrift1_189.png" $limitedWeight"189"$limitedHeight "189x189"
echoLine
echo "---- DONE ----"
echoLine