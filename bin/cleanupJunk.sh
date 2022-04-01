#!/bin/bash

MAILDIRUSER="$1"
LOCKFILE="/tmp/cleanupJunk.lock"

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

echo delete ${MAILDIRUSER} old spam
doveadm expunge -u ${MAILDIRUSER} mailbox Junk savedbefore 60d
echo mark seen ${MAILDIRUSER} yesterdays spam
doveadm flags add -u tobias '\Seen' mailbox Junk savedbefore 1d
rm ${LOCKFILE}
