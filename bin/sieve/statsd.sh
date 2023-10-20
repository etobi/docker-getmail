#!/bin/bash

echowithdate()
{
    echo `date +%c`:: $*
}

echowithdate "rs02: $1 - bogo: $2 - from: $3" >> /srv/mail/statsd.log
