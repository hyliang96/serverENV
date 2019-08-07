#!/usr/bin/env bash


# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
admin_tool_path="$here"

alias _all="$SHELL $here/all.sh"
all()
{
    _all $@
}

alias _send="$SHELL $here/all.sh --send"
send()
{
    _send $@
}

alluid()
{
    local server_set=
    if [ $# -eq 1 ]; then
        server_set="a"
    else
        server_set="$1"
        shift
    fi
    local uid="$1"
    all "$server_set" --checkuid $uid
}

allgpu()
{
    local server_set=
    if [ $# -eq 0 ]; then
        server_set=g
    else
        server_set="$1"
    fi
    all "$server_set" --no-prompt 'gpustat'
}

# use sudo to do something
admin()
{
    local commands=''
    for i in "$@"; do
        echo "$i"
        if [[ "$i" =~ ' ' ]]; then
            local commands="$commands \"$i\""
        else
            local commands="$commands $i"
        fi
    done
    echo "$commands"
    sudo su -c ". $admin_tool_path/load_all.sh && $commands"
}

. $here/adduser_command.sh

. $here/mfs_set.sh


unset here
