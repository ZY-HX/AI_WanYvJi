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
 * 通知实体类
 * 对应数据库notification表，存储系统通知消息
 */
@Data
@TableName("notification")
public class Notification {

    /** 通知ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 目标用户ID */
    private Long userId;

    /** 通知标题 */
    private String title;

    /** 通知内容 */
    private String content;

    /** 是否已读：1-已读，0-未读 */
    private Integer isRead;

    /** 通知类型 */
    private String type;

    /** 状态：1-正常，0-已删除（逻辑删除） */
    @TableLogic
    private Integer status;

    /** 创建时间（自动填充） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}

