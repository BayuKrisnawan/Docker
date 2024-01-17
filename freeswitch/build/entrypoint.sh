#!/bin/sh

set -e

if [ -z "$@" ]; then
  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf  --nodaemon
else
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi
