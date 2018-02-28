#!/bin/sh

#set up logging support
touch /var/log/dovecot.info /var/log/dovecot.warning /var/log/dovecot.err /var/log/dovecot.crit
syslogd

dovecot

/bin/sh
