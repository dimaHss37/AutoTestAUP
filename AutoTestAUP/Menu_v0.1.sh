#!/bin/bash

clear
ACTIVE_DIR=$(dirname "$0")
echo ""
echo ""
echo -e "\t\e[1m--- Главное Меню ---\e[0m"
echo -e "\t----------------------------"
echo -e "\t\e[1m1. Провести тест системы\e[0m"
echo -e "\t\e[1m2. Интервальное копирование файлов\e[0m"
echo -e "\t\e[1m3. Проверка скорости обработки файлов\e[0m"
echo -e "\t\e[1m4. Проверка записи параметров [ACTUAL COUNTERS]\e[0m"
echo -e "\t\e[1m5. Выход\e[0m"
echo ""
read -p "Введите номер опции (1-5): " choice

case $choice in
    1)
    $ACTIVE_DIR/TestSystem.sh
    ;;
    2)
    $ACTIVE_DIR/CopyRandomFile_v0.3a.sh
    ;;
    3)
    $ACTIVE_DIR/TimeMetr.sh
    ;;
    4)
    $ACTIVE_DIR/ChecParamsRecord[AC].sh
    ;;
    5)
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
