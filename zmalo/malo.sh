#!/bin/bash/

# TODO: Dodaj se nakljucni komunisticni citat...
# https://www.marxists.org/subject/quotes/
# Presledke bo stevilu znakov in ne crk...

# 1) preberem s curl
# 2) z gawkom sparsam, naredim txt file, marx, engels, hegel, lenin, trotsky, mao, ostali...
# 3) preberem txt in izberem random vrstico...
# ZASTARELO...
# S parsam s parse.py
# Na roke popravim navednice, apostrofe in umlaute
# Potem pa pisem...


# Imamo 5 dokumentov
# echo stevilo arg: $# pa se prvi arg: $1
if [ $# -eq 0 ] || [ $1 -eq 0 ] ; then
    declare -a fajli=(/home/len/local/zmalo/zmarx.txt /home/len/local/zmalo/zlenin.txt /home/len/local/zmalo/zhegel.txt /home/len/local/zmalo/ztrocki.txt /home/len/local/zmalo/zraz.txt) #maota sem izkljucil

    rand_avt=$(($RANDOM % 5))
    vrstic="$(wc -l < ${fajli[$rand_avt]})"
    rand_vrst=$(($RANDOM % $vrstic + 1 )) # vprasanje kako se stejejo vrstice v fajlu

    citat=$(sed -n -e "$rand_vrst {p; q}" ${fajli[$rand_avt]} )
    #echo $citat
    COUNTER=0
    cel=""
    NEWLINE=$'\n'
    for word in $citat
    do
        if [ $COUNTER -eq 0 ] ; then
            cel="$word"
            st_crk="$(echo $word | wc -c)"
            let COUNTER=COUNTER+$st_crk
        else
            st_crk="$(echo $word | wc -c)"
            let COUNTER=COUNTER+$st_crk
            if [ $COUNTER -gt 45 ] ; then
                COUNTER=1
                cel="$cel${NEWLINE}$word"
            else
                cel="$cel $word"
                #echo $cel
            fi
        fi
    done

    #cel=$(printf "$cel")
    tovarisica="Tovarisica, vzdrzi se malomescanskih vzgibov" # 45 znakov
    preberi="${NEWLINE}in preberi naslednje modre besede:${NEWLINE}${NEWLINE}"
    # echo "$cel"
    # echo -e $cel
    celota=$tovarisica$preberi$cel

    xmessage -buttons "Razumem:1, Nisem spran:0" "$celota" && bash /home/len/local/zmalo/malo.sh $?

    # Sedaj pa moram samo se narest nekaj, kar prebere vrednost izhoda iz
    # standardnega outputa in ce je vrednost ne razumem izpisati nov citat.

    # Skripta ima en parameter. Ce vhodnega parametra ni, potem se mora izvesti
    # ta osnovni del, ki je ze napisan. Skripta potem pajpa nazaj sama vase.
    # Ce je vhodni parameter enak 0, se konca, drugace pa se zazene z drugacno
    # Zacetno vrednostjo, ki spet izpise drug citat.
fi
