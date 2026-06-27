-- 同声翻译功能数据库表
-- 创建时间: 2026-04-27

CREATE TABLE IF NOT EXISTS `translation_session` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `session_id` VARCHAR(32) NOT NULL COMMENT '会话唯一标识',
    `source_lang` VARCHAR(10) NOT NULL COMMENT '源语言代码',
    `target_lang` VARCHAR(10) NOT NULL COMMENT '目标语言代码',
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE/ENDED',
    `duration` INT NOT NULL DEFAULT 0 COMMENT '持续时长（秒）',
    `transcript` TEXT COMMENT '识别文本记录',
    `translation` TEXT COMMENT '翻译文本记录',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_session_id` (`session_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='同声翻译会话表';
