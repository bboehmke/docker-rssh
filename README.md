RSSH
====

Easy to use restricted secure shell for SFTP, SCP and RSYNC.

Based on (https://github.com/atmoz/sftp).

Usage
-----

- Define users as last arguments to `docker run`, one user per argument  
  (syntax: `user:pass[:e][:[uid][:gid]]`).
  - You must set custom UID for your users if you want them to make changes to
    your mounted volumes with permissions matching your host filesystem.
- Mount volumes in user's home folder.

Examples
--------

### Single user and volume

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d bboehmke/rssh \
    foo:123:1001
```

#### Logging in

The OpenSSH server runs by default on port 22, and in this example, we are
forwarding the container's port 22 to the host's port 2222. To log in with an
OpenSSH client, run: `sftp -P 2222 foo@<host-ip>`, `sftp -P 2222 <SRC> <DST>` or
`rsync -e 'ssh -p 2222' <SRC> <DST>`

### Multiple users and volumes

```
docker run \
    -v /host/share:/home/foo/share \
    -v /host/documents:/home/foo/documents \
    -v /host/http:/home/bar/http \
    -p 2222:22 -d bboehmke/rssh \
    foo:123:1001 \
    bar:abc:1002
```

### Encrypted password

Add `:e` behind password to mark it as encrypted. Use single quotes.

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d bboehmke/rssh \
    'foo:$1$0G2g0GSt$ewU0t6GXG15.0hWoOX8X9.:e:1001'
```

Tip: you can use makepasswd to generate encrypted passwords:  
`echo -n 123 | makepasswd --crypt-md5 --clearfrom -`

### Using SSH key (without password)

Create the file `/home/<user>/.ssh/authorized_keys` in a mounted directory or mount the file 
at this location.

```
docker run \
    -v /host/foo_authorized_keys:/home/foo/.ssh/authorized_keys:ro \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d bboehmke/rssh \
    foo::1001
```