#!/bin/bash

# запись в log
TIME_STR=$(date +"%H:%M:%S")
echo "[ARCHIVE3]" >> $LOG
echo "[ARCHIVE3]"
MOD="ARCHIVE3"
ARCHIVE3=$(cat $TARGET | awk '/\[ARCHIVE3\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')


if [[ -z "$ARCHIVE3" ]]; then
    echo "В файле: $NAME_FILE нет интервального архива"
    echo "---------------------------"
    echo ""
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][В тестируемом файле нет интервального архива]" >> $LOG
    exit 0
fi

arcnums=$(echo "$ARCHIVE3" | wc -l)

# запись в log
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Количество записей: $arcnums]" >> $LOG

for ((i=1; i<=$arcnums; i++)); do
    ind="NR==$i"
    line=$(echo "$ARCHIVE3" | awk $ind)
    IFS=';' read -r -a arr <<< "$line"

export PGPASSWORD=$Password
devdate=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT devdate FROM archives.intarc
where flow_id = $flow_id and arcnum = ${arr[0]};")
unset PGPASSWORD
devdate=$(date -d "$devdate" +"%d.%m.%Y %H:%M:%S" 2>/dev/null)

export PGPASSWORD=$Password
arcdata=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT arcdata FROM archives.intarc
where flow_id = $flow_id and arcnum = ${arr[0]};")
unset PGPASSWORD


if [[ "$VER_PROTOCOL" -eq 0 && -n "$VERS_S" ]]; then
    VSTOT=$(echo "$arcdata" | jq -r '.VSTOT')
    T=$(echo "$arcdata" | jq -r '.T')
    T=$(echo "scale=2; $T / 1" | bc)
    [[ $T == .* ]] && T="0$T"
    [[ $T == -.* ]] && T=$(echo "$T" | sed 's/^-./-0./')
    T_OUT=$(echo "$arcdata" | jq -r '.T_OUT')
    T_OUT=$(echo "scale=2; $T_OUT / 1" | bc)
    [[ $T_OUT == .* ]] && T="0$T_OUT"
    K=$(echo "$arcdata" | jq -r '.K')
    TMRSTATE=$(echo "$arcdata" | jq -r '.TMRSTATE')
    WARNINGSTATE=$(echo "$arcdata" | jq -r '.WARNINGSTATE')
    CRASHSTATE=$(echo "$arcdata" | jq -r '.CRASHSTATE')
    EVENTCODE=$(echo "$arcdata" | jq -r '.EVENTCODE')
    VSTOT=$(echo "$arcdata" | jq -r '.VSTOT')
    SENSORSTATE=$(echo "$arcdata" | jq -r '.SENSORSTATE')
    VALVESTATE=$(echo "$arcdata" | jq -r '.VALVESTATE')
    ALARMSTATE=$(echo "$arcdata" | jq -r '.ALARMSTATE')
    VSUND=$(echo "$arcdata" | jq -r '.VSUND')

    F_devdate=$(echo "${arr[1]}" | sed 's/,/ /g')
    F_VSTOT=$(echo "scale=4; ${arr[2]} * $VOLUME_PULSE" | bc)
    if [[ "$F_VSTOT" == *0 ]]; then
        F_VSTOT=$(echo "$F_VSTOT" | sed 's/0*$//')
    fi
    if [[ "$F_VSTOT" == .* ]]; then
        F_VSTOT="0$F_VSTOT"
    fi
    if [ -z "$F_VSTOT" ]; then
        F_VSTOT=0
    fi
    F_T=${arr[3]}
    F_T_OUT=${arr[4]}
    F_K=${arr[5]}
    F_VSUND=$F_VSTOT

