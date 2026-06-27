package com.english.filter;

import com.english.dto.AuthenticatedUser;
import com.english.entity.User;
import com.english.mapper.UserMapper;
import com.english.service.TokenBlacklistService;
import com.english.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * JWT认证过滤器
 * 继承OncePerRequestFilter，确保每个请求只执行一次过滤
 * 负责从HTTP请求头中提取JWT Token，验证其有效性，并设置用户认证信息到Security上下文
 * 支持普通用户Token和游客Token两种认证方式
 *
 * 工作流程：
 * 1. 从请求头的Authorization中提取Bearer Token
 * 2. 验证Token是否有效且未被加入黑名单
 * 3. 根据Token中的角色信息区分用户类型
 * 4. 查询数据库验证用户状态（仅对注册用户）
 * 5. 创建Authentication对象并设置到SecurityContext
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    /** JWT工具类，用于生成和解析Token */
    private final JwtUtil jwtUtil;
    /** Token黑名单服务，用于检查Token是否已被注销 */
    private final TokenBlacklistService tokenBlacklistService;
    /** 用户数据访问对象，用于查询用户信息 */
    private final UserMapper userMapper;

    /**
     * 构造函数，通过依赖注入初始化所需的组件
     *
     * @param jwtUtil JWT工具类实例
     * @param tokenBlacklistService Token黑名单服务实例
     * @param userMapper 用户Mapper实例
     */
    @Autowired
    public JwtAuthenticationFilter(JwtUtil jwtUtil, TokenBlacklistService tokenBlacklistService, UserMapper userMapper) {
        this.jwtUtil = jwtUtil;
        this.tokenBlacklistService = tokenBlacklistService;
        this.userMapper = userMapper;
    }

    /**
     * 执行过滤的核心方法
     * 对每个请求进行JWT Token认证，提取用户信息并设置到Spring Security上下文中
     *
     * @param request HTTP请求对象
     * @param response HTTP响应对象
     * @param filterChain 过滤器链，用于将请求传递给下一个过滤器
     * @throws ServletException Servlet异常
     * @throws IOException IO异常
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        // 从请求中提取JWT Token
        String token = extractToken(request);

        // 如果Token存在且有效，则进行认证
        if (StringUtils.hasText(token) && isTokenActive(token)) {
            // 从Token中解析用户基本信息
            String role = jwtUtil.getRole(token);
            Long userId = jwtUtil.getUserId(token);
            String username = jwtUtil.getUsername(token);

            // 处理注册用户的认证
            if (userId != null && userMapper != null) {
                // 查询用户信息
                User currentUser = userMapper.selectById(userId);
                // 验证用户是否存在且状态正常（status=1表示正常）
                if (currentUser == null || currentUser.getStatus() == null || currentUser.getStatus() != 1) {
                    // 用户不存在或被禁用，跳过认证，继续执行过滤器链
                    filterChain.doFilter(request, response);
                    return;
                }
                // 创建已认证的用户主体对象
                AuthenticatedUser authenticatedUser = new AuthenticatedUser(userId, currentUser.getUsername(), currentUser.getRole());
                // 创建UsernamePasswordAuthenticationToken并设置权限
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                authenticatedUser,           // 认证主体（用户信息）
                                null,                       // 凭证（Token认证不需要密码）
                                List.of(new SimpleGrantedAuthority("ROLE_" + currentUser.getRole()))  // 用户权限列表
                        );
                // 将认证信息设置到Security上下文中
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
            // 处理游客用户的认证
            else if ("GUEST".equals(role) && username != null) {
                // 获取游客ID
                String guestId = jwtUtil.getGuestId(token);
                if (guestId != null) {
                    // 创建游客的认证Token
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    "GUEST:" + guestId,       // 游客标识
                                    null,                      // 凭证
                                    List.of(new SimpleGrantedAuthority("ROLE_GUEST"))  // 游客权限
                            );
                    // 设置游客认证信息到Security上下文
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                }
            }
        }

        // 无论是否认证成功，都继续执行过滤器链
        filterChain.doFilter(request, response);
    }

    /**
     * 从HTTP请求头中提取JWT Token
     * Token格式：Authorization: Bearer <token>
     *
     * @param request HTTP请求对象
     * @return 提取到的Token字符串，如果不存在则返回null
     */
    private String extractToken(HttpServletRequest request) {
        // 获取Authorization请求头
        String bearerToken = request.getHeader("Authorization");
        // 检查是否以"Bearer "开头（注意空格）
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            // 去掉"Bearer "前缀，返回纯Token字符串
            return bearerToken.substring(7);
        }
        return null;
    }

    /**
     * 检查Token是否处于活跃状态（有效且未注销）
     * 如果配置了Token黑名单服务，则同时检查黑名单；否则只验证Token有效性
     *
     * @param token JWT Token字符串
     * @return true-Token活跃可用，false-Token无效或已注销
     */
    private boolean isTokenActive(String token) {
        // 如果没有配置黑名单服务，则只验证Token签名和过期时间
        // 如果配置了黑名单服务，则额外检查Token是否在黑名单中
        return tokenBlacklistService == null ? jwtUtil.validateToken(token) : tokenBlacklistService.isTokenActive(token);
    }
}
