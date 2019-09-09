#!/usr/bin/env bash
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
. $here/utils.sh

# 生成随机密码
randpasswd()
{
    if [ "$1" = help ] || [ "$1" = '--help' ] || [ "$1" = '-h' ]; then
        echo "Usage: \`randpasswd [length]\` to generate random passwod of this length"
        return
    fi
    if [ $# -eq 0 ]; then
        local len=24
    else
        local len=$1
    fi
    openssl rand -base64 $len
}

manual_set() {
    local username_=
    local realname_=
    local uid_=
    echo -n 'set username: ' >&2 ; read -r username_
    echo -n 'set realname: ' >&2 ; read -r realname_
    echo -n 'set uid: ' >&2 ; read uid_
    local password=
    while true; do
        echo -n 'set password: ' >&2 ; read -sr password; echo '' >&2
        echo -n 'check password: ' >&2 ; read -sr password2; echo '' >&2
        if [ "$password" = "$password2" ]; then
            break
        else
            echo 'passwords are not the same, re-input it' >&2
        fi
    done
    local enc_password_=$(echo "$password" | openssl passwd -1 -stdin)

    eval $1=\"\$username_\"
    eval $2=\"\$realname_\"
    eval $3=\"\$uid_\"
    eval $4=\"\$enc_password_\"
}

adduser_command() {


    local username=$1
    local realname=$2
    local uid=$3
    local enc_password=$4


    username=${username//\'/\'\\\'\'}
    username=${username//\"/\'\\\"\'}
    realname=${realname//\'/\'\\\'\'}
    realname=${realname//\"/\'\\\"\'}
    enc_password=${enc_password//\'/\'\\\'\'}
    enc_password=${enc_password//\"/\'\\\"\'}

    echo -E "useradd '$username' -m -c '$realname' -s /usr/bin/zsh -u $uid && usermod --password '$enc_password' '$username'"
    echo

    unset username
    unset realname
    unset uid
    unset enc_password
}


allnewkey() {
    if [ $# -ne 2 ]; then
        echo 'Usage: `allnewkey <server_set> <username>`
What it will do:
    regernate ~/.ssh/{id_rsa,id_rsa.pub} for <username>
    add id_rsa.pub to ~/.ssh/authorized_keys
    send ~/.ssh to all servers in <server_set>'
        return
    fi
    local server_set="$1"
    local username="$2"

    echo "=================== making keys in /home/$username/.ssh  ====================="
    # 若已有id_rsa,id_rsa.pub，则会询问你是否覆盖之
    su - $username -c 'ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -q && \
     cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'

    echo "======= seperating /home/$username/.ssh to server set [${server_set}] ========"
    # 会覆盖各个服务器上的原文件
    send /home/$username/.ssh  ${server_set}:/home/$username/
}

_alladduser()
{
    if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]  || \
        ! ( [ $# -eq 0 ] || [ $# -eq 1 ]  || [ $# -eq 5 ] ) ; then
        echo 'Usage:
* interactively:    `alladduser [<server_set> default=a]`
    realname can contains English letters in low/captital case, chinese characters, `'\''``. `"`,-,_ ,sapce,etc
* non-interactively: `alladduser <server_set> <username> <realname> <uid> <enc_password>`
    the enc_password is gotten by
        method1      `openssl passwd -1`         to encrypted the password
        method2      `sudo cat /etc/shadow`      the 2nd part (segmented by ":") is encrypted user password
Attention:
    * please set user'\''s uid the same on all server machines, or authorization will wrong under mfs folder
    * generate random password: `openssl rand -base64 24`  24-letter, on 64-bit machine' >&2
        return
    fi

    if [ $# -eq 0 ]; then
        local server_set='a'
    else
        local server_set="$1"; shift
    fi

    if [ $# -eq 4 ]; then
        local username=$1
        local realname=$2
        local uid=$3
        local enc_password=$4
    else
        local username=
        local realname=
        local uid=
        local enc_password=
        manual_set username realname uid enc_password
    fi


    echo "============================ making user account  ============================"

    all "$server_set" "$(adduser_command $username $realname $uid $enc_password)"

    local servers=()
    parse_server_set "$server_set" servers
    ssh ${servers[1]} ". $admin_tool_path/load_all.sh && allnewkey '$server_set' $username"
}

alladduser()
{
    # echo "`eval echo $here`"
    sudo su -c ". $admin_tool_path/load_all.sh; _alladduser $*"
}

# show uid of all users on this server
uids()
{
    if [ $# -eq 0 ]; then
        awk -F '[:]' '{print $3, $1}' /etc/passwd | sort -nr
    else
        awk -F '[:]' '{print $3, $1}' /etc/passwd | sort -nr | head -n$1
    fi
}

gid()
{
    if [ $# -eq 0 ]; then
        getent group | awk -F '[:]' '{print $3, $1":"$2":"$4}' | sort -n
    else
        getent group $@
    fi
}

# set uid for a user on all servers
allsetuid()
{
    if [ $# -eq 3 ]; then
        local server_set="$1"; shift
    else
        local server_set='a'
    fi
    local username="$1"
    local uid="$2"
    all "$server_set" "usermod -u $uid $username && groupmod -g $uid $username"
}

