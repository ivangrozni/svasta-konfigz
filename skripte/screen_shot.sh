#!/bin/bash

# requirements:
#  - zenity
#  - import (imagemagick)

scrshot_help() {
    echo "Open dialog box where you can input file name into which to save the screenshot. If input is left empty /tmp/<currentdate>.png is chosen."
    #echo -e "\nEXAMPLE"
}

scrshot_create() {
    SC_DEFAULT="/tmp/sc-$(date '+%y%m%d-%H%M').png"
    SC_FILENAME=$(zenity --entry --text "Screenshot name?" --entry-text $SC_DEFAULT --width=400 --height=150)
    echo "filename: $SC_FILENAME"
    if [ -z "$SC_FILENAME" ]
    then
        # do nothing (wrong input)
        echo "Canceled."
    elif [ -f $SC_FILENAME ]
    then
	(zenity --question --text "Filename $SC_FILENAME already exists. Overwrite it?") && import $SC_FILENAME || scrshot_create
    else
        import $SC_FILENAME
    fi
}

scrshot_create
