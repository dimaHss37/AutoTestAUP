#!/bin/bash

# ищем "sgs.json"
FILE_SGS_JSON=$(find /opt -type f -name "sgs.json" 2>/dev/null)

DatabaseLocation=$(cat $FILE_SGS_JSON | jq -r '.AUPService.DbWriterService.DatabaseLocation')
if [ "$DatabaseLocation" == "Local" ]; then
    DatabaseType=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.DatabaseType')
    if [ "$DatabaseType" == "PostgreSQL" ]; then
        Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Name')
        Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Host')
        Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Port')
        Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Login')
        Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.PostgreSQL.SGS.Password')
    else
        SGS_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Name')
        SGS_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Host')
        SGS_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Port')
        SGS_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Login')
        SGS_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Password')

        TMR_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Name')
        TMR_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Host')
        TMR_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Port')
        TMR_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Login')
        TMR_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Password')

        CON_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Name')
        CON_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Host')
        CON_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Port')
        CON_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Login')
        CON_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Password')

        ALP_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Name')
        ALP_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Host')
        ALP_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Port')
        ALP_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Login')
        ALP_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Password')

    fi
else
    if [ "$DatabaseLocation" == "Server" ]; then
        DatabaseType=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.DatabaseType')
        if [ "$DatabaseType" == "PostgreSQL" ]; then
            Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Name')
            Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Host')
            Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Port')
            Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Login')
            Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Server.PostgreSQL.SGS.Password')
        else
            SGS_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Name')
            SGS_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Host')
            SGS_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Port')
            SGS_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Login')
            SGS_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.SGS.Password')

            TMR_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Name')
            TMR_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Host')
            TMR_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Port')
            TMR_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Login')
            TMR_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.TMR.Password')

            CON_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Name')
            CON_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Host')
            CON_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Port')
            CON_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Login')
            CON_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.CON.Password')

            ALP_Name=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Name')
            ALP_Host=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Host')
            ALP_Port=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Port')
            ALP_Login=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Login')
            ALP_Password=$(cat $FILE_SGS_JSON | jq -r '.DatabaseConnection.Local.Firebird.ALP.Password')
        fi
    else
        sgs_stat="Некорректный sgs.json"
    fi
fi
