package com.english.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AdminAiConfigUpdateRequest {

    @Size(max = 500, message = "AI服务地址长度不能超过500个字符")
    private String baseUrl;

    @Size(max = 100, message = "模型名称长度不能超过100个字符")
    private String model;

    private String apiKey;
}
