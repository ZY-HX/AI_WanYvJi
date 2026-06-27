package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AiArticleHistoryItemResponse {

    private Long id;

    private Long wordBankId;

    private String wordBankName;

    private String theme;

    private String difficulty;

    private String length;

    private Integer duration;

    private LocalDateTime createdAt;
}
