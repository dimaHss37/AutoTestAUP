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

if [[ "$VER_PROTOCOL" -gt 9 ]]; then
    SIM1=$(cat $TARGET | awk '/\[SIM1 DATA\]/{f=2} f && /#\(/ {f=0; print; next} f' | sed '/SIM/d' | sed '/#(/d' | iconv -f CP1251 -t UTF-8)
    IFS=';' read -r -a arr1 <<< "$SIM1"
    SIM2=$(cat $TARGET | awk '/\[SIM2 DATA\]/{f=2} f && /#\(/ {f=0; print; next} f' | sed '/SIM/d' | sed '/#(/d' | iconv -f CP1251 -t UTF-8)
    IFS=';' read -r -a arr2 <<< "$SIM2"
    SIM3=$(cat $TARGET | awk '/\[SIM3 DATA\]/{f=2} f && /#\(/ {f=0; print; next} f' | sed '/SIM/d' | sed '/#(/d' | iconv -f CP1251 -t UTF-8)
    IFS=';' read -r -a arr3 <<< "$SIM3"



for ((i=1; i<=3; i++)); do

    if [ $i -eq 1 ]; then
            arr=("${arr1[@]}")
    fi
    if [ $i -eq 2 ]; then
            arr=("${arr2[@]}")
    fi
    if [ $i -eq 3 ]; then
            arr=("${arr3[@]}")
    fi

    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[SIM$i DATA]" >> $LOG
    echo ""
    echo "[SIM$i DATA]"
    echo "---------------------------"
    MOD="SIM$i DATA"

    # SIM_ENABLE
    sleep 0.1
    export PGPASSWORD=$Password
    SIM_ENABLE=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
    join dicts.attributes_dict as ad on ad.id=si.attribute_id
    join devices_custs.device_sim as ds on ds.id=si.sim_id
    where ds.device_id=$device_id and sim_num=$i and attribute_id=2686;")
    unset PGPASSWORD
    F_SIM_ENABLE="${arr[0]}"
    if [[ "$F_SIM_ENABLE" == "$SIM_ENABLE" ]]; then
        echo "SIM_ENABLE"
        echo -e "${GREEN}F: $F_SIM_ENABLE${NC}"
        echo -e "${GREEN}B: $SIM_ENABLE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][SIM_ENABLE: FILE -> $F_SIM_ENABLE DB -> $SIM_ENABLE параметры совпали]" >> $LOG
    else
        echo "SIM_ENABLE"
        echo -e "${RED}F: $F_SIM_ENABLE${NC}"
        echo -e "${RED}B: $SIM_ENABLE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][SIM_ENABLE: FILE -> $F_SIM_ENABLE DB -> $SIM_ENABLE параметры не совпали]" >> $LOG
    fi

#SERVER_URL/PORT (TCP_ADDRESS)
sleep 0.1
export PGPASSWORD=$Password
TCP_ADDRESS=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=55;")
unset PGPASSWORD
F_SERVER_URL="${arr[1]}"
F_PORT="${arr[2]}"
F_TCP_ADDRESS="${F_SERVER_URL}:${F_PORT}"
    if [[ "$F_TCP_ADDRESS" == "$TCP_ADDRESS" ]]; then
        echo "TCP_ADDRESS"
        echo -e "${GREEN}F: $F_TCP_ADDRESS${NC}"
        echo -e "${GREEN}B: $TCP_ADDRESS${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][TCP_ADDRESS: FILE -> $F_TCP_ADDRESS DB -> $TCP_ADDRESS параметры совпали]" >> $LOG
    else
        echo "TCP_ADDRESS"
        echo -e "${RED}F: $F_TCP_ADDRESS${NC}"
        echo -e "${RED}B: $TCP_ADDRESS${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][TCP_ADDRESS: FILE -> $F_TCP_ADDRESS DB -> $TCP_ADDRESS параметры не совпали]" >> $LOG
    fi

