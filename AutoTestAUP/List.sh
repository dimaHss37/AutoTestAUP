#!/bin/bash

ACTIVE_DIR=$(dirname "$0")
#LIST=$(ls $ACTIVE_DIR/rdt | column -t)
#ls $ACTIVE_DIR/rdt | column -t > $ACTIVE_DIR/.list.tmp



files=$(find $ACTIVE_DIR/rdt -type f | wc -l )


file=$(find $ACTIVE_DIR/rdt -type f)

for ((i=1; i<=$files; i++)); do
    ind="NR==$i"
    name=$(ls $ACTIVE_DIR/rdt | column -t | awk $ind)
    #name_file=$(find $ACTIVE_DIR/rdt -type f | awk $ind)
    vers=$(cat $ACTIVE_DIR/rdt/$name | grep vers -i | grep -oE '[0-9]*\.?[0-9]+')
    prot=$(cat $ACTIVE_DIR/rdt/$name | grep "VER_PROTOCOL=")
    if [ -z $prot ]; then
    prot="VER_PROTOCOL=0"
    fi
    echo -e "$name\t$vers\t$prot" | nl -s ' ==> ' >> ./list.txt
done

for ((i=1; i<=$files; i++)); do
    ind="NR==$i"
    cat ./list.txt | awk $ind
    sleep 0.02
done
rm ./list.txt
