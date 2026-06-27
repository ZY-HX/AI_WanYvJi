package com.english.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * AI文章日志实体类
 * 对应数据库ai_article_log表，记录AI生成的文章历史
 */
@Data
@TableName("ai_article_log")
public class AiArticleLog {

    /** 日志ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 使用的词库ID */
    private Long wordBankId;

    /** 文章主题 */
    private String theme;

    /** 文章难度等级 */
    private String difficulty;

    /** 文章长度 */
    private String length;

    /** 文章内容 */
    private String content;

    /** 高亮显示的单词（JSON格式） */
    private String highlightWords;

    /** 中文翻译内容 */
    private String translation;

    /** 生成耗时（毫秒） */
    private Integer duration;

    /** 生成状态：1-成功，0-失败 */
    private Integer status;

    /** 创建时间（自动填充） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
