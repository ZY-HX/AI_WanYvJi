package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AudioTranslateRequest {

    @NotBlank(message = "音频数据不能为空")
    @Size(max = 10485760, message = "音频数据不能超过10MB")
    private String audioData;

    private String format;

    private String sessionId;
}
