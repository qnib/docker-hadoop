#!/bin/bash

source /etc/bashrc.hadoop
source /opt/qnib/consul/etc/bash_functions.sh

if [ "${HADOOP_HDFS_NAMENODE}" != "true" ];then
    rm -f /etc/consul.d/hdfs-namenode.json
    consul reload
    sleep 2
    exit 0
fi

if [ ! -d /data/hadoopdata/hdfs/namenode ];then
    echo "Formating namenode"
    chown -R hadoop: /data/hadoopdata/hdfs
    su -c '/opt/hadoop/bin/hdfs namenode -format' hadoop
fi
if [ ! -d /data/hadoopdata/logs ];then
    mkdir /data/hadoopdata/logs/
    chown -R hadoop: /data/hadoopdata/logs/
    ln -s /data/hadoopdata/logs /opt/hadoop/
else
    chown -R hadoop: /opt/hadoop/logs
fi

# Wait for sshd to be up'n'running
wait_for_srv ssh

HADOOP_HDFS_NAMENODE_URI=0.0.0.0

consul-template -consul localhost:8500 -once -template "/etc/consul-templates/hdfs/core-site.xml.ctmpl:/opt/hadoop/etc/hadoop/core-site.xml"
su -c '/opt/hadoop/bin/hdfs namenode' hadoop

