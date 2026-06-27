package com.english.dto;

import lombok.Data;

@Data
public class TranslationSessionResponse {

    private Long id;

    private String sessionId;

    private String sourceLang;

    private String targetLang;

    private String status;

    private Integer duration;

    private String sourceLangName;

    private String targetLangName;

    private String createdAt;
}
