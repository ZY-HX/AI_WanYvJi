package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UserProfileResponse {

    private Long userId;
    private String username;
    private String nickname;
    private String email;
    private String phone;
    private String role;
    private String avatarUrl;
    private Integer studySessionSize;
    private Boolean allowSameDayReview;
    private LocalDateTime createdAt;
}
