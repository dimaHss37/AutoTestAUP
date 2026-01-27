#!/bin/bash

ACTIVE_DIR=$(dirname "$0")

mkdir $ACTIVE_DIR/Log 2>/dev/null
# назватие модуля
MODULE_NAME="ChecARCHIVE3"
# получаем текущую дату
DATE_STR=$(date +"%d_%m_%Y")
# формируем имя и путь лог файла
F_LOG="/Log/ChecARCHIVE3_$DATE_STR.log"
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

#VER_PROTOCOL !
VER_PROTOCOL=$(cat $TARGET | grep protocol -i | grep -o '[0-9]\+')
if [[ -z "$VER_PROTOCOL" ]]; then
    VER_PROTOCOL=0
fi
#if [[ "$VER_PROTOCOL" != 0 ]]; then
#    echo "Версия протокола: $VER_PROTOCOL"
#    exit 0
#fi


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

ARCHIVE3=$(cat $TARGET | awk '/\[ARCHIVE3\]/{f=2} f && /#/ {f=0; print; next} f' | sed '1d;$d' | sed '/ARCHIVE/d' | sed '/#/d')


if [[ -z "$ARCHIVE3" ]]; then
    echo "В файле: $NAME_FILE нет часового архива"
    echo ""
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][В файле: $NAME_FILE нет часового архива]" >> $LOG
    exit 0
fi

arcnums=$(echo "$ARCHIVE3" | wc -l)

# запись в log
DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Количество записей: $arcnums]" >> $LOG

