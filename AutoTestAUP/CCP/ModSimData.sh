#!/bin/bash

# Коды цветов
RED="\033[31m" # Красный
GREEN="\033[32m" # Зеленый
NC="\033[0m" # Без цвета (сброс)
DATE_STR=$(date +"%d.%m.%Y")

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

    TIME_STR=$(date +"%H:%M:%S")
    echo "[SIM$i DATA]" >> $LOG
    echo ""
    echo "[SIM$i DATA]"
    echo "---------------------------"
    MOD="SIM$i DATA"

    # 1 SIM_ENABLE
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
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][SIM_ENABLE: FILE -> $F_SIM_ENABLE DB -> $SIM_ENABLE значения совпали]" >> $LOG
    else
        echo "SIM_ENABLE"
        echo -e "${RED}F: $F_SIM_ENABLE${NC}"
        echo -e "${RED}B: $SIM_ENABLE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][SIM_ENABLE: FILE -> $F_SIM_ENABLE DB -> $SIM_ENABLE значения не совпали]" >> $LOG
    fi

# 2/3 SERVER_URL/PORT (TCP_ADDRESS)
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
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][TCP_ADDRESS: FILE -> $F_TCP_ADDRESS DB -> $TCP_ADDRESS значения совпали]" >> $LOG
    else
        echo "TCP_ADDRESS"
        echo -e "${RED}F: $F_TCP_ADDRESS${NC}"
        echo -e "${RED}B: $TCP_ADDRESS${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][TCP_ADDRESS: FILE -> $F_TCP_ADDRESS DB -> $TCP_ADDRESS значения не совпали]" >> $LOG
    fi

# 4/5 SERVER_URL2/PORT2 (TCP_ADDRESS2)
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
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][TCP_ADDRESS2: FILE -> $F_TCP_ADDRESS2 DB -> $TCP_ADDRESS2 значения совпали]" >> $LOG
    else
        echo "TCP_ADDRESS"
        echo -e "${RED}F: $F_TCP_ADDRESS2${NC}"
        echo -e "${RED}B: $TCP_ADDRESS2${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][TCP_ADDRESS2: FILE -> $F_TCP_ADDRESS2 DB -> $TCP_ADDRESS2 значения не совпали]" >> $LOG
    fi

# 6 APN_ADDRESS
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
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][APN_ADDRESS: FILE -> $F_APN_ADDRESS DB -> $APN_ADDRESS значения совпали]" >> $LOG
    else
        echo "APN_ADDRESS"
        echo -e "${RED}F: $F_APN_ADDRESS${NC}"
        echo -e "${RED}B: $APN_ADDRESS${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][APN_ADDRESS: FILE -> $F_APN_ADDRESS DB -> $APN_ADDRESS значения не совпали]" >> $LOG
    fi

# 7 APN_LOGIN
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
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][APN_LOGIN: FILE -> $F_APN_LOGIN DB -> $APN_LOGIN значения совпали]" >> $LOG
    else
        echo "APN_LOGIN"
        echo -e "${RED}F: $F_APN_LOGIN${NC}"
        echo -e "${RED}B: $APN_LOGIN${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][APN_LOGIN: FILE -> $F_APN_LOGIN DB -> $APN_LOGIN значения не совпали]" >> $LOG
    fi

# 8 APN_PASSWORD
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
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][APN_PASSWORD: FILE -> $F_APN_PASSWORD DB -> $APN_PASSWORD значения совпали]" >> $LOG
    else
        echo "APN_PASSWORD"
        echo -e "${RED}F: $F_APN_PASSWORD${NC}"
        echo -e "${RED}B: $APN_PASSWORD${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][APN_PASSWORD: FILE -> $F_APN_PASSWORD DB -> $APN_PASSWORD значения не совпали]" >> $LOG
    fi

# 9 MODE_TRANSFER
sleep 0.1
export PGPASSWORD=$Password
MODE_TRANSFER=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=42;")
unset PGPASSWORD
F_MODE_TRANSFER="${arr[8]},${arr[9]}:${arr[10]},${arr[11]}"
    if [[ "$F_MODE_TRANSFER" == "$MODE_TRANSFER" ]]; then
        echo "MODE_TRANSFER"
        echo -e "${GREEN}F: $F_MODE_TRANSFER${NC}"
        echo -e "${GREEN}B: $MODE_TRANSFER${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][MODE_TRANSFER: FILE -> $F_MODE_TRANSFER DB -> $MODE_TRANSFER значения совпали]" >> $LOG
    else
        echo "MODE_TRANSFER"
        echo -e "${RED}F: $F_MODE_TRANSFER${NC}"
        echo -e "${RED}B: $MODE_TRANSFER${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][MODE_TRANSFER: FILE -> $F_MODE_TRANSFER DB -> $MODE_TRANSFER значения не совпали]" >> $LOG
    fi

