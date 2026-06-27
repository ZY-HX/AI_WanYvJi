package com.english.dto;

import lombok.Data;

@Data
public class LoginResponse {

    private String token;
    private Long userId;
    private String username;
    private String nickname;
    private String email;
    private String role;
    private String avatarUrl;
}
