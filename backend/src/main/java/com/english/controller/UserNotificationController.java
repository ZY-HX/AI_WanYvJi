package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.NotificationUnreadCountResponse;
import com.english.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "用户消息通知", description = "用户站内消息快捷接口")
@RestController
@RequestMapping("/api/user/notifications")
@RequiredArgsConstructor
public class UserNotificationController {

    private final NotificationService notificationService;

    @Operation(summary = "获取当前用户未读消息数量")
    @GetMapping("/unread-count")
    public Result<NotificationUnreadCountResponse> getUnreadCount(Authentication authentication) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取未读数量成功", notificationService.getUnreadCount(currentUser.getUserId()));
    }

    private AuthenticatedUser requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问消息通知");
        }
        if ("GUEST".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "游客模式不支持访问消息通知");
        }
        return authenticatedUser;
    }
}
