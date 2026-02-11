#!/bin/bash

    # Ищем папку "In", куда будем копировать файл
    IN_DIR=$(find /opt -type d -name "In" 2>/dev/null | grep Arc/In) # Папка, куда копируем
    # Получаем дату
    DATE_STR=$(date +"%d_%m_%Y")
    #ищем WatcherService.log актуальной даты
    FILE_LOG_WatcherService=$(find /opt -type f -name "WatcherService_$DATE_STR.log" 2>/dev/null | grep Log/WatcherService_$DATE_STR.log)
    #ищем DbWriterService.log актуальной даты
    FILE_LOG_DbWriterService=$(find /opt -type f -name "DBWM_$DATE_STR.log" 2>/dev/null | grep DBWM_$DATE_STR.log)
    #ищем sgs.json
    FILE_SGS_JSON=$(find /opt -type f -name "sgs.json" 2>/dev/null)
    ACTIVE_DIR=$(dirname "$0")
    #принудительно создаём директори
    mkdir $ACTIVE_DIR/Log 2>/dev/null
    #формируем имя и путь лог файла
    F_LOG="/Log/${NAME_MODUL}_$DATE_STR.log"
    LOG="$ACTIVE_DIR$F_LOG"
    # Папка, откуда берем файлы
    SOURCE_DIR="/media/sf_/RDT"
    NAME_MODUL="TestSystem"

clear
echo ""
echo ""
echo -e "\tПредварительная проверка системы"
echo ""
echo "" >> $LOG
echo "" >> $LOG
sleep 0.1
#проверка статуса AUP-DbWriterService.service
        SERVICE_NAME="AUP-DbWriterService.service"
        STATUS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен.]"
        fi

sleep 0.1
#проверка статуса AUP-SmtHandler.service
        SERVICE_NAME="AUP-SmtHandler.service"
        STATUS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен.]"
        fi

sleep 0.1
#проверка статуса AUP-ValidatorService.service
        SERVICE_NAME="AUP-ValidatorService.service"
        STATUS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен.]"
        fi

sleep 0.1
#проверка статуса AUP-WatcherService.service
        SERVICE_NAME="AUP-WatcherService.service"
        STATUS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен.]"
        fi

sleep 0.1
# Проверяем, был ли найден путь к логу WatcherService
        if [ -z "$FILE_LOG_WatcherService" ]; then
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Лог файл WatcherService не найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Лог файл WatcherService не найден.]"
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Лог файл WatcherService найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][Лог файл WatcherService найден.]"
        fi

sleep 0.1
# Проверяем, был ли найден путь к папке логу DbWriterService
        if [ -z "$FILE_LOG_DbWriterService" ]; then
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Лог файл DbWriterService не найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Лог файл DbWriterService не найден.]"
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Лог файл DbWriterService найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][Лог файл DbWriterService найден.]"
        fi

# Проверяем подключение к БД
        #DB_CONECT_STATUS=$(tac $FILE_LOG_DbWriterService | grep -E "установлено|не удалось подключиться" | head -n 1)
        #DB_CONECT=$()

sleep 0.1
# Проверяем, был ли найден файл настроек sgs.json
        if [ -z "$FILE_SGS_JSON" ]; then
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Файл настроек sgs.json не найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Файл настроек sgs.json не найден.]"
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Файл настроек sgs.json найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][Файл настроек sgs.json найден.]"
        fi

sleep 0.1
# Проверяем, был ли найден путь к папке "In"
        if [ -z "$IN_DIR" ]; then
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Директория "In" не найдена.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Директория "In" не найдена.]"
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Найдена директория "In": $IN_DIR]" >> $LOG
            echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][Найдена директория "In": $IN_DIR]"
        fi
