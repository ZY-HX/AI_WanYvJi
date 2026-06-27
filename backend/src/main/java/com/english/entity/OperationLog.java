package com.english.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 操作日志实体类
 * 对应数据库operation_log表，记录管理员的操作日志
 */
@Data
@TableName("operation_log")
public class OperationLog {

    /** 日志ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 管理员用户ID */
    private Long adminId;

    /** 操作类型：如CREATE、UPDATE、DELETE等 */
    private String operationType;

    /** 目标对象类型：如USER、WORD_BANK等 */
    private String targetType;

    /** 目标对象ID */
    private Long targetId;

    /** 操作详情（JSON格式） */
    private String details;

    /** 操作者IP地址 */
    private String ipAddress;

    /** 创建时间（自动填充） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
