package com.english.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AiArticleTranslateRequest {

    @Size(max = 500, message = "自定义 API Key 长度不能超过500字符")
    private String customApiKey;

    @Size(max = 255, message = "服务地址长度不能超过255字符")
    private String apiBaseUrl;

    @Size(max = 100, message = "模型名称长度不能超过100字符")
    private String model;
}
