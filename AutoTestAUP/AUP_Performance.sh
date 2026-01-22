#!/bin/bash

clear
echo ""
sleep 0.15
dir="/opt/SGS_ExtraPlus/Arc"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка Arc найдена"
else
    echo -e "\e[1;31m●\e[0m Папка Arc не найдена"
fi

sleep 0.15
dir="/opt/SGS_ExtraPlus/Arc/In"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка In найдена"
else
    echo -e "\e[1;31m●\e[0m Папка In не найдена"
fi

sleep 0.15
dir="/opt/SGS_ExtraPlus/Arc/Out"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка Out найдена"
else
    echo -e "\e[1;31m●\e[0m Папка Out не найдена"
fi

sleep 0.15
dir="/opt/SGS_ExtraPlus/Arc/Out/OK"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка OK найдена"
else
    echo -e "\e[1;31m●\e[0m Папка OK не найдена"
fi

sleep 0.15
dir="/opt/SGS_ExtraPlus/Arc/Out/OW"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка OW найдена"
else
    echo -e "\e[1;31m●\e[0m Папка OW не найдена"
fi

sleep 0.15
dir="/opt/SGS_ExtraPlus/Arc/Resp"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка Resp найдена"
else
    echo -e "\e[1;31m●\e[0m Папка Resp не найдена"
fi

sleep 0.15
dir="/opt/SGS_ExtraPlus/AUP"
if [ -d "$dir" ]; then
    echo -e "\e[1;32m●\e[0m Папка AUP найдена"
else
    echo -e "\e[1;31m●\e[0m Папка AUP не найдена"
fi

sleep 0.15
file="/opt/SGS_ExtraPlus/AUP/WatcherService"
if [ -f "$file" ]; then
    echo -e "\e[1;32m●\e[0m Файл WatcherService найден"
else
    echo -e "\e[1;31m●\e[0m Файл WatcherService не найден"
fi

sleep 0.15
file="/opt/SGS_ExtraPlus/AUP/ValidatorService"
if [ -f "$file" ]; then
    echo -e "\e[1;32m●\e[0m Файл ValidatorService найден"
else
    echo -e "\e[1;31m●\e[0m Файл ValidatorService не найден"
fi

sleep 0.15
file="/opt/SGS_ExtraPlus/AUP/DbWriterService"
if [ -f "$file" ]; then
    echo -e "\e[1;32m●\e[0m Файл DbWriterService найден"
else
    echo -e "\e[1;31m●\e[0m Файл DbWriterService не найден"
fi

sleep 0.15
file="/opt/SGS_ExtraPlus/AUP/SmtHandler"
if [ -f "$file" ]; then
    echo -e "\e[1;32m●\e[0m Файл SmtHandler найден"
else
    echo -e "\e[1;31m●\e[0m Файл SmtHandler не найден"
fi

sleep 0.15
FILE_SGS_JSON="/opt/SGS_ExtraPlus/sgs.json"
if [ -f "$FILE_SGS_JSON" ]; then
    echo -e "\e[1;32m●\e[0m Файл sgs.json найден"
else
    echo -e "\e[1;31m●\e[0m Файл sgs.json не найден"
fi
sleep 0.15
#проверка статуса AUP-DbWriterService.service
SERVICE_NAME="AUP-DbWriterService.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [ "$STATUS_DBS" = "active" ]; then
    echo -e "\e[1;32m●\e[0m AUP-DbWriterService запущен"
else
    echo -e "\e[1;31m●\e[0m AUP-DbWriterService не запущен"
fi
sleep 0.15
#проверка статуса AUP-SmtHandler.service
SERVICE_NAME="AUP-SmtHandler.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [ "$STATUS_DBS" = "active" ]; then
    echo -e "\e[1;32m●\e[0m AUP-SmtHandlerService запущен"
else
    echo -e "\e[1;31m●\e[0m AUP-SmtHandlerService не запущен"
fi
sleep 0.15
#проверка статуса AUP-ValidatorService.service
SERVICE_NAME="AUP-ValidatorService.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [ "$STATUS_DBS" = "active" ]; then
    echo -e "\e[1;32m●\e[0m AUP-ValidatorService запущен"
else
    echo -e "\e[1;31m●\e[0m AUP-ValidatorService не запущен"
fi
sleep 0.15
#проверка статуса AUP-WatcherService.service
SERVICE_NAME="AUP-WatcherService.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [ "$STATUS_DBS" = "active" ]; then
    echo -e "\e[1;32m●\e[0m AUP-WatcherService запущен"
