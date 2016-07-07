# docker-mail
This is a simpel postfix setup that:
 - forwards incoming e-mails to an existing emailaddress
 - is able to send e-mails
 - uses spamassassin to fight spam
 - uses saslauth to authenticate (only one user)
 - allows multiple domains
 - uses opendkim

# How to use this image

```
docker run \
  --name mail
  --hostname mail.example.com \
  --volume /data/opendkim/keys:/etc/opendkim/keys \
  --env MYORIGIN="example.com" \
  --env VIRTUAL_ALIAS_DOMAINS="example.com example.nl" \
  --env VIRTUAL_ALIAS_MAPS="@example.com example.com@gmail.com;@example.nl example.nl@gmail.com" \
  --env TRUSTED_HOSTS="example.com;example.nl" \
  --env USER=myusername \
  --env PASSWORD=mysecret \
  --publish 25:25 \
    berrygoudswaard/mail
```

The `hostname` is set as `myhostname` in the file /etc/postfix/main.cf  
`MYORIGIN` is set as `myorigin` in the file /etc/postfix/main.cf  

Use `VIRTUAL_ALIAS_DOMAINS` to tell postfix which domains are OK.  
With `VIRTUAL_ALIAS_MAPS` you can tell postfix what the forward address is for specific domains/mailaddresses.  

`TRUSTED_HOSTS` tells opendkim which domains are OK (seperated by a semicolon)  

The `USER` and `PASSWORD` are for SASL auth. When the container is started user is created automatically.  

Don't forget to create a volume for your opendkim keys. In this example the host folder `/data/opendkim/keys` has
the following structure:
   - data
     - opendkim
       - keys
         - example.com
           - mail.private <-- the opendkim key for example.com
         - example.nl
           - mail.private <-- the opendkim key for example.nl

Use `--env BLACKLIST=zen.spamhaus.org` to configure a blacklist for Postfix.
