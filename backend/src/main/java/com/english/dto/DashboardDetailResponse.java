package com.english.dto;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class DashboardDetailResponse {

    private int totalVocabulary;

    private double totalAccuracyRate;

    private int totalCorrectCount;

    private int totalWrongCount;

    private int errorBookCount;

    private List<TrendPoint> dailyTrend;

    private List<TrendPoint> weeklyTrend;

    private List<TrendPoint> monthlyTrend;

    @Data
    public static class TrendPoint {
        private String date;
        private int studyCount;
        private int correctCount;
        private int wrongCount;
        private int newWordsCount;

        public TrendPoint() {}

        public TrendPoint(String date, int studyCount, int correctCount, int wrongCount, int newWordsCount) {
            this.date = date;
            this.studyCount = studyCount;
            this.correctCount = correctCount;
            this.wrongCount = wrongCount;
            this.newWordsCount = newWordsCount;
        }
    }
}
