#!/bin/bash
set -x

sleep 10
/etc/init.d/ssh restart &
sleep 10

hdfs namenode -format
sleep 10

/root/hadoop/sbin/stop-all.sh
sleep 10

/root/hadoop/sbin/start-all.sh &
sleep 10


cd ~/hadoop
/root/hadoop/bin/hdfs dfs -mkdir /user
/root/hadoop/bin/hdfs dfs -mkdir /user/root
sleep 1


sleep 10
/root/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver  &

sleep 10



sleep 10
log_suffix=`date +"%Y%m%d%H%M%S"`



$CONFLUENT_HOME/bin/zookeeper-server-start $CONFLUENT_HOME/etc/kafka/zookeeper.properties 2>&1  | tee -a /root/zookeeper_console_log/zookeeper_console_$log_suffix.log  > /dev/null &

sleep 30

$CONFLUENT_HOME/bin/kafka-server-start $CONFLUENT_HOME/etc/kafka/server.properties 2>&1  | tee -a /root/kafka_console_log/kafka_console_$log_suffix.log  > /dev/null &

sleep 30

$CONFLUENT_HOME/bin/schema-registry-start $CONFLUENT_HOME/etc/schema-registry/schema-registry.properties 2>&1  | tee -a /root/schema_console_log/schema_console_$log_suffix.log  > /dev/null &

sleep 30


$CONFLUENT_HOME/bin/ksql-server-start $CONFLUENT_HOME/etc/ksqldb/ksql-server.properties 2>&1  | tee -a /root/ksql_console_log/ksql_console_$log_suffix.log  > /dev/null &
sleep 30

$CONFLUENT_HOME/bin/connect-distributed $CONFLUENT_HOME/etc/kafka/connect-distributed.properties 2>&1  | tee -a /root/connect_console_log/connect_console_$log_suffix.log  > /dev/null &

sleep 30

zeppelin-daemon.sh start &

sleep 30


