SELECT count(*)
from stock s 
where s.stk_nm LIKE '삼성%'
;


-- ORDER BY 에서 default는 ASC
-- 내림차순으로 보고싶다면 DESC 를 반드시 적어야함.
SELECT s.stk_cd
		,s.stk_nm 
		,s.sec_nm
		,hd.c_prc `190304종가`
		,RANK() over(ORDER by hd.c_prc) `종가순위`
FROM stock s 
inner join history_dt hd on (s.stk_cd=hd.stk_cd)
WHERE s.stk_nm LIKE '삼성%'
AND hd.dt ='2019-03-04'
;


-- 2019년 2020년 거래금액 가장 높은 10개 종목 조회
select s.*
	  ,hd.dt	
      , hd.vol
      , hd.c_prc     
      , hd.c_prc * hd.vol/1e8 `거래금액(억)`
      ,rank() over (order by (hd.c_prc * hd.vol) desc ) `순위`
from history_dt hd
inner join stock s on(hd.stk_cd=s.stk_cd)
--where hd.dt = '2019-01-08'
--and s.stk_nm in ('삼성전자','SK하이닉스','현대차')
order by '순위' ASC
limit 10
;

-- 2019년 1월2일~2020년 12월 30일 등락률 순위
SELECT s.* ,hd.dt ,hd.c_prc `190102종가` ,hd2.dt ,hd.c_prc `201230종가` 
       , round(  ( (hd.c_prc-hd2.c_prc)/hd2.c_prc *100 ) , 1)  CHG_RT
       , rank() over( order by ( (hd.c_prc-hd2.c_prc)/hd2.c_prc *100) desc ) CHG_RT_RANK
FROM stock s 
inner join history_dt hd on (s.stk_cd=hd.stk_cd)
INNER JOIN history_dt hd2 on (s.stk_cd=hd2.stk_cd)
WHERE hd.dt ='2019-01-02'
AND hd2.dt ='2020-12-30'
ORDER BY CHG_RT DESC 
;


-- 2019년 1월2일~2020년12월 30일까지 등락률 높은것 5종목
select a.*
from
(select s.*
       ,hd.dt
       ,hd.c_prc `0228가격`
       ,hd2.dt
       ,hd2.c_prc `0201가격`
       ,  round(  ( (hd.c_prc-hd2.c_prc)/hd2.c_prc *100 ) , 1)  CHG_RT
       , rank() over( order by ( (hd.c_prc-hd2.c_prc)/hd2.c_prc *100) desc ) CHG_RT_RANK
	from stock s
	inner join history_dt hd on (hd.stk_cd=s.stk_cd)
	inner join history_dt hd2 on (hd2.stk_cd=s.stk_cd)
	where hd.dt='2019-01-02'
	and hd2.dt='2020-12-30'
	ORDER BY CHG_RT desc
	)a
where a.CHG_RT_RANK <=5	
;

-- 거래금액순위를 조회하는 쿼리
SELECT s.stk_cd 
		,s.stk_nm 
		,s.sec_nm 
		,round( hd.vol * hd.c_prc / 1e8,1) `거래금액(억)`
		,RANK () over(ORDER by hd.vol * hd.c_prc DESC) `거래금액순위`
FROM stock s 
inner join history_dt hd on (hd.stk_cd=s.stk_cd)
WHERE hd.dt ='2019-03-04'
;

-- 위의 쿼리를 이용해 각 섹터별 순위를 가져오는 쿼리
-- PARTITION BY 를 통해 각 섹터별로 순위를 조회
SELECT s.stk_cd 
		,s.stk_nm 
		,s.sec_nm 
		,round( hd.vol * hd.c_prc / 1e8,1) `거래금액(억)`
		,RANK () over(PARTITION by s.sec_nm 
				ORDER by hd.vol * hd.c_prc DESC) `섹터별거래금액순위`
FROM stock s 
inner join history_dt hd on (hd.stk_cd=s.stk_cd)
WHERE hd.dt ='2019-03-04'
;

-- 2019년3월 4일 각 섹터별 거래금액 1위 2위
select a.*
	from(select s.*
	       ,hd.vol
	       ,hd.c_prc
	       ,round( hd.vol * hd.c_prc / 1e8, 1) `거래금액(억)`
	       ,rank() over( PARTITION by s.sec_nm
	                   order by hd.vol * hd.c_prc desc
	                   ) `섹터별거래금액순위`
	from stock s
	inner join history_dt hd on(s.stk_cd=hd.stk_cd)
	where hd.dt='2019-03-04'
	) a
where a.`섹터별거래금액순위`<=2 --각 섹터별로 1,2위만 가져옴.
;

-- 2019년3월 4일 거래소별 하락순위
SELECT s.*
		,hd.chg_rt 
		,RANK () over(PARTITION by s.ex_cd 
		ORDER by hd.chg_rt ASC)	`거래소별하락순위`
FROM stock s 
inner join history_dt hd on (hd.stk_cd=s.stk_cd)
WHERE hd.dt ='2019-03-04'
;

-- 위 쿼리를 서브쿼리로 사용해서 조회
-- 거래소별 하락순위 전체기간
SELECT a.*
from(SELECT s.*
			,hd.chg_rt 
			,RANK () over(PARTITION by s.ex_cd 
			ORDER by hd.chg_rt ASC)	`거래소별하락순위`
	FROM stock s 
	inner join history_dt hd on (hd.stk_cd=s.stk_cd)
	-- WHERE hd.dt ='2019-03-04'
)a
WHERE a.`거래소별하락순위` <=3
;
