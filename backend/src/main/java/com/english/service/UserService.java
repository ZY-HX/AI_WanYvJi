package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.english.common.BusinessException;
import com.english.dto.LoginLockStatusResponse;
import com.english.dto.ChangePasswordRequest;
import com.english.dto.UpdateProfileRequest;
import com.english.entity.User;
import com.english.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 用户服务类
 * 提供用户管理的核心业务逻辑，包括：
 * - 用户注册（普通用户和游客用户）
 * - 用户登录认证
 * - 密码修改和个人信息更新
 * - 账户安全保护（登录失败锁定机制）
 * - 头像上传处理
 *
 * 使用Spring的@Service注解标记为服务层组件
 * 使用@RequiredArgsConstructor自动通过构造函数注入依赖
 */
@Service
@RequiredArgsConstructor
public class UserService {

    /** 最大允许连续登录失败次数，超过此次数将锁定账户 */
    private static final int MAX_LOGIN_FAIL_COUNT = 5;
    /** 账户锁定时长（分钟），超过此时间后自动解锁 */
    private static final int LOCK_MINUTES = 10;

    /** 用户数据访问对象 */
    private final UserMapper userMapper;
    /** 密码编码器（BCrypt算法） */
    private final PasswordEncoder passwordEncoder;

    /**
     * 根据用户名查询用户
     *
     * @param username 用户名（唯一）
     * @return 用户实体对象，如果不存在返回null
     */
    public User getByUsername(String username) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username);
        return userMapper.selectOne(wrapper);
    }

    /**
     * 根据邮箱地址查询用户
     *
     * @param email 邮箱地址（唯一）
     * @return 用户实体对象，如果不存在返回null
     */
    public User getByEmail(String email) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getEmail, email);
        return userMapper.selectOne(wrapper);
    }

    /**
     * 根据用户ID查询用户
     *
     * @param id 用户ID（主键）
     * @return 用户实体对象，如果不存在返回null
     */
    public User getById(Long id) {
        return userMapper.selectById(id);
    }

    /**
     * 根据用户ID查询已存在的有效用户
     * 如果用户不存在或已被删除则抛出业务异常
     *
     * @param id 用户ID
     * @return 用户实体对象
     * @throws BusinessException 当用户不存在或已删除时抛出404异常
     */
    public User getExistingById(Long id) {
        User user = getById(id);
        if (user == null || user.getStatus() == 0) {
            throw new BusinessException(404, "用户不存在");
        }
        return user;
    }

    /**
     * 注册新用户（普通注册用户）
     * 执行以下操作：
     * 1. 检查用户名是否已存在
     * 2. 检查邮箱是否已被注册
     * 3. 创建用户对象并设置默认值
     * 4. 使用BCrypt加密密码后保存到数据库
     *
     * @param username 用户名（必填，唯一）
     * @param password 明文密码（将被加密存储）
     * @param email 邮箱地址（必填，唯一）
     * @param nickname 昵称（可选，为空时使用用户名作为默认昵称）
     * @throws BusinessException 当用户名或邮箱已存在时抛出400异常
     */
    @Transactional(rollbackFor = Exception.class)
    public void register(String username, String password, String email, String nickname) {
        // 去除首尾空白字符
        String normalizedUsername = StringUtils.trimWhitespace(username);
        String normalizedEmail = StringUtils.trimWhitespace(email);

        // 检查用户名是否已被占用
        if (getByUsername(normalizedUsername) != null) {
            throw new BusinessException(400, "用户名已存在");
        }
        // 检查邮箱是否已被注册
        if (getByEmail(normalizedEmail) != null) {
            throw new BusinessException(400, "邮箱已被注册");
        }

        // 构建新用户对象
        User user = new User();
        user.setUsername(normalizedUsername);
        // 使用BCrypt算法加密密码（不可逆）
        user.setPassword(passwordEncoder.encode(password));
        user.setEmail(normalizedEmail);
        // 如果昵称为空或只有空白字符，则使用用户名作为默认昵称
        String normalizedNickname = StringUtils.trimWhitespace(nickname);
        user.setNickname(StringUtils.hasText(normalizedNickname) ? normalizedNickname : normalizedUsername);
        user.setRole("USER");           // 默认角色为普通用户
        user.setStatus(1);               // 状态：1-正常
        user.setLoginFailCount(0);       // 初始登录失败次数为0
        user.setVersion(0);              // 初始乐观锁版本号为0

        // 插入数据库
        userMapper.insert(user);
    }

    /**
     * 创建游客用户
     * 游客用户的特征：
     * - 自动生成随机用户名（guest_前缀+12位UUID）
     * - 邮箱使用虚拟域名（@guest.local）
     * - 昵称显示为"游客"+6位随机码
     * - 角色为GUEST，权限受限
     * - Token有有效期和续期次数限制
     *
     * @return 新创建的游客用户实体对象
     */
    @Transactional(rollbackFor = Exception.class)
    public User createGuestUser() {
        // 生成随机后缀（去掉UUID中的连字符）
        String suffix = UUID.randomUUID().toString().replace("-", "");
        // 构建游客用户名：guest_ + 12位随机字符
        String username = "guest_" + suffix.substring(0, 12);

        User user = new User();
        user.setUsername(username);
        // 生成随机密码（游客不会使用密码登录）
        user.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
        // 使用虚拟邮箱域名
        user.setEmail(username + "@guest.local");
        // 设置游客昵称
        user.setNickname("游客" + suffix.substring(0, 6));
        user.setRole("GUEST");          // 游客角色
        user.setStatus(1);              // 正常状态
        user.setLoginFailCount(0);
        user.setVersion(0);

        // 保存到数据库
        userMapper.insert(user);
        return user;
    }

    public User login(String username, String password) {
        String loginAccount = StringUtils.trimWhitespace(username);
        for (int attempt = 0; attempt < 3; attempt++) {
            LocalDateTime now = LocalDateTime.now();
            User user = findByLoginAccount(loginAccount);
            if (user == null) {
                throw new BusinessException(400, "用户名或密码错误");
            }

            if (user.getStatus() != 1) {
                if (user.getStatus() == 0) {
                    throw new BusinessException(403, "账号已被删除");
                } else if (user.getStatus() == 2) {
                    throw new BusinessException(403, "账号已被管理员禁用，请联系客服解封");
                } else {
                    throw new BusinessException(403, "账号状态异常，无法登录");
                }
            }

            if (isLocked(user, now)) {
                throw buildLockException(user.getLockTime(), now, "账号已被锁定");
            }

            if (!passwordEncoder.matches(password, user.getPassword())) {
                int failCount = safeFailCount(user) + 1;
                user.setLoginFailCount(failCount);
                if (failCount >= MAX_LOGIN_FAIL_COUNT) {
                    LocalDateTime lockUntil = now.plusMinutes(LOCK_MINUTES);
                    user.setLockTime(lockUntil);
                    if (userMapper.updateById(user) == 0 && attempt < 2) {
                        continue;
                    }
                    throw buildLockException(lockUntil, now, "登录失败5次，账号已锁定");
                }
                if (userMapper.updateById(user) == 0 && attempt < 2) {
                    continue;
                }
                throw new BusinessException(400, "用户名或密码错误");
            }

            user.setLoginFailCount(0);
            user.setLockTime(null);
            if (userMapper.updateById(user) == 0 && attempt < 2) {
                continue;
            }
            return userMapper.selectById(user.getId());
        }
        throw new BusinessException(409, "登录请求冲突，请稍后重试");
    }

    private User findByLoginAccount(String loginAccount) {
        User user = getByUsername(loginAccount);
        if (user == null) {
            return getByEmail(loginAccount);
        }
        return user;
    }

    private boolean isLocked(User user, LocalDateTime now) {
        return user.getLockTime() != null && user.getLockTime().isAfter(now);
    }

    private int safeFailCount(User user) {
        return user.getLoginFailCount() == null ? 0 : user.getLoginFailCount();
    }

    private BusinessException buildLockException(LocalDateTime lockUntil, LocalDateTime now, String prefix) {
        long remainingSeconds = calculateRemainingLockSeconds(lockUntil, now);
        String remainingText = formatRemainingLockTime(remainingSeconds);

        LoginLockStatusResponse response = new LoginLockStatusResponse();
        response.setLocked(true);
        response.setRemainingLockSeconds(remainingSeconds);
        response.setRemainingLockTimeText(remainingText);
        response.setLockUntil(lockUntil);

        return new BusinessException(403, prefix + "，剩余锁定时间：" + remainingText, response);
    }

    private long calculateRemainingLockSeconds(LocalDateTime lockUntil, LocalDateTime now) {
        Duration duration = Duration.between(now, lockUntil);
        if (duration.isNegative() || duration.isZero()) {
            return 0L;
        }
        return Math.max(1L, (duration.toMillis() + 999L) / 1000L);
    }

    private String formatRemainingLockTime(long remainingSeconds) {
        long minutes = remainingSeconds / 60;
        long seconds = remainingSeconds % 60;
        return minutes + "分" + seconds + "秒";
    }

    @Transactional(rollbackFor = Exception.class)
    public User updateProfile(Long userId, UpdateProfileRequest request) {
        User user = getExistingById(userId);

        String normalizedUsername = StringUtils.trimWhitespace(request.getUsername());
        String normalizedEmail = StringUtils.trimWhitespace(request.getEmail());
        String normalizedNickname = StringUtils.trimWhitespace(request.getNickname());

        User usernameOwner = getByUsername(normalizedUsername);
        if (usernameOwner != null && !usernameOwner.getId().equals(userId)) {
            throw new BusinessException(400, "用户名已存在");
        }

        User emailOwner = getByEmail(normalizedEmail);
        if (emailOwner != null && !emailOwner.getId().equals(userId)) {
            throw new BusinessException(400, "邮箱已被注册");
        }

        user.setUsername(normalizedUsername);
        user.setEmail(normalizedEmail);
        user.setNickname(StringUtils.hasText(normalizedNickname) ? normalizedNickname : normalizedUsername);
        userMapper.updateById(user);
        return getExistingById(userId);
    }

    @Transactional(rollbackFor = Exception.class)
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = getExistingById(userId);

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new BusinessException(400, "旧密码错误");
        }
        if (request.getOldPassword().equals(request.getNewPassword())) {
            throw new BusinessException(400, "新密码不能与旧密码相同");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userMapper.updateById(user);
    }

    @Transactional(rollbackFor = Exception.class)
    public User updateAvatar(Long userId, String avatarUrl) {
        User user = getExistingById(userId);
        user.setAvatarUrl(avatarUrl);
        userMapper.updateById(user);
        return getExistingById(userId);
    }
}
