#!/usr/bin/env bash


tmp_log=$(mktemp /tmp/tmp.XXXXXXXXXX)
tmp_finish=$(mktemp /tmp/tmp.XXXXXXXXXX)

echo $tmp_log
echo $tmp_finish

exit_func() {
    pkill -P $$
    rm $tmp_log $tmp_finish
}
trap exit_func SIGINT

watch -n 1 -t "sort -n $tmp_log" &

{
    du -axhd1  --block-size=1G $@ >> $tmp_log
    echo 1 >> $tmp_finish
} &

while true; do
    if [ "`cat $tmp_finish`" != '' ]; then
        exit_func
    fi
done


wait

exit_func
