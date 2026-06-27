package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.NotificationResponse;
import com.english.dto.NotificationUnreadCountResponse;
import com.english.dto.PageResponse;
import com.english.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "消息通知", description = "站内消息查询、已读标记与未读数量接口")
@Validated
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @Operation(summary = "分页获取当前用户消息列表")
    @GetMapping
    public Result<PageResponse<NotificationResponse>> getNotifications(
            Authentication authentication,
            @RequestParam(name = "is_read", required = false) Integer isRead,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取消息列表成功",
                notificationService.getNotifications(currentUser.getUserId(), isRead, current, size));
    }

    @Operation(summary = "标记单条消息为已读")
    @PutMapping("/{id}/read")
    public Result<Void> markRead(
            Authentication authentication,
            @PathVariable Long id
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        notificationService.markRead(currentUser.getUserId(), id);
        return Result.success("消息已标记为已读", null);
    }

    @Operation(summary = "全部标记为已读")
    @PutMapping("/read-all")
    public Result<Integer> markAllRead(Authentication authentication) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        int updatedCount = notificationService.markAllRead(currentUser.getUserId());
        return Result.success("全部消息已标记为已读", updatedCount);
    }

    @Operation(summary = "获取当前用户未读数量")
    @GetMapping("/unread-count")
    public Result<NotificationUnreadCountResponse> getUnreadCount(Authentication authentication) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取未读数量成功", notificationService.getUnreadCount(currentUser.getUserId()));
    }

    private AuthenticatedUser requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问消息通知");
        }
        return authenticatedUser;
    }
}

