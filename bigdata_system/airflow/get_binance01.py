from airflow import DAG
import pendulum
import datetime
from airflow.operators.python import PythonOperator
import random

with DAG(
    dag_id="get_binance01",#DAG 아이디
    schedule_interval="@hourly", #시간마다 실행
    start_date=pendulum.datetime(2023, 9, 27, tz="Asia/Seoul"), #2023년 9월 27일 부터 실행
    catchup=False
) as dag:

    def get_bitcoin():
        import requests #
        from datetime import datetime,timezone, timedelta
        import time
        import pytz
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

            #coin_list[-1][0] : 코인 리스트 마지막 행 (-1) 0번째 열 => 수집한 마지막 시간이 int 로 저장되 있음
            # 단위는 1/1000 초
            #60000 -> 60초 후 시간을 시작 시간으로 데이터 수집 
            start = coin_list[-1][0] + 60000  # 다음 step으로
            #print("coin_list[-1][0] + 60000 =",coin_list[-1][0] + 60000)
            #print("start=",start)
            time.sleep(1)

    py_t1 = PythonOperator(
        task_id='py_t0927_01', #실행할 task id
        python_callable=get_bitcoin #실행 할 함수
    )

    py_t1