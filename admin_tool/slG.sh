#!/usr/bin/env bash

here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
here="`echo $here | sed 's/^\/mfs\/\([^\/]\+\)/\/home\/\1\/mfs/'`"
. ${here}/utils.sh

tmp_log=$(mktemp /tmp/tmp.XXXXXXXXXX)
tmp_log_sort=$(mktemp /tmp/tmp.XXXXXXXXXX)
tmp_finish=$(mktemp /tmp/tmp.XXXXXXXXXX)


# echo $tmp_log
# echo $tmp_finish

exit_func() {
    # 杀死所有子进程
    pkill -P $$
    cat $tmp_log_sort
    # sort -n $tmp_log
    if [ "`cat $tmp_finish`" = 'finished' ]; then echo finished; else echo unfinished; fi
    [ -f $tmp_log ] && rm $tmp_log
    [ -f $tmp_finish ] && rm $tmp_finish
    [ -f $tmp_log_sort ] && rm $tmp_log_sort
}

exit_script() {
    exit_func
    # 退出程序
    exit 1
}

ctrl_c() {
    exit_func
    # 杀死本进程及其子进程
    kill 0
}


trap ctrl_c SIGINT
# trap "exit" INT TERM ERR
# trap "kill 0" EXIT
# trap 'kill background' EXIT


# watch -n 1 -t "sort -n -r $tmp_log" &

{
    for i in `ls $@`; do
        du  -axhd0  --block-size=1G $i >> $tmp_log &
    done
    wait
    # du -axhd1  --block-size=1G $@ >> $tmp_log
    echo finished >> $tmp_finish
    sort -n -r $tmp_log >> $tmp_log_sort
}  &

monitor_file "$tmp_log_sort"

while true; do
    sleep 1
    if [ "`cat $tmp_finish`" = 'finished' ]; then
        exit_script
    fi
done


wait

exit_script
