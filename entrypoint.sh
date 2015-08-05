#!/bin/bash
# Based on entrypoint of https://github.com/atmoz/sftp

# prepare rssh.conf
echo "logfacility = LOG_USER" > /etc/rssh.conf
echo "allowscp" >> /etc/rssh.conf
echo "allowsftp" >> /etc/rssh.conf
echo "allowrsync" >> /etc/rssh.conf
echo "umask = 022" >> /etc/rssh.conf
#echo "chrootpath=/home" >> /etc/rssh.conf

# go through given users
for users in "$@"; do
    # split user
    IFS=':' read -a data <<< "$users"

    # get user and password
    user="${data[0]}"
    pass="${data[1]}"

    # check if given passwords are encrypted
    if [ "${data[2]}" == "e" ]; then
        # enable encrypted option for chpasswd
        chpasswdOptions="-e"

        # get user id and group id
        uid="${data[3]}"
        gid="${data[4]}"
    else
        uid="${data[2]}"
        gid="${data[3]}"
    fi

    # prepare useradd option
    useraddOptions="--create-home --no-user-group --shell /usr/bin/rssh"

    # add user id if given
    if [ -n "$uid" ]; then
        useraddOptions="$useraddOptions --non-unique --uid $uid"
    fi

    # add group id if given
    if [ -n "$gid" ]; then
        useraddOptions="$useraddOptions --gid $gid"

        # add group (suppress warning if group exist)
        groupadd --gid $gid $gid 2> /dev/null
    fi

    # add user (suppress warning if user exist)
    useradd $useraddOptions $user 2> /dev/null

    # add rssh entry
    echo "user=$user:011:100110:" >> /etc/rssh.conf

    # if no password given create random password
    if [ -z "$pass" ]; then
        pass="$(echo `</dev/urandom tr -dc A-Za-z0-9 | head -c256`)"
        chpasswdOptions=""
    fi

    # set password
    echo "$user:$pass" | chpasswd $chpasswdOptions

done
echo >> /etc/rssh.conf

# start ssh daemon
exec /usr/sbin/sshd -D -e