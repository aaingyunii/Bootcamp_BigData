with raw as (
			select a.stk_cd
			     	,c.stk_nm
			     	,a.fin_itm_val
			     	,round(b.c_prc / a.fin_itm_val,2) PER
--			     	,RANK() over ( order by b.c_prc / a.fin_itm_val desc)
			from finance_y a
			inner join history_dt b on (a.stk_cd = b.stk_cd)
			inner join stock c on (a.stk_cd = c.stk_cd)
			where a.yy = '2019'
			and a.fin_itm_nm = '주당순이익'
   			and b.dt = (
   				select max(s.dt) from history_dt s where s.dt like '2019-12-__' and s.stk_cd = a.stk_cd
   				)
)
select r.stk_cd ,r.stk_nm ,r.PER
		,SUM(hd3.vol) `총 거래량`
		,SUM(hd3.vol * hd3.c_prc) `총 거래금액`
		,round((hd2.c_prc -hd.c_prc) / hd.c_prc *100,2 ) `19년 등락률`
from raw r
INNER JOIN history_dt hd ON (r.stk_cd=hd.stk_cd)
INNER JOIN history_dt hd2 ON (r.stk_cd=hd2.stk_cd)
INNER JOIN history_dt hd3 ON (r.stk_cd=hd3.stk_cd)
WHERE r.PER BETWEEN 0 AND 4
AND hd.dt = '2019-01-02'
AND hd2.dt =(
   			select max(k.dt) from history_dt k where k.dt like '2019-12-__' and k.stk_cd = r.stk_cd
   			)
AND hd3.dt BETWEEN '2019-01-01' AND '2019-12-31'
GROUP BY r.stk_cd ,r.stk_nm ,r.PER ,hd.c_prc ,hd2.c_prc
ORDER BY `19년 등락률` DESC
;


SELECT SUM(hd.vol)/COUNT(*) *0.2
FROM history_dt hd 
WHERE hd.dt BETWEEN '2019-01-01' AND '2019-12-31'
;


SELECT * 
FROM stock s 
WHERE s.stk_nm LIKE '%자안%'
;
--WITH res AS(
--select a.stk_cd
--     	,c.stk_nm
--     	,a.fin_itm_val
--     	,(b.c_prc / a.fin_itm_val) PER
----			     	,RANK() over ( order by b.c_prc / a.fin_itm_val desc)
--from finance_y a
--inner join history_dt b on (a.stk_cd = b.stk_cd)
--inner join stock c on (a.stk_cd = c.stk_cd)
--where a.yy = '2019'
--and a.fin_itm_nm = '주당순이익'
--and b.dt = (
--	select max(s.dt) from history_dt s where s.dt like '2019-12-__' and s.stk_cd = a.stk_cd
--	)
--)
--SELECT res.*
--FROM res
--WHERE res.PER > 0
--ORDER BY res.PER ASC;