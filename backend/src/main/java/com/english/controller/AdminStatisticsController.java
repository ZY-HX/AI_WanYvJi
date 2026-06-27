package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AdminStatisticsOverviewResponse;
import com.english.dto.AdminStatisticsTrendPointResponse;
import com.english.dto.AuthenticatedUser;
import com.english.service.AdminStatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "管理端-统计仪表板", description = "管理员查看平台统计概览与趋势图数据")
@Validated
@RestController
@RequestMapping("/api/admin/statistics")
@RequiredArgsConstructor
public class AdminStatisticsController {

    private final AdminStatisticsService adminStatisticsService;

    @Operation(summary = "获取仪表板概览数据")
    @GetMapping("/overview")
    public Result<AdminStatisticsOverviewResponse> getOverview(Authentication authentication) {
        requireAdmin(authentication);
        return Result.success("获取统计概览成功", adminStatisticsService.getOverview());
    }

    @Operation(summary = "获取用户增长趋势")
    @GetMapping("/user-trend")
    public Result<List<AdminStatisticsTrendPointResponse>> getUserTrend(
            Authentication authentication,
            @RequestParam(defaultValue = "30") @Min(value = 1, message = "天数必须大于0")
            @Max(value = 365, message = "天数不能超过365") int days
    ) {
        requireAdmin(authentication);
        return Result.success("获取用户增长趋势成功", adminStatisticsService.getUserTrend(days));
    }

    @Operation(summary = "获取学习活跃度趋势")
    @GetMapping("/study-activity")
    public Result<List<AdminStatisticsTrendPointResponse>> getStudyActivity(
            Authentication authentication,
            @RequestParam(defaultValue = "7") @Min(value = 1, message = "天数必须大于0")
            @Max(value = 365, message = "天数不能超过365") int days
    ) {
        requireAdmin(authentication);
        return Result.success("获取学习活跃度趋势成功", adminStatisticsService.getStudyActivity(days));
    }

    @Operation(summary = "获取AI调用趋势")
    @GetMapping("/ai-usage")
    public Result<List<AdminStatisticsTrendPointResponse>> getAiUsage(
            Authentication authentication,
            @RequestParam(defaultValue = "7") @Min(value = 1, message = "天数必须大于0")
            @Max(value = 365, message = "天数不能超过365") int days
    ) {
        requireAdmin(authentication);
        return Result.success("获取AI调用趋势成功", adminStatisticsService.getAiUsage(days));
    }

    private AuthenticatedUser requireAdmin(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问管理端接口");
        }
        if (!"ADMIN".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "仅管理员可访问");
        }
        return authenticatedUser;
    }
}
