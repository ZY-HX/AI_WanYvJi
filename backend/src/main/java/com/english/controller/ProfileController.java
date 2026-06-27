package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AvatarUploadResponse;
import com.english.dto.AuthenticatedUser;
import com.english.dto.ChangePasswordRequest;
import com.english.dto.UpdateProfileRequest;
import com.english.dto.UserProfileResponse;
import com.english.entity.User;
import com.english.service.UserStudyPlanService;
import com.english.service.UserService;
import com.english.storage.FileStorageService;
import com.english.storage.StoredFile;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Set;

@Slf4j
@Tag(name = "用户资料", description = "当前登录用户信息接口")
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ProfileController {

    private static final long MAX_AVATAR_SIZE = 2 * 1024 * 1024L;
    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of(
            MediaType.IMAGE_JPEG_VALUE,
            MediaType.IMAGE_PNG_VALUE,
            "image/webp"
    );

    private final UserService userService;
    private final UserStudyPlanService userStudyPlanService;
    private final FileStorageService fileStorageService;

    @Operation(summary = "获取当前登录用户信息")
    @GetMapping("/user/profile")
    public Result<UserProfileResponse> getCurrentUser(Authentication authentication) {
        User user = requireCurrentUser(authentication);
        return Result.success("获取当前用户成功", toProfileResponse(user));
    }

    @Operation(summary = "兼容旧版的当前登录用户信息接口")
    @GetMapping("/users/me")
    public Result<UserProfileResponse> getCurrentUserCompat(Authentication authentication) {
        User user = requireCurrentUser(authentication);
        return Result.success("获取当前用户成功", toProfileResponse(user));
    }

    @Operation(summary = "更新个人资料")
    @PutMapping("/user/profile")
    public Result<UserProfileResponse> updateProfile(
            Authentication authentication,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        User user = userService.updateProfile(currentUser.getUserId(), request);
        userStudyPlanService.updatePlan(
                currentUser.getUserId(),
                request.getStudySessionSize(),
                request.getAllowSameDayReview()
        );
        return Result.success("个人资料更新成功", toProfileResponse(user));
    }

    @Operation(summary = "修改密码")
    @PostMapping("/user/change-password")
    public Result<Void> changePassword(
            Authentication authentication,
            @Valid @RequestBody ChangePasswordRequest request
    ) {
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BusinessException(400, "两次新密码输入不一致");
        }

        AuthenticatedUser currentUser = requireEditableUser(authentication);
        userService.changePassword(currentUser.getUserId(), request);
        return Result.success("密码修改成功，请重新登录", null);
    }

    @Operation(summary = "上传头像")
    @PostMapping(value = "/user/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Result<AvatarUploadResponse> uploadAvatar(
            Authentication authentication,
            @RequestPart("file") MultipartFile file
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);

        if (file.isEmpty()) {
            throw new BusinessException(400, "请选择要上传的头像文件");
        }
        if (file.getSize() > MAX_AVATAR_SIZE) {
            throw new BusinessException(400, "头像大小不能超过2MB");
        }
        if (!ALLOWED_CONTENT_TYPES.contains(file.getContentType())) {
            throw new BusinessException(400, "头像仅支持 JPG、PNG、WEBP 格式");
        }

        User existingUser = userService.getExistingById(currentUser.getUserId());
        try {
            StoredFile storedFile = fileStorageService.store(file, "avatars", "avatar_" + currentUser.getUserId());
            userService.updateAvatar(currentUser.getUserId(), storedFile.getUrl());
            deletePreviousAvatar(existingUser.getAvatarUrl(), storedFile.getUrl());
            return Result.success("头像上传成功", new AvatarUploadResponse(storedFile.getUrl()));
        } catch (IOException e) {
            log.error("头像上传失败，userId={}", currentUser.getUserId(), e);
            throw new BusinessException(500, "头像上传失败，请稍后重试", true);
        }
    }

    private User requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问用户信息");
        }
        return userService.getExistingById(authenticatedUser.getUserId());
    }

    private AuthenticatedUser requireEditableUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持执行该操作");
        }
        if ("GUEST".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "游客模式仅支持查看资料，无法修改敏感信息");
        }
        return authenticatedUser;
    }

    private UserProfileResponse toProfileResponse(User user) {
        UserStudyPlanService.StudyPlanSettings planSettings = userStudyPlanService.getPlan(user.getId());
        UserProfileResponse response = new UserProfileResponse();
        response.setUserId(user.getId());
        response.setUsername(user.getUsername());
        response.setNickname(user.getNickname());
        response.setEmail(user.getEmail());
        response.setPhone(user.getPhone());
        response.setRole(user.getRole());
        response.setAvatarUrl(user.getAvatarUrl());
        response.setStudySessionSize(planSettings.studySessionSize());
        response.setAllowSameDayReview(planSettings.allowSameDayReview());
        response.setCreatedAt(user.getCreatedAt());
        return response;
    }

    private void deletePreviousAvatar(String previousAvatarUrl, String currentAvatarUrl) {
        if (!StringUtils.hasText(previousAvatarUrl) || previousAvatarUrl.equals(currentAvatarUrl)) {
            return;
        }
        try {
            fileStorageService.delete(previousAvatarUrl);
        } catch (IOException e) {
            log.warn("清理旧头像失败，url={}", previousAvatarUrl, e);
        }
    }
}
