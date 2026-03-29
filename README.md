miniircd -- A (very) simple Internet Relay Chat (IRC) server (which i just ported to a dockerfile)
============================================================

## ☕ Support This Project

<a href="https://www.buymeacoffee.com/josh56432" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="40" />
</a>

Description
-----------

miniircd is a small and limited IRC server written in Python. Despite its size,
it is a functional alternative to a full-blown ircd for private or internal
use. Installation is simple; no configuration is required.

This is a Dockerfile fork

Installation
--------
From source:
```bash
git clone https://github.com/josh56432/miniircd-docker.git
cd miniircd-docker
docker build -t miniircd .
docker run -p 6667:6667 -e PORTS=6667 -e SETUID=root miniircd
```

Dockerhub:
```bash
docker run -p 6667:6667 -e PORTS=6667 -e SETUID=root docker.io/josh56432/miniircd
```
(Podman compatible)

Features
--------

* Knows about the basic IRC protocol and commands.
* Easy installation.
* Basic SSL support.
* No configuration.
* No ident lookup (so that people behind firewalls that filter the ident port
  without sending NACK can connect without long timeouts).
* Reasonably secure when used with --chroot and --setuid.


Limitations
-----------

* Can't connect to other IRC servers.
* Only knows the most basic IRC commands.
* No IRC operators.
* No channel operators.
* No user or channel modes except channel key.
* No reverse DNS lookup.
* No other mechanism to reject clients than requiring a password.

# Docker Environment Variable Usage

This container wraps miniircd server. Instead of passing `--flags` directly, configure the server using Docker's `-e` (environment variable) flags.

## Quick Start

```bash
docker run -e PORTS=6667 -e PASSWORD=secret josh56432/miniircd
```

---

## Flag Reference

Each `--flag` has a corresponding `-e` environment variable equivalent.

| `--` Flag | `-e` Environment Variable | Example Value |
|---|---|---|
| `--channel-log-dir X` | `CHANNEL_LOG_DIR` | `/var/log/channels` |
| `--chroot X` | `CHROOT` | `/var/run/ircd` |
| `--cloak X` | `CLOAK` | `myhostname.com` |
| `-d, --daemon` | `DAEMON` | `1` |
| `--ipv6` | `IPV6` | `1` |
| `--debug` | `DEBUG` | `1` |
| `--listen X` | `LISTEN` | `0.0.0.0` |
| `--log-count X` | `LOG_COUNT` | `10` |
| `--log-file X` | `LOG_FILE` | `/var/log/ircd.log` |
| `--log-max-size X` | `LOG_MAX_SIZE` | `10` |
| `--motd X` | `MOTD` | `/etc/ircd/motd.txt` |
| `--pid-file X` | `PID_FILE` | `/var/run/ircd.pid` |
| `-p, --password X` | `PASSWORD` | `mysecretpassword` |
| `--password-file X` | `PASSWORD_FILE` | `/run/secrets/password` |
| `--ports X` | `PORTS` | `6667,6697` |
| `--setuid U[:G]` | `SETUID` | `ircd:ircd` |
| `--ssl-cert-file FILE` | `SSL_CERT_FILE` | `/certs/server.crt` |
| `--ssl-key-file FILE` | `SSL_KEY_FILE` | `/certs/server.key` |
| `-s, --ssl-pem-file FILE` | `SSL_PEM_FILE` | `/certs/server.pem` |
| `--state-dir X` | `STATE_DIR` | `/var/lib/ircd` |
| `--verbose` | `VERBOSE` | `1` |

> **Boolean flags** (`--daemon`, `--ipv6`, `--debug`, `--verbose`) are enabled by setting their variable to any non-empty value (e.g. `1` or `true`). Omitting the variable disables them.

---

## Examples

### Minimal — plain IRC server on port 6667

```bash
docker run -e PORTS=6667 josh56432/miniircd
```

### With password and logging

```bash
docker run \
  -e PORTS=6667 \
  -e PASSWORD=secret \
  -e LOG_FILE=/var/log/ircd.log \
  -e LOG_COUNT=5 \
  josh56432/miniircd
```

