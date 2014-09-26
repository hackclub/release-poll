# release-poll

This projects polls a repository on GitHub and sends an email to the specified 
recipients when a new release is created. Useful for quickly updating packages
that you're the maintainer for.

## Usage

release-poll is best run in a Docker container and requires the following
environment variables to be set:

```
REPOSITORY - GitHub repository to poll. Ex. 'hackedu/release-poll'
SMTP_ADDRESS - Address to SMTP server. Ex. 'smtp.beeblebrox.com'
SMTP_PORT - Port to use to connect to SMTP server. Ex. '587'
SMTP_DOMAIN - Personal domain for email you'll send from. Ex. 'beeblebrox.com'
SMTP_USERNAME - Username to SMTP server. Ex. 'zaphod'
SMTP_PASSWORD - Password for SMTP server. Ex. 'Beeblebrox123'
RECIPIENT_EMAILS - Comma-separated list of one-or-more emails to send
                   notifications to. Ex. 'zaphod@beeblebrox.com',
                   'zaphod@beeblebrox.com,arthur@dent.com'
FROM_EMAIL - Identity to send emails from. Ex.
             'Marvin the Paranoid <marvin@beeblebrox.com>'
```

Do note that only connecting to the SMTP server with STARTTLS is supported. The
current polling interval is also every ten minutes.

##### CoreOS

Example systemd unit for CoreOS deployment that watches
[coreos/fleet](https://github.com/coreos/fleet):

```
[Unit]
Description=release-poll fleet

[Service]
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill release-poll-fleet
ExecStartPre=-/usr/bin/docker rm release-poll-fleet
ExecStart=/bin/sh -c '/usr/bin/docker run --rm --name release-poll-fleet \
  -e REPOSITORY=$(/usr/bin/etcdctl get /app/release-poll/fleet/repository) \
  -e SMTP_ADDRESS=$(/usr/bin/etcdctl get /secrets/smtp/address) \
  -e SMTP_PORT=$(/usr/bin/etcdctl get /secrets/smtp/port) \
  -e SMTP_USERNAME=$(/usr/bin/etcdctl get /secrets/smtp/username) \
  -e SMTP_PASSWORD=$(/usr/bin/etcdctl get /secrets/smtp/password) \
  -e SMTP_DOMAIN=$(/usr/bin/etcdctl get /app/release-poll/fleet/from_domain) \
  -e RECIPIENT_EMAILS=$(/usr/bin/etcdctl get /app/release-poll/fleet/recipient_emails) \
  -e FROM_EMAIL="$(/usr/bin/etcdctl get /app/release-poll/fleet/from_email)" \
  hackedu/release-poll'
ExecStop=/usr/bin/docker stop release-poll-fleet
```

It expects the following configuration options to be set in etcd:

```
/app/release-poll/fleet/repository
/app/release-poll/fleet/recipient_emails
/app/release-poll/fleet/from_domain
/app/release-poll/fleet/from_email
/secrets/smtp/address
/secrets/smtp/port
/secrets/smtp/username
/secrets/smtp/password
```

## License

The MIT License (MIT)

Copyright (c) 2014 hackEDU

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
