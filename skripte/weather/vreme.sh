#!/bin/bash

# opens weather diagram in feh
# Optional argument - location
# Dependencies: wget, feh

# todo:
#  - validation for location

location='lj'

print_help()
{
echo "This script downloads a weather diagram from Meteorologic department of Faculty of Mathematics and Physics from Ljubljana."  
echo -e "Usage:\n\t-h ... prints this help\n\t-l ... location [optional] - downloads diagram for city:\n\t\t * lj - Ljubljana \n\t\t * ce - Celje \n\t\t * mb - Maribor \n\t\t * ms - Murska Soboto\n\t\t * ng - Nova Gorica \n\t\t * nm - Novo mesto \n\t\t * pz - Portoroz \n\t\t * po - Postojna \n\t\t * ra - Ratece\n\t If this flag is omitted, it will open diagram for Ljubljana."
}

weather_in()
{
  domain="http://meteo.fmf.uni-lj.si/external/WRFMF/pictures/"
  filein="out_meteogram_$location.png"  
  path="$domain$filein"
  echo -e "Downloading: $path"
  now=$(date +"%Y%m%d")
  fileout="/tmp/$now-$filein"
  echo "Saving to: $fileout"
  wget -O $fileout $path 
  feh $fileout &
}

if [[ $# -eq 0 ]]
then
    weather_in
fi

while [[ $# -gt 0 ]]
    do
        argument="$1"
        case $argument in
            -h)
                print_help
                shift
                shift
                ;;
            -l)
                location=$2
                weather_in
                shift
                shift
                ;;
            -*)
                echo "Unkown argument: \"$argument\"" 
                print_help
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

#<select name="Kraj" id="City" onchange="display_picture()" size="9" class="wrf_select">
#  <option value="lj" selected="selected">Ljubljana</option>
#  <option value="ce">Celje</option>
#  <option value="mb">Maribor</option>
#  <option value="ms">Murska Sobota</option>
#  <option value="ng">Nova Gorica</option>
#  <option value="nm">Novo mesto</option>
#  <option value="pz">Portoroz</option>
#  <option value="po">Postojna</option>
#  <option value="ra">Ratece</option>
#</select>


