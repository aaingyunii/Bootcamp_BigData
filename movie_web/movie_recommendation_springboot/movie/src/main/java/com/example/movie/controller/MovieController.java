package com.example.movie.controller;

import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.entity.UrlEncodedFormEntity;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.movie.data.entity.Movie;
import com.example.movie.data.repository.MovieRepository;
import com.mysql.cj.xdevapi.JsonArray;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
public class MovieController {
    @Autowired
    // SQL 쿼리를 실행하는 객체 주입
    private MovieRepository movieRepository;

    @RequestMapping(value = "/box_office")
    @ResponseBody // Json 문자열 리턴
    // 박스 오피스 가장 흥행한 영화 5개와 각 영화와 가장 가까운 영화 3개 추천
    public String boxOffice() throws Exception{
        List<Movie> boxOfficeList = movieRepository.findBoxOffice();

        // 박스 오피스 흥행 영화와 추천 영화가 모두 저장될 객체
        List<Map> allMovie = new ArrayList<Map>();

        for(int i=0;i<boxOfficeList.size();i++){
            // 영화 한편과 해당 영화의 추천 영화가 저장될 객체
            Map oneMovie = new HashMap();
            Movie movie = boxOfficeList.get(i);
            
            oneMovie.put("movie", movie);

            ArrayList<Movie> recommendMovieList = new ArrayList<Movie>();
            String movieTitle = movie.getTitle();

            log.info("영화 제목 : "+movieTitle);

            // 호출할 Flask의 url 설정
            HttpPost httpPost = new HttpPost("호출할 Flask의 url/movie_recommend");

            // Flask로 전송할 영화 제목을 저장할 객체
            List<BasicNameValuePair> nvps = new ArrayList<>();
            // 전송할 영화 제목 설정 (파라미터 이름, 파라미터 값)
            nvps.add(new BasicNameValuePair("title", movieTitle));
            // Flask로 전송할 문자 타입 설정 UTF-8
            httpPost.setEntity(
                    new UrlEncodedFormEntity(nvps, Charset.forName("UTF-8"))
            );

            // Flask에 접속해서 실행 결과를 가져올 객체 생성
            CloseableHttpClient httpClient = HttpClients.createDefault();
            // 실행 결과를 가져옴
            CloseableHttpResponse response2 = httpClient.execute(httpPost);
            // 결과 할당
            String flaskResult = 
                        EntityUtils.toString(response2.getEntity(),
                                Charset.forName("UTF-8"));

            log.info("플라스크 결과 : "+flaskResult);

            // Flask 서버와 연결 종료
            httpClient.close();
            
            try{
                // Flask 서버에서 가져온 문자열을 Json 형태 객체로 변환
                JSONArray jsonArray = new JSONArray(flaskResult);

                // jsonArray.length() : 추천 영화 수
                for(int j=0; j < jsonArray.length();j++){
                    // j번째 추천 영화 리턴
                    JSONArray recommend = jsonArray.getJSONArray(j);
                    // 0번째 영화 제목 리턴
                    String recommendTitle = recommend.getString(0);
                    // 추천 영화를 DB에서 조회
                    Movie recommendMoive = movieRepository.findByTitle(recommendTitle);
                    recommendMovieList.add(recommendMoive);
                }

                oneMovie.put("recommend", recommendMovieList);
                allMovie.add(oneMovie);
                
            }catch(Exception e){
                log.info("에러 : "+e);
            }
        }
        JSONArray movieMovie = new JSONArray(allMovie);
        // log.info("무비무비 : "+movieMovie.getJSONObject(1));
        for(int i=0;i<movieMovie.length();i++){
            JSONObject tmp = movieMovie.getJSONObject(i);
            // log.info("템프템프 : "+tmp);
            log.info("템프 무비 : "+tmp.getJSONObject("movie"));
            JSONObject temp = tmp.getJSONObject("movie");
            
        }
        return movieMovie.toString();
        
    }
}
