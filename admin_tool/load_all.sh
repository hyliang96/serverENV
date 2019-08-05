

# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

alias all="$SHELL $here/all.sh"

alias send="$SHELL $here/all.sh --send"

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

. $here/adduser_command.sh

. $here/mfs_set.sh


unset here
