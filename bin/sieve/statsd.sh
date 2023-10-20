#!/bin/bash

echowithdate()
{
    echo `date +%c`:: $*
}

echowithdate "rs02: $1 - Bogo: $2 - From: $3" >> /srv/mail/statsd.log