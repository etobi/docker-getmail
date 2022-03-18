#!/bin/bash
set -e

echo > /var/log/getmail/getmail.log
/etc/init.d/cron start
exec "$@"
