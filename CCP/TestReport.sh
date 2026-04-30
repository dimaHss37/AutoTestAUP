#!/bin/bash

# Отчёт о тесте
Passed=$(tac $LOG | sed -n '1,/'$NAME_FILE'/p' | grep "Passed" | wc -l)
((Passed--))
Failed=$(tac $LOG | sed -n '1,/'$NAME_FILE'/p' | grep "Failed" | wc -l)
((Failed--))
end=$(date +%s)
COUNTERS=$(tac $TARGET | grep -m 1 "ACTUAL COUNTERS" -a1 | head -n 1 | grep -o ";" | wc -l)
AC=$((COUNTERS + 1))
ARC3=$(cat $TARGET | awk '/\[ARCHIVE3\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
ARC4=$(cat $TARGET | awk '/\[ARCHIVE4\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
ARC5=$(cat $TARGET | awk '/\[ARCHIVE5\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
ARC7=$(cat $TARGET | awk '/\[ARCHIVE7\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
ARC9=$(cat $TARGET | awk '/\[ARCHIVE9\]/{f=2} f && /#/ {f=0; print; next} f' | sed '/ARCHIVE/d' | sed '/#/d' | wc -l)
MA3="записей" MA4="записей" MA5="записей" MA7="записей" MA9="записей"
[[ $ARC3 = 0 ]] && ARC3="нет"
[[ $ARC3 =~ [234]$ && $ARC3 != 12 && $ARC3 != 13 && $ARC3 != 14 ]] && MA3="записи"
[[ $ARC3 =~ [1]$ && $ARC3 != 11 ]] && MA3="запись"
[[ $ARC4 = 0 ]] && ARC4="нет"
[[ $ARC4 =~ [234]$ && $ARC4 != 12 && $ARC4 != 13 && $ARC4 != 14 ]] && MA4="записи"
[[ $ARC4 =~ [1]$ && $ARC4 != 11 ]] && MA4="запись"
[[ $ARC5 = 0 ]] && ARC5="нет"
[[ $ARC5 =~ [234]$ && $ARC5 != 12 && $ARC5 != 13 && $ARC5 != 14 ]] && MA5="записи"
[[ $ARC5 =~ [1]$ && $ARC5 != 11 ]] && MA5="запись"
[[ $ARC7 = 0 ]] && ARC7="нет"
[[ $ARC7 =~ [234]$ && $ARC7 != 12 && $ARC7 != 13 && $ARC7 != 14 ]] && MA7="записи"
[[ $ARC7 =~ [1]$ && $ARC7 != 11 ]] && MA7="запись"
[[ $ARC9 = 0 ]] && ARC9="нет"
[[ $ARC9 =~ [234]$ && $ARC9 != 12 && $ARC9 != 13 && $ARC9 != 14 ]] && MA9="записи"
[[ $ARC9 =~ [1]$ && $ARC9 != 11 ]] && MA9="запись"

echo ""
echo -e "\t\e[1m[ACTUAL COUNTERS]: $AC параметров\e[0m"
echo -e "\t\e[1m[ARCHIVE3]: $ARC3 $MA3 \e[0m"
echo -e "\t\e[1m[ARCHIVE4]: $ARC4 $MA4 \e[0m"
echo -e "\t\e[1m[ARCHIVE5]: $ARC5 $MA5 \e[0m"
echo -e "\t\e[1m[ARCHIVE7]: $ARC7 $MA7 \e[0m"
echo -e "\t\e[1m[ARCHIVE9]: $ARC9 $MA9 \e[0m"
echo ""
echo -e "\t\e[1mУспешных тестов: $Passed \tПроваленых тестов: $Failed\e[0m"

echo "" >> $LOG
echo "[ACTUAL COUNTERS]: $AC параметров" >> $LOG
echo "[ARCHIVE3]: $ARC3 $MA3" >> $LOG
echo "[ARCHIVE4]: $ARC4 $MA4" >> $LOG
echo "[ARCHIVE5]: $ARC5 $MA5" >> $LOG
echo "[ARCHIVE7]: $ARC7 $MA7" >> $LOG
echo "[ARCHIVE9]: $ARC9 $MA9" >> $LOG
echo "" >> $LOG
echo -e "Успешных тестов: $Passed \tПроваленых тестов: $Failed" >> $LOG
echo ""
time=$((end - start))
if [ "$time" -gt 59 ]; then
    mins=$(( time / 60 ))
    secs=$(( time % 60 ))
    echo -e "\t\e[1mВремя тестирования: ${mins} мин. ${secs} сек.\e[0m"
    echo "Время тестирования: ${mins} мин. ${secs} сек." >> $LOG
else
    echo -e "\t\e[1mВремя тестирования: ${time} сек.\e[0m"
    echo "Время тестирования: ${time} сек." >> $LOG
fi


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
