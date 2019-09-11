#!/usr/bin/env bash


tmp_log=$(mktemp /tmp/tmp.XXXXXXXXXX)
tmp_finish=$(mktemp /tmp/tmp.XXXXXXXXXX)


echo $tmp_log
echo $tmp_finish

exit_func() {
    # 杀死所有子进程
    pkill -P $$
    sort -n $tmp_log
    if [ "`cat $tmp_finish`" = '1' ]; then echo finished; else echo unfinished; fi
    [ -f $tmp_log ] && rm $tmp_log
    [ -f $tmp_finish ] && rm $tmp_finish
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

watch -n 1 -t "sort -n -r $tmp_log" &

{
    du -axhd1  --block-size=1G $@ >> $tmp_log
    echo 1 >> $tmp_finish
} &

while true; do
    sleep 1
    if [ "`cat $tmp_finish`" = '1' ]; then
        exit_script
    fi
done


wait

exit_script