# 10 HOUR_TRANSFER
sleep 0.1
export PGPASSWORD=$Password
HOUR_TRANSFER=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=2687;")
unset PGPASSWORD
F_HOUR_TRANSFER="${arr[9]}"
    if [[ "$F_HOUR_TRANSFER" == "$HOUR_TRANSFER" ]]; then
        echo "HOUR_TRANSFER"
        echo -e "${GREEN}F: $F_HOUR_TRANSFER${NC}"
        echo -e "${GREEN}B: $HOUR_TRANSFER${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][HOUR_TRANSFER: FILE -> $F_HOUR_TRANSFER DB -> $HOUR_TRANSFER значения совпали]" >> $LOG
    else
        echo "HOUR_TRANSFER"
        echo -e "${RED}F: $F_HOUR_TRANSFER${NC}"
        echo -e "${RED}B: $HOUR_TRANSFER${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][HOUR_TRANSFER: FILE -> $F_HOUR_TRANSFER DB -> $HOUR_TRANSFER значения не совпали]" >> $LOG
    fi

# 11 MINUTE_TRANSFER
sleep 0.1
export PGPASSWORD=$Password
MINUTE_TRANSFER=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=2688;")
unset PGPASSWORD
F_MINUTE_TRANSFER="${arr[10]}"
    if [[ "$F_MINUTE_TRANSFER" == "$MINUTE_TRANSFER" ]]; then
        echo "MINUTE_TRANSFER"
        echo -e "${GREEN}F: $F_MINUTE_TRANSFER${NC}"
        echo -e "${GREEN}B: $MINUTE_TRANSFER${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][MINUTE_TRANSFER: FILE -> $F_MINUTE_TRANSFER DB -> $MINUTE_TRANSFER значения совпали]" >> $LOG
    else
        echo "MINUTE_TRANSFER"
        echo -e "${RED}F: $F_MINUTE_TRANSFER${NC}"
        echo -e "${RED}B: $MINUTE_TRANSFER${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][MINUTE_TRANSFER: FILE -> $F_MINUTE_TRANSFER DB -> $MINUTE_TRANSFER значения не совпали]" >> $LOG
    fi

# 12 DAY_TRANSFER
sleep 0.1
export PGPASSWORD=$Password
DAY_TRANSFER=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=2689;")
unset PGPASSWORD
F_DAY_TRANSFER="${arr[11]}"
    if [[ "$F_DAY_TRANSFER" == "$DAY_TRANSFER" ]]; then
        echo "DAY_TRANSFER"
        echo -e "${GREEN}F: $F_DAY_TRANSFER${NC}"
        echo -e "${GREEN}B: $DAY_TRANSFER${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][DAY_TRANSFER: FILE -> $F_DAY_TRANSFER DB -> $DAY_TRANSFER значения совпали]" >> $LOG
    else
        echo "DAY_TRANSFER"
        echo -e "${RED}F: $F_DAY_TRANSFER${NC}"
        echo -e "${RED}B: $DAY_TRANSFER${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][DAY_TRANSFER: FILE -> $F_DAY_TRANSFER DB -> $DAY_TRANSFER значения не совпали]" >> $LOG
    fi

# 13 RESERVED_INT
sleep 0.1
export PGPASSWORD=$Password
RESERVED_INT=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=99;")
unset PGPASSWORD
F_RESERVED_INT="${arr[12]}"
    if [[ "$F_RESERVED_INT" == "$RESERVED_INT" ]]; then
        echo "RESERVED_INT"
        echo -e "${GREEN}F: $F_RESERVED_INT${NC}"
        echo -e "${GREEN}B: $RESERVED_INT${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][RESERVED_INT: FILE -> $F_RESERVED_INT DB -> $RESERVED_INT значения совпали]" >> $LOG
    else
        echo "RESERVED_INT"
        echo -e "${RED}F: $F_RESERVED_INT${NC}"
        echo -e "${RED}B: $RESERVED_INT${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][RESERVED_INT: FILE -> $F_RESERVED_INT DB -> $RESERVED_INT значения не совпали]" >> $LOG
    fi

