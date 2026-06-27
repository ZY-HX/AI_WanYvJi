package com.english.dto;

import lombok.Data;

@Data
public class StudyWordBankOptionResponse {

    private Long id;

    private String name;

    private String category;

    private String language;

    private Integer wordCount;

    private Integer isPublic;
}
