# Flask를 통해 노트북으로 실행한 코드들, 영화 추천 시스템을
## 웹으로 전달하려고 한다.
### Rest Server

from flask import Flask, request
import json
import pymysql

import pandas as pd
import numpy as np
from tqdm import tqdm
from sklearn.metrics.pairwise import euclidean_distances
from sklearn.preprocessing import StandardScaler

db = pymysql.connect(
    # host = "aws db 엔드포인트",
    host="database-1.csv7mtiwmjcc.ap-northeast-2.rds.amazonaws.com",
    port=3306,
    user='admin',
    # passwd='관리자 계정 비밀번호',
    passwd="rbsldks43198!",
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

app = Flask(__name__)


# POST 방식으로 movie_recommend URL 일 때, 실행
@app.route('/movie_recommend',methods=["POST"])
def hello_world():
    # 입력한 제목 값 리턴
    req_title = request.form["title"]
    
    # 입력한 영화 제목과 가장 가까운 영화 3편을 result에 할당
    result = sim_df[req_title].sort_values()[1:4]
    
    # 영화 제목이 저장된 result.index 를 리스트로 변환
    result = result.index.tolist()
    
    # Json 문자열로 변환
    result = json.dumps(result, ensure_ascii=False)
    
    return result

if __name__ == "__main__":
    app.run(host="0.0.0.0") # Flask 시작, host = "0.0.0.0" 다른 컴퓨터에서 접속 가능