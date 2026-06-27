package com.english.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户配额实体类
 * 对应数据库user_quota表，记录用户的各种使用配额
 */
@Data
@TableName("user_quota")
public class UserQuota {

    /** 配额记录ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 配额类型：如AI文章生成次数、导出次数等 */
    private String quotaType;

    /** 总配额数 */
    private Integer totalQuota;

    /** 已使用数量 */
    private Integer usedCount;

    /** 重置时间 */
    private LocalDateTime resetTime;

    /** 创建时间（自动填充） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 更新时间（自动填充） */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
