package com.english.service;

import com.english.common.BusinessException;
import com.english.resilience.ResilientRedisTemplate;
import com.english.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.util.HexFormat;

@Slf4j
@Service
@RequiredArgsConstructor
public class TokenBlacklistService {

    private static final String BLACKLIST_KEY_PREFIX = "auth:token:blacklist:";

    private final ResilientRedisTemplate resilientRedisTemplate;
    private final JwtUtil jwtUtil;

    public boolean isTokenActive(String token) {
        return StringUtils.hasText(token) && jwtUtil.validateToken(token) && !isBlacklisted(token);
    }

    public void blacklist(String token) {
        if (!StringUtils.hasText(token) || !jwtUtil.validateToken(token)) {
            throw new BusinessException(401, "Token无效或已过期");
        }

        long remainingValidityMillis = jwtUtil.getRemainingValidityMillis(token);
        if (remainingValidityMillis <= 0) {
            throw new BusinessException(401, "Token无效或已过期");
        }

        String blacklistKey = buildBlacklistKey(token);
        resilientRedisTemplate.set(
                blacklistKey,
                "1",
                Duration.ofMillis(remainingValidityMillis)
        );
        log.debug("🚫 Token 已加入黑名单 key={}", blacklistKey);
    }

    public boolean isBlacklisted(String token) {
        if (!StringUtils.hasText(token)) {
            return false;
        }

        String blacklistKey = buildBlacklistKey(token);
        Boolean exists = resilientRedisTemplate.hasKey(blacklistKey);
        return Boolean.TRUE.equals(exists);
    }

    private String buildBlacklistKey(String token) {
        return BLACKLIST_KEY_PREFIX + sha256Hex(token);
    }

    private String sha256Hex(String token) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 algorithm not available", e);
        }
    }
}
