#!/bin/bash

ACTIVE_DIR=$(dirname "$0")
#принудительно создаём директори
mkdir $ACTIVE_DIR/Log 2>/dev/null
#формируем имя и путь лог файла
DATE_STR=$(date +"%d_%m_%Y")
TIME_STR=$(date +"%H:%M:%S")
F_LOG="/Log/TimeMetr_$DATE_STR.log"
LOG="$ACTIVE_DIR$F_LOG"

#запускаем TestSystemPre.sh
$ACTIVE_DIR/TestSystemPre.sh

echo "[$DATE_STR][$TIME_STR][TimeMetr][Старт теста скорости обработки файлов]" >> $LOG


echo ""
DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo -e  "[$DATE_STR][$TIME_STR][TimeMetr][Останавливаем AUP-WatcherService]"

sudo systemctl stop AUP-WatcherService.service

DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][TimeMetr][AUP-WatcherService остановлен]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][TimeMetr][AUP-WatcherService остановлен]"

# Папка, откуда берем файлы
SOURCE_DIR="/media/sf_/RDT"
#папка куда копируем файлы
IN_DIR=$(find /opt -type d -name "In" 2>/dev/null | grep Arc/In) # Папка, куда копируем

read -p "Введите количество копируемых файлов: " TOTAL_FILES_CP

DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][TimeMetr][Начало копирования $TOTAL_FILES_CP файлов]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][TimeMetr][Копирование $TOTAL_FILES_CP файлов...]"

#копируем определённое количество рандомных файлов
find $SOURCE_DIR -maxdepth 1 -type f | shuf | head -n $TOTAL_FILES_CP | xargs cp -t $IN_DIR 2>/dev/null

DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][TimeMetr][Копирование $TOTAL_FILES_CP файлов завершено]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][TimeMetr][Копирование $TOTAL_FILES_CP файлов завершено]"

sleep 2

DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo -e  "[$DATE_STR][$TIME_STR][TimeMetr][Старт AUP-WatcherService]"

sudo systemctl start AUP-WatcherService.service

DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][TimeMetr][AUP-WatcherService запущен]" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][TimeMetr][AUP-WatcherService запущен]"
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
        echo "Папка пуста."
        
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
        echo "В папке $IN_DIR есть файлы. Ждем..."
    fi
    # Пауза перед следующей проверкой
    sleep 1
done
echo ""
TIME=$((TIME_STOP - TIME_START))
TIME_FORMAT=$(date -u -d "@$TIME" +%H:%M:%S)
TIME_SPEAD=$(echo "$TOTAL_FILES_CP / $TIME * 60" | bc -l)
TIME_SPEAD=$(printf "%g\n" "$TIME_SPEAD" 2>/dev/null)


DATE_STR=$(date +"%d.%m.%Y")
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][TimeMetr][Обработано $TOTAL_FILES_CP файлов]" >> $LOG
echo "[$DATE_STR][$TIME_STR][TimeMetr][Затраченое время на обработку $TIME_FORMAT]" >> $LOG
echo "[$DATE_STR][$TIME_STR][TimeMetr][Средняя скорость обработки: $TIME_SPEAD файлов в минуту]" >> $LOG
echo "-------------------------------------------------------------------------" >> $LOG
echo "" >> $LOG
echo -e  "[$DATE_STR][$TIME_STR][TimeMetr][\e[1mОбработано $TOTAL_FILES_CP файлов\e[0m]"
echo -e  "[$DATE_STR][$TIME_STR][TimeMetr][\e[1mЗатраченое время на обработку $TIME_FORMAT.\e[0m]"
echo -e  "[$DATE_STR][$TIME_STR][TimeMetr][\e[1mСредняя скорость обработки: $TIME_SPEAD файлов в минуту\e[0m]"


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


# - 29.12.25
# - Добавлена средняя скорость обработки файлов за минуту.
# - принудительно создаём директори