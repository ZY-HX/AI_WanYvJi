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
 * 单词实体类
 * 对应数据库word表，存储单词详细信息
 */
@Data
@TableName("word")
public class Word {

    /** 单词ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 所属词库ID */
    private Long wordBankId;

    /** 英文单词 */
    private String english;

    /** 单词语种：EN/JA/KO */
    private String language;

    /** 音标 */
    private String phonetic;

    /** 中文释义 */
    private String chinese;

    /** 例句 */
    private String example;

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
