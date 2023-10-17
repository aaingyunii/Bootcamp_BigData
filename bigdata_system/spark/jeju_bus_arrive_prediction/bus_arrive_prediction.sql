-- 제주 버스 도착 시간 예측 결과를 저장할 데이터베이스
create database bus_db;

-- bus_db 접속
use bus_db;

-- 제주 버스 도착 시간 예측 결과를 저장할 테이블 생성
create table bus_arrive_prediction (
	num int auto_increment primary key -- 일련번호
    ,now_date	datetime default current_timestamp -- 운행날짜와 시간 저장, 기본값: 현재 날짜, 시간(current_timestamp)
	,route_id	varchar(30)
	,vh_id		varchar(30)
	,route_nm	varchar(30)
	,now_latitude	decimal(10,6)
	,now_longitude	decimal(10,6)
	,now_station	varchar(30)
	,distance		decimal(10,1)
	,next_station	varchar(30)
	,next_latitude	decimal(10,6)
	,next_longitude	decimal(10,6)
	,next_arrive_time	decimal(10,3)
    );
    
desc bus_arrive_prediction;
