package com.english.dto;

import lombok.Data;

@Data
public class AiTestConnectionResponse {

    private boolean success;

    private String providerCode;

    private String providerName;

    private String detectedBaseUrl;

    private String detectedModel;

    private String message;

    private Long responseTimeMs;
}
