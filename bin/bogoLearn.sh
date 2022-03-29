#!/bin/bash

MAILDIRUSER="$1"
LOCKFILE="/tmp/bogoLearnHam.lock"

if [ -f ${LOCKFILE} ] ; then
  # the lock file already exists, so what to do?
  if [ "$(ps -p `cat ${LOCKFILE}` | grep -v PID | wc -l)" -gt 0 ]; then
    # process is still running
    echo `timestamp` "$0: quit at start: lingering process `cat ${LOCKFILE}`"
    exit 0
  else
    # process not running, but lock file not deleted?
    echo `timestamp` "$0: orphan lock file warning. Lock file deleted."
    rm ${LOCKFILE}
  fi
fi

echo $$ > ${LOCKFILE}

echo Learn Not spam
(doveadm mailbox create -u ${MAILDIRUSER} learn_notspam || true) > /dev/null 2>&1
(doveadm mailbox create -u ${MAILDIRUSER} learn_notspam/processing || true) > /dev/null 2>&1
doveadm move -u ${MAILDIRUSER} learn_notspam/processing mailbox learn_notspam ALL
doveadm flags add -u ${MAILDIRUSER} '\Seen' mailbox learn_notspam/processing ALL
/usr/bin/bogofilter -d /app/bogofilter/${MAILDIRUSER}/ \
  -Sn \
  -B \
  -v \
  /srv/mail/${MAILDIRUSER}/Maildir/.learn_notspam.processing/{cur,new}/
doveadm move -u ${MAILDIRUSER} INBOX mailbox learn_notspam/processing ALL

echo Learn spam
(doveadm mailbox create -u ${MAILDIRUSER} Junk || true) > /dev/null 2>&1
(doveadm mailbox create -u ${MAILDIRUSER} learn_spam || true) > /dev/null 2>&1
(doveadm mailbox create -u ${MAILDIRUSER} learn_spam/processing || true) > /dev/null 2>&1
doveadm move -u ${MAILDIRUSER} learn_spam/processing mailbox learn_spam ALL
doveadm flags add -u ${MAILDIRUSER} '\Seen' mailbox learn_spam/processing ALL
/usr/bin/bogofilter -d /app/bogofilter/${MAILDIRUSER}/ \
  -Ns \
  -B \
  -v \
  /srv/mail/${MAILDIRUSER}/Maildir/.learn_spam.processing/{cur,new}/
doveadm move -u ${MAILDIRUSER} Junk mailbox learn_spam/processing ALL

echo delete old spam
doveadm expunge -u ${MAILDIRUSER} mailbox Junk savedbefore 60d

rm ${LOCKFILE}