# 14 BALANCE_PHONE
sleep 0.1
export PGPASSWORD=$Password
BALANCE_PHONE=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=41;")
unset PGPASSWORD
F_BALANCE_PHONE="${arr[13]}"
    if [[ "$F_BALANCE_PHONE" == "$BALANCE_PHONE" ]]; then
        echo "BALANCE_PHONE"
        echo -e "${GREEN}F: $F_BALANCE_PHONE${NC}"
        echo -e "${GREEN}B: $BALANCE_PHONE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][BALANCE_PHONE: FILE -> $F_BALANCE_PHONE DB -> $BALANCE_PHONE значения совпали]" >> $LOG
    else
        echo "BALANCE_PHONE"
        echo -e "${RED}F: $F_BALANCE_PHONE${NC}"
        echo -e "${RED}B: $BALANCE_PHONE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][BALANCE_PHONE: FILE -> $F_BALANCE_PHONE DB -> $BALANCE_PHONE значения не совпали]" >> $LOG
    fi

# 15 PASSWORD_OMEGA
sleep 0.1
export PGPASSWORD=$Password
PASSWORD_OMEGA=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=2690;")
unset PGPASSWORD
F_PASSWORD_OMEGA="${arr[14]}"
    if [[ "$F_PASSWORD_OMEGA" == "$PASSWORD_OMEGA" ]]; then
        echo "PASSWORD_OMEGA"
        echo -e "${GREEN}F: $F_PASSWORD_OMEGA${NC}"
        echo -e "${GREEN}B: $PASSWORD_OMEGA${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][PASSWORD_OMEGA: FILE -> $F_PASSWORD_OMEGA DB -> $PASSWORD_OMEGA значения совпали]" >> $LOG
    else
        echo "PASSWORD_OMEGA"
        echo -e "${RED}F: $F_PASSWORD_OMEGA${NC}"
        echo -e "${RED}B: $PASSWORD_OMEGA${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][PASSWORD_OMEGA: FILE -> $F_PASSWORD_OMEGA DB -> $PASSWORD_OMEGA значения не совпали]" >> $LOG
    fi

    # 16 PASSWORD_OMEGA2
    sleep 0.1
    export PGPASSWORD=$Password
    PASSWORD_OMEGA2=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
    join dicts.attributes_dict as ad on ad.id=si.attribute_id
    join devices_custs.device_sim as ds on ds.id=si.sim_id
    where ds.device_id=$device_id and sim_num=$i and attribute_id=2691;")
    unset PGPASSWORD
    F_PASSWORD_OMEGA2="${arr[15]}"
        if [[ "$F_PASSWORD_OMEGA2" == "$PASSWORD_OMEGA2" ]]; then
            echo "PASSWORD_OMEGA2"
            echo -e "${GREEN}F: $F_PASSWORD_OMEGA2${NC}"
            echo -e "${GREEN}B: $PASSWORD_OMEGA2${NC}"
            echo "---------------------------"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][PASSWORD_OMEGA2: FILE -> $F_PASSWORD_OMEGA2 DB -> $PASSWORD_OMEGA2 значения совпали]" >> $LOG
        else
            echo "PASSWORD_OMEGA2"
            echo -e "${RED}F: $F_PASSWORD_OMEGA2${NC}"
            echo -e "${RED}B: $PASSWORD_OMEGA2${NC}"
            echo "---------------------------"
            # запись в log
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][PASSWORD_OMEGA2: FILE -> $F_PASSWORD_OMEGA2 DB -> $PASSWORD_OMEGA2 значения не совпали]" >> $LOG
        fi

# 17 AUTO_SWITCH_MODE
sleep 0.1
export PGPASSWORD=$Password
AUTO_SWITCH_MODE=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=101;")
unset PGPASSWORD
F_AUTO_SWITCH_MODE="${arr[16]}"
    if [[ "$F_AUTO_SWITCH_MODE" == "$AUTO_SWITCH_MODE" ]]; then
        echo "AUTO_SWITCH_MODE"
        echo -e "${GREEN}F: $F_AUTO_SWITCH_MODE${NC}"
        echo -e "${GREEN}B: $AUTO_SWITCH_MODE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][AUTO_SWITCH_MODE: FILE -> $F_AUTO_SWITCH_MODE DB -> $AUTO_SWITCH_MODE значения совпали]" >> $LOG
    else
        echo "AUTO_SWITCH_MODE"
        echo -e "${RED}F: $F_AUTO_SWITCH_MODE${NC}"
        echo -e "${RED}B: $AUTO_SWITCH_MODE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][AUTO_SWITCH_MODE: FILE -> $F_PASSWORD_OMEGA2 DB -> $AUTO_SWITCH_MODE значения не совпали]" >> $LOG
    fi

