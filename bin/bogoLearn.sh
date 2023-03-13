#!/bin/bash

MAILDIRUSER="$1"
LOCKFILE="/tmp/bogoLearnHam.lock"

if [ ! -f /app/bogofilter/${MAILDIRUSER}/wordlist.db ] ; then
  exit;
fi

timestamp()
{
 date +"%Y-%m-%d %T"
}

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

echo prepare ${MAILDIRUSER} mailboxes
(doveadm mailbox create -u ${MAILDIRUSER} Junk || true) > /dev/null 2>&1
(doveadm mailbox create -u ${MAILDIRUSER} learn_spam || true) > /dev/null 2>&1
(doveadm mailbox create -u ${MAILDIRUSER} learn_spam/processing || true) > /dev/null 2>&1
(doveadm mailbox create -u ${MAILDIRUSER} learn_notspam || true) > /dev/null 2>&1
(doveadm mailbox create -u ${MAILDIRUSER} learn_notspam/processing || true) > /dev/null 2>&1
(doveadm mailbox create -u ${MAILDIRUSER} Archive || true) > /dev/null 2>&1


echo Learn ${MAILDIRUSER} Not spam
doveadm move \
  -u ${MAILDIRUSER} \
  learn_notspam/processing \
  MAILBOX 'learn_notspam' ALL
doveadm flags add \
  -u ${MAILDIRUSER} \
  '\Seen $NotJunk NotJunk' \
  MAILBOX 'learn_notspam/processing' ALL
doveadm flags remove \
  -u ${MAILDIRUSER} \
  '\Flagged $MailFlagBit0 $MailFlagBit2' \
  MAILBOX 'learn_notspam/processing' ALL
/usr/bin/bogofilter \
  -d /app/bogofilter/${MAILDIRUSER}/ \
  -Sn \
  -B \
  -v \
  /srv/mail/${MAILDIRUSER}/Maildir/.learn_notspam.processing/{cur,new}/
doveadm move \
  -u ${MAILDIRUSER} \
  INBOX \
  MAILBOX 'learn_notspam/processing' ALL


echo Learn ${MAILDIRUSER} spam
doveadm move \
  -u ${MAILDIRUSER} \
  'learn_spam/processing' \
  MAILBOX 'learn_spam' ALL
doveadm flags add \
  -u ${MAILDIRUSER} \
  '\Seen' \
  MAILBOX 'learn_spam/processing' ALL
doveadm flags remove \
  -u ${MAILDIRUSER} \
  '\Flagged $MailFlagBit0 $MailFlagBit2 $NotJunk NotJunk' \
  MAILBOX 'learn_notspam/processing' ALL
/usr/bin/bogofilter \
  -d /app/bogofilter/${MAILDIRUSER}/ \
  -Ns \
  -B \
  -v \
  /srv/mail/${MAILDIRUSER}/Maildir/.learn_spam.processing/{cur,new}/
doveadm move \
  -u ${MAILDIRUSER} \
  Junk \
  MAILBOX learn_spam/processing ALL


echo Learn ${MAILDIRUSER} archived unsure mails as ham
doveadm flags add \
  -u ${MAILDIRUSER} '$bogoLearnAsHam' \
  MAILBOX 'Archive' SAVEDSINCE 1h HEADER "X-Bogosity" "Unsure" UNKEYWORD '$bogoLearnedAsHam'

doveadm fetch \
  -u ${MAILDIRUSER} \
  guid \
  MAILBOX 'Archive' KEYWORD '$bogoLearnAsHam' \
  | grep 'guid:' \
  | awk -F': ' '{print $2}' \
  | xargs -I _ \
  sh -c "doveadm fetch -u ${MAILDIRUSER} text MAILBOX 'Archive' GUID '_' | bogofilter -d /app/bogofilter/${MAILDIRUSER}/ -Sn -v"

doveadm flags add \
  -u ${MAILDIRUSER} \
  '$bogoLearnedAsHam' \
  MAILBOX 'Archive' KEYWORD '$bogoLearnAsHam'
doveadm flags remove \
  -u ${MAILDIRUSER} \
  '$bogoLearnAsHam' \
  MAILBOX 'Archive' KEYWORD '$bogoLearnedAsHam'

rm ${LOCKFILE}

exit 0;
