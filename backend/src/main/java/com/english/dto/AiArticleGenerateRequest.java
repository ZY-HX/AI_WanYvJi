package com.english.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AiArticleGenerateRequest {

    @NotNull(message = "请选择词库")
    private Long wordBankId;

    @Size(max = 50, message = "主题长度不能超过50个字符")
    private String theme;

    @NotBlank(message = "请选择难度")
    private String difficulty;

    @NotBlank(message = "请选择长度")
    private String length;

    @NotBlank(message = "请选择 API Key 来源")
    private String apiKeySource;

    @Size(max = 500, message = "自定义 API Key 长度不能超过500个字符")
    private String customApiKey;

    @NotBlank(message = "请选择配置方式")
    private String configMode;

    @Size(max = 50, message = "服务商标识长度不能超过50个字符")
    private String providerCode;

    @Size(max = 255, message = "服务地址长度不能超过255个字符")
    private String apiBaseUrl;

    @Size(max = 100, message = "模型名称长度不能超过100个字符")
    private String model;
}
