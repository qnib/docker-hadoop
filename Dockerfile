###### Docker Images
FROM qnib/java8

RUN useradd hadoop 
ENV HADOOP_VER=2.7.2 \
    HADOOP_DFS_REPLICATION=1 \
    HADOOP_HDFS_NAMENODE=false \
    HADOOP_HDFS_NAMENODE_PORT=8020 \
    HADOOP_HDFS_NAMENODE_URI=localhost \
    HADOOP_YARN_RESOURCEMANAGER=false
RUN curl -fsL http://apache.claz.org/hadoop/common/hadoop-${HADOOP_VER}/hadoop-${HADOOP_VER}.tar.gz | tar xzf - -C /opt && mv /opt/hadoop-${HADOOP_VER} /opt/hadoop
ADD opt/hadoop/etc/hadoop/* /opt/hadoop/etc/hadoop/
## Install SSH
RUN yum install -y openssh-server
ADD etc/supervisord.d/sshd.ini /etc/supervisord.d/
ADD opt/qnib/sshd/bin/start.sh /opt/qnib/sshd/bin/
ADD etc/bashrc.hadoop /etc/bashrc.hadoop
RUN echo "source /etc/bashrc.hadoop" >> /etc/bashrc
    
VOLUME ["/data/hadoopdata/hdfs"]
## passwordless login for hadoop user
USER hadoop
RUN ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa && \
    cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys
ADD ssh/config /home/hadoop/.ssh/config
USER root
RUN echo "su -c 'hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-${HADOOP_VER}-tests.jar TestDFSIO -write -nrFiles 64 -fileSize 16GB -resFile /tmp/TestDFSIOwrite.txt' hadoop" >> /root/.bash_history && \
    echo "su -c 'hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.2-tests.jar DistributedFSCheck -resFile /tmp/DistributedFSCheck.txt' hadoop" >> /root/.bash_history && \
    echo "hadoop fs -ls /" >> /root/.bash_history && \
    echo "su -c 'hadoop fs -mkdir /test' hadoop" >> /root/.bash_history && \
    echo "su -c 'hadoop fs -copyFromLocal /etc/hosts /test/' hadoop" >> /root/.bash_history
ADD etc/supervisord.d/hdfs-datanode.ini \
    etc/supervisord.d/hdfs-namenode.ini \
    etc/supervisord.d/sshd.ini \
    etc/supervisord.d/yarn-resourcemanager.ini \
    etc/supervisord.d/yarn-nodemanager.ini \
    /etc/supervisord.d/
ADD etc/consul.d/hdfs-namenode.json \
    etc/consul.d/hdfs-datanode.json \
    etc/consul.d/sshd.json \
    etc/consul.d/yarn-resourcemanager.json \
    etc/consul.d/yarn-nodemanager.json \
    /etc/consul.d/
## Namenode Setup
ADD etc/consul-templates/hdfs/namenode/core-site.xml.ctmpl \
    etc/consul-templates/hdfs/namenode/hdfs-site.xml.ctmpl \
    /etc/consul-templates/hdfs/namenode/
ADD opt/qnib/hdfs/namenode/bin/start.sh /opt/qnib/hdfs/namenode/bin/
## Datanode Setup
ADD opt/qnib/hdfs/datanode/bin/start.sh /opt/qnib/hdfs/datanode/bin/
ADD etc/consul-templates/hdfs/hdfs-site.xml.ctmpl /etc/consul-templates/hdfs/
ADD etc/consul-templates/yarn/yarn-site.xml.ctmpl /etc/consul-templates/yarn/
ADD opt/qnib/yarn/resourcemanager/bin/start.sh /opt/qnib/yarn/resourcemanager/bin/
ADD opt/qnib/yarn/resourcemanager/etc/capacity-scheduler.xml \
    opt/qnib/yarn/resourcemanager/etc/yarn-env.sh \
    opt/qnib/yarn/resourcemanager/etc/yarn-site.xml \
    /opt/qnib/yarn/resourcemanager/etc/
ADD opt/qnib/yarn/nodemanager/bin/start.sh /opt/qnib/yarn/nodemanager/bin/
ADD opt/qnib/yarn/resourcemanager/etc/capacity-scheduler.xml \
    opt/qnib/yarn/resourcemanager/etc/yarn-env.sh \
    opt/qnib/yarn/resourcemanager/etc/yarn-site.xml \
    /opt/qnib/yarn/resourcemanager/etc/
ADD opt/qnib/hdfs/namenode/etc/hadoop-env.sh \
    opt/qnib/hdfs/namenode/etc/hdfs-site.xml \
    /opt/qnib/hdfs/namenode/etc/
ADD opt/qnib/hdfs/datanode/etc/hadoop-env.sh \
    opt/qnib/hdfs/datanode/etc/hdfs-site.xml \
    /opt/qnib/hdfs/datanode/etc/
ADD etc/consul-templates/hadoop/core-site.xml.ctmpl \
    /etc/consul-templates/hadoop/
ADD opt/qnib/hadoop/bin/configure.sh /opt/qnib/hadoop/bin/
ADD etc/supervisord.d/hadoop-configure.ini /etc/supervisord.d/
ADD etc/supervisord.d/consul.ini /etc/supervisord.d/


