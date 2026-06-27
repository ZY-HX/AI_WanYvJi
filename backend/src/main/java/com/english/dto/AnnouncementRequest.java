package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AnnouncementRequest {

    @NotBlank(message = "公告标题不能为空")
    @Size(max = 100, message = "标题长度不能超过100个字符")
    private String title;

    @NotBlank(message = "公告内容不能为空")
    @Size(max = 1000, message = "内容长度不能超过1000个字符")
    private String content;
}
