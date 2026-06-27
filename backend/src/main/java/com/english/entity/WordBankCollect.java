package com.english.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 词库收藏实体类
 * 对应数据库word_bank_collect表，记录用户收藏的词库
 */
@Data
@TableName("word_bank_collect")
public class WordBankCollect {

    /** 收藏记录ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 词库ID */
    private Long wordBankId;

    /** 收藏状态：1-已收藏，0-已取消 */
    private Integer status;

    /** 创建时间（自动填充） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 更新时间（自动填充） */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
