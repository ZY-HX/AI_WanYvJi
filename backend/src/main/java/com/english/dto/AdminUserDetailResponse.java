package com.english.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 管理端-用户详细信息响应
 * 包含用户基本信息、学习计划配置、学习统计数据
 */
@Data
public class AdminUserDetailResponse {

    /** 用户ID */
    private Long userId;

    /** 用户名 */
    private String username;

    /** 昵称 */
    private String nickname;

    /** 邮箱 */
    private String email;

    /** 手机号 */
    private String phone;

    /** 头像URL */
    private String avatarUrl;

    /** 角色 */
    private String role;

    /** 账户状态 1-正常 0-禁用 */
    private Integer status;

    /** 注册时间 */
    private LocalDateTime createdAt;

    /** 最后更新时间 */
    private LocalDateTime updatedAt;

    /** 最后登录时间 */
    private LocalDateTime lastLoginAt;

    /** 登录失败次数 */
    private Integer loginFailCount;

    // ===== 学习配置 =====

    /** 单次学习题量 */
    private Integer studySessionSize;

    /** 是否允许当天继续复习 */
    private Boolean allowSameDayReview;

    // ===== 学习统计 =====

    /** 学习总次数（完成的学习会话数） */
    private Long totalStudySessions;

    /** 学习总单词数（去重后的不同单词数） */
    private Long totalWordsLearned;

    /** 总正确次数 */
    private Long totalCorrectCount;

    /** 总错误次数 */
    private Long totalWrongCount;

    /** 正确率（百分比，保留1位小数） */
    private Double accuracyRate;

    /** 待复习单词数 */
    private Long pendingReviewCount;

    /** 已掌握单词数（连续正确3次以上） */
    private Long masteredWordCount;
}
