#!/usr/bin/env bash


tmp_log=$(mktemp /tmp/tmp.XXXXXXXXXX)
tmp_finish=$(mktemp /tmp/tmp.XXXXXXXXXX)
BGPID=$!
SCPID=$$

echo $(jobs -p)
echo $tmp_log
echo $tmp_finish

function exit_func() {
    # echo $!
    # pgrep -P $SCPID
    # pkill -P $$
    # killall $tmp_log
    # killall $tmp_finish
    # echo $(jobs -p)
    # kill $(jobs -p)
    # pkill -P $$
    sort -n $tmp_log
    if [ "`cat $tmp_finish`" = '1' ]; then echo finished; else echo unfinished; fi
    [ -f $tmp_log ] && rm $tmp_log
    [ -f $tmp_finish ] && rm $tmp_finish
    # kill $BGPID
    exit 1
}
trap exit_func SIGINT
trap "exit" INT TERM ERR
trap "kill 0" EXIT
# trap 'kill background' EXIT

watch -n 1 -t "sort -n -r $tmp_log" &

{
    du -axhd1  --block-size=1G $@ >> $tmp_log
    echo 1 >> $tmp_finish
} &

while true; do
    sleep 1
    if [ "`cat $tmp_finish`" = '1' ]; then
        exit_func
    fi
done


wait

exit_func
