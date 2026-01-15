#!/bin/bash

ACTIVE_DIR=$(dirname "$0")

#запускаем TestSystemPre.sh
$ACTIVE_DIR/TestSystemPre.sh
    #принудительно создаём директори
    mkdir $ACTIVE_DIR/Log 2>/dev/null
    # Ищем папку "In", куда будем копировать файл
    IN_DIR=$(find /opt -type d -name "In" 2>/dev/null | grep Arc/In) # Папка, куда копируем
    # Получаем дату
    DATE_STR=$(date +"%d_%m_%Y")
    #ищем DbWriterService.log актуальной даты
    FILE_LOG_DbWriterService=$(find /opt -type f -name "DBWM_$DATE_STR.log" 2>/dev/null | grep DBWM_$DATE_STR.log)
    #ищем WatcherService.log актуальной даты
    FILE_LOG_WatcherService=$(find /opt -type f -name "WatcherService_$DATE_STR.log" 2>/dev/null | grep Log/WatcherService_$DATE_STR.log)
    #формируем имя и путь лог файла
    F_LOG="/Log/CopyRandomFile_$DATE_STR.log"
    LOG="$ACTIVE_DIR$F_LOG"
    # Папка, откуда берем файлы
    SOURCE_DIR="/home/user/rdt"

    
#индекс цыкла
IND=0

echo "" # Перевод строки
#количество итераций
read -p "Укажите количество копируемых файлов: " IT

while [[ ! $IT =~ ^[+-]?[0-9]+$ ]]; do
    echo "Значение '$IT' не является целым числом."
    echo ""
    read -p "Укажите количество копируемых файлов: " IT
done

#интервал между копированием
read -p "Укажите интервал между копированием в секундах (минимальное значение 5 секунд): " INT

while [[ ! $INT =~ ^[+-]?[0-9]+$ ]]; do
    echo "Значение '$INT' не является целым числом."
    echo ""
    read -p "Укажите интервал между копированием в секундах (минимальное значение 5 секунд): " INT
done

if [ $INT -lt 5 ]; then
    INT=5
fi
echo "" # Перевод строки


while [ $IND -lt $IT ]; do
    # Дата и время
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    # Получаем список всех файлов в исходной папке
    # Исключаем папки, если они есть
    # Затем выбираем один случайный файл
    RANDOM_FILE=$(find "$SOURCE_DIR" -maxdepth 1 -type f | shuf -n 1)

    # Проверяем, был ли найден файл
        if [ -z "$RANDOM_FILE" ]; then
            # Дата и время
            DATE_STR=$(date +"%d.%m.%Y")
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][CopyRandomFile][В папке $SOURCE_DIR не найдены файлы.]" >> $LOG
        fi

    # Получаем имя файла
    FILENAME=$(basename "$RANDOM_FILE")
    # Копируем файл
    cp "$RANDOM_FILE" "$IN_DIR"

    # Дата и время
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    #пишем в log операцию копирования
    echo "[$DATE_STR][$TIME_STR][CopyRandomFile][Скопирован файл: $FILENAME в $IN_DIR]" >> $LOG
        
    #пауза, ждём пока обработается файл
    sleep $INT #интервал

        
    ERRORS=$(cat $FILE_LOG_WatcherService | grep -i 'error\|ошибка\|не обрабатываются' | awk "/$TIME_STR/ {f=1} f")
    if [ -z "$ERRORS" ]; then
      #оставляем только строки содержащие "error", "ошибка", "не обрабатываются" и записываем во временный файл .errors.tmp
      cat $FILE_LOG_WatcherService | grep -i 'error\|ошибка\|не обрабатываются' | awk "/$TIME_STR/ {f=1} f" >> $ACTIVE_DIR/.errors.tmp
      #выводим из лога DBWM что запись успешна
      READ_BD=$(tac $FILE_LOG_DbWriterService | grep -m 1 "Запись в БД завершена успешно" | grep -o "Запись.*")
      echo "[$DATE_STR][$TIME_STR][DbWriterService][$READ_BD]" >> $LOG
      #выводими в консоль информацию из лога, подсвечиваем новые записи в БД зелёным цветом
      awk "/$TIME_STR/ {f=1} f" $LOG | sed '/error/s/.*/\o033[31m&\o033[0m/' | sed '/ошибка/s/.*/\o033[31m&\o033[0m/' | sed '/readout/s/.*/\o033[31m&\o033[0m/' | sed '/Запись/s/.*/\o033[32m&\o033[0m/'
    else
      echo "$ERRORS" >> $LOG
      #выводими в консоль информацию из лога
      awk "/$TIME_STR/ {f=1} f" $LOG | sed '/error/s/.*/\o033[31m&\o033[0m/' | sed '/ошибка/s/.*/\o033[31m&\o033[0m/' | sed '/readout/s/.*/\o033[31m&\o033[0m/'
      ERRORS=""
    fi

    # Увеличиваем счетчик
    ((IND++))
done

echo "-------------------------------------------------------------------------" >> $LOG
echo "" >> $LOG

#удаляем временный файл .errors.tmp
rm $ACTIVE_DIR/.errors.tmp

echo ""
echo ""
echo -e "\e[1m1. Запустить заново\e[0m"
echo -e "\e[1m2. Главное меню\e[0m"
echo -e "\e[1m3. Выход\e[0m"
echo ""
read -p "Введите номер опции (1-3): " choice

case $choice in
  1)
    $ACTIVE_DIR/CopyRandomFile_v0.3a.sh
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



# 29.12.25
# - добавлен вывод в консоль вывод  об успешной записи в БД из лога "DbWriterService" (зелёным цветом)
# - принудительное создание папки "Log"
#
