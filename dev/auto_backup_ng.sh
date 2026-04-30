#!/bin/bash

backup_dir="/mnt/b67b159b-ecb4-43bb-bfca-c4eb1f02d168"
Name="sgs"
Host="172.22.0.96"
Port="5432"
Login="GazSetLogin"

# количество backups
backup_quantity=3
curent_quantity=$(ls $backup_dir | wc -l)
# время жизни backup (дней)
life_time_backup=60


# сколько дней хра

if [ "$curent_quantity" -lt "$backup_quantity" ]; then
    # делаем backup
    backup_name="sgs_backup_$(date +"%d_%m_%Y").tar"
    PGPASSWORD='masterGazSetLogin' pg_dump -v -U $Login -h $Host -d $Name -F tar -f ${backup_dir}/${backup_name}
    # удаляем старые backup
    [[ -n $old_backup_del ]] && find $backup_dir -type f -name "*.tar" -mtime +$life_time_backup -delete
else
    # удаляем старые backup
    [[ -n $old_backup_del ]] && find $backup_dir -type f -name "*.tar" -mtime +$life_time_backup -delete
fi
