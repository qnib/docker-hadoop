#!/bin/bash

source /etc/bashrc.hadoop
source /opt/qnib/consul/etc/bash_functions.sh

if [ "${HADOOP_YARN_RESOURCEMANAGER}" != "true" ];then
    rm -f /etc/consul.d/yarn-resourcemanager.json
    consul reload
    sleep 2
    exit 0
else
    HADOOP_YARN_RM_HOST=0.0.0.0
fi

function stop_it {
    su -c '/opt/hadoop/sbin/yarn-daemon.sh stop resourcemanager' hadoop
}

trap stop_it TERM EXIT

wait_for_srv hdfs-namenode
wait_for_srv hdfs-datanode

su -c '/opt/hadoop/bin/yarn --config /opt/qnib/yarn/resourcemanager/etc/ resourcemanager' hadoop
