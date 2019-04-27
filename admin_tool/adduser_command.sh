#!/usr/bin/env bash


manual_set(){
    local username=
    local realname=
    local uid=
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
    echo -E "$username"
    echo -E "$realname"
    echo -E "$uid"
    echo -E "$enc_password"
    eval $1=\"\$username\"
    eval $2=\"\$realname\"
    eval $3=\"\$uid\"
    eval $4=\"\$enc_password\"
    echo 1 $1
    echo 2 $2
    echo 3 $3
    echo 4 $4
}

adduser_command(){

    if [ "$1" = '-n' ]; then
        shift
        local username=$1
        local realname=$2
        local uid=$3
        local enc_password=$4
    elif [ $# -eq 0 ]; then
        local username=
        local realname=
        local uid=
        local enc_password=
        manual_set username realname uid enc_password
        echo -E "$username"
        echo -E "$realname"
        echo -E "$uid"
        echo -E "$enc_password"
        # local username=
        # local realname=
        # local realname=
        # echo -n 'set username: ' >&2 ; read -r username
        # echo -n 'set realname: ' >&2 ; read -r realname
        # echo -n 'set uid: ' >&2 ; read uid
        # while true; do
        #     echo -n 'set password: ' >&2 ; read -sr password; echo '' >&2
        #     echo -n 'check password: ' >&2 ; read -sr password2; echo '' >&2
        #     if [ "$password" = "$password2" ]; then
        #         break
        #     else
        #         echo 'passwords are not the same, re-input it' >&2
        #     fi
        # done
        # local enc_password=$(echo "$password" | openssl passwd -1 -stdin)
    else
        echo 'Usage:
* interactively:    `adduser_command`
    realname can contains English letters in low/captital case, chinese characters, `'\''``. `"`,-,_ ,sapce,etc
* non-interactively: `adduser_command -n <username> <realname> <uid> <enc_password>`
    the enc_password is gotten by
        method1      `openssl passwd -1`         to encrypted the password
        method2      `sudo cat /etc/shadow`      the 2nd part (segmented by ":") is encrypted user password
Attention:
    * please set user'\''s uid the same on all server machines, or authorization will wrong under mfs folder
    * generate random password: `openssl rand -base64 24`  24-letter, on 64-bit machine' >&2
        return
    fi

    username=${username//\'/\'\\\'\'}
    username=${username//\"/\'\\\"\'}
    realname=${realname//\'/\'\\\'\'}
    realname=${realname//\"/\'\\\"\'}
    enc_password=${enc_password//\'/\'\\\'\'}
    enc_password=${enc_password//\"/\'\\\"\'}

    echo -E "useradd '$username' -m -c '$realname' -s /usr/bin/zsh -u $uid && usermod --password '$enc_password' '$username'"
}

# alladduser()
# {

#     su - test -c 'ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -q && \
#      cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'

#     send /home/test/.ssh  a:/home/test/
# }


