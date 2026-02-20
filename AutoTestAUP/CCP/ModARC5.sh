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
echo "[ARCHIVE5]" >> $LOG
echo "[ARCHIVE5]"
MOD="ARCHIVE5"
ARCHIVE5=$(cat $TARGET | awk '/\[ARCHIVE5\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')

if [[ -z "$ARCHIVE5" ]]; then
    echo "В файле: $NAME_FILE нет архива изменений"
    echo "---------------------------"
    echo ""
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][В тестируемом файле нет архива изменений]" >> $LOG
    exit 0
fi

arcnums=$(echo "$ARCHIVE5" | wc -l)

# запись в log
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Количество записей: $arcnums]" >> $LOG

for ((i=1; i<=$arcnums; i++)); do
    ind="NR==$i"
    line=$(echo "$ARCHIVE5" | awk $ind)
    values=$(echo "$line" | grep -o ";" | wc -l)
    values=$((values + 1))

    IFS=';' read -r -a arr <<< "$line"

   # берём данные из archives.event_changearc
    export PGPASSWORD=$Password
    value_details=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT value_details FROM archives.event_changearc
    where device_id  = $device_id and arcnum = ${arr[0]};")
    unset PGPASSWORD
    BODYSTATE=$(echo "$value_details" | jq -r '.BODYSTATE')
    KALIBSTATE=$(echo "$value_details" | jq -r '.KALIBSTATE')
    LKG=$(echo "$value_details" | jq -r '.LKG')
    MANUFACTURERSTATE=$(echo "$value_details" | jq -r '.MANUFACTURERSTATE')
    SOURCECODE=$(echo "$value_details" | jq -r '.SOURCECODE')
    SUPPLIERSTATE=$(echo "$value_details" | jq -r '.SUPPLIERSTATE')
    export PGPASSWORD=$Password
    devdate=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT devdate FROM archives.event_changearc
    where device_id  = $device_id and arcnum = ${arr[0]};")
    unset PGPASSWORD
    devdate=$(date -d "$devdate" +"%d.%m.%Y %H:%M:%S")
    export PGPASSWORD=$Password
    value_old=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT value_old FROM archives.event_changearc
    where device_id  = $device_id and arcnum = ${arr[0]};")
    unset PGPASSWORD
    export PGPASSWORD=$Password
    value_new=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT value_new FROM archives.event_changearc
    where device_id  = $device_id and arcnum = ${arr[0]};")
    unset PGPASSWORD

    #[0]  arcnum
    #[1]  devdate
    #[2]  KALIBSTATE
    #[3]  MANUFACTURERSTATE
    #[4]  SUPPLIERSTATE
    #[5]  SOURCECODE
    #[6]
    #[7]  value_old
    #[8]  value_new
    #[9]  LKG
    #[10] BODYSTATE

    F_devdate=$(echo "${arr[1]}" | sed 's/,/ /g')
    F_KALIBSTATE=${arr[2]}
    F_MANUFACTURERSTATE=${arr[3]}
    F_SUPPLIERSTATE=${arr[4]}
    F_SOURCECODE=${arr[5]}

    F_value_old=${arr[7]}
    F_value_new=${arr[8]}
    F_LKG=${arr[9]}
    F_BODYSTATE=$(echo "${arr[10]}" | sed 's/[[:space:]]*$//')


    echo "arcnum: ${arr[0]}"
    echo ""

    sleep 0.05
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

    sleep 0.05
    if echo "$F_value_old" | grep -wq "$value_old"; then
        echo "VALUE_OLD"
        echo -e "${GREEN}F: $F_value_old${NC}"
        echo -e "${GREEN}B: $value_old${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} VALUE_OLD: FILE -> $F_value_old DB -> $value_old значения совпали]" >> $LOG
    else
        echo "VALUE_OLD"
        echo -e "${RED}F: $F_value_old${NC}"
        echo -e "${RED}B: $value_old${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} VALUE_OLD: FILE -> $F_value_old DB -> $value_old значения не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_value_new" | grep -wq "$value_new"; then
        echo "VALUE_NEW"
        echo -e "${GREEN}F: $F_value_new${NC}"
        echo -e "${GREEN}B: $value_new${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} VALUE_NEW: FILE -> $F_value_new DB -> $value_new значения совпали]" >> $LOG
    else
        echo "VALUE_NEW"
        echo -e "${RED}F: $F_value_new${NC}"
        echo -e "${RED}B: $value_new${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} VALUE_NEW: FILE -> $F_value_new DB -> $value_new значения не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_BODYSTATE" | grep -wq "$BODYSTATE"; then
        echo "BODYSTATE"
        echo -e "${GREEN}F: $F_BODYSTATE${NC}"
        echo -e "${GREEN}B: $BODYSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} BODYSTATE: FILE -> $F_BODYSTATE DB -> $BODYSTATE значения совпали]" >> $LOG
    else
        echo "BODYSTATE"
        echo -e "${RED}F: $F_BODYSTATE${NC}"
        echo -e "${RED}B: $BODYSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} BODYSTATE: FILE -> $F_BODYSTATE DB -> $BODYSTATE значения не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_KALIBSTATE" | grep -wq "$KALIBSTATE"; then
        echo "KALIBSTATE"
        echo -e "${GREEN}F: $F_KALIBSTATE${NC}"
        echo -e "${GREEN}B: $KALIBSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} KALIBSTATE: FILE -> $F_KALIBSTATE DB -> $KALIBSTATE значения совпали]" >> $LOG
    else
        echo "KALIBSTATE"
        echo -e "${RED}F: $F_KALIBSTATE${NC}"
        echo -e "${RED}B: $KALIBSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} KALIBSTATE: FILE -> $F_KALIBSTATE DB -> $KALIBSTATE значения не совпали]" >> $LOG
    fi

   # sleep 0.05
   # if echo "$F_LKG" | grep -wq "$LKG"; then
   #     echo "LKG"
   #     echo -e "${GREEN}F: $F_LKG${NC}"
   #     echo -e "${GREEN}B: $LKG${NC}"
   #     # запись в log
   #     TIME_STR=$(date +"%H:%M:%S")
   #     echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} LKG: FILE -> $F_LKG DB -> $LKG значения совпали]" >> $LOG
   # else
   #     echo "LKG"
   #     echo -e "${RED}F: $F_LKG${NC}"
   #     echo -e "${RED}B: $LKG${NC}"
   #     # запись в log
   #     TIME_STR=$(date +"%H:%M:%S")
   #     echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} LKG: FILE -> $F_LKG DB -> $LKG значения не совпали]" >> $LOG
   # fi

    sleep 0.05
    if echo "$F_MANUFACTURERSTATE" | grep -wq "$MANUFACTURERSTATE"; then
        echo "MANUFACTURERSTATE"
        echo -e "${GREEN}F: $F_MANUFACTURERSTATE${NC}"
        echo -e "${GREEN}B: $MANUFACTURERSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} MANUFACTURERSTATE: FILE -> $F_MANUFACTURERSTATE DB -> $MANUFACTURERSTATE значения совпали]" >> $LOG
    else
        echo "MANUFACTURERSTATE"
        echo -e "${RED}F: $F_MANUFACTURERSTATE${NC}"
        echo -e "${RED}B: $MANUFACTURERSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} MANUFACTURERSTATE: FILE -> $F_MANUFACTURERSTATE DB -> $MANUFACTURERSTATE значения не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_SOURCECODE" | grep -wq "$SOURCECODE"; then
        echo "SOURCECODE"
        echo -e "${GREEN}F: $F_SOURCECODE${NC}"
        echo -e "${GREEN}B: $SOURCECODE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} SOURCECODE: FILE -> $F_SOURCECODE DB -> $SOURCECODE значения совпали]" >> $LOG
    else
        echo "SOURCECODE"
        echo -e "${RED}F: $F_SOURCECODE${NC}"
        echo -e "${RED}B: $SOURCECODE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} SOURCECODE: FILE -> $F_SOURCECODE DB -> $SOURCECODE значения не совпали]" >> $LOG
    fi

    sleep 0.05
    if echo "$F_SUPPLIERSTATE" | grep -wq "$SUPPLIERSTATE"; then
        echo "SUPPLIERSTATE"
        echo -e "${GREEN}F: $F_SUPPLIERSTATE${NC}"
        echo -e "${GREEN}B: $SUPPLIERSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Запись: ${arr[0]} SUPPLIERSTATE: FILE -> $F_SUPPLIERSTATE DB -> $SUPPLIERSTATE значения совпали]" >> $LOG
    else
        echo "SUPPLIERSTATE"
        echo -e "${RED}F: $F_SUPPLIERSTATE${NC}"
        echo -e "${RED}B: $SUPPLIERSTATE${NC}"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Запись: ${arr[0]} SUPPLIERSTATE: FILE -> $F_SUPPLIERSTATE DB -> $SUPPLIERSTATE значения не совпали]" >> $LOG
    fi

    echo "---------------------------"
done
