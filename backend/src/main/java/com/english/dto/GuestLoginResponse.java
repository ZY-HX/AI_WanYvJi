package com.english.dto;

import lombok.Data;

@Data
public class GuestLoginResponse {

    private String token;
    private Long userId;
    private String username;
    private String nickname;
    private String role;
    private Long expiresAt;
    private Integer validityDays;
    private Integer renewLimit;
    private Integer renewCountRemaining;
}
