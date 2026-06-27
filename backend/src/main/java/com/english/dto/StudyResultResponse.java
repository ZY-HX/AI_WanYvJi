package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class StudyResultResponse {

    private Long recordId;

    private Long wordId;

    private Long wordBankId;

    private String studyMode;

    private Integer correctCount;

    private Integer wrongCount;

    private Integer reviewCount;

    private LocalDateTime nextReviewTime;
}
