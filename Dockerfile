###### Docker Images
FROM qnib/java7

RUN useradd hadoop 
ENV HADOOP_VER=2.5.2 \
    HADOOP_DFS_REPLICATION=1 \
    HADOOP_HDFS_NAMENODE=false \
    HADOOP_HDFS_NAMENODE_PORT=8020 \
    HADOOP_HDFS_NAMENODE_URI=localhost
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
ADD opt/qnib/hdfs/namenode/bin/start.sh /opt/qnib/hdfs/namenode/bin/
ADD opt/qnib/hdfs/datanode/bin/start.sh /opt/qnib/hdfs/datanode/bin/
ADD etc/supervisord.d/hdfs-datanode.ini \
    etc/supervisord.d/hdfs-namenode.ini \
    etc/supervisord.d/sshd.ini \
    etc/supervisord.d/yarn.ini \
    /etc/supervisord.d/
ADD etc/consul.d/hdfs-namenode.json \
    etc/consul.d/hdfs-datanode.json \
    etc/consul.d/sshd.json \
    /etc/consul.d/
ADD etc/consul-templates/hdfs/hdfs-site.xml.ctmpl \
    etc/consul-templates/hdfs/core-site.xml.ctmpl \
    /etc/consul-templates/hdfs/
