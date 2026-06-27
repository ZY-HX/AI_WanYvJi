package com.english.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户实体类
 * 对应数据库user表，存储系统用户的基本信息
 * 支持普通用户（USER）和管理员（ADMIN）两种角色
 * 包含账户安全相关字段：登录失败次数、锁定时间、乐观锁版本号等
 */
@Data
@TableName("user")
public class User {

    /** 用户ID（主键，数据库自增） */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户名（登录账号，唯一） */
    private String username;

    /** 密码（使用BCrypt算法加密存储） */
    private String password;

    /** 邮箱地址（用于找回密码和通知，唯一） */
    private String email;

    /** 手机号码（可选，用于短信通知） */
    private String phone;

    /** 头像URL地址（用户上传或系统默认头像） */
    private String avatarUrl;

    /** 用户昵称（显示名称，可修改） */
    private String nickname;

    /**
     * 用户角色
     * USER - 普通用户：可进行学习、收藏等操作
     * ADMIN - 管理员：拥有后台管理权限
     */
    private String role;

    /**
     * 账户状态
     * 1 - 正常：可正常登录和使用
     * 2 - 禁用：被管理员禁用，无法登录
     * 0 - 已删除：逻辑删除状态
     */
    private Integer status;

    /**
     * 登录失败连续次数
     * 用于账户安全保护，连续失败达到阈值后自动锁定账户
     * 成功登录后重置为0
     */
    private Integer loginFailCount;

    /**
     * 账户锁定时间
     * 当登录失败次数超过限制时，记录锁定开始时间
     * 超过锁定时长后自动解锁
     */
    private LocalDateTime lockTime;

    /**
     * 乐观锁版本号
     * 用于处理并发更新冲突，每次更新时版本号自动+1
     * 配合MyBatis-Plus的OptimisticLockerInnerInterceptor使用
     */
    @Version
    private Integer version;

    /** 创建时间（插入时自动填充当前时间） */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 更新时间（插入和更新时自动填充当前时间） */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
