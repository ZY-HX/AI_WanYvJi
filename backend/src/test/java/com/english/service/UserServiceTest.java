package com.english.service;

import com.english.common.BusinessException;
import com.english.dto.LoginLockStatusResponse;
import com.english.entity.User;
import com.english.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserMapper userMapper;

    @Mock
    private PasswordEncoder passwordEncoder;

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService(userMapper, passwordEncoder);
    }

    @Test
    void shouldReturnRemainingLockTimeWhenUserAlreadyLocked() {
        User user = buildUser("locked_user", 2, LocalDateTime.now().plusMinutes(8).plusSeconds(5));
        when(userMapper.selectOne(any())).thenReturn(user);

        BusinessException exception = expectBusinessException(() -> userService.login("locked_user", "wrong-password"));

        assertEquals(403, exception.getCode());
        assertTrue(exception.getMessage().contains("账号已被锁定"));
        LoginLockStatusResponse data = assertInstanceOf(LoginLockStatusResponse.class, exception.getData());
        assertTrue(data.isLocked());
        assertTrue(data.getRemainingLockSeconds() > 0);
        assertNotNull(data.getLockUntil());
        assertTrue(data.getRemainingLockTimeText().contains("分"));
        verify(userMapper, never()).updateById(any(User.class));
    }

    @Test
    void shouldLockAccountOnFifthFailedLoginAndReturnCountdown() {
        User user = buildUser("fifth_fail_user", 4, null);
        when(userMapper.selectOne(any())).thenReturn(user);
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false);

        BusinessException exception = expectBusinessException(() -> userService.login("fifth_fail_user", "wrong-password"));

        assertEquals(403, exception.getCode());
        assertEquals(5, user.getLoginFailCount());
        assertNotNull(user.getLockTime());
        assertTrue(user.getLockTime().isAfter(LocalDateTime.now().plusMinutes(9)));

        LoginLockStatusResponse data = assertInstanceOf(LoginLockStatusResponse.class, exception.getData());
        assertTrue(data.isLocked());
        assertTrue(data.getRemainingLockSeconds() >= 599);
        assertEquals(user.getLockTime(), data.getLockUntil());
        verify(userMapper).updateById(any(User.class));
    }

    private User buildUser(String username, Integer failCount, LocalDateTime lockTime) {
        User user = new User();
        user.setId(1L);
        user.setUsername(username);
        user.setEmail(username + "@example.com");
        user.setPassword("encoded-password");
        user.setRole("USER");
        user.setStatus(1);
        user.setLoginFailCount(failCount);
        user.setLockTime(lockTime);
        return user;
    }

    private BusinessException expectBusinessException(Runnable runnable) {
        try {
            runnable.run();
        } catch (BusinessException exception) {
            return exception;
        }
        fail("预期抛出 BusinessException");
        return null;
    }
}