for ((i=1; i<=$arcnums; i++)); do
    ind="NR==$i"
    line=$(echo "$ARCHIVE3" | awk $ind)
    values=$(echo "$line" | grep -o ";" | wc -l)
    values=$((values + 1))

    IFS=';' read -r -a arr <<< "$line"


        ACTUAL_COUNTERS=$(tac $TARGET | grep -m 1 "ACTUAL COUNTERS" -a1 | head -n 1)
        IFS=';' read -r -a ac <<< "$ACTUAL_COUNTERS" # Преобразует строку в массив 'ac'

        VOLUME_PULSE=$(echo "scale=4; 1 / ${ac[1]}" | bc)
        VOLUME_PULSE=0$VOLUME_PULSE
       # if [[ $(echo "$DB_VOLUME_PULSE == 0.001 && $VOLUME_PULSE == 0.0010" | bc) -eq 1 ]]; then
       #     DB_VOLUME_PULSE=0.0010
       # fi


        export PGPASSWORD=$Password
        devdate=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT devdate FROM archives.intarc
        where flow_id = $flow_id and arcnum = ${arr[0]};")
        unset PGPASSWORD
        devdate=$(date -d "$devdate" +"%d.%m.%Y %H:%M:%S")

        export PGPASSWORD=$Password
        arcdata=$(psql -U $Login -h $Host -d $Name -p $Port -tA -c "SELECT arcdata FROM archives.intarc
        where flow_id = $flow_id and arcnum = ${arr[0]};")
        unset PGPASSWORD

        VSTOT=$(echo "$arcdata" | jq -r '.VSTOT')
        T=$(echo "$arcdata" | jq -r '.T')
        if [[ $T =~ ^[0-9]+\.[0-9]$ ]]; then
                T=$(echo "${T}0")
        fi
        T_OUT=$(echo "$arcdata" | jq -r '.T_OUT')
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
        F_TMRSTATE=$(printf "%d" 0x"${arr[6]}" 2>/dev/null)
        F_WARNINGSTATE=$(printf "%d" 0x"${arr[7]}" 2>/dev/null)
        F_CRASHSTATE=$(printf "%d" 0x"${arr[9]}" 2>/dev/null)
        F_EVENTCODE=$(printf "%d" 0x"${arr[10]}" 2>/dev/null)
        F_VSUND=$(echo "scale=4; ${arr[12]} * $VOLUME_PULSE" | bc)
            if [[ "$F_VSUND" == *0 ]]; then
                F_VSUND=$(echo "$F_VSUND" | sed 's/0*$//')
            fi
            if [[ "$F_VSUND" == .* ]]; then
                F_VSUND="0$F_VSUND"
            fi
            if [ -z "$F_VSUND" ]; then
                F_VSUND=0
            fi
        F_SENSORSTATE=$(printf "%d" 0x"${arr[13]}" 2>/dev/null)
        F_VALVESTATE=${arr[15]}
        F_BATTERY_PERCENT=${arr[16]}
        F_BATTERY_PERCENT_INPUT=${arr[17]}

    #    [0] 	arcnum
    #    [1] 	devdate
    #    [2]	VSTOT
    #    [3] 	T
    #    [4] 	T_OUT
    #    [5] 	K
    #    [6]	TMRSTATE
    #    [7]	WARNINGSTATE
    #    [8]
    #    [9] 	CRASHSTATE
    #    [10]	EVENTCODE
    #    [11]
    #    [12]	VSUND
    #    [13]	SENSORSTATE
    #    [14]
    #    [15]	VALVESTATE
    #    [16]	BATTERY_PERCENT
    #    [17]	BATTERY_PERCENT_INPUT

    #          	ALARMSTATE
    #          	RPUSTATE
    #          	SENSORSTATE_PR
    #          	VALVESTATE_PR
    #          	VSUND




        echo "arcnum: ${arr[0]}"
        echo ""

        sleep 0.03
        if echo "$F_devdate" | grep -wq "$devdate"; then
            echo "DEVDATE"
            echo -e "${GREEN}F: $F_devdate${NC}"
            echo -e "${GREEN}B: $devdate${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} DEVDATE: FILE ==> $F_devdate DB ==> $devdate параметры совпали]" >> $LOG
        else
            echo "DEVDATE"
            echo -e "${RED}F: $F_devdate${NC}"
            echo -e "${RED}B: $devdate${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} DEVDATE: FILE ==> $F_devdate DB ==> $devdate параметры не совпали]" >> $LOG
        fi

        sleep 0.03
        if echo "$F_VSTOT" | grep -wq "$VSTOT"; then
            echo "VSTOT"
            echo -e "${GREEN}F: $F_VSTOT${NC}"
            echo -e "${GREEN}B: $VSTOT${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} VSTOT: FILE ==> $F_VSTOT DB ==> $VSTOT параметры совпали]" >> $LOG
        else
            echo "VSTOT"
            echo -e "${RED}F: $F_VSTOT${NC}"
            echo -e "${RED}B: $VSTOT${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} VSTOT: FILE ==> $F_VSTOT DB ==> $VSTOT параметры не совпали]" >> $LOG
        fi

         sleep 0.03
         if echo "$F_T" | grep -wq "$T"; then
             echo "T"
             echo -e "${GREEN}F: $F_T${NC}"
             echo -e "${GREEN}B: $T${NC}"
             # запись в log
             DATE_STR=$(date +"%d.%m.%Y")
             TIME_STR=$(date +"%H:%M:%S")
             echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} T: FILE ==> $F_T DB ==> $T параметры совпали]" >> $LOG
         else
             echo "T"
             echo -e "${RED}F: $F_T${NC}"
             echo -e "${RED}B: $T${NC}"
             # запись в log
             DATE_STR=$(date +"%d.%m.%Y")
             TIME_STR=$(date +"%H:%M:%S")
             echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} T: FILE ==> $F_T DB ==> $T параметры не совпали]" >> $LOG
         fi

         sleep 0.03
         if echo "$F_K" | grep -wq "$K"; then
             echo "K"
             echo -e "${GREEN}F: $F_K${NC}"
             echo -e "${GREEN}B: $K${NC}"
             # запись в log
             DATE_STR=$(date +"%d.%m.%Y")
             TIME_STR=$(date +"%H:%M:%S")
             echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} K: FILE ==> $F_K DB ==> $K параметры совпали]" >> $LOG
         else
             echo "TMRSTATE"
             echo -e "${RED}F: $F_K${NC}"
             echo -e "${RED}B: $K${NC}"
             # запись в log
             DATE_STR=$(date +"%d.%m.%Y")
             TIME_STR=$(date +"%H:%M:%S")
             echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} K: FILE ==> $F_K DB ==> $K параметры не совпали]" >> $LOG
         fi

        sleep 0.03
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

        sleep 0.03
        if echo "$F_WARNINGSTATE" | grep -wq "$WARNINGSTATE"; then
            echo "WARNINGSTATE"
            echo -e "${GREEN}F: $F_WARNINGSTATE${NC}"
            echo -e "${GREEN}B: $WARNINGSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} WARNINGSTATE: FILE ==> $F_WARNINGSTATE DB ==> $WARNINGSTATE параметры совпали]" >> $LOG
        else
            echo "WARNINGSTATE"
            echo -e "${RED}F: $F_WARNINGSTATE${NC}"
            echo -e "${RED}B: $WARNINGSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} WARNINGSTATE: FILE ==> $F_WARNINGSTATE DB ==> $WARNINGSTATE параметры не совпали]" >> $LOG
        fi

        sleep 0.03
        if echo "$F_CRASHSTATE" | grep -wq "$CRASHSTATE"; then
            echo "CRASHSTATE"
            echo -e "${GREEN}F: $F_CRASHSTATE${NC}"
            echo -e "${GREEN}B: $CRASHSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} CRASHSTATE: FILE ==> $F_CRASHSTATE DB ==> $CRASHSTATE параметры совпали]" >> $LOG
        else
            echo "CRASHSTATE"
            echo -e "${RED}F: $F_CRASHSTATE${NC}"
            echo -e "${RED}B: $CRASHSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} CRASHSTATE: FILE ==> $F_CRASHSTATE DB ==> $CRASHSTATE параметры не совпали]" >> $LOG
        fi

        sleep 0.03
        if [[ "$F_EVENTCODE" == "$EVENTCODE" ]]; then
            echo "EVENTCODE"
            echo -e "${GREEN}F: $F_EVENTCODE${NC}"
            echo -e "${GREEN}B: $EVENTCODE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} EVENTCODE: FILE ==> $F_EVENTCODE DB ==> $EVENTCODE параметры совпали]" >> $LOG
        else
            echo "EVENTCODE"
            echo -e "${RED}F: $F_EVENTCODE${NC}"
            echo -e "${RED}B: $EVENTCODE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} EVENTCODE: FILE ==> $F_EVENTCODE DB ==> $EVENTCODE параметры не совпали]" >> $LOG
        fi

        sleep 0.03
        if [[ "$F_VSUND" == "$VSUND" ]]; then
            echo "VSUND"
            echo -e "${GREEN}F: $F_VSUND${NC}"
            echo -e "${GREEN}B: $VSUND${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} VSUND: FILE ==> $F_VSUND DB ==> $VSUND параметры совпали]" >> $LOG
        else
            echo "VSUND"
            echo -e "${RED}F: $F_VSUND${NC}"
            echo -e "${RED}B: $VSUND${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} VSUND: FILE ==> $F_VSUND DB ==> $VSUND параметры не совпали]" >> $LOG
        fi

        sleep 0.03
        if [[ "$F_SENSORSTATE" == "$SENSORSTATE" ]]; then
            echo "SENSORSTATE"
            echo -e "${GREEN}F: $F_SENSORSTATE${NC}"
            echo -e "${GREEN}B: $SENSORSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} SENSORSTATE: FILE ==> $F_SENSORSTATE DB ==> $SENSORSTATE параметры совпали]" >> $LOG
        else
            echo "SENSORSTATE"
            echo -e "${RED}F: $F_SENSORSTATE${NC}"
            echo -e "${RED}B: $SENSORSTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} SENSORSTATE: FILE ==> $F_SENSORSTATE DB ==> $SENSORSTATE параметры не совпали]" >> $LOG
        fi

        sleep 0.03
        if echo "$F_VALVESTATE" | grep -wq "$VALVESTATE"; then
            echo "VALVESTATE"
            echo -e "${GREEN}F: $F_VALVESTATE${NC}"
            echo -e "${GREEN}B: $VALVESTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} VALVESTATE: FILE ==> $F_VALVESTATE DB ==> $VALVESTATE параметры совпали]" >> $LOG
        else
            echo "VALVESTATE"
            echo -e "${RED}F: $F_VALVESTATE${NC}"
            echo -e "${RED}B: $VALVESTATE${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} VALVESTATE: FILE ==> $F_VALVESTATE DB ==> $VALVESTATE параметры не совпали]" >> $LOG
        fi

        sleep 0.03
        if echo "$F_BATTERY_PERCENT" | grep -wq "$BATTERY_PERCENT"; then
            echo "BATTERY_PERCENT"
            echo -e "${GREEN}F: $F_BATTERY_PERCENT${NC}"
            echo -e "${GREEN}B: $BATTERY_PERCENT${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} BATTERY_PERCENT: FILE ==> $F_BATTERY_PERCENT DB ==> $BATTERY_PERCENT параметры совпали]" >> $LOG
        else
            echo "BATTERY_PERCENT"
            echo -e "${RED}F: $F_BATTERY_PERCENT${NC}"
            echo -e "${RED}B: $BATTERY_PERCENT${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} BATTERY_PERCENT: FILE ==> $F_BATTERY_PERCENT DB ==> $BATTERY_PERCENT параметры не совпали]" >> $LOG
        fi

        sleep 0.03
        if echo "$F_BATTERY_PERCENT_INPUT" | grep -wq "$BATTERY_PERCENT_INPUT"; then
            echo "BATTERY_PERCENT_INPUT"
            echo -e "${GREEN}F: $F_BATTERY_PERCENT_INPUT${NC}"
            echo -e "${GREEN}B: $BATTERY_PERCENT_INPUT${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Passed][Запись: ${arr[0]} BATTERY_PERCENT_INPUT: FILE ==> $F_BATTERY_PERCENT_INPUT DB ==> $BATTERY_PERCENT_INPUT параметры совпали]" >> $LOG
        else
            echo "BATTERY_PERCENT_INPUT"
            echo -e "${RED}F: $F_BATTERY_PERCENT_INPUT${NC}"
            echo -e "${RED}B: $BATTERY_PERCENT_INPUT${NC}"
            # запись в log
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Failed][Запись: ${arr[0]} BATTERY_PERCENT_INPUT: FILE ==> $F_BATTERY_PERCENT_INPUT DB ==> $BATTERY_PERCENT_INPUT параметры не совпали]" >> $LOG
        fi

        echo "---------------------------"



done
