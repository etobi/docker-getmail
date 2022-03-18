FROM debian:bullseye-slim

ENV TZ="Europe/Berlin"
ENV USER="getmail"

RUN touch /usr/share/man/man5/maildir.maildrop.5.gz \
    && touch /usr/share/man/man7/maildirquota.maildrop.7.gz

RUN apt update -qq \
    && apt install --no-install-recommends -y \
    tini \
    cron \
    moreutils \
    getmail \
    bogofilter \
    maildrop \
    && rm -fr /var/lib/apt/lists

RUN ln -sf /usr/share/zoneinfo/${TZ:-UTC} /etc/localtime

COPY bin/ /app/bin/
RUN chmod +x /app/bin/*.sh

COPY etc/crontab /etc/cron.d/rungetmail
RUN chmod 644 /etc/cron.d/rungetmail

COPY etc/bogofilter.cf /etc/bogofilter.cf

RUN mkdir -p /home/$USER/
RUN useradd --groups=users --shell='/bin/true' "$USER"
RUN ln -s /app/getmail/ /home/$USER/.getmail \
    && ln -s /app/bogofilter/ /home/$USER/.bogofilter
COPY etc/mailfilter /home/$USER/.mailfilter
RUN chown -R "$USER:$USER" "/home/$USER/" \
    && chmod 700 /home/$USER/.mailfilter

RUN mkdir -p /var/log/getmail/ \
    && touch /var/log/getmail/getmail.log \
    && chown -R "$USER:$USER" "/var/log/getmail/"

ENTRYPOINT ["/usr/bin/tini", "--", "/app/bin/entrypoint.sh"]
CMD ["tail", "--follow", "/var/log/getmail/getmail.log"]
