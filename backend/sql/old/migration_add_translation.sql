-- AI阅读文章翻译功能迁移脚本
-- 为 ai_article_log 表添加 translation 字段

ALTER TABLE `ai_article_log`
ADD COLUMN `translation` text DEFAULT NULL COMMENT '中文翻译内容' AFTER `highlight_words`;
