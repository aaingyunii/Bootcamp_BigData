# Flask를 통해 노트북으로 실행한 코드들, 영화 추천 시스템을
## 웹으로 전달하려고 한다.
### Rest Server

from flask import Flask, request, render_template
import json
import pymysql
import pandas as pd
import numpy as np
from tqdm import tqdm
from sklearn.metrics.pairwise import euclidean_distances
from sklearn.preprocessing import StandardScaler

db = pymysql.connect(
    # host = "aws db 엔드포인트",
    host="",
    port=3306,
    user='admin',
    # passwd='관리자 계정 비밀번호',
    passwd="",
    db='movie_db',
    charset='utf8'
)

# select 쿼리를 통해 DB 데이터 -> DataFrame으로 불러옴
sql = "SELECT * FROM movie"
movie_df = pd.read_sql(sql, db)

# 모든 행의 synopsis_vector 컬럼을 numpy 배열로 변환해 synopsis_vector_numpy 에 할당
movie_df.loc[:,"synopsis_vector_numpy"] = \
    movie_df.loc[:,"synopsis_vector"].apply(lambda x : np.fromstring(x, dtype="float32"))

# 데이터의 각 열의 평균을 뺀 다음 표준편차로 
## 나눠 평균을 0으로 표준편차를 1로 변환하는 `StandardScalar` 객체 생성
scaler = StandardScaler()

# 각 열의 평균 표준편차 계산
scaler.fit(np.array(movie_df["synopsis_vector_numpy"].tolist()))

# 데이터의 각 열의 평균을 뺀 다음 표준편차로 나눈 후
## 평균을  0, 표준편차를 1로 변환한 후
### 리스트로 변환해 synopsis_vector_numpy_scale 컬럼에 삽입
movie_df["synopsis_vector_numpy_scale"] = \
    scaler.transform(np.array(movie_df["synopsis_vector_numpy"].tolist())).tolist()
    

# synopsis_vector_numpy_scale 컬럼의 유클리드 거리를 계산
sim_score = euclidean_distances(
    movie_df["synopsis_vector_numpy_scale"].tolist(),
    movie_df["synopsis_vector_numpy_scale"].tolist())

sim_df = pd.DataFrame(data=sim_score)

sim_df.index = movie_df["title"]
sim_df.columns = movie_df["title"]

### 웹서버가 열리기 이전에 추천 모델에 필요한 작업들을 미리 해놔
### 웹에서 실행되는 속도를 올릴 수 있음.
### 위 과정은 MySQL DB 데이터를 가져와 파이썬 내부에서 DataFrame을 통해
### 데이터를 조작하고, scaling, euclidean_distance 계산을 미리 해놓은 상태.



################# 웹 서버 동작관련 ########################
app = Flask(__name__)

@app.route("/", methods=["GET"])
def main():
    return render_template("index.html")

# POST 방식으로 main() 에서 작성된 값을 받아
## 해당 URL 에서 동작
@app.route("/ffirst", methods=["POST"])
def ffirst():
    user_id = request.form["id"]
    user_pw = request.form["pw"]

    return "아이디 : "+user_id+"\n비밀번호 : "+user_pw


# POST 방식으로 movie_recommend URL 일 때, 실행
@app.route('/movie_recommend',methods=["POST"])
def hello_world():
    # 입력한 제목 값 리턴
    req_title = request.form["title"]
    # 입력한 영화 제목과 가장 가까운 영화 3편을 result에 할당
    result = sim_df[req_title].sort_values()[1:4]
    # 영화 제목이 저장된 result.index 를 리스트로 변환
    result = result.reset_index().values.tolist()
    # Json 문자열로 변환
    result = json.dumps(result, ensure_ascii=False)
    
    return result

if __name__ == "__main__":
    app.run(host="0.0.0.0") # Flask 시작, host = "0.0.0.0" 다른 컴퓨터에서 접속 가능
                            ## 따로 port= 설정하지 않았으므로 5000을 사용
                            ### 만약 다른 포트를 사용하면, port= 설정.