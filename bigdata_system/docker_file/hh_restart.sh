#!/bin/bash
# 하둡과 하이브 세팅이 사전에 완료된 환경에서
## docker를 다시시작 했을 때 불필요한 작업 없이 하둡과 하이브를
### 실행시키기 위한 것. (사전 세팅이 없다면 사용X)

#### 기존의 nohup &으로 실행되었던 명령어들을 &(백그라운드)로만 하여
#### docker 실행창을 끄면 해당 프로세스들이 일부러 죽게 만듦
##### => 실시간으로 CLI 환경창에서 실행되는 내용을 표시하기 위함.

#한글 다운로드
# apt-get install locales - 도커 빌드 단계에서 설치됨

# 아래 명령어를 통해 hive에서 데이터 조회 시 한글 인코딩이 잘 됨.
## 가장 먼저 실행되어야 함.
#한글 출력 설정
localedef -f UTF-8 -i ko_KR ko_KR.UTF-8
#하이브 한글 출력 설정
export LC_ALL=ko_KR.UTF-8
#한글 입력 설정
LC_ALL=ko_KR.UTF-8 bash

# 스크립트를 실행할 때 명령어가 실행되는 내용을 표시하도록 디버그 모드를 활성화
set -x

# SSH 서비스는 원격 액세스를 가능하게 하는 서비스로, 주로 시스템 관리 및 원격 접속 목적으로 사용됨
# SSH 서비스를 다시 시작
/etc/init.d/ssh restart &
sleep 3

# Hadoop 클러스터의 모든 구성 요소를 다시 시작
/root/hadoop/sbin/start-all.sh &
sleep 10

# MySQL 서비스를 다시 시작
service mysql restart &
sleep 10

# HiveServer2를 백그라운드에서 실행
hive --service hiveserver2 &

