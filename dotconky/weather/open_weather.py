#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import urllib2, socket
import datetime as d
import time
#import os

#Free License - aGPL 3.0
#2014 12 16
#by len

#program, ki bo generiral vremensko datoteko, ki jo prebral conky :)
#podakte zajamem iz openweathermap

#conky: http://conky.sourceforge.net/variables.html
#       ${exec cat <path to file>}
#       ${texeci 10800 python path/to/python/script}
# ${exec python /path/open_weather.py} # NEA FAKING DELA!!!

#Ljubljana 3196359 # ubistvu bi python lahko preveril kje sem...

#TO DO:
#  
#  2) Preveri kraj, kjer se nahajam
#  3) Kalendar

# DONE:
#  1) Error handling - kaj ce nimam internet - naj kaze, da je zunaj sonce
#  4) Ce je z netom povezava vzpostavljena, pa zajem ni uspesen, lahko naredi wait
#  4) asociativna polja - dictionary
#  5) Ce ni podatkov, se ne odpira fajla

# BUGGG
# Treba je dat konkreten path do fajle vreme .txt, ki ga skripta ustvari
# ker ker ga naredi, v mapi, v kateri se nahajaš... 
# in conky vresnici izvede to skripto, ampak ne zapiše pravega fajla.
# Prednost fajla je v tem, da se zažene za nazaj...
# Zato bom vztrajal na fajlu. 

# My (len42) APPID (API key) c92d1289ca0cbc9cc4762c80d9e6808e

# import time
# time.sleep(5) # zaspi za 5 sekund

timeout = 5
socket.setdefaulttimeout(timeout)

def fetchHTML(url, tries=0):
    try:
        req = urllib2.Request(url)
        response=urllib2.urlopen(req)
        return response.read()
    except urllib2.HTTPError:
        # print "HTTPError"
        # return "httperror"
        tries += 1
        if tries < 5:
            time.sleep(60)
            return fetchHTML(url, tries)
        else:
            return None
    except urllib2.URLError:
        # print "URLError"
        # return "urlerror"
        tries += 1
        if tries < 5:
            time.sleep(60)
            return fetchHTML(url, tries)
        else:
            return None
    except socket.timeout:
        # print "socket.timeout"
        # return "socket.timeout"
        tries += 1
        if tries < 5:
            time.sleep(60)
            return fetchHTML(url, tries)
        else:
            return None
    except TypeError:
        tries += 1
        if tries < 5:
            time.sleep(60)
            return fetchHTML(url, tries)
        else:
            return None

def picture(st):
    legenda = {"Rain": 'p8.png', "Clear": 'p1.png', "Few Clouds" : 'p3.png', "Clouds": 'p6.png', "Broken Clouds":'p12.png', "Shower Rain": 'p9.png', "Thunderstorm": 'p7.png', "Snow" : 'p10.png', "Mist":'p5.png', "Fog": 'p5.png'}
    if (st in legenda): return legenda[st]
    else: return 'p13.png'

def swday(i):
    legenda = {0 : 'Pon', 1 : 'Tor', 2: 'Sre', 3: 'Cet', 4: 'Pet', 5:'Sob', 6:'Ned'}
    if (i in legenda): return legenda[i]
    else: return 'Xxx'

def dat(i):
    # pretvori unix time v datum
    return d.datetime.fromtimestamp( i ).strftime('%Y-%m-%d %H:%M:%S') 

filename = "/home/len/.conky/weather/vreme.txt"
#d = os.path.dirname(filename)
#if not os.path.exists(d):
#    os.makedirs(d)

#url_now = 'http://api.openweathermap.org/data/2.5/weather?id=3196359'
url_now = 'http://api.openweathermap.org/data/2.5/weather?id=3196359&APPID=c92d1289ca0cbc9cc4762c80d9e6808e'
#url_fut = 'http://api.openweathermap.org/data/2.5/forecast/daily?id=3196359'
now_j = json.loads(fetchHTML(url_now))

url_fut = 'http://api.openweathermap.org/data/2.5/forecast/daily?id=3196359&APPID=c92d1289ca0cbc9cc4762c80d9e6808e'
fut_j = json.loads(fetchHTML(url_fut))

now = {'main' : now_j['weather'][0]['main'], 'desc' : now_j['weather'][0]['description'] , 'temp': round(now_j['main']['temp'] - 273.15, 0), 'press' : now_j['main']['pressure'], 'hum': now_j['main']['humidity'], 'speed':now_j['wind']['speed'], 'clouds':now_j['clouds']['all'], 'name' : now_j['name'], 'tim':now_j['dt']}
# lahko bi naredil dictionary

# tole nima ful smisla
slika = picture(now['main'])
temp = now['temp']
# Bolje bi bilo narest asociativno polje vsega, preden se sploh fajl odpre...
# Zato da je napaka preden se fajl odpre...

# zelena: 29b030 - glitchbg.jpg
# roza od prej: D60650
# modra: 1F88A7
btekst = "A11A5D" # viola glitch
bcrta = "29B030"

