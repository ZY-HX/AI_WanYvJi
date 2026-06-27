package com.english.service;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserStudyPlanService {

    private static final int DEFAULT_STUDY_SESSION_SIZE = 20;
    private static final boolean DEFAULT_ALLOW_SAME_DAY_REVIEW = true;
    private static final int MIN_STUDY_SESSION_SIZE = 5;
    private static final int MAX_STUDY_SESSION_SIZE = 100;

    private final JdbcTemplate jdbcTemplate;

    @PostConstruct
    public void initialize() {
        ensureTableExists();
    }

    public StudyPlanSettings getPlan(Long userId) {
        ensureTableExists();
        StudyPlanSettings settings = jdbcTemplate.query(
                """
                        SELECT study_session_size, allow_same_day_review
                        FROM user_study_plan
                        WHERE user_id = ?
                        LIMIT 1
                        """,
                rs -> rs.next()
                        ? new StudyPlanSettings(rs.getInt("study_session_size"),
                        rs.getBoolean("allow_same_day_review"))
                        : null,
                userId
        );

        if (settings != null) {
            return settings;
        }

        StudyPlanSettings defaultSettings = new StudyPlanSettings(
                DEFAULT_STUDY_SESSION_SIZE,
                DEFAULT_ALLOW_SAME_DAY_REVIEW
        );
        jdbcTemplate.update(
                """
                        INSERT INTO user_study_plan (user_id, study_session_size, allow_same_day_review)
                        VALUES (?, ?, ?)
                        """,
                userId,
                defaultSettings.studySessionSize(),
                defaultSettings.allowSameDayReview() ? 1 : 0
        );
        return defaultSettings;
    }

    public StudyPlanSettings updatePlan(Long userId, Integer studySessionSize, Boolean allowSameDayReview) {
        StudyPlanSettings currentPlan = getPlan(userId);
        int nextStudySessionSize = normalizeStudySessionSize(
                studySessionSize == null ? currentPlan.studySessionSize() : studySessionSize
        );
        boolean nextAllowSameDayReview = allowSameDayReview == null
                ? currentPlan.allowSameDayReview()
                : allowSameDayReview;

        jdbcTemplate.update(
                """
                        UPDATE user_study_plan
                        SET study_session_size = ?, allow_same_day_review = ?
                        WHERE user_id = ?
                        """,
                nextStudySessionSize,
                nextAllowSameDayReview ? 1 : 0,
                userId
        );
        return new StudyPlanSettings(nextStudySessionSize, nextAllowSameDayReview);
    }

    private int normalizeStudySessionSize(int value) {
        return Math.max(MIN_STUDY_SESSION_SIZE, Math.min(MAX_STUDY_SESSION_SIZE, value));
    }

    private void ensureTableExists() {
        try {
            jdbcTemplate.execute(
                    """
                            CREATE TABLE IF NOT EXISTS user_study_plan (
                                id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
                                user_id BIGINT NOT NULL COMMENT '用户ID',
                                study_session_size INT NOT NULL DEFAULT 20 COMMENT '单次学习题量',
                                allow_same_day_review TINYINT NOT NULL DEFAULT 1 COMMENT '是否允许当天继续复习',
                                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                PRIMARY KEY (id),
                                UNIQUE KEY uk_user_id (user_id)
                            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习计划表'
                            """
            );
        } catch (DataAccessException e) {
            log.warn("初始化用户学习计划表失败", e);
            throw e;
        }
    }

    public record StudyPlanSettings(int studySessionSize, boolean allowSameDayReview) {
    }
}
