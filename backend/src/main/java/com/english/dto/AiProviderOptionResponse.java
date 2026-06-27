package com.english.dto;

import lombok.Data;

@Data
public class AiProviderOptionResponse {

    private String providerCode;

    private String providerName;

    private String baseUrl;

    private String defaultModel;

    private String adapterType;

    private Boolean recommended;
}
