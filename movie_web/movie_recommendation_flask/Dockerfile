# 운영체제
FROM ubuntu:22.04

# 작업할 폴더 생성
WORKDIR /app

# 작업했던 파일들을 복사해서 my_boot 에 복사
# COPY . (현재 폴더, Dockerfile 있는 폴더, /home/ubuntu/movie_recommendation_flask)
#      . (작업 폴더 /app)
COPY . .

# 리눅스 bash 쉘 (수업 시간에 명령어를 입력했던 창) 에서
# 명령들이 실행되도록 설정

### 도커는 기본으로 /bin/sh 창에서 명령들이 실행됨
SHELL [ "/bin/bash", "-c" ]

# 시스템 업데이터
RUN apt-get update
# 파이썬 설치 -y : yes 자동 입력
RUN apt-get install software-properties-common -y
# pip 설치 -y
RUN apt-get install python3-pip -y

### ubuntu 내에 pip 가 기본으로 있으므로, pip3 라고 명시해서 실행.
# requirements.txt 에 저장한 파이썬 라이브러리 설치
RUN pip3 install -r requirements.txt

# 포트 5000 사용
## 다른 포트를 사용한다면 EC2 인바운드 규칙에 포트 번호 추가
EXPOSE 5000

# Flask 실행
## 외부 접속 가능 --host = 0.0.0.0
## 기본 app.run(host='0.0.0.0')의 경우 모든 호스트로 접속이 가능
### nohub 으로 실행할 명령 설정 (항상 백그라운드로 실행)
#### ENTRYPOINT 는 Dockerfile 내에 하나만 설정할 수 있다.
ENTRYPOINT [ "python3", "-m", "flask", "run", "--host=0.0.0.0" ]