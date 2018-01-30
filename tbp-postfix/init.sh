#!/bin/sh

PFROOT=/var/spool/postfix
mkdir -p $PFROOT/etc
cp -r /etc/hosts /etc/localtime /etc/resolv.conf /etc/services /etc/ssl $PFROOT/etc

chown root:root $PFROOT
chown root:root $PFROOT/pid

postfix start

/bin/sh