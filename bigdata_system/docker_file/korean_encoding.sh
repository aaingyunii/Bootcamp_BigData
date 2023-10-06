#!/bin/bash
#한글 다운로드
# apt-get install locales - 도커 빌드 단계에서 설치됨

# 아래 명령어를 통해 hive에서 데이터 조회 시 한글 인코딩이 잘 됨.
## 가장 먼저 실행되어야 함.

#한글 출력 설정
localedef -f UTF-8 -i ko_KR ko_KR.UTF-8 &
sleep 3

#하이브 한글 출력 설정
export LC_ALL=ko_KR.UTF-8
sleep 3

#한글 입력 설정
LC_ALL=ko_KR.UTF-8 bash