package com.english.dto;

import lombok.Data;

import java.util.List;

@Data
public class AiArticleHistoryDetailResponse {

    private Long id;

    private Long wordBankId;

    private String wordBankName;

    private String theme;

    private String difficulty;

    private String length;

    private Integer duration;

    private String content;

    private List<AiArticleHighlightWordResponse> highlightWords;

    private String translation;

    private java.time.LocalDateTime createdAt;
}
