package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AiArticleQuotaResponse {

    private Integer totalQuota;

    private Integer usedCount;

    private Integer remainingCount;

    private LocalDateTime resetTime;

    private Boolean systemApiKeyConfigured;

    private String defaultBaseUrl;

    private String defaultModel;
}
