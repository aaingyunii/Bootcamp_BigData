# 부트캠프 `빅데이터 시스템` 관련 학습
플레이데이터 부트캠프 데이터 엔지니어링 과정에서 "빅데이터"와 관련된 여러 학습 과정이 담긴 repo 입니다. 일부 내용은 해당 학습을 위한 과정과 관련 있습니다.

<br>

## ✅ `bigdata_system` 폴더

- `dockerfile, airflow, hive, pig, elasticsearch, spark, kafka` 등 **빅데이터 시스템 관련 학습** 과정
<br>

## ✅ `movie_web` 프로젝트 폴더 🎦

1. "네이버 영화 검색" 을 통해 **`데이터 웹 크롤링`** 후 추천 모델을 작성<br>

1. **`Flask`** 를 통해 웹 서버에서 동작 => **AWS 를 통해 배포 - 모델 서버** <br>

1. **`Spring boot`** 를 통해 백엔드 구성 => **AWS 를 통해 배포 - 백엔드 서버** <br>

1. **`ReactJS`** 를 통해 프론트 엔드 구성 => **AWS 를 통해 배포 - 프론트 엔드 서버**
<br>

## ✅ `jeju_bus_mini_project` 폴더

- `jeju_bus.csv` 파일 데이터 활용 : `pig table` 저장
  
- **`ElasticSearch` 와 `Kibana` 를 통해 각종 시각화 및 EDA** : `export.ndjson`
<br>

## ✅ `stock_mini_project` 폴더

- `Hadoop` 에 저장된 `finance_y.csv` 와 `stock.csv` , `history_dt.csv` 파일 데이터 활용
  
- `Hive table` 에 저장 후 `DBeaver` 프로그램을 통해 각종 SQL 쿼리문을 통해
  
- **2019년의 주가 변동사항을 고려해 2020년도에 투자해야할 종목 검색**<br>

- <u>투자 종목 선정 기준</u> : <br> <u>**주당순이익(PER)** 값이 0~4 사이의 기업 중 19년도 주가 등락률을 기준으로 정렬 후 선정</u>
  
- 배포한 `볼린저밴드, 모멘텀 지표, MACD` 모델 등을 활용해 선정된 투자 종목을 학습-모델링 후 최종, 매수-매도 타임 잡기

> `finance_y` : 기업들의 재무상태의 일부 정보<br>
> `stock` : 종목명, 종목코드, 섹터명 등의 정보<br>
> `history_dt` : 2019년 1월 1일부터 2020년 12월30일까지의 당일 주식 정보
