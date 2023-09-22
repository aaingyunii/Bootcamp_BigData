#!/bin/bash
# 하둡과 하이브 세팅이 사전에 완료된 환경에서
## docker를 다시시작 했을 때 불필요한 작업 없이 하둡과 하이브를
### 실행시키기 위한 것. (사전 세팅이 없다면 사용X)

#### 기존의 nohup &으로 실행되었던 명령어들을 &(백그라운드)로만 하여
#### docker 실행창을 끄면 해당 프로세스들이 일부러 죽게 만듦
##### => 실시간으로 CLI 환경창에서 실행되는 내용을 표시하기 위함.

# 디버그 모드 활성화 => 실행창에 작업기록이 남겨짐.
set -x

/etc/init.d/ssh restart &
sleep 3

# Hadoop 클러스터의 모든 구성 요소를 다시 시작
/root/hadoop/sbin/start-all.sh &
sleep 15

# MySQL 서비스를 다시 시작
service mysql restart &
sleep 10

# HiveServer2를 백그라운드에서 실행
hive --service hiveserver2 &