else
    echo -e "\e[1;31m●\e[0m AUP-WatcherService не запущен"
fi
sleep 0.15
if id -nG | grep -q "gazset"; then
    echo -e "\e[1;32m●\e[0m Пользователь состоит в группе 'gazset'"
else
    echo -e "\e[1;31m●\e[0m Пользователь НЕ состоит в группе 'gazset'"
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

if [[ -z "$sgs_stat" && "$DatabaseType" == "PostgreSQL" ]]; then
    sleep 0.15
    if [ -n "$DatabaseLocation" ]; then
        echo -e "\e[1;32m●\e[0m Локация базы данных '$DatabaseLocation'"
    else
        echo -e "\e[1;31m●\e[0m Локация базы данных не указана"
    fi
    sleep 0.15
    if [ -n "$DatabaseType" ]; then
        echo -e "\e[1;32m●\e[0m Тип базы данных '$DatabaseType'"
    else
        echo -e "\e[1;31m●\e[0m Тип базы данных не указан"
    fi
    sleep 0.15
    if [ -n "$Name" ]; then
        echo -e "\e[1;32m●\e[0m Имя базы данных '$Name'"
    else
        echo -e "\e[1;31m●\e[0m Имя базы данных не указано"
    fi
    sleep 0.15
    if [ -n "$Host" ]; then
        echo -e "\e[1;32m●\e[0m Хост базы данных '$Host'"
    else
        echo -e "\e[1;31m●\e[0m Хост базы данных не указан"
    fi
    sleep 0.15
    if [ -n "$Port" ]; then
        echo -e "\e[1;32m●\e[0m Порт базы данных '$Port'"
    else
        echo -e "\e[1;31m●\e[0m Порт базы данных не указан"
    fi
    sleep 0.15
    if [ -n "$Login" ]; then
        echo -e "\e[1;32m●\e[0m Логин базы данных '$Login'"
    else
        echo -e "\e[1;31m●\e[0m Логин базы данных не указан"
    fi
    sleep 0.15
    if [ -n "$Password" ]; then
        echo -e "\e[1;32m●\e[0m Пароль базы данных '$Password'"
    else
        echo -e "\e[1;31m●\e[0m Пароль базы данных не указан"
    fi
fi

# надо доработать
if [[ -z "$sgs_stat" && "$DatabaseType" == "Firebird" ]]; then
    sleep 0.15
    if [ -n "$DatabaseLocation" ]; then
        echo -e "\e[1;32m●\e[0m Локация базы данных '$DatabaseLocation'"
    else
        echo -e "\e[1;31m●\e[0m Локация базы данных не указана"
    fi
    sleep 0.15
    if [ -n "$DatabaseType" ]; then
        echo -e "\e[1;32m●\e[0m Тип базы данных '$DatabaseType'"
    else
        echo -e "\e[1;31m●\e[0m Тип базы данных не указан"
    fi
fi

if [ -n "$sgs_stat" ]; then
    echo -e "\e[1;31m●\e[0m Некорректный sgs.json"
fi

sleep 0.15
#проверка статуса postgresql.service
SERVICE_NAME="postgresql.service"
STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
if [[ "$STATUS_DBS" = "active" && "$DatabaseType" == "Firebird" ]]; then
    echo -e "\e[1;32m●\e[0m Postgresql.service запущен"
fi
if [[ "$STATUS_DBS" != "active" && "$DatabaseType" == "PostgreSQL" ]]; then
    echo -e "\e[1;31m●\e[0m Postgresql.service не запущен"
fi
if [[ "$STATUS_DBS" != "active" && "$DatabaseType" == "Firebird" ]]; then
    echo -e "\e[1;37m●\e[0m Postgresql.service не запущен"
fi
if [[ "$STATUS_DBS" = "active" && "$DatabaseType" == "PostgreSQL" ]]; then
    echo -e "\e[1;32m●\e[0m Postgresql.service запущен"
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
if [ "$DatabaseType" == "PostgreSQL" ]; then
export PGPASSWORD=$Password
Connection_DB=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "\l" 2>/dev/null | grep $Name)
unset PGPASSWORD
    if [ -z "$Connection_DB" ]; then
    echo -e "\e[1;31m●\e[0m Нет подключения к базе данных '$Name'"
    else
    echo -e "\e[1;32m●\e[0m Подключение к базе данных '$Name' успешно"
    fi
fi


# проверка подключения к базе данных Firebird