# 18 AUTO_5MODE_FALSE
sleep 0.1
export PGPASSWORD=$Password
AUTO_5MODE_FALSE=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=2692;")
unset PGPASSWORD
F_AUTO_5MODE_FALSE="${arr[17]}"
    if [[ "$F_AUTO_5MODE_FALSE" == "$AUTO_5MODE_FALSE" ]]; then
        echo "AUTO_5MODE_FALSE"
        echo -e "${GREEN}F: $F_AUTO_5MODE_FALSE${NC}"
        echo -e "${GREEN}B: $AUTO_5MODE_FALSE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][AUTO_5MODE_FALSE: FILE -> $F_AUTO_5MODE_FALSE DB -> $AUTO_5MODE_FALSE значения совпали]" >> $LOG
    else
        echo "AUTO_5MODE_FALSE"
        echo -e "${RED}F: $F_AUTO_5MODE_FALSE${NC}"
        echo -e "${RED}B: $AUTO_5MODE_FALSE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][AUTO_5MODE_FALSE: FILE -> $F_AUTO_5MODE_FALSE DB -> $AUTO_5MODE_FALSE значения не совпали]" >> $LOG
    fi

# 19 AUTO_OFF_REZREP
sleep 0.1
export PGPASSWORD=$Password
AUTO_OFF_REZREP=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=2672;")
unset PGPASSWORD
F_AUTO_OFF_REZREP="${arr[18]}"
    if [[ "$F_AUTO_OFF_REZREP" == "$AUTO_OFF_REZREP" ]]; then
        echo "AUTO_OFF_REZREP"
        echo -e "${GREEN}F: $F_AUTO_OFF_REZREP${NC}"
        echo -e "${GREEN}B: $AUTO_OFF_REZREP${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][AUTO_OFF_REZREP: FILE -> $F_AUTO_OFF_REZREP DB -> $AUTO_OFF_REZREP значения совпали]" >> $LOG
    else
        echo "AUTO_OFF_REZREP"
        echo -e "${RED}F: $F_AUTO_OFF_REZREP${NC}"
        echo -e "${RED}B: $AUTO_OFF_REZREP${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][AUTO_OFF_REZREP: FILE -> $F_AUTO_OFF_REZREP DB -> $AUTO_OFF_REZREP значения не совпали]" >> $LOG
    fi

# 20 CNT_REZERV_SESSION (если равен 0, то будет как 4)
sleep 0.1
#export PGPASSWORD=$Password
#CNT_REZERV_SESSION=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
#join dicts.attributes_dict as ad on ad.id=si.attribute_id
#join devices_custs.device_sim as ds on ds.id=si.sim_id
#where ds.device_id=$device_id and sim_num=$i and attribute_id=2672;")
#unset PGPASSWORD
F_CNT_REZERV_SESSION="${arr[19]}"
CNT_REZERV_SESSION="в разработке!"
    if [[ "$F_CNT_REZERV_SESSION" == "$CNT_REZERV_SESSION" ]]; then
        echo "CNT_REZERV_SESSION"
        echo -e "${GREEN}F: $F_CNT_REZERV_SESSION${NC}"
        echo -e "${GREEN}B: $CNT_REZERV_SESSION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][CNT_REZERV_SESSION: FILE -> $F_CNT_REZERV_SESSION DB -> $CNT_REZERV_SESSION значения совпали]" >> $LOG
    else
        echo "CNT_REZERV_SESSION"
        echo -e "${RED}F: $F_CNT_REZERV_SESSION${NC}"
        echo -e "${RED}B: $CNT_REZERV_SESSION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][CNT_REZERV_SESSION: FILE -> $F_CNT_REZERV_SESSION DB -> $CNT_REZERV_SESSION значения не совпали]" >> $LOG
    fi

# 21-27 резерв

# 28 ERROR_SESSION
sleep 0.1
export PGPASSWORD=$Password
ERROR_SESSION=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=45;")
unset PGPASSWORD
F_ERROR_SESSION="${arr[27]}"
    if [[ "$F_ERROR_SESSION" == "$ERROR_SESSION" ]]; then
        echo "ERROR_SESSION"
        echo -e "${GREEN}F: $F_ERROR_SESSION${NC}"
        echo -e "${GREEN}B: $ERROR_SESSION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][ERROR_SESSION: FILE -> $F_ERROR_SESSION DB -> $ERROR_SESSION значения совпали]" >> $LOG
    else
        echo "ERROR_SESSION"
        echo -e "${RED}F: $F_ERROR_SESSION${NC}"
        echo -e "${RED}B: $ERROR_SESSION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][ERROR_SESSION: FILE -> $F_ERROR_SESSION DB -> $ERROR_SESSION значения не совпали]" >> $LOG
    fi

