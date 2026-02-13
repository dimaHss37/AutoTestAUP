#!/bin/bash


# Отчёт о тесте
Passed=$(tac $LOG | sed -n '1,/'$NAME_FILE'/p' | grep "Passed" | wc -l)
((Passed--))
Failed=$(tac $LOG | sed -n '1,/'$NAME_FILE'/p' | grep "Failed" | wc -l)
((Failed--))
echo ""
echo -e "\t\e[1mУспешных тестов: $Passed \tПроваленых тестов: $Failed\e[0m"
echo "" >> $LOG
echo -e "Успешных тестов: $Passed \tПроваленых тестов: $Failed" >> $LOG


if [[ "$Failed" > 0 ]]; then
    echo ""
    echo ""
    echo -e "\t----------------------------"
    echo -e "\t\e[1m1. Вывести ошибки из лога\e[0m"
    echo -e "\t\e[1m2. Вывести весь лог\e[0m"
    echo -e "\t\e[1m3. Выбрать другой файл\e[0m"
    echo -e "\t\e[1m4. Выход\e[0m"
    echo ""
    read -p "Введите номер опции (1-4): " choice

    case $choice in
        1)
        echo ""
        tac $LOG | sed -n '1,/'$NAME_FILE'/p' | grep "Failed" | tac | sed '/Passed/d'
        ;;
        2)
        echo ""
        tac $LOG | sed -n '1,/'$NAME_FILE'/p' | tac
        ;;
        3)
        $ACTIVE_DIR/ComplexChecParams.sh
        ;;
        4)
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
fi

if [[ "$Failed" == 0 ]]; then
    echo ""
    echo ""
    echo -e "\t----------------------------"
    echo -e "\t\e[1m1. Вывести весь лог\e[0m"
    echo -e "\t\e[1m2. Выбрать другой файл\e[0m"
    echo -e "\t\e[1m3. Выход\e[0m"
    echo ""
    read -p "Введите номер опции (1-3): " choice

    case $choice in
        1)
        echo ""
        tac $LOG | sed -n '1,/'$NAME_FILE'/p' | tac
        ;;
        2)
        $ACTIVE_DIR/ComplexChecParams.sh
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
fi
