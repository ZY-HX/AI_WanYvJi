package com.english.config;

import com.english.common.Result;
import com.english.filter.JwtAuthenticationFilter;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import jakarta.servlet.DispatcherType;
import java.io.IOException;
import java.util.List;

/**
 * Spring Security安全配置类
 * 负责配置系统的认证和授权规则，包括：
 * - JWT Token认证机制
 * - CORS跨域访问控制
 * - 密码加密方式（BCrypt）
 * - API接口权限控制
 * - 静态资源访问权限
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    /** JWT认证过滤器，用于验证Token并设置用户认证信息 */
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    /** JSON对象映射器，用于将错误信息转换为JSON格式响应 */
    private final ObjectMapper objectMapper;
    /**
     * 允许的跨域来源模式列表
     * 支持localhost和127.0.0.1的所有端口，方便前后端分离开发调试
     * 可通过application.yml中的app.cors.allowed-origin-patterns配置项自定义
     */
    @Value("${app.cors.allowed-origin-patterns:http://localhost:*,http://127.0.0.1:*}")
    private String[] allowedOriginPatterns;

    /**
     * 配置安全过滤链
     * 定义HTTP安全策略，包括：
     * 1. 禁用CSRF保护（因为使用JWT无状态认证）
     * 2. 启用CORS跨域支持
     * 3. 使用无状态会话管理（不使用Session）
     * 4. 配置自定义认证失败和授权失败处理器
     * 5. 设置公开接口和白名单路径
     * 6. 添加JWT认证过滤器
     *
     * @param http HttpSecurity配置对象
     * @return 构建完成的SecurityFilterChain
     * @throws Exception 配置异常
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 禁用CSRF保护，因为使用JWT Token进行无状态认证
                .csrf(AbstractHttpConfigurer::disable)
                // 配置CORS跨域支持
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                // 使用无状态会话，不创建或使用HTTP Session
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // 配置异常处理：自定义未认证和未授权的响应格式
                .exceptionHandling(exception -> exception
                        // 认证失败处理器（401）：返回JSON格式的错误信息
                        .authenticationEntryPoint((request, response, authException) ->
                                writeJsonError(response, 401, "未登录或Token已过期"))
                        // 授权失败处理器（403）：返回JSON格式的错误信息
                        .accessDeniedHandler((request, response, accessDeniedException) ->
                                writeJsonError(response, 403, "无权访问该资源"))
                )
                // 配置请求授权规则
                .authorizeHttpRequests(auth -> auth
                        // 允许异步请求和错误页面 dispatcherType 无需认证
                        .dispatcherTypeMatchers(DispatcherType.ASYNC, DispatcherType.ERROR).permitAll()
                        // 配置公开接口白名单（无需Token即可访问）
                        .requestMatchers(
                                "/api/auth/login",          // 用户登录接口
                                "/api/auth/register",       // 用户注册接口
                                "/api/auth/guest",          // 游客登录接口
                                "/api/auth/guest/renew",    // 游客Token续期接口
                                "/api/auth/renew",          // 用户Token续期接口
                                "/api/auth/sync",           // 数据同步接口
                                "/api/health",              // 健康检查接口
                                "/uploads/**",              // 静态资源文件（上传的图片等）
                                "/v3/api-docs/**",         // OpenAPI文档
                                "/swagger-ui.html",        // Swagger UI首页
                                "/swagger-ui/**"            // Swagger UI静态资源
                        ).permitAll()
                        // 其他所有请求都需要认证
                        .anyRequest().authenticated()
                )
                // 在用户名密码过滤器之前添加JWT认证过滤器
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * 配置CORS跨域源
     * 设置允许的跨域请求来源、方法、头部等信息
     *
     * @return CORS配置源对象
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        // 设置允许的跨域来源模式（支持通配符）
        configuration.setAllowedOriginPatterns(List.of(allowedOriginPatterns));
        // 允许的HTTP方法：GET、POST、PUT、DELETE、OPTIONS
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        // 允许所有请求头
        configuration.setAllowedHeaders(List.of("*"));
        // 允许携带Cookie等凭证信息
        configuration.setAllowCredentials(true);
        // 预检请求缓存时间（秒）
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        // 对所有路径应用CORS配置
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    /**
     * 密码编码器Bean
     * 使用BCrypt算法对密码进行加密存储
     * BCrypt是一种单向哈希算法，自带盐值，安全性高
     *
     * @return BCryptPasswordEncoder实例
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * 认证管理器Bean
     * 用于Spring Security的认证流程
     *
     * @param config 认证配置对象
     * @return AuthenticationManager实例
     * @throws Exception 获取认证管理器失败时抛出异常
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    /**
     * 写入JSON格式的错误响应
     * 用于认证失败和授权失败时的统一错误响应格式
     *
     * @param response HTTP响应对象
     * @param code HTTP状态码（如401、403）
     * @param message 错误提示消息
     * @throws IOException 写入响应时发生IO异常
     */
    private void writeJsonError(jakarta.servlet.http.HttpServletResponse response, int code, String message)
            throws IOException {
        // 设置HTTP状态码
        response.setStatus(code);
        // 设置响应内容类型为JSON
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        // 设置字符编码为UTF-8
        response.setCharacterEncoding("UTF-8");
        // 将错误信息以JSON格式写入响应体
        response.getWriter().write(objectMapper.writeValueAsString(Result.error(code, message)));
    }
}