# 29 ERROR2_SESSION
sleep 0.1
export PGPASSWORD=$Password
ERROR2_SESSION=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=2693;")
unset PGPASSWORD
F_ERROR2_SESSION="${arr[28]}"
    if [[ "$F_ERROR2_SESSION" == "$ERROR2_SESSION" ]]; then
        echo "ERROR2_SESSION"
        echo -e "${GREEN}F: $F_ERROR2_SESSION${NC}"
        echo -e "${GREEN}B: $ERROR2_SESSION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][ERROR2_SESSION: FILE -> $F_ERROR2_SESSION DB -> $ERROR2_SESSION значения совпали]" >> $LOG
    else
        echo "ERROR2_SESSION"
        echo -e "${RED}F: $F_ERROR2_SESSION${NC}"
        echo -e "${RED}B: $ERROR2_SESSION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][ERROR2_SESSION: FILE -> $F_ERROR2_SESSION DB -> $ERROR2_SESSION значения не совпали]" >> $LOG
    fi

# 30 NAME_OPERATOR
sleep 0.1
export PGPASSWORD=$Password
NAME_OPERATOR=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=97;")
unset PGPASSWORD
F_NAME_OPERATOR="${arr[29]}"
    if [[ "$F_NAME_OPERATOR" == "$NAME_OPERATOR" ]]; then
        echo "NAME_OPERATOR"
        echo -e "${GREEN}F: $F_NAME_OPERATOR${NC}"
        echo -e "${GREEN}B: $NAME_OPERATOR${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][NAME_OPERATOR: FILE -> $F_NAME_OPERATOR DB -> $NAME_OPERATOR значения совпали]" >> $LOG
    else
        echo "NAME_OPERATOR"
        echo -e "${RED}F: $F_NAME_OPERATOR${NC}"
        echo -e "${RED}B: $NAME_OPERATOR${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][NAME_OPERATOR: FILE -> $F_NAME_OPERATOR DB -> $NAME_OPERATOR значения не совпали]" >> $LOG
    fi

# 31 CCID SIM карты / SIM_UID
sleep 0.1
export PGPASSWORD=$Password
SIM_UID=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=50;")
unset PGPASSWORD
F_SIM_UID="${arr[30]}"
    if [[ "$F_SIM_UID" == "$SIM_UID" ]]; then
        echo "SIM_UID"
        echo -e "${GREEN}F: $F_SIM_UID${NC}"
        echo -e "${GREEN}B: $SIM_UID${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][SIM_UID: FILE -> $F_SIM_UID DB -> $SIM_UID значения совпали]" >> $LOG
    else
        echo "SIM_UID"
        echo -e "${RED}F: $F_SIM_UID${NC}"
        echo -e "${RED}B: $SIM_UID${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][SIM_UID: FILE -> $F_SIM_UID DB -> $SIM_UID значения не совпали]" >> $LOG
    fi

# 32 GSM_LEVEL
sleep 0.1
export PGPASSWORD=$Password
GSM_LEVEL=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=32;")
unset PGPASSWORD
F_GSM_LEVEL="${arr[31]}"
if [[ "$F_GSM_LEVEL" != "99" ]]; then
    F_GSM_LEVEL=$((-113 + $F_GSM_LEVEL * 2))
fi
    if [[ "$F_GSM_LEVEL" == "$GSM_LEVEL" ]]; then
        echo "GSM_LEVEL"
        echo -e "${GREEN}F: $F_GSM_LEVEL${NC}"
        echo -e "${GREEN}B: $GSM_LEVEL${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][GSM_LEVEL: FILE -> $F_GSM_LEVEL DB -> $GSM_LEVEL значения совпали]" >> $LOG
    else
        echo "GSM_LEVEL"
        echo -e "${RED}F: $F_GSM_LEVEL${NC}"
        echo -e "${RED}B: $GSM_LEVEL${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][GSM_LEVEL: FILE -> $F_GSM_LEVEL DB -> $GSM_LEVEL значения не совпали]" >> $LOG
    fi

