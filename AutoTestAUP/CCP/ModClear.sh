#!/bin/bash

ACTIVE_DIR=$(dirname "$0")
export ACTIVE_DIR=$ACTIVE_DIR
# удаляем старые логи (30 дней и старше)
find $ACTIVE_DIR/log/ -type f -mtime +30 -delete
# чистим папку "tmp"
rm -r $ACTIVE_DIR/tmp/* 2>/dev/null

# удаляем все не rdt файлы и папки из папки "rdt"
find $ACTIVE_DIR/rdt -type f ! -name "*.rdt" -delete
find $ACTIVE_DIR/rdt -mindepth 1 -type d -exec rm -rf {} +

#
timestamp="$ACTIVE_DIR/tmp/.timestamp.conf"
if [[ -f $timestamp ]]; then
    if find "$timestamp" -mtime -1 | grep -q .; then
        # Файл не старше одного дня
        # читаем timestamp.conf
        PCid=$(cat /etc/machine-id)
        FPCid=$(cat $timestamp | grep "PC-id" | cut -d'=' -f2- | sed 's/ //g')
        if [[ "$PCid" != "$FPCid" ]]; then
            rm $timestamp 2>/dev/null
            $ACTIVE_DIR/ModTestSystem.sh
        fi
        DirArc=$(cat $timestamp | grep "DirArc" | grep -oE '[0-9]+')
        DirIn=$(cat $timestamp | grep "DirIn" | grep -oE '[0-9]+')
        DirOut=$(cat $timestamp | grep "DirOut" | grep -oE '[0-9]+')
        DirOk=$(cat $timestamp | grep "DirOk" | grep -oE '[0-9]+')
        DirOw=$(cat $timestamp | grep "DirOw" | grep -oE '[0-9]+')
        DirResp=$(cat $timestamp | grep "DirResp" | grep -oE '[0-9]+')
        DirAUP=$(cat $timestamp | grep "DirAUP" | grep -oE '[0-9]+')
        WatcherService=$(cat $timestamp | grep "WatcherService" | grep -oE '[0-9]+')
        ValidatorService=$(cat $timestamp | grep "ValidatorService" | grep -oE '[0-9]+')
        DbWriterService=$(cat $timestamp | grep "DbWriterService" | grep -oE '[0-9]+')
        SmtHandlerService=$(cat $timestamp | grep "SmtHandlerService" | grep -oE '[0-9]+')
        SgsJson=$(cat $timestamp | grep "SgsJson" | grep -oE '[0-9]+')
        DbWriterStatus=$(cat $timestamp | grep "DbWriterStatus" | grep -oE '[0-9]+')
        SmtHandlerStatus=$(cat $timestamp | grep "SmtHandlerStatus" | grep -oE '[0-9]+')
        ValidatorStatus=$(cat $timestamp | grep "ValidatorStatus" | grep -oE '[0-9]+')
        WatcherStatus=$(cat $timestamp | grep "WatcherStatus" | grep -oE '[0-9]+')
        Group=$(cat $timestamp | grep "Group" | grep -oE '[0-9]+')
        DBLocation=$(cat $timestamp | grep "DBLocation" | grep -oE '[0-9]+')
        DBType=$(cat $timestamp | grep "DBType" | grep -oE '[0-9]+')
        DBName=$(cat $timestamp | grep "DBName" | grep -oE '[0-9]+')
        DBHost=$(cat $timestamp | grep "DBHost" | grep -oE '[0-9]+')
        DBPort=$(cat $timestamp | grep "DBPort" | grep -oE '[0-9]+')
        DBLogin=$(cat $timestamp | grep "DBLogin" | grep -oE '[0-9]+')
        DBPassword=$(cat $timestamp | grep "DBPassword" | grep -oE '[0-9]+')
        PostgresqlStatus=$(cat $timestamp | grep "PostgresqlStatus" | grep -oE '[0-9]+')
        DBConnection=$(cat $timestamp | grep "DBConnection" | grep -oE '[0-9]+')

        if (( DirArc + DirIn + DirOut + DirOk + DirOw + DirResp + DirAUP + WatcherService + ValidatorService + DbWriterService + SmtHandlerService + SgsJson + DbWriterStatus + SmtHandlerStatus + ValidatorStatus + WatcherStatus + Group + DBLocation + DBType + DBName + DBHost + DBPort + DBLogin + DBPasswo + PostgresqlStatus + DBConnection == 0 )); then
            $ACTIVE_DIR/ComplexChecParams.sh
        else
            # start test
            rm $timestamp 2>/dev/null
            $ACTIVE_DIR/ModTestSystem.sh
        fi
    else
        # Файл старше одного дня или не существует
        # start test
        rm $timestamp 2>/dev/null
        $ACTIVE_DIR/ModTestSystem.sh
    fi
else
    # start test
    rm $timestamp 2>/dev/null
    $ACTIVE_DIR/ModTestSystem.sh
fi
