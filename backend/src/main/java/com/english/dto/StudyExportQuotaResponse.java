package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class StudyExportQuotaResponse {

    private Integer totalQuota;

    private Integer usedCount;

    private Integer remainingCount;

    private LocalDateTime resetTime;
}
