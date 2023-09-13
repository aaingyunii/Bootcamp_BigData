# 운영체제
FROM ubuntu:22.04

# 작업할 폴더 생성
WORKDIR /app

# 작업했던 파일들을 복사해서 my_boot 에 복사
# COPY . (현재 폴더, Dockerfile 있는 폴더, /home/ubuntu/movie_recommendation_react/movie_react)
#      . (작업 폴더 /app)
COPY . .

# 리눅스 bash 쉘 (수업 시간에 명령어를 입력했던 창) 에서
# 명령들이 실행되도록 설정
### 도커는 기본으로 /bin/sh 창에서 명령들이 실행됨
SHELL [ "/bin/bash", "-c" ]

# 시스템 업데이터
RUN apt-get update

# NodeJS 설치
RUN apt-get install nodejs -y

# npm 설치
RUN apt-get install npm -y

# React 사용 라이브러리 설치
RUN npm install

EXPOSE 3000

# React 시작
ENTRYPOINT [ "npm", "start" ]

