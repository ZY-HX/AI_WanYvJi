package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class WordCreateRequest {

    @NotBlank(message = "英文单词不能为空")
    @Size(max = 100, message = "英文单词不能超过100个字符")
    private String english;

    @Size(max = 100, message = "音标不能超过100个字符")
    private String phonetic;

    @NotBlank(message = "中文释义不能为空")
    @Size(max = 500, message = "中文释义不能超过500个字符")
    private String chinese;

    @Size(max = 1000, message = "例句不能超过1000个字符")
    private String example;
}
