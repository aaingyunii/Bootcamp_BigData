-- bus_db 접속
use bus_db;

-- 정류장 정보 저장 테이블
create table bus_station (
	s_num int primary key auto_increment -- 정류장 번호
    ,latitude double -- 정류장 위도
    ,longitude double -- 정류장 경도
    ,station_name varchar(30) -- 정류장 이름
    );
    
desc bus_station;

-- bus_station.csv 파일로부터 데이터 import 완료
select * from bus_station;


-- 제주공항과 가까운 정류장 순서로 조회
-- 제주공항 경도 : 126.492776 / 위도 : 33.5070537
-- 거리 계산 => ST_Distance_Sphere(Point(경도,위도), Point(경도,위도)) -> 두 지점 사이의 거리 계산, 단위: m
select 
station_name, longitude, latitude, 
ST_Distance_Sphere(Point(126.492776,33.5070537),Point(longitude,latitude)) as `공항과의 거리(m)`
from bus_station
order by `공항과의 거리(m)` ASC;

-- 2km 이내의 정류장들만 조회
select 
station_name, longitude, latitude, 
ST_Distance_Sphere(Point(126.492776,33.5070537),Point(longitude,latitude)) as `공항과의 거리(m)`
from bus_station
having `공항과의 거리(m)` <=2000
order by `공항과의 거리(m)` ASC;

-- 버스 위치 정보 및 예측값을 가진 테이블 조회
select * from bus_arrive_prediction;


-- 2km 이내의 정류장의 도착 예정 정보 조회 확인
-- 4km 이내의 정류장 도착 예정 정보 조회 : 2km 내에는 데이터가 없어 조회 X
use bus_db;
-- 제주공항 경도 : 126.492776 / 위도 : 33.5070537
select 
s.station_name 
,s.longitude
,s.latitude 
,ST_Distance_Sphere(Point(126.492776,33.5070537),Point(longitude,latitude)) as `공항과의 거리(m)`
,loc.next_arrive_time/60 `도착예정시간(분)`
from bus_station as s
inner join bus_arrive_prediction as loc on (s.latitude=loc.next_latitude and s.longitude=loc.next_longitude)
having `공항과의 거리(m)` <=4000
order by `공항과의 거리(m)` ASC;


