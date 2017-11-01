#!/bin/bash

vse=$(ls *.JPG | wc -l)
ste=1
for f in *.JPG; do echo "$ste / $vse Converting $f"; convert "$f" -resize 1000 -auto-orient "tpload/1709_aut-swz_$(basename "$f" .JPG).jpg"; ((ste++)); done # za rotacijo dodaj -rotate 90

