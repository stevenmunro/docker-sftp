#!/bin/bash

for users in "$@"; do
    IFS=':' read -a data <<< "$users"
    user="${data[0]}"
    pass="${data[1]}"

    if [ "${data[2]}" == "e" ]; then
        chpasswdOptions="-e"
        uid="${data[3]}"
        gid="${data[4]}"
    else
        uid="${data[2]}"
        gid="${data[3]}"
    fi

    useraddOptions="--create-home --no-user-group"

    if [ -n "$uid" ]; then
        useraddOptions="$useraddOptions --non-unique --uid $uid"
    fi

    if [ -n "$gid" ]; then
        useraddOptions="$useraddOptions --gid $gid"
        groupadd --gid $gid $gid
    fi

    useradd $useraddOptions $user
    chown root:root /home/$user
    chmod 755 /home/$user

    if [ -z "$pass" ]; then
        pass="$(echo `</dev/urandom tr -dc A-Za-z0-9 | head -c256`)"
        chpasswdOptions=""
    fi

    echo "$user:$pass" | chpasswd $chpasswdOptions

    cat /home/$user/.ssh/keys/* >> /home/$user/.ssh/authorized_keys
    chown $user /home/$user/.ssh/authorized_keys
    chmod 600 /home/$user/.ssh/authorized_keys
done

exec /usr/sbin/sshd -D