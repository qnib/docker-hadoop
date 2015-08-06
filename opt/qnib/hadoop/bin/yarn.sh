#!/bin/bash

source /etc/bashrc.hadoop

function check_hdfs {
    cnt_hdfs=$(curl -s localhost:8500/v1/catalog/service/hdfs|grep -c "\"Node\":\"hadoop\"")
    if [ ${cnt_hdfs} -ne 1 ];then
        echo "[start_yarn] No running 'hdfs service yet, sleep 5 sec'"
        sleep 5
        check_hdfs
    fi
}


trap "echo stopping yarn;su -c stop-yarn.sh hadoop; exit" HUP INT TERM EXIT

# Wait for hdfs to be up'n'running
check_hdfs
su -c 'start-yarn.sh' hadoop

while [ true ];do
    sleep 1
done
