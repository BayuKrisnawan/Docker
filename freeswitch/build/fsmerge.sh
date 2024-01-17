#!/bin/sh
TARLIB=/usr/src/fs.tar.gz
IMGTAR=/usr/src/fs-image.tar.gz
FOLDER="/var /usr /etc"
FSLIST=/tmp/all.txt
FILELIST=/tmp/filelist.txt
WITHOUT_PERL="true"
WITHOUT_PYTHON="no"
WITHOUT_JAVA="true"
BUILD_ROOT="/tmp/fs"

[ -d $BUILD_ROOT ] && rm  -r $BUILD_ROOT

ldd_helper() {
    TESTFILE=$1
    ldd $TESTFILE 2> /dev/null > /dev/null || return

    RESULT=$(ldd $TESTFILE | grep -oP '\s\S+\s\(\S+\)' | sed -e 's/^\s//' -e 's/\s.*$//')
    echo "$RESULT"
}

fs_file_lst() {
   > $FSLIST
   find /var > /var-new.txt
   find /etc > /etc-new.txt
   find /usr |grep -Ewv /usr/src > /usr-new.txt
   for lst in `echo $FOLDER`;do
      diff $lst.txt $lst-new.txt |grep \>|awk '{print $2}'  |\
       grep -Ewv /usr/include | grep -Ewv /var/ >>$FSLIST 
   done
}

create_libs() {
  > $FSLIST.new
  for lst in `cat $FSLIST`;do
    if [ -f $lst ]; then
        echo >>$FSLIST.new
	      echo $lst >> $FSLIST.new
  	   ldd_helper `which ${lst}` >> $FSLIST.new
    fi
  done
  sort $FSLIST.new | sort | uniq | sed -e '/linux-vdso.so.1/d' > $FSLIST
   rm $FSLIST.new
}




filter_unnecessary_files() {
# excluded following files and directories recursive
# /.
# /lib/systemd/
# /usr/share/doc/
# /usr/share/lintian/
# /usr/share/freeswitch/sounds/
# all "*.flac" files

    sed -i \
        -e '\|^/\.$|d' \
        -e '\|^/lib/systemd|d' \
        -e '\|^/etc/apt|d' \
        -e '\|^/etc/alternatives|d' \
        -e '\|^/usr/share/doc|d' \
        -e '\|^/usr/share/lintian|d' \
        -e '\|^/var/log/.*|d' \
        -e '\|^/var/lib/.*|d' \
        -e '\|^/var/cache/.*|d' \
        -e '\|^/.*\.flac$|d' \
        -e '\|^/.*/flac$|d' \
        $FSLIST

# if disabled Perl and python removing this too
    if [ "$WITHOUT_PERL"="true" ];then
        sed -i -e '\|^/usr/share/perl|d' $FSLIST
    fi
    if [ "$WITHOUT_PYTHON"="true" ];then
        sed -i -e '\|^/usr/share/pyshared|d' -e '\|^/usr/share/python-support|d' $FSLIST
    fi
    if [ "$WITHOUT_JAVA"="true" ];then
        sed -i -e '\|^/usr/share/freeswitch/scripts/freeswitch.jar|d' $FSLIST
    fi
}


update_libs() {
  > $FSLIST.new
  for lst in `cat $FSLIST`;do
    if [ -f $lst ]; then
	      echo $lst >> $FSLIST.new
  	    ldd_helper `which ${lst}` >> $FSLIST.new
    else 
      echo $lst >> $FSLIST.new
    fi
  done
  sort $FSLIST.new | sort | uniq | sed -e '/linux-vdso.so.1/d' > $FSLIST
  rm $FSLIST.new
}

final_update_libs() {
  > $FSLIST.new
    for lst in `cat $FSLIST`;do
        echo $lst >>$FSLIST.new
        symlink=$(file $lst |grep symbolic | awk '{print $5}')
        fulldir=$(dirname $lst)
        if ! echo "$symlink" | grep -q "^\/";  then
            [ ! -z $symlink ] && echo "$fulldir/$symlink " >>$FSLIST.new
        fi 
    done
  sort $FSLIST.new | sort | uniq > $FSLIST
  filter_unnecessary_files 
  rm $FSLIST.new

}

gen_tar_libs() {
    #tar -czf $TARLIB --dereference -T $LIBLST
    for liblist in `cat $FSLIST `;do echo $liblist;done > /tmp/fs.txt
    tar -cf $TARLIB -T /tmp/fs.txt
    rm /tmp/fs.txt
}

fs_file_lst
create_libs
update_libs
final_update_libs
gen_tar_libs
mkdir -p $BUILD_ROOT
cd $BUILD_ROOT
echo "Extracting ... "
tar xf $TARLIB
