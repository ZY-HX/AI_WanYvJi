package com.english.dto;

import lombok.Data;

@Data
public class AdminStatisticsOverviewResponse {

    private Long totalUsers;

    private Long todayNewUsers;

    private Long totalWordBanks;

    private Long todayStudyRecords;

    private Long totalAiGenerations;

    private Long todayAiGenerations;
}
