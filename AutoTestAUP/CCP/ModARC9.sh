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

P_NAME_FILE=$(echo "$NAME_FILE" | grep -o "_" | wc -l)
if [ $P_NAME_FILE == 3 ]; then
    devnum=$(echo "${NAME_FILE#*_}")
    devnum=$(echo "${devnum#*_}")
    devnum=$(echo "${devnum%_*}")
else
    devnum=$(echo "$NAME_FILE" | sed 's/.*_//' | cut -d'.' -f1)
fi

export PGPASSWORD=$Password
device_id=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select id from devices_custs.device
where devnum='$devnum';")
unset PGPASSWORD

export PGPASSWORD=$Password
flow_id=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT id FROM devices_custs.flow
where device_id = $device_id;")
unset PGPASSWORD


# Путь к обрабатываемому файлу
TARGET="$ACTIVE_DIR/rdt/$NAME_FILE"

#VER_PROTOCOL
VER_PROTOCOL=$(cat $TARGET | grep protocol -i | grep -o '[0-9]\+')
if [[ -z "$VER_PROTOCOL" ]]; then
    VER_PROTOCOL=0
fi
if [[ "$VER_PROTOCOL" = 0 ]]; then
    echo "Версия протокола: $VER_PROTOCOL"
    exit 0
fi
DATE_STR=$(date +"%d.%m.%Y")
# запись в log
echo "[ARCHIVE9]" >> $LOG
echo "[ARCHIVE9]"
MOD="ARCHIVE9"
ARCHIVE9=$(cat $TARGET | awk '/\[ARCHIVE9\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')

if [[ -z "$ARCHIVE9" ]]; then
    echo "В файле: $NAME_FILE нет архива телеметрии"
    echo ""
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][В тестируемом файле нет архива телеметрии]" >> $LOG
    exit 0
fi

arcnums=$(echo "$ARCHIVE9" | wc -l)

# запись в log
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Количество записей: $arcnums]" >> $LOG

