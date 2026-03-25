#!/bin/bash

ACTIVE_DIR=$(dirname "$0")
MODULE_NAME="ComplexChecParams"
MOD="TestSystem"


# получаем текущую дату
DATE_STR=$(date +"%d_%m_%Y")
# формируем имя и путь лог файла
F_LOG="/log/${MODULE_NAME}_$DATE_STR.log"
LOG="$ACTIVE_DIR$F_LOG"
export LOG=$LOG
timestamp="$ACTIVE_DIR/tmp/.timestamp.conf"
export timestamp=$timestamp
rm $timestamp 2>/dev/null
PCid=$(cat /etc/machine-id)

clear
DATE_STR=$(date +"%d.%m.%Y")
TIME=$(date +"%H:%M:%S")
echo "[SYSTEM STATUS CHECK]" >> $timestamp
echo "TimeStart = $DATE_STR $TIME" >> $timestamp
echo "PC-id = $PCid" >> $timestamp
echo "" >> $LOG
echo "" >> $LOG
echo "------------------------------------------------------------------------" >> $LOG


echo ""
sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
dir="/opt/SGS_ExtraPlus/Arc"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка Arc найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Папка Arc найдена]" >> $LOG
    echo "DirArc = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Папка Arc не найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Папка Arc не найдена]" >> $LOG
    echo "DirArc = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
dir="/opt/SGS_ExtraPlus/Arc/In"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка In найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Папка In найдена]" >> $LOG
    echo "DirIn = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Папка In не найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Папка In не найдена]" >> $LOG
    echo "DirIn = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
dir="/opt/SGS_ExtraPlus/Arc/Out"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка Out найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Папка Out найдена]" >> $LOG
    echo "DirOut = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Папка Out не найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Папка Out не найдена]" >> $LOG
    echo "DirOut = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
dir="/opt/SGS_ExtraPlus/Arc/Out/OK"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка OK найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Папка OK найдена]" >> $LOG
    echo "DirOk = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Папка OK не найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Папка OK не найдена]" >> $LOG
    echo "DirOk = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
dir="/opt/SGS_ExtraPlus/Arc/Out/OW"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка OW найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Папка OW найдена]" >> $LOG
    echo "DirOw = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Папка OW не найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Папка OW не найдена]" >> $LOG
    echo "DirOw = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
dir="/opt/SGS_ExtraPlus/Arc/Resp"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка Resp найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Папка Resp найдена]" >> $LOG
    echo "DirResp = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Папка Resp не найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Папка Resp не найдена]" >> $LOG
    echo "DirResp = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
dir="/opt/SGS_ExtraPlus/AUP"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка AUP найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Папка AUP найдена]" >> $LOG
    echo "DirAUP = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Папка AUP не найдена"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Папка AUP не найдена]" >> $LOG
    echo "DirAUP = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
file="/opt/SGS_ExtraPlus/AUP/WatcherService"
if [ -f "$file" ]; then
    echo -e "\e[1;32m●\e[0m Файл WatcherService найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Файл WatcherService найден]" >> $LOG
    echo "WatcherService = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Файл WatcherService не найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Файл WatcherService не найден]" >> $LOG
    echo "WatcherService = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
file="/opt/SGS_ExtraPlus/AUP/ValidatorService"
if [ -f "$file" ]; then
    echo -e "\e[1;32m●\e[0m Файл ValidatorService найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Файл ValidatorService найден]" >> $LOG
    echo "ValidatorService = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Файл ValidatorService не найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Файл ValidatorService не найден]" >> $LOG
    echo "ValidatorService = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
file="/opt/SGS_ExtraPlus/AUP/DbWriterService"
if [ -f "$file" ]; then
    echo -e "\e[1;32m●\e[0m Файл DbWriterService найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Файл DbWriterService найден]" >> $LOG
    echo "DbWriterService = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Файл DbWriterService не найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Файл DbWriterService не найден]" >> $LOG
    echo "DbWriterService = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
file="/opt/SGS_ExtraPlus/AUP/SmtHandler"
if [ -f "$file" ]; then
    echo -e "\e[1;32m●\e[0m Файл SmtHandlerService найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Файл SmtHandlerService найден]" >> $LOG
    echo "SmtHandlerService = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Файл SmtHandlerService не найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Файл SmtHandlerService не найден]" >> $LOG
    echo "SmtHandlerService = 0" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
