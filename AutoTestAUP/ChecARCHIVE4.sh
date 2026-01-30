#!/bin/bash

ACTIVE_DIR=$(dirname "$0")

mkdir $ACTIVE_DIR/Log 2>/dev/null
# назватие модуля
MODULE_NAME="ChecARCHIVE4"
# получаем текущую дату
DATE_STR=$(date +"%d_%m_%Y")
# формируем имя и путь лог файла
F_LOG="/Log/ChecARCHIVE4_$DATE_STR.log"
LOG="$ACTIVE_DIR$F_LOG"


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

# МЕНЮ ВЫБОРА ФАЙЛА
# принудительное удаление временных файлов
rm $ACTIVE_DIR/.files_list.tmp 2>/dev/null
rm $ACTIVE_DIR/.list1.tmp 2>/dev/null
rm $ACTIVE_DIR/.list2.tmp 2>/dev/null
# принудительное создание папки rdt
mkdir $ACTIVE_DIR/rdt 2>/dev/null
# удаление файлов с расширениен не "rdt" в папке rdt
find $ACTIVE_DIR/rdt -type f ! -iname "*.rdt" -delete
# подщёт количества файлов в папке
files=$(find $ACTIVE_DIR/rdt -type f | wc -l )
if [[ $files == 0 ]]; then
    echo ""
    echo "Файлов rdt в папке $ACTIVE_DIR/rdt не найдено."
    exit 0
fi
ls $ACTIVE_DIR/rdt | column -t > $ACTIVE_DIR/.files_list.tmp

for ((i=1; i<=$files; i++)); do
    ind="NR==$i"
    name=$(ls $ACTIVE_DIR/rdt | column -t | awk $ind)
    vers=$(cat $ACTIVE_DIR/rdt/$name | grep vers -i | grep -oE '[0-9]*\.?[0-9]+')
    prot=$(cat $ACTIVE_DIR/rdt/$name | grep "VER_PROTOCOL=")
    if [ -z $prot ]; then
    prot="VER_PROTOCOL=0"
    fi
    Application=$(cat $ACTIVE_DIR/rdt/$name | head -n 1)
    if echo "$Application" | grep -wq "Application"; then
        vers=$(cat $ACTIVE_DIR/rdt/$name | grep "ApplVersion" | grep -oE '[0-9]*\.[0-9]*\.[0-9]*')
        prot="Не_поддерживается"
    fi
    echo -e "$name $vers $prot" >> $ACTIVE_DIR/.list1.tmp
done
cat $ACTIVE_DIR/.list1.tmp | column -t >> $ACTIVE_DIR/.list2.tmp
list=$(cat $ACTIVE_DIR/.list2.tmp | nl -s ' ==> ')
clear
echo ""
for ((i=1; i<=$files; i++)); do
    ind="NR==$i"
    echo "$list" | awk $ind
    sleep 0.015
done

 echo ""
 read -p "Укажите номер файла для обработки: " NUM_FILE
 NUM_FILE="NR==$NUM_FILE"
 NAME_FILE=$(cat $ACTIVE_DIR/.files_list.tmp | awk $NUM_FILE)
 rm $ACTIVE_DIR/.files_list.tmp 2>/dev/null
 rm $ACTIVE_DIR/.list1.tmp 2>/dev/null
 rm $ACTIVE_DIR/.list2.tmp 2>/dev/null
 clear
# КОНЕЦ МЕНЮ ВЫБОРА ФАЙЛА

devnum=$(echo "$NAME_FILE" | sed 's/.*_//' | cut -d'.' -f1)

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
if [[ "$VER_PROTOCOL" != 0 ]]; then
    echo "Версия протокола: $VER_PROTOCOL"
    exit 0
fi


# запись в log
DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "" >> $LOG
echo "" >> $LOG
echo "------------------------------------------------------------------------" >> $LOG
echo "" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Тестируем файл: $NAME_FILE]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][id прибора: $device_id]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][База данных: $Name]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Имя пользователя: $Login]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Пароль: $Password]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Хост: $Host]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Порт: $Port]" >> $LOG
echo "" >> $LOG
echo -e "Успешный тест: [Passed] \tТест провален: [Failed]" >> $LOG
echo "" >> $LOG

ARCHIVE4=$(cat $TARGET | awk '/\[ARCHIVE4\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d')

