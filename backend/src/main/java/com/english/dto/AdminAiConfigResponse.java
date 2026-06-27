package com.english.dto;

import lombok.Data;

@Data
public class AdminAiConfigResponse {

    private String baseUrl;

    private String model;

    private String apiKeyMasked;

    private boolean apiKeyConfigured;
}
