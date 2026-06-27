-- 检查并插入测试数据

-- 1. 先查看当前数据
SELECT '=== 当前user_study_record表数据统计 ===' AS info;
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT word_id) AS unique_words,
    SUM(correct_count) AS total_correct,
    SUM(wrong_count) AS total_wrong,
    ROUND(SUM(correct_count) / (SUM(correct_count) + SUM(wrong_count)) * 100, 2) AS accuracy_rate
FROM user_study_record
WHERE user_id = 33 AND status IN (1, 2);

SELECT '=== 最近5条记录 ===' AS info;
SELECT id, word_id, study_mode, correct_count, wrong_count, updated_at
FROM user_study_record
WHERE user_id = 33
ORDER BY updated_at DESC
LIMIT 5;

-- 2. 如果没有数据或数据不足，则删除旧数据重新插入
DELETE FROM error_book WHERE user_id = 33;
DELETE FROM user_study_record WHERE user_id = 33;

-- 3. 插入完整的测试学习记录（过去30天）
INSERT INTO user_study_record (user_id, word_bank_id, word_id, study_mode, correct_count, wrong_count, next_review_time, review_count, status, created_at, updated_at) VALUES
-- 今天（高频）
(33, 1, 101, 'spelling', 8, 2, DATE_ADD(NOW(), INTERVAL 1 DAY), 3, 1, NOW(), NOW()),
(33, 1, 102, 'choice', 9, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 5, 1, NOW(), NOW()),
(33, 1, 103, 'spelling', 7, 3, DATE_ADD(NOW(), INTERVAL 1 DAY), 2, 1, NOW(), NOW()),
(33, 2, 201, 'choice', 10, 0, DATE_ADD(NOW(), INTERVAL 3 DAY), 4, 1, NOW(), NOW()),
(33, 2, 202, 'spelling', 6, 4, NOW(), 1, 1, NOW(), NOW()),
-- 1天前
(33, 1, 104, 'choice', 9, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(33, 1, 105, 'spelling', 8, 2, DATE_ADD(NOW(), INTERVAL 1 DAY), 2, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(33, 2, 203, 'choice', 7, 3, NOW(), 1, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
-- 2天前
(33, 1, 106, 'spelling', 9, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(33, 1, 107, 'choice', 8, 2, DATE_ADD(NOW(), INTERVAL 3 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(33, 2, 204, 'spelling', 10, 0, DATE_ADD(NOW(), INTERVAL 4 DAY), 5, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(33, 2, 205, 'choice', 6, 4, NOW(), 2, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
-- 3天前
(33, 1, 108, 'choice', 7, 3, NOW(), 1, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(33, 1, 109, 'spelling', 9, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(33, 2, 206, 'choice', 8, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
-- 4天前
(33, 1, 110, 'spelling', 10, 0, DATE_ADD(NOW(), INTERVAL 3 DAY), 5, 1, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
(33, 1, 111, 'choice', 8, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
(33, 2, 207, 'spelling', 9, 1, DATE_ADD(NOW(), INTERVAL 4 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
-- 5天前
(33, 1, 112, 'choice', 7, 3, NOW(), 2, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(33, 1, 113, 'spelling', 8, 2, DATE_ADD(NOW(), INTERVAL 1 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
-- 6天前
(33, 2, 208, 'choice', 9, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
(33, 2, 209, 'spelling', 6, 4, NOW(), 1, 1, DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
-- 7-14天前
(33, 1, 114, 'choice', 8, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
(33, 1, 115, 'spelling', 9, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
(33, 2, 210, 'choice', 7, 3, NOW(), 2, 1, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
(33, 1, 116, 'spelling', 10, 0, DATE_ADD(NOW(), INTERVAL 4 DAY), 5, 1, DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY)),
(33, 2, 211, 'choice', 8, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY)),
(33, 1, 117, 'choice', 9, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)),
(33, 1, 118, 'spelling', 7, 3, NOW(), 1, 1, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)),
(33, 2, 212, 'spelling', 8, 2, DATE_ADD(NOW(), INTERVAL 1 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)),
(33, 1, 119, 'choice', 6, 4, NOW(), 2, 1, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(33, 2, 213, 'spelling', 9, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(33, 1, 120, 'spelling', 8, 2, DATE_ADD(NOW(), INTERVAL 3 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY)),
(33, 1, 121, 'choice', 10, 0, DATE_ADD(NOW(), INTERVAL 4 DAY), 5, 1, DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY)),
(33, 2, 214, 'choice', 7, 3, NOW(), 1, 1, DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY)),
(33, 1, 122, 'spelling', 9, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY)),
(33, 1, 123, 'choice', 8, 2, DATE_ADD(NOW(), INTERVAL 3 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 13 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY)),
(33, 2, 215, 'spelling', 6, 4, NOW(), 2, 1, DATE_SUB(NOW(), INTERVAL 13 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY)),
(33, 1, 124, 'spelling', 9, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY)),
-- 15-30天前
(33, 2, 216, 'choice', 7, 3, DATE_ADD(NOW(), INTERVAL 2 DAY), 2, 1, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
(33, 1, 125, 'spelling', 8, 2, DATE_ADD(NOW(), INTERVAL 3 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 16 DAY), DATE_SUB(NOW(), INTERVAL 16 DAY)),
(33, 2, 217, 'choice', 9, 1, DATE_ADD(NOW(), INTERVAL 4 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 18 DAY), DATE_SUB(NOW(), INTERVAL 18 DAY)),
(33, 1, 126, 'spelling', 6, 4, NOW(), 1, 1, DATE_SUB(NOW(), INTERVAL 19 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY)),
(33, 2, 218, 'choice', 8, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 21 DAY), DATE_SUB(NOW(), INTERVAL 21 DAY)),
(33, 1, 127, 'spelling', 10, 0, DATE_ADD(NOW(), INTERVAL 3 DAY), 5, 1, DATE_SUB(NOW(), INTERVAL 22 DAY), DATE_SUB(NOW(), INTERVAL 22 DAY)),
(33, 2, 219, 'choice', 7, 3, NOW(), 2, 1, DATE_SUB(NOW(), INTERVAL 24 DAY), DATE_SUB(NOW(), INTERVAL 24 DAY)),
(33, 1, 128, 'spelling', 9, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 25 DAY)),
(33, 2, 220, 'choice', 8, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), 4, 1, DATE_SUB(NOW(), INTERVAL 27 DAY), DATE_SUB(NOW(), INTERVAL 27 DAY)),
(33, 1, 129, 'spelling', 6, 4, NOW(), 1, 1, DATE_SUB(NOW(), INTERVAL 28 DAY), DATE_SUB(NOW(), INTERVAL 28 DAY)),
(33, 2, 221, 'choice', 9, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), 3, 1, DATE_SUB(NOW(), INTERVAL 29 DAY), DATE_SUB(NOW(), INTERVAL 29 DAY)),
(33, 1, 130, 'spelling', 7, 3, DATE_ADD(NOW(), INTERVAL 2 DAY), 2, 1, DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY));

-- 4. 插入错题本数据
INSERT INTO error_book (user_id, word_id, error_type, error_times, is_mastered, status, created_at, updated_at) VALUES
(33, 103, 'spelling', 3, 0, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(33, 202, 'meaning', 4, 0, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(33, 203, 'choice', 3, 0, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(33, 106, 'spelling', 3, 0, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(33, 111, 'pronunciation', 2, 0, 1, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
(33, 113, 'meaning', 3, 0, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(33, 117, 'spelling', 4, 0, 1, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
(33, 120, 'choice', 4, 0, 1, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(33, 126, 'meaning', 4, 0, 1, DATE_SUB(NOW(), INTERVAL 19 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY)),
(33, 129, 'spelling', 4, 0, 1, DATE_SUB(NOW(), INTERVAL 28 DAY), DATE_SUB(NOW(), INTERVAL 28 DAY));

-- 5. 验证插入结果
SELECT '=== 插入后的数据统计 ===' AS info;
SELECT
    COUNT(DISTINCT word_id) AS total_vocabulary,
    SUM(correct_count) AS total_correct,
    SUM(wrong_count) AS total_wrong,
    ROUND(SUM(correct_count) / (SUM(correct_count) + SUM(wrong_count)) * 100, 2) AS accuracy_rate
FROM user_study_record
WHERE user_id = 33 AND status IN (1, 2);

SELECT COUNT(*) AS error_book_count FROM error_book WHERE user_id = 33 AND status = 1;

SELECT '=== 最近7天每日学习统计 ===' AS info;
SELECT
    DATE(updated_at) AS study_date,
    COUNT(*) AS study_count,
    SUM(correct_count) AS correct,
    SUM(wrong_count) AS wrong
FROM user_study_record
WHERE user_id = 33 AND updated_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(updated_at)
ORDER BY study_date DESC;
