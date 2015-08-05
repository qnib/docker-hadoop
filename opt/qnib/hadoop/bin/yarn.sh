#!/bin/bash

# Wait for hdfs to be up'n'running
sleep 15
su -c 'start-yarn.sh' hadoop
