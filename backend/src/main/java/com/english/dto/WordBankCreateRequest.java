package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class WordBankCreateRequest {

    @NotBlank(message = "词库名称不能为空")
    @Size(max = 100, message = "词库名称长度不能超过100个字符")
    private String name;

    @Size(max = 500, message = "词库描述长度不能超过500个字符")
    private String description;

    @Pattern(regexp = "EN|JA|KO|DE|FR|ES", message = "语种仅支持 EN、JA、KO、DE、FR、ES")
    private String language;
}
