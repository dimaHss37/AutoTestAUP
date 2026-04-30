#!/bin/bash


ACTIVE_DIR=$(dirname "$0")
NAME_MODUL="CopyRandomFile"
# Коды цветов
RED="\033[31m" # Красный
GREEN="\033[32m" # Зеленый
NC="\033[0m" # Без цвета (сброс)

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


NAME_MODUL="CopyRandomFile"

#принудительно создаём директори
mkdir $ACTIVE_DIR/Log 2>/dev/null
# Ищем папку "In", куда будем копировать файл
IN_DIR=$(find /opt -type d -name "In" 2>/dev/null | grep Arc/In) # Папка, куда копируем
# Получаем дату
DATE_STR=$(date +"%d_%m_%Y")
#ищем DbWriterService.log актуальной даты
FILE_LOG_DbWriterService=$(find /opt -type f -name "DBWM_$DATE_STR.log" 2>/dev/null | grep DBWM_$DATE_STR.log)
#ищем WatcherService.log актуальной даты
FILE_LOG_WatcherService=$(find /opt -type f -name "SGS_AUP_WatcherService_$DATE_STR.log" 2>/dev/null | grep Log/SGS_AUP_WatcherService_$DATE_STR.log)
# Папка, откуда берем файлы
SOURCE_DIR="/media/sf_/RDT"

# проверка существования "SOURCE_DIR" и файлов rdt в ней
if [ ! -d "$SOURCE_DIR" ]; then
    DATE_STR=$(date +"%d.%m.%Y")
    TIME_STR=$(date +"%H:%M:%S")
    echo  ""
    echo -e "${RED}[$DATE_STR][$TIME_STR][$NAME_MODUL][F][Директория $SOURCE_DIR не найдена]${NC}"
    echo -e "${RED}[$DATE_STR][$TIME_STR][$NAME_MODUL][I][Измените значение переменной 'SOURCE_DIR']${NC}"
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][I][Завершение работы]"
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][F][Директория $SOURCE_DIR не найдена]" >> $LOG
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][I][Завершение работы]" >> $LOG
    exit 0
fi

if [ -z "$(find $SOURCE_DIR -type f -iname "*.rdt" 2>/dev/null)" ]; then
    TIME_STR=$(date +"%H:%M:%S")
    echo  ""
    echo -e "${RED}[$DATE_STR][$TIME_STR][$NAME_MODUL][F][В директории $SOURCE_DIR файлы RDT не найдены]${NC}"
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][I][Завершение работы]"
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][F][В директории $SOURCE_DIR файлы RDT не найдены]" >> $LOG
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][I][Завершение работы]" >> $LOG
    exit 0
fi

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
read -p "Укажите интервал между копированием в секундах, либо введите значение a  (минимальное значение 5 секунд): " INT

if [ -z $INT ]; then
    INT="a"
    echo ""
    echo "Установлен автоматический интервал копирования."
fi

while [[ ! $INT =~ ^[0-9]+$ && $INT != "a" ]]; do
    echo "Значение '$INT' не является целым числом или "a"."
    echo ""
    read -p "Укажите интервал между копированием в секундах (минимальное значение 5 секунд): " INT
done

if [ $INT != "a" ]; then
    if [[ $INT -lt 5 ]]; then
        INT=5
        echo ""
        echo "Установлен интервал копирования: 5 секунд."
    fi
fi

echo "" # Перевод строки
TIME_STR=$(date +"%H:%M:%S")
echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][I][Начато копирование $IT файлов.]" >> $LOG

