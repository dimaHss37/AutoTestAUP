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


DATE_STR=$(date +"%d.%m.%Y")
# запись в log
echo "[ARCHIVE4]" >> $LOG
echo "[ARCHIVE4]"
MOD="ARCHIVE4"
ARCHIVE4=$(cat $TARGET | awk '/\[ARCHIVE4\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')

if [[ -z "$ARCHIVE4" ]]; then
    echo "В файле: $NAME_FILE нет архива событий"
    echo "---------------------------"
    echo ""
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][В тестируемом файле нет архива событий]" >> $LOG
    exit 0
fi


#VER_PROTOCOL
VER_PROTOCOL=$(cat $TARGET | grep protocol -i | grep -o '[0-9]\+')
if [[ -z "$VER_PROTOCOL" ]]; then
    VER_PROTOCOL=0
fi
if [[ "$VER_PROTOCOL" != 0 ]]; then
    TIME_STR=$(date +"%H:%M:%S")
    echo "Версия протокола: $VER_PROTOCOL" >> $LOG
    echo "Версия протокола: $VER_PROTOCOL"
    exit 0
fi

arcnums=$(echo "$ARCHIVE4" | wc -l)

# запись в log
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Количество записей: $arcnums]" >> $LOG

for ((i=1; i<=$arcnums; i++)); do
    ind="NR==$i"
    line=$(echo "$ARCHIVE4" | awk $ind)
    values=$(echo "$line" | grep -o ";" | wc -l)
    values=$((values + 1))

    IFS=';' read -r -a arr <<< "$line"

    if [[ "${arr[3]}" == 11 ]]; then

        export PGPASSWORD=$Password
        event_details=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT event_details FROM archives.eventarc
        where flow_id = $flow_id and arcnum = ${arr[0]};")
        unset PGPASSWORD

        DEV_DATE_END=$(echo "$event_details" | jq -r '.DEV_DATE_END')
        SEANCE_NUM=$(echo "$event_details" | jq -r '.SEANCE_NUM')
        STATUS=$(echo "$event_details" | jq -r '.STATUS')
        TMRSTATE=$(echo "$event_details" | jq -r '.TMRSTATE')

        F_STATUS=${arr[4]}
        F_SEANCE_NUM=${arr[5]}
        F_DEV_DATE_END=$(echo "${arr[2]}" | sed 's/,/ /g')
        F_TMRSTATE=$(printf "%d" 0x"${arr[6]}" 2>/dev/null)

        echo "arcnum: ${arr[0]}"
        echo ""

        sleep 0.05
        if echo "$F_DEV_DATE_END" | grep -wq "$DEV_DATE_END"; then
            echo "DEV_DATE_END"
            echo -e "${GREEN}F: $F_DEV_DATE_END${NC}"
            echo -e "${GREEN}B: $DEV_DATE_END${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} DEV_DATE_END: FILE -> $F_DEV_DATE_END DB -> $DEV_DATE_END значения совпали]" >> $LOG
        else
            echo "DEV_DATE_END"
            echo -e "${RED}F: $F_DEV_DATE_END${NC}"
            echo -e "${RED}B: $DEV_DATE_END${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} DEV_DATE_END: FILE -> $F_DEV_DATE_END DB -> $DEV_DATE_END значения не совпали]" >> $LOG
        fi

        sleep 0.05
        if echo "$F_SEANCE_NUM" | grep -wq "$SEANCE_NUM"; then
            echo "SEANCE_NUM"
            echo -e "${GREEN}F: $F_SEANCE_NUM${NC}"
            echo -e "${GREEN}B: $SEANCE_NUM${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} SEANCE_NUM -> FILE: $F_SEANCE_NUM DB -> $SEANCE_NUM значения совпали]" >> $LOG
        else
            echo "SEANCE_NUM"
            echo -e "${RED}F: $F_SEANCE_NUM${NC}"
            echo -e "${RED}B: $SEANCE_NUM${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} SEANCE_NUM -> FILE: $F_SEANCE_NUM DB -> $SEANCE_NUM значения не совпали]" >> $LOG
        fi

        sleep 0.05
        if echo "$F_STATUS" | grep -wq "$STATUS"; then
            echo "STATUS"
            echo -e "${GREEN}F: $F_STATUS${NC}"
            echo -e "${GREEN}B: $STATUS${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} STATUS: FILE -> $F_STATUS DB -> $STATUS значения совпали]" >> $LOG
        else
            echo "STATUS"
            echo -e "${RED}F: $F_STATUS${NC}"
            echo -e "${RED}B: $STATUS${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} STATUS: FILE -> $F_STATUS DB -> $STATUS значения не совпали]" >> $LOG
        fi

        sleep 0.05
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

        echo "---------------------------"

    else
        # берём данные из archives.telemetryarc
        export PGPASSWORD=$Password
        details=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT details FROM archives.telemetryarc
        where device_id  = $device_id and arcnum = ${arr[0]};")
        unset PGPASSWORD
        TMRSTATE=$(echo "$details" | jq -r '.TMRSTATE')

        export PGPASSWORD=$Password
        DATE_START=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT date_start FROM archives.telemetryarc
        where device_id  = $device_id and arcnum = ${arr[0]};")
        unset PGPASSWORD
        DATE_START=$(date -d "$DATE_START" +"%d.%m.%Y %H:%M:%S")

        export PGPASSWORD=$Password
        DATE_END=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT date_end FROM archives.telemetryarc
        where device_id  = $device_id and arcnum = ${arr[0]};")
        unset PGPASSWORD
        DATE_END=$(date -d "$DATE_END" +"%d.%m.%Y %H:%M:%S")

        export PGPASSWORD=$Password
        SEANCE_NUM=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT seance_num FROM archives.telemetryarc
        where device_id  = $device_id and arcnum = ${arr[0]};")
        unset PGPASSWORD

        export PGPASSWORD=$Password
        ERROR_CODE=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT error_code FROM archives.telemetryarc
        where device_id  = $device_id and arcnum = ${arr[0]};")
        unset PGPASSWORD

        F_DATE_START=$(echo "${arr[1]}" | sed 's/,/ /g')
        F_DATE_END=$(echo "${arr[2]}" | sed 's/,/ /g')
        F_SEANCE_NUM=${arr[5]}
        F_ERROR_CODE=${arr[4]}
        F_TMRSTATE=$(printf "%d" 0x"${arr[6]}" 2>/dev/null)





        echo "arcnum: ${arr[0]}"
        echo ""

        sleep 0.05
        if echo "$F_DATE_START" | grep -wq "$DATE_START"; then
            echo "DATE_START"
            echo -e "${GREEN}F: $F_DATE_START${NC}"
            echo -e "${GREEN}B: $DATE_START${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} DATE_START: FILE -> $F_DATE_START DB -> $DATE_START значения совпали]" >> $LOG
        else
            echo "DATE_START"
            echo -e "${RED}F: $F_DATE_START${NC}"
            echo -e "${RED}B: $DATE_START${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} DATE_START: FILE -> $F_DATE_START DB -> $DATE_START значения не совпали]" >> $LOG
        fi

        sleep 0.05
        if echo "$F_DATE_END" | grep -wq "$DATE_END"; then
            echo "DATE_END"
            echo -e "${GREEN}F: $F_DATE_END${NC}"
            echo -e "${GREEN}B: $DATE_END${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} DATE_END: FILE -> $F_DATE_END DB -> $DATE_END значения совпали]" >> $LOG
        else
            echo "DATE_END"
            echo -e "${RED}F: $F_DATE_END${NC}"
            echo -e "${RED}B: $DATE_END${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} DATE_END: FILE -> $F_DATE_END DB -> $DATE_END значения не совпали]" >> $LOG
        fi

        sleep 0.05
        if echo "$F_SEANCE_NUM" | grep -wq "$SEANCE_NUM"; then
            echo "SEANCE_NUM"
            echo -e "${GREEN}F: $F_SEANCE_NUM${NC}"
            echo -e "${GREEN}B: $SEANCE_NUM${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} SEANCE_NUM: FILE -> $F_SEANCE_NUM DB -> $SEANCE_NUM значения совпали]" >> $LOG
        else
            echo "SEANCE_NUM"
            echo -e "${RED}F: $F_SEANCE_NUM${NC}"
            echo -e "${RED}B: $SEANCE_NUM${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} SEANCE_NUM: FILE -> $F_SEANCE_NUM DB -> $SEANCE_NUM значения не совпали]" >> $LOG
        fi

        sleep 0.05
        if [[ "$F_ERROR_CODE" == "$ERROR_CODE" ]]; then
            echo "ERROR_CODE"
            echo -e "${GREEN}F: $F_ERROR_CODE${NC}"
            echo -e "${GREEN}B: $ERROR_CODE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} ERROR_CODE: FILE -> $F_ERROR_CODE DB -> $ERROR_CODE значения совпали]" >> $LOG
        else
            echo "ERROR_CODE"
            echo -e "${RED}F: $F_ERROR_CODE${NC}"
            echo -e "${RED}B: $ERROR_CODE${NC}"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} ERROR_CODE: FILE -> $F_ERROR_CODE DB -> $ERROR_CODE значения не совпали]" >> $LOG
        fi

        sleep 0.05
        if [[ "$F_TMRSTATE" == "$TMRSTATE" ]]; then
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

        echo "---------------------------"

    fi

done
