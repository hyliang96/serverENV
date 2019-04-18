

# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
# here=/home/haoyu/mfs/alladduser

alias all="$SHELL $here/all.sh"
allgpu(){
    local server_set=
    if [ $# -eq 0 ]; then
        server_set=g
    else
        server_set=$1
    fi
    all $server_set --no-prompt 'gpustat'
}

. $here/adduser_command.sh


all_adduser(){
    local server_set=
    if [ $# -eq 0 ]; then
        server_set=a
    else
        server_set=$1
    fi
    all $server_set "$(adduser_command)"
}

unset here
