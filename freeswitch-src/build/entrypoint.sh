#!/bin/sh

set -e

if [ -z "$@" ]; then
  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf  --nodaemon --logfile=/proc/1/fd/1 --logfile_maxbytes=0
else
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi
