drop table stock_invest;

/*
1. PER (주가수익비율 = 현재 종가 / 주당순이익)
- 2019년 12월 30일 폐장일 종가
- 주당순이익
- 주가수익율 (0~4) 안정적인 평가된 구간으로 선정
*/
create table stock_invest as
with raw as (
select a.yy 
     , a.stk_cd 
     , c.stk_nm
     , a.fin_itm_val                                        -- 주당순이익
     , round(b.c_prc / a.fin_itm_val,2) per                 -- 주가수익비율 = 현재 종가 / 주당순이익
     , RANK() over ( order by b.c_prc / a.fin_itm_val desc) -- 주가수익비율 순위
  from finance_y a
 inner join history_dt b on (a.stk_cd = b.stk_cd)
 inner join stock c on (a.stk_cd = c.stk_cd)
 where a.yy = '2019'
   and a.fin_itm_nm = '주당순이익'
   and b.dt = (select max(s.dt) from history_dt s where s.dt like '2019-12-__' and s.stk_cd = a.stk_cd)
   and b.c_prc / a.fin_itm_val between 0 and 4
), raw2 as (
select r.stk_cd
     , r.stk_nm
     , r.per
     , max(if (h.dt = '2019-01-02', h.c_prc, 0)) prc_201901 -- 2019-01-02 종가
     , max(if (h.dt = '2019-12-30', h.c_prc, 0)) prc_201912 -- 2019-12-30 종가
     , max(if (h.dt = '2020-03-19', h.c_prc, 0)) prc_0319   -- 2020-03-19 종가
     , max(if (h.dt = '2020-12-30', h.c_prc, 0)) prc_1230   -- 2020-12-30 종가
  from raw r
 inner join history_dt h on (r.stk_cd = h.stk_cd)
 where h.dt in ('2019-01-02', '2019-12-30', '2020-03-19', '2020-12-30')
 group by r.stk_cd, r.stk_nm, r.per
)
select * from raw2;


select * from stock_invest;


drop table stock_invest2;

/*
2. 거래금액이 평균 10억 정도 투자되는 종목 선정
3. 2019년도 개폐장일 종가 기준 변동률이 높은 순으로 선정
- 주가가 상승하고 있는 조건
*/

create table stock_invest2 as
with vol_prc as (
select s.stk_cd
     , s.stk_nm
     , s.per
     , s.prc_201901 -- 2019년 개장일 종가
     , s.prc_201912 -- 2019년 폐장일 종가
     , max(round((s.prc_201912 - s.prc_201901) / s.prc_201901 * 100, 2)) chg_rt -- 개폐장일 종가 기준 변동률
     , rank() over( order by (s.prc_201912 - s.prc_201901) / s.prc_201901 * 100 desc) chg_rt_rank --개폐장일 종가 기준 변동률 순위
     , max(h.vol * h.c_prc) max_vol_prc -- 거래금액
     , ROUND(AVG(h.vol * h.c_prc), 0) vol_prc_avg -- 평균 거래금액
     , (select ROUND(AVG(a.vol * a.c_prc) * 0.1, 0) from history_dt a where a.dt = '2020-03-19') vol_prc_tot_avg --2020-03-19 거래금액 평균
  from stock_invest s
 inner join history_dt h on (s.stk_cd = h.stk_cd)
 where s.prc_201901 > 0
   and s.prc_201912 > 0
   and h.dt <= '2020-03-19'
 group by s.stk_cd
     , s.stk_nm
     , s.per
     , s.prc_201901 -- 2019년 개장일 종가
     , s.prc_201912 -- 2019년 폐장일 종가  
)
select * 
  from vol_prc v
 where v.max_vol_prc > 1000000000 --거래금액이 평균 이상인 것
   and v.vol_prc_avg > 1000000000 --거래금액이 평균 이상인 것
   and chg_rt > 0     -- 변동률이 상승하고 있는 조건 
;


select * from stock_invest2;


drop table stock_invest3;

/*
예상 수익울 확인하기 위한 정보
3월 20일 투자시 2020년 폐장일의 변동률
*/

create table stock_invest3 as
with invest_rnk as (
select h.stk_cd
     , s.stk_nm
     , s.chg_rt
     , s.per
     , s.vol_prc_avg 
     , s.vol_prc_tot_avg 
     --, h.dt
     --, h.c_prc 
     , max(if (h.dt = '2020-03-19', h.c_prc, 0)) prc_20200319
	 , max(if (h.dt = '2020-03-19', h.c_prc, 0)) prc_20200320
     , max(if (h.dt = '2020-12-30', h.c_prc, 0)) prc_20201230
--     , s.m3_prc
--     , s.m5_prc
--     , s.m10_prc
     , max(if (h.dt = '2019-01-02', h.m3_prc, 0)) m3_prc_20190102 --2019년 개장일 3일 이동평균
     , max(if (h.dt = '2019-02-28', h.m3_prc, 0)) m3_prc_20190228 --2019년 1분기 3일 이동평균
     , max(if (h.dt = '2019-05-31', h.m3_prc, 0)) m3_prc_20190531 --2019년 2분기 3일 이동평균
     , max(if (h.dt = '2019-08-30', h.m3_prc, 0)) m3_prc_20190830 --2019년 3분기 3일 이동평균
     , max(if (h.dt = '2019-12-30', h.m3_prc, 0)) m3_prc_20191230 --2019년 4분기 3일 이동평균
     , max(if (h.dt = '2020-03-19', h.m3_prc, 0)) m3_prc_20200319 --2020년 3월 19일 기준 3일 이동평균
     , max(if (h.dt = '2020-12-30', h.m3_prc, 0)) m3_prc_20201230 --2020년 12월 30일 예상 3일 이동평균
  from history_dt h 
 inner join stock_invest2 s on (s.stk_cd = h.stk_cd)
 where h.dt in ('2019-01-02', '2019-02-28', '2019-05-31', '2019-08-30', '2019-12-30', '2020-03-19', '2020-12-30')
  group by  h.stk_cd, s.stk_nm, s.chg_rt, s.per, s.vol_prc_avg, s.vol_prc_tot_avg --, h.dt, h.c_prc 
)
select stk_cd
     , stk_nm
     , per --주당
     , chg_rt
     , vol_prc_avg -- 평균거래금액
     , vol_prc_tot_avg --총주식 평균거래금액
     , prc_20200319 -- 3월 19일 종가
     , prc_20201230 -- 12월 30일 종가
--     , m3_prc_20200319
     , round((prc_20200319 - m3_prc_20191230) / m3_prc_20191230 * 100,2) chg_rt_20200319 --2019년 폐장일 종가에서 2020년 3월 19일 변동률
     , round((prc_20201230 - prc_20200320) / prc_20200320 * 100,2) chg_rt_20201230 --2020년 3월 20일에서 2020년 폐장일 종가 변동률
     , m3_prc_20190102
     , m3_prc_20190228
     , m3_prc_20190531
     , m3_prc_20190830
     , m3_prc_20191230
     , m3_prc_20200319
     , m3_prc_20201230
  from invest_rnk
;

select * from stock_invest3
;