# 운영체제
FROM ubuntu:22.04

# 작업할 폴더 생성 자바 실행 파일 jar를 저장할 디렉토리 
WORKDIR /my_boot

# 작업했던 파일들을 복사해서 my_boot 에 복사
# COPY . (현재 폴더, pom.xml과 Dockerfile 있는 폴더, )
#      . (작업 폴더 /my_boot)
COPY . .


######### 실행 환경 설정 명령어 ##########

# 시스템 업데이터
RUN apt-get update

RUN apt-get install openjdk-11-jre-headless -y

RUN apt-get install maven -y

RUN mvn package -Dmaven.test.skip=true

# 사용 포트 설정
EXPOSE 8080

# nohup 실행 명령어 설정
ENTRYPOINT [ "java", "-jar", "/my_boot/target/movie-0.0.1-SNAPSHOT.jar" ]