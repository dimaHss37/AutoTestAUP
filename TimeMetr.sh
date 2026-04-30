#!/bin/bash

NAME_MODUL="TimeMetr"
ACTIVE_DIR=$(dirname "$0")
#принудительно создаём директори
mkdir $ACTIVE_DIR/log 2>/dev/null
#формируем имя и путь лог файла
DATE_STR=$(date +"%d_%m_%Y")
TIME_STR=$(date +"%H:%M:%S")
F_LOG="/log/TimeMetr_$DATE_STR.log"
LOG="$ACTIVE_DIR$F_LOG"
FILE_LOG_WatcherService=$(find /opt -type f -name "SGS_AUP_WatcherService_$DATE_STR.log" 2>/dev/null | grep log/SGS_AUP_WatcherService_$DATE_STR.log)
DATE_STR=$(date +"%d.%m.%Y")


function TestSystemPre()
{
IN_DIR=$(find /opt -type d -name "In" 2>/dev/null | grep Arc/In) # Папка, куда копируем
DATE_STR=$(date +"%d_%m_%Y")
FILE_LOG_WatcherService=$(find /opt -type f -name "SGS_AUP_WatcherService_$DATE_STR.log" 2>/dev/null | grep Log/SGS_AUP_WatcherService_$DATE_STR.log)
FILE_LOG_DbWriterService=$(find /opt -type f -name "DBWM_$DATE_STR.log" 2>/dev/null | grep DBWM_$DATE_STR.log)
FILE_SGS_JSON=$(find /opt -type f -name "sgs.json" 2>/dev/null)
ACTIVE_DIR=$(dirname "$0")
mkdir $ACTIVE_DIR/log 2>/dev/null
F_LOG="/Log/${NAME_MODUL}_$DATE_STR.log"
LOG="$ACTIVE_DIR$F_LOG"
# Папка, откуда берем файлы
SOURCE_DIR="/media/sf_/RDT"
NAME_MODUL="TestSystem"
Sgsjson=0
ind=0

    clear
    echo ""
    echo ""
    echo -e "\tПредварительная проверка системы"
    echo ""
    echo "" >> $LOG
    echo "" >> $LOG
    sleep 0.1
    DATE_STR=$(date +"%d.%m.%Y")
    #проверка статуса SGS_AUP_DbWriterService.service
            SERVICE_NAME="SGS_AUP_DbWriterService.service"
            STATUS=$(systemctl is-active "$SERVICE_NAME")
            if [ "$STATUS" = "active" ]; then
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME запущен]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][$SERVICE_NAME запущен]"
            else
                ind=1
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME не запущен]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен]"
            fi

    sleep 0.1
    #проверка статуса SGS_AUP_SmtHandler.service
            SERVICE_NAME="SGS_AUP_SMTHandler.service"
            STATUS=$(systemctl is-active "$SERVICE_NAME")
            if [ "$STATUS" = "active" ]; then
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME запущен]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][$SERVICE_NAME запущен]"
            else
                ind=1
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME не запущен]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен]"
            fi

    sleep 0.1
    #проверка статуса SGS_AUP_ValidatorService.service
            SERVICE_NAME="SGS_AUP_ValidatorService.service"
            STATUS=$(systemctl is-active "$SERVICE_NAME")
            if [ "$STATUS" = "active" ]; then
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME запущен]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][$SERVICE_NAME запущен]"
            else
                ind=1
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME не запущен]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен]"
            fi

    sleep 0.1
    #проверка статуса SGS_AUP_WatcherService.service
            SERVICE_NAME="SGS_AUP_WatcherService.service"
            STATUS=$(systemctl is-active "$SERVICE_NAME")
            if [ "$STATUS" = "active" ]; then
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME запущен]" >> $LOG
            echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][$SERVICE_NAME запущен]"
            else
                ind=1
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][$SERVICE_NAME не запущен.]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][$SERVICE_NAME не запущен]"
            fi

    sleep 0.1
    # Проверяем, был ли найден путь к логу WatcherService
            if [ -z "$FILE_LOG_WatcherService" ]; then
                ind=1
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Лог файл WatcherService не найден]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Лог файл WatcherService не найден]"
            else
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Лог файл WatcherService найден]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][Лог файл WatcherService найден]"
            fi

    sleep 0.1
    # Проверяем, был ли найден путь к папке логу DbWriterService
            if [ -z "$FILE_LOG_DbWriterService" ]; then
                ind=1
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Лог файл DbWriterService не найден]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Лог файл DbWriterService не найден]"
            else
                TIME_STR=$(date +"%H:%M:%S")
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Лог файл DbWriterService найден]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][Лог файл DbWriterService найден]"
            fi

    sleep 0.1
    # Проверяем, был ли найден файл настроек sgs.json
    if [ -z "$FILE_SGS_JSON" ]; then
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Файл настроек sgs.json не найден]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Файл настроек sgs.json не найден]"
        Sgsjson=1
        ind=1
    else
        TIME_STR=$(date +"%H:%M:%S")
        echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Файл настроек sgs.json найден]" >> $LOG
        echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][Файл настроек sgs.json найден]"
    fi

    # Проверяем подключение к БД
    sleep 0.1
    if [[ -n "$FILE_SGS_JSON" && $Sgsjson != 1 ]]; then
        DatabaseLocation=$(cat $FILE_SGS_JSON | jq -r '.AUPService.SGS_AUP_DbWriterService.DatabaseLocation')
        if [ "$DatabaseLocation" == "Local" ]; then
            DatabaseType=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.DatabaseType')
            if [ "$DatabaseType" == "PostgreSQL" ]; then
                Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Name')
                Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Host')
                Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Port')
                Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Login')
                Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Password')
            else
                Sgsjson=1
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
                    Sgsjson=1
                fi
            else
                Sgsjson=1
            fi
        fi
        if [[ "$DatabaseType" == "PostgreSQL" && $Sgsjson != 1 ]]; then
            export PGPASSWORD=$Password
            Connection_DB=$(psql -U $Login -h $Host -p $Port -d $Name -tA -c "\l" 2>/dev/null | grep $Name)
            unset PGPASSWORD
            if [ -z "$Connection_DB" ]; then
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Нет подключения к базе данных '$Name']" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Нет подключения к базе данных '$Name']"
                ind=1
            else
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Подключение к базе данных '$Name' успешно]" >> $LOG
                echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][Подключение к базе данных '$Name' успешно]"
            fi
        fi
    fi

