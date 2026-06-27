package com.english.dto;

import lombok.Data;

@Data
public class AudioTranslateResponse {

    private String text;

    private String translation;

    private String confidence;

    private Long timestamp;

    private Boolean isFinal;
}
