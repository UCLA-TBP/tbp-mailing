FROM alpine

RUN apk update
RUN apk add dovecot

COPY config /etc/dovecot

CMD ["sh", "-c", "dovecot; sh"]
