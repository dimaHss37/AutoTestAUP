#!/bin/bash

# ищем "sgs.json"
FILE_SGS_JSON=$(find /opt -type f -name "sgs.json" 2>/dev/null)
if [ -z "$FILE_SGS_JSON" ]; then
     echo "Файл sgs.json не найден!"
     # Запускаем подменю программы
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

# Ищем папку "In", куда будем копировать файл
IN_DIR=$(find /opt -type d -name "In" 2>/dev/null | grep Arc/In)

ACTIVE_DIR=$(dirname "$0")
LIST=$(ls $ACTIVE_DIR/rdt | column -t)
ls $ACTIVE_DIR/rdt | column -t > $ACTIVE_DIR/.list.tmp

if [ -z "$LIST" ]; then
     echo "Нет файлов для тестов"
     # Запускаем подменю программы
     exit 0
else
    clear
    echo ""
    ls $ACTIVE_DIR/rdt | column -t | nl
    echo ""
    read -p "Выберите файл для обработки: " NUM_FILE
    NUM_FILE="NR==$NUM_FILE"
    NAME_FILE=$(cat $ACTIVE_DIR/.list.tmp | awk $NUM_FILE)
    rm $ACTIVE_DIR/.list.tmp 2>/dev/null
    clear
fi

# Путь к обрабатываемому файлу
TARGET="$ACTIVE_DIR/rdt/$NAME_FILE"
# Коды цветов
RED="\033[31m" # Красный
GREEN="\033[32m" # Зеленый
NC="\033[0m" # Без цвета (сброс)

Readout_TYPE=$(cat $TARGET | grep "Readout\|Application")
if [ -n "$Readout_TYPE" ]; then
    echo -e "${RED}Файлы из readout не обрабатываются, нет реализации на текущий момент.${NC}"
    echo ""
    # Запускаем подменю программы
    exit 0
fi

devnum=$(echo "$NAME_FILE" | sed 's/.*_//' | cut -d'.' -f1)
devtype_id=$(psql -U $Login -d $Name -p $Port -tA -c "SELECT devtype_id FROM devices_custs.device
where devnum='$devnum';")
id=$(psql -U $Login -d $Name -tA -c "select id from devices_custs.device
where devnum='$devnum';")
if [ -z "$id" ]; then
    echo -e "${RED}Данного прибора ($devnum) нет в базе данных.${NC}"
    echo ""
    # Запускаем подменю программы
    exit 0
fi
SIM_ACTIV=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
join dicts.attributes_dict on dicts.attributes_dict.id = info_params.device_info_params.attribute_id
where device_id=$id and attribute_name='SIM_ACTIV';")

mkdir $ACTIVE_DIR/Log 2>/dev/null
# назватие модуля
MODULE_NAME="ChecParamsRecordAC"
# получаем текущую дату
DATE_STR=$(date +"%d_%m_%Y")
# формируем имя и путь лог файла
F_LOG="/Log/$MODULE_NAME$_DATE_STR.log"
LOG="$ACTIVE_DIR$F_LOG"





#[DEVICE DATA]
# TYPE
TYPE=$(cat $TARGET | grep type -i | grep -o '[0-9]\+')

SMT_numbs="99 96 9 82 81 80 8 79 78 77 76 75 74 73 72 71 7 68 67 66 65 64 6 53 52 51 50 5
49 4 38 37 36 35 34 3100 3099 3096 3066 3065 3064 3051 3050 3049 3010 3009 3008 3005 3004
3003 3 28 27 26 25 24 23 22 2100 21 2099 2096 2066 2065 2064 2051 2050 2049 2010 2009 2008
2005 2004 2003 20 19 18 12 1100 11 1099 1096 1066 1065 1064 1051 1050 1049 1010 1009 1008
1005 1004 1003 100 10 98 97 95 94 93 92 91 90 89 88 87 86 85 84 83 70 69 63 62 61 60 59 58
57 56 55 54 48 47 46 45 44 43 42 41 40 39 33 32 31 3098 3097 3095 3084 3083 3070 3069 3033
3032 3031 3030 3029 3017 3016 3015 3014 3013 30 29 2098 2097 2095 2084 2083 2070 2069 2033
2032 2031 2030 2029 2017 2016 2015 2014 2013 17 16 15 14 13 1098 1097 1095 1084 1083 1070
1069 1033 1032 1031 1030 1029 1017 1016 1015 1014 1013"

#if echo "$SMT_numbs" | grep -wq "$TYPE"; then
if ! grep -q "$TYPE" <<< "$SMT_numbs"; then
    echo -e "${RED}Данный тип прибора не поддерживается.${NC}"
    echo ""
    # Запускаем подменю программы
    exit 0
fi

echo ""
echo -e "Обрабатываем файл: ${GREEN}$NAME_FILE${NC}"
echo -e "Тип прибора: ${GREEN}SMT${NC}"
echo -e "id прибора: ${GREEN}$id${NC}"
#VER_PROTOCOL
VER_PROTOCOL=$(cat $TARGET | grep protocol -i | grep -o '[0-9]\+')
if [[ -z "$VER_PROTOCOL" ]]; then
    VER_PROTOCOL=0
fi
echo -e "Версия протокола: ${GREEN}$VER_PROTOCOL${NC}"

echo ""
sleep 0.3
echo -e "\e[1m[DEVICE DATA]\e[0m"
echo "---------------------------"
# запись в log
DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Обрабатываем файл: $NAME_FILE]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Тип прибора: SMT]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][id прибора: $id]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME]Версия протокола: $VER_PROTOCOL]" >> $LOG
echo "[DEVICE DATA]" >> $LOG

