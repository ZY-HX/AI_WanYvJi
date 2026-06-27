package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.PageResponse;
import com.english.dto.WordCreateRequest;
import com.english.dto.WordImportResponse;
import com.english.dto.WordResponse;
import com.english.dto.WordUpdateRequest;
import com.english.service.AdminWordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;

@Tag(name = "管理端-词库单词管理", description = "管理员管理词库中的单词")
@Validated
@RestController
@RequestMapping("/api/admin/words")
@RequiredArgsConstructor
public class AdminWordController {

    private final AdminWordService adminWordService;

    @Operation(summary = "分页查询词库中的单词列表")
    @GetMapping
    public Result<PageResponse<WordResponse>> getWords(
            Authentication authentication,
            @RequestParam @NotNull(message = "词库ID不能为空") Long wordBankId,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size
    ) {
        requireAdmin(authentication);
        return Result.success("获取单词列表成功", adminWordService.getWordsByWordBankId(wordBankId, current, size));
    }

    @Operation(summary = "获取单词详情")
    @GetMapping("/{wordId}")
    public Result<WordResponse> getWordDetail(
            Authentication authentication,
            @PathVariable Long wordId
    ) {
        requireAdmin(authentication);
        return Result.success("获取单词详情成功", adminWordService.getWordDetail(wordId));
    }

    @Operation(summary = "添加单词到词库")
    @PostMapping
    public Result<WordResponse> createWord(
            Authentication authentication,
            HttpServletRequest request,
            @RequestParam @NotNull(message = "词库ID不能为空") Long wordBankId,
            @Valid @RequestBody WordCreateRequest createRequest
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        String ipAddress = resolveIp(request);
        WordResponse response = adminWordService.createWord(admin.getUserId(), wordBankId, createRequest, ipAddress);
        return Result.success("添加单词成功", response);
    }

    @Operation(summary = "更新单词信息")
    @PutMapping("/{wordId}")
    public Result<WordResponse> updateWord(
            Authentication authentication,
            HttpServletRequest request,
            @PathVariable Long wordId,
            @Valid @RequestBody WordUpdateRequest updateRequest
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        String ipAddress = resolveIp(request);
        WordResponse response = adminWordService.updateWord(admin.getUserId(), wordId, updateRequest, ipAddress);
        return Result.success("更新单词成功", response);
    }

    @Operation(summary = "删除单词")
    @DeleteMapping("/{wordId}")
    public Result<Void> deleteWord(
            Authentication authentication,
            HttpServletRequest request,
            @PathVariable Long wordId
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        String ipAddress = resolveIp(request);
        adminWordService.deleteWord(admin.getUserId(), wordId, ipAddress);
        return Result.success("删除单词成功", null);
    }

    @Operation(summary = "通过TXT文件批量导入单词")
    @PostMapping("/import")
    public Result<WordImportResponse> importWords(
            Authentication authentication,
            HttpServletRequest request,
            @RequestParam @NotNull(message = "词库ID不能为空") Long wordBankId,
            @RequestParam("file") MultipartFile file
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        String ipAddress = resolveIp(request);
        WordImportResponse response = adminWordService.importWordsFromFile(admin.getUserId(), wordBankId, file, ipAddress);
        return Result.success("批量导入完成", response);
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
