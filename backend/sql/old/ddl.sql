SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS `english_learning_mate`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `english_learning_mate`;

DROP TABLE IF EXISTS `operation_log`;
DROP TABLE IF EXISTS `notification`;
DROP TABLE IF EXISTS `word_bank_collect`;
DROP TABLE IF EXISTS `sensitive_word`;
DROP TABLE IF EXISTS `user_study_plan`;
DROP TABLE IF EXISTS `user_quota`;
DROP TABLE IF EXISTS `ai_article_log`;
DROP TABLE IF EXISTS `error_book`;
DROP TABLE IF EXISTS `user_study_record`;
DROP TABLE IF EXISTS `word`;
DROP TABLE IF EXISTS `word_bank`;
DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username` varchar(50) NOT NULL COMMENT '用户名',
    `password` varchar(100) NOT NULL COMMENT '密码（BCrypt加密）',
    `email` varchar(100) NOT NULL COMMENT '邮箱',
    `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
    `avatar_url` varchar(255) DEFAULT NULL COMMENT '头像URL',
    `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
    `role` varchar(20) NOT NULL DEFAULT 'USER' COMMENT '角色：GUEST/USER/ADMIN',
    `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-禁用/删除',
    `login_fail_count` int NOT NULL DEFAULT 0 COMMENT '登录失败次数',
    `lock_time` datetime DEFAULT NULL COMMENT '账号锁定时间',
    `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_email` (`email`),
    KEY `idx_status` (`status`),
    KEY `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

CREATE TABLE `word_bank` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` bigint NOT NULL COMMENT '创建者ID（逻辑外键，关联user.id）',
    `name` varchar(100) NOT NULL COMMENT '词库名称',
    `description` varchar(500) DEFAULT NULL COMMENT '词库描述',
    `category` varchar(50) DEFAULT NULL COMMENT '词库分类：四级/六级/考研/自定义',
    `language` varchar(16) NOT NULL DEFAULT 'EN' COMMENT '学习语种：EN/JA/KO',
    `word_count` int NOT NULL DEFAULT 0 COMMENT '单词数量',
    `is_public` tinyint NOT NULL DEFAULT 0 COMMENT '是否公开：0-私有，1-待审核，2-已公开',
    `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-禁用/删除',
    `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_language` (`language`),
    KEY `idx_is_public` (`is_public`),
    KEY `idx_status` (`status`),
    KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词库表';

CREATE TABLE `word` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `word_bank_id` bigint NOT NULL COMMENT '词库ID（逻辑外键，关联word_bank.id）',
    `english` varchar(100) NOT NULL COMMENT '英文单词',
    `language` varchar(16) NOT NULL DEFAULT 'EN' COMMENT '单词语种：EN/JA/KO',
    `phonetic` varchar(100) DEFAULT NULL COMMENT '音标',
    `chinese` varchar(500) NOT NULL COMMENT '中文释义',
    `example` varchar(1000) DEFAULT NULL COMMENT '例句',
    `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-禁用/删除',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_word_bank_language_english_status` (`word_bank_id`, `language`, `english`, `status`),
    KEY `idx_word_bank_id` (`word_bank_id`),
    KEY `idx_language` (`language`),
    KEY `idx_english` (`english`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='单词表';

CREATE TABLE `user_study_record` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
    `word_bank_id` bigint NOT NULL COMMENT '词库ID（逻辑外键，关联word_bank.id）',
    `word_id` bigint NOT NULL COMMENT '单词ID（逻辑外键，关联word.id）',
    `study_mode` varchar(20) NOT NULL COMMENT '学习模式：EN_TO_CN/CN_TO_EN/LISTEN/SPELL',
    `correct_count` int NOT NULL DEFAULT 0 COMMENT '正确次数',
    `wrong_count` int NOT NULL DEFAULT 0 COMMENT '错误次数',
    `next_review_time` datetime DEFAULT NULL COMMENT '下次复习时间',
    `review_count` int NOT NULL DEFAULT 0 COMMENT '复习次数',
    `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-学习中，2-已掌握',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id_word_bank_id` (`user_id`, `word_bank_id`),
    KEY `idx_next_review_time` (`next_review_time`),
    KEY `idx_status` (`status`),
    KEY `idx_usr_bank_status_review` (`user_id`, `word_bank_id`, `status`, `next_review_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习记录表';

CREATE TABLE `user_study_plan` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` bigint NOT NULL COMMENT '用户ID',
    `study_session_size` int NOT NULL DEFAULT 20 COMMENT '单次学习题量',
    `allow_same_day_review` tinyint NOT NULL DEFAULT 1 COMMENT '是否允许当天继续复习',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习计划表';

CREATE TABLE `error_book` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
    `word_id` bigint NOT NULL COMMENT '单词ID（逻辑外键，关联word.id）',
    `error_type` varchar(20) NOT NULL COMMENT '错误类型：EN_TO_CN/CN_TO_EN/LISTEN/SPELL',
    `error_times` int NOT NULL DEFAULT 1 COMMENT '错误次数',
    `is_mastered` tinyint NOT NULL DEFAULT 0 COMMENT '是否已掌握：0-未掌握，1-已掌握',
    `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-删除',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_word_id` (`word_id`),
    KEY `idx_is_mastered` (`is_mastered`),
    KEY `idx_error_type` (`error_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='错题本表';

CREATE TABLE `ai_article_log` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
    `word_bank_id` bigint NOT NULL COMMENT '词库ID（逻辑外键，关联word_bank.id）',
    `theme` varchar(50) NOT NULL COMMENT '文章主题',
    `difficulty` varchar(20) NOT NULL COMMENT '难度：EASY/MEDIUM/HARD/PROFESSIONAL',
    `length` varchar(20) NOT NULL COMMENT '长度：SHORT/MEDIUM/LONG',
    `content` text NOT NULL COMMENT '文章内容',
    `highlight_words` text DEFAULT NULL COMMENT '高亮单词（JSON格式）',
    `translation` text DEFAULT NULL COMMENT '中文翻译内容',
    `duration` int NOT NULL COMMENT '生成耗时（毫秒）',
    `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-成功，0-失败',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_word_bank_id` (`word_bank_id`),
    KEY `idx_created_at` (`created_at`),
    KEY `idx_status` (`status`),
    KEY `idx_user_status_created` (`user_id`, `status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI文章生成日志表';

CREATE TABLE `user_quota` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
    `quota_type` varchar(20) NOT NULL COMMENT '配额类型：AI_ARTICLE/EXPORT',
    `total_quota` int NOT NULL DEFAULT 5 COMMENT '总配额',
    `used_count` int NOT NULL DEFAULT 0 COMMENT '已使用次数',
    `reset_time` datetime NOT NULL COMMENT '重置时间（每日0点）',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_quota_reset` (`user_id`, `quota_type`, `reset_time`),
    KEY `idx_user_id_quota_type` (`user_id`, `quota_type`),
    KEY `idx_reset_time` (`reset_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户每日配额表';

CREATE TABLE `sensitive_word` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `word` varchar(100) NOT NULL COMMENT '敏感词',
    `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_word` (`word`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='敏感词库表';

CREATE TABLE `word_bank_collect` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
    `word_bank_id` bigint NOT NULL COMMENT '词库ID（逻辑外键，关联word_bank.id）',
    `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-已收藏，0-已取消',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_user_id_word_bank_id` (`user_id`, `word_bank_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词库收藏表';

CREATE TABLE `notification` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` bigint NOT NULL COMMENT '用户ID（0表示所有用户）',
    `title` varchar(100) NOT NULL COMMENT '消息标题',
    `content` varchar(1000) NOT NULL COMMENT '消息内容',
    `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读：0-未读，1-已读',
    `type` varchar(20) NOT NULL COMMENT '消息类型：SYSTEM/ANNOUNCEMENT/AUDIT',
    `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-删除',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_is_read` (`is_read`),
    KEY `idx_type` (`type`),
    KEY `idx_created_at` (`created_at`),
    KEY `idx_user_read_created` (`user_id`, `is_read`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='站内消息表';

CREATE TABLE `operation_log` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `admin_id` bigint NOT NULL COMMENT '管理员ID（逻辑外键，关联user.id）',
    `operation_type` varchar(50) NOT NULL COMMENT '操作类型：USER_DISABLE/USER_ENABLE/WORDBANK_APPROVE等',
    `target_type` varchar(50) NOT NULL COMMENT '目标类型：USER/WORDBANK/SENSITIVE_WORD等',
    `target_id` bigint NOT NULL COMMENT '目标ID',
    `details` varchar(1000) DEFAULT NULL COMMENT '操作详情',
    `ip_address` varchar(50) NOT NULL COMMENT '操作IP地址',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_admin_id` (`admin_id`),
    KEY `idx_operation_type` (`operation_type`),
    KEY `idx_target_type_target_id` (`target_type`, `target_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';
