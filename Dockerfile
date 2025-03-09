FROM dovecot/dovecot:2.3-latest

ENV TZ="Europe/Berlin"

RUN apt update -qq \
    && apt install --no-install-recommends -y \
    cron \
    moreutils \
    getmail \
    bogofilter \
    curl \
    netcat \
    && rm -fr /var/lib/apt/lists

RUN ln -sf /usr/share/zoneinfo/${TZ:-UTC} /etc/localtime

COPY bin/ /app/bin/
COPY etc/bogofilter.cf /etc/bogofilter.cf
COPY etc/dovecot/ /etc/dovecot/
COPY etc/crontab /etc/cron.d/rungetmail
RUN chmod +x /etc/cron.d/rungetmail \
    && chmod +x /app/bin/*.sh

# Create the pseudo log file to point to stdout
RUN ln -sf /proc/1/fd/1 /var/log/stdout

CMD ["bash", "-c", "/app/bin/start.sh"]
