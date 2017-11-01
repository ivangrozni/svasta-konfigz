#for i in $(ls); do echo $i; identify -verbose $i | grep unknown ; done
#exiftool dela hitreje
for i in *.JPG; 
    do echo $i; 
    exiftool $i | grep Rating;
    if [ $? -eq 0 ] ; then
	   cp $i izbrane;
	   echo "kopiram $i";
    fi 
done

# recimo kake opcije
# treba je program premaknit v /usr/lib al nekaj takega ...
# treba ga je poslat na nomacs
# gizmo je rekel da se da /home/usr/bin v path in je to to
