#!/bin/bash

clear
START=$(ss -antp | grep :5432 | grep ESTAB | awk '{print $5}' | cut -d':' -f1 | sort -u | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
[[ -n $START ]] && echo "$START" | sed 's/^/\x1b[1;32m●\x1b[0m /'
while true; do
OLD=$(ss -antp | grep :5432 | grep ESTAB)
sleep 0.5
NEW=$(ss -antp | grep :5432 | grep ESTAB)
[[ "$OLD" != "$NEW" ]] && clear && echo "$NEW" | awk '{print $5}' | cut -d':' -f1 | sort -u | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' | sed 's/^/\x1b[1;32m●\x1b[0m /'
done
