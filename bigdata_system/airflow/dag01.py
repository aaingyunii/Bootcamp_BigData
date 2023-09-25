from airflow import DAG
import datetime
import pendulum
from airflow.operators.bash import BashOperator

with DAG(
    #Dag (workflow) 의 아이디로 고유한 값이어야 함
    dag_id="dag01",
    #Dag를 실행 할 시간
    schedule="0 0 * * *", # 매일 0시 0분 마다
    #Dag를 실행 시작할 시간
    start_date=pendulum.datetime(2023, 9, 24, tz="Asia/Seoul"),
    catchup=False
) as dag:

    #Workflow의 작업 task 설정
    bash_t1 = BashOperator(
        task_id="bash_t092511", #task id (고유한 값이어야 한다)
        bash_command="echo hello", # task가 해야 할 일
    )

    #Workflow의 작업 task 설정
    bash_t2 = BashOperator(
        task_id="bash_t092512", #task id (고유한 값이어야 한다)
        bash_command="echo $HOSTNAME", # task가 해야 할 일
    )

   #bash_t1 작업 한 후에 bash_t2 작업을 수행하도록 작업의 순서 설정
    bash_t1 >> bash_t2