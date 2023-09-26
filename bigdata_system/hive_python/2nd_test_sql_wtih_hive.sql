select * from stock s ;


SELECT hd.stk_cd , hd.dt , hd.o_prc , hd.h_prc , hd.l_prc , hd.c_prc , hd.vol , hd.chg_rt  
FROM history_dt hd 
WHERE hd.stk_cd ="005930" --삼성전자 종목 코드 005930
ORDER BY hd.dt ASC;


SELECT hd.stk_cd , hd.dt , hd.o_prc , hd.h_prc , hd.l_prc , hd.c_prc , hd.vol , hd.chg_rt  
FROM history_dt hd 
WHERE hd.stk_cd ="005930" --삼성전자 종목 코드 005930
AND hd.dt = "2019-01-08";

SELECT hd.stk_cd , hd.dt , hd.o_prc , hd.h_prc , hd.l_prc , hd.c_prc , hd.vol , hd.chg_rt  
FROM history_dt hd 
WHERE hd.stk_cd ="005930" --삼성전자 종목 코드 005930
AND hd.dt BETWEEN "2019-01-01" AND "2019-01-31";


SELECT s.stk_cd `종목코드` , s.stk_nm`종목명` , s.sec_nm`섹터명` , s.ex_cd`거래소코드` 
FROM stock s 
WHERE s.stk_nm LIKE "동일%"
ORDER BY s.stk_cd ASC;

SELECT s.sec_nm`섹터명` 
FROM stock s 
WHERE s.stk_nm LIKE "동일%"
GROUP BY s.sec_nm;

SELECT s.ex_cd `섹터명` 
FROM stock s 
WHERE s.stk_nm LIKE "동일%"
GROUP BY s.ex_cd;


SELECT s.sec_nm, count(*) CNT
from stock s 
group by s.sec_nm 
ORDER BY CNT DESC ; -- sec_nm이 없는 것은 우선주


SELECT hd.stk_cd 
	, round(AVG(hd.c_prc),3)`종가의평균`
	, round(AVG(hd.vol),3)`거래량의평균`  
FROM history_dt hd 
WHERE hd.dt >='2019-01-01'
AND hd.dt <'2019-02-01'
GROUP BY hd.stk_cd
ORDER BY `거래량의평균` DESC
;

describe history_dt;
describe stock;

SELECT s.stk_nm 
FROM stock s 
WHERE s.stk_cd = "000660"
;


SELECT SUBSTRING(s.stk_nm,1,2)`회사명`, COUNT(*) `개수` 
from stock s 
WHERE (s.stk_nm LIKE '삼성%' OR s.stk_nm LIKE '현대%')
GROUP BY SUBSTRING(s.stk_nm,1,2) -- select 문 보다 먼저 실행되기 때문에 설정한 컬럼명 사용불가.
ORDER by `회사명`;

SELECT 
--s.stk_nm `종목명`
	COUNT(*)
from stock s 
WHERE s.stk_nm LIKE 'LG%'


SELECT hd.stk_cd `종목코드`, SUM(hd.vol)`총 거래량` 
FROM history_dt hd 
WHERE hd.stk_cd IN ('005930', '005380')
AND hd.dt BETWEEN '2019-01-01' AND '2019-12-31'
GROUP BY hd.stk_cd 
ORDER BY `종목코드`
;

SELECT hd.stk_cd `종목코드`, SUM(hd.c_prc * hd.vol)`거래금액 합계` 
FROM history_dt hd 
WHERE hd.dt BETWEEN '2019-02-01' AND '2019-03-01'
GROUP BY hd.stk_cd 
HAVING SUM(hd.c_prc * hd.vol) > 2000000000000
ORDER BY hd.stk_cd 
;


select *
from stock s 
WHERE stk_nm='삼성전자'
;

SELECT hd.stk_cd ,hd.c_prc ,s.stk_cd ,s.stk_nm ,s.sec_nm 
FROM history_dt hd ,stock s 
WHERE hd.dt ='2019-01-08'
AND hd.stk_cd ='000020'
;

SELECT hd.stk_cd ,hd.c_prc ,s.stk_cd ,s.stk_nm ,s.sec_nm 
FROM history_dt hd ,stock s 
WHERE hd.dt ='2019-01-08'
AND hd.stk_cd =s.stk_cd 
;


-- 조인문 사용
SELECT hd.stk_cd ,hd.c_prc ,s.stk_nm ,s.sec_nm 
FROM stock s 
	INNER JOIN history_dt hd 
		on 	(s.stk_cd = hd.stk_cd)
WHERE s.stk_nm ='삼성전자'
ORDER BY hd.dt
;

SELECT hd.stk_cd `종목코드`, SUM(hd.c_prc * hd.vol)`거래금액 합계` 
FROM history_dt hd 
GROUP BY hd.stk_cd 
ORDER BY `거래금액 합계` DESC
limit 5
;

SELECT hd.stk_cd `종목코드`, SUM(hd.c_prc * hd.vol)`거래금액 합계` , s.stk_nm `종목명` ,s.sec_nm `섹터명`
FROM history_dt hd 
	Inner join stock s 
		on (s.stk_cd=hd.stk_cd)
GROUP BY hd.stk_cd, s.stk_nm ,s.sec_nm  
ORDER BY `거래금액 합계` DESC
limit 5
;

SELECT hd.*, s.stk_nm ,s.sec_nm 
FROM (
	select stk_cd, sum(hd2.vol * hd2.c_prc) VOL_CRC
	from history_dt hd2 
	group by hd2.stk_cd
	ORDER BY VOL_CRC DESC 
	limit 5
	) hd
	INNER JOIN stock s on (s.stk_cd = hd.stk_cd)
;

SELECT s.stk_cd ,s.stk_nm ,hd.c_prc 
FROM stock s 
Inner join history_dt hd on (s.stk_cd=hd.stk_cd)
where s.stk_nm LIKE '삼성%'
AND hd.dt = '2019-01-08'
;

SELECT s.stk_cd `종목코드` 
		,s.stk_nm `종목명` 
		,hd.dt `당일조회` 
		,hd.c_prc `당일 종가` 
		,hd2.dt `하루전 조회`
		, hd2.c_prc `하루전 종가`
FROM stock s 
inner join history_dt hd on (s.stk_cd=hd.stk_cd)
INNER JOIN history_dt hd2 on (s.stk_cd=hd2.stk_cd)
WHERE s.stk_nm LIKE '삼성%'
AND hd.dt='2019-01-08'
AND hd2.dt='2019-01-07'
;
-- 위와 같이 INNER JOIN을 여러번 사용하여 다른 조건으로 같은 컬럼의 값을 보여줄 수 있다.

SELECT s.sec_nm, SUM(hd.vol * hd.c_prc) VOL_AMT
FROM history_dt hd 
inner join stock s on (s.stk_cd=hd.stk_cd)
WHERE s.sec_nm <> '' -- 섹터명이 빈칸이 아닌 것.
GROUP BY s.sec_nm 
ORDER BY VOL_AMT DESC
limit 5
;

SELECT s.stk_nm ,SUM(hd.vol * hd.c_prc) VOL_AMT
FROM history_dt hd 
INNER JOIN stock s on (s.stk_cd=hd.stk_cd)
WHERE s.sec_nm ='제약바이오'
GROUP BY s.stk_nm 
ORDER BY VOL_AMT DESC
limit 5
;