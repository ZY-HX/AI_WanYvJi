USE `english_learning_mate`;

ALTER TABLE `word_bank`
    ADD COLUMN `language` varchar(16) NOT NULL DEFAULT 'EN' COMMENT '学习语种：EN/JA/KO' AFTER `category`,
    ADD KEY `idx_language` (`language`);
