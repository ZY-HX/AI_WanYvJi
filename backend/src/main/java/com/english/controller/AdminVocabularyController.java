package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.PageResponse;
import com.english.dto.VocabularyCreateRequest;
import com.english.dto.VocabularyUpdateRequest;
import com.english.dto.WordBankResponse;
import com.english.service.AdminVocabularyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

@Tag(name = "管理端-公共词库管理", description = "管理员发布和管理公共词库")
@Validated
@RestController
@RequestMapping("/api/admin/vocabularies")
@RequiredArgsConstructor
public class AdminVocabularyController {

    private final AdminVocabularyService adminVocabularyService;

    @Operation(summary = "分页查询所有公共词库")
    @GetMapping
    public Result<PageResponse<WordBankResponse>> getPublicVocabularies(
            Authentication authentication,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size
    ) {
        requireAdmin(authentication);
        return Result.success("获取公共词库列表成功", adminVocabularyService.getPublicVocabularies(current, size));
    }

    @Operation(summary = "获取公共词库详情")
    @GetMapping("/{id}")
    public Result<WordBankResponse> getVocabularyDetail(
            Authentication authentication,
            @PathVariable Long id
    ) {
        requireAdmin(authentication);
        return Result.success("获取词库详情成功", adminVocabularyService.getVocabularyDetail(id));
    }

    @Operation(summary = "发布新的公共词库")
    @PostMapping
    public Result<WordBankResponse> createPublicVocabulary(
            Authentication authentication,
            HttpServletRequest request,
            @Valid @RequestBody VocabularyCreateRequest createRequest
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        String ipAddress = resolveIp(request);
        WordBankResponse response = adminVocabularyService.createPublicVocabulary(admin.getUserId(), createRequest, ipAddress);
        return Result.success("发布公共词库成功", response);
    }

    @Operation(summary = "更新公共词库信息")
    @PutMapping("/{id}")
    public Result<WordBankResponse> updatePublicVocabulary(
            Authentication authentication,
            HttpServletRequest request,
            @PathVariable Long id,
            @Valid @RequestBody VocabularyUpdateRequest updateRequest
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        String ipAddress = resolveIp(request);
        WordBankResponse response = adminVocabularyService.updatePublicVocabulary(admin.getUserId(), id, updateRequest, ipAddress);
        return Result.success("更新公共词库成功", response);
    }

    @Operation(summary = "删除公共词库")
    @DeleteMapping("/{id}")
    public Result<Void> deletePublicVocabulary(
            Authentication authentication,
            HttpServletRequest request,
            @PathVariable Long id
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        String ipAddress = resolveIp(request);
        adminVocabularyService.deletePublicVocabulary(admin.getUserId(), id, ipAddress);
        return Result.success("删除公共词库成功", null);
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
