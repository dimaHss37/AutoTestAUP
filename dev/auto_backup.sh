#!/bin/bash

backup_dir="/mnt/b67b159b-ecb4-43bb-bfca-c4eb1f02d168"
Name="sgs"
Host="172.22.0.96"
Port="5432"
Login="GazSetLogin"

old_backup_del=$(find $backup_dir -type f -name "*.tar" -mtime +60)
old_backup=$(find $backup_dir -type f -name "*.tar" -mtime +30)
activ_backup=$(find $backup_dir -type f -name "*.tar")

if [[ -z $activ_backup &&  -z $old_backup ]]; then
    # делаем backup
    backup_name="sgs_backup_$(date +"%d_%m_%Y").tar"
    PGPASSWORD='masterGazSetLogin' pg_dump -v -U $Login -h $Host -d $Name -F tar -f ${backup_dir}/${backup_name}
fi
if [[ -z $activ_backup &&  -n $old_backup ]]; then
    # делаем backup
    backup_name="sgs_backup_$(date +"%d_%m_%Y").tar"
    PGPASSWORD='masterGazSetLogin' pg_dump -v -U $Login -h $Host -d $Name -F tar -f ${backup_dir}/${backup_name}
    # удаляем старые backup
    [[ -n $old_backup_del ]] && find $backup_dir -type f -name "*.tar" -mtime +60 -delete
fi
if [[ -n $activ_backup &&  -n $old_backup ]]; then
    # удаляем старые backup
    [[ -n $old_backup_del ]] && find $backup_dir -type f -name "*.tar" -mtime +60 -delete
fi
