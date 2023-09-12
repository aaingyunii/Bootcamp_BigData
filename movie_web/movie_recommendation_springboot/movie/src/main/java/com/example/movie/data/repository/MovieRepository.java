package com.example.movie.data.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.movie.data.entity.Movie;

@Repository
public interface MovieRepository extends JpaRepository<Movie, String>{
    @Query(value = "select * from movie m where m.title=:title limit 1", nativeQuery=true)
    public Movie findByTitle (@Param(value="title") String title);

    @Query(value = "select * from movie m order by num limit 5", nativeQuery = true)
    public List<Movie> findBoxOffice();
}
