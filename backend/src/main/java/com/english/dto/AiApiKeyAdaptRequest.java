package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AiApiKeyAdaptRequest {

    @NotBlank(message = "请选择 API Key 来源")
    private String apiKeySource;

    @Size(max = 500, message = "自定义 API Key 长度不能超过500个字符")
    private String customApiKey;
}
