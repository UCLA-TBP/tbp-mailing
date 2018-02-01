#!/bin/sh

PFROOT=/var/spool/postfix
mkdir -p $PFROOT/etc
cp -r /etc/hosts /etc/localtime /etc/resolv.conf /etc/services /etc/ssl $PFROOT/etc

chown root:root $PFROOT
chown root:root $PFROOT/pid

postmap /etc/postfix/virtual
postmap /etc/postfix/restrict_classes/tbponly
postmap /etc/postfix/restrict_classes/houseleaders
postmap /etc/postfix/access_restrictions
newaliases

postfix start

/bin/sh
