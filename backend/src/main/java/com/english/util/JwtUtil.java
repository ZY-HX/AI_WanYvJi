package com.english.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT（JSON Web Token）工具类
 * 负责JWT Token的生成、解析、验证和续期等核心操作
 * 使用HS256算法进行签名，支持普通用户Token和游客Token两种模式
 *
 * 主要功能：
 * - 生成用户访问Token（支持记住我功能，延长有效期）
 * - 生成游客临时Token（限制续期次数）
 * - Token续期（防止重复续期）
 * - 解析Token获取用户信息
 * - 验证Token有效性和过期时间
 */
@Component
public class JwtUtil {

    /** JWT签名密钥（从配置文件读取，必须保密） */
    @Value("${jwt.secret}")
    private String secret;

    /** 普通Token有效期（毫秒），默认2小时 */
    @Value("${jwt.expiration}")
    private long expiration;

    /** 记住我模式的Token有效期（毫秒），默认7天 */
    @Value("${jwt.refresh-expiration}")
    private long refreshExpiration;

    /**
     * 获取签名密钥对象
     * 将配置文件中的密钥字符串转换为SecretKey对象
     *
     * @return 用于JWT签名的SecretKey实例
     */
    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * 生成普通用户的访问Token
     * 包含用户ID、用户名、角色等基本信息
     *
     * @param userId 用户ID
     * @param username 用户名
     * @param role 用户角色（USER/ADMIN）
     * @return 生成的JWT Token字符串
     */
    public String generateToken(Long userId, String username, String role) {
        // 构建Token载荷（Claims）
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);       // 用户ID
        claims.put("username", username);   // 用户名
        claims.put("role", role);           // 用户角色
        claims.put("renewed", false);       // 续期标记：初始为false
        return createToken(claims, expiration);
    }

    /**
     * 生成用户访问Token（支持"记住我"功能）
     * 如果选择记住我，则使用更长的有效期
     *
     * @param userId 用户ID
     * @param username 用户名
     * @param role 用户角色
     * @param rememberMe 是否记住我（true-延长有效期至7天，false-标准2小时）
     * @return 生成的JWT Token字符串
     */
    public String generateToken(Long userId, String username, String role, boolean rememberMe) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("role", role);
        claims.put("renewed", false);
        // 根据是否记住我来决定Token有效期
        long tokenExpiration = rememberMe ? refreshExpiration : expiration;
        return createToken(claims, tokenExpiration);
    }

    /**
     * 生成游客临时访问Token
     * 游客Token与普通用户Token的区别：
     * - 角色固定为GUEST
     * - 包含续期次数限制信息
     * - 有效期可自定义
     *
     * @param userId 游客临时用户ID
     * @param username 游客用户名
     * @param expirationMs Token有效期（毫秒）
     * @param renewLimit 最大允许续期次数
     * @param renewCount 当前已续期次数
     * @return 生成的游客JWT Token字符串
     */
    public String generateGuestToken(Long userId, String username, long expirationMs, int renewLimit, int renewCount) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);               // 游客用户ID
        claims.put("username", username);           // 游客用户名
        claims.put("role", "GUEST");                // 固定为游客角色
        claims.put("renewLimit", renewLimit);       // 最大续期次数限制
        claims.put("renewCount", renewCount);       // 已使用的续期次数
        return createToken(claims, expirationMs);
    }

    /**
     * 续期用户Token（生成新Token替换旧Token）
     * 防止重复续期：如果Token已被续期过（renewed=true），则返回null
     * 游客Token续期后固定为7天有效期
     *
     * @param oldToken 原始的JWT Token
     * @return 新生成的Token，如果已续期过或解析失败则返回null
     */
    public String renewToken(String oldToken) {
        // 解析旧Token获取载荷信息
        Claims claims = parseToken(oldToken);
        // 检查是否已经续期过
        Boolean renewed = claims.get("renewed", Boolean.class);
        if (renewed != null && renewed) {
            return null;  // 已经续期过，拒绝再次续期
        }

        // 构建新的Token载荷
        Map<String, Object> newClaims = new HashMap<>();
        Long userId = claims.get("userId", Long.class);
        String guestId = claims.get("guestId", String.class);
        String username = claims.get("username", String.class);
        String role = claims.get("role", String.class);

        newClaims.put("role", role);
        newClaims.put("renewed", true);  // 标记为已续期

        // 根据角色类型生成不同有效期的新Token
        if ("GUEST".equals(role)) {
            // 游客Token续期后固定为7天有效期
            newClaims.put("guestId", guestId);
            return createToken(newClaims, 7 * 24 * 60 * 60 * 1000L);
        } else {
            // 普通用户Token续期后恢复标准有效期
            newClaims.put("userId", userId);
            newClaims.put("username", username);
            return createToken(newClaims, expiration);
        }
    }

    /**
     * 续期游客Token（增加续期计数）
     * 用于游客在达到最大续期次数前的续期操作
     *
     * @param oldToken 当前的游客Token
     * @param expirationMs 新Token的有效期（毫秒）
     * @param renewLimit 最大允许续期次数
     * @param renewCount 更新后的续期次数（原次数+1）
     * @return 新生成的游客Token
     */
    public String renewGuestToken(String oldToken, long expirationMs, int renewLimit, int renewCount) {
        Claims claims = parseToken(oldToken);
        Long userId = claims.get("userId", Long.class);
        String username = claims.get("username", String.class);
        return generateGuestToken(userId, username, expirationMs, renewLimit, renewCount);
    }

    /**
     * 创建JWT Token的核心方法
     * 设置签发时间、过期时间，并使用HS256算法签名
     *
     * @param claims Token载荷数据（包含用户信息等）
     * @param expirationMs Token有效期（毫秒）
     * @return 完整的JWT Token字符串
     */
    private String createToken(Map<String, Object> claims, long expirationMs) {
        Date now = new Date();                                    // 当前时间（签发时间）
        Date expiryDate = new Date(now.getTime() + expirationMs); // 过期时间 = 当前时间 + 有效期
        return Jwts.builder()
                .setClaims(claims)                                // 设置载荷数据
                .setIssuedAt(now)                                 // 设置签发时间
                .setExpiration(expiryDate)                        // 设置过期时间
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)  // 使用HS256算法签名
                .compact();                                       // 生成紧凑格式的Token
    }

    /**
     * 解析JWT Token并获取载荷（Claims）
     * 会验证Token签名和格式，如果无效会抛出异常
     *
     * @param token JWT Token字符串
     * @return Token的载荷对象，包含所有声明数据
     * @throws Exception Token无效、过期或签名不匹配时抛出异常
     */
    public Claims parseToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())  // 设置验证签名所需的密钥
                .build()
                .parseClaimsJws(token)            // 解析并验证Token
                .getBody();                       // 返回载荷部分
    }

    /**
     * 验证Token是否有效（只验证格式和签名，不检查过期时间）
     *
     * @param token JWT Token字符串
     * @return true-Token有效，false-Token无效或解析失败
     */
    public boolean validateToken(String token) {
        try {
            parseToken(token);  // 尝试解析Token，如果抛出异常则说明无效
            return true;
        } catch (Exception e) {
            return false;  // 解析过程中任何异常都视为Token无效
        }
    }

    /**
     * 从Token中提取用户ID
     *
     * @param token JWT Token字符串
     * @return 用户ID（Long类型），如果不存在返回null
     */
    public Long getUserId(String token) {
        Claims claims = parseToken(token);
        return claims.get("userId", Long.class);
    }

    /**
     * 从Token中提取游客ID
     * 仅对游客Token有效
     *
     * @param token JWT Token字符串
     * @return 游客ID（String类型），如果不存在返回null
     */
    public String getGuestId(String token) {
        Claims claims = parseToken(token);
        return claims.get("guestId", String.class);
    }

    /**
     * 从Token中提取用户名
     *
     * @param token JWT Token字符串
     * @return 用户名字符串
     */
    public String getUsername(String token) {
        Claims claims = parseToken(token);
        return claims.get("username", String.class);
    }

    /**
     * 从Token中提取用户角色
     *
     * @param token JWT Token字符串
     * @return 角色字符串（USER/ADMIN/GUEST）
     */
    public String getRole(String token) {
        Claims claims = parseToken(token);
        return claims.get("role", String.class);
    }

    /**
     * 检查Token是否已过期
     *
     * @param token JWT Token字符串
     * @return true-已过期或无效，false-未过期
     */
    public boolean isTokenExpired(String token) {
        try {
            Claims claims = parseToken(token);
            return claims.getExpiration().before(new Date());  // 过期时间是否在当前时间之前
        } catch (Exception e) {
            return true;  // 解析失败视为已过期
        }
    }

    /**
     * 获取Token的过期时间戳（毫秒）
     *
     * @param token JWT Token字符串
     * @return 过期时间的毫秒时间戳
     */
    public long getExpirationTime(String token) {
        return parseToken(token).getExpiration().getTime();
    }

    /**
     * 计算Token剩余有效时长（毫秒）
     * 如果已过期则返回0
     *
     * @param token JWT Token字符串
     * @return 剩余有效时长（毫秒），最小为0
     */
    public long getRemainingValidityMillis(String token) {
        return Math.max(getExpirationTime(token) - System.currentTimeMillis(), 0L);
    }

    /**
     * 获取游客Token的已续期次数
     * 用于判断游客是否还可以继续续期
     *
     * @param token JWT Token字符串
     * @return 已续期次数（整数），解析失败返回0
     */
    public int getGuestRenewCount(String token) {
        Object renewCount = parseToken(token).get("renewCount");
        // 支持数字类型和字符串类型的兼容处理
        if (renewCount instanceof Number number) {
            return number.intValue();
        }
        if (renewCount instanceof String value && !value.isBlank()) {
            return Integer.parseInt(value);
        }
        return 0;
    }
}
