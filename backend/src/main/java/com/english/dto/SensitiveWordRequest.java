package com.english.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class SensitiveWordRequest {

    @Size(max = 100, message = "敏感词长度不能超过100个字符")
    private String word;

    private Integer status;
}
