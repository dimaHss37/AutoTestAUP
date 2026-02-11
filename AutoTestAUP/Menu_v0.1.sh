#!/bin/bash

clear
ACTIVE_DIR=$(dirname "$0")
echo ""
echo ""
echo -e "\t\e[1m--- Главное Меню ---\e[0m"
echo -e "\t----------------------------"
echo -e "\t\e[1m1. Провести тест работоспособности системы AUP\e[0m"
echo -e "\t\e[1m2. Провести тест системы\e[0m"
echo -e "\t\e[1m3. Интервальное копирование файлов\e[0m"
echo -e "\t\e[1m4. Проверка скорости обработки файлов\e[0m"
echo -e "\t\e[1m5. Проверка записи параметров [ACTUAL COUNTERS]\e[0m"
echo -e "\t\e[1m6. Проверка записи архива событий [ARCHIVE4]\e[0m"
echo -e "\t\e[1m7. Проверка записи часового архива [ARCHIVE3]\e[0m"
echo -e "\t\e[1m8. Проверка записи архива телеметрии [ARCHIVE9]\e[0m"
echo -e "\t\e[1m9. Выход\e[0m"
echo ""
read -p "Введите номер опции (1-9): " choice

case $choice in
    1)
    $ACTIVE_DIR/AUP_Performance.sh
    ;;
    2)
    $ACTIVE_DIR/TestSystem.sh
    ;;
    3)
    $ACTIVE_DIR/CopyRandomFile_v1.0.sh
    ;;
    4)
    $ACTIVE_DIR/TimeMetr.sh
    ;;
    5)
    $ACTIVE_DIR/ChecParamsRecord[AC].sh
    ;;
    6)
    $ACTIVE_DIR/ChecARCHIVE4.sh
    ;;
    7)
    $ACTIVE_DIR/ChecARCHIVE3.sh
    ;;
    8)
    $ACTIVE_DIR/ChecARCHIVE9.sh
    ;;
    9)
    echo ""
    echo ""
    clear
    echo "Завершение работы."
    exit 0
    ;;
    *)
    echo ""
    echo ""
    echo "Ошибка: Неправильный ввод."
    ;;
esac
