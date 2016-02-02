#!/bin/bash

source /etc/bashrc.hadoop

wait_for_srv hdfs-namenode
wait_for_srv hdfs-datanode


trap "echo stopping yarn;su -c stop-yarn.sh hadoop; exit" HUP INT TERM EXIT

su -c 'start-yarn.sh' hadoop

while [ true ];do
    sleep 1
done
