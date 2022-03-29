#!/bin/bash

GETMAILDIR="/app/getmailrc"

timestamp()
{
 date +"%Y-%m-%d %T"
}

if [ -f /tmp/rungetmail.lock ] ; then
  # the lock file already exists, so what to do?
  if [ "$(ps -p `cat /tmp/rungetmail.lock` | grep -v PID | wc -l)" -gt 0 ]; then
    # process is still running
    echo `timestamp` "$0: quit at start: lingering process `cat /tmp/rungetmail.lock`"
    exit 0
  else
    # process not running, but lock file not deleted?
    echo `timestamp` "$0: orphan lock file warning. Lock file deleted."
    rm /tmp/rungetmail.lock
  fi
fi

echo $$ > /tmp/rungetmail.lock

for RCFILE in $(ls -1 ${GETMAILDIR}/*.getmailrc); do
  echo `timestamp` $RCFILE
  /usr/bin/timeout -k 15m 10m \
    /usr/bin/getmail \
    --getmaildir /app/getmail \
    --quiet \
    --rcfile $RCFILE
  STATUS=$?
  if [ $STATUS -gt 0 ]; then
    echo `timestamp` getmail $RCFILE failed with status $STATUS
  fi
done

rm /tmp/rungetmail.lock
