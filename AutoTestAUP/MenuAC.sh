#!/bin/bash

ACTIVE_DIR=$(dirname "$0")
echo ""
echo ""
echo -e "\t----------------------------"
echo -e "\t\e[1m1. Запустить заново\e[0m"
echo -e "\t\e[1m2. Главное меню\e[0m"
echo -e "\t\e[1m5. Выход\e[0m"
echo ""
read -p "Введите номер опции (1-3): " choice

case $choice in
    1)
    $ACTIVE_DIR/ChecParamsRecord[AC].sh
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
