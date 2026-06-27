package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class AiArticleGenerateResponse {

    private Long logId;

    private Long wordBankId;

    private String theme;

    private String difficulty;

    private String length;

    private String content;

    private List<AiArticleHighlightWordResponse> highlightWords;

    private Integer duration;

    private LocalDateTime generatedAt;

    private AiArticleQuotaResponse quota;
}
