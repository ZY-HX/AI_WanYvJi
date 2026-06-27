package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ErrorBookResponse {

    private Long id;
    private Long wordId;
    private Long wordBankId;
    private String wordBankName;
    private String english;
    private String phonetic;
    private String chinese;
    private String example;
    private String errorType;
    private Integer errorTimes;
    private Integer isMastered;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