else
    VSTOT=$(echo "$arcdata" | jq -r '.VSTOT')
    T=$(echo "$arcdata" | jq -r '.T')
    T=$(echo "scale=2; $T / 1" | bc)
    [[ $T == .* ]] && T="0$T"
    [[ $T == -.* ]] && T=$(echo "$T" | sed 's/^-./-0./')
    if [[ -n $VERS_K ]]; then
        T_OUT=$(echo "$arcdata" | jq -r '.T_OUT')
        T_OUT=$(echo "scale=2; $T_OUT / 1" | bc)
        [[ $T_OUT == .* ]] && T_OUT="0$T_OUT"
        [[ $T_OUT == -.* ]] && T_OUT=$(echo "$T_OUT" | sed 's/^-./-0./')
    else
        T_OUT=""
    fi
    K=$(echo "$arcdata" | jq -r '.K')
    TMRSTATE=$(echo "$arcdata" | jq -r '.TMRSTATE')
    WARNINGSTATE=$(echo "$arcdata" | jq -r '.WARNINGSTATE')
    CRASHSTATE=$(echo "$arcdata" | jq -r '.CRASHSTATE')
    EVENTCODE=$(echo "$arcdata" | jq -r '.EVENTCODE')
    VSUND=$(echo "$arcdata" | jq -r '.VSUND')
    SENSORSTATE=$(echo "$arcdata" | jq -r '.SENSORSTATE')
    VALVESTATE=$(echo "$arcdata" | jq -r '.VALVESTATE')
    BATTERY_PERCENT=$(echo "$arcdata" | jq -r '.BATTERY_PERCENT')
    BATTERY_PERCENT_INPUT=$(echo "$arcdata" | jq -r '.BATTERY_PERCENT_INPUT')
    ALARMSTATE=$(echo "$arcdata" | jq -r '.ALARMSTATE')
    RPUSTATE=$(echo "$arcdata" | jq -r '.RPUSTATE')
    SENSORSTATE_PR=$(echo "$arcdata" | jq -r '.SENSORSTATE_PR')
    VALVESTATE_PR=$(echo "$arcdata" | jq -r '.VALVESTATE_PR')
    VSUND=$(echo "$arcdata" | jq -r '.VSUND')

    F_devdate=$(echo "${arr[1]}" | sed 's/,/ /g')
    if [ -n "${arr[2]}" ] && [ "${arr[2]}" != 0 ]; then
        F_VSUND=$(echo "${arr[2]}" | grep -oE '[0-9]+')
        F_VSUND=$(echo "scale=4; $F_VSUND * $VOLUME_PULSE" | bc 2>/dev/null)
        [[ "$F_VSUND" == *0 ]] && F_VSUND=$(echo "$F_VSUND" | sed 's/0*$//')
        [[ $F_VSUND == .* ]] && F_VSUND="0$F_VSUND"
    else
        F_VSUND=0
    fi

    if [ -n "${arr[12]}" ] && [ "${arr[12]}" != 0 ]; then
        F_VSTOT=$(echo "${arr[12]}" | grep -oE '[0-9]+' 2>/dev/null)
        F_VSTOT=$(echo "scale=4; $F_VSTOT * $VOLUME_PULSE" | bc)
        [[ "$F_VSTOT" == *0 ]] && F_VSTOT=$(echo "$F_VSTOT" | sed 's/0*$//')
        [[ $F_VSTOT == .* ]] && F_VSTOT="0$F_VSTOT"
    else
        F_VSTOT=$F_VSUND
    fi


    F_T=${arr[3]}
    F_T_OUT=${arr[4]}
    F_K=${arr[5]}
    F_TMRSTATE=$(printf "%d" 0x"${arr[6]}" 2>/dev/null)
    F_WARNINGSTATE=$(printf "%d" 0x"${arr[7]}" 2>/dev/null)
    F_ALARMSTATE=$(printf "%d" 0x"${arr[8]}" 2>/dev/null)
    F_CRASHSTATE=$(printf "%d" 0x"${arr[9]}" 2>/dev/null)
    F_EVENTCODE=$(printf "%d" 0x"${arr[10]}" 2>/dev/null)
    if [[ "$F_EVENTCODE" != "$EVENTCODE" ]]; then
        F_EVENTCODE=$((16#${arr[10]}))
    fi


    if [ -n "${arr[13]}" ]; then
        F_SENSORSTATE=$(printf "%d" 0x"${arr[13]}" 2>/dev/null)
    else
        F_SENSORSTATE=""
    fi
    if [ -n "${arr[15]}" ]; then
        F_VALVESTATE=$(echo "${arr[15]}" | grep -oE '[0-9]+' 2>/dev/null)
    else
        F_VALVESTATE=""
    fi
    if [ -n "${arr[16]}" ]; then
        F_BATTERY_PERCENT=$(echo "scale=2; ${arr[16]} / 100" | bc 2>/dev/null)
        if [[ "$F_BATTERY_PERCENT" == *"0" ]]; then
            F_BATTERY_PERCENT="${F_BATTERY_PERCENT%0}"
        fi
    else
        F_BATTERY_PERCENT=""
    fi
    if [ -n "${arr[17]}" ]; then
        F_BATTERY_PERCENT_INPUT=$(echo "${arr[17]}" | grep -oE '[0-9]+' 2>/dev/null)
        F_BATTERY_PERCENT_INPUT=$(echo "scale=2; $F_BATTERY_PERCENT_INPUT / 100" | bc | sed 's/\.*0*$//' 2>/dev/null)
        if [[ "$F_BATTERY_PERCENT_INPUT" == *"0" ]] && [[ "$F_BATTERY_PERCENT_INPUT" != 100 ]]; then
            F_BATTERY_PERCENT_INPUT="${F_BATTERY_PERCENT_INPUT%0}"
        fi
    else
        F_BATTERY_PERCENT_INPUT=""
    fi

fi

        echo "arcnum: ${arr[0]}"
        echo ""

        sleep 0.03
        if echo "$F_devdate" | grep -wq "$devdate"; then
            echo "DEVDATE"
            echo -e "${GREEN}F: $F_devdate${NC}"
            echo -e "${GREEN}B: $devdate${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} DEVDATE: FILE -> $F_devdate DB -> $devdate значения совпали]" >> $LOG
        else
            echo "DEVDATE"
            echo -e "${RED}F: $F_devdate${NC}"
            echo -e "${RED}B: $devdate${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} DEVDATE: FILE -> $F_devdate DB -> $devdate значения не совпали]" >> $LOG
        fi

        sleep 0.03
        if echo "$F_VSTOT" | grep -wq "$VSTOT"; then
            echo "VSTOT"
            echo -e "${GREEN}F: $F_VSTOT${NC}"
            echo -e "${GREEN}B: $VSTOT${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} VSTOT: FILE -> $F_VSTOT DB -> $VSTOT значения совпали]" >> $LOG
        else
            echo "VSTOT"
            echo -e "${RED}F: $F_VSTOT${NC}"
            echo -e "${RED}B: $VSTOT${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} VSTOT: FILE -> $F_VSTOT DB -> $VSTOT значения не совпали]" >> $LOG
        fi

         sleep 0.03
         if [[ "$F_T" == "$T" ]]; then
             echo "T"
             echo -e "${GREEN}F: $F_T${NC}"
             echo -e "${GREEN}B: $T${NC}"
             # запись в log
             TIME_STR=$(date +"%H:%M:%S")
             echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} T: FILE -> $F_T DB -> $T значения совпали]" >> $LOG
         else
             echo "T"
             echo -e "${RED}F: $F_T${NC}"
             echo -e "${RED}B: $T${NC}"
             # запись в log
             TIME_STR=$(date +"%H:%M:%S")
             echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} T: FILE -> $F_T DB -> $T значения не совпали]" >> $LOG
         fi

    if [ -n "$T_OUT" ]; then
        sleep 0.03
        if [[ "$F_T_OUT" == "$T_OUT" ]]; then
            echo "T_OUT"
            echo -e "${GREEN}F: $F_T_OUT${NC}"
            echo -e "${GREEN}B: $T_OUT${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} T_OUT: FILE -> $F_T_OUT DB -> $T_OUT значения совпали]" >> $LOG
        else
            echo "T_OUT"
            echo -e "${RED}F: $F_T_OUT${NC}"
            echo -e "${RED}B: $T_OUT${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} T_OUT: FILE -> $F_T_OUT DB -> $T_OUT значения не совпали]" >> $LOG
        fi
    fi

         sleep 0.03
         if echo "$F_K" | grep -wq "$K"; then
             echo "K"
             echo -e "${GREEN}F: $F_K${NC}"
             echo -e "${GREEN}B: $K${NC}"
             # запись в log
             TIME_STR=$(date +"%H:%M:%S")
             echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} K: FILE -> $F_K DB -> $K значения совпали]" >> $LOG
         else
             echo "K"
             echo -e "${RED}F: $F_K${NC}"
             echo -e "${RED}B: $K${NC}"
             # запись в log
             TIME_STR=$(date +"%H:%M:%S")
             echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} K: FILE -> $F_K DB -> $K значения не совпали]" >> $LOG
         fi

        sleep 0.03
        if echo "$F_TMRSTATE" | grep -wq "$TMRSTATE"; then
            echo "TMRSTATE"
            echo -e "${GREEN}F: $F_TMRSTATE${NC}"
            echo -e "${GREEN}B: $TMRSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} TMRSTATE: FILE -> $F_TMRSTATE DB -> $TMRSTATE значения совпали]" >> $LOG
        else
            echo "TMRSTATE"
            echo -e "${RED}F: $F_TMRSTATE${NC}"
            echo -e "${RED}B: $TMRSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} TMRSTATE: FILE -> $F_TMRSTATE DB -> $TMRSTATE значения не совпали]" >> $LOG
        fi

    if [ -n "$F_WARNINGSTATE" ]; then
        sleep 0.03
        if echo "$F_WARNINGSTATE" | grep -wq "$WARNINGSTATE"; then
            echo "WARNINGSTATE"
            echo -e "${GREEN}F: $F_WARNINGSTATE${NC}"
            echo -e "${GREEN}B: $WARNINGSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} WARNINGSTATE: FILE -> $F_WARNINGSTATE DB -> $WARNINGSTATE значения совпали]" >> $LOG
        else
            echo "WARNINGSTATE"
            echo -e "${RED}F: $F_WARNINGSTATE${NC}"
            echo -e "${RED}B: $WARNINGSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} WARNINGSTATE: FILE -> $F_WARNINGSTATE DB -> $WARNINGSTATE значения не совпали]" >> $LOG
        fi
    fi

    if [ -n "$F_ALARMSTATE" ]; then
        sleep 0.03
        if echo "$F_ALARMSTATE" | grep -wq "$ALARMSTATE"; then
            echo "ALARMSTATE"
            echo -e "${GREEN}F: $F_ALARMSTATE${NC}"
            echo -e "${GREEN}B: $ALARMSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} ALARMSTATE: FILE -> $F_ALARMSTATE DB -> $ALARMSTATE значения совпали]" >> $LOG
        else
            echo "ALARMSTATE"
            echo -e "${RED}F: $F_ALARMSTATE${NC}"
            echo -e "${RED}B: $ALARMSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} ALARMSTATE: FILE -> $F_ALARMSTATE DB -> $ALARMSTATE значения не совпали]" >> $LOG
        fi
    fi

    if [ -n "$F_CRASHSTATE" ]; then
        sleep 0.03
        if echo "$F_CRASHSTATE" | grep -wq "$CRASHSTATE"; then
            echo "CRASHSTATE"
            echo -e "${GREEN}F: $F_CRASHSTATE${NC}"
            echo -e "${GREEN}B: $CRASHSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} CRASHSTATE: FILE -> $F_CRASHSTATE DB -> $CRASHSTATE значения совпали]" >> $LOG
        else
            echo "CRASHSTATE"
            echo -e "${RED}F: $F_CRASHSTATE${NC}"
            echo -e "${RED}B: $CRASHSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} CRASHSTATE: FILE -> $F_CRASHSTATE DB -> $CRASHSTATE значения не совпали]" >> $LOG
        fi
    fi

    if [ -n "$F_EVENTCODE" ]; then
        sleep 0.03
        if [[ "$F_EVENTCODE" == "$EVENTCODE" ]]; then
            echo "EVENTCODE"
            echo -e "${GREEN}F: $F_EVENTCODE${NC}"
            echo -e "${GREEN}B: $EVENTCODE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} EVENTCODE: FILE -> $F_EVENTCODE DB -> $EVENTCODE значения совпали]" >> $LOG
        else
            echo "EVENTCODE"
            echo -e "${RED}F: $F_EVENTCODE${NC}"
            echo -e "${RED}B: $EVENTCODE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} EVENTCODE: FILE -> $F_EVENTCODE DB -> $EVENTCODE значения не совпали]" >> $LOG
        fi
    fi

        sleep 0.03
        if [[ "$F_VSUND" == "$VSUND" ]]; then
            echo "VSUND"
            echo -e "${GREEN}F: $F_VSUND${NC}"
            echo -e "${GREEN}B: $VSUND${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} VSUND: FILE -> $F_VSUND DB -> $VSUND значения совпали]" >> $LOG
        else
            echo "VSUND"
            echo -e "${RED}F: $F_VSUND${NC}"
            echo -e "${RED}B: $VSUND${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} VSUND: FILE -> $F_VSUND DB -> $VSUND значения не совпали]" >> $LOG
        fi

    if [ -n "$F_SENSORSTATE" ]; then
        sleep 0.03
        if [[ "$F_SENSORSTATE" == "$SENSORSTATE" ]]; then
            echo "SENSORSTATE"
            echo -e "${GREEN}F: $F_SENSORSTATE${NC}"
            echo -e "${GREEN}B: $SENSORSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} SENSORSTATE: FILE -> $F_SENSORSTATE DB -> $SENSORSTATE значения совпали]" >> $LOG
        else
            echo "SENSORSTATE"
            echo -e "${RED}F: $F_SENSORSTATE${NC}"
            echo -e "${RED}B: $SENSORSTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} SENSORSTATE: FILE -> $F_SENSORSTATE DB -> $SENSORSTATE значения не совпали]" >> $LOG
        fi
    fi

    if [ -n "$F_VALVESTATE" ]; then
        sleep 0.03
        if echo "$F_VALVESTATE" | grep -wq "$VALVESTATE"; then
            echo "VALVESTATE"
            echo -e "${GREEN}F: $F_VALVESTATE${NC}"
            echo -e "${GREEN}B: $VALVESTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} VALVESTATE: FILE -> $F_VALVESTATE DB -> $VALVESTATE значения совпали]" >> $LOG
        else
            echo "VALVESTATE"
            echo -e "${RED}F: $F_VALVESTATE${NC}"
            echo -e "${RED}B: $VALVESTATE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} VALVESTATE: FILE -> $F_VALVESTATE DB -> $VALVESTATE значения не совпали]" >> $LOG
        fi
    fi

    if [ -n "$F_BATTERY_PERCENT" ]; then
        sleep 0.03
        if echo "$F_BATTERY_PERCENT" | grep -wq "$BATTERY_PERCENT"; then
            echo "BATTERY_PERCENT"
            echo -e "${GREEN}F: $F_BATTERY_PERCENT${NC}"
            echo -e "${GREEN}B: $BATTERY_PERCENT${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} BATTERY_PERCENT: FILE -> $F_BATTERY_PERCENT DB -> $BATTERY_PERCENT значения совпали]" >> $LOG
        else
            echo "BATTERY_PERCENT"
            echo -e "${RED}F: $F_BATTERY_PERCENT${NC}"
            echo -e "${RED}B: $BATTERY_PERCENT${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} BATTERY_PERCENT: FILE -> $F_BATTERY_PERCENT DB -> $BATTERY_PERCENT значения не совпали]" >> $LOG
        fi
    fi

    if [ -n "$F_BATTERY_PERCENT_INPUT" ]; then
           sleep 0.03
        if echo "$F_BATTERY_PERCENT_INPUT" | grep -wq "$BATTERY_PERCENT_INPUT"; then
            echo "BATTERY_PERCENT_INPUT"
            echo -e "${GREEN}F: $F_BATTERY_PERCENT_INPUT${NC}"
            echo -e "${GREEN}B: $BATTERY_PERCENT_INPUT${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} BATTERY_PERCENT_INPUT: FILE -> $F_BATTERY_PERCENT_INPUT DB -> $BATTERY_PERCENT_INPUT значения совпали]" >> $LOG
        else
            echo "BATTERY_PERCENT_INPUT"
            echo -e "${RED}F: $F_BATTERY_PERCENT_INPUT${NC}"
            echo -e "${RED}B: $BATTERY_PERCENT_INPUT${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} BATTERY_PERCENT_INPUT: FILE -> $F_BATTERY_PERCENT_INPUT DB -> $BATTERY_PERCENT_INPUT значения не совпали]" >> $LOG
        fi
    fi

    echo "---------------------------"
done
