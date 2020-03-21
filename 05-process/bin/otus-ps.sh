#!/usr/bin/env bash

re_num='^[0-9]+$'
re_socket='^.*:\[.*\]$'

printf "%7s %7s %7s %7s %s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"

get_tty() {
    if [[ -L /proc/$pid/fd/0 ]]; then
        tty=$(ls -l /proc/$pid/fd/0 | awk '{print $11}')
        if ! [[ $tty =~ $re_socket ]]; then
            tty=$(echo $tty | cut -c 6-)
            if [[ $tty == "null" ]]; then
                tty="?"
            fi
        fi
    else
        tty="?"
    fi
}

get_stat() {
    stat=$(cat /proc/$pid/stat | awk '{print $3}')
}

get_time() {
    utime=$(cat /proc/$pid/stat | awk '{ print $14 }')
    stime=$(cat /proc/$pid/stat | awk '{ print $15 }')
    seconds="$(($utime + $stime))"
    time=$(printf '%d:%d' $(($seconds%3600/60)) $(($seconds%60)))
}

get_cmd() {
    cmd=$(cat /proc/$pid/cmdline)
    if [[ -z $cmd ]]; then
        cmd="[$(cat /proc/$pid/comm)]"
    fi
}

for proc in /proc/*; do
    pid=$(echo $proc | awk 'BEGIN {FS="/";} { print $3 }')
    if [[ $pid =~ $re_num ]]; then

        get_tty
        get_stat
        get_time
        get_cmd

        printf "%7s %7s %7s %7s %7s\n" "$pid" "$tty" "$stat" "$time" "$cmd"
    fi
done
