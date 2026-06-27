package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AiTestConnectionRequest {

    @NotBlank(message = "请输入 API Key")
    @Size(max = 500, message = "API Key 长度不能超过500个字符")
    private String apiKey;

    private String baseUrl;

    private String model;
}