while [ $IND -lt $IT ]; do
    TIME_STR=$(date +"%H:%M:%S")
    # Получаем список всех файлов в исходной папке
    # Исключаем папки, если они есть
    # Затем выбираем один случайный файл
    RANDOM_FILE=$(find "$SOURCE_DIR" -maxdepth 1 -type f | shuf -n 1)

    # Проверяем, был ли найден файл
        if [ -z "$RANDOM_FILE" ]; then
            TIME_STR=$(date +"%H:%M:%S")
            echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][W][В папке $SOURCE_DIR не найдены файлы.]" >> $LOG
            echo -e "${RED}[$DATE_STR][$TIME_STR][$NAME_MODUL][W][В папке $SOURCE_DIR не найдены файлы.]${NC}"
            break
        fi

    # Получаем имя файла
    FILENAME=$(basename "$RANDOM_FILE")
    # Копируем файл
    cp "$RANDOM_FILE" "$IN_DIR"

    TIME_STR=$(date +"%H:%M:%S")
    #пишем в log операцию копирования
    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][I][Скопирован файл: $FILENAME в $IN_DIR]" >> $LOG
    NAME_FILE=$(echo "${RANDOM_FILE##*/}")

    #пауза, ждём пока обработается файл
        if [ $INT == "a" ]; then
            while ls "$IN_DIR/$NAME_FILE" 1> /dev/null 2>&1; do
                sleep 1.1 # Пауза перед следующей проверкой
                if [ -n "$(find "$IN_DIR/$NAME_FILE" -type f -mmin +0,3 2>/dev/null)" ]; then
                    echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][E][Файл $NAME_FILE не обрабатвыается!]" >> $LOG
                    ERRORS_PROC="error"
                    break
                fi
            done
        else
            while ls "$IN_DIR/$NAME_FILE" 1> /dev/null 2>&1; do
            sleep $INT #интервал
            if [ -n "$(find "$IN_DIR/$NAME_FILE" -type f -mmin +0,3 2>/dev/null)" ]; then
                echo "[$DATE_STR][$TIME_STR][$NAME_MODUL][E][Файл $NAME_FILE не обрабатвыается!]" >> $LOG
                ERRORS_PROC="error"
                break
            fi
            done
        fi

    ERRORS=$(cat $FILE_LOG_WatcherService | grep -i 'error\|ошибка\|не обрабатываются\|обрабатвыается!' | awk "/$TIME_STR/ {f=1} f")
    if [[ -z "$ERRORS" && -z "$ERRORS_PROC" ]]; then
      #выводим из лога DBWM что запись успешна
      READ_BD=$(tac $FILE_LOG_DbWriterService | grep -m 1 "Запись в БД завершена успешно" | grep -o "Запись.*")
      echo "[$DATE_STR][$TIME_STR][DbWriterService][I][$READ_BD]" >> $LOG
      #выводими в консоль информацию из лога, подсвечиваем новые записи в БД зелёным цветом
      awk "/$TIME_STR/ {f=1} f" $LOG | sed '/Запись/s/.*/\o033[32m&\o033[0m/'
    fi
    if [[ -z "$ERRORS" && -n "$ERRORS_PROC" ]]; then
        #выводими в консоль информацию из лога
        awk "/$TIME_STR/ {f=1} f" $LOG | sed '/error/s/.*/\o033[31m&\o033[0m/' | sed '/ошибка/s/.*/\o033[31m&\o033[0m/' | sed '/readout/s/.*/\o033[31m&\o033[0m/' | sed '/обрабатвыается!/s/.*/\o033[31m&\o033[0m/'
        ERRORS=""
        ERRORS_PROC=""
    fi
     if [[ -n "$ERRORS" && -z "$ERRORS_PROC" ]]; then
      echo "$ERRORS" >> $LOG
      #выводими в консоль информацию из лога
      awk "/$TIME_STR/ {f=1} f" $LOG | sed '/error/s/.*/\o033[31m&\o033[0m/' | sed '/ошибка/s/.*/\o033[31m&\o033[0m/' | sed '/readout/s/.*/\o033[31m&\o033[0m/' | sed '/обрабатвыается!/s/.*/\o033[31m&\o033[0m/'
      ERRORS=""
      ERRORS_PROC=""
    fi

    # Увеличиваем счетчик
    ((IND++))
done

echo "" >> $LOG

echo ""
# Отчёт о тесте
ok=$(tac $LOG | sed -n '1,/'Начато'/p' | grep "ID=" | wc -l)
ow=$(tac $LOG | sed -n '1,/'Начато'/p' | grep -i 'error\|ошибка\|не обрабатываются' | wc -l)
nc=$(tac $LOG | sed -n '1,/'Начато'/p' | grep "обрабатвыается!" | wc -l)
echo ""
echo -e "\t\e[1mУспешно обработано: $ok \tОбработано с ошибкой: $ow \tНе обработанных: $nc\e[0m"
echo "" >> $LOG
echo -e "Успешно обработано: $ok \tОбработано с ошибкой: $ow \tНе обработанных: $nc" >> $LOG
echo "-------------------------------------------------------------------------" >> $LOG

if [[ "$ow" > 0 || "$nc" > 0 ]]; then
    echo ""
    echo ""
    echo -e "\e[1m1. Вывести все ошибки из лога\e[0m"
    echo -e "\e[1m2. Запустить заново\e[0m"
    echo -e "\e[1m3. Главное меню\e[0m"
    echo -e "\e[1m4. Выход\e[0m"
    echo ""
    read -p "Введите номер опции (1-4): " choice

    case $choice in
    1)
        echo ""
        tac $LOG | sed -n '1,/'Начато'/p' | grep -i 'error\|ошибка\|не обрабатываются\|обрабатвыается!'
        ;;
    2)
        $ACTIVE_DIR/CopyRandomFile_v1.0.sh
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
        $ACTIVE_DIR/$NAME_MODUL_v1.0.sh
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

# 29.12.25
# - добавлен вывод в консоль вывод  об успешной записи в БД из лога "DbWriterService" (зелёным цветом)
# - принудительное создание папки "log"
#
#
