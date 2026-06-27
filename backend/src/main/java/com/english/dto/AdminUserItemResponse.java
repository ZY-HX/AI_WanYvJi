package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AdminUserItemResponse {

    private Long id;

    private String username;

    private String nickname;

    private String email;

    private String phone;

    private String avatarUrl;

    private String role;

    private Integer status;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