# Получения значения из БД
DB_TYPE=$(psql -U $Login -d $Name -tA -c "SELECT devcode FROM dicts.devtypedict
where id=$devtype_id;")
sleep 0.1
STR1="TYPE: $TYPE"
STR2="TYPE: $DB_TYPE"

if [ "$STR1" != "$STR2" ]; then
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][TYPE: FILE-$TYPE DB-$DB_TYPE параметры не совпали]" >> $LOG
else
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][TYPE: FILE-$TYPE DB-$DB_TYPE параметры совпали]" >> $LOG
fi
# SN
SN=$(cat $TARGET | grep sn -i | grep -o '[0-9]\+')
# Получения значения из БД
#export PGPASSWORD='masterGazSetLogin'
DB_SN=$(psql -U $Login -d $Name -tA -c "select devnum from devices_custs.device
where id=$id;")
#unset PGPASSWORD

STR1="SN: $SN"
STR2="SN: $DB_SN"
sleep 0.1
if echo "$SN" | grep -wq "$DB_SN"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][SN: FILE-$SN DB-$DB_SN параметры совпали]" >> $LOG
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][SN: FILE-$SN DB-$DB_SN параметры не совпали]" >> $LOG
fi
# VERS
VERS=$(cat $TARGET | grep vers -i | grep -oE '[0-9]*\.?[0-9]+')
# Комплекс или смарт?
if [[ "$VERS" == 1.0* ]]; then
#if (( $(echo "$VERS >= 1.0" | bc -l) )); then
    VERS_K=$VERS
    VERS_S=""
else
    VERS_S=$VERS
    VERS_K=""
fi

    # Получения значения из БД
#export PGPASSWORD='masterGazSetLogin'
DB_VERS=$(psql -U $Login -d $Name -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=29;")
#unset PGPASSWORD
STR1="VERS: $VERS"
STR2="VERS: $DB_VERS"
sleep 0.2
if echo "$VERS" | grep -wq "$DB_VERS"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][VERS: FILE-$VERS DB-$DB_VERS параметры совпали]" >> $LOG
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][VERS: FILE-$VERS DB-$DB_VERS параметры не совпали]" >> $LOG
fi
#SIMIP
SIMIP=$(cat $TARGET | grep simip -i | awk -F'=' '{print $2}')
# Получения значения из БД
#export PGPASSWORD='masterGazSetLogin'
DB_SIMIP=$(psql -U $Login -d $Name -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=48;")
#unset PGPASSWORD
STR1="SIMIP: $SIMIP"
STR2="SIMIP: $DB_SIMIP"
#SIMIP_LOG=$(cat $TARGET | grep simip -i | awk -F'=' '{print $2}' | sed -i '$s/\n//')
sleep 0.1
if echo "$SIMIP" | grep -wq "$DB_SIMIP"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][SIMIP: FILE-$SIMIP_LOG DB-$DB_SIMIP параметры совпали]" >> $LOG
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][SIMIP: FILE-$SIMIP_LOG DB-$DB_SIMIP параметры не совпали]" >> $LOG
fi


sleep 0.3
# [ACTUAL COUNTERS]
# подщёт количества параметров в файле
COUNTERS=$(tac $TARGET | grep -m 1 "ACTUAL COUNTERS" -a1 | head -n 1 | grep -o ";" | wc -l)
COUNTERS=$((COUNTERS + 1))
echo ""
echo -e "\e[1m[ACTUAL COUNTERS]\e[0m"
echo "---------------------------"
echo -e "Количество параметров: ${GREEN}$COUNTERS${NC}"
echo "---------------------------"
# запись в log
echo "[ACTUAL COUNTERS]" >> $LOG
DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Количество параметров: $COUNTERS]" >> $LOG

ACTUAL_COUNTERS=$(tac $TARGET | grep -m 1 "ACTUAL COUNTERS" -a1 | head -n 1)

