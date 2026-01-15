#!/bin/bash

ACTIVE_DIR=$(dirname "$0")

echo ""
echo "---------------------------"
echo ""
echo ""
echo -e "\e[1m1. Запустить заново\e[0m"
echo -e "\e[1m2. Главное меню\e[0m"
echo -e "\e[1m3. Выход\e[0m"
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
    echo "Завершение работы."
    exit 0
    ;;
  *)
    echo "Ошибка: Неправильный ввод."
    ;;
esac