# 33 SIM_BALANCE
sleep 0.1
export PGPASSWORD=$Password
SIM_BALANCE=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=47;")
unset PGPASSWORD
F_SIM_BALANCE="${arr[32]}"
    if [[ "$F_SIM_BALANCE" == "$SIM_BALANCE" ]]; then
        echo "SIM_BALANCE"
        echo -e "${GREEN}F: $F_SIM_BALANCE${NC}"
        echo -e "${GREEN}B: $SIM_BALANCE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][SIM_BALANCE: FILE -> $F_SIM_BALANCE DB -> $SIM_BALANCE значения совпали]" >> $LOG
    else
        echo "SIM_BALANCE"
        echo -e "${RED}F: $F_SIM_BALANCE${NC}"
        echo -e "${RED}B: $SIM_BALANCE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][SIM_BALANCE: FILE -> $F_SIM_BALANCE DB -> $SIM_BALANCE значения не совпали]" >> $LOG
    fi

# 34 GSM_CODE
sleep 0.1
export PGPASSWORD=$Password
GSM_CODE=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=149;")
unset PGPASSWORD
F_GSM_CODE="${arr[33]}"
    if [[ "$F_GSM_CODE" == "$GSM_CODE" ]]; then
        echo "GSM_CODE"
        echo -e "${GREEN}F: $F_GSM_CODE${NC}"
        echo -e "${GREEN}B: $GSM_CODE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][GSM_CODE: FILE -> $F_GSM_CODE DB -> $GSM_CODE значения совпали]" >> $LOG
    else
        echo "GSM_CODE"
        echo -e "${RED}F: $F_GSM_CODE${NC}"
        echo -e "${RED}B: $GSM_CODE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][GSM_CODE: FILE -> $F_GSM_CODE DB -> $GSM_CODE значения не совпали]" >> $LOG
    fi

