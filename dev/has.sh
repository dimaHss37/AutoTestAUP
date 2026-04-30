#!/bin/bash

CHSM() {
    input_var="$1"
    total_lines=$(echo "$input_var" | wc -l)
    checksum=0
    start=$(date +%s%N)
    for ((q=1; q<=$total_lines; q++)); do
        ind1="NR==$q"
        line=$(echo "$input_var" | awk $ind1)
        params=$(echo "$line" | grep -o ";" | wc -l)
        params=$((params + 1))
        IFS=';' read -r -a arr <<< "$line"
        for ((i=0; i<$params; i++)); do
            element=${arr[$i]}
            elements_array=()
            for (( j=0; j<${#element}; j++ )); do
                elements_array+=("${element:$j:1}")
                new_element=$(printf "0x%x\n" "'${elements_array[$j]}")
                checksum=$((checksum + new_element))
            done
        done
    done
    end=$(date +%s%N)
    echo -e "Контрольная сумма: $(printf '%x\n' "$checksum") \tвремя расчёта: $((($end - $start) / 1000000)) мс"
}

in1=$(cat /media/sf_/projects/AutoTestAUP_dev/rdt/250708_100137311_20324090096.rdt | awk '/\[ARCHIVE3\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')
in2=$(cat /media/sf_/projects/AutoTestAUP_dev/rdt/250708_100137311_20324090096.rdt | awk '/\[ARCHIVE4\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')
in3=$(cat /media/sf_/projects/AutoTestAUP_dev/rdt/250708_100137311_20324090096.rdt | awk '/\[ARCHIVE5\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')
in4=$(cat /media/sf_/projects/AutoTestAUP_dev/rdt/250708_100137311_20324090096.rdt | awk '/\[ARCHIVE7\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')
in5=$(cat /media/sf_/projects/AutoTestAUP_dev/rdt/250708_100137311_20324090096.rdt | awk '/\[ARCHIVE9\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')
in6=$(cat /media/sf_/projects/AutoTestAUP_dev/rdt/250708_100137311_20324090096.rdt)

output=$(CHSM "$in1")
echo "$output"
output=$(CHSM "$in2")
echo "$output"
output=$(CHSM "$in3")
echo "$output"
output=$(CHSM "$in4")
echo "$output"
output=$(CHSM "$in5")
echo "$output"
output=$(CHSM "$in6")
echo "$output"
