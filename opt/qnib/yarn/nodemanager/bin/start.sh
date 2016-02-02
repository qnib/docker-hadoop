#!/bin/bash

source /etc/bashrc.hadoop

function stop_it {
    su -c '/opt/hadoop/sbin/yarn-daemon.sh stop nodemanager' hadoop
}

trap stop_it TERM EXIT

wait_for_srv yarn-resourcemanager

consul-template -consul localhost:8500 -once -template "/etc/consul-templates/yarn/yarn-site.xml.ctmpl:/opt/hadoop/etc/hadoop/yarn-site.xml"
su -c '/opt/hadoop/bin/yarn nodemanager' hadoop
