package com.example.movie.data.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;

import lombok.Data;

@Data // setter, getter, toString 자동생성
@Entity(name = "movie")
public class Movie {
    @Id
    private int num;

    private String title;

    private String poster;

    private String degree;

    private String genre;

    @Column
    private String openDate;

    private String country;

    private String movieTime;

    private String synopsis;
}
