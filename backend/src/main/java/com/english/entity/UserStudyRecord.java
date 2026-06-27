package com.english.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户学习记录实体类
 * 对应数据库user_study_record表，记录用户的学习进度和成绩
 */
@Data
@TableName("user_study_record")
public class UserStudyRecord {

    /** 学习记录ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 词库ID */
    private Long wordBankId;

    /** 单词ID */
    private Long wordId;

    /** 学习模式 */
    private String studyMode;

    /** 正确次数 */
    private Integer correctCount;

    /** 错误次数 */
    private Integer wrongCount;

    /** 下次复习时间 */
    private LocalDateTime nextReviewTime;

    /** 复习次数 */
    private Integer reviewCount;

    /** 记录状态 */
    private Integer status;

    /** 创建时间（自动填充） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 更新时间（自动填充） */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
