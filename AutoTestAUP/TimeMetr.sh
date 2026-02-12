#!/bin/bash

export NAME_MODUL="TimeMetr"
ACTIVE_DIR=$(dirname "$0")
#принудительно создаём директори
mkdir $ACTIVE_DIR/Log 2>/dev/null
#формируем имя и путь лог файла
DATE_STR=$(date +"%d_%m_%Y")
TIME_STR=$(date +"%H:%M:%S")
F_LOG="/Log/TimeMetr_$DATE_STR.log"
LOG="$ACTIVE_DIR$F_LOG"
FILE_LOG_DbWriterService=$(find /opt -type f -name "DBWM_$DATE_STR.log" 2>/dev/null | grep DBWM_$DATE_STR.log)
FILE_LOG_WatcherService=$(find /opt -type f -name "WatcherService_$DATE_STR.log" 2>/dev/null | grep Log/WatcherService_$DATE_STR.log)

#запускаем TestSystemPre.sh
$ACTIVE_DIR/TestSystemPre.sh

DATE_STR=$(date +"%d.%m.%Y")
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][Старт теста скорости обработки файлов]" >> $LOG


echo ""
TIME_STR=$(date +"%H:%M:%S")
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][Останавливаем AUP-WatcherService]"

sudo systemctl stop AUP-WatcherService.service

TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][AUP-WatcherService остановлен]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][AUP-WatcherService остановлен]"

# Папка, откуда берем файлы
SOURCE_DIR="/media/sf_/RDT"
#папка куда копируем файлы
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

sleep 2

TIME_STR=$(date +"%H:%M:%S")
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][Старт AUP-WatcherService]"

sudo systemctl start AUP-WatcherService.service

TIME_STR=$(date +"%H:%M:%S")
#TIMESTAMP=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][AUP-WatcherService запущен]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][$NAME_MODUL][AUP-WatcherService запущен]"
sleep 2
TIME_START=$(date +%s)
TIMER=0


# Бесконечный цикл для проверки
while true; do
    # Проверяем, есть ли файлы в папке
    # -z проверяет, пустая ли строка (т.е. файлов нет)
    if [ -z "$(ls "$IN_DIR")" ]; then
        TIME_STOP=$(date +%s)
        clear
        echo "Папка $IN_DIR пуста."

        # Если нужно, чтобы команда выполнилась один раз и скрипт завершился,
        # добавьте 'break'
        break
    else
        #записываем в переменную оставшееся количество файлов
        REM=$(ls -1 $IN_DIR | wc -l)
        PROG=$(echo "100 / $TOTAL_FILES_CP * $REM" | bc -l)
        PROG=$(printf "%.0f" "$PROG" 2>/dev/null)
        PROG=$((100 - PROG))
        ((TIMER++))
        TIMERS=$(date -u -d "@$TIMER" +%H:%M:%S)
        clear
        echo "Обработано $PROG%      $TIMERS"
        echo "В папке $IN_DIR есть файлы. Обработка..."
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
echo -e "[$DATE_STR][$TIME_STR][$NAME_MODUL][\e[1mКоличество файлов перемещённых в директорию OW: $QUANTITY_OW\e[0m]" >> $LOG


if [ $QUANTITY_OW > 0 ]; then
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
