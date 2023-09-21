SELECT s.stk_cd ,s.stk_nm ,s.sec_nm 
		,hd.c_prc `종가`
		,hd.vol `거래량`
		,RANK () over( ORDER by (hd.c_prc * hd.vol) DESC) 
FROM stock s 
inner join history_dt hd on (s.stk_cd=hd.stk_cd)
WHERE hd.dt BETWEEN '2019-01-01' AND '2020-03-19'
;

SELECT
    s.stk_cd
    ,s.stk_nm
    ,s.sec_nm
    ,hd.c_prc `종가`
    ,hd.vol `거래량`
    ,RANK() OVER (PARTITION BY s.stk_cd ORDER BY (hd.c_prc * hd.vol) DESC) `거래금액순위`
FROM stock s
INNER JOIN history_dt hd ON s.stk_cd = hd.stk_cd
WHERE hd.dt BETWEEN '2019-01-01' AND '2020-03-19'
;


SELECT s.stk_cd ,s.stk_nm 
		,SUM(hd.vol)
		,RANK () OVER(ORDER BY SUM(hd.vol) DESC )
FROM stock s
INNER JOIN history_dt hd ON s.stk_cd = hd.stk_cd
WHERE hd.dt BETWEEN '2019-01-01' AND '2020-03-19'
GROUP BY s.stk_cd ,s.stk_nm 
;



SELECT s.stk_cd ,s.stk_nm 
		,SUM(hd.vol) `총 거래량`
		,SUM(hd.vol * hd.c_prc) `총 거래금액량` 
		,RANK () OVER(ORDER BY SUM(hd.vol * hd.c_prc) DESC ) `총 거래금액 순위`
		,RANK () OVER(ORDER BY SUM(hd.vol) DESC ) `총 거래량 순위`
FROM stock s
INNER JOIN history_dt hd ON s.stk_cd = hd.stk_cd
WHERE hd.dt BETWEEN '2019-01-01' AND '2020-03-19'
GROUP BY s.stk_cd ,s.stk_nm 
ORDER BY `총 거래금액 순위` ASC 
;

SELECT *
FROM finance_y fy ;

SELECT s.stk_cd ,s.stk_nm 
		,SUM(hd.h_prc - hd.l_prc ) `고가 저가 차이`
		,RANK () OVER(ORDER BY SUM(hd.h_prc - hd.l_prc) DESC) `고저 차이 순위`
FROM stock s
INNER JOIN history_dt hd ON s.stk_cd = hd.stk_cd
WHERE hd.dt BETWEEN '2019-01-01' AND '2020-03-19'
GROUP BY s.stk_cd ,s.stk_nm
;


WITH res1 AS (SELECT s.stk_cd ,s.stk_nm 
					,SUM(hd.h_prc - hd.l_prc ) `고가 저가 차이`
					,RANK () OVER(ORDER BY SUM(hd.h_prc - hd.l_prc) DESC) `고저 차이 순위`
			FROM stock s
			INNER JOIN history_dt hd ON s.stk_cd = hd.stk_cd
			WHERE hd.dt BETWEEN '2019-01-01' AND '2020-03-19'
			GROUP BY s.stk_cd ,s.stk_nm
			limit 100
)
SELECT s.stk_cd ,s.stk_nm 
		,SUM(hd.vol) `총 거래량`
		,SUM(hd.vol * hd.c_prc) `총 거래금액량` 
		,RANK () OVER(ORDER BY SUM(hd.vol * hd.c_prc) DESC ) `총 거래금액 순위`
		,RANK () OVER(ORDER BY SUM(hd.vol) DESC ) `총 거래량 순위`
FROM stock s
INNER JOIN history_dt hd ON s.stk_cd = hd.stk_cd
INNER JOIN res1 ON res1.stk_cd = s.stk_cd
WHERE hd.dt BETWEEN '2019-01-01' AND '2020-03-19'
GROUP BY s.stk_cd ,s.stk_nm
ORDER BY `총 거래금액 순위` ASC
;
WITH res1 AS(
	SELECT AVG()
	FROM history_dt hd4 
	WHERE hd4.dt BETWEEN '2019-01-01' AND '2020-03-19' 
)
SELECT s.stk_cd ,s.stk_nm 
		,SUM(hd.vol) `총 거래량`
		,SUM(hd.vol * hd.c_prc) `총 거래금액량` 
		,round( (hd3.c_prc-hd2.c_prc) / hd2.c_prc *100 ,2) `총기간의 등락률`
		,RANK () OVER(ORDER BY (hd3.c_prc-hd2.c_prc) DESC) `등락률 순위`
		,RANK () OVER(ORDER BY SUM(hd.vol * hd.c_prc) DESC ) `총 거래금액 순위`
		,RANK () OVER(ORDER BY SUM(hd.vol) DESC ) `총 거래량 순위`
FROM stock s
INNER JOIN history_dt hd ON s.stk_cd = hd.stk_cd
INNER JOIN history_dt hd2 ON s.stk_cd =hd2.stk_cd
INNER JOIN history_dt hd3 ON s.stk_cd =hd3.stk_cd 
WHERE hd.dt BETWEEN '2019-01-01' AND '2020-03-19' 
AND hd2.dt = '2019-01-01'
AND hd3.dt = '2020-03-19'
AND 
GROUP BY s.stk_cd ,s.stk_nm
ORDER BY `총기간의 등락률` ASC
;