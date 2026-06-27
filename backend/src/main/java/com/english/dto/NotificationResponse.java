package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class NotificationResponse {

    private Long id;

    private String title;

    private String content;

    private Integer isRead;

    private String type;

    private LocalDateTime createdAt;
}

