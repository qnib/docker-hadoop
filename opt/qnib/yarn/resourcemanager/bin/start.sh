#!/bin/bash

source /etc/bashrc.hadoop

if [ "${HADOOP_YARN_RESOURCEMANAGER}" != "true" ];then
    rm -f /etc/consul.d/yarn-resourcemanager.json
    consul reload
    sleep 2
    exit 0
fi

function stop_it {
    su -c '/opt/hadoop/sbin/yarn-daemon.sh stop resourcemanager' hadoop
}

trap stop_it TERM EXIT

wait_for_srv hdfs-namenode
wait_for_srv hdfs-datanode


su -c '/opt/hadoop/sbin/yarn-daemon.sh start resourcemanager' hadoop
sleep 3

tail -f /opt/hadoop/logs/yarn-hadoop-resourcemanager-*
