package com.english.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.Version;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 词库实体类
 * 对应数据库word_bank表，存储词库信息
 */
@Data
@TableName("word_bank")
public class WordBank {

    /** 词库ID（主键，自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 创建者用户ID */
    private Long userId;

    /** 词库名称 */
    private String name;

    /** 词库描述 */
    private String description;

    /** 词库分类 */
    private String category;

    /** 学习语种：EN/JA/KO */
    private String language;

    /** 单词数量 */
    private Integer wordCount;

    /** 是否公开：1-公开，0-私有 */
    private Integer isPublic;

    /** 状态：0-已删除（逻辑删除），非0-正常 */
    @TableLogic(delval = "0")
    private Integer status;

    /** 乐观锁版本号 */
    @Version
    private Integer version;

    /** 创建时间（自动填充） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 更新时间（自动填充） */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
