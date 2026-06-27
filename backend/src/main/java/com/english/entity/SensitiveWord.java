package com.english.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 敏感词实体类
 * 对应数据库sensitive_word表，存储敏感词信息
 */
@Data
@TableName("sensitive_word")
public class SensitiveWord {

    /** 敏感词ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 敏感词内容 */
    private String word;

    /** 状态：1-启用，0-禁用 */
    private Integer status;

    /** 创建时间（自动填充） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 更新时间（自动填充） */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
