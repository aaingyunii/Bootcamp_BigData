from airflow import DAG
import datetime
import pendulum
from airflow.operators.python import PythonOperator
import random

with DAG(
    #Dag (workflow) 의 아이디로 고유한 값이어야 함
    dag_id="dags_python02",
    #Dag를 실행 할 시간
    schedule="*/1 * * * *", # 매일 매시 10분마다 실행
    #시작 시간
    start_date=pendulum.datetime(2023, 9, 1, tz="Asia/Seoul"),
    catchup=False
) as dag:
    #함수 선언
    def select_fruit():
        fruits = ['APPLE', 'BANANA', 'ORANGE', 'AVOCADO']
        # 0~3 사이 난수 생성
        rand_int = random.randint(0,3)
        #랜덤으로 과일 출력
        print(fruits[rand_int])
        
    # task 선언
    py_t1 = PythonOperator(
        task_id= 'py_t092511',
        python_callable= select_fruit # task에서 실행할 파이썬 함수 설정
    )
    
    def select_movie():
        movies=['잠' ,'밀수' ,'콘트리트유토피아' ,'범죄도시3']
        # 0~3 사이 난수 생성
        rand_int = random.randint(0,3)
        #랜덤으로 영화 출력
        print(movies[rand_int])
        
    # task 선언
    py_t2 = PythonOperator(
        task_id= 'py_t092512',
        python_callable= select_movie # task에서 실행할 파이썬 함수 설정
    )
    
    # py_t1 실행 후 py_t2 실행
    py_t1 >> py_t2