IFS=';' read -r -a arr <<< "$ACTUAL_COUNTERS" # Преобразует строку в массив 'arr'
i=0
# 1 STATUS_SYSTEM
# Получения значения из БД
DB_STATUS_SYSTEM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=71;")
STR1=$((16#${arr[$i]}))
STATUS_SYSTEM=$STR1
STR1="STATUS_SYSTEM: $STR1"
STR2="STATUS_SYSTEM: $DB_STATUS_SYSTEM"
sleep 0.1
if echo "$STR1" | grep -wq "$STR2"; then
    echo "---------------------------"
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][Параметр №1 STATUS_SYSTEM: FILE-$STATUS_SYSTEM DB-$DB_STATUS_SYSTEM параметры совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo "---------------------------"
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][Параметр №1 STATUS_SYSTEM: FILE-$STATUS_SYSTEM DB-$DB_STATUS_SYSTEM параметры не совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 2 VOLUME_PULSE
# Получения значения из БД
DB_VOLUME_PULSE=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=103;")
STR1=$(echo "scale=4; 1 / ${arr[$i]}" | bc)
VOLUME_PULSE=0$STR1
if [ $(echo "$DB_VOLUME_PULSE == 0.001 && $VOLUME_PULSE == 0.0010" | bc) -eq 1 ]; then
    DB_VOLUME_PULSE=0.0010
fi
STR1="VOLUME_PULSE: $VOLUME_PULSE"
STR2="VOLUME_PULSE: $DB_VOLUME_PULSE"
sleep 0.1
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][Параметр №2 VOLUME_PULSE: FILE-$VOLUME_PULSE DB-$DB_VOLUME_PULSE параметры совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][Параметр №2 VOLUME_PULSE: FILE-$VOLUME_PULSE DB-$DB_VOLUME_PULSE параметры не совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 3 CURRENT_COUNTER
# Получения значения из БД
DB_CURRENT_COUNTER=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=37;")
CURRENT_COUNTER=$(echo "scale=4; ${arr[$i]} * $VOLUME_PULSE" | bc)
# Добавляем "0" если значение меньше единицы
if [[ "$CURRENT_COUNTER" == .* ]]; then
    CURRENT_COUNTER=0$CURRENT_COUNTER
fi
STR1="CURRENT_COUNTER: $CURRENT_COUNTER"
STR2="CURRENT_COUNTER: $DB_CURRENT_COUNTER"
sleep 0.1
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][Параметр №3 CURRENT_COUNTER: FILE-$CURRENT_COUNTER DB-$DB_CURRENT_COUNTER параметры совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][Параметр №3 CURRENT_COUNTER: FILE-$CURRENT_COUNTER DB-$DB_CURRENT_COUNTER параметры не совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 4 DATETIME
# Получения значения из БД
DB_DATETIME=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=33;")
DATETIME=${arr[$i]}
STR1="DATETIME: ${arr[$i]}"
STR1=$(echo "$STR1" | awk -F'.' '{print $1"."$2".20"$3""$4}' | sed 's/,/ /g')
STR2="DATETIME: $DB_DATETIME"
sleep 0.1
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][Параметр №4 DATETIME: FILE-$DATETIME DB-$DB_DATETIME параметры совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][Параметр №4 DATETIME: FILE-$DATETIME DB-$DB_DATETIME параметры не совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 5 APN_ADDRESS
if [ -z "$SIM_ACTIV" ]; then
# Получения значения из БД
    DB_APN_ADDRESS=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=54;")
else
    # Получения значения из БД
    DB_APN_ADDRESS=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
    join dicts.attributes_dict as ad on ad.id=si.attribute_id
    join devices_custs.device_sim as ds on ds.id=si.sim_id
    where ds.device_id=$id and attribute_id=54 and sim_num=$SIM_ACTIV;")
fi
APN_ADDRESS=${arr[$i]}
STR1="APN_ADDRESS: ${arr[$i]}"
STR2="APN_ADDRESS: $DB_APN_ADDRESS"
sleep 0.1
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][Параметр №5 APN_ADDRESS: FILE-$DATETIME DB-$DB_DATETIME параметры совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][Параметр №5 APN_ADDRESS: FILE-$DATETIME DB-$DB_DATETIME параметры не совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 6 APN_LOGIN
if [ -z "$SIM_ACTIV" ]; then
    DB_APN_LOGIN=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=52;")
else
    # Получения значения из БД
    DB_APN_LOGIN=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
    join dicts.attributes_dict as ad on ad.id=si.attribute_id
    join devices_custs.device_sim as ds on ds.id=si.sim_id
    where ds.device_id=$id and attribute_id=52 and sim_num=$SIM_ACTIV;")
fi
APN_LOGIN=${arr[$i]}
STR1="APN_LOGIN: ${arr[$i]}"
STR2="APN_LOGIN: $DB_APN_LOGIN"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][OK][Параметр №6 APN_LOGIN: FILE-$APN_LOGIN DB-$DB_APN_LOGIN параметры совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    # запись в log
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][ERR][Параметр №6 APN_LOGIN: FILE-$APN_LOGIN DB-$DB_APN_LOGIN параметры не совпали]" >> $LOG
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 7 APN_PASSWORD
if [ -z "$SIM_ACTIV" ]; then
    DB_APN_PASSWORD=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=53;")
else
    # Получения значения из БД
    DB_APN_PASSWORD=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
    join dicts.attributes_dict as ad on ad.id=si.attribute_id
    join devices_custs.device_sim as ds on ds.id=si.sim_id
    where ds.device_id=$id and attribute_id=53 and sim_num=$SIM_ACTIV;")
fi
APN_PASSWORD=${arr[$i]}
STR1="APN_PASSWORD: ${arr[$i]}"
STR2="APN_PASSWORD: $DB_APN_PASSWORD"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 8 TCP_ADDRESS  //SERVER_URL
if [ -z "$SIM_ACTIV" ]; then
    DB_TCP_ADDRESS=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=55;")
else
    # Получения значения из БД
    DB_TCP_ADDRESS=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
    join dicts.attributes_dict as ad on ad.id=si.attribute_id
    join devices_custs.device_sim as ds on ds.id=si.sim_id
    where ds.device_id=$id and attribute_id=55 and sim_num=$SIM_ACTIV;")
fi
TCP_ADDRESS=${arr[$i]}
STR1="TCP_ADDRESS: ${arr[$i]}"
STR2="TCP_ADDRESS: $DB_TCP_ADDRESS"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 9 SMS_PHONE    //SMS_PHONE
# Получения значения из БД
#DB_SMS_PHONE=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
#join dicts.attributes_dict as ad on ad.id=si.attribute_id
#join devices_custs.device_sim as ds on ds.id=si.sim_id
#where ds.device_id=$id and attribute_id=55 and sim_num=$SIM_ACTIV;")
SMS_PHONE=${arr[$i]}
STR1="SMS_PHONE: ${arr[$i]}"
STR2="SMS_PHONE: $DB_SMS_PHONE"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 10 BALANCE_PHONE     //BALANCE_PHONE
if [ -z "$SIM_ACTIV" ]; then
    DB_BALANCE_PHONE=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=41;")
else
    # Получения значения из БД
    DB_BALANCE_PHONE=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
    join dicts.attributes_dict as ad on ad.id=si.attribute_id
    join devices_custs.device_sim as ds on ds.id=si.sim_id
    where ds.device_id=$id and attribute_id=41 and sim_num=$SIM_ACTIV;")
fi
BALANCE_PHONE=${arr[$i]}
STR1="BALANCE_PHONE: ${arr[$i]}"
STR2="BALANCE_PHONE: $DB_BALANCE_PHONE"
sleep 0.2
select=$(echo "$STR1" | grep "$DB_BALANCE_PHONE")
if [ -n "$select" ]; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 11 MODE_TRANSFER //MODE_TRANSFER
if [ -z "$SIM_ACTIV" ]; then
    DB_MODE_TRANSFER=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=42;")
else
    # Получения значения из БД
    DB_MODE_TRANSFER=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
    join dicts.attributes_dict as ad on ad.id=si.attribute_id
    join devices_custs.device_sim as ds on ds.id=si.sim_id
    where ds.device_id=$id and attribute_id=42 and sim_num=$SIM_ACTIV;")
fi
MODE_TRANSFER=${arr[$i]}
STR1="MODE_TRANSFER: ${arr[$i]}"
STR2="MODE_TRANSFER: $DB_MODE_TRANSFER"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 12 BATTERY   //BATTERY
# Получения значения из БД
DB_BATTERY=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
join dicts.attributes_dict on dicts.attributes_dict.id = info_params.device_info_params.attribute_id
where device_id=$id and attribute_id=57;")
BATTERY=$(echo "scale=3; ${arr[$i]} / 1000" | bc)
# Добавляем "0" если значение меньше единицы
if [[ "$BATTERY" == .* ]]; then
    BATTERY=0$BATTERY
fi
STR1="BATTERY: $BATTERY"
STR2="BATTERY: $DB_BATTERY"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 13 SENSOR_TEMP   //TEMP_SENSOR
# Получения значения из БД
DB_SENSOR_TEMP=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
join dicts.attributes_dict on dicts.attributes_dict.id = info_params.device_info_params.attribute_id
where device_id=$id and attribute_id=59;")
SENSOR_TEMP=${arr[$i]}
STR1="SENSOR_TEMP: ${arr[$i]}"
STR2="SENSOR_TEMP: $DB_SENSOR_TEMP"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 14 RESERVE_INTERVAL   //RESERVED_INT
if [ -z "$SIM_ACTIV" ]; then
    DB_MODE_TRANSFER=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=99;")
else
    # Получения значения из БД
    DB_RESERVE_INTERVAL=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
    join dicts.attributes_dict as ad on ad.id=si.attribute_id
    join devices_custs.device_sim as ds on ds.id=si.sim_id
    where ds.device_id=$id and attribute_id=99 and sim_num=$SIM_ACTIV;")
fi
RESERVE_INTERVAL=${arr[$i]}
STR1="RESERVE_INTERVAL: ${arr[$i]}"
STR2="RESERVE_INTERVAL: $DB_RESERVE_INTERVAL"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 15 SEANCECNT_MAX  //MAX_SESSION
# Получения значения из БД
DB_SEANCECNT_MAX=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=46;")
SEANCECNT_MAX=${arr[$i]}
STR1="SEANCECNT_MAX: ${arr[$i]}"
STR2="SEANCECNT_MAX: $DB_SEANCECNT_MAX"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 16 SEANCECNT  //COUNT_SESSION
if [ -z "$SIM_ACTIV" ]; then
DB_SEANCECNT=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=44;")
else
# Получения значения из БД
DB_SEANCECNT=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$id and attribute_id=44 and sim_num=$SIM_ACTIV;")
fi
SEANCECNT=${arr[$i]}
STR1="SEANCECNT: ${arr[$i]}"
STR2="SEANCECNT: $DB_SEANCECNT"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 17 SEANCECNT_ERR  //ERROR_SESSION
if [ -z "$SIM_ACTIV" ]; then
DB_SEANCECNT_ERR=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=45;")
else
# Получения значения из БД
DB_SEANCECNT_ERR=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$id and attribute_id=45 and sim_num=$SIM_ACTIV;")
fi
SEANCECNT_ERR=${arr[$i]}
STR1="SEANCECNT_ERR: ${arr[$i]}"
STR2="SEANCECNT_ERR: $DB_SEANCECNT_ERR"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 18 GAS_DAY    //GAS_DAY
# Получения значения из БД
DB_GAS_DAY=$(psql -U $Login -d $Name -p $Port -tA -c "SELECT gasbegin FROM devices_custs.device_static_params
where device_id=$id;")
GAS_DAY=${arr[$i]}:00:00
STR1="GAS_DAY: $GAS_DAY"
STR2="GAS_DAY: $DB_GAS_DAY"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 19 HWVERSION  //HW_VER
# Получения значения из БД
DB_HWVERSION=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=100;")
SEANCECNT_MAX=${arr[$i]}
STR1="HWVERSION: ${arr[$i]}"
STR2="HWVERSION: $DB_HWVERSION"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 20 AUTOSWITH  //AUTO_SWITCH_MODE
if [ -z "$SIM_ACTIV" ]; then
DB_AUTOSWITH=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=101;")
else
# Получения значения из БД
DB_AUTOSWITH=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$id and attribute_id=101 and sim_num=$SIM_ACTIV;")
fi
AUTOSWITH=${arr[$i]}
STR1="AUTOSWITH: ${arr[$i]}"
STR2="AUTOSWITH: $DB_AUTOSWITH"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 21 LASTCHANGEARCNUM   //ARC_CHANGE_LASTREC
# Получения значения из БД
DB_LASTCHANGEARCNUM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=87;")
LASTCHANGEARCNUM=${arr[$i]}
STR1="LASTCHANGEARCNUM: ${arr[$i]}"
STR2="LASTCHANGEARCNUM: $DB_LASTCHANGEARCNUM"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 22 LASTSYSARCNUM  //ARC_SYSTEM_LASTREC || ARC_EVENT_LASTREC
if [ -n "$VERS_S" ]; then
if (( $(echo "$VERS_S < 1.273700" | bc -l) )); then
    # Получения значения из БД
    DB_LASTSYSARCNUM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=2684;")
    LASTSYSARCNUM=${arr[$i]}
    STR1="LASTEVENTARCNUM: ${arr[$i]}"
    STR2="LASTEVENTARCNUM: $DB_LASTSYSARCNUM"
    sleep 0.2
        if echo "$STR1" | grep -wq "$STR2"; then
            echo -e "${GREEN}FILE ==>    $STR1${NC}"
            echo -e "${GREEN}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        else
            echo -e "${RED}FILE ==>    $STR1${NC}"
            echo -e "${RED}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        fi
else
    # Получения значения из БД
    DB_LASTSYSARCNUM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=82;")
    LASTSYSARCNUM=${arr[$i]}
    STR1="LASTSYSARCNUM: ${arr[$i]}"
    STR2="LASTSYSARCNUM: $DB_LASTSYSARCNUM"
    sleep 0.2
        if echo "$STR1" | grep -wq "$STR2"; then
            echo -e "${GREEN}FILE ==>    $STR1${NC}"
            echo -e "${GREEN}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        else
            echo -e "${RED}FILE ==>    $STR1${NC}"
            echo -e "${RED}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        fi
fi
else
    # Получения значения из БД
    DB_LASTSYSARCNUM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
    where device_id=$id and attribute_id=82;")
    LASTSYSARCNUM=${arr[$i]}
    STR1="LASTSYSARCNUM: ${arr[$i]}"
    STR2="LASTSYSARCNUM: $DB_LASTSYSARCNUM"
    sleep 0.2
        if echo "$STR1" | grep -wq "$STR2"; then
            echo -e "${GREEN}FILE ==>    $STR1${NC}"
            echo -e "${GREEN}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        else
            echo -e "${RED}FILE ==>    $STR1${NC}"
            echo -e "${RED}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        fi
fi
# 23 LASTHOURARCNUM //ARC_HOUR_LASTREC
# Получения значения из БД
DB_LASTHOURARCNUM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=86;")
LASTHOURARCNUM=${arr[$i]}
STR1="LASTHOURARCNUM: ${arr[$i]}"
STR2="LASTHOURARCNUM: $DB_LASTHOURARCNUM"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 24 LASTDAYARCNUM  //ARC_DAY_LASTREC
# Получения значения из БД
DB_LASTDAYARCNUM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=84;")
LASTDAYARCNUM=${arr[$i]}
STR1="LASTDAYARCNUM: ${arr[$i]}"
STR2="LASTDAYARCNUM: $DB_LASTDAYARCNUM"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 25 P_ABS  //PABS
# Получения значения из БД
DB_P_ABS=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2667;")
P_ABS=${arr[$i]}
STR1="P_ABS: ${arr[$i]}"
STR2="P_ABS: $DB_P_ABS"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 26 LASTVALVECMD   //VALVE_SRV_CMD
# Получения значения из БД
DB_LASTVALVECMD=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2685;")
LASTVALVECMD=${arr[$i]}
STR1="LASTVALVECMD: ${arr[$i]}"
STR2="LASTVALVECMD: $DB_LASTVALVECMD"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 27 VALVESTATE //VALVE_STATE
# Получения значения из БД
DB_VALVESTATE=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=72;")
VALVESTATE=${arr[$i]}
STR1="VALVESTATE: ${arr[$i]}"
STR2="VALVESTATE: $DB_VALVESTATE"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 28 CNT_FAIL_SIM   //COUNT_FAIL_SIM
if [ -z "$SIM_ACTIV" ]; then
DB_CNT_FAIL_SIM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2669;")
else
# Получения значения из БД
DB_CNT_FAIL_SIM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$id and attribute_id=2669 and sim_num=$SIM_ACTIV;")
fi
CNT_FAIL_SIM=${arr[$i]}
STR1="CNT_FAIL_SIM: ${arr[$i]}"
STR2="CNT_FAIL_SIM: $DB_CNT_FAIL_SIM"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 29 CNT_FAIL_SPEED //COUNT_FAIL_SPEED
# Получения значения из БД
DB_CNT_FAIL_SPEED=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2670;")
CNT_FAIL_SPEED=${arr[$i]}
STR1="CNT_FAIL_SPEED: ${arr[$i]}"
STR2="CNT_FAIL_SPEED: $DB_CNT_FAIL_SPEED"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 30 VALVE_AUTO_CTL //VALVE_AUTO_CONTROL
# Получения значения из БД
DB_VALVE_AUTO_CTL=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2671;")
VALVE_AUTO_CTL=${arr[$i]}
STR1="VALVE_AUTO_CTL: ${arr[$i]}"
STR2="VALVE_AUTO_CTL: $DB_VALVE_AUTO_CTL"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 31 KFAKTOR    //K_FACTOR
# Получения значения из БД
#DB_KFAKTOR=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
#where device_id=$id and attribute_id=2671;")
KFAKTOR=${arr[$i]}
STR1="KFAKTOR: ${arr[$i]}"
STR2="KFAKTOR: $DB_KFAKTOR"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 32 LASTTELARCNUM  //ARC_TELEMETRY_LASTREC
# Получения значения из БД
DB_LASTTELARCNUM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=85;")
LASTTELARCNUM=${arr[$i]}
STR1="LASTTELARCNUM: ${arr[$i]}"
STR2="LASTTELARCNUM: $DB_LASTTELARCNUM"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 33 BATTERY_PERCENT    //BAT_TELEMETRY
# Получения значения из БД
DB_BATTERY_PERCENT=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=35;")
BATTERY_PERCENT=${arr[$i]}
STR1="BATTERY_PERCENT: ${arr[$i]}"
STR2="BATTERY_PERCENT: $DB_BATTERY_PERCENT"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 34 TCP_ADDRESS2   //SERVER_URL2 (char57) - для конкретной SIM карты. Cм.описание
if [ -z "$SIM_ACTIV" ]; then
DB_TCP_ADDRESS2=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=56;")
else
DB_TCP_ADDRESS2=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$id and attribute_id=56 and sim_num=$SIM_ACTIV;")
fi
TCP_ADDRESS2=${arr[$i]}
STR1="TCP_ADDRESS2: ${arr[$i]}"
STR2="TCP_ADDRESS2: $DB_TCP_ADDRESS2"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 35 AUTO_OFF_REZREP    //AUTO_OFF_REZREP (uint8) - использование резервных и повторных сеансов для конкретной SIM карты. Cм.описание.
if [ -n "$VERS_K" ]; then
    if (( $(echo "$VERS_K >= 1.050299" | bc -l) )); then
        DB_AUTO_OFF_REZREP=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
        join dicts.attributes_dict as ad on ad.id=si.attribute_id
        join devices_custs.device_sim as ds on ds.id=si.sim_id
        where ds.device_id=$id and attribute_id=2672 and sim_num=$SIM_ACTIV;")
        AUTO_OFF_REZREP=${arr[$i]}
        STR1="AUTO_OFF_REZREP: ${arr[$i]}"
        STR2="AUTO_OFF_REZREP: $DB_AUTO_OFF_REZREP"
        sleep 0.2
        if echo "$STR1" | grep -wq "$STR2"; then
            echo -e "${GREEN}FILE ==>    $STR1${NC}"
            echo -e "${GREEN}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        else
            echo -e "${RED}FILE ==>    $STR1${NC}"
            echo -e "${RED}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        fi
    else
        echo -e "${GREEN}FILE ==>    reserved${NC}"
        echo -e "${GREEN}DB   ==>    reserved${NC}"
        echo "---------------------------"
        ((i++))
        if [ "$i" -ge "$COUNTERS" ]; then
            # Запускаем подменю программы
            exit 0
        fi
    fi
else
    if (( $(echo "$VERS_S >= 1.290299" | bc -l) )); then
        DB_AUTO_OFF_REZREP=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.sim_info_params as si
        join dicts.attributes_dict as ad on ad.id=si.attribute_id
        join devices_custs.device_sim as ds on ds.id=si.sim_id
        where ds.device_id=$id and attribute_id=2672 and sim_num=$SIM_ACTIV;")
        AUTO_OFF_REZREP=${arr[$i]}
        STR1="AUTO_OFF_REZREP: ${arr[$i]}"
        STR2="AUTO_OFF_REZREP: $DB_AUTO_OFF_REZREP"
        sleep 0.2
        if echo "$STR1" | grep -wq "$STR2"; then
            echo -e "${GREEN}FILE ==>    $STR1${NC}"
            echo -e "${GREEN}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        else
            echo -e "${RED}FILE ==>    $STR1${NC}"
            echo -e "${RED}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        fi
    else
        echo -e "${GREEN}FILE ==>    reserved${NC}"
        echo -e "${GREEN}DB   ==>    reserved${NC}"
        echo "---------------------------"
        ((i++))
        if [ "$i" -ge "$COUNTERS" ]; then
            # Запускаем подменю программы
            exit 0
        fi
    fi
fi

# 36 SERIAL_BOARD   //SERIAL_NUMBER_BOARD (char14) - серийный номер платы. . Cм.описание NUMBER_BOARD2.
# Получения значения из БД
DB_SERIAL_BOARD=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2673;")
SERIAL_BOARD=${arr[$i]}
STR1="SERIAL_BOARD: ${arr[$i]}"
STR2="SERIAL_BOARD: $DB_SERIAL_BOARD"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 37 SGS_PHONE2 //SMS_PHONE2 (char14) - резерв
# Получения значения из БД
#DB_SGS_PHONE2=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
#where device_id=$id and attribute_id=2673;")
SGS_PHONE2=${arr[$i]}
STR1="SGS_PHONE2: ${arr[$i]}"
STR2="SGS_PHONE2: $DB_SGS_PHONE2"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 38 WARNINGSTATE   //STATUS_WARNING (uint32) - текущий статус предупреждений.
# Получения значения из БД
DB_WARNINGSTATE=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=75;")
#преобразуем значение из файла из hex16 в hex10
WARNINGSTATE=$(printf "%d" 0x"${arr[$i]}")
STR1="WARNINGSTATE: $WARNINGSTATE"
STR2="WARNINGSTATE: $DB_WARNINGSTATE"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 39 ALARMSTATE     //STATUS_ALARM (uint32) - текущий статус тревог.
# Получения значения из БД
DB_ALARMSTATE=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=74;")
#преобразуем значение из файла из hex16 в hex10
ALARMSTATE=$(printf "%d" 0x"${arr[$i]}")
STR1="ALARMSTATE: $ALARMSTATE"
STR2="ALARMSTATE: $DB_ALARMSTATE"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 40 CRASHSTATE     //STATUS_CRASH (uint32) - текущий статус аварий.
# Получения значения из БД
DB_CRASHSTATE=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=73;")
#преобразуем значение из файла из hex16 в hex10
CRASHSTATE=$(printf "%d" 0x"${arr[$i]}")
STR1="CRASHSTATE: $CRASHSTATE"
STR2="CRASHSTATE: $DB_CRASHSTATE"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 41 STATUS_STORY    STATUS_STORY (uint64) - текущее состояние регистров ПТА. 0-15 биты П, 16-31 биты Т, 32-47 биты- А.
# Получения значения из БД
DB_STATUS_STORY=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=110;")
#преобразуем значение из файла из hex16 в hex10
CRASHSTATE=$(printf "%d" 0x"${arr[$i]}")
STR1="STATUS_STORY: $CRASHSTATE"
STR2="STATUS_STORY: $DB_STATUS_STORY"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 42 ERROR_SESSION_SERVER2     ERROR_SESSION_SERVER_2 (uint32) - счётчик неудачных сеансов на серев1 для конкретной SIM карты (не обнуляется).
DB_ERROR_SESSION_SERVER2=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2675;")
ERROR_SESSION_SERVER2=${arr[$i]}
STR1="ERROR_SESSION_SERVER2: ${arr[$i]}"
STR2="ERROR_SESSION_SERVER2: $DB_ERROR_SESSION_SERVER2"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 43 CNT_REZREP     //CNT_REZREP (uint32) - число всего совершённых сеансов повторных и резервных.
if [ -n "$VERS_K" ]; then
    if (( $(echo "$VERS_K >= 1.050299" | bc -l) )); then
        DB_CNT_REZREP=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
        where device_id=$id and attribute_id=2676;")
        CNT_REZREP=${arr[$i]}
        STR1="CNT_REZREP: ${arr[$i]}"
        STR2="CNT_REZREP: $DB_CNT_REZREP"
        sleep 0.2
        if echo "$STR1" | grep -wq "$STR2"; then
            echo -e "${GREEN}FILE ==>    $STR1${NC}"
            echo -e "${GREEN}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        else
            echo -e "${RED}FILE ==>    $STR1${NC}"
            echo -e "${RED}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        fi
    else
        echo -e "${GREEN}FILE ==>    reserved${NC}"
        echo -e "${GREEN}DB   ==>    reserved${NC}"
        echo "---------------------------"
        ((i++))
        if [ "$i" -ge "$COUNTERS" ]; then
            # Запускаем подменю программы
            exit 0
        fi
    fi
else
    if (( $(echo "$VERS_S >= 1.290299" | bc -l) )); then
        DB_CNT_REZREP=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
        where device_id=$id and attribute_id=2676;")
        CNT_REZREP=${arr[$i]}
        STR1="CNT_REZREP: ${arr[$i]}"
        STR2="CNT_REZREP: $DB_CNT_REZREP"
        sleep 0.2
        if echo "$STR1" | grep -wq "$STR2"; then
            echo -e "${GREEN}FILE ==>    $STR1${NC}"
            echo -e "${GREEN}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        else
            echo -e "${RED}FILE ==>    $STR1${NC}"
            echo -e "${RED}DB   ==>    $STR2${NC}"
            echo "---------------------------"
            ((i++))
            if [ "$i" -ge "$COUNTERS" ]; then
                # Запускаем подменю программы
                exit 0
            fi
        fi
    else
        echo -e "${GREEN}FILE ==>    reserved${NC}"
        echo -e "${GREEN}DB   ==>    reserved${NC}"
        echo "---------------------------"
        ((i++))
        if [ "$i" -ge "$COUNTERS" ]; then
            # Запускаем подменю программы
            exit 0
        fi
    fi
fi

# 44 BATTERY_TELEMETRY  //BAT_COUNTER (float) - остаточная ёмкость батареи счётчика (резервная) в %.
DB_BATTERY_TELEMETRY=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=3022;")
BATTERY_TELEMETRY=${arr[$i]}
STR1="BATTERY_TELEMETRY: ${arr[$i]}"
STR2="BATTERY_TELEMETRY: $DB_BATTERY_TELEMETRY"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 45 CURRENT_FLOW   //CURRENT_FLOW (uint64) - м3*10000  -текущий расход газа.
DB_CURRENT_FLOW=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2677;")
CURRENT_FLOW=${arr[$i]}
STR1="CURRENT_FLOW: ${arr[$i]}"
STR2="CURRENT_FLOW: $DB_CURRENT_FLOW"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 46 CURRENT_FLOW_DISPL     //CURRENT_FLOW_DISPL (uint64) - м3*10000 - текущий возмущённый расход газа
DB_CURRENT_FLOW_DISPL=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2678;")
CURRENT_FLOW_DISPL=${arr[$i]}
STR1="CURRENT_FLOW_DISPL: ${arr[$i]}"
STR2="CURRENT_FLOW_DISPL: $DB_CURRENT_FLOW_DISPL"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 47 LASTVSDIST     //CURRENT_COUNTER_DISC (uint64) - м3*10000 - накопленный возмущённый объём.
#DB_LASTVSDIST=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
#where device_id=$id and attribute_id=2678;")
LASTVSDIST=${arr[$i]}
STR1="LASTVSDIST: ${arr[$i]}"
STR2="LASTVSDIST: $DB_LASTVSDIST"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 48 CURRENT_COUNTER_GLOB   //CURRENT_COUNTER_GLOB (uint64) - м3*10000, равен CURRENT_COUNTER
DB_CURRENT_COUNTER_GLOB=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=37;")
CURRENT_COUNTER_GLOB=$(echo ${arr[$i]} | grep -oE '[0-9]*\.?[0-9]+')
CURRENT_COUNTER_GLOB=$(echo "scale=4; $CURRENT_COUNTER_GLOB * $VOLUME_PULSE" | bc)
# Добавляем "0" если значение меньше единицы
if [[ "$CURRENT_COUNTER_GLOB" == .* ]]; then
    CURRENT_COUNTER_GLOB=0$CURRENT_COUNTER_GLOB
fi
STR1="CURRENT_COUNTER_GLOB: $CURRENT_COUNTER_GLOB"
STR2="CURRENT_COUNTER_GLOB: $DB_CURRENT_COUNTER_GLOB"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 49 STATUS_RS485   //STATUS_RS485 (uint8) - 0 бит - '1' - есть питание внешнее, 1 бит - '1' - есть питание интерфейса, 2 бит - '1' - есть активность интерфейса.
DB_STATUS_RS485=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2679;")
STATUS_RS485=${arr[$i]}
STR1="STATUS_RS485: ${arr[$i]}"
STR2="STATUS_RS485: $DB_STATUS_RS485"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 50 SIM_ENABLE     //SIM_ENABLE (uint8), hex - какие сим карты включены: 0 бит 1 SIM, 1 бит 2 SIM, 2 бит 3 SIM.
DB_SIM_ENABLE=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2686;")
SIM_ENABLE=${arr[$i]}
STR1="SIM_ENABLE: ${arr[$i]}"
STR2="SIM_ENABLE: $DB_SIM_ENABLE"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 51 SIM_ACTIV  //SIM_ACTIV (uint8) - (1-3) какая SIM сейчас активна при включённом модем или была активной последней после выключения модема.
DB_SIM_ACTIV=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2680;")
SIM_ACTIV=${arr[$i]}
STR1="SIM_ACTIV: ${arr[$i]}"
STR2="SIM_ACTIV: $DB_SIM_ACTIV"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 52 MODEM_IMEI     //IMEI модема
DB_MODEM_IMEI=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=51;")
MODEM_IMEI=${arr[$i]}
STR1="MODEM_IMEI: ${arr[$i]}"
STR2="MODEM_IMEI: $DB_MODEM_IMEI"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 53 EN_ARCHIVE_SIM3    //EN_ARCHIVE_SIM3 (uint8) - разрешение ведение арх.телем для SIM3
DB_EN_ARCHIVE_SIM3=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2681;")
EN_ARCHIVE_SIM3=${arr[$i]}
STR1="EN_ARCHIVE_SIM3: ${arr[$i]}"
STR2="EN_ARCHIVE_SIM3: $DB_EN_ARCHIVE_SIM3"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 54 TEMP_BOARD     //TEMP_BOARD (float) - температура платы
DB_TEMP_BOARD=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2682;")
TEMP_BOARD=${arr[$i]}
STR1="TEMP_BOARD: ${arr[$i]}"
STR2="TEMP_BOARD: $DB_TEMP_BOARD"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 55 EXT_ANT    //EXT_ANT (uint8) - переключатель антенны в универсальной плате
DB_EXT_ANT=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
where device_id=$id and attribute_id=2683;")
EXT_ANT=${arr[$i]}
STR1="EXT_ANT: ${arr[$i]}"
STR2="EXT_ANT: $DB_EXT_ANT"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 56 GAS_MON    //газовый месяц
#DB_GAS_MON=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
#where device_id=$id and attribute_id=2683;")
GAS_MON=${arr[$i]}
STR1="GAS_MON: ${arr[$i]}"
STR2="GAS_MON: $DB_GAS_MON"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi

# 57 LASTMONARCNUM  //последний номер арх. месячного
#DB_LASTMONARCNUM=$(psql -U $Login -d $Name -p $Port -tA -c "select value from info_params.device_info_params
#where device_id=$id and attribute_id=2683;")
LASTMONARCNUM=${arr[$i]}
STR1="LASTMONARCNUM: ${arr[$i]}"
STR2="LASTMONARCNUM: $DB_LASTMONARCNUM"
sleep 0.2
if echo "$STR1" | grep -wq "$STR2"; then
    echo -e "${GREEN}FILE ==>    $STR1${NC}"
    echo -e "${GREEN}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
else
    echo -e "${RED}FILE ==>    $STR1${NC}"
    echo -e "${RED}DB   ==>    $STR2${NC}"
    echo "---------------------------"
    ((i++))
    if [ "$i" -ge "$COUNTERS" ]; then
        # Запускаем подменю программы
        exit 0
    fi
fi



# Запускаем подменю программы
#$ACTIVE_DIR/Menu[AC].sh
