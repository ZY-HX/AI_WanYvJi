package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class WordBankResponse {

    private Long id;
    private String name;
    private String description;
    private String category;
    private String language;
    private Integer wordCount;
    private Integer isPublic;
    private Long userId;
    private String creatorName;
    private Boolean collected;
    private Boolean editable;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
