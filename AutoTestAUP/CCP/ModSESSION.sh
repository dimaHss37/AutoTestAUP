#!/bin/bash

TIME_STR=$(date +"%H:%M:%S")
echo "[SESSION]" >> $LOG
echo -e "\e[1m[SESSION]\e[0m"
echo "---------------------------"
MOD="SESSION"
SESSION=$(cat $TARGET | awk '/\[SESSION\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/SESSION/d' | sed '/#/d')


F_date_connect=$(echo "$SESSION" | grep "DTSTART")
F_date_connect=$(echo "${F_date_connect#*=}" | sed 's/[[:space:]]*$//')

F_date_end=$(echo "$SESSION" | grep "DTEND")
F_date_end=$(echo "${F_date_end#*=}" | sed 's/[[:space:]]*$//')

F_status=$(echo "$SESSION" | grep "STATUS" | grep -o '[0-9]\+')

export PGPASSWORD=$Password
date_connect=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select date_connect from server.session
where device_id=$device_id;")
unset PGPASSWORD
date_connect=$(echo "${date_connect%.*}")


export PGPASSWORD=$Password
date_end=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select date_end from server.session
where device_id=$device_id;")
unset PGPASSWORD
date_end=$(echo "${date_end%.*}")



export PGPASSWORD=$Password
status=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select status from server.session
where device_id=$device_id;")
unset PGPASSWORD

ind=$(echo "${F_date_connect#*.*.}" | cut -d',' -f1 | wc -m)
if [[ $ind -gt 3 ]]; then
    date_connect=$(date -d "$date_connect" +"%d.%m.%Y,%H:%M:%S")
    date_end=$(date -d "$date_end" +"%d.%m.%Y,%H:%M:%S")
else
    date_connect=$(date -d "$date_connect" +"%d.%m.%y,%H:%M:%S")
    date_end=$(date -d "$date_end" +"%d.%m.%y,%H:%M:%S")
fi




sleep 0.03
if echo "$F_date_connect" | grep -wq "$date_connect"; then
    echo "DTSTART"
    echo -e "${GREEN}F: $F_date_connect${NC}"
    echo -e "${GREEN}B: $date_connect${NC}"
    # запись в log
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][DTSTART: FILE -> $F_date_connect DB -> $date_connect значения совпали]" >> $LOG
else
    echo "DTSTART"
    echo -e "${RED}F: $F_date_connect${NC}"
    echo -e "${RED}B: $date_connect${NC}"
    # запись в log
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][DTSTART: FILE -> $F_date_connect DB -> $date_connect значения не совпали]" >> $LOG
fi

sleep 0.03
if echo "$F_date_end" | grep -wq "$date_end"; then
    echo "DTEND"
    echo -e "${GREEN}F: $F_date_end${NC}"
    echo -e "${GREEN}B: $date_end${NC}"
    # запись в log
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][DTEND: FILE -> $F_date_end DB -> $date_end значения совпали]" >> $LOG
else
    echo "DTEND"
    echo -e "${RED}F: $F_date_end${NC}"
    echo -e "${RED}B: $date_end${NC}"
    # запись в log
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][DTEND: FILE -> $F_date_end DB -> $date_end значения не совпали]" >> $LOG
fi

sleep 0.03
if echo "$F_status" | grep -wq "$status"; then
    echo "STATUS"
    echo -e "${GREEN}F: $F_status${NC}"
    echo -e "${GREEN}B: $status${NC}"
    echo "---------------------------"
    # запись в log
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][STATUS: FILE -> $F_status DB -> $status значения совпали]" >> $LOG
else
    echo "STATUS"
    echo -e "${RED}F: $F_status${NC}"
    echo -e "${RED}B: $status${NC}"
    echo "---------------------------"
    # запись в log
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][STATUS: FILE -> $F_status DB -> $status значения не совпали]" >> $LOG
fi

echo ""
