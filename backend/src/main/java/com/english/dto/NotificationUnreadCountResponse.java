package com.english.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class NotificationUnreadCountResponse {

    private long unreadCount;
}

