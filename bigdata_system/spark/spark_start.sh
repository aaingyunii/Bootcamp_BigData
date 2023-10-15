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

service elasticsearch start &

sleep 10

service kibana start &

sleep 30

zeppelin-daemon.sh start &

sleep 30


