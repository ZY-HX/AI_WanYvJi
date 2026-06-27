USE `english_learning_mate`;

SET @add_language_col_sql = (
    SELECT IF(
            EXISTS (
                SELECT 1
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'word'
                  AND COLUMN_NAME = 'language'
            ),
            'SELECT 1',
            'ALTER TABLE `word` ADD COLUMN `language` varchar(16) NOT NULL DEFAULT ''EN'' COMMENT ''单词语种：EN/JA/KO'' AFTER `english`'
    )
);
PREPARE stmt FROM @add_language_col_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE `word` w
INNER JOIN `word_bank` wb ON wb.id = w.word_bank_id
SET w.`language` = IFNULL(wb.`language`, 'EN');

SET @drop_old_uk_sql = (
    SELECT IF(
            EXISTS (
                SELECT 1
                FROM information_schema.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'word'
                  AND INDEX_NAME = 'uk_word_bank_english_status'
            ),
            'ALTER TABLE `word` DROP KEY `uk_word_bank_english_status`',
            'SELECT 1'
    )
);
PREPARE stmt FROM @drop_old_uk_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_new_uk_sql = (
    SELECT IF(
            EXISTS (
                SELECT 1
                FROM information_schema.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'word'
                  AND INDEX_NAME = 'uk_word_bank_language_english_status'
            ),
            'SELECT 1',
            'ALTER TABLE `word` ADD UNIQUE KEY `uk_word_bank_language_english_status` (`word_bank_id`, `language`, `english`, `status`)'
    )
);
PREPARE stmt FROM @add_new_uk_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_idx_lang_sql = (
    SELECT IF(
            EXISTS (
                SELECT 1
                FROM information_schema.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'word'
                  AND INDEX_NAME = 'idx_language'
            ),
            'SELECT 1',
            'ALTER TABLE `word` ADD KEY `idx_language` (`language`)'
    )
);
PREPARE stmt FROM @add_idx_lang_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 初始化多语种公共词库（如已存在同名词库则跳过）
INSERT INTO `word_bank` (`user_id`, `name`, `description`, `category`, `language`, `word_count`, `is_public`, `status`, `version`)
SELECT 1, '日语入门词库', '日语基础高频词（示例数据）', '日语', 'JA', 0, 2, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM `word_bank` WHERE `name` = '日语入门词库' AND `status` = 1);

INSERT INTO `word_bank` (`user_id`, `name`, `description`, `category`, `language`, `word_count`, `is_public`, `status`, `version`)
SELECT 1, '韩语入门词库', '韩语基础高频词（示例数据）', '韩语', 'KO', 0, 2, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM `word_bank` WHERE `name` = '韩语入门词库' AND `status` = 1);

-- 为新增词库写入示例单词
INSERT INTO `word` (`word_bank_id`, `english`, `language`, `phonetic`, `chinese`, `example`, `status`)
SELECT wb.id, 'こんにちは', 'JA', NULL, '你好', 'こんにちは、はじめまして。', 1
FROM `word_bank` wb
WHERE wb.name = '日语入门词库' AND wb.language = 'JA' AND wb.status = 1
  AND NOT EXISTS (SELECT 1 FROM `word` w WHERE w.word_bank_id = wb.id AND w.english = 'こんにちは' AND w.status = 1);

INSERT INTO `word` (`word_bank_id`, `english`, `language`, `phonetic`, `chinese`, `example`, `status`)
SELECT wb.id, 'ありがとう', 'JA', NULL, '谢谢', '手伝ってくれて、ありがとう。', 1
FROM `word_bank` wb
WHERE wb.name = '日语入门词库' AND wb.language = 'JA' AND wb.status = 1
  AND NOT EXISTS (SELECT 1 FROM `word` w WHERE w.word_bank_id = wb.id AND w.english = 'ありがとう' AND w.status = 1);

INSERT INTO `word` (`word_bank_id`, `english`, `language`, `phonetic`, `chinese`, `example`, `status`)
SELECT wb.id, '사랑', 'KO', NULL, '爱', '가족에 대한 사랑이 깊다.', 1
FROM `word_bank` wb
WHERE wb.name = '韩语入门词库' AND wb.language = 'KO' AND wb.status = 1
  AND NOT EXISTS (SELECT 1 FROM `word` w WHERE w.word_bank_id = wb.id AND w.english = '사랑' AND w.status = 1);

INSERT INTO `word` (`word_bank_id`, `english`, `language`, `phonetic`, `chinese`, `example`, `status`)
SELECT wb.id, '학교', 'KO', NULL, '学校', '나는 학교에 갑니다.', 1
FROM `word_bank` wb
WHERE wb.name = '韩语入门词库' AND wb.language = 'KO' AND wb.status = 1
  AND NOT EXISTS (SELECT 1 FROM `word` w WHERE w.word_bank_id = wb.id AND w.english = '학교' AND w.status = 1);

-- 清理历史脏数据：词条文本与词库语种不匹配时自动下架
UPDATE `word` w
INNER JOIN `word_bank` wb ON wb.id = w.word_bank_id
SET w.status = 0
WHERE w.status = 1
  AND (
      (wb.language = 'JA' AND w.english NOT REGEXP '[ぁ-んァ-ヶ一-龯]')
      OR (wb.language = 'KO' AND w.english NOT REGEXP '[가-힣]')
      OR (wb.language = 'EN' AND w.english NOT REGEXP '[A-Za-z]')
  );

-- 回填词库单词统计
UPDATE `word_bank` wb
LEFT JOIN (
    SELECT word_bank_id, COUNT(*) AS cnt
    FROM `word`
    WHERE status = 1
    GROUP BY word_bank_id
) wc ON wc.word_bank_id = wb.id
SET wb.word_count = IFNULL(wc.cnt, 0)
WHERE wb.status = 1;
