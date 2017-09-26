#!/bin/sh

# This is a simple script that downloads current weather conditions and zone
# forecast from the National Weather Service and displays them.
# 
# This script is preconfigured for the Tulsa, OK area.
# It is biased toward the US, as it gets its data from the NWS.
# 
# To change the observations site, replace KTUL with another observations site.
# See <http://weather.noaa.gov/pub/data/observations/metar/decoded/> for a list.
# For the bare, unparsed METAR, replace "decoded" in the URI with "stations".
# 
# To change the forecast zone, replace ok/okz060 with another forecast zone.
# See <http://weather.noaa.gov/pub/data/forecasts/zone/> for a list.

echo "********** CURRENT CONDITIONS **********"
wget -q -O- http://weather.noaa.gov/pub/data/observations/metar/decoded/LJLJ.TXT
# Tega ne rabim...
#echo
#echo "********** NWS ZONE FORECAST **********"
#wget -q -O- http://weather.noaa.gov/pub/data/forecasts/zone/ok/okz060.txt


##############################
#       Druga skripta        #
##############################

#!/bin/sh

#echo "********** CURRENT CONDITIONS **********"
stanje=$(wget -q -O- api.openweathermap.org/data/2.5/weather?id=3196359) 
#wget -q -O- api.openweathermap.org/data/2.5/weather?id=2172797 #London
#| grep -Po '"description":.*?[^\\]",' 
#main, description, temp, pressure, humidity, temp_min, temp_max, wind, clouds

#echo $stanje
#echo
echo $stanje | grep -Po '"main":"[a-zA-Z]+[^\\]",'
echo $stanje | grep -Po '"description":.*?[^\\]",'
echo $stanje | grep -Po '"temp":.[0-9]+\.[0-9]+[^\\],'
echo $stanje | grep -Po '"humidity":[0-9]+[^\\],'
hitrost=$(echo $stanje | grep -Po '"speed":[0-9]+\.?[0-9]*[^\\],')
echo $hitrost
oblacnost=$(echo $stanje | grep -Po '"all":[0-9]+,' )
echo $oblacnost

napoved=$(wget -q -O- http://api.openweathermap.org/data/2.5/forecast/daily?id=3196359)

#echo
#echo $napoved