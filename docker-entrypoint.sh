#!/bin/bash

write_lines() {
    LINES_VAR="$1"
    TARGET_FILE="$2"
    TEMPLATE=${3:-"\"\$LINE\""}

    IFS=";"
    for LINE in $LINES_VAR
    do
        eval PROCESSED="$TEMPLATE"
        echo "$PROCESSED" >> "$TARGET_FILE"
    done
}

function start() {
    postconf -e "myorigin = ${MYORIGIN}"
    postconf -e "myhostname = ${MYHOSTNAME:-$(hostname)}"
    postconf -e "smtpd_sasl_local_domain = $myhostname"
    postconf -e "virtual_alias_domains = ${VIRTUAL_ALIAS_DOMAINS:-$MYORIGIN}"

    write_lines "$VIRTUAL_ALIAS_MAPS" "/etc/postfix/virtual"
    postmap /etc/postfix/virtual

    adduser postfix sasl

    groupadd spamd
    useradd -g spamd -s /bin/false -d /var/log/spamassassin spamd
    mkdir /var/log/spamassassin
    chown spamd:spamd /var/log/spamassassin

    useradd -g mail -m $USER
    echo -e "$PASSWORD\n$PASSWORD" | passwd $USER

    mkdir -p /etc/opendkim/keys

    write_lines "$TRUSTED_HOSTS" "/etc/opendkim/TrustedHosts" "\"*.\$LINE\""
    write_lines "$TRUSTED_HOSTS" "/etc/opendkim/KeyTable" "\"mail._domainkey.\$LINE \$LINE:mail:/etc/opendkim/keys/\$LINE/mail.private\""
    write_lines "$TRUSTED_HOSTS" "/etc/opendkim/SigningTable" "\"*@\$LINE mail._domainkey.\$LINE\""
    chown opendkim:opendkim -R /etc/opendkim/keys

    service rsyslog start
    service spamassassin start
    service saslauthd start
    service postfix start
    service opendkim start

    while [ ! -f /var/log/mail.log ]
    do
        sleep 1
    done
    tail -F /var/log/mail.log
}

if [ "$1" = 'start' ]; then
    start
fi
