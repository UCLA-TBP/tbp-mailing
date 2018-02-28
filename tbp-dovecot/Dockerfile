FROM alpine

RUN apk update
RUN apk add dovecot

COPY config /etc/dovecot
COPY syslog.conf /etc/syslog.conf
COPY init.sh /etc/init.sh

CMD ["sh", "/etc/init.sh"]
