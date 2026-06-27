package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class WordLookupRequest {

    @NotBlank(message = "请输入要查询的单词")
    @Size(max = 100, message = "单词长度不能超过100个字符")
    private String word;

    @Size(max = 16, message = "语种长度不能超过16个字符")
    private String language;

    private String customApiKey;

    private String apiBaseUrl;

    private String model;
}
