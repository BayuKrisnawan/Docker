#!/bin/bash

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
/usr/bin/freeswitch -nc -nf -nonat
