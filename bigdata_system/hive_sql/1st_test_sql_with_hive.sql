SELECT * FROM stock s ;

SELECT * FROM stock s WHERE sec_nm ='문구류';

SELECT stk_cd, stk_nm from stock s ;


SELECT * FROM stock s 
WHERE sec_nm ='문구류'
ORDER BY stk_nm;

SELECT stk_cd, stk_nm, sec_nm
from stock s 
WHERE stk_nm = '삼성물산'
ORDER BY stk_cd desc;

SELECT stk_cd, stk_nm, sec_nm
from stock s 
WHERE stk_nm >= '효성화학';


SELECT stk_cd, stk_nm, sec_nm
from stock s 
WHERE stk_cd <= '000100'
ORDER  BY stk_cd DESC;


SELECT stk_cd, stk_nm, sec_nm
from stock s 
WHERE stk_cd < '000100'
ORDER  BY stk_cd DESC;


SELECT stk_cd, stk_nm, sec_nm, ex_cd 
from stock s 
WHERE sec_nm = '문구류'
AND ex_cd ='KD'
ORDER  BY stk_cd DESC;


SELECT stk_cd, stk_nm, sec_nm, ex_cd 
from stock s 
WHERE stk_cd >='100000'
AND stk_cd <= '101000'
AND ex_cd ='KP'
AND sec_nm = '기계와장비'
ORDER  BY stk_cd DESC;


SELECT stk_cd, stk_nm, sec_nm, ex_cd 
from stock s 
WHERE sec_nm = '문구류'
OR stk_nm = '대교'
ORDER  BY stk_nm;

SELECT stk_cd, stk_nm, sec_nm, ex_cd 
from stock s 
WHERE sec_nm = '담배'
OR sec_nm = '주류제조업'
ORDER  BY stk_nm;


SELECT stk_cd, stk_nm, sec_nm, ex_cd 
from stock s 
WHERE stk_nm NOT LIKE 'LG%'
ORDER BY stk_nm;


SELECT stk_cd, stk_nm, sec_nm, ex_cd 
from stock s 
where stk_nm BETWEEN '삼성' AND '삼아'
AND sec_nm IN ('보험','제약바이오')
ORDER BY stk_nm ;


SELECT stk_cd, stk_nm, sec_nm, ex_cd 
from stock s 
WHERE sec_nm IN ('담배','주류제조업','문구류')
ORDER BY stk_nm;


SELECT stk_cd, stk_nm, sec_nm, ex_cd 
from stock s 
Order by sec_nm DESC, stk_cd ASC;


SELECT s.stk_cd `종목코드`, s.stk_nm `종목명`, sec_nm `종목분야` 
from stock s 
WHERE s.stk_cd >='100000';


SELECT * from history_dt limit 5;


SELECT stk_cd, dt, o_prc, h_prc, l_prc, c_prc, vol, chg_rt
from history_dt hd 
where stk_cd ='005930'
ORDER BY dt ASC ;