f=open(filename, 'w')
f.write('${color %s}${font Caviar Dreams:size=24}%s${font}\n${color FFFFFF} ${font Caviar Dreams:size=6} %s${font}\n${color %s}${hr}\n'%(btekst, now['name'], dat(now['tim']), bcrta ) )
#prej je bila slika na 5, 31, potem 5, 46, potem 51, potem 45... 58
#bilo je na 54, potem sem prestavil na 55 in je vse totalno dol premaknil - WTF!!!
f.write('${image ~/.conky/weather/img/%s -p 6,59 -s 60x60}${color %s}${font Caviar Dreams:size=24}${offset 70}%s °C ${font}\n' %(picture(now['main']), btekst, now['temp'])  )
f.write('${color %s}${font Caviar Dreams:size=12}Desc: ${color FFFFFF}%s${font}\n' %(btekst, now['desc']))
f.write('${color %s}${font Caviar Dreams:size=12}Wind: ${color FFFFFF}%s m/s${font}\n' %(btekst, now['speed']))
f.write('${color %s}${font Caviar Dreams:size=12}Clouds: ${color FFFFFF}%s perc${font}\n' %(btekst, now['clouds']))
f.write('${color %s}${font Caviar Dreams:size=12}Pressure: ${color FFFFFF}%s mbar${font}\n' %(btekst, now['press']))
f.write('${color %s}${font Caviar Dreams:size=12}Humidity: ${color FFFFFF}%s perc${font}\n${color %s}${hr}\n' %(btekst, now['hum'], bcrta))


dat = d.datetime.now()
wday = dat.weekday()

fut = {}
#print fut_j
for i in range(5):
    key = 'day%d'%(i+1)
    #print "temp: %.2f"%round(fut_j['list'][i]['temp']['day'] - 273.15, 0)
    #print "vreme: %s"%fut_j['list'][i]['weather'][0]['main']
    fut[key] = (round(fut_j['list'][i+1]['temp']['day'] - 273.15, 1), fut_j['list'][i+1]['weather'][0]['main']) #tole mi zgenerira dictionary - upam
    img = picture(fut[key][1])
    #print '%d\t%d\t%s\t%s\t%s'%(i, wday, swday((wday+i)%7), img, fut[key][0])
    f.write('${font Caviar Dreams:size:14}${color %s}%s ${image ~/.conky/weather/img/%s -p 40,%d -s 55x55}${color %s}${font Caviar Dreams:size=22}${offset 70}%s °C ${font}\n${color %s}${hr}\n'%(bcrta, swday((wday+i+1)%7), img, 195+i*44, btekst, fut[key][0], bcrta) ) #prej je bilo 170, 185, 190, 186 (*43, 44), 199, 188, 190*43
    #print "%s : %s\n"%(fut[key][1], img)

f.close()



#Json izgleda tako - to je treba sparsat
#{"coord":{"lon":14.51,"lat":46.05},
 #"sys":{"type":1,"id":5882,"message":0.0303,"country":"SI","sunrise":1418452556,"sunset":1418483805},
 #"weather":[{"id":500,"main":"Rain","description":"light rain","icon":"10n"}],
 #"base":"cmc stations",
 #"main":{"temp":276.71,"pressure":1020,"humidity":93,"temp_min":273.15,"temp_max":280.15},
 #"wind":{"speed":1.5,"deg":340,"var_beg":300,"var_end":10},
 #"clouds":{"all":75},"dt":1418512800,"id":3196359,"name":"Ljubljana","cod":200}

#Napoved
#{"cod":"200","message":0.0148,"city":{"id":524901,"name":"Moscow","coord":{"lon":37.615555,"lat":55.75222},"country":"RU","population":1000000},"cnt":7,
  #"list":[
    #{"dt":1418461200,"temp":{"day":275.15,"min":275.15,"max":275.15,"night":275.15,"eve":275.15,"morn":275.15},"pressure":996.44,"humidity":87,"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03n"}],"speed":9.36,"deg":251,"clouds":36},
    #{"dt":1418547600,"temp":{"day":274.38,"min":271.73,"max":274.38,"night":273.3,"eve":271.73,"morn":274.29},"pressure":1001.56,"humidity":90,"weather":[{"id":601,"main":"Snow","description":"snow","icon":"13d"}],"speed":6.72,"deg":250,"clouds":88,"snow":8.5},{"
    #dt":1418634000,"temp":{"day":270.96,"min":262.3,"max":272.74,"night":272.74,"eve":270.72,"morn":262.3},"pressure":1018.1,"humidity":0,"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"speed":2.02,"deg":191,"clouds":75,"snow":0.29},
    #{"dt":1418720400,"temp":{"day":276.13,"min":274.78,"max":276.13,"night":274.78,"eve":275.62,"morn":275.66},"pressure":1008.21,"humidity":0,"weather":[{"id":500,"main":"Rain","description":"light rain","icon":"10d"}],"speed":5.74,"deg":225,"clouds":97,"rain":2.2},
    #{"dt":1418806800,"temp":{"day":275.01,"min":274.52,"max":275.01,"night":274.7,"eve":274.52,"morn":274.71},"pressure":999.9,"humidity":0,"weather":[{"id":800,"main":"Clear","description":"sky is clear","icon":"01d"}],"speed":6.03,"deg":229,"clouds":97,"rain":1.12,"snow":0.01},
    #{"dt":1418893200,"temp":{"day":274.46,"min":274.03,"max":276.31,"night":276.31,"eve":274.46,"morn":274.03},"pressure":995.99,"humidity":0,"weather":[{"id":500,"main":"Rain","description":"light rain","icon":"10d"}],"speed":7.07,"deg":188,"clouds":22,"rain":0.29},
    #{"dt":1418979600,"temp":{"day":276.01,"min":275.33,"max":276.59,"night":276.59,"eve":275.33,"morn":276.18},"pressure":990.1,"humidity":0,"weather":[{"id":500,"main":"Rain","description":"light rain","icon":"10d"}],"speed":5.87,"deg":210,"clouds":97,"rain":2.95}]}

#lahko bi sam ugotovil kraj, kjer se nahajam...

# Naslednja ideja je, da bom naredil kalendar,
# v katerega bom lahko vpisoval dogodke


