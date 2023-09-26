-- 비트코인 가격 정보를 저장할 데이터베이스
create database coin_db;

-- coin_db 접속
use coin_db;

-- 비트코인 정보를 저장할 테이블 생성
create table coin (
	num int auto_increment primary key, -- 일련번호
    open_time datetime, -- 날짜와 시간
    open_price decimal(10,3), -- 시가
    high_price decimal(10,3), -- 고가
    low_price decimal(10,3), -- 저가
    close_price decimal(10,3), -- 종가
    volume decimal(10,3), -- 거래량
    symbol varchar(30), -- 비트코인명
    predic_price decimal(10,3) -- 비트코인 예측값
    );
    
desc coin;

select * from coin
where num=16550;

select count(*) 
from coin;
