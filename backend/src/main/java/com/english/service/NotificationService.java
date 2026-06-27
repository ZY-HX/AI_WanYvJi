package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.dto.NotificationResponse;
import com.english.dto.NotificationUnreadCountResponse;
import com.english.dto.PageResponse;
import com.english.entity.Notification;
import com.english.mapper.NotificationMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private static final int ACTIVE_STATUS = 1;
    private static final int UNREAD = 0;
    private static final int READ = 1;

    private final NotificationMapper notificationMapper;

    public PageResponse<NotificationResponse> getNotifications(Long userId, Integer isRead, long current, long size) {
        validateIsRead(isRead);

        Page<Notification> page = new Page<>(Math.max(current, 1L), Math.max(size, 1L));
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId)
                .eq(Notification::getStatus, ACTIVE_STATUS)
                .eq(isRead != null, Notification::getIsRead, isRead)
                .orderByDesc(Notification::getCreatedAt)
                .orderByDesc(Notification::getId);

        Page<Notification> result = notificationMapper.selectPage(page, wrapper);
        PageResponse<NotificationResponse> response = new PageResponse<>();
        response.setCurrent(result.getCurrent());
        response.setSize(result.getSize());
        response.setTotal(result.getTotal());
        response.setRecords(result.getRecords().stream().map(this::toResponse).toList());
        return response;
    }

    public NotificationUnreadCountResponse getUnreadCount(Long userId) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId)
                .eq(Notification::getStatus, ACTIVE_STATUS)
                .eq(Notification::getIsRead, UNREAD);
        return new NotificationUnreadCountResponse(notificationMapper.selectCount(wrapper));
    }

    @Transactional(rollbackFor = Exception.class)
    public void markRead(Long userId, Long id) {
        Notification notification = getOwnedNotification(userId, id);
        if (READ == (notification.getIsRead() == null ? UNREAD : notification.getIsRead())) {
            return;
        }

        notification.setIsRead(READ);
        notificationMapper.updateById(notification);
    }

    @Transactional(rollbackFor = Exception.class)
    public int markAllRead(Long userId) {
        return notificationMapper.markAllReadByUserId(userId);
    }

    @Transactional(rollbackFor = Exception.class)
    public void createNotification(Long userId, String title, String content, String type) {
        if (userId == null) {
            throw new BusinessException(400, "通知接收用户不能为空");
        }

        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setTitle(title);
        notification.setContent(content);
        notification.setIsRead(UNREAD);
        notification.setType(type);
        notification.setStatus(ACTIVE_STATUS);
        notificationMapper.insert(notification);
    }

    private Notification getOwnedNotification(Long userId, Long id) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getId, id)
                .eq(Notification::getUserId, userId)
                .eq(Notification::getStatus, ACTIVE_STATUS);
        Notification notification = notificationMapper.selectOne(wrapper);
        if (notification == null) {
            throw new BusinessException(404, "消息不存在");
        }
        return notification;
    }

    private void validateIsRead(Integer isRead) {
        List<Integer> allowedValues = List.of(UNREAD, READ);
        if (isRead != null && !allowedValues.contains(isRead)) {
            throw new BusinessException(400, "已读状态参数不合法");
        }
    }

    private NotificationResponse toResponse(Notification notification) {
        NotificationResponse response = new NotificationResponse();
        response.setId(notification.getId());
        response.setTitle(notification.getTitle());
        response.setContent(notification.getContent());
        response.setIsRead(notification.getIsRead());
        response.setType(notification.getType());
        response.setCreatedAt(notification.getCreatedAt());
        return response;
    }
}
