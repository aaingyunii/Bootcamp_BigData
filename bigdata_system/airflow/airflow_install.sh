#!/bin/bash

# 스크립트 실행 도중 실행되는 명령어를 디버그 모드로 표시
set -x  

# 서울 시간대로 시스템 시간대를 설정
sudo ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# APT 패키지 관리자를 업데이트하고 누락된 패키지 정보를 다시 가져옴
sudo apt update --fix-missing

# 시스템에 설치된 모든 패키지를 최신 버전으로 업그레이드
sudo apt upgrade -y

# 패키지 정보를 다시 업데이트
sudo apt update

# Docker 설치를 위해 필요한 패키지들을 설치
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

# Docker의 GPG 키를 다운로드하고 시스템에 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Docker의 APT 저장소를 시스템에 추가
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y

# Docker 저장소를 포함하여 시스템의 패키지 정보를 다시 업데이트
sudo apt-get update

# Docker 및 관련 도구를 설치
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# SSH 서버를 설치
sudo apt install -y openssh-server

# SSH 클라이언트를 설치
sudo apt install -y openssh-client

# PDSH(Parallel Distributed Shell)를 설치
sudo apt install -y pdsh

# Vim 에디터를 설치
sudo apt-get install -y vim

# SSH 서버 구성 파일에서 root 사용자의 로그인 허용을 활성화
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/gi' /etc/ssh/sshd_config

# &를 통해 백그라운드에서 SSH 서비스 시작
/etc/init.d/ssh restart &
sleep 10

# Apache Airflow Docker Compose 파일을 다운로드
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.7.1/docker-compose.yaml'

# Apache Airflow를 위한 디렉토리를 생성
mkdir -p ./dags ./logs ./plugins ./config

# 사용자의 UID를 .env 파일에 저장
echo -e "AIRFLOW_UID=$(id -u)" > .env

# Docker 서비스를 다시 시작
sudo /etc/init.d/docker restart
sleep 10

# 이전에 실행한 Docker Compose를 중지하고 볼륨 및 고아 컨테이너를 제거
sudo docker compose down --volumes --remove-orphans
sleep 10

# Apache Airflow 초기화 서비스를 실행
sudo docker compose up airflow-init
sleep 10

# Apache Airflow와 관련 서비스를 실행
sudo docker compose up
sleep 10
