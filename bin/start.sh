#!/bin/bash
set -e

/etc/init.d/cron start
sievec /etc/dovecot/sieve/bogofilter.sieve
/usr/sbin/dovecot -F 1> /var/log/stdout 2>&1
tail -qf --follow=name --retry /var/log/stdout
