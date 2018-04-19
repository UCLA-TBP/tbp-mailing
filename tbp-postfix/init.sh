#!/bin/sh

#tls support
postfix tls enable-client
postfix tls enable-server

#set up logging support
touch /var/log/postfix.info /var/log/postfix.warning /var/log/postfix.err /var/log/postfix.crit
syslogd

#set up chroot environment
PFROOT=/var/spool/postfix
mkdir -p $PFROOT/etc
cp -r /etc/hosts /etc/localtime /etc/resolv.conf /etc/services /etc/ssl /etc/syslog.conf $PFROOT/etc

#set up permissions of chroot environment
chown root:root $PFROOT
chown root:root $PFROOT/pid

#set up virtual mailboxes
VMAIL=/var/mail/vhosts
mkdir -p $VMAIL
chown -R postfix:postfix $VMAIL

#create postfix databases
postmap /etc/postfix/virtual
postmap /etc/postfix/vmailbox
postmap /etc/postfix/restrict_classes/tbponly
postmap /etc/postfix/restrict_classes/houseleaders
postmap /etc/postfix/access_restrictions
postmap /etc/postfix/sender_bcc
newaliases

postfix start

/bin/sh
