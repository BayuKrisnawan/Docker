#!/bin/bash

PREFILE=/files-pre-build.txt
PRAFILE=/files-pra-build.txt
DIFFFILE=/tmp/diff.txt
LIBFILE=/tmp/libs.txt
ALLFILE=/tmp/all.txt
TARFILE=/freeswitch.tar.gz

[[ ! -f $PREFILE  ||  ! -f $PRAFILE ]] && exit

generate_libs() {
    cat $1|grep -v "/include/\|/share/doc/\|/htdocs/\|/fonts/\|/unimrcp/conf/\|/unimrcp/data/"| \
        xargs ldd 2>/dev/null |grep "=>"|awk '{print $3}'  |sort |uniq > $2
}

generate_diff() {
    diff $1 $2 | grep ^\>|awk '{print $2}' > $3
}

generate_tarz() {
    # merge diff and libs -> allfile
    sort $2 $3 |uniq | grep -v "/include/\|/share/doc/\|/htdocs/\|/fonts/" >$4.0
    echo $file >$4
    for file in $(cat $4.0);do
        echo $file >>$4
        if [ -L ${file} ] && [ -e ${file} ]; then
                echo link :$file
                realpath $file >> $4
        fi
    done
    tar --hard-dereference -czf $1 -T $4
    #tar --dereference -czf $1 -T $4
}

generate_diff $PREFILE $PRAFILE $DIFFFILE
generate_libs $DIFFFILE $LIBFILE
generate_tarz $TARFILE $DIFFFILE $LIBFILE $ALLFILE