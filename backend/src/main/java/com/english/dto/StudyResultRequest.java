package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class StudyResultRequest {

    @NotNull(message = "学习记录ID不能为空")
    private Long recordId;

    @NotNull(message = "单词ID不能为空")
    private Long wordId;

    @NotNull(message = "答题结果不能为空")
    private Boolean correct;

    @NotBlank(message = "学习模式不能为空")
    private String mode;
}
