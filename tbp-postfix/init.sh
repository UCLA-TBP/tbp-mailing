#!/bin/sh

#set up logging support
touch /etc/syslog.conf
touch /var/log/postfix.info /var/log/postfix.warning /var/log/postfix.err /var/log/postfix.crit
echo -e "mail.crit\t/var/log/postfix.crit" >> /etc/syslog.conf
echo -e "mail.err\t/var/log/postfix.err" >> /etc/syslog.conf
echo -e "mail.warning\t/var/log/postfix.warning" >> /etc/syslog.conf
echo -e "mail.info\t/var/log/postfix.info" >> /etc/syslog.conf
echo -e "mail.debug\t/var/log/postfix.debug" >> /etc/syslog.conf
syslogd

#set up chroot environment
PFROOT=/var/spool/postfix
mkdir -p $PFROOT/etc
cp -r /etc/hosts /etc/localtime /etc/resolv.conf /etc/services /etc/ssl /etc/syslog.conf $PFROOT/etc

#set up permissions of chroot environment
chown root:root $PFROOT
chown root:root $PFROOT/pid

#create postfix databases
postmap /etc/postfix/virtual
postmap /etc/postfix/restrict_classes/tbponly
postmap /etc/postfix/restrict_classes/houseleaders
postmap /etc/postfix/access_restrictions
newaliases

postfix start

/bin/sh
