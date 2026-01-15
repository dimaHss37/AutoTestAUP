##НАБОР СКРИПТОВ ДЛЯ ТЕСТИРОВАНИЯ СИСТЕМЫ AUP

####TestSystem


####CopyRandomFile


####TimeMetr


####ChecParamsRecord[AC]
Описание:
Программа сравнивает значения [ACTUAL COUNTERS] в файле rdt и в базе данных Postgresql

Инструкция
- в системе должен быть установлен и запущен "postgresql.service"
- в файле конфигурации "/var/lib/pgsql/data/pg_hba.conf" рекомендуется изменить значение в поле "METHOD" на "trust"
пример:
```sh
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
```
- для начала работы необходимо скопировать тестируемый файл/файлы rdt в папку "AutoTestAUP\rdt"
- запуск скрипта можно осуществлять непосредственно запустив его или через главное меню, выбрав пункт "4. Проверка записи параметров [ACTUAL COUNTERS]"
