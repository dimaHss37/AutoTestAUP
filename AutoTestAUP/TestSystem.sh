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
    # назватие модуля
    MODULE_NAME="TestSystem"
    #формируем имя и путь лог файла
    F_LOG="/Log/TestSystem_$DATE_STR.log"
    LOG="$ACTIVE_DIR$F_LOG"
    # Папка, откуда берем файлы
    SOURCE_DIR="/media/sf_/RDT"

echo ""
echo ""
#проверка статуса AUP-DbWriterService.service
        SERVICE_NAME="AUP-DbWriterService.service"
        STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS_DBS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        sleep 0.3
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен.]"
            sleep 0.3
        fi

#проверка статуса AUP-SmtHandler.service
        SERVICE_NAME="AUP-SmtHandler.service"
        STATUS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        sleep 0.3
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен.]"
            sleep 0.2
        fi

#проверка статуса AUP-ValidatorService.service
        SERVICE_NAME="AUP-ValidatorService.service"
        STATUS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        sleep 0.3
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен.]"
            sleep 0.2
        fi

#проверка статуса AUP-WatcherService.service
        SERVICE_NAME="AUP-WatcherService.service"
        STATUS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        sleep 0.3
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен.]"
            sleep 0.2
        fi

#проверка статуса postgresql.service
        SERVICE_NAME="postgresql.service"
        STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS_DBS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        sleep 0.3
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;33mATT\033[0m][$SERVICE_NAME не запущен.]"
            sleep 0.3
        fi

#проверка статуса firebird.service
        SERVICE_NAME="firebird.service"
        STATUS_DBS=$(systemctl is-active "$SERVICE_NAME")
        if [ "$STATUS_DBS" = "active" ]; then
        DATE_STR=$(date +"%d.%m.%Y")
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME запущен.]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][$SERVICE_NAME запущен.]"
        sleep 0.3
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$SERVICE_NAME не запущен.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[\033[1;33mATT\033[0m][$SERVICE_NAME не запущен.]"
            sleep 0.3
        fi

# Проверяем, был ли найден путь к логу WatcherService
        if [ -z "$FILE_LOG_WatcherService" ]; then
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Лог файл WatcherService не найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][Лог файл WatcherService не найден.]"
            sleep 0.2
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Лог файл WatcherService найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][Лог файл WatcherService найден.]"
            sleep 0.2
        fi

# Проверяем, был ли найден путь к папке логу DbWriterService
        if [ -z "$FILE_LOG_DbWriterService" ]; then
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Лог файл DbWriterService не найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][Лог файл DbWriterService не найден.]"
            sleep 0.2
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Лог файл DbWriterService найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][Лог файл DbWriterService найден.]"
            sleep 0.3
        fi
# Проверяем подключение к локальной/глобальной сети
        #ping -c 1 -W 2 8.8.8.8 > /dev/null && echo "Интернет есть" || echo "Нет интернета"



# Проверяем подключение к БД
    #проеряем работает ли AUP-DbWriterService.service и нашёлся ли лог, если нет то выводим сообщение о том что нет инф. о подключении
if [[ "$STATUS_DBS" = "activating" || -z "$FILE_LOG_DbWriterService" ]]; then
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Нет информации о подключении к БД.]" >> $LOG
    echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][Нет информации о подключении к БД.]"
    sleep 0.2
else

       DB_CONECT_STATUS=$(tac $FILE_LOG_DbWriterService | grep -E "установлено|не удалось подключиться" | head -n 1 | grep установлено)
        if [ -z "$DB_CONECT_STATUS" ]; then
        # если подключения нет
            DB_ERR=$(tac $FILE_LOG_DbWriterService | grep -E "установлено|не удалось подключиться" | head -n 1 | grep -o 'Ошибка.*' | grep -o '.*)')
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$DB_ERR.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][$DB_ERR.]"
            sleep 0.2
        else
            # если подключения есть
            DB_FB_PSQL=$(tac $FILE_LOG_DbWriterService | grep -m 1 "установлено" | grep -o 'Подключение.*' | grep -o '.*установлено' | grep -o "Firebird")
            if [ -z "$DB_FB_PSQL" ]; then
                # если PostgreSQL
                DB_OK=$(tac $FILE_LOG_DbWriterService | grep -m 1 "установлено" | grep -o 'Подключение.*' | grep -o '.*установлено')
                DATE_STR=$(date +"%d.%m.%Y")
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$DB_OK.]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][$DB_OK.]"
                sleep 0.3
            else
                # если Firebird
                # подключение к SGS
                DB_OK=$(tac $FILE_LOG_DbWriterService | grep -m 2 "установлено" | grep -o 'Подключение.*' | grep -o '.*установлено' | sed -n '2p')
                DATE_STR=$(date +"%d.%m.%Y")
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$DB_OK.]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][$DB_OK.]"
                sleep 0.3
                # подключение к TMR
                DB_OK=$(tac $FILE_LOG_DbWriterService | grep -m 1 "установлено" | grep -o 'Подключение.*' | grep -o '.*установлено' | sed -n '1p')
                DATE_STR=$(date +"%d.%m.%Y")
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][$DB_OK.]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][$DB_OK.]"
                sleep 0.3
            fi
        fi
fi

# Проверяем, был ли найден файл настроек sgs.json
        if [ -z "$FILE_SGS_JSON" ]; then
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Файл настроек sgs.json не найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][Файл настроек sgs.json не найден.]"
            sleep 0.2
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Файл настроек sgs.json найден.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][Файл настроек sgs.json найден.]"
            sleep 0.2
        fi

# Проверяем, был ли найден путь к папке "In"
        if [ -z "$IN_DIR" ]; then
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Директория "In" не найдена.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;31mERR\033[0m][Директория "In" не найдена.]"
            sleep 0.2
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Найдена директория "In": $IN_DIR]" >> $LOG
            echo -e  "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][Найдена директория "In": $IN_DIR]"
            sleep 0.2
        fi

# проверяем релиз ОС
        OS_REL=$(cat /etc/os-release | grep PRETTY_NAME | grep -o '".*.*"' | grep RED)
        OS=$(cat /etc/os-release | grep PRETTY_NAME | grep -o '".*.*"')
        if [ -z "$OS_REL" ]; then
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Установлена система $OS. Совместимость не гарантирована.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;33mATT\033[0m][Установлена система $OS. Совместимость не гарантирована.]"
            sleep 0.2
        else
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$MODULE_NAME][Установлена система $OS.]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$MODULE_NAME][\033[1;32mOK\033[0m][Установлена система $OS.]"
            sleep 0.2
        fi
echo "----------------------------------------------------------" >> $LOG
echo "" >> $LOG
echo ""
echo ""
echo -e "\e[1m1. Запустить заново\e[0m"
echo -e "\e[1m2. Главное меню\e[0m"
echo -e "\e[1m3. Выход\e[0m"
echo ""
read -p "Введите номер опции (1-3): " choice

case $choice in
  1)
    $ACTIVE_DIR/TestSystem.sh
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

# 26.12.25
# - принудительное создание папки "Log"
# - добавлены паузы при неудачных проверках
# - ветвление в проиерке БД (если сервис dbWriter не активен, ничего не проверять, просто вывести сообщение)
# - добавлена проверка статуса firebird.service
# - добавлена проверка статуса postgresql.service