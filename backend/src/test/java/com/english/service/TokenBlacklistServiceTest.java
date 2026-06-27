package com.english.service;

import com.english.resilience.ResilientRedisTemplate;
import com.english.util.JwtUtil;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class TokenBlacklistServiceTest {

    private static final String SECRET = "EnglishLearningMateSecretKey2024ForJWTTokenGenerationAndValidationMustBeLongEnough";

    @Test
    void shouldTreatTokenAsActiveWhenRedisUnavailableAndTokenNotBlacklisted() {
        ResilientRedisTemplate resilientRedisTemplate = mock(ResilientRedisTemplate.class);
        when(resilientRedisTemplate.hasKey(anyString())).thenReturn(false);

        TokenBlacklistService service = new TokenBlacklistService(resilientRedisTemplate, createJwtUtil());
        String token = createJwtUtil().generateToken(1L, "tester", "USER");

        assertTrue(service.isTokenActive(token));
    }

    @Test
    void shouldFallbackToLocalBlacklistWhenRedisUnavailable() {
        ResilientRedisTemplate resilientRedisTemplate = mock(ResilientRedisTemplate.class);
        doThrow(new RuntimeException("redis down")).when(resilientRedisTemplate).set(anyString(), any(), any(java.time.Duration.class));
        when(resilientRedisTemplate.hasKey(anyString())).thenReturn(true);

        JwtUtil jwtUtil = createJwtUtil();
        TokenBlacklistService service = new TokenBlacklistService(resilientRedisTemplate, jwtUtil);
        String token = jwtUtil.generateToken(2L, "blocked-user", "USER");

        service.blacklist(token);

        assertTrue(service.isBlacklisted(token));
        assertFalse(service.isTokenActive(token));
    }

    private JwtUtil createJwtUtil() {
        JwtUtil jwtUtil = new JwtUtil();
        ReflectionTestUtils.setField(jwtUtil, "secret", SECRET);
        ReflectionTestUtils.setField(jwtUtil, "expiration", 60_000L);
        ReflectionTestUtils.setField(jwtUtil, "refreshExpiration", 60_000L);
        return jwtUtil;
    }
}
