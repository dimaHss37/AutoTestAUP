#!/bin/bash

# Исходные даты
DATETIME="10.09.2025 09:25:21"
DB_DATETIME="31.03.2026 15:04:47"

# Преобразование в формат, который понимает команда date (YYYY-MM-DD HH:MM:SS)
# Для этого меняем местами день и месяц или используем формат ГГГГММДД
d1_sec=$(date -d "${DATETIME:6:4}-${DATETIME:3:2}-${DATETIME:0:2} ${DATETIME:11}" +%s)
d2_sec=$(date -d "${DB_DATETIME:6:4}-${DB_DATETIME:3:2}-${DB_DATETIME:0:2} ${DB_DATETIME:11}" +%s)

# Сравнение числовых значений
#if [ "$d1_sec" -lt "$d2_sec" ]; then
#    echo ""
#    echo "Значения в базе данных актуальней"
#    exit 0
#fi
#

 T=-.25
 T=$(echo "scale=2; $T / 1" | bc)
 echo "$T"
 [[ $T == .* ]] && T="0$T"
 [[ $T == -.* ]] && T=$(printf "%.2f\n" "$T")
 echo "$T"