FILE_SGS_JSON="/opt/SGS_ExtraPlus/sgs.json"
if [ -f "$FILE_SGS_JSON" ]; then
    echo -e "\e[1;32m●\e[0m Файл sgs.json найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Файл sgs.json найден]" >> $LOG
    echo "SgsJson = 0" >> $timestamp
    # pars file
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
            SGS_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Name')
            SGS_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Host')
            SGS_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Port')
            SGS_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Login')
            SGS_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Password')

            TMR_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Name')
            TMR_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Host')
            TMR_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Port')
            TMR_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Login')
            TMR_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Password')

            CON_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Name')
            CON_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Host')
            CON_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Port')
            CON_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Login')
            CON_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Password')

            ALP_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Name')
            ALP_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Host')
            ALP_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Port')
            ALP_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Login')
            ALP_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Password')

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
                SGS_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Name')
                SGS_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Host')
                SGS_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Port')
                SGS_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Login')
                SGS_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Password')

                TMR_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Name')
                TMR_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Host')
                TMR_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Port')
                TMR_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Login')
                TMR_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Password')

                CON_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Name')
                CON_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Host')
                CON_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Port')
                CON_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Login')
                CON_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Password')

                ALP_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Name')
                ALP_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Host')
                ALP_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Port')
                ALP_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Login')
                ALP_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Password')
            fi
        else
            sgs_stat="Некорректный sgs.json"
        fi
    fi

else
    echo -e "\e[1;31m●\e[0m Файл sgs.json не найден"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Файл sgs.json не найден]" >> $LOG
    echo "SgsJson = 1" >> $timestamp
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
#проверка статуса AUP-DbWriterService.service
SERVICE_NAME="AUP-DbWriterService.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [ "$STATUS_DBS" = "active" ]; then
    echo -e "\e[1;32m●\e[0m AUP-DbWriterService запущен"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][AUP-DbWriterService запущен]" >> $LOG
    echo "DbWriterStatus = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m AUP-DbWriterService не запущен"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][AUP-DbWriterService не запущен]" >> $LOG
    echo "DbWriterStatus = 1" >> $timestamp
    ServiceStatus=1
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
#проверка статуса AUP-SmtHandler.service
SERVICE_NAME="AUP-SmtHandler.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [ "$STATUS_DBS" = "active" ]; then
    echo -e "\e[1;32m●\e[0m AUP-SmtHandlerService запущен"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][AUP-SmtHandlerService запущен]" >> $LOG
    echo "SmtHandlerStatus = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m AUP-SmtHandlerService не запущен"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][AUP-SmtHandlerService не запущен]" >> $LOG
    echo "SmtHandlerStatus = 1" >> $timestamp
    ServiceStatus=1
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
#проверка статуса AUP-ValidatorService.service
SERVICE_NAME="AUP-ValidatorService.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [ "$STATUS_DBS" = "active" ]; then
    echo -e "\e[1;32m●\e[0m AUP-ValidatorService запущен"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][AUP-ValidatorService запущен]" >> $LOG
    echo "ValidatorStatus = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m AUP-ValidatorService не запущен"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][AUP-ValidatorService не запущен]" >> $LOG
    echo "ValidatorStatus = 1" >> $timestamp
    ServiceStatus=1
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
#проверка статуса AUP-WatcherService.service
SERVICE_NAME="AUP-WatcherService.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [ "$STATUS_DBS" = "active" ]; then
    echo -e "\e[1;32m●\e[0m AUP-WatcherService запущен"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][AUP-WatcherService запущен]" >> $LOG
    echo "WatcherStatus = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m AUP-WatcherService не запущен"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][AUP-WatcherService не запущен]" >> $LOG
    echo "WatcherStatus = 1" >> $timestamp
    ServiceStatus=1
fi

sleep 0.15
TIME_STR=$(date +"%H:%M:%S")
if id -nG | grep -q "gazset"; then
    echo -e "\e[1;32m●\e[0m Пользователь состоит в группе 'gazset'"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Passed][Пользователь состоит в группе 'gazset']" >> $LOG
    echo "Group = 0" >> $timestamp
else
    echo -e "\e[1;31m●\e[0m Пользователь НЕ состоит в группе 'gazset'"
    echo "[$DATE_STR][$TIME_STR][$MOD][$MODULE_NAME][Failed][Пользователь НЕ состоит в группе 'gazset']" >> $LOG
    echo "Group = 1" >> $timestamp
    Grp=1
fi

