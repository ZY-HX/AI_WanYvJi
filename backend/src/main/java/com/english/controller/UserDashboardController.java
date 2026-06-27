package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.DashboardDetailResponse;
import com.english.dto.DashboardHomeResponse;
import com.english.service.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "用户仪表板", description = "首页仪表板数据统计接口")
@RestController
@RequestMapping("/api/user/dashboard")
@RequiredArgsConstructor
public class UserDashboardController {

    private final DashboardService dashboardService;

    @Operation(summary = "获取首页仪表板统计数据")
    @GetMapping("/home")
    public Result<DashboardHomeResponse> getHomeDashboard(Authentication authentication) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        DashboardHomeResponse dashboard = dashboardService.getHomeDashboard(currentUser.getUserId());
        return Result.success("获取仪表板数据成功", dashboard);
    }

    @Operation(summary = "获取详细数据看板统计")
    @GetMapping("/detail")
    public Result<DashboardDetailResponse> getDetailDashboard(Authentication authentication) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        DashboardDetailResponse detail = dashboardService.getDetailDashboard(currentUser.getUserId());
        return Result.success("获取详细数据成功", detail);
    }

    private AuthenticatedUser requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问仪表板");
        }
        return authenticatedUser;
    }
}
