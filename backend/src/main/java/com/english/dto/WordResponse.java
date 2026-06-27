package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class WordResponse {

    private Long id;

    private Long wordBankId;

    private String english;

    private String language;

    private String phonetic;

    private String chinese;

    private String example;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
