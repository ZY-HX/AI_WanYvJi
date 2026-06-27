package com.english.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class SystemConfigService {

    private final JdbcTemplate jdbcTemplate;

    @Value("${app.guest.token-validity-days:7}")
    private int defaultGuestTokenValidityDays;

    @Value("${app.guest.token-renew-limit:1}")
    private int defaultGuestTokenRenewLimit;

    @Value("${app.ai.article-daily-quota:5}")
    private int defaultAiArticleDailyQuota;

    @Value("${app.study.export-daily-quota:3}")
    private int defaultStudyExportDailyQuota;

    @Value("${app.ai.base-url:https://api.openai.com/v1}")
    private String defaultAiBaseUrl;

    @Value("${app.ai.model:gpt-4o-mini}")
    private String defaultAiModel;

    @Value("${app.ai.api-key:}")
    private String defaultAiApiKey;

    public int getGuestTokenValidityDays() {
        return getIntConfig("guest_token_validity_days", defaultGuestTokenValidityDays);
    }

    public int getGuestTokenRenewLimit() {
        return getIntConfig("guest_token_renew_limit", defaultGuestTokenRenewLimit);
    }

    public int getAiArticleDailyQuota() {
        return getIntConfig("ai_article_daily_quota", defaultAiArticleDailyQuota);
    }

    public int getStudyExportDailyQuota() {
        return getIntConfig("export_daily_quota", defaultStudyExportDailyQuota);
    }

    public String getAiBaseUrl() {
        return getStringConfig("ai_base_url", defaultAiBaseUrl);
    }

    public String getAiModel() {
        return getStringConfig("ai_model", defaultAiModel);
    }

    public String getAiApiKey() {
        return getStringConfig("ai_api_key", defaultAiApiKey);
    }

    public void updateStringConfig(String key, String value) {
        ensureTableExists();
        String existing = getStringConfig(key, null);
        if (existing != null) {
            jdbcTemplate.update(
                    "UPDATE system_config SET config_value = ?, updated_at = NOW() WHERE config_key = ?",
                    value, key
            );
        } else {
            jdbcTemplate.update(
                    "INSERT INTO system_config (config_key, config_value, created_at, updated_at) VALUES (?, ?, NOW(), NOW())",
                    key, value
            );
        }
        log.info("系统配置已更新：{} = {}", key, maskSensitiveValue(key, value));
    }

    public void deleteConfig(String key) {
        ensureTableExists();
        jdbcTemplate.update("DELETE FROM system_config WHERE config_key = ?", key);
        log.info("系统配置已删除：{}", key);
    }

    private int getIntConfig(String key, int defaultValue) {
        try {
            Integer tableCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(1) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'system_config'",
                    Integer.class
            );

            if (tableCount == null || tableCount == 0) {
                return defaultValue;
            }

            String configValue = jdbcTemplate.query(
                    "SELECT config_value FROM system_config WHERE config_key = ? LIMIT 1",
                    rs -> rs.next() ? rs.getString(1) : null,
                    key
            );

            if (configValue == null || configValue.isBlank()) {
                return defaultValue;
            }

            return Integer.parseInt(configValue.trim());
        } catch (DataAccessException | NumberFormatException e) {
            log.warn("读取系统配置 {} 失败，使用默认值 {}", key, defaultValue);
            return defaultValue;
        }
    }

    private String getStringConfig(String key, String defaultValue) {
        try {
            ensureTableExists();
            String configValue = jdbcTemplate.query(
                    "SELECT config_value FROM system_config WHERE config_key = ? LIMIT 1",
                    rs -> rs.next() ? rs.getString(1) : null,
                    key
            );

            if (configValue == null || configValue.isBlank()) {
                return defaultValue;
            }

            return configValue.trim();
        } catch (DataAccessException e) {
            log.warn("读取字符串系统配置 {} 失败，使用默认值", key);
            return defaultValue;
        }
    }

    private void ensureTableExists() {
        try {
            Integer tableCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(1) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'system_config'",
                    Integer.class
            );

            if (tableCount == null || tableCount == 0) {
                jdbcTemplate.execute("""
                        CREATE TABLE IF NOT EXISTS system_config (
                            id BIGINT AUTO_INCREMENT PRIMARY KEY,
                            config_key VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
                            config_value TEXT COMMENT '配置值',
                            created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            INDEX idx_config_key (config_key)
                        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表'
                        """);
                log.info("系统配置表 system_config 创建成功");
            }
        } catch (DataAccessException e) {
            log.error("检查或创建系统配置表失败", e);
            throw new RuntimeException("无法初始化系统配置表", e);
        }
    }

    private String maskSensitiveValue(String key, String value) {
        if (key.toLowerCase().contains("api-key") || key.toLowerCase().contains("apikey") || key.toLowerCase().contains("secret")) {
            if (value == null || value.length() <= 8) {
                return "****";
            }
            return value.substring(0, 4) + "****" + value.substring(value.length() - 4);
        }
        return value;
    }
}
