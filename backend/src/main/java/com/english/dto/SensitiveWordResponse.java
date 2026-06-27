package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class SensitiveWordResponse {

    private Long id;

    private String word;

    private Integer status;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
