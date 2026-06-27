package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class StudyExportRecordResponse {

    private String english;

    private String chinese;

    private String studyMode;

    private Integer reviewCount;

    private Integer correctCount;

    private Integer wrongCount;

    private LocalDateTime nextReviewTime;
}
