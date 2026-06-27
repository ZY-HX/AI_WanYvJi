package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class TranslationSessionCreateRequest {

    @NotBlank(message = "源语言不能为空")
    @Pattern(regexp = "^[A-Z]{2,3}$", message = "源语言格式不正确")
    private String sourceLang;

    @NotBlank(message = "目标语言不能为空")
    @Pattern(regexp = "^[A-Z]{2,3}$", message = "目标语言格式不正确")
    private String targetLang;
}
