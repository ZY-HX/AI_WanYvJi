package com.english.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 错题本实体类
 * 对应数据库error_book表，记录用户的错题信息
 */
@Data
@TableName("error_book")
public class ErrorBook {

    /** 错题记录ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 单词ID */
    private Long wordId;

    /** 错误类型 */
    private String errorType;

    /** 错误次数 */
    private Integer errorTimes;

    /** 是否已掌握：1-已掌握，0-未掌握 */
    private Integer isMastered;

    /** 状态：1-正常，0-已删除（逻辑删除） */
    @TableLogic
    private Integer status;

    /** 创建时间（自动填充） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 更新时间（自动填充） */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