if [[ -z "$sgs_stat" && "$DatabaseType" == "PostgreSQL" ]]; then
    sleep 0.15
    if [ -n "$DatabaseLocation" ]; then
        echo -e "\e[1;32m●\e[0m Локация базы данных '$DatabaseLocation'"
        echo "DBLocation = 0" >> $timestamp
    else
        echo -e "\e[1;31m●\e[0m Локация базы данных не указана"
        echo "DBLocation = 1" >> $timestamp
    fi
    sleep 0.15
    if [ -n "$DatabaseType" ]; then
        echo -e "\e[1;32m●\e[0m Тип базы данных '$DatabaseType'"
        echo "DBType = 0" >> $timestamp
    else
        echo -e "\e[1;31m●\e[0m Тип базы данных не указан"
        echo "DBType = 0" >> $timestamp
    fi
    sleep 0.15
    if [ -n "$Name" ]; then
        echo -e "\e[1;32m●\e[0m Имя базы данных '$Name'"
        echo "DBName = 0" >> $timestamp
    else
        echo -e "\e[1;31m●\e[0m Имя базы данных не указано"
        echo "DBName = 1" >> $timestamp
    fi
    sleep 0.15
    if [ -n "$Host" ]; then
        echo -e "\e[1;32m●\e[0m Хост базы данных '$Host'"
        echo "DBHost = 0" >> $timestamp
    else
        echo -e "\e[1;31m●\e[0m Хост базы данных не указан"
        echo "DBHost = 1" >> $timestamp
    fi
    sleep 0.15
    if [ -n "$Port" ]; then
        echo -e "\e[1;32m●\e[0m Порт базы данных '$Port'"
        echo "DBPort = 0" >> $timestamp
    else
        echo -e "\e[1;31m●\e[0m Порт базы данных не указан"
        echo "DBPort = 1" >> $timestamp
    fi
    sleep 0.15
    if [ -n "$Login" ]; then
        echo -e "\e[1;32m●\e[0m Логин базы данных '$Login'"
        echo "DBLogin = 0" >> $timestamp
    else
        echo -e "\e[1;31m●\e[0m Логин базы данных не указан"
        echo "DBLogin = 1" >> $timestamp
    fi
    sleep 0.15
    if [ -n "$Password" ]; then
        echo -e "\e[1;32m●\e[0m Пароль базы данных '$Password'"
        echo "DBPassword = 0" >> $timestamp
    else
        echo -e "\e[1;31m●\e[0m Пароль базы данных не указан"
        echo "DBPassword = 1" >> $timestamp
    fi
fi

# надо доработать
if [[ -z "$sgs_stat" && "$DatabaseType" == "Firebird" ]]; then
    sleep 0.15
    if [ -n "$DatabaseLocation" ]; then
        echo -e "\e[1;32m●\e[0m Локация базы данных '$DatabaseLocation'"
        echo "DBLocation = 0" >> $timestamp
    else
        echo -e "\e[1;31m●\e[0m Локация базы данных не указана"
        echo "DBLocation = 1" >> $timestamp
    fi
    sleep 0.15
    if [ -n "$DatabaseType" ]; then
        echo -e "\e[1;32m●\e[0m Тип базы данных '$DatabaseType'"
        echo "DBType = 1" >> $timestamp
    else
        echo -e "\e[1;31m●\e[0m Тип базы данных не указан"
        echo "DBType = 1" >> $timestamp
    fi
fi

if [ -f "$FILE_SGS_JSON" ]; then
    if [ -n "$sgs_stat" ]; then
        echo -e "\e[1;31m●\e[0m Некорректный sgs.json"
        echo "ErrSgsjson = 1" >> $timestamp
    fi
fi

sleep 0.15
#проверка статуса postgresql.service
SERVICE_NAME="postgresql.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [[ "$STATUS_DBS" = "active" && "$DatabaseType" == "Firebird" ]]; then
    echo -e "\e[1;32m●\e[0m Postgresql.service запущен"
    echo "PostgresqlStatus = 0" >> $timestamp
fi
if [[ "$STATUS_DBS" != "active" && "$DatabaseType" == "PostgreSQL" ]]; then
    echo -e "\e[1;31m●\e[0m Postgresql.service не запущен"
    echo "PostgresqlStatus = 1" >> $timestamp
    ServiceStatus=1
