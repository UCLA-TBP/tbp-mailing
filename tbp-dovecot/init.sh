#!/bin/sh

#set up logging support
touch /etc/syslog.conf
touch /var/log/dovecot.info /var/log/dovecot.warning /var/log/dovecot.err /var/log/dovecot.crit
echo -e "mail.crit\t/var/log/dovecot.crit" >> /etc/syslog.conf
echo -e "mail.err\t/var/log/dovecot.err" >> /etc/syslog.conf
echo -e "mail.warning\t/var/log/dovecot.warning" >> /etc/syslog.conf
echo -e "mail.info\t/var/log/dovecot.info" >> /etc/syslog.conf
syslogd

dovecot

/bin/sh
