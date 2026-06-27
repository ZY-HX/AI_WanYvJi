package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class LoginLockStatusResponse {

    private boolean locked;
    private long remainingLockSeconds;
    private String remainingLockTimeText;
    private LocalDateTime lockUntil;
}
