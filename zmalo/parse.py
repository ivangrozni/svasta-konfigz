#!/usr/bin/env python
# -*- coding: utf-8 -*-


import lxml.html as lh
from sys import argv
#import sys # za argumente od zunaj

# argumenta: ime_in, ime_out, avtor
# Programcic:
#    1) sparsa ime_in
#    2) zapise rezultate v ime_out
# Spletne strani bom pobral z wget, ker jih ni veliko
# mystring.replace('\n', ' ')

skripta, ime_in, ime_out = argv

o = open(ime_in, 'r')
root = lh.fromstring(o.read())
o.close()

P = root.findall(".//p")
f = open(ime_out, 'w')
for p in P:
    if len(p.attrib)==0:
        for child in p:
            if child.tag=="a":
                citat = p.text_content().replace('\n', ' ').replace('\r', ' ')
                f.write("%s\n"%citat.encode('UTF-8'))


f.close()
                
                
#root = ee.HTML( o.read() )
#tree = ee.ElementTree(root)
#from lxml import etree as ee
#for p in P:
#    if len(p.attrib)==0:
#        for child in p:
#            if child.tag=="a":
#                print p.attrib
#                citat = p.text
#                #citat = citat.replace('\n', ' ').replace('\r', '')
#                vir = child.text.replace('\n', ' ').replace('\r', '')
#                data[i] = (citat, vir)
#                i += 1

# Kaj smo se naucili. etree in html sta dva razlicna parserja v lxml
# html je boljsi, ker ima text_content() metodo!!!
