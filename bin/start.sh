#!/bin/bash
set -e

/etc/init.d/cron start
(ls -l /etc/dovecot/sieve/ && sievec /etc/dovecot/sieve/) || true
/usr/sbin/dovecot -F 1> /var/log/stdout 2>&1
tail -qf --follow=name --retry /var/log/stdout
