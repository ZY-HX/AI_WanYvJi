USE `english_learning_mate`;

-- 说明：
-- 1. 先执行 ddl.sql，再执行本脚本。
-- 2. 由于仓库内未提供完整四级/六级/考研词表文件，本脚本先插入词库元数据与示例单词，
--    后续可通过批量导入继续补齐完整词库内容。
-- 3. 初始账号：
--    admin / admin123
--    user1 / 123456
--    user2 / 123456

INSERT INTO `user`
(`id`, `username`, `password`, `email`, `phone`, `avatar_url`, `nickname`, `role`, `status`, `login_fail_count`, `lock_time`, `version`)
VALUES
(1, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'admin@example.com', NULL, NULL, '系统管理员', 'ADMIN', 1, 0, NULL, 0),
(2, 'user1', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'user1@example.com', NULL, NULL, '测试用户1', 'USER', 1, 0, NULL, 0),
(3, 'user2', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'user2@example.com', NULL, NULL, '测试用户2', 'USER', 1, 0, NULL, 0);

INSERT INTO `word_bank`
(`id`, `user_id`, `name`, `description`, `category`, `language`, `word_count`, `is_public`, `status`, `version`)
VALUES
(1, 1, '四级核心词汇', '大学英语四级核心词汇（示例数据，可继续批量导入）', '四级', 'EN', 3, 2, 1, 0),
(2, 1, '六级核心词汇', '大学英语六级核心词汇（示例数据，可继续批量导入）', '六级', 'EN', 3, 2, 1, 0),
(3, 1, '考研核心词汇', '考研英语核心词汇（示例数据，可继续批量导入）', '考研', 'EN', 3, 2, 1, 0),
(4, 2, '计算机专业词汇', '计算机相关专业英语词汇', '自定义', 'EN', 2, 0, 1, 0),
(5, 2, '日常英语词汇', '日常英语常用词汇', '自定义', 'EN', 2, 0, 1, 0),
(6, 3, '商务英语词汇', '商务场景英语词汇', '自定义', 'EN', 2, 0, 1, 0),
(7, 1, '日语入门词库', '日语基础高频词（示例数据）', '日语', 'JA', 2, 2, 1, 0),
(8, 1, '韩语入门词库', '韩语基础高频词（示例数据）', '韩语', 'KO', 2, 2, 1, 0);

INSERT INTO `word`
(`id`, `word_bank_id`, `english`, `language`, `phonetic`, `chinese`, `example`, `status`)
VALUES
(1, 1, 'ability', 'EN', '/əˈbɪləti/', '能力；才能', 'She has the ability to solve difficult problems.', 1),
(2, 1, 'achieve', 'EN', '/əˈtʃiːv/', '实现；达到', 'You can achieve your goal through practice.', 1),
(3, 1, 'approach', 'EN', '/əˈprəʊtʃ/', '方法；接近', 'We need a better approach to learning new words.', 1),
(4, 2, 'accelerate', 'EN', '/əkˈseləreɪt/', '加速；促进', 'The new policy will accelerate economic growth.', 1),
(5, 2, 'conservative', 'EN', '/kənˈsɜːvətɪv/', '保守的；守旧的', 'He holds a conservative view on education.', 1),
(6, 2, 'derive', 'EN', '/dɪˈraɪv/', '获得；起源于', 'Many English words derive from Latin.', 1),
(7, 3, 'abolish', 'EN', '/əˈbɒlɪʃ/', '废除；取消', 'The law was abolished many years ago.', 1),
(8, 3, 'compile', 'EN', '/kəmˈpaɪl/', '编写；汇编', 'She compiled a list of important expressions.', 1),
(9, 3, 'retain', 'EN', '/rɪˈteɪn/', '保持；保留', 'Regular review helps retain vocabulary.', 1),
(10, 4, 'algorithm', 'EN', '/ˈælɡərɪðəm/', '算法', 'This algorithm sorts the data efficiently.', 1),
(11, 4, 'database', 'EN', '/ˈdeɪtəbeɪs/', '数据库', 'The system stores records in a database.', 1),
(12, 5, 'grocery', 'EN', '/ˈɡrəʊsəri/', '食品杂货店', 'I bought fruit from the grocery store.', 1),
(13, 5, 'schedule', 'EN', '/ˈʃedjuːl/', '日程；安排', 'My study schedule starts at seven every evening.', 1),
(14, 6, 'contract', 'EN', '/ˈkɒntrækt/', '合同', 'The company signed a new contract yesterday.', 1),
(15, 6, 'negotiate', 'EN', '/nɪˈɡəʊʃieɪt/', '谈判；协商', 'They negotiated the price for two hours.', 1),
(16, 7, 'こんにちは', 'JA', NULL, '你好', 'こんにちは、はじめまして。', 1),
(17, 7, 'ありがとう', 'JA', NULL, '谢谢', '手伝ってくれて、ありがとう。', 1),
(18, 8, '사랑', 'KO', NULL, '爱', '가족에 대한 사랑이 깊다.', 1),
(19, 8, '학교', 'KO', NULL, '学校', '나는 학교에 갑니다.', 1);

