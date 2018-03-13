FROM alpine

EXPOSE 25

RUN apk update
RUN apk add postfix openssl

COPY config /etc/postfix
COPY syslog.conf /etc/syslog.conf
COPY init.sh /etc/init.sh

CMD ["sh", "/etc/init.sh"]
