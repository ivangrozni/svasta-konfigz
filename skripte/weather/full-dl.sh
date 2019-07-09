#!/bin/bash

# Pretoci celotno serijo oddaj
# Vhodni parameter url do oddaje
#   Primer: https://radiostudent.si/dru%C5%BEba/torba-smrti
# Ustvari mapo z imenom oddaje
# Vanjo pretoci vse mp3-je

fullurl=$1

title=$(basename $fullurl)

# extract the protocol
proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
# remove the protocol
url="$(echo ${1/$proto/})"
# extract the user (if any)
user="$(echo $url | grep @ | cut -d@ -f1)"
# extract the host and port
hostport="$(echo ${url/$user@/} | cut -d/ -f1)"
# by request host without port    
host="$(echo $hostport | sed -e 's,:.*,,g')"
# by request - try to extract the port
port="$(echo $hostport | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
# extract the path (if any)
path="$(echo $url | grep / | cut -d/ -f2-)"

mkdir $title
pushd $title

seznam=$(curl $fullurl | grep $title | grep -Po '(?<=href=")[^"]*' | grep $title | sort | uniq)
while read -r line; do
	num=$(echo $line | wc -m)
	echo $num
	printf '=%.0s' {1..$num}
	echo
	echo $line 
        printf '=%.0s' {1..$num}
	echo
	#wget -e robots=off --accept '*.mp3' --level=1 --recursive --no-directories "$proto$host$line"
done <<< "$seznam"

popd