INSERT INTO `user_study_record`
(`id`, `user_id`, `word_bank_id`, `word_id`, `study_mode`, `correct_count`, `wrong_count`, `next_review_time`, `review_count`, `status`)
VALUES
(1, 2, 1, 1, 'EN_TO_CN', 2, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), 3, 1),
(2, 2, 4, 10, 'SPELL', 1, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), 3, 1),
(3, 3, 6, 14, 'CN_TO_EN', 3, 0, DATE_ADD(NOW(), INTERVAL 4 DAY), 3, 2);

INSERT INTO `error_book`
(`id`, `user_id`, `word_id`, `error_type`, `error_times`, `is_mastered`, `status`)
VALUES
(1, 2, 1, 'LISTEN', 2, 0, 1),
(2, 2, 10, 'SPELL', 3, 0, 1),
(3, 3, 14, 'CN_TO_EN', 1, 1, 1);

INSERT INTO `ai_article_log`
(`id`, `user_id`, `word_bank_id`, `theme`, `difficulty`, `length`, `content`, `highlight_words`, `duration`, `status`)
VALUES
(1, 2, 4, '科技', 'MEDIUM', 'SHORT', 'Algorithms and databases are basic concepts in computer science.', '["algorithm","database"]', 1320, 1),
(2, 3, 6, '职场', 'PROFESSIONAL', 'MEDIUM', 'Negotiating a contract requires patience, clear goals and business awareness.', '["contract","negotiate"]', 1680, 1);

INSERT INTO `user_quota`
(`id`, `user_id`, `quota_type`, `total_quota`, `used_count`, `reset_time`)
VALUES
(1, 2, 'AI_ARTICLE', 5, 1, DATE_FORMAT(NOW(), '%Y-%m-%d 00:00:00')),
(2, 2, 'EXPORT', 3, 0, DATE_FORMAT(NOW(), '%Y-%m-%d 00:00:00')),
(3, 3, 'AI_ARTICLE', 5, 1, DATE_FORMAT(NOW(), '%Y-%m-%d 00:00:00')),
(4, 3, 'EXPORT', 3, 0, DATE_FORMAT(NOW(), '%Y-%m-%d 00:00:00'));

INSERT INTO `sensitive_word`
(`id`, `word`, `status`)
VALUES
(1, '暴力', 1),
(2, '色情', 1),
(3, '赌博', 1),
(4, '毒品', 1),
(5, '诈骗', 1),
(6, '辱骂', 1),
(7, '枪支', 1),
(8, '违法', 1),
(9, '恐怖主义', 1),
(10, '仇恨言论', 1);

INSERT INTO `word_bank_collect`
(`id`, `user_id`, `word_bank_id`, `status`)
VALUES
(1, 2, 3, 1),
(2, 3, 1, 1);

INSERT INTO `notification`
(`id`, `user_id`, `title`, `content`, `is_read`, `type`, `status`)
VALUES
(1, 0, '系统公告', '欢迎使用 EnglishLearningMate，登录后可永久保存学习数据。', 0, 'ANNOUNCEMENT', 1),
(2, 2, '审核通知', '你的共享词库已进入审核队列，请耐心等待。', 0, 'AUDIT', 1),
(3, 3, '学习提醒', '今天还有待复习单词，记得按时完成学习计划。', 0, 'SYSTEM', 1);

INSERT INTO `operation_log`
(`id`, `admin_id`, `operation_type`, `target_type`, `target_id`, `details`, `ip_address`)
VALUES
(1, 1, 'WORDBANK_APPROVE', 'WORDBANK', 1, '初始化公开内置四级词库', '127.0.0.1'),
(2, 1, 'WORDBANK_APPROVE', 'WORDBANK', 2, '初始化公开内置六级词库', '127.0.0.1'),
(3, 1, 'WORDBANK_APPROVE', 'WORDBANK', 3, '初始化公开内置考研词库', '127.0.0.1');

INSERT INTO `system_config`
(`config_key`, `config_value`, `description`)
VALUES
('ai_article_daily_quota', '5', '用户每日 AI 阅读生成配额'),
('export_daily_quota', '3', '用户每日学习记录导出配额');
