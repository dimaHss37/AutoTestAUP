#!/bin/bash

ACTIVE_DIR=$(dirname "$0")
rm $ACTIVE_DIR/tmp/*
sors="/media/sf_/projects/AutoTestAUP_dev/rdt"
#sors="$ACTIVE_DIR/rdt/"
files=$(find $sors -type f | wc -l )
clear

SMT_numbs=" 99 96 9 82 81 80 8 79 78 77 76 75 74 73 72 71 7 68 67 66 65 64 6 53 52 51 50 5
49 4 38 37 36 35 34 3100 3099 3096 3066 3065 3064 3051 3050 3049 3010 3009 3008 3005 3004
3003 3 28 27 26 25 24 23 22 2100 21 2099 2096 2066 2065 2064 2051 2050 2049 2010 2009 2008
2005 2004 2003 20 19 18 12 1100 11 1099 1096 1066 1065 1064 1051 1050 1049 1010 1009 1008
1005 1004 1003 100 10 98 97 95 94 93 92 91 90 89 88 87 86 85 84 83 70 69 63 62 61 60 59 58
57 56 55 54 48 47 46 45 44 43 42 41 40 39 33 32 31 3098 3097 3095 3084 3083 3070 3069 3033
3032 3031 3030 3029 3017 3016 3015 3014 3013 30 29 2098 2097 2095 2084 2083 2070 2069 2033
2032 2031 2030 2029 2017 2016 2015 2014 2013 17 16 15 14 13 1098 1097 1095 1084 1083 1070
1069 1033 1032 1031 1030 1029 1017 1016 1015 1014 1013"

for ((i=1; i<=$files; i++)); do
    ind="NR==$i"
    name=$(ls $sors | column -t | awk $ind)
    type=$(cat $sors/$name | grep type -i | grep -o '[0-9]\+')
    type=$(echo "$SMT_numbs" | grep -w "$type")
    if [[ ! $name =~ [[:cyrillic:]] && -n $type && -z $(grep "Application" $sors/$name) && -n $(tac $sors/$name | grep -m 1 "ACTUAL COUNTERS" -a1 | head -n 1) && -n $(cat $sors/$name | awk '/\[SESSION\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/SESSION/d' | sed '/#/d') ]]; then
        ARC3=$(cat $sors/$name | awk '/\[ARCHIVE3\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
        [[ -z $ARC3 ]] && ARC3=0
        ARC4=$(cat $sors/$name | awk '/\[ARCHIVE4\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
        [[ -z $ARC4 ]] && ARC4=0
        ARC5=$(cat $sors/$name | awk '/\[ARCHIVE5\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
        [[ -z $ARC5 ]] && ARC5=0
        ARC7=$(cat $sors/$name | awk '/\[ARCHIVE7\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
        [[ -z $ARC7 ]] && ARC7=0
        ARC9=$(cat $sors/$name | awk '/\[ARCHIVE9\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
        [[ -z $ARC9 ]] && ARC9=0
        vers=$(cat $sors/$name | grep vers -i | grep -oE '[0-9]*\.?[0-9]+')
        prot=$(cat $sors/$name | grep "VER_PROTOCOL=" | grep -oE '[0-9]+')
        [[ -z $prot ]] && prot=0
        prot="Протокол:$prot"
         echo -e "$name \t $vers \t $prot \t $ARC3 $ARC4 $ARC5 $ARC7 $ARC9"
         #echo -e "$name \t $vers \t $prot \t $ARC3 $ARC4 $ARC5 $ARC7 $ARC9" >> $ACTIVE_DIR/tmp/list.tmp
    fi
done
