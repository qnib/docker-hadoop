#!/bin/bash

source /etc/bashrc.hadoop

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


consul-template -consul localhost:8500 -once -template "/etc/consul-templates/yarn/yarn-site.xml.ctmpl:/opt/hadoop/etc/hadoop/yarn-site.xml"
su -c '/opt/hadoop/sbin/yarn-daemon.sh start resourcemanager' hadoop
sleep 3

tail -f /opt/hadoop/logs/yarn-hadoop-resourcemanager-*
