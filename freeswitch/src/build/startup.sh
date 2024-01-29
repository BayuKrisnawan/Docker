#!/bin/bash
DBHOST=$SWITCH_DB_HOST
DBNAME=$SWITCH_DB_NAME
DBUSER=$SWITCH_DB_USER
#- check pgsl running
lcore=$(ps uax|grep [p]ostgres|wc -l)

if [[ $lcore -gt 1 && $DBHOST == "127.0.0.1" ]]; then
        #CLEANUPDB
        dropdb -U postgres coredb
        createdb -U postgres coredb
fi

do_setlimits() {
        ulimit -c unlimited >/dev/null 2>&1
        ulimit -d unlimited >/dev/null 2>&1
        ulimit -f unlimited >/dev/null 2>&1
        ulimit -i unlimited >/dev/null 2>&1
        ulimit -n 999999    >/dev/null 2>&1
        ulimit -q unlimited >/dev/null 2>&1
        ulimit -u unlimited >/dev/null 2>&1
        ulimit -v unlimited >/dev/null 2>&1
        ulimit -x unlimited >/dev/null 2>&1
        ulimit -s 240       >/dev/null 2>&1
        ulimit -l unlimited >/dev/null 2>&1
        return 0
}

##### Main 
### - Starting FreeSwitch
do_setlimits
ulimit -a  >/tmp/limits.txt
/usr/bin/freeswitch -nc -nf -nonat