fi
if [[ "$STATUS_DBS" != "active" && "$DatabaseType" == "Firebird" ]]; then
    echo -e "\e[1;37m●\e[0m Postgresql.service не запущен"
    echo "PostgresqlStatus = 1" >> $timestamp
fi
if [[ "$STATUS_DBS" = "active" && "$DatabaseType" == "PostgreSQL" ]]; then
    echo -e "\e[1;32m●\e[0m Postgresql.service запущен"
    echo "PostgresqlStatus = 0" >> $timestamp
fi

sleep 0.15
#проверка статуса Firebird.service
SERVICE_NAME="firebird.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [[ "$STATUS_DBS" = "active" && "$DatabaseType" == "Firebird" ]]; then
    echo -e "\e[1;32m●\e[0m Firebird.service запущен"
fi
if [[ "$STATUS_DBS" != "active" && "$DatabaseType" == "PostgreSQL" ]]; then
    echo -e "\e[1;37m●\e[0m Firebird.service не запущен"
fi
if [[ "$STATUS_DBS" != "active" && "$DatabaseType" == "Firebird" ]]; then
    echo -e "\e[1;31m●\e[0m Firebird.service не запущен"
fi
if [[ "$STATUS_DBS" = "active" && "$DatabaseType" == "PostgreSQL" ]]; then
    echo -e "\e[1;32m●\e[0m Firebird.service запущен"
fi

sleep 0.15
# проверка подключения к базе данных PostgreSQL
status_PostgreSQL=$(systemctl is-active "postgresql.service")
if [[ "$DatabaseType" == "PostgreSQL" && $status_PostgreSQL = "active" ]]; then
export PGPASSWORD=$Password
Connection_DB=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "\l" 2>/dev/null | grep $Name)
unset PGPASSWORD
    if [ -z "$Connection_DB" ]; then
    echo -e "\e[1;31m●\e[0m Нет подключения к базе данных '$Name'"
    echo "DBConnection = 1" >> $timestamp
    BDCon=1
    else
    echo -e "\e[1;32m●\e[0m Подключение к базе данных '$Name' успешно"
    echo "DBConnection = 0" >> $timestamp
    fi
fi

DirArc=$(cat $timestamp | grep "DirArc" | grep -oE '[0-9]+')
DirIn=$(cat $timestamp | grep "DirIn" | grep -oE '[0-9]+')
DirOut=$(cat $timestamp | grep "DirOut" | grep -oE '[0-9]+')
DirOk=$(cat $timestamp | grep "DirOk" | grep -oE '[0-9]+')
DirOw=$(cat $timestamp | grep "DirOw" | grep -oE '[0-9]+')
DirResp=$(cat $timestamp | grep "DirResp" | grep -oE '[0-9]+')
DirAUP=$(cat $timestamp | grep "DirAUP" | grep -oE '[0-9]+')
WatcherService=$(cat $timestamp | grep "WatcherService" | grep -oE '[0-9]+')
ValidatorService=$(cat $timestamp | grep "ValidatorService" | grep -oE '[0-9]+')
DbWriterService=$(cat $timestamp | grep "DbWriterService" | grep -oE '[0-9]+')
SmtHandlerService=$(cat $timestamp | grep "SmtHandlerService" | grep -oE '[0-9]+')
SgsJson=$(cat $timestamp | grep "SgsJson" | grep -oE '[0-9]+')
DbWriterStatus=$(cat $timestamp | grep "DbWriterStatus" | grep -oE '[0-9]+')
SmtHandlerStatus=$(cat $timestamp | grep "SmtHandlerStatus" | grep -oE '[0-9]+')
ValidatorStatus=$(cat $timestamp | grep "ValidatorStatus" | grep -oE '[0-9]+')
WatcherStatus=$(cat $timestamp | grep "WatcherStatus" | grep -oE '[0-9]+')
Group=$(cat $timestamp | grep "Group" | grep -oE '[0-9]+')
DBLocation=$(cat $timestamp | grep "DBLocation" | grep -oE '[0-9]+')
DBType=$(cat $timestamp | grep "DBType" | grep -oE '[0-9]+')
DBName=$(cat $timestamp | grep "DBName" | grep -oE '[0-9]+')
DBHost=$(cat $timestamp | grep "DBHost" | grep -oE '[0-9]+')
DBPort=$(cat $timestamp | grep "DBPort" | grep -oE '[0-9]+')
DBLogin=$(cat $timestamp | grep "DBLogin" | grep -oE '[0-9]+')
DBPassword=$(cat $timestamp | grep "DBPassword" | grep -oE '[0-9]+')
PostgresqlStatus=$(cat $timestamp | grep "PostgresqlStatus" | grep -oE '[0-9]+')
DBConnection=$(cat $timestamp | grep "DBConnection" | grep -oE '[0-9]+')

