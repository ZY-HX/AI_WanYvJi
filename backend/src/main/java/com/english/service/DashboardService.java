package com.english.service;

import com.english.dto.DashboardDetailResponse;
import com.english.dto.DashboardHomeResponse;
import com.english.mapper.ErrorBookMapper;
import com.english.mapper.UserStudyRecordMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class DashboardService {

    private final UserStudyRecordMapper userStudyRecordMapper;
    private final ErrorBookMapper errorBookMapper;

    public DashboardHomeResponse getHomeDashboard(Long userId) {
        DashboardHomeResponse response = new DashboardHomeResponse();

        LocalDateTime now = LocalDateTime.now();
        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();
        LocalDateTime todayEnd = today.plusDays(1).atStartOfDay();

        long todayReviewCount = userStudyRecordMapper.countTodayReviewWords(userId, now);
        response.setTodayReviewCount((int) todayReviewCount);

        int consecutiveDays = calculateConsecutiveStudyDays(userId, today);
        response.setConsecutiveDays(consecutiveDays);

        long todayStudyRecords = userStudyRecordMapper.countTodayStudyRecords(userId, todayStart, todayEnd);
        int studyMinutes = estimateStudyMinutes(todayStudyRecords);
        response.setTodayStudyMinutes(studyMinutes);

        long totalWordsLearned = userStudyRecordMapper.countTotalLearnedWords(userId);
        response.setTotalWordsLearned((int) totalWordsLearned);

        long activeWordBanks = userStudyRecordMapper.countActiveWordBanks(userId);
        response.setTotalWordBanks((int) activeWordBanks);

        return response;
    }

    public DashboardDetailResponse getDetailDashboard(Long userId) {
        DashboardDetailResponse response = new DashboardDetailResponse();

        long totalVocabulary = userStudyRecordMapper.countTotalLearnedWords(userId);
        response.setTotalVocabulary((int) totalVocabulary);

        int totalCorrectCount = userStudyRecordMapper.sumTotalCorrectCount(userId);
        int totalWrongCount = userStudyRecordMapper.sumTotalWrongCount(userId);

        response.setTotalCorrectCount(totalCorrectCount);
        response.setTotalWrongCount(totalWrongCount);

        double accuracyRate = 0.0;
        if (totalCorrectCount + totalWrongCount > 0) {
            accuracyRate = (double) totalCorrectCount / (totalCorrectCount + totalWrongCount) * 100;
            accuracyRate = Math.round(accuracyRate * 100.0) / 100.0;
        }
        response.setTotalAccuracyRate(accuracyRate);

        long errorBookCount = errorBookMapper.countUserErrorBooks(userId);
        response.setErrorBookCount((int) errorBookCount);

        LocalDateTime now = LocalDateTime.now();
        LocalDate today = LocalDate.now();

        LocalDateTime dailyStart = today.minusDays(29).atStartOfDay();
        LocalDateTime dailyEnd = today.plusDays(1).atStartOfDay();
        List<Map<String, Object>> dailyData = userStudyRecordMapper.selectDailyTrend(userId, dailyStart, dailyEnd);
        response.setDailyTrend(convertToTrendPoints(dailyData));

        LocalDateTime weeklyStart = today.minusWeeks(11).with(TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY)).atStartOfDay();
        LocalDateTime weeklyEnd = today.plusDays(1).atStartOfDay();
        List<Map<String, Object>> weeklyData = userStudyRecordMapper.selectWeeklyTrend(userId, weeklyStart, weeklyEnd);
        response.setWeeklyTrend(convertToTrendPoints(weeklyData));

        LocalDateTime monthlyStart = today.with(TemporalAdjusters.firstDayOfMonth()).minusMonths(11).atStartOfDay();
        LocalDateTime monthlyEnd = today.plusDays(1).atStartOfDay();
        List<Map<String, Object>> monthlyData = userStudyRecordMapper.selectMonthlyTrend(userId, monthlyStart, monthlyEnd);
        response.setMonthlyTrend(convertToTrendPoints(monthlyData));

        return response;
    }

    private List<DashboardDetailResponse.TrendPoint> convertToTrendPoints(List<Map<String, Object>> data) {
        List<DashboardDetailResponse.TrendPoint> trendPoints = new ArrayList<>();
        for (Map<String, Object> row : data) {
            String date = String.valueOf(row.get("date"));
            if (row.containsKey("weekDate")) {
                date = String.valueOf(row.get("weekDate"));
            } else if (row.containsKey("monthDate")) {
                date = String.valueOf(row.get("monthDate"));
            }

            int studyCount = ((Number) row.get("studyCount")).intValue();
            int correctCount = ((Number) row.get("correctCount")).intValue();
            int wrongCount = ((Number) row.get("wrongCount")).intValue();
            int newWordsCount = ((Number) row.get("newWordsCount")).intValue();

            trendPoints.add(new DashboardDetailResponse.TrendPoint(date, studyCount, correctCount, wrongCount, newWordsCount));
        }
        return trendPoints;
    }

    private int calculateConsecutiveStudyDays(Long userId, LocalDate today) {
        int consecutiveDays = 0;
        LocalDate checkDate = today.minusDays(1);

        while (true) {
            LocalDateTime dayStart = checkDate.atStartOfDay();
            LocalDateTime dayEnd = checkDate.plusDays(1).atStartOfDay();
            int studyDays = userStudyRecordMapper.countStudyDaysInRange(userId, dayStart, dayEnd);

            if (studyDays > 0) {
                consecutiveDays++;
                checkDate = checkDate.minusDays(1);
            } else {
                break;
            }

            if (consecutiveDays >= 365) {
                break;
            }
        }

        LocalDateTime todayStart = today.atStartOfDay();
        LocalDateTime todayEnd = today.plusDays(1).atStartOfDay();
        int todayStudyDays = userStudyRecordMapper.countStudyDaysInRange(userId, todayStart, todayEnd);
        if (todayStudyDays > 0) {
            consecutiveDays++;
        }

        return consecutiveDays;
    }

    private int estimateStudyMinutes(long recordCount) {
        if (recordCount <= 0) {
            return 0;
        }
        int estimatedMinutes = (int) (recordCount / 10);
        return Math.max(estimatedMinutes, 1);
    }
}
