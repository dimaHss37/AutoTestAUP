#!/bin/bash

# Коды цветов
RED="\033[31m" # Красный
GREEN="\033[32m" # Зеленый
NC="\033[0m" # Без цвета (сброс)

# ищем "sgs.json"
FILE_SGS_JSON=$(find /opt -type f -name "sgs.json" 2>/dev/null)
if [ -z "$FILE_SGS_JSON" ]; then
     echo "$Файл sgs.json не найден!"
     exit 0
fi

DatabaseLocation=$(cat $FILE_SGS_JSON | jq -r '.AUPService.DbWriterService.DatabaseLocation')

if [ "$DatabaseLocation" == "Local" ]; then
    DatabaseType=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.DatabaseType')
    if [ "$DatabaseType" == "PostgreSQL" ]; then
        Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Name')
        Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Host')
        Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Port')
        Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Login')
        Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Password')
    else
        echo "Firebird"
        # Запускаем подменю программы
        exit 0
    fi
else
    if [ "$DatabaseLocation" == "Server" ]; then
        DatabaseType=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.DatabaseType')
        if [ "$DatabaseType" == "PostgreSQL" ]; then
            Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Name')
            Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Host')
            Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Port')
            Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Login')
            Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Password')
        else
            echo "Firebird"
            # Запускаем подменю программы
            exit 0
        fi
    else
        echo "Некорректный sgs.json"
    fi
fi


# Путь к обрабатываемому файлу
TARGET="$ACTIVE_DIR/rdt/$NAME_FILE"

# запись в log
DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[SESSION]" >> $LOG
echo -e "\e[1m[SESSION]\e[0m"
echo "---------------------------"
MOD="SESSION"
SESSION=$(cat $TARGET | awk '/\[SESSION\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/SESSION/d' | sed '/#/d')


if [[ -z "$SESSION" ]]; then
    echo "В файле: $NAME_FILE нет секции [SESSION]"
    echo "---------------------------"
    echo ""
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][В тестируемом файле нет секции [SESSION]]" >> $LOG
    exit 0
fi

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
    echo "---------------------------"
    # запись в log
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][DTSTART: FILE -> $F_date_connect DB -> $date_connect значения совпали]" >> $LOG
else
    echo "DTSTART"
    echo -e "${RED}F: $F_date_connect${NC}"
    echo -e "${RED}B: $date_connect${NC}"
    echo "---------------------------"
    # запись в log
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][DTSTART: FILE -> $F_date_connect DB -> $date_connect значения не совпали]" >> $LOG
fi

sleep 0.03
if echo "$F_date_end" | grep -wq "$date_end"; then
    echo "DTEND"
    echo -e "${GREEN}F: $F_date_end${NC}"
    echo -e "${GREEN}B: $date_end${NC}"
    echo "---------------------------"
    # запись в log
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][DTEND: FILE -> $F_date_end DB -> $date_end значения совпали]" >> $LOG
else
    echo "DTEND"
    echo -e "${RED}F: $F_date_end${NC}"
    echo -e "${RED}B: $date_end${NC}"
    echo "---------------------------"
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
