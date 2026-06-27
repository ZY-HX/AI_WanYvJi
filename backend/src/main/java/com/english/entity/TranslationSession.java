package com.english.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("translation_session")
public class TranslationSession {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String sessionId;

    private String sourceLang;

    private String targetLang;

    private String status;

    private Integer duration;

    private String transcript;

    private String translation;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