sleep 0.1
# Проверяем, был ли найден путь к папке "In"
if [ -z "$IN_DIR" ]; then
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Директория "In" не найдена.]" >> $LOG
    echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Директория "In" не найдена]"
    ind=1
else
    TIME_STR=$(date +"%H:%M:%S")
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Найдена директория "In": $IN_DIR]" >> $LOG
    echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;32mOK\033[0m][Найдена директория "In": $IN_DIR]"
fi
}

TestSystemPre

if [ $ind = 1 ]; then
    echo
    echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Система не готова к тестированию]"
    echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\033[1;31mERR\033[0m][Зевершение работы]"
    exit 0
fi

NAME_MODUL="TimeMetr"

# Папка, откуда берем файлы
SOURCE_DIR="/media/sf_/RDT"
if find $SOURCE_DIR -name *.rdt >/dev/null 2>&1; then
    echo ""
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][В директории $SOURCE_DIR обнаружены файлы RDT]" >> $LOG
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][В директории $SOURCE_DIR обнаружены файлы RDT]"
else
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][В директории $SOURCE_DIR файлы RDT не обнаружены]" >> $LOG
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][В директории $SOURCE_DIR файлы RDT не обнаружены]"
    exit 0
fi

echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Старт теста скорости обработки файлов]" >> $LOG
TIME_STR=$(date +"%H:%M:%S")
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][Останавливаем SGS_AUP_WatcherService]"