if (( DirArc + DirIn + DirOut + DirOk + DirOw + DirResp + DirAUP + WatcherService + ValidatorService + DbWriterService + SmtHandlerService + SgsJson + DbWriterStatus + SmtHandlerStatus + ValidatorStatus + WatcherStatus + Group + DBLocation + DBType + DBName + DBHost + DBPort + DBLogin + DBPasswo + PostgresqlStatus + DBConnection == 0 )); then
    sleep 5
    $ACTIVE_DIR/ComplexChecParams.sh
else
    if [ "$ServiceStatus" == 1 ]; then
        echo ""
        echo ""
cat <<EOF
Для управления службами в Linux используйте команду sudo systemctl [команда] [имя_службы].
Для выполнения этих команд обычно требуются права суперпользователя (sudo).

Управление текущим состоянием:
● sudo systemctl start <name> — запустить сервис.
● sudo systemctl stop <name> — остановить сервис.
● sudo systemctl restart <name> — перезапустить сервис (полная остановка и запуск).
● sudo systemctl reload <name> — перечитать конфигурацию без полной остановки.

Управление автозагрузкой:
● sudo systemctl enable <name> — включить автоматический запуск при загрузке системы.
● sudo systemctl disable <name> — отключить автоматический запуск.

Просмотр состояния:
● systemctl status <name> — показать подробный статус сервиса и последние строки логов.
● systemctl is-active <name> — проверить, запущен ли сервис в данный момент.
● systemctl list-units --type=service — вывести список всех загруженных сервисов.
EOF
        echo ""
        echo ""
        exit 0
    fi

    if [ "$BDCon" == 1 ]; then
        echo ""
        echo ""
cat <<EOF
Основные причины, почему не удается подключиться:

1. Сервер не запущен
Симптом: Ошибка вроде Connection refused (соединение отклонено).
Что делать:
Проверьте статус службы (в Linux: sudo systemctl status postgresql).
Используйте утилиту pg_isready, чтобы быстро проверить, принимает ли сервер соединения.

2. Неверные параметры подключения
Симптом: Ошибка таймаута или «неверный порт/хост».
Что делать:
Порт: Убедитесь, что порт совпадает с указанным в postgresql.conf (стандарт — 5432).
Хост: Если вы подключаетесь удаленно, убедитесь, что указываете правильный IP-адрес, а не localhost.

3. Сервер не слушает внешние соединения
Симптом: Подключение по localhost работает, а по IP-адресу — нет.
Что делать:
В файле postgresql.conf найдите параметр listen_addresses. Он должен быть установлен в '*' или содержать IP, к которому вы обращаетесь. Если там стоит localhost, сервер принимает только локальные подключения.

4. Ограничения доступа (pg_hba.conf)
Симптом: Ошибка аутентификации или no pg_hba.conf entry for host....
Что делать:
Файл pg_hba.conf контролирует, кто и откуда может подключаться. Проверьте, есть ли там запись, разрешающая ваш IP-адрес, пользователя и базу данных. После изменения файла обязательно перезагрузите PostgreSQL.

5. Сетевые экраны (Файрвол)
Симптом: Соединение «висит» и отваливается по таймауту.
Что делать:
Проверьте файрвол на сервере (например, ufw, iptables, firewalld в Linux или Брандмауэр Windows). Порт 5432 должен быть открыт.

6. Проблемы с пользователем/паролем
Симптом: Ошибка аутентификации (Authentication failed).
Что делать:
Проверьте имя пользователя и пароль. Помните, что они чувствительны к регистру.
Убедитесь, что у пользователя есть права на доступ к конкретной базе данных.
EOF
        echo ""
        echo ""
        exit 0
    fi
if [ "$Group" == 1 ]; then
    echo ""
    echo ""
cat <<EOF
Для добавления существующего пользователя в группу в Linux используйте команду usermod -aG <группа> <пользователь>.
Опция -a` (append) обязательна, чтобы добавить пользователя к существующим группам, а не заменить их.
Для применения изменений обычно требуется перелогиниться.

Пример: "sudo usermod -aG gazset <пользователь>"
EOF
fi

fi