#SERVER_URL2/PORT2 (TCP_ADDRESS2)
sleep 0.1
export PGPASSWORD=$Password
TCP_ADDRESS2=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=56;")
unset PGPASSWORD
F_SERVER_URL2="${arr[3]}"
F_PORT2="${arr[4]}"
F_TCP_ADDRESS2="${F_SERVER_URL2}:${F_PORT2}"
    if [[ "$F_TCP_ADDRESS2" == "$TCP_ADDRESS2" ]]; then
        echo "TCP_ADDRESS2"
        echo -e "${GREEN}F: $F_TCP_ADDRESS2${NC}"
        echo -e "${GREEN}B: $TCP_ADDRESS2${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][TCP_ADDRESS2: FILE -> $F_TCP_ADDRESS2 DB -> $TCP_ADDRESS2 параметры совпали]" >> $LOG
    else
        echo "TCP_ADDRESS"
        echo -e "${RED}F: $F_TCP_ADDRESS2${NC}"
        echo -e "${RED}B: $TCP_ADDRESS2${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][TCP_ADDRESS2: FILE -> $F_TCP_ADDRESS2 DB -> $TCP_ADDRESS2 параметры не совпали]" >> $LOG
    fi

# APN_ADDRESS
sleep 0.1
export PGPASSWORD=$Password
APN_ADDRESS=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=54;")
unset PGPASSWORD
F_APN_ADDRESS="${arr[5]}"
    if [[ "$F_APN_ADDRESS" == "$APN_ADDRESS" ]]; then
        echo "APN_ADDRESS"
        echo -e "${GREEN}F: $F_APN_ADDRESS${NC}"
        echo -e "${GREEN}B: $APN_ADDRESS${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][APN_ADDRESS: FILE -> $F_APN_ADDRESS DB -> $APN_ADDRESS параметры совпали]" >> $LOG
    else
        echo "APN_ADDRESS"
        echo -e "${RED}F: $F_APN_ADDRESS${NC}"
        echo -e "${RED}B: $APN_ADDRESS${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][APN_ADDRESS: FILE -> $F_APN_ADDRESS DB -> $APN_ADDRESS параметры не совпали]" >> $LOG
    fi

# APN_LOGIN
sleep 0.1
export PGPASSWORD=$Password
APN_LOGIN=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=52;")
unset PGPASSWORD
F_APN_LOGIN="${arr[6]}"
    if [[ "$F_APN_LOGIN" == "$APN_LOGIN" ]]; then
        echo "APN_LOGIN"
        echo -e "${GREEN}F: $F_APN_LOGIN${NC}"
        echo -e "${GREEN}B: $APN_LOGIN${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][APN_LOGIN: FILE -> $F_APN_LOGIN DB -> $APN_LOGIN параметры совпали]" >> $LOG
    else
        echo "APN_LOGIN"
        echo -e "${RED}F: $F_APN_LOGIN${NC}"
        echo -e "${RED}B: $APN_LOGIN${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][APN_LOGIN: FILE -> $F_APN_LOGIN DB -> $APN_LOGIN параметры не совпали]" >> $LOG
    fi

# APN_PASSWORD
sleep 0.1
export PGPASSWORD=$Password
APN_PASSWORD=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=53;")
unset PGPASSWORD
F_APN_PASSWORD="${arr[7]}"
    if [[ "$F_APN_PASSWORD" == "$APN_PASSWORD" ]]; then
        echo "APN_PASSWORD"
        echo -e "${GREEN}F: $F_APN_PASSWORD${NC}"
        echo -e "${GREEN}B: $APN_PASSWORD${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][APN_PASSWORD: FILE -> $F_APN_PASSWORD DB -> $APN_PASSWORD параметры совпали]" >> $LOG
    else
        echo "APN_PASSWORD"
        echo -e "${RED}F: $F_APN_PASSWORD${NC}"
        echo -e "${RED}B: $APN_PASSWORD${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][APN_PASSWORD: FILE -> $F_APN_PASSWORD DB -> $APN_PASSWORD параметры не совпали]" >> $LOG
    fi




done










else
    SIM_DATA=$(cat $TARGET | awk '/\[SIM DATA\]/{f=2} f && /#\(/ {f=0; print; next} f' | sed '/SIM/d' | sed '/#(/d' | iconv -f CP1251 -t UTF-8)
    COUNTERS=$(echo $SIM_DATA | head -n 1 | grep -o ";" | wc -l)
    COUNTERS=$((COUNTERS + 1))
    IFS=';' read -r -a arr <<< "$SIM_DATA"
fi
