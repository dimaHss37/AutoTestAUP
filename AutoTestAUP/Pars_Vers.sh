#!/bin/bash

VERS=1.2418
# Комплекс или смарт?
if [[ "$VERS" == 1.0* ]]; then
    VERS_K=$VERS
    VERS_S=""
else
    VERS_S=$VERS
    VERS_K=""
fi


if [ -n "$VERS_S" ]; then
    if (( $(echo "$VERS_S >= 1.20" | bc -l) )) && (( $(echo "$VERS_S < 1.2422" | bc -l) )); then
        echo "20 параметров."
    fi
    if (( $(echo "$VERS_S >= 1.2422" | bc -l) )) && (( $(echo "$VERS_S < 1.2525" | bc -l) )); then
        echo "22 параметров."
    fi
    if (( $(echo "$VERS_S >= 1.252500" | bc -l) )) && (( $(echo "$VERS_S < 1.252910" | bc -l) )); then
        echo "29 параметров."
    fi
    if (( $(echo "$VERS_S >= 1.252910" | bc -l) )) && (( $(echo "$VERS_S < 1.253202" | bc -l) )); then
        echo "31 параметров."
    fi
    if (( $(echo "$VERS_S >= 1.253202" | bc -l) )) && (( $(echo "$VERS_S < 1.253500" | bc -l) )); then
        echo "31 параметров."
    fi
    if (( $(echo "$VERS_S >= 1.273700" | bc -l) )) && (( $(echo "$VERS_S < 1.290218" | bc -l) )); then
        echo "48 параметров."
    fi
    if (( $(echo "$VERS_S >= 1.290218" | bc -l) )) && (( $(echo "$VERS_S < 1.290300" | bc -l) )); then
        echo "49 параметров."
    fi
    if (( $(echo "$VERS_S >= 1.290300" | bc -l) )) && (( $(echo "$VERS_S < 1.290315" | bc -l) )); then
        echo "55 параметров."
    fi
    if (( $(echo "$VERS_S >=  1.290315" | bc -l) )); then
        echo "57 параметров."
    fi

else
    if (( $(echo "$VERS_K < 1.030703" | bc -l) )); then
        echo "44 параметров."
    fi
    if (( $(echo "$VERS_K >= 1.030703" | bc -l) )) && (( $(echo "$VERS_K < 1.050218" | bc -l) )); then
        echo "48 параметров."
    fi
    if (( $(echo "$VERS_K >= 1.050218" | bc -l) )) && (( $(echo "$VERS_K < 1.050300" | bc -l) )); then
        echo "49 параметров."
    fi
    if (( $(echo "$VERS_K >= 1.050315" | bc -l) )); then
        echo "57 параметров."
    fi
fi