sudo systemctl stop SGS_AUP_WatcherService.service

TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][SGS_AUP_WatcherService остановлен]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][SGS_AUP_WatcherService остановлен]"

# папка куда копируем файлы
IN_DIR=$(find /opt -type d -name "In" 2>/dev/null | grep Arc/In) # Папка, куда копируем

read -p "Введите количество копируемых файлов: " TOTAL_FILES_CP

TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Начало копирования $TOTAL_FILES_CP файлов]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][Копирование $TOTAL_FILES_CP файлов...]"

#копируем определённое количество рандомных файлов
find $SOURCE_DIR -maxdepth 1 -type f | shuf | head -n $TOTAL_FILES_CP | xargs cp -t $IN_DIR 2>/dev/null

TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Копирование $TOTAL_FILES_CP файлов завершено]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][Копирование $TOTAL_FILES_CP файлов завершено]"
sleep 1
TIME_STR=$(date +"%H:%M:%S")
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][Старт SGS_AUP_WatcherService]"

sudo systemctl start SGS_AUP_WatcherService.service

TIME_STR=$(date +"%H:%M:%S")
#TIMESTAMP=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][SGS_AUP_WatcherService запущен]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][SGS_AUP_WatcherService запущен]"
sleep 2
TIME_START=$(date +%s)
TIMER=0
old_err_hand=$(tac $FILE_LOG_WatcherService | grep "не найден обработчик" | head -n 1)

