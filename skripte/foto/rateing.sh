#!/bin/bash

# prints help
function phelp {
    printf "Usage: rating-pics [OPTIONS] PATH-TO-FOLDER-W-IMAGES\n"
    echo
    printf "Options:\n"
    printf "\t-c\tCreate folders and copy image files into these folders\n"
    printf "\t-r\tCreate folders, copy files, resize them to [WIDTHxHEIGHT]]\n"
    printf "\t\tPossible to do only width or height\n"
    printf "\t-n\tAdd name to image files [ANAME]\n"
    printf "\t-u\tDelete/remove unrated images\n"
    printf "\t-j\tConvert images into format [SUFFIX] (jpg, png)\n"
    printf "\t-m\tRemove metadata from images\n"
    printf "\t-h\tPrints this help\n"
    echo
    printf "Example:\nrateing ~/Pictures/2017/presidental-elections -r 1000 -j jpg -m -u\n"
    printf "\tSorts Nomacs rated images into subfolder, resizes them to width 1000,\n"
    printf "\tconverts them to jpg and removes metadata."
    echo
    printf "AUTHOR\n"
    printf "\tWritten by Lio Novelli; www.novelli.si\tOctober 2017\n"
    echo
    printf "COPYRIGHT\n"
    printf "\tLicense GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n"
    printf "\tThis is free software: you are free to change and redistribute it.  \n"
    printf "\tThere is NO WARRANTY, to the extent permitted by law.\n"
    printf "\tLet's fight that one day this disclaimer will be unnecessary!\n"
    echo
}

# we expect path
function abspath {
    if [ -d $ptimagef ]
    then
        pushd "$ptimagef" >/dev/null
        pwd
        popd >/dev/null
    elif [ -e $ptimagef ]
    then
        pushd "$(dirname "$ptimagef")" >/dev/null
        echo "$(pwd)/$(basename "$ptimagef")"
        popd >/dev/null
    else
        echo "$ptimagef" does not exist! >&2
        return 127
    fi
}


# checks if there are filenames with spaces and asks to correct that
# otherwise other functions fail
function fnames {
    if [ `ls *\ * | wc -l` -gt 0 ]; then
        echo "There are filenames containing whitspaces in this folder."
        echo "Do you want to replace them with underlines? [Y/n]"
        read -r -p "Are you sure? [y/N] " response
        response=${response,,}    # tolower
        if [[ "$response" =~ ^(yes|y)$ ]]; then
            for name in *\ *
            do
                newname="$(echo $name | sed 's/ /_/g')"
                mv "$name" $newname
                echo "$name -> $newname"
            done
            echo "Proceeding ..."
        else
            #printf $help
            phelp
        fi
    fi
}

declare -A imgsnames
declare -A imgsrates
declare -A rated0
declare -A nr

# counts number of ratings
function ratings {
    echo "Rating imgs!"
    cnt=0
    vse=$( ls $ptimagef )
    nr[0]=0; nr[1]=0; nr[2]=0; nr[3]=0; nr[4]=0; nr[5]=0; nr[6]=0;
    for i in $vse; do
        file $ptimagef/$i | grep -q image; # ne bomo po nepotrebnem prevec izpisovali
        if [ $? -eq 0 ]; then
            res=$(exiftool $ptimagef/$i | egrep "Rating[[:blank:]]+:")
            #exiftool $ptimagef/$i | egrep -q "Rating[[:blank:]]+:"
            if [ ! $? -eq 0 ]; then
                imgsnames[$cnt]=$i
                imgsrates[$cnt]=0
                #echo "Else cnt $cnt nr od 0 ${nr[0]}"
                (( cnt += 1 ))
                rated0+=" $i"
                (( nr[0] += 1 ))
            else
                rat=$(echo $res | egrep -o "[[:digit:]]")
                if [ $rat -eq 1 ]; then
                    (( nr[1] += 1 ))
                    imgsnames[$cnt]=$i
                    imgsrates[$cnt]=$rat
                    (( cnt += 1 ))
                elif [ $rat -eq 2 ]; then
                        (( nr[2] += 1 ))
                        imgsnames[$cnt]=$i
                        imgsrates[$cnt]=$rat
                        (( cnt += 1 ))
                elif [ $rat -eq 3 ]; then
                        (( nr[3] += 1 ))
                        imgsnames[$cnt]=$i
                        imgsrates[$cnt]=$rat
                        (( cnt += 1 ))
                elif [ $rat -eq 4 ]; then
                        (( nr[4] += 1 ))
                        imgsnames[$cnt]=$i
                        imgsrates[$cnt]=$rat
                        (( cnt += 1 ))
                elif [ $rat -eq 5 ]; then
                        (( nr[5] += 1 ))
                        imgsnames[$cnt]=$i
                        imgsrates[$cnt]=$rat
                        (( cnt += 1 ))
                elif [ $rat -eq 0 ]; then
                    (( nr[0] += 1 ))
                    imgsnames[$cnt]=$i
                    imgsrates[$cnt]=$rat
                    (( cnt += 1 ))

                fi
            fi
        fi
    done
    printf "===========|===================\n"
    for r in 0 1 2 3 4 5; do
        printf "rating: %2s | images: %10s\n" $r ${nr[$r]}
    done
    printf "===========|===================\n"
    printf "total: %24s\n" ${#imgsrates[@]}
}

# create dirs
function cdirs {
    for r in 0 1 2 3 4 5; do
        echo "in cdirs"
        printf "rating: %2s : images: %10s\n" $r ${nr[r]}
        if [ "${nr[$r]}" -gt 0 ]; then
            echo "Creating folder rated$r for ${nr[$r]} images."
            mkdir $ptimagef/rated$r
        fi
    done
}

# copying imgs
function cpimgs {
    num=$(( ${#imgsrates[@]} - 1 ))
    for i in $( seq 0 $num ); do
        imgname=${imgsnames[$i]}
        imgrate=${imgsrates[$i]}
        cp $ptimagef/$imgname $ptimagef/rated$imgrate
        printf "%3f / %4f copying %s\n" $i $num $imgname $imgrate
        (( cnt += 1 ))
    done
}

# copy and resize rated imgs
function rszimgs {
    num=$(( ${#imgsrates[@]} - 1 ))
    for i in $( seq 0 $num ); do
        imgname=${imgsnames[$i]}
        imgrate=${imgsrates[$i]}
        convert $ptimagef/$imgname -resize $size -auto-orient $ptimagef/rated$imgrate/$imgname
        printf "%3s / %4s converting %s rated %2s\n" $i $num $imgname $imgrate
    done
}


# add name to copied imgs
function addname {
    for r in 0 1 2 3 4 5; do
        vse=$( ls $ptimagef/rated$r )
        for i in $vse; do
            mv $ptimagef/rated$r/$i $ptimagef/rated$r/$aname$i
            echo "Renameing $i -> $aneme$i"
        done
    done
}


# convert imgs into jpeg
function i2suff {
    for r in 0 1 2 3 4 5; do
        vse=$( ls $ptimagef/rated$r )
        for i in $vse; do
            convert $ptimagef/rated$r/$i $ptimagef/rated$r/${i%.*}.$suffix
            rm $ptimagef/rated$r/$i
            echo "Converting $i -> ${i%.*}.$suffix"
        done
    done
}

# remove unrated images from base folder
function rurated {
    for i in "${rated0}"; do
        rm $ptimagef/$i
        echo "Removing $i"
    done
}

# remove metadata from rated images
function rmeta {
    for r in 0 1 2 3 4 5; do
        echo "Removing metadata from images rated $r."
        exiftool -all= $ptimagef/rated$r/*
    done
}

function rwhitespace {
    fww=$(ls $pimagef | grep " " | wc -l)

    if [ $fww -gt 0 ]; then
        #if [ `ls *\ * | wc -l` -gt 0 ]; then
        echo "There are filenames containing whitspaces in this folder."
        read -r -p "Do you want to replace them with underlines? [y/N] " response
        response=${response,,}    # tolower
        if [[ "$response" =~ ^(yes|y)$ ]]; then
            for name in *\ *
            do
                newname="$(echo $name | sed 's/ /_/g')"
                mv "$name" $newname
                echo "$name -> $newname"
            done
            echo "Proceeding ..."
        else
            printf "Find help!\n"
            phelp
        fi
    fi
}

while getopts 'f:cr:n:uj:mh' OPTION; do
	  case "${OPTION}" in
        f)
            ptimagef=$OPTARG
            abspath
            rwhitespace
            ratings
            ;;
        c)
            echo "Creating folders and copying images."
            cdirs
            cpimgs
            ;;
        r)
            echo "The value of resize tag -r is $OPTARG"
            size=$OPTARG
            cdirs
            rszimgs
            ;;
        n)
            aname=$OPTARG
            echo "Add name $aname to img files."
            addname
            ;;
        u)
            echo "Removing unrated imgs from base folder."
            rurated
            ;;
        j)
            #I have to check if it is jpg, jpeg or png
            suffix=$OPTARG
            echo "i2suff wth $suffix"
            i2suff
            ;;
        m)
            echo "Removing metadata from rated imgs."
            rmeta
            ;;
        h)
            phelp
            exit 2
            ;;
        \?)
            phelp
            exit 5
            ;;
    esac
done

exit 0
