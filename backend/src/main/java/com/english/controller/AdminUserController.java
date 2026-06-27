package com.english.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AdminUserDetailResponse;
import com.english.dto.AdminUserItemResponse;
import com.english.dto.AuthenticatedUser;
import com.english.dto.PageResponse;
import com.english.entity.User;
import com.english.entity.UserStudyRecord;
import com.english.mapper.UserMapper;
import com.english.mapper.UserStudyRecordMapper;
import com.english.service.UserStudyPlanService;
import org.springframework.jdbc.core.JdbcTemplate;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Tag(name = "管理端-用户管理", description = "管理员查看和管理用户列表")
@Validated
@Slf4j
@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final UserMapper userMapper;
    private final UserStudyRecordMapper studyRecordMapper;
    private final UserStudyPlanService studyPlanService;
    private final JdbcTemplate jdbcTemplate;

    @Operation(summary = "获取用户列表（支持筛选和分页）")
    @GetMapping
    public Result<PageResponse<AdminUserItemResponse>> getUsers(
            Authentication authentication,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) LocalDate startDate,
            @RequestParam(required = false) LocalDate endDate,
            @RequestParam(required = false) String keyword
    ) {
        requireAdmin(authentication);

        Page<User> page = new Page<>(current, size);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();

        if (status != null) {
            wrapper.eq(User::getStatus, status);
        }

        if (startDate != null) {
            wrapper.ge(User::getCreatedAt, startDate.atStartOfDay());
        }

        if (endDate != null) {
            wrapper.lt(User::getCreatedAt, endDate.plusDays(1).atStartOfDay());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.and(w -> w
                    .like(User::getUsername, keyword.trim())
                    .or()
                    .like(User::getNickname, keyword.trim())
                    .or()
                    .like(User::getEmail, keyword.trim())
                    .or()
                    .like(User::getPhone, keyword.trim())
            );
        }

        wrapper.orderByDesc(User::getCreatedAt);

        Page<User> userPage = userMapper.selectPage(page, wrapper);

        PageResponse<AdminUserItemResponse> response = new PageResponse<>();
        response.setCurrent(userPage.getCurrent());
        response.setSize(userPage.getSize());
        response.setTotal(userPage.getTotal());
        response.setRecords(
                userPage.getRecords().stream()
                        .map(this::toUserItemResponse)
                        .toList()
        );

        return Result.success("获取用户列表成功", response);
    }

    @Operation(summary = "获取用户详细信息（含学习数据）")
    @GetMapping("/{userId}")
    public Result<AdminUserDetailResponse> getUserDetail(
            Authentication authentication,
            @PathVariable Long userId
    ) {
        requireAdmin(authentication);

        User user = userMapper.selectByIdIncludingDeleted(userId);
        if (user == null) {
            throw new BusinessException(404, "用户不存在");
        }

        AdminUserDetailResponse response = new AdminUserDetailResponse();
        response.setUserId(user.getId());
        response.setUsername(user.getUsername());
        response.setNickname(user.getNickname());
        response.setEmail(user.getEmail());
        response.setPhone(user.getPhone());
        response.setAvatarUrl(user.getAvatarUrl());
        response.setRole(user.getRole());
        response.setStatus(user.getStatus());
        response.setCreatedAt(user.getCreatedAt());
        response.setUpdatedAt(user.getUpdatedAt());
        response.setLoginFailCount(user.getLoginFailCount());

        // 获取学习计划配置
        UserStudyPlanService.StudyPlanSettings plan = studyPlanService.getPlan(userId);
        if (plan != null) {
            response.setStudySessionSize(plan.studySessionSize());
            response.setAllowSameDayReview(plan.allowSameDayReview());
        }

        // 统计学习数据
        LambdaQueryWrapper<UserStudyRecord> recordWrapper = new LambdaQueryWrapper<>();
        recordWrapper.eq(UserStudyRecord::getUserId, userId);

        Long totalRecords = studyRecordMapper.selectCount(recordWrapper);

        // 总学习次数（所有记录数）
        response.setTotalStudySessions(totalRecords != null ? totalRecords : 0L);

        // 学习的总单词数（去重）
        Long totalWordsLearned;
        try {
            Long count = jdbcTemplate.queryForObject(
                    "SELECT COUNT(DISTINCT word_id) FROM user_study_record WHERE user_id = ?",
                    Long.class,
                    userId
            );
            totalWordsLearned = count == null ? 0L : count;
        } catch (Exception e) {
            log.warn("统计用户学习单词数失败 userId={}", userId, e);
            totalWordsLearned = totalRecords != null ? totalRecords : 0L;
        }
        response.setTotalWordsLearned(totalWordsLearned);

        // 使用JdbcTemplate查询统计数据（更可靠的方式）
        long totalCorrect = 0L;
        long totalWrong = 0L;
        try {
            java.util.Map<String, Object> statsMap = jdbcTemplate.queryForMap(
                    "SELECT IFNULL(SUM(correct_count), 0) as total_correct, " +
                    "IFNULL(SUM(wrong_count), 0) as total_wrong FROM user_study_record WHERE user_id = ?",
                    userId
            );
            Object correctObj = statsMap.get("total_correct");
            Object wrongObj = statsMap.get("total_wrong");
            if (correctObj instanceof Number) {
                totalCorrect = ((Number) correctObj).longValue();
            }
            if (wrongObj instanceof Number) {
                totalWrong = ((Number) wrongObj).longValue();
            }
        } catch (Exception e) {
            log.warn("统计用户答题正确/错误次数失败 userId={}", userId, e);
        }

        response.setTotalCorrectCount(totalCorrect);
        response.setTotalWrongCount(totalWrong);

        // 计算正确率
        long totalAttempts = totalCorrect + totalWrong;
        if (totalAttempts > 0) {
            double accuracy = (double) totalCorrect / totalAttempts * 100;
            response.setAccuracyRate(BigDecimal.valueOf(accuracy).setScale(1, RoundingMode.HALF_UP).doubleValue());
        } else {
            response.setAccuracyRate(0.0);
        }

        // 待复习单词数（有下次复习时间且未到期的记录）
        LocalDateTime now = LocalDateTime.now();
        Long pendingReviewCount = studyRecordMapper.selectCount(
                new LambdaQueryWrapper<UserStudyRecord>()
                        .eq(UserStudyRecord::getUserId, userId)
                        .isNotNull(UserStudyRecord::getNextReviewTime)
                        .le(UserStudyRecord::getNextReviewTime, now)
                        .eq(UserStudyRecord::getStatus, 1)
        );
        response.setPendingReviewCount(pendingReviewCount);

        // 已掌握单词数（连续正确3次以上的单词）
        Long masteredCount;
        try {
            Long count = jdbcTemplate.queryForObject(
                    "SELECT COUNT(DISTINCT word_id) FROM user_study_record WHERE user_id = ? AND correct_count >= 3",
                    Long.class,
                    userId
            );
            masteredCount = count == null ? 0L : count;
        } catch (Exception e) {
            log.warn("统计用户已掌握单词数失败 userId={}", userId, e);
            masteredCount = 0L;
        }
        response.setMasteredWordCount(masteredCount);

        return Result.success("获取用户详情成功", response);
    }

    @Operation(summary = "启用/禁用用户")
    @PutMapping("/{userId}/status")
    public Result<Void> updateUserStatus(
            Authentication authentication,
            @PathVariable Long userId,
            @RequestParam Integer status
    ) {
        requireAdmin(authentication);

        if (status != 1 && status != 2) {
            throw new BusinessException(400, "状态值无效：1-正常，2-禁用");
        }

        User user = userMapper.selectByIdIncludingDeleted(userId);
        if (user == null) {
            throw new BusinessException(404, "用户不存在");
        }

        if ("ADMIN".equals(user.getRole())) {
            throw new BusinessException(400, "不能禁用管理员账号");
        }

        int rows = userMapper.updateStatusById(userId, status);

        System.out.println("===== 管理员操作：更新用户状态 =====");
        System.out.println("用户ID: " + userId + ", 新状态: " + status + ", 影响行数: " + rows);

        if (rows > 0) {
            String action = status == 2 ? "禁用" : "启用";
            return Result.success("用户已" + action, null);
        } else {
            throw new BusinessException(500, "更新用户状态失败");
        }
    }

    private AdminUserItemResponse toUserItemResponse(User user) {
        AdminUserItemResponse response = new AdminUserItemResponse();
        response.setId(user.getId());
        response.setUsername(user.getUsername());
        response.setNickname(user.getNickname());
        response.setEmail(user.getEmail());
        response.setPhone(user.getPhone());
        response.setAvatarUrl(user.getAvatarUrl());
        response.setRole(user.getRole());
        response.setStatus(user.getStatus());
        response.setCreatedAt(user.getCreatedAt());
        response.setUpdatedAt(user.getUpdatedAt());
        return response;
    }

    private AuthenticatedUser requireAdmin(Authentication authentication) {
        if (authentication == null) {
            throw new BusinessException(401, "请先登录");
        }
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问管理端接口");
        }
        if (!"ADMIN".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "仅管理员可访问");
        }
        return authenticatedUser;
    }
}