arcnums=$(echo "$ARCHIVE4" | wc -l)

# запись в log
DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Количество записей: $arcnums]" >> $LOG

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
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} DEV_DATE_END: FILE ==> $F_DEV_DATE_END DB ==> $DEV_DATE_END параметры совпали]" >> $LOG
        else
            echo "DEV_DATE_END"
            echo -e "${RED}F: $F_DEV_DATE_END${NC}"
            echo -e "${RED}B: $DEV_DATE_END${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} DEV_DATE_END: FILE ==> $F_DEV_DATE_END DB ==> $DEV_DATE_END параметры не совпали]" >> $LOG
        fi

        sleep 0.05
        if echo "$F_SEANCE_NUM" | grep -wq "$SEANCE_NUM"; then
            echo "SEANCE_NUM"
            echo -e "${GREEN}F: $F_SEANCE_NUM${NC}"
            echo -e "${GREEN}B: $SEANCE_NUM${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} SEANCE_NUM ==> FILE: $F_SEANCE_NUM DB ==> $SEANCE_NUM параметры совпали]" >> $LOG
        else
            echo "SEANCE_NUM"
            echo -e "${RED}F: $F_SEANCE_NUM${NC}"
            echo -e "${RED}B: $SEANCE_NUM${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} SEANCE_NUM ==> FILE: $F_SEANCE_NUM DB ==> $SEANCE_NUM параметры не совпали]" >> $LOG
        fi

        sleep 0.05
        if echo "$F_STATUS" | grep -wq "$STATUS"; then
            echo "STATUS"
            echo -e "${GREEN}F: $F_STATUS${NC}"
            echo -e "${GREEN}B: $STATUS${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} STATUS: FILE ==> $F_STATUS DB ==> $STATUS параметры совпали]" >> $LOG
        else
            echo "STATUS"
            echo -e "${RED}F: $F_STATUS${NC}"
            echo -e "${RED}B: $STATUS${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} STATUS: FILE ==> $F_STATUS DB ==> $STATUS параметры не совпали]" >> $LOG
        fi

        sleep 0.05
        if echo "$F_TMRSTATE" | grep -wq "$TMRSTATE"; then
            echo "TMRSTATE"
            echo -e "${GREEN}F: $F_TMRSTATE${NC}"
            echo -e "${GREEN}B: $TMRSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} TMRSTATE: FILE ==> $F_TMRSTATE DB ==> $TMRSTATE параметры совпали]" >> $LOG
        else
            echo "TMRSTATE"
            echo -e "${RED}F: $F_TMRSTATE${NC}"
            echo -e "${RED}B: $TMRSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} TMRSTATE: FILE ==> $F_TMRSTATE DB ==> $TMRSTATE параметры не совпали]" >> $LOG
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
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} DATE_START: FILE ==> $F_DATE_START DB ==> $DATE_START параметры совпали]" >> $LOG
        else
            echo "DATE_START"
            echo -e "${RED}F: $F_DATE_START${NC}"
            echo -e "${RED}B: $DATE_START${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} DATE_START: FILE ==> $F_DATE_START DB ==> $DATE_START параметры не совпали]" >> $LOG
        fi

        sleep 0.05
        if echo "$F_DATE_END" | grep -wq "$DATE_END"; then
            echo "DATE_END"
            echo -e "${GREEN}F: $F_DATE_END${NC}"
            echo -e "${GREEN}B: $DATE_END${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} DATE_END: FILE ==> $F_DATE_END DB ==> $DATE_END параметры совпали]" >> $LOG
        else
            echo "DATE_END"
            echo -e "${RED}F: $F_DATE_END${NC}"
            echo -e "${RED}B: $DATE_END${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} DATE_END: FILE ==> $F_DATE_END DB ==> $DATE_END параметры не совпали]" >> $LOG
        fi

        sleep 0.05
        if echo "$F_SEANCE_NUM" | grep -wq "$SEANCE_NUM"; then
            echo "SEANCE_NUM"
            echo -e "${GREEN}F: $F_SEANCE_NUM${NC}"
            echo -e "${GREEN}B: $SEANCE_NUM${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} SEANCE_NUM: FILE ==> $F_SEANCE_NUM DB ==> $SEANCE_NUM параметры совпали]" >> $LOG
        else
            echo "SEANCE_NUM"
            echo -e "${RED}F: $F_SEANCE_NUM${NC}"
            echo -e "${RED}B: $SEANCE_NUM${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} SEANCE_NUM: FILE ==> $F_SEANCE_NUM DB ==> $SEANCE_NUM параметры не совпали]" >> $LOG
        fi

        sleep 0.05
        if [[ "$F_ERROR_CODE" == "$ERROR_CODE" ]]; then
            echo "ERROR_CODE"
            echo -e "${GREEN}F: $F_ERROR_CODE${NC}"
            echo -e "${GREEN}B: $ERROR_CODE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} ERROR_CODE: FILE ==> $F_ERROR_CODE DB ==> $ERROR_CODE параметры совпали]" >> $LOG
        else
            echo "ERROR_CODE"
            echo -e "${RED}F: $F_ERROR_CODE${NC}"
            echo -e "${RED}B: $ERROR_CODE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} ERROR_CODE: FILE ==> $F_ERROR_CODE DB ==> $ERROR_CODE параметры не совпали]" >> $LOG
        fi

        sleep 0.05
        if [[ "$F_TMRSTATE" == "$TMRSTATE" ]]; then
            echo "TMRSTATE"
            echo -e "${GREEN}F: $F_TMRSTATE${NC}"
            echo -e "${GREEN}B: $TMRSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} TMRSTATE: FILE ==> $F_TMRSTATE DB ==> $TMRSTATE параметры совпали]" >> $LOG
        else
            echo "TMRSTATE"
            echo -e "${RED}F: $F_TMRSTATE${NC}"
            echo -e "${RED}B: $TMRSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} TMRSTATE: FILE ==> $F_TMRSTATE DB ==> $TMRSTATE параметры не совпали]" >> $LOG
        fi

        echo "---------------------------"

    fi

