SELECT * FROM history_dt hd ;
SELECT * FROM stock s ;

SELECT s.stk_cd `종목코드` ,s.stk_nm `종목명` ,s.sec_nm `섹터명` 
	,hd.dt `날짜` ,hd.c_prc `종가` ,hd.vol `거래량` , hd.vol *hd.c_prc `거래금액`
FROM stock s 
INNER JOIN history_dt hd ON (s.stk_cd=hd.stk_cd)
WHERE s.stk_nm LIKE '삼성%'
ORDER BY hd.dt 
;

SELECT s.stk_cd ,s.stk_nm ,s.sec_nm
	,hd.dt ,hd.c_prc ,hd.vol , hd.vol *hd.c_prc 
FROM stock s 
INNER JOIN history_dt hd ON (s.stk_cd=hd.stk_cd)
ORDER BY hd.dt 
;

-- 삼성 관련 주 중 거래 금액 높은 20 개 조회
-- 삼성전자가 너무 압도적으로 높아, 삼성전자를 제외한 결과 값을 가져옴
SELECT s.stk_cd `종목코드` ,s.stk_nm `종목명` ,s.sec_nm `섹터명` 
	,hd.dt `날짜` ,hd.c_prc `종가` ,hd.vol `거래량` 
	, round(hd.vol *hd.c_prc / 1e8,1) `거래금액(억)`
FROM stock s 
INNER JOIN history_dt hd ON (s.stk_cd=hd.stk_cd)
WHERE s.stk_nm LIKE '삼성%'
AND s.stk_nm <> '삼성전자'
ORDER BY `거래금액(억)` DESC
limit 20
;

SELECT MAX(hd.dt) 
FROM history_dt hd 
WHERE hd.dt < '2019-04-01'
;

-- 서브쿼리 활용
SELECT s.stk_cd ,s.stk_nm ,s.sec_nm ,hd.dt ,hd.c_prc 
FROM stock s 
inner join history_dt hd on (s.stk_cd=hd.stk_cd)
WHERE hd.dt =(
				SELECT MAX(hd.dt) 
				FROM history_dt hd 
				WHERE hd.dt < '2019-04-01'	
			)
AND s.stk_nm ='삼성전자'
;

SELECT hd.stk_cd 
FROM history_dt hd 
order by hd.vol DESC 
limit 5
;

-- 서브쿼리를 이용해 위의 종목코드가 무슨 회사인지 찾기
SELECT s.stk_cd ,s.stk_nm ,s.sec_nm 
FROM stock s 
WHERE s.stk_cd IN (
				SELECT hd.stk_cd 
				FROM history_dt hd 
				order by hd.vol DESC 
				limit 5
				)
;

--조인 이용을 이용해 다른 데이터들도 가져오기.
SELECT s.stk_cd ,s.stk_nm ,s.sec_nm ,s.ex_cd 
		,hd.dt ,hd.vol ,hd.c_prc 
FROM stock s 
inner join history_dt hd on (s.stk_cd=hd.stk_cd)
ORDER BY hd.vol DESC 
limit 50
;

SELECT a.stk_cd `종목코드` 
	,a.stk_nm `종목명` 
	,MAX(a.vol*a.c_prc) `최대거래금액` 
	,MAX(a.vol) `최대거래량`  
FROM (
	SELECT s.stk_cd ,s.stk_nm ,s.sec_nm ,s.ex_cd 
			,hd.dt ,hd.vol ,hd.c_prc 
	FROM stock s 
	inner join history_dt hd on (s.stk_cd=hd.stk_cd)
	ORDER BY hd.vol DESC 
	limit 50
) a
GROUP BY a.stk_cd, a.stk_nm
ORDER BY `최대거래금액` DESC
;


SELECT a.stk_cd `종목코드` 
	,MAX(a.vol*a.c_prc) `최대거래금액` 
	,MAX(a.vol) `최대거래량`  
	,MAX(a.stk_nm)
	,MAX(a.sec_nm) 
FROM (
	SELECT s.stk_cd ,s.stk_nm ,s.sec_nm ,s.ex_cd 
			,hd.dt ,hd.vol ,hd.c_prc 
	FROM stock s 
	inner join history_dt hd on (s.stk_cd=hd.stk_cd)
	ORDER BY hd.vol DESC 
	limit 50
) a
GROUP BY a.stk_cd
ORDER BY `최대거래금액` DESC
;


-- 삼성전자의 2019년 마지막 주식 거래 일자의 주가 정보
SELECT s.stk_cd `종목코드` ,s.stk_nm `종목명` ,hd.dt `거래일자` ,hd.c_prc `종가`
FROM stock s 
INNER JOIN history_dt hd on (s.stk_cd=hd.stk_cd)
WHERE hd.dt = (
				SELECT MAX(hd2.dt) 
				FROM history_dt hd2 
				WHERE hd2.dt < '2020-01-01'
			)
AND s.stk_nm ='삼성전자'
;

-- 2019년 1월 2일, 2020년 12월30일 등락률 조회
SELECT hd.stk_cd `종목코드` ,s.stk_nm `종목명` ,s.sec_nm `섹터명` ,s.ex_cd `거래소코드` 
		,hd.dt `거래일자` ,hd.c_prc `190102 종가` ,hd2.dt  `거래일자2`,hd2.c_prc `201230 종가`
		,round( (hd2.c_prc-hd.c_prc) / hd.c_prc *100 ,2) `등락률`
FROM history_dt hd
inner join history_dt hd2 on (hd.stk_cd=hd2.stk_cd)
inner join stock s on (s.stk_cd=hd.stk_cd)
WHERE hd.dt ='2019-01-02'
AND hd2.dt = '2020-12-30'
ORDER BY `등락률` DESC 
limit 10
;

-- with 을 통해 인라인 뷰에 작성할 내용을 가장 앞쪽으로 배치해서 단독으로 ,rest1 과 같이 정의할 수 있다.
with res1 as (
				-- 19년부터 20년 등락률 상위 10개 조회
				SELECT hd.stk_cd `종목코드` ,s.stk_nm `종목명` ,s.sec_nm `섹터명` ,s.ex_cd `거래소코드` 
						,hd.dt `거래일자` 
						,hd.c_prc `190102 종가` 
						,hd2.dt  `거래일자2`
						,hd2.c_prc `201230 종가`
						,round( (hd2.c_prc-hd.c_prc) / hd.c_prc *100 ,2) `등락률`
				FROM history_dt hd
				inner join history_dt hd2 on (hd.stk_cd=hd2.stk_cd)
				inner join stock s on (s.stk_cd=hd.stk_cd)
				WHERE hd.dt ='2019-01-02'
				AND hd2.dt = '2020-12-30'
				ORDER BY `등락률` DESC 
				limit 10
			)
			,res2 AS (
						SELECT a.*
						FROM res1 a
						ORDER BY a.`201230 종가` DESC
					)
		SELECT * FROM res1
		ORDER BY `201230 종가` DESC
		;


-- SELECT 과 HAVING 실행순서 직접 확인한 결과
SELECT s.stk_nm `종목명` ,MAX(hd.c_prc) 
FROM stock s 
INNER JOIN  history_dt hd on (hd.stk_cd=s.stk_cd)
GROUP BY s.stk_nm HAVING s.stk_nm LIKE '삼성%'
;

SELECT s.stk_nm `종목명` ,MAX(hd.c_prc) 
FROM stock s 
INNER JOIN  history_dt hd on (hd.stk_cd=s.stk_cd)
GROUP BY s.stk_nm HAVING `종목명` LIKE '삼성%'
;
