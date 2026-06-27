package com.english.dto;

import lombok.Data;

@Data
public class DashboardHomeResponse {

    private int todayReviewCount;
    private int consecutiveDays;
    private int todayStudyMinutes;
    private int totalWordsLearned;
    private int totalWordBanks;
}
