package com.english.filter;

import com.english.dto.AuthenticatedUser;
import com.english.entity.User;
import com.english.mapper.UserMapper;
import com.english.service.TokenBlacklistService;
import com.english.util.JwtUtil;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class JwtAuthenticationFilterTest {

    private static final String SECRET = "EnglishLearningMateSecretKey2024ForJWTTokenGenerationAndValidationMustBeLongEnough";

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void shouldAuthenticateActiveToken() throws Exception {
        JwtUtil jwtUtil = createJwtUtil();
        TokenBlacklistService tokenBlacklistService = mock(TokenBlacklistService.class);
        UserMapper userMapper = mock(UserMapper.class);
        User testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("tester");
        testUser.setRole("USER");
        testUser.setStatus(1);

        String token = jwtUtil.generateToken(1L, "tester", "USER");
        when(tokenBlacklistService.isTokenActive(token)).thenReturn(true);
        when(userMapper.selectById(1L)).thenReturn(testUser);

        JwtAuthenticationFilter filter = new JwtAuthenticationFilter(jwtUtil, tokenBlacklistService, userMapper);
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("Authorization", "Bearer " + token);

        filter.doFilter(request, new MockHttpServletResponse(), new MockFilterChain());

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        assertNotNull(authentication);
        AuthenticatedUser principal = assertInstanceOf(AuthenticatedUser.class, authentication.getPrincipal());
        assertEquals(1L, principal.getUserId());
        assertEquals("tester", principal.getUsername());
        assertEquals("USER", principal.getRole());
    }

    @Test
    void shouldRejectBlacklistedToken() throws Exception {
        JwtUtil jwtUtil = createJwtUtil();
        TokenBlacklistService tokenBlacklistService = mock(TokenBlacklistService.class);
        UserMapper userMapper = mock(UserMapper.class);

        String token = jwtUtil.generateToken(2L, "blocked-user", "USER");
        when(tokenBlacklistService.isTokenActive(token)).thenReturn(false);

        JwtAuthenticationFilter filter = new JwtAuthenticationFilter(jwtUtil, tokenBlacklistService, userMapper);
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("Authorization", "Bearer " + token);

        filter.doFilter(request, new MockHttpServletResponse(), new MockFilterChain());

        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    private JwtUtil createJwtUtil() {
        JwtUtil jwtUtil = new JwtUtil();
        ReflectionTestUtils.setField(jwtUtil, "secret", SECRET);
        ReflectionTestUtils.setField(jwtUtil, "expiration", 60_000L);
        ReflectionTestUtils.setField(jwtUtil, "refreshExpiration", 60_000L);
        return jwtUtil;
    }
}
