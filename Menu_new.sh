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
echo -e "\t\e[1m5. Тест файлов RDT\e[0m"
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
    $ACTIVE_DIR/CCP/ModClear.sh
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
