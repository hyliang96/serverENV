#!/usr/bin/env bash


manual_set(){
    echo -n 'set username: ' >&2 ; read -r username
    echo -n 'set realname: ' >&2 ; read -r realname
    echo -n 'set uid: ' >&2 ; read uid
    while true; do
        echo -n 'set password: ' >&2 ; read -sr password; echo '' >&2
        echo -n 'check password: ' >&2 ; read -sr password2; echo '' >&2
        if [ "$password" = "$password2" ]; then
            break
        else
            echo 'passwords are not the same, re-input it' >&2
        fi
    done
    local enc_password=$(echo "$password" | openssl passwd -1 -stdin)
    # echo -En "$username
# $realname
# $uid
# $password"

    # echo -En $username
    # echo -En $realname
    # echo -En $uid
    # echo -En $password
    # echo -E
}

adduser_command(){
    # non interactive

    if [ "$1" = '-n' ]; then
        shift
        local username=$1
        local realname=$2
        local uid=$3
        local enc_password=$4
    elif [ $# -eq 0 ]; then
        echo -n 'set username: ' >&2 ; read -r username
        echo -n 'set realname: ' >&2 ; read -r realname
        echo -n 'set uid: ' >&2 ; read uid
        while true; do
            echo -n 'set password: ' >&2 ; read -sr password; echo '' >&2
            echo -n 'check password: ' >&2 ; read -sr password2; echo '' >&2
            if [ "$password" = "$password2" ]; then
                break
            else
                echo 'passwords are not the same, re-input it' >&2
            fi
        done
        local enc_password=$(echo "$password" | openssl passwd -1 -stdin)
    else
        echo 'Usage:
* interactively:     `adduser_command`
    realname can contains English letters in low/captital case, chinese characters, `'\''``. `"`,-,_ ,sapce,etc
* non-interactively: `adduser_command -n <username> <realname> <uid> <enc_password>`
    the enc_password is gotten by
        `openssl rand -base64 24`  generate 24-letter random password
        `openssl passwd -1`        to encrypted the password
        `sudo cat /etc/shadow`     to see encrypted user password' >&2
        return
    fi

    # echo -En $username
    # echo -En $realname
    # echo -En $uid
    # echo -En $password


    # # encrypt user password
    # local enc_password=$(echo "$password" | openssl passwd -1 -stdin)
    # echo "password = '$password'" >&2
    # # return useradd command
    username=${username//\'/\'\\\'\'}
    username=${username//\"/\'\\\"\'}
    realname=${realname//\'/\'\\\'\'}
    realname=${realname//\"/\'\\\"\'}
    enc_password=${enc_password//\'/\'\\\'\'}
    enc_password=${enc_password//\"/\'\\\"\'}

    echo -E "useradd '$username' -m -c '$realname' -s /usr/bin/zsh -u $uid && usermod --password '$enc_password' '$username'"
}

# 用法

# `all -c "$(alladduser test_name 'TEST NAME' UID password)"`

# `sudo su`
# `zsh all.sh junall "$(adduser_command)"`   # 双引号不得少，不得用单引号

# `echo $password | openssl passwd -1 -stdin`  encrypt $password by how linux encrypts user password
# `openssl rand -base64 24`  generate 24-letter random string
# `sudo cat /etc/shadow` to see encrypted user password

