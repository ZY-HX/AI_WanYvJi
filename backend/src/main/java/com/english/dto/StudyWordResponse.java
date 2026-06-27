package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class StudyWordResponse {

    private Long recordId;

    private Long wordId;

    private Long wordBankId;

    private String studyMode;

    private LocalDateTime nextReviewTime;

    private String english;

    private String phonetic;

    private String chinese;

    private String example;
}