# цикл для проверки
while true; do
    # -z проверяет, пустая ли строка (т.е. файлов нет)
    if [ -z "$(ls "$IN_DIR")" ]; then
        TIME_STOP=$(date +%s)
        clear
        echo "Папка $IN_DIR пуста."
        # Если нужно, чтобы команда выполнилась один раз, добавьте 'break'
        break
    else
        #записываем в переменную оставшееся количество файлов
        err_hand=$(tac $FILE_LOG_WatcherService | grep "не найден обработчик" | head -n 1)
        if [[ -n $err_hand && $old_err_hand != $err_hand ]]; then
            file_to_delete=$(echo "$err_hand" | awk -F'[' '{print $6}'| sed 's/\(.rdt\).*/\1/')
            if [ -f "${IN_DIR}/$file_to_delete" ]; then
                info=$(echo "$err_hand" | awk -F'[' '{print $7}')
                rm ${IN_DIR}/$file_to_delete
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Удалён файл $file_to_delete из директории $IN_DIR][$info" >> $LOG
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Удалён файл $file_to_delete из директории $IN_DIR][$info" >> $ACTIVE_DIR/tmp/del_files.tmp
            fi
        fi
        REM=$(ls -1 $IN_DIR | wc -l)
        PROG=$(echo "100 / $TOTAL_FILES_CP * $REM" | bc -l)
        PROG=$(printf "%.0f" "$PROG" 2>/dev/null)
        PROG=$((100 - PROG))
        ((TIMER++))
        TIMERS=$(date -u -d "@$TIMER" +%H:%M:%S)
        clear
        echo -e "Обработано: $PROG%/$REM файлов\tЗатраченное время: $TIMERS"
        echo "В папке $IN_DIR есть файлы. Обработка..."
        old_err_hand=$err_hand
    fi
    # Пауза перед следующей проверкой
    sleep 1
done
echo ""
TIME=$((TIME_STOP - TIME_START))
TIME_FORMAT=$(date -u -d "@$TIME" +%H:%M:%S)
TIME_SPEAD=$(echo "$TOTAL_FILES_CP / $TIME * 60" | bc -l)
TIME_SPEAD=$(printf "%g\n" "$TIME_SPEAD" 2>/dev/null)
MAX_TIME=$(cat $FILE_LOG_WatcherService | awk '/Мониторинг/ {content=""; next} {content = content $0 ORS} END {printf "%s", content}' | grep "Время обработки" | awk '{print $3}' | sort | tail -n 1)
MIN_TIME=$(cat $FILE_LOG_WatcherService | awk '/Мониторинг/ {content=""; next} {content = content $0 ORS} END {printf "%s", content}' | grep "Время обработки" | awk '{print $3}' | sort | head -n 1)
QUANTITY_OW=$(cat $FILE_LOG_WatcherService | awk '/Мониторинг/ {content=""; next} {content = content $0 ORS} END {printf "%s", content}' | grep "Arc/Out/OW" | wc -l)
OW=$(cat $FILE_LOG_WatcherService | awk '/Мониторинг/ {content=""; next} {content = content $0 ORS} END {printf "%s", content}' | grep "Arc/Out/OW" | awk -F ']' '{print $5}' | sed 's/^.//')

TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Обработано $TOTAL_FILES_CP файлов]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Затраченое время на обработку $TIME_FORMAT]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Средняя скорость обработки: $TIME_SPEAD файлов в минуту]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Максимальное время обработки файла: $MAX_TIME]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Минимальное время обработки файла: $MIN_TIME]" >> $LOG
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Количество файлов перемещённых в директорию OW: $QUANTITY_OW]" >> $LOG
echo "-------------------------------------------------------------------------" >> $LOG
echo "" >> $LOG
echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\e[1mОбработано $TOTAL_FILES_CP файлов\e[0m]"
echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\e[1mЗатраченое время на обработку $TIME_FORMAT\e[0m]"
echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\e[1mСредняя скорость обработки: $TIME_SPEAD файлов в минуту\e[0m]"
echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\e[1mМаксимальное время обработки файла: $MAX_TIME\e[0m]"
echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\e[1mМинимальное время обработки файла: $MIN_TIME\e[0m]"
echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\e[1mКоличество файлов перемещённых в директорию OW: $QUANTITY_OW\e[0m]"
echo "$ACTIVE_DIR/tmp/del_files.tmp"
rm $ACTIVE_DIR/tmp/del_files.tmp

if [ "$QUANTITY_OW" -gt 0 ]; then
    echo ""
    echo ""
    echo -e "\e[1m1. Вывести список файлов перемещённых в директорию OW\e[0m"
    echo -e "\e[1m2. Запустить заново\e[0m"
    echo -e "\e[1m3. Главное меню\e[0m"
    echo -e "\e[1m4. Выход\e[0m"
    echo ""
    read -p "Введите номер опции (1-4): " choice

    case $choice in
    1)
        echo ""
        echo "$OW"
        ;;
    2)
        $ACTIVE_DIR/TimeMetr.sh
        ;;
    3)
        $ACTIVE_DIR/Menu_v0.1.sh
        ;;
    4)
        echo "Завершение работы."
        exit 0
        ;;
    *)
        echo "Ошибка: Неправильный ввод."
        ;;
    esac

else
    echo ""
    echo ""
    echo -e "\e[1m1. Запустить заново\e[0m"
    echo -e "\e[1m2. Главное меню\e[0m"
    echo -e "\e[1m3. Выход\e[0m"
    echo ""
    read -p "Введите номер опции (1-3): " choice

    case $choice in
    1)
        $ACTIVE_DIR/TimeMetr.sh
        ;;
    2)
        $ACTIVE_DIR/Menu_v0.1.sh
        ;;
    3)
        echo "Завершение работы."
        exit 0
        ;;
    *)
        echo "Ошибка: Неправильный ввод."
        ;;
    esac

fi

# - 29.12.25
# - Добавлена средняя скорость обработки файлов за минуту.
# - принудительно создаём директори
# - 12.02.26
# - Добавлена средняя скорость обработки
# - Добавлена максимальное время обработки файла
# - Добавлена минимальное время обработки файла
# - Добавлено количество файлов перемещённых в директорию OW
# - Добавлен список файлов перемещённых в директорию OW
