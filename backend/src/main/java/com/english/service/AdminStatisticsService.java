package com.english.service;

import com.english.dto.AdminStatisticsOverviewResponse;
import com.english.dto.AdminStatisticsTrendPointResponse;
import com.english.mapper.AdminStatisticsMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminStatisticsService {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private final AdminStatisticsMapper adminStatisticsMapper;

    public AdminStatisticsOverviewResponse getOverview() {
        LocalDate today = LocalDate.now();
        LocalDateTime start = today.atStartOfDay();
        LocalDateTime end = today.plusDays(1L).atStartOfDay();

        AdminStatisticsOverviewResponse response = new AdminStatisticsOverviewResponse();
        response.setTotalUsers(nullToZero(adminStatisticsMapper.countTotalUsers()));
        response.setTodayNewUsers(nullToZero(adminStatisticsMapper.countNewUsersBetween(start, end)));
        response.setTotalWordBanks(nullToZero(adminStatisticsMapper.countTotalWordBanks()));
        response.setTodayStudyRecords(nullToZero(adminStatisticsMapper.countStudyRecordsBetween(start, end)));
        response.setTotalAiGenerations(nullToZero(adminStatisticsMapper.countTotalAiGenerations()));
        response.setTodayAiGenerations(nullToZero(adminStatisticsMapper.countAiGenerationsBetween(start, end)));
        return response;
    }

    public List<AdminStatisticsTrendPointResponse> getUserTrend(int days) {
        DateRange dateRange = buildDateRange(days);
        List<AdminStatisticsTrendPointResponse> rawData = adminStatisticsMapper.selectUserTrend(
                dateRange.startDateTime(),
                dateRange.endDateTime()
        );
        return fillMissingDates(dateRange.startDate(), days, rawData);
    }

    public List<AdminStatisticsTrendPointResponse> getStudyActivity(int days) {
        DateRange dateRange = buildDateRange(days);
        List<AdminStatisticsTrendPointResponse> rawData = adminStatisticsMapper.selectStudyActivity(
                dateRange.startDateTime(),
                dateRange.endDateTime()
        );
        return fillMissingDates(dateRange.startDate(), days, rawData);
    }

    public List<AdminStatisticsTrendPointResponse> getAiUsage(int days) {
        DateRange dateRange = buildDateRange(days);
        List<AdminStatisticsTrendPointResponse> rawData = adminStatisticsMapper.selectAiUsage(
                dateRange.startDateTime(),
                dateRange.endDateTime()
        );
        return fillMissingDates(dateRange.startDate(), days, rawData);
    }

    private DateRange buildDateRange(int days) {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(days - 1L);
        return new DateRange(startDate, startDate.atStartOfDay(), endDate.plusDays(1L).atStartOfDay());
    }

    private List<AdminStatisticsTrendPointResponse> fillMissingDates(
            LocalDate startDate,
            int days,
            List<AdminStatisticsTrendPointResponse> rawData
    ) {
        Map<String, Long> valueMap = new HashMap<>();
        for (AdminStatisticsTrendPointResponse item : rawData) {
            valueMap.put(item.getDate(), nullToZero(item.getValue()));
        }

        return startDate.datesUntil(startDate.plusDays(days))
                .map(date -> {
                    AdminStatisticsTrendPointResponse point = new AdminStatisticsTrendPointResponse();
                    String key = date.format(DATE_FORMATTER);
                    point.setDate(key);
                    point.setValue(valueMap.getOrDefault(key, 0L));
                    return point;
                })
                .toList();
    }

    private long nullToZero(Long value) {
        return value == null ? 0L : value;
    }

    private record DateRange(
            LocalDate startDate,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
    }
}
