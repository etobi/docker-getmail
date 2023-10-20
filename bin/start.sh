#!/bin/bash
set -e

/etc/init.d/cron start

(find /srv/mail/*/Maildir/sieve/ -name *.sieve -print -exec sievec {} \;) || true
(find /app/bin/sieve/ -name *.sieve -print -exec sievec {} \;) || true

/usr/sbin/dovecot -F 1> /var/log/stdout 2>&1
tail -qf --follow=name --retry /var/log/stdout
