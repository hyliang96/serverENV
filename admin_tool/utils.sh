#!/bin/bash

is_array() {
    local array_name="$1"
    if [[ "$(declare -p $array_name)" =~ 'declare -a ' ]] || \
       [[ "$(declare -p $array_name)" =~ 'typeset -g -a ' ]] || \
       [[ "$(declare -p $array_name)" =~ 'typeset -a ' ]] ; then
        echo true
    else
        echo false
    fi
}


here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
. $here/all_config.sh

# 检查server_set是否有效
parse_server_set()
{
    # local server_set=
    eval "local server_set=($1)"
    local servers_var="$2"
    eval "$servers_var=()"

    if ! [ "$(is_array server_set)" = true ]; then
        echo 'invalid server_set' >&2
        echo "Usage: <server_set_name> '<command>'"
        echo "Usage: 'server1 server2 server3' '<command>'"
        echo "Usage: all 'server1 server2 server{3..5} server{10..13}' '<command>'"
        exit
    fi

    for i in $server_set; do
        if [[ " ${server_sets[@]} " =~ " $i " ]]; then
            eval "$servers_var=( \${$servers_var[@]} \${$i[@]} )"
        else
            eval "$servers_var=( \${$servers_var[@]} $i )"
        fi
    done

    # valid_server=false
    # for i in ${server_sets[@]}; do
        # if [ "$i" = "$server_set" ]; then
            # valid_server=true
            # break
        # fi
    # done

    # if [ "$valid_server" = false ]; then
        # #  服务器列表生成
        # eval "$servers_var=($server_set)"
        # if ! [ "$(is_array $servers_var)" = true ]; then
            # echo 'invalid server_set' >&2
            # echo "Usage: <server_set_name> '<command>'"
            # echo "Usage: 'server1 server2 server3' '<command>'"
            # echo "Usage: all 'server1 server2 server{3..5} server{10..13}' '<command>'"
            # exit
        # fi
    # else
        # #  服务器列表生成
        # eval "$servers_var=(\${$server_set[@]})"
    # fi
}