### SSL enabled

```bash
docker run \
  -e PORTS=6697 \
  -e SSL_CERT_FILE=/certs/server.crt \
  -e SSL_KEY_FILE=/certs/server.key \
  -v /path/to/certs:/certs \
  josh56432/miniircd
```

### Debug mode with verbose output

```bash
docker run \
  -e PORTS=6667 \
  -e DEBUG=1 \
  -e VERBOSE=1 \
  josh56432/miniircd
```

### Using an env file

For many variables, use `--env-file` instead of multiple `-e` flags:

```bash
docker run --env-file .env josh56432/miniircd
```

Example `.env` file:

```env
PORTS=6667,6697
PASSWORD=mysecretpassword
LOG_FILE=/var/log/ircd.log
LOG_COUNT=10
LOG_MAX_SIZE=10
STATE_DIR=/var/lib/ircd
VERBOSE=1
```

---

## Passing Flags Directly (Alternative)

If you prefer, you can still pass `--` flags directly to the container by appending them after the image name:

```bash
docker run josh56432/miniircd --ports 6667 --password secret --verbose
```

This can be combined with `-e` variables — direct flags take precedence over environment variables for the same option.


Using `--chroot` and `--setuid`
-------------------------------

In order to use the `--chroot` or `--setuid` options, you must be using an OS
that supports these functions (most Unix-like systems), and you must start the
server as root. These options limit the daemon process to a small subset of the
filesystem, running with the privileges of the specified user (ideally
unprivileged) instead of the user who launched miniircd.

To create a new chroot jail for miniircd, edit the Makefile and change JAILDIR
and JAILUSER to suit your needs, then run ``make jail`` as root. If you have a
motd file or an SSL PEM file, you'll need to put them in the jail as well:

    cp miniircd.pem motd.txt /var/jail/miniircd

Remember to specify the paths for `--state-dir`, `--channel-log-dir`, `--motd`
and `--ssl-pem-file` from within the jail, e.g.:

    miniircd --state-dir=/ --channel-log-dir=/ --motd=/motd.txt \
        --setuid=nobody --ssl-pem-file=/miniircd.pem --chroot=/var/jail/miniircd

Make sure your jail is writable by whatever user/group you are running the
server as. Also, keep your jail clean. Ideally it should only contain the files
mentioned above and the state/log files from miniircd. You should **not** place
the miniircd script itself, or any executables, in the jail. In the end it
should look something like this:

    # ls -alR /var/jail/miniircd
    .:
    total 36
    drwxr-xr-x 3 nobody root   4096 Jun 10 16:20 .
    drwxr-xr-x 4 root   root   4096 Jun 10 18:40 ..
    -rw------- 1 nobody nobody   26 Jun 10 16:20 #channel
    -rw-r--r-- 1 nobody nobody 1414 Jun 10 16:51 #channel.log
    drwxr-xr-x 2 root   root   4096 Jun 10 16:19 dev
    -rw-r----- 1 rezrov nobody 5187 Jun  9 22:25 ircd.pem
    -rw-r--r-- 1 rezrov nobody   17 Jun  9 22:26 motd.txt

    ./dev:
    total 8
    drwxr-xr-x 2 root   root   4096 Jun 10 16:19 .
    drwxr-xr-x 3 nobody root   4096 Jun 10 16:20 ..
    crw-rw-rw- 1 root   root   1, 3 Jun 10 16:16 null
    crw-rw-rw- 1 root   root   1, 9 Jun 10 16:19 urandom


License
-------

GNU General Public License version 2 or later.


Primary author miniircd
--------------

- Joel Rosdahl <joel@rosdahl.net>


Contributors miniircd
------------

- Alex Wright
- Braxton Plaxco
- Hanno Foest
- Jan Fuchs
- John Andersen
- Julien Castiaux
- Julien Monnier
- Leandro Lucarella
- Leonardo Taccari
- Martin Maney
- Matt Baxter
- Matt Behrens
- Michael Rene Wilcox
- Ron Fritz