# 35 GEOLOCATION
sleep 0.1
export PGPASSWORD=$Password
GEOLOCATION=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=122;")
unset PGPASSWORD
F_GEOLOCATION=$(echo "${arr[34]}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    if [[ "$F_GEOLOCATION" == "$GEOLOCATION" ]]; then
        echo "GEOLOCATION"
        echo -e "${GREEN}F: $F_GEOLOCATION${NC}"
        echo -e "${GREEN}B: $GEOLOCATION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][GEOLOCATION: FILE -> $F_GEOLOCATION DB -> $GEOLOCATION значения совпали]" >> $LOG
    else
        echo "GEOLOCATION"
        echo -e "${RED}F: $F_GEOLOCATION${NC}"
        echo -e "${RED}B: $GEOLOCATION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][GEOLOCATION: FILE -> $F_GEOLOCATION DB -> $GEOLOCATION значения не совпали]" >> $LOG
    fi

# 36 SEANCECNT / COUNT_SESSION
sleep 0.1
export PGPASSWORD=$Password
SEANCECNT=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=44;")
unset PGPASSWORD
F_SEANCECNT=${arr[35]}
    if [[ "$F_SEANCECNT" == "$SEANCECNT" ]]; then
        echo "SEANCECNT"
        echo -e "${GREEN}F: $F_SEANCECNT${NC}"
        echo -e "${GREEN}B: $SEANCECNT${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][SEANCECNT: FILE -> $F_SEANCECNT DB -> $SEANCECNT значения совпали]" >> $LOG
    else
        echo "SEANCECNT"
        echo -e "${RED}F: $F_SEANCECNT${NC}"
        echo -e "${RED}B: $SEANCECNT${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][SEANCECNT: FILE -> $F_SEANCECNT DB -> $SEANCECNT значения не совпали]" >> $LOG
    fi

# 36 CNT_FAIL_SIM / COUNT_FAIL_SIM
sleep 0.1
export PGPASSWORD=$Password
CNT_FAIL_SIM=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and sim_num=$i and attribute_id=2669;")
unset PGPASSWORD
F_CNT_FAIL_SIM=$(echo "${arr[36]}" | grep -o '[0-9]\+')
    if [[ "$F_CNT_FAIL_SIM" == "$CNT_FAIL_SIM" ]]; then
        echo "CNT_FAIL_SIM"
        echo -e "${GREEN}F: $F_CNT_FAIL_SIM${NC}"
        echo -e "${GREEN}B: $CNT_FAIL_SIM${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][CNT_FAIL_SIM: FILE -> $F_CNT_FAIL_SIM DB -> $CNT_FAIL_SIM значения совпали]" >> $LOG
    else
        echo "CNT_FAIL_SIM"
        echo -e "${RED}F: $F_CNT_FAIL_SIM${NC}"
        echo -e "${RED}B: $CNT_FAIL_SIM${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][CNT_FAIL_SIM: FILE -> $F_CNT_FAIL_SIM DB -> $CNT_FAIL_SIM значения не совпали]" >> $LOG
    fi

done

else
    SIM_DATA=$(cat $TARGET | awk '/\[SIM DATA\]/{f=2} f && /#\(/ {f=0; print; next} f' | sed '/SIM/d' | sed '/#(/d' | iconv -f CP1251 -t UTF-8)
    COUNTERS=$(echo $SIM_DATA | head -n 1 | grep -o ";" | wc -l)
    COUNTERS=$((COUNTERS + 1))
    IFS=';' read -r -a arr <<< "$SIM_DATA"
    i=0

echo "[SIM DATA]" >> $LOG
echo ""
echo "[SIM DATA]"
echo "---------------------------"
MOD="SIM DATA"

# 1 GSM_NAME
sleep 0.1
export PGPASSWORD=$Password
GSM_NAME=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "SELECT value FROM info_params.device_info_params
where device_id = $device_id and attribute_id = 97;")
unset PGPASSWORD
F_GSM_NAME=${arr[$i]}
    if [[ "$F_GSM_NAME" == "$GSM_NAME" ]]; then
        echo "GSM_NAME"
        echo -e "${GREEN}F: $F_GSM_NAME${NC}"
        echo -e "${GREEN}B: $GSM_NAME${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][GSM_NAME: FILE -> $F_GSM_NAME DB -> $GSM_NAME значения совпали]" >> $LOG
    else
        echo "GSM_NAME"
        echo -e "${RED}F: $F_GSM_NAME${NC}"
        echo -e "${RED}B: $GSM_NAME${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][GSM_NAME: FILE -> $F_GSM_NAME DB -> $GSM_NAME значения не совпали]" >> $LOG
    fi
((i++))
if [ "$i" -ge "$COUNTERS" ]; then
        exit 0
fi

# 2 SIM_UID
sleep 0.1
export PGPASSWORD=$Password
SIM_UID=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "SELECT value FROM info_params.device_info_params
where device_id = $device_id and attribute_id = 50;")
unset PGPASSWORD
F_SIM_UID=${arr[$i]}
    if [[ "$F_SIM_UID" == "$SIM_UID" ]]; then
        echo "GSM_NAME"
        echo -e "${GREEN}F: $F_SIM_UID${NC}"
        echo -e "${GREEN}B: $SIM_UID${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][SIM_UID: FILE -> $F_SIM_UID DB -> $SIM_UID значения совпали]" >> $LOG
    else
        echo "SIM_UID"
        echo -e "${RED}F: $F_SIM_UID${NC}"
        echo -e "${RED}B: $SIM_UID${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][SIM_UID: FILE -> $F_SIM_UID DB -> $SIM_UID значения не совпали]" >> $LOG
    fi
((i++))
if [ "$i" -ge "$COUNTERS" ]; then
        exit 0
fi

# 3 GSM_LEVEL
sleep 0.1
export PGPASSWORD=$Password
GSM_LEVEL=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "SELECT value FROM info_params.device_info_params
where device_id = $device_id and attribute_id = 32;")
unset PGPASSWORD
F_GSM_LEVEL="${arr[$i]}"
if [[ "$F_GSM_LEVEL" != "99" ]]; then
    F_GSM_LEVEL=$((-113 + $F_GSM_LEVEL * 2))
fi
    if [[ "$F_GSM_LEVEL" == "$GSM_LEVEL" ]]; then
        echo "GSM_LEVEL"
        echo -e "${GREEN}F: $F_GSM_LEVEL${NC}"
        echo -e "${GREEN}B: $GSM_LEVEL${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][GSM_LEVEL: FILE -> $F_GSM_LEVEL DB -> $GSM_LEVEL значения совпали]" >> $LOG
    else
        echo "GSM_LEVEL"
        echo -e "${RED}F: $F_GSM_LEVEL${NC}"
        echo -e "${RED}B: $GSM_LEVEL${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][GSM_LEVEL: FILE -> $F_GSM_LEVEL DB -> $GSM_LEVEL значения не совпали]" >> $LOG
    fi
((i++))
if [ "$i" -ge "$COUNTERS" ]; then
        exit 0
fi

# 4 SIM_BALANCE
sleep 0.1
export PGPASSWORD=$Password
SIM_BALANCE=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "SELECT value FROM info_params.device_info_params
where device_id = $device_id and attribute_id = 47;")
unset PGPASSWORD
F_SIM_BALANCE=$(echo "${arr[$i]}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    if [[ "$F_SIM_BALANCE" == "$SIM_BALANCE" ]]; then
        echo "SIM_BALANCE"
        echo -e "${GREEN}F: $F_SIM_BALANCE${NC}"
        echo -e "${GREEN}B: $SIM_BALANCE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][SIM_BALANCE: FILE -> $F_SIM_BALANCE DB -> $SIM_BALANCE значения совпали]" >> $LOG
    else
        echo "SIM_BALANCE"
        echo -e "${RED}F: $F_SIM_BALANCE${NC}"
        echo -e "${RED}B: $SIM_BALANCE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][SIM_BALANCE: FILE -> $F_SIM_BALANCE DB -> $SIM_BALANCE значения не совпали]" >> $LOG
    fi
((i++))
if [ "$i" -ge "$COUNTERS" ]; then
        exit 0
fi

# 5 MODEM_IMEI
sleep 0.1
export PGPASSWORD=$Password
MODEM_IMEI=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "SELECT value FROM info_params.device_info_params
where device_id = $device_id and attribute_id = 51;")
unset PGPASSWORD
F_MODEM_IMEI=$(echo "${arr[$i]}" | sed 's/[[:space:]]*$//')
    if [[ "$F_MODEM_IMEI" == "$MODEM_IMEI" ]]; then
        echo "MODEM_IMEI"
        echo -e "${GREEN}F: $F_MODEM_IMEI${NC}"
        echo -e "${GREEN}B: $MODEM_IMEI${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][MODEM_IMEI: FILE -> $F_MODEM_IMEI DB -> $MODEM_IMEI значения совпали]" >> $LOG
    else
        echo "MODEM_IMEI"
        echo -e "${RED}F: $F_MODEM_IMEI${NC}"
        echo -e "${RED}B: $MODEM_IMEI${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][MODEM_IMEI: FILE -> $F_MODEM_IMEI DB -> $MODEM_IMEI значения не совпали]" >> $LOG
    fi
((i++))
if [ "$i" -ge "$COUNTERS" ]; then
        exit 0
fi

# 6 GSM_CODE
sleep 0.1
export PGPASSWORD=$Password
GSM_CODE=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "SELECT value FROM info_params.device_info_params
where device_id = $device_id and attribute_id = 149;")
unset PGPASSWORD
F_GSM_CODE="${arr[$i]}"
    if [[ "$F_GSM_CODE" == "$GSM_CODE" ]]; then
        echo "GSM_CODE"
        echo -e "${GREEN}F: $F_GSM_CODE${NC}"
        echo -e "${GREEN}B: $GSM_CODE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][GSM_CODE: FILE -> $F_GSM_CODE DB -> $GSM_CODE значения совпали]" >> $LOG
    else
        echo "GSM_CODE"
        echo -e "${RED}F: $F_GSM_CODE${NC}"
        echo -e "${RED}B: $GSM_CODE${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][GSM_CODE: FILE -> $F_GSM_CODE DB -> $GSM_CODE значения не совпали]" >> $LOG
    fi
((i++))
if [ "$i" -ge "$COUNTERS" ]; then
        exit 0
fi

# 7 GEOLOCATION
sleep 0.1
export PGPASSWORD=$Password
GEOLOCATION=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "select value from info_params.sim_info_params as si
join dicts.attributes_dict as ad on ad.id=si.attribute_id
join devices_custs.device_sim as ds on ds.id=si.sim_id
where ds.device_id=$device_id and attribute_id=122;")
unset PGPASSWORD
F_GEOLOCATION=$(echo "${arr[$i]}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    if [[ "$F_GEOLOCATION" == "$GEOLOCATION" ]]; then
        echo "GEOLOCATION"
        echo -e "${GREEN}F: $F_GEOLOCATION${NC}"
        echo -e "${GREEN}B: $GEOLOCATION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][GEOLOCATION: FILE -> $F_GEOLOCATION DB -> $GEOLOCATION значения совпали]" >> $LOG
    else
        echo "GEOLOCATION"
        echo -e "${RED}F: $F_GEOLOCATION${NC}"
        echo -e "${RED}B: $GEOLOCATION${NC}"
        echo "---------------------------"
        # запись в log
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][GEOLOCATION: FILE -> $F_GEOLOCATION DB -> $GEOLOCATION значения не совпали]" >> $LOG
    fi
((i++))
if [ "$i" -ge "$COUNTERS" ]; then
        exit 0
fi

fi