done

# Отчёт о тесте
Passed=$(tac $LOG | sed -n '1,/'$NAME_FILE'/p' | grep "Passed" | wc -l)
((Passed--))
Failed=$(tac $LOG | sed -n '1,/'$NAME_FILE'/p' | grep "Failed" | wc -l)
((Failed--))
echo ""
echo -e "\t\e[1mУспешных тестов: $Passed \tПроваленых тестов: $Failed\e[0m"
echo "" >> $LOG
echo -e "Успешных тестов: $Passed \tПроваленых тестов: $Failed" >> $LOG


if [[ "$Failed" > 0 ]]; then
    echo ""
    echo ""
    echo -e "\t----------------------------"
    echo -e "\t\e[1m1. Вывести ошибки из лога\e[0m"
    echo -e "\t\e[1m2. Вывести весь лог\e[0m"
    echo -e "\t\e[1m3. Главное меню\e[0m"
    echo -e "\t\e[1m4. Выход\e[0m"
    echo ""
    read -p "Введите номер опции (1-4): " choice

    case $choice in
        1)
        echo ""
        tac $LOG | sed -n '1,/'$NAME_FILE'/p' | grep "Failed" | tac | sed '/Passed/d'
        ;;
        2)
        echo ""
        tac $LOG | sed -n '1,/'$NAME_FILE'/p' | tac
        ;;
        3)
        $ACTIVE_DIR/Menu_v0.1.sh
        ;;
        4)
        echo ""
        echo ""
        echo "Завершение работы."
        exit 0
        ;;
        *)
        echo ""
        echo ""
        echo "Ошибка: Неправильный ввод."
        ;;
    esac
fi

if [[ "$Failed" == 0 ]]; then
    echo ""
    echo ""
    echo -e "\t----------------------------"
    echo -e "\t\e[1m1. Вывести весь лог\e[0m"
    echo -e "\t\e[1m2. Главное меню\e[0m"
    echo -e "\t\e[1m3. Выход\e[0m"
    echo ""
    read -p "Введите номер опции (1-3): " choice

    case $choice in
        1)
        echo ""
        tac $LOG | sed -n '1,/'$NAME_FILE'/p' | tac
        ;;
        2)
        $ACTIVE_DIR/Menu_v0.1.sh
        ;;
        3)
        echo ""
        echo ""
        echo "Завершение работы."
        exit 0
        ;;
        *)
        echo ""
        echo ""
        echo "Ошибка: Неправильный ввод."
        ;;
    esac
fi