for ((i=1; i<=$arcnums; i++)); do
    ind="NR==$i"
    line=$(echo "$ARCHIVE9" | awk $ind)
    values=$(echo "$line" | grep -o ";" | wc -l)
    values=$((values + 1))

    IFS=';' read -r -a arr <<< "$line"

   # берём данные из archives.telemetryarc
    export PGPASSWORD=$Password
    details=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT details FROM archives.telemetryarc
    where device_id  = $device_id and arcnum = ${arr[0]};")
    unset PGPASSWORD
    SERVERCODE1=$(echo "$details" | jq -r '.SERVERCODE1')
    SERVERCODE2=$(echo "$details" | jq -r '.SERVERCODE2')
    SERVERCODE3=$(echo "$details" | jq -r '.SERVERCODE3')
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


    F_SERVERCODE1=${arr[4]}
    F_SERVERCODE2=${arr[5]}
    F_SERVERCODE3=${arr[6]}
    F_TMRSTATE=$(printf "%d" 0x"${arr[9]}" 2>/dev/null)
    F_DATE_START=$(echo "${arr[1]}" | sed 's/,/ /g')
    F_DATE_END=$(echo "${arr[2]}" | sed 's/,/ /g')
    F_ERROR_CODE=${arr[7]}
    F_SEANCE_NUM=${arr[8]}



    echo "arcnum: ${arr[0]}"
    echo ""

    sleep 0.05
    if echo "$F_DATE_START" | grep -wq "$DATE_START"; then
        echo "DATE_START"
        echo -e "${GREEN}F: $F_DATE_START${NC}"
        echo -e "${GREEN}B: $DATE_START${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} DATE_START: FILE ==> $F_DATE_START DB ==> $DATE_START параметры совпали]" >> $LOG
    else
        echo "DATE_START"
        echo -e "${RED}F: $F_DATE_START${NC}"
        echo -e "${RED}B: $DATE_START${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} DATE_START: FILE ==> $F_DATE_START DB ==> $DATE_START параметры не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_DATE_END" | grep -wq "$DATE_END"; then
        echo "DATE_END"
        echo -e "${GREEN}F: $F_DATE_END${NC}"
        echo -e "${GREEN}B: $DATE_END${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} DATE_END: FILE ==> $F_DATE_END DB ==> $DATE_END параметры совпали]" >> $LOG
    else
        echo "DATE_END"
        echo -e "${RED}F: $F_DATE_END${NC}"
        echo -e "${RED}B: $DATE_END${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} DATE_END: FILE ==> $F_DATE_END DB ==> $DATE_END параметры не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_SEANCE_NUM" | grep -wq "$SEANCE_NUM"; then
        echo "SEANCE_NUM"
        echo -e "${GREEN}F: $F_SEANCE_NUM${NC}"
        echo -e "${GREEN}B: $SEANCE_NUM${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} SEANCE_NUM: FILE ==> $F_SEANCE_NUM DB ==> $SEANCE_NUM параметры совпали]" >> $LOG
    else
        echo "SEANCE_NUM"
        echo -e "${RED}F: $F_SEANCE_NUM${NC}"
        echo -e "${RED}B: $SEANCE_NUM${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} SEANCE_NUM: FILE ==> $F_SEANCE_NUM DB ==> $SEANCE_NUM параметры не совпали]" >> $LOG
    fi

    sleep 0.05
    if [[ "$F_ERROR_CODE" == "$ERROR_CODE" ]]; then
        echo "ERROR_CODE"
        echo -e "${GREEN}F: $F_ERROR_CODE${NC}"
        echo -e "${GREEN}B: $ERROR_CODE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} ERROR_CODE: FILE ==> $F_ERROR_CODE DB ==> $ERROR_CODE параметры совпали]" >> $LOG
    else
        echo "ERROR_CODE"
        echo -e "${RED}F: $F_ERROR_CODE${NC}"
        echo -e "${RED}B: $ERROR_CODE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} ERROR_CODE: FILE ==> $F_ERROR_CODE DB ==> $ERROR_CODE параметры не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_SERVERCODE1" | grep -wq "$SERVERCODE1"; then
        echo "SERVERCODE1"
        echo -e "${GREEN}F: $F_SERVERCODE1${NC}"
        echo -e "${GREEN}B: $SERVERCODE1${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} SERVERCODE1: FILE ==> $F_SERVERCODE1 DB ==> $SERVERCODE1 параметры совпали]" >> $LOG
    else
        echo "SERVERCODE1"
        echo -e "${RED}F: $F_SERVERCODE1${NC}"
        echo -e "${RED}B: $SERVERCODE1${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} SERVERCODE1: FILE ==> $F_SERVERCODE1 DB ==> $SERVERCODE1 параметры не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_SERVERCODE2" | grep -wq "$SERVERCODE2"; then
        echo "SERVERCODE2"
        echo -e "${GREEN}F: $F_SERVERCODE2${NC}"
        echo -e "${GREEN}B: $SERVERCODE2${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} SERVERCODE2: FILE ==> $F_SERVERCODE2 DB ==> $SERVERCODE2 параметры совпали]" >> $LOG
    else
        echo "SERVERCODE2"
        echo -e "${RED}F: $F_SERVERCODE2${NC}"
        echo -e "${RED}B: $SERVERCODE2${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} SERVERCODE2: FILE ==> $F_SERVERCODE2 DB ==> $SERVERCODE2 параметры не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_SERVERCODE3" | grep -wq "$SERVERCODE3"; then
        echo "SERVERCODE3"
        echo -e "${GREEN}F: $F_SERVERCODE3${NC}"
        echo -e "${GREEN}B: $SERVERCODE3${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} SERVERCODE3: FILE ==> $F_SERVERCODE3 DB ==> $SERVERCODE3 параметры совпали]" >> $LOG
    else
        echo "SERVERCODE3"
        echo -e "${RED}F: $F_SERVERCODE3${NC}"
        echo -e "${RED}B: $SERVERCODE3${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} SERVERCODE3: FILE ==> $F_SERVERCODE3 DB ==> $SERVERCODE3 параметры не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_TMRSTATE" | grep -wq "$TMRSTATE"; then
        echo "TMRSTATE"
        echo -e "${GREEN}F: $F_TMRSTATE${NC}"
        echo -e "${GREEN}B: $TMRSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} TMRSTATE: FILE ==> $F_TMRSTATE DB ==> $TMRSTATE параметры совпали]" >> $LOG
    else
        echo "TMRSTATE"
        echo -e "${RED}F: $F_TMRSTATE${NC}"
        echo -e "${RED}B: $TMRSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} TMRSTATE: FILE ==> $F_TMRSTATE DB ==> $TMRSTATE параметры не совпали]" >> $LOG
    fi

    echo "---------------------------"
done
