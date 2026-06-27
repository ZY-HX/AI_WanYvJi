package com.english.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AnnouncementRequest;
import com.english.dto.AuthenticatedUser;
import com.english.entity.Notification;
import com.english.entity.User;
import com.english.mapper.NotificationMapper;
import com.english.mapper.UserMapper;
import com.english.service.OperationLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "管理端-系统公告", description = "管理员发布系统公告，向所有用户发送站内信")
@RestController
@RequestMapping("/api/admin/notifications")
@RequiredArgsConstructor
public class AdminNotificationController {

    private final UserMapper userMapper;
    private final NotificationMapper notificationMapper;
    private final OperationLogService operationLogService;

    @Operation(summary = "发布系统公告", description = "向所有用户发送系统公告站内信")
    @PostMapping("/announcement")
    @Transactional(rollbackFor = Exception.class)
    public Result<Void> publishAnnouncement(
            Authentication authentication,
            @RequestBody @Validated AnnouncementRequest request
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);

        LambdaQueryWrapper<User> userWrapper = new LambdaQueryWrapper<>();
        userWrapper.eq(User::getStatus, 1);
        List<User> users = userMapper.selectList(userWrapper);

        for (User user : users) {
            Notification notification = new Notification();
            notification.setUserId(user.getId());
            notification.setTitle(request.getTitle());
            notification.setContent(request.getContent());
            notification.setIsRead(0);
            notification.setType("ANNOUNCEMENT");
            notification.setStatus(1);
            notificationMapper.insert(notification);
        }

        operationLogService.createLog(
                admin.getUserId(),
                "CREATE",
                "ANNOUNCEMENT",
                0L,
                String.format("{\"title\":\"%s\",\"recipientCount\":%d}", request.getTitle(), users.size()),
                ""
        );

        return Result.success("公告发布成功，已发送给" + users.size() + "位用户", null);
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
