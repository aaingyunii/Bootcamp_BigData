from airflow import DAG
import pendulum
import datetime
from airflow.operators.python import PythonOperator
import random

with DAG(
    dag_id="get_binance02",#DAG 아이디
    schedule_interval="@hourly", #시간마다 실행
    start_date=pendulum.datetime(2023, 10, 4, tz="Asia/Seoul"), #2023년 10월 4일 부터 실행
    catchup=False
) as dag:

    def get_bitcoin():
        import requests #
        from datetime import datetime,timezone, timedelta
        import time
        import pytz
        import pymysql
        
        
        #현재 날짜와 시간을 가져옴 (표준시) 예) 2023-09-27 09:18:24:000
        now = datetime.now()
        print("now =",str(now))

        #현재 날짜와 시간 2023-09-27 09:18:24:000 에서 16번째 자리까지 리턴 2023-09-27 09:18 (분까지 리턴)
        end_date_time = str(now)[:16]
        print("end_date_time=",end_date_time)

        #현재 날짜와 시간 의 1시간 전 리턴 2023-09-27 08:18:24:000
        one_hour_ago = (now - timedelta(hours=1))
        print("one_hour_ago=",str(one_hour_ago))

        #현재 날짜와 시간의 1시간 전의 16번째 문자열 까지 리턴 2023-09-27 08:18
        start_date_time = str(one_hour_ago)[0:16]
        print("start_date_time=",start_date_time)


        #비트코인 정보를 가져올 바이넌스 API 주소
        URL = 'https://api.binance.com/api/v3/klines'
        #비트코인 종류 BTCUSDT (비트코인) ETHUSDT (이더리움)
        coin_name = "BTCUSDT"
        


        #문자열 형태의 end_date_time 를 date_time 으로 변환 (변환 결과는 1 초 단위)
        #변환 결과를 정수로 변환
        #변환 결과에 1000 곱해서 1/1000 단위로 변환
        #변환 결과 1초 ->1000

        end = int(time.mktime(datetime.strptime(end_date_time , '%Y-%m-%d %H:%M').timetuple())) * 1000
        print("end=",end)
        
        #문자열 형태의 start_date_time 를 date_time 으로 변환 (변환 결과는 1 초 단위)
        #변환 결과를 정수로 변환
        #변환 결과에 1000 곱해서 1/1000 단위로 변환
        #변환 결과 1초 ->1000
        start = int(time.mktime(datetime.strptime(start_date_time , '%Y-%m-%d %H:%M').timetuple())) * 1000
        print("start=",start)
        
        #바이낸스 API 파라메터 정보
        params = {
            'symbol': coin_name, #코인 이름 BTCUSDT (비트코인) ETHUSDT (이더리움)
            'interval': '1m', #수집 시간 간격 1m (1분), 1h (1시간)
            'limit': 1000, #한번에 가져올 데이터의 수
            'startTime': start, #시작 시간
            'endTime': end #끝시간
        }
        
        #데이터베이스 연결
        db = pymysql.connect(
            host='192.168.0.171' # MySQL 이 설치된 컴퓨터 IP 주소
            ,port=3306
            ,user='root'
            ,passwd='1234'
            ,db='coin_db'
            ,charset='utf8'
        )
        
        #데이터베이스 쿼리를 실행할 객체
        cursor=db.cursor()
        
        #start 가 end 보다 작을 동안 반복
        while start < end:
            print("start=",start//1000)
            #바이낵스 파라메터에 start (시작 시간 갱신)
            params['startTime'] = start
            #바이낸스 API 접속 해서 결과를 리턴
            #바이낸스 API의 결과(비트코인 가격) 은 result에 저장
            result = requests.get(URL, params = params)
            #result (비트코인 가격 1000 건)을 coin_list에 저장
            coin_list = result.json()
            #print("coin_list=",coin_list)
            if not coin_list:#coin_list가 존재 하지 않으면
                break #반복 종료

            #coin_list에서 코인가격 하나를 coin 변수에 저장
            for coin in coin_list:
                #표준시를 서울 시간으로 변환 할 객체
                timezone = pytz.timezone('Asia/Seoul')

                #coin[0] : 비트코인 날짜와 시간이 정수 값으로 저장(단위 1/1000 초)
                #1초는  ->1000 으로 저장되 있으므로 1000 을 나눠서 초로 변환 한 후에
                #datetime.fromtimestamp 으로 문자열로 변환  
                # tz=timezone : 서울 시간으로 변환              
                open_time = datetime.fromtimestamp(coin[0] //1000, tz=timezone)
                print("open_time=",open_time) #비트코인 날짜와 시간
                open_price = coin[1] #비트코인 시가
                print("open_price=",open_price)
                high_price = coin[2] #비트코인 고가
                print("high_price=",high_price)
                low_price = coin[3]  #비트코인 저가
                print("low_price=",low_price)
                close_price = coin[4] #비트코인 종가
                print("close_price=",close_price)
                volume = coin [5] #거래량
                print("volume=", volume)
                print("="*100)
                
                #open_time(비트코인 날짜와 시간)이 일치하는 행의 개수 조회하는 쿼리
                count_sql = "select count(*) from coin where open_time=%s"
                cursor.execute(count_sql,(open_time))
                
                #조회 결과 저장
                count = cursor.fetchall()[0][0]
                print("count : ", count)
                
                if count < 1:   # 조회날짜가 없음
                    insert_sql = "insert into coin (open_time, open_price, high_price, low_price, close_price, volume, symbol) "
                    insert_sql +="  values(%s,  %s, %s, %s, %s, %s, %s);"    
                                    
                    cursor.execute(insert_sql, (open_time,open_price, high_price, low_price, close_price, volume, coin_name))
                    db.commit()
                    
                else: # 조회날짜가 있다면
                    update_sql = "update coin set open_price=%s, high_price=%s, low_price=%s, close_price=%s, volume=%s, symbol=%s where open_time=%s;"
                    
                    cursor.execute(update_sql, (open_price, high_price, low_price, close_price, volume, coin_name ,open_time))
                    db.commit()
                    
            #coin_list[-1][0] : 코인 리스트 마지막 행 (-1) 0번째 열 => 수집한 마지막 시간이 int 로 저장되 있음
            # 단위는 1/1000 초
            #60000 -> 60초 후 시간을 시작 시간으로 데이터 수집 
            start = coin_list[-1][0] + 60000  # 다음 step으로
            #print("coin_list[-1][0] + 60000 =",coin_list[-1][0] + 60000)
            #print("start=",start)
            time.sleep(1)
        
        db.close()

    py_t1 = PythonOperator(
        task_id='py_t1004_01', #실행할 task id
        python_callable=get_bitcoin #실행 할 함수
    )

    # 비트코인 가격 예측값을 DB에 저장
    def get_predict():
        import pymysql
        from prophet import Prophet
        import pandas as pd
        
        #데이터베이스 연결
        db = pymysql.connect(
            host='192.168.0.171' # MySQL 이 설치된 컴퓨터 IP 주소
            ,port=3306
            ,user='root'
            ,passwd='1234'
            ,db='coin_db'
            ,charset='utf8'
        )
        
        #데이터베이스 쿼리를 실행할 객체
        cursor=db.cursor()
        
        # 가장 최근 데이터 14400개 데이터 저장
        # 1일 : 60*24 = 1440개의 데이터 생성
        # 10일 -> 14400개
        #10일치의 비트코인 가격 조회
        
        # 날짜 데이터 ASC (오래된 데이터 -> 최근 데이터) 정렬
        sql = "SELECT c.* FROM (SELECT open_time AS ds, close_price AS y FROM coin " 
        sql += "ORDER BY open_time DESC limit 14400) AS c ORDER BY c.ds ASC ;"
        
        #조회한 결과를 DataFrame에 저장
        bitcoin_df = pd.read_sql(sql, db)
        
        # prophet 의 input data columns 는 'ds'와 'y'로 고정되어야 한다.
        ## seasonality_mode : 연간, 월간, 주간, 일간 등의 트렌드성을 반영하는 것을 의미
        ### changepoint_prior_scale : 트렌드가 변경되는 문맥을 반영하여 예측, 수치가 높을수록 트렌드를 더 반영
        ### 비트코인의 데이터의 경우, 대부분의 주기마다 트렌드성이 반영되는 것이 좋다.
        prophet = Prophet(
            seasonality_mode='multiplicative', # 트렌드 반영
            yearly_seasonality=True, # 연간 트렌드
            weekly_seasonality=True, # 주간 트렌드
            daily_seasonality=True, # 일간 트렌드
            changepoint_prior_scale=0.5 # 트렌드 반영 비율
        )
        
        # 예측하기 위해 기존 데이터 파악
        prophet.fit(bitcoin_df)

        # 1분씩 데이터 60개 (60분) 예측하도록 설정
        future_data = prophet.make_future_dataframe(periods=60, freq='min')
        
        # 비트코인 가격 예측
        forecast_data = prophet.predict(future_data)    

        # future data 행의 수 리턴
        df_count = len(future_data)
        
        for i in range(df_count):
            # 실제 비트코인 가격 정보가 저장된 bitcoin_df 의 index 행 ds 열의 데이터 리턴
            open_time = future_data.loc[i,'ds']
            print("오픈 시간 : ", open_time)
            
            # 예측값이 저장된 forecast_data 의 index 행 ds 열의 데이터 리턴
            predict_price = forecast_data.loc[i,"yhat"]
            print("예측 가격 : ", predict_price)
            
            # open_time과 일치하는 시간의 레코드 개수 조회 쿼리
            count_sql = "SELECT COUNT(*) FROM coin WHERE open_time=%s ;"
            cursor.execute(count_sql, open_time)
            
            count= cursor.fetchall()[0][0]
            
            if count >= 1: # 존재하는 값이라면
                # 예측값이 null 인 데이터 수 조회
                predict_count_sql = "SELECT COUNT(*) FROM coin WHERE open_time=%s AND predic_price IS NULL ;"
                cursor.execute(predict_count_sql, open_time)
                predict_count = cursor.fetchall()[0][0]
                print("예측 값 수 : ", predict_count)
                
                if predict_count >= 1 : # 예측값이 null 인 값이 1개 이상 존재
                    # coin 테이블에 예측값을 넣는 쿼리, 기존 null 값, update 사용
                    update_sql = 'update coin set predic_price=%s where open_time=%s;'

                    cursor.execute(update_sql,(predict_price, open_time))
                    db.commit()
            
            else: # 없는 데이터라면
                insert_sql = "insert into coin (open_time, predic_price) values(%s, %s)"
                cursor.execute(insert_sql,(open_time, predict_price))
                db.commit()
                
            print("="*100)

        db.close()
        
    py_t2 = PythonOperator(
        task_id='py_t1004_02', #실행할 task id
        python_callable=get_predict #실행 할 함수
    )
    
    # py_t1 실행 후 py_t2
    py_t1 >> py_t2