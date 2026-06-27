USE `english_learning_mate`;

ALTER TABLE `user_quota`
    ADD UNIQUE KEY `uk_user_quota_reset` (`user_id`, `quota_type`, `reset_time`);

ALTER TABLE `word`
    ADD UNIQUE KEY `uk_word_bank_english_status` (`word_bank_id`, `english`, `status`);

ALTER TABLE `user_study_record`
    ADD KEY `idx_usr_bank_status_review` (`user_id`, `word_bank_id`, `status`, `next_review_time`);

ALTER TABLE `notification`
    ADD KEY `idx_user_read_created` (`user_id`, `is_read`, `created_at`);

ALTER TABLE `ai_article_log`
    ADD KEY `idx_user_status_created` (`user_id`, `status`, `created_at`);

ANALYZE TABLE `user_quota`, `word`, `user_study_record`, `notification`, `ai_article_log`;
