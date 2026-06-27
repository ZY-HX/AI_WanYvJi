package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.PageResponse;
import com.english.dto.SensitiveWordRequest;
import com.english.dto.SensitiveWordResponse;
import com.english.service.AdminSensitiveWordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "管理端-敏感词管理", description = "管理员维护敏感词列表")
@Validated
@RestController
@RequestMapping("/api/admin/sensitive-words")
@RequiredArgsConstructor
public class AdminSensitiveWordController {

    private final AdminSensitiveWordService adminSensitiveWordService;

    @Operation(summary = "分页查询敏感词列表")
    @GetMapping
    public Result<PageResponse<SensitiveWordResponse>> getSensitiveWords(
            Authentication authentication,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword
    ) {
        requireAdmin(authentication);
        return Result.success(
                "获取敏感词列表成功",
                adminSensitiveWordService.getSensitiveWords(current, size, status, keyword)
        );
    }

    @Operation(summary = "新增敏感词")
    @PostMapping
    public Result<SensitiveWordResponse> createSensitiveWord(
            Authentication authentication,
            HttpServletRequest request,
            @Valid @RequestBody SensitiveWordRequest sensitiveWordRequest
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        SensitiveWordResponse response = adminSensitiveWordService.createSensitiveWord(
                admin.getUserId(),
                sensitiveWordRequest,
                resolveIp(request)
        );
        return Result.success("新增敏感词成功", response);
    }

    @Operation(summary = "修改敏感词")
    @PutMapping("/{id}")
    public Result<SensitiveWordResponse> updateSensitiveWord(
            Authentication authentication,
            HttpServletRequest request,
            @PathVariable Long id,
            @Valid @RequestBody SensitiveWordRequest sensitiveWordRequest
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        SensitiveWordResponse response = adminSensitiveWordService.updateSensitiveWord(
                admin.getUserId(),
                id,
                sensitiveWordRequest,
                resolveIp(request)
        );
        return Result.success("更新敏感词成功", response);
    }

    @Operation(summary = "删除敏感词")
    @DeleteMapping("/{id}")
    public Result<Void> deleteSensitiveWord(
            Authentication authentication,
            HttpServletRequest request,
            @PathVariable Long id
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        adminSensitiveWordService.deleteSensitiveWord(admin.getUserId(), id, resolveIp(request));
        return Result.success("删除敏感词成功", null);
    }

    private AuthenticatedUser requireAdmin(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问管理端接口");
        }
        if (!"ADMIN".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "仅管理员可访问");
        }
        return authenticatedUser;
    }

    private String resolveIp(HttpServletRequest request) {
        if (request == null) {
            return "unknown";
        }
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            String first = forwarded.split(",")[0].trim();
            if (!first.isBlank()) {
                return first;
            }
        }
        String realIp = request.getHeader("X-Real-IP");
        if (realIp != null && !realIp.isBlank()) {
            return realIp.trim();
        }
        return request.getRemoteAddr();
    }
}
