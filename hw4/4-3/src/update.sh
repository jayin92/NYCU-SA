#!/usr/local/bin/bash

while true
do
    free_space=`df / | tail -n +2 | tr -s " " | cut -d" " -f3`;
    total_space=`df / | tail -n +2 | tr -s " " | cut -d" " -f4`;
    boot_time=`sysctl -a | grep kern.boottime | cut -d '=' -f 2 | cut -d ',' -f 1 | tr -d " "`;
    current_time=`date +%s`;
    echo $free_space > ./data/free_space.txt
    echo $total_space > ./data/total_space.txt
    echo $boot_time > ./data/boot_time.txt
    echo $current_time > ./data/current_time.txt
done