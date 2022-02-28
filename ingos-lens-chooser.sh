#!/usr/bin/env bash

options=(\
   'Jupiter 11 135 mm f/4' \
   'Helios 44-2 58mm f/2' \
)

function show_prompt()
{
    echo ""
    echo "Lens Options:"

    PS3='
    Enter choice: '

    lens_name=""

    select opt in "${options[@]}"
    do
        echo ""

        # if not an integer, <= 0, or > number of options, abort
        if [ "${REPLY//[0-9]}" != "" ] || [ "$REPLY" -le 0 ] || [ "$REPLY" -gt "${#options[@]}" ]
        then
            echo "Enter a valid number from menu above"
        else
            lens_name="$opt"
            break
        fi
    done

    echo "    Selected lens: $lens_name"
    echo ""
}

show_prompt

while true
do
    read -r -p "    Proceeed with selected lens? (y)es, (n)o, or (q)uit: " choice
    case "$choice" in
        y|Y|yes|YES|Yes) break;;
        n|N|no|NO|No) show_prompt;;
        q|Q|quit|QUIT|Quit) exit;;
    esac
done

lens_params=''

# for primes
focal_length=''
max_aperture=''

# for zooms
focal_length_min=''
focal_length_max=''
max_aperture_at_min_fl=''
max_aperture_at_max_fl=''


case "$lens_name" in

   'Jupiter 11 135 mm f/4')
      focal_length='135'
      max_aperture='4.0'
      lens_params="\
               -AFAperture='$max_aperture' \
               -DNGLensInfo='$lens_name' \
               -EffectiveMaxAperture='$max_aperture' \
               -FocalLength='$focal_length' \
               -Lens='$lens_name' \
               -LensFStops='7.00' \
               -LensInfo='$lens_name' \
               -LensModel='$lens_name' \
               -LensType='MF' \
               -MaxApertureAtMaxFocal='$max_aperture' \
               -MaxApertureAtMinFocal='$max_aperture' \
               -MaxApertureValue='$max_aperture' \
               -MaxFocalLength='$focal_length' \
               -MinFocalLength='$focal_length' \
               "
   ;;

   'Helios 44-2 58mm f/2')
      focal_length='58'
      max_aperture='2.0'
      lens_params="\
               -AFAperture='$max_aperture' \
               -DNGLensInfo='$lens_name' \
               -EffectiveMaxAperture='$max_aperture' \
               -FocalLength='$focal_length' \
               -Lens='$lens_name' \
               -LensFStops='7.00' \
               -LensInfo='$lens_name' \
               -LensModel='$lens_name' \
               -LensType='MF' \
               -MaxApertureAtMaxFocal='$max_aperture' \
               -MaxApertureAtMinFocal='$max_aperture' \
               -MaxApertureValue='$max_aperture' \
               -MaxFocalLength='$focal_length' \
               -MinFocalLength='$focal_length' \
               "
   ;;

esac

#######################

# function to calculate "35mm  Effective Focal Length"
function calc35mmFocalLength()
{
   # Is this already handled automatically by exiftool? May not be necessary...
   local fileName="$1"
   local focalLength="$2"
   local conversionFactor=$(exiftool -ScaleFactor35efl "$fileName" | cut -d : -f 2 | sed 's/^ *//')
   local focalLength35mm=$(echo "$conversionFactor * $focalLength" | bc -l)

   echo $focalLength35mm
}


# need to have "$@" properly escaped!
# loop over each file
RESULT=""


for file in "$@"
do
   focalLength35mmParam=""

   # if a zoom defines a min focal length, use that as effective focal length
   #  can be overridden if focal_length is still defined in block
   if [ "$focal_length" == "" -a "$focal_length_min" != "" ]
   then
      focal_length="$focal_length_min"
   fi

   if [ "$focal_length" != "" ]
   then
      focalLength35mm=$(calc35mmFocalLength "$file" "$focal_length")
      focalLength35mmParam="-FocalLengthIn35mmFormat='$focalLength35mm'"
   fi

   # Non-Nikon camera can display weird info for LensID and LensType, so clear it out if not Nikon mount
   nonNikonParam=""
   nonNikon=$(exiftool -Make "$file" | cut -d : -f 2 | grep -i -c -v 'Nikon')
   if [ $nonNikon -gt 0 ]
   then
      nonNikonParam="-LensID='0' -LensType='None'"
   fi

   cmd="exiftool -overwrite_original $lens_params $focalLength35mmParam $nonNikonParam \"$file\" 2>&1"

   # update the EXIF info in file(s)
   RESULT="$RESULT $file = $(eval $cmd)\n"
done



# Write output and gather stats

EXIF_FILE='exif-lens-chooser.txt'
EXIF_PATH_DISPLAY='~'
EXIF_PATH="/Users/$(id -un)"
EXIF_FULL_PATH="$EXIF_PATH/$EXIF_FILE"


echo -e "$RESULT" > "$EXIF_PATH/$EXIF_FILE"

NUM_GOOD=$(grep -c '1 image files updated' "$EXIF_FULL_PATH" )
NUM_BAD=$(grep -c '0 image files updated' "$EXIF_FULL_PATH" )


if [ "$NUM_BAD" -gt "0" ]
then
   # couldn't update some files
   SUBTITLE_TEXT="Updated: $NUM_GOOD, NOT Updated: $NUM_BAD"
   MESSAGE_TEXT="See $EXIF_PATH_DISPLAY/$EXIF_FILE"
else
   # all files updated, remove file
   #rm "$EXIF_FULL_PATH"
   SUBTITLE_TEXT="Success!"
   MESSAGE_TEXT="Files updated: $NUM_GOOD"
fi

TITLE_TEXT="EXIF Update Complete"
SOUND="Hero"

echo ""
echo "$TITLE_TEXT"
echo "$SUBTITLE_TEXT"
echo "$MESSAGE_TEXT"

# Show notification
if true
then
   if type terminal-notifier > /dev/null
   then
      #terminal-notifier -message "$MESSAGE_TEXT" -title "$TITLE_TEXT" -subtitle "$SUBTITLE_TEXT" -sound "$SOUND" -sender "com.apple.automator.EXIF Lens Chooser"
      terminal-notifier -message "$MESSAGE_TEXT" -title "$TITLE_TEXT" -subtitle "$SUBTITLE_TEXT"
      #terminal-notifier -message "test" -title "Tiel"
   else
      osascript -e "display notification \"$MESSAGE_TEXT\" with title \"$TITLE_TEXT\" subtitle \"$SUBTITLE_TEXT\" sound name \"$SOUND\" "
   fi
fi

