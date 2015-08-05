###### Docker Images
FROM qnib/terminal

RUN yum install -y java-1.7.0-openjdk && \
    useradd hadoop 
ENV HADOOP_VER=2.5.2
RUN curl -fsL http://apache.claz.org/hadoop/common/hadoop-${HADOOP_VER}/hadoop-${HADOOP_VER}.tar.gz | tar xzf - -C /opt && mv /opt/hadoop-${HADOOP_VER} /opt/hadoop
ADD opt/hadoop/etc/hadoop/* /opt/hadoop/etc/hadoop/
## Install SSH
RUN yum install -y openssh-server
ADD etc/supervisord.d/sshd.ini /etc/supervisord.d/
ADD etc/consul.d/check_sshd.json /etc/consul.d/
ADD opt/qnib/bin/startup_sshd.sh /opt/qnib/bin/
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
ADD opt/qnib/hadoop/bin/ /opt/qnib/hadoop/bin/
ADD etc/supervisord.d/hdfs.ini etc/supervisord.d/yarn.ini /etc/supervisord.d/
