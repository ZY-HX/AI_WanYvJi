package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.*;
import com.english.entity.User;
import com.english.service.SystemConfigService;
import com.english.service.TokenBlacklistService;
import com.english.service.UserService;
import com.english.util.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 认证管理控制器
 * 提供用户认证相关的API接口，包括：
 * - 用户名密码登录
 * - 游客临时账号登录
 * - JWT Token续期
 * - 用户注册
 * - 数据同步接口
 *
 * 所有接口路径都以 /api/auth 为前缀
 * 使用Swagger的@Tag注解进行API文档分组
 */
@Tag(name = "认证管理", description = "用户注册、登录、游客认证相关接口")
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    /** 用户服务，处理用户相关的业务逻辑 */
    private final UserService userService;
    /** 系统配置服务，获取系统级配置参数 */
    private final SystemConfigService systemConfigService;
    /** Token黑名单服务，管理Token注销状态 */
    private final TokenBlacklistService tokenBlacklistService;
    /** JWT工具类，用于生成和解析Token */
    private final JwtUtil jwtUtil;

    /**
     * 用户登录接口
     * 接收用户名和密码，验证成功后返回JWT Token和用户基本信息
     * 支持"记住我"功能，选择记住我可延长Token有效期至7天
     *
     * @param request 登录请求体，包含username、password、rememberMe字段
     * @return 登录成功响应，包含Token、用户ID、用户名、昵称等信息
     * @throws BusinessException 登录失败时抛出异常（用户名/密码错误、账户锁定等）
     */
    @Operation(summary = "用户登录")
    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        // 调用UserService执行登录验证
        User user = userService.login(request.getUsername(), request.getPassword());
        // 生成JWT Token（根据是否记住我来决定有效期）
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole(), request.isRememberMe());

        // 构建登录响应对象
        LoginResponse response = new LoginResponse();
        response.setToken(token);              // JWT Token
        response.setUserId(user.getId());      // 用户ID
        response.setUsername(user.getUsername());  // 用户名
        response.setNickname(user.getNickname());  // 昵称
        response.setEmail(user.getEmail());    // 邮箱
        response.setRole(user.getRole());      // 角色
        response.setAvatarUrl(user.getAvatarUrl());  // 头像URL

        return Result.success("登录成功", response);
    }

    /**
     * 游客登录接口
     * 为未注册用户创建临时游客账号，返回有限制的Token
     * 游客Token特点：
     * - 有效期较短（可通过系统配置调整）
     * - 有最大续期次数限制
     * - 权限受限（ROLE_GUEST）
     *
     * @return 游客登录响应，包含临时Token、用户信息和配额限制
     */
    @Operation(summary = "游客登录")
    @PostMapping("/guest")
    public Result<GuestLoginResponse> guestLogin() {
        // 从系统配置获取游客Token的有效期天数
        int validityDays = systemConfigService.getGuestTokenValidityDays();
        // 从系统配置获取游客Token的最大续期次数
        int renewLimit = systemConfigService.getGuestTokenRenewLimit();

        // 创建新的游客用户
        User guestUser = userService.createGuestUser();
        // 生成游客专用Token（包含有效期和续期限制信息）
        String token = jwtUtil.generateGuestToken(
                guestUser.getId(),
                guestUser.getUsername(),
                daysToMillis(validityDays),   // 将天数转换为毫秒
                renewLimit,                    // 最大续期次数
                0                              // 当前已用续期次数：初始为0
        );

        return Result.success("游客登录成功", buildGuestLoginResponse(guestUser, token, validityDays, renewLimit, renewLimit));
    }

    /**
     * 注册用户Token续期接口
     * 用于在Token即将过期但还未过期时获取新Token
     * 安全机制：
     * - 每个Token只能续期一次（防止无限续期）
     * - 续期后将旧Token加入黑名单使其失效
     * - 续期后会检查用户状态是否正常
     *
     * @param request 续期请求体，包含当前有效的Token
     * @return 续期成功响应，包含新Token和最新用户信息
     * @throws BusinessException Token无效、已过期、已续期过或用户状态异常时抛出相应异常
     */
    @Operation(summary = "Token续期")
    @PostMapping("/renew")
    public Result<LoginResponse> renewToken(@Valid @RequestBody TokenRenewRequest request) {
        // 验证当前Token是否仍然有效（未被注销且未过期）
        if (!tokenBlacklistService.isTokenActive(request.getToken())) {
            throw new BusinessException(401, "Token无效或已过期");
        }

        // 从Token中提取角色信息
        String role = jwtUtil.getRole(request.getToken());
        // 游客Token需要使用专门的续期接口
        if ("GUEST".equals(role)) {
            throw new BusinessException(400, "游客请使用 /api/auth/guest/renew 接口续期");
        }

        // 执行Token续期（生成新Token）
        String newToken = jwtUtil.renewToken(request.getToken());
        if (newToken == null) {
            // 该Token已经续期过了，拒绝再次续期
            throw new BusinessException(400, "Token已续期过一次，不可再次续期");
        }
        // 将旧Token加入黑名单（使其失效）
        tokenBlacklistService.blacklist(request.getToken());

        // 从新Token中提取用户ID并查询最新用户信息
        Long userId = jwtUtil.getUserId(newToken);
        User user = userService.getById(userId);
        // 验证用户状态是否正常
        if (user == null || user.getStatus() == null || user.getStatus() != 1) {
            throw new BusinessException(403, "账号已失效，请重新登录");
        }

        // 构建续期成功响应
        LoginResponse response = new LoginResponse();
        response.setToken(newToken);             // 新的JWT Token
        response.setUserId(user.getId());
        response.setUsername(user.getUsername());
        response.setNickname(user.getNickname());
        response.setEmail(user.getEmail());
        response.setRole(user.getRole());
        response.setAvatarUrl(user.getAvatarUrl());

        return Result.success("续期成功", response);
    }

    @Operation(summary = "游客Token续期")
    @PostMapping("/guest/renew")
    public Result<GuestLoginResponse> renewGuestToken(@Valid @RequestBody TokenRenewRequest request) {
        if (!tokenBlacklistService.isTokenActive(request.getToken())) {
            throw new BusinessException(401, "游客Token无效或已过期");
        }

        String role = jwtUtil.getRole(request.getToken());
        if (!"GUEST".equals(role)) {
            throw new BusinessException(400, "仅支持游客Token续期");
        }

        Long userId = jwtUtil.getUserId(request.getToken());
        if (userId == null) {
            throw new BusinessException(400, "当前游客Token版本不支持续期，请重新以游客身份登录");
        }

        User guestUser = userService.getById(userId);
        if (guestUser == null || !"GUEST".equals(guestUser.getRole()) || guestUser.getStatus() == 0) {
            throw new BusinessException(404, "游客账号不存在或已失效");
        }

        int validityDays = systemConfigService.getGuestTokenValidityDays();
        int renewLimit = systemConfigService.getGuestTokenRenewLimit();
        int currentRenewCount = jwtUtil.getGuestRenewCount(request.getToken());

        if (currentRenewCount >= renewLimit) {
            throw new BusinessException(400, "游客Token续期次数已用完，请重新以游客身份登录");
        }

        int newRenewCount = currentRenewCount + 1;
        String newToken = jwtUtil.renewGuestToken(request.getToken(), daysToMillis(validityDays), renewLimit, newRenewCount);
        tokenBlacklistService.blacklist(request.getToken());

        return Result.success(
                "游客Token续期成功",
                buildGuestLoginResponse(guestUser, newToken, validityDays, renewLimit, renewLimit - newRenewCount)
        );
    }

    @Operation(summary = "游客数据同步")
    @PostMapping("/sync")
    public Result<Void> syncGuestData(@Valid @RequestBody DataSyncRequest request) {
        if (!tokenBlacklistService.isTokenActive(request.getGuestToken())) {
            throw new BusinessException(401, "游客Token无效或已过期");
        }

        String role = jwtUtil.getRole(request.getGuestToken());
        if (!"GUEST".equals(role)) {
            throw new BusinessException(400, "仅支持游客数据同步");
        }

        return Result.success("数据同步完成", null);
    }

    @Operation(summary = "用户登出")
    @PostMapping("/logout")
    public Result<Void> logout(HttpServletRequest request) {
        String token = extractToken(request);
        if (!tokenBlacklistService.isTokenActive(token)) {
            throw new BusinessException(401, "Token无效或已过期");
        }

        tokenBlacklistService.blacklist(token);
        return Result.success("登出成功", null);
    }

    private GuestLoginResponse buildGuestLoginResponse(
            User guestUser,
            String token,
            int validityDays,
            int renewLimit,
            int renewCountRemaining
    ) {
        GuestLoginResponse response = new GuestLoginResponse();
        response.setToken(token);
        response.setUserId(guestUser.getId());
        response.setUsername(guestUser.getUsername());
        response.setNickname(guestUser.getNickname());
        response.setRole(guestUser.getRole());
        response.setExpiresAt(jwtUtil.getExpirationTime(token));
        response.setValidityDays(validityDays);
        response.setRenewLimit(renewLimit);
        response.setRenewCountRemaining(Math.max(renewCountRemaining, 0));
        return response;
    }

    private long daysToMillis(int days) {
        return java.util.concurrent.TimeUnit.DAYS.toMillis(days);
    }

    private String extractToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (StringUtils.hasText(authorization) && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }
}
