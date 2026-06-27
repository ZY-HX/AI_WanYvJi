package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.PageResponse;
import com.english.dto.WordBankCreateRequest;
import com.english.dto.WordImportResponse;
import com.english.dto.WordBankResponse;
import com.english.dto.WordBankUpdateRequest;
import com.english.service.WordBankService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "我的词库", description = "当前登录用户的词库增删改查接口")
@Validated
@RestController
@RequestMapping("/api/wordbanks")
@RequiredArgsConstructor
public class WordBankController {

    private final WordBankService wordBankService;

    @Operation(summary = "分页获取当前用户创建的词库列表")
    @GetMapping
    public Result<PageResponse<WordBankResponse>> getCurrentUserWordBanks(
            Authentication authentication,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size,
            @RequestParam(required = false) String language
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取我的词库成功",
                wordBankService.getCurrentUserWordBanks(currentUser.getUserId(), current, size, language));
    }

    @Operation(summary = "分页搜索公开词库")
    @GetMapping("/public")
    public Result<PageResponse<WordBankResponse>> getPublicWordBanks(
            Authentication authentication,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String language
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取公开词库成功",
                wordBankService.getPublicWordBanks(currentUser.getUserId(), current, size, keyword, language));
    }

    @Operation(summary = "分页获取当前用户收藏的词库列表")
    @GetMapping("/collected")
    public Result<PageResponse<WordBankResponse>> getCollectedWordBanks(
            Authentication authentication,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size,
            @RequestParam(required = false) String language
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取收藏词库成功",
                wordBankService.getCollectedWordBanks(currentUser.getUserId(), current, size, language));
    }

    @Operation(summary = "获取词库详情")
    @GetMapping("/{id}")
    public Result<WordBankResponse> getWordBankDetail(
            Authentication authentication,
            @PathVariable Long id
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取词库详情成功",
                wordBankService.getWordBankDetail(currentUser.getUserId(), id));
    }

    @Operation(summary = "创建新词库")
    @PostMapping
    public Result<WordBankResponse> createWordBank(
            Authentication authentication,
            @Valid @RequestBody WordBankCreateRequest request
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        return Result.success("创建词库成功",
                wordBankService.createWordBank(currentUser.getUserId(), request));
    }

    @Operation(summary = "更新词库名称和描述")
    @PutMapping("/{id}")
    public Result<WordBankResponse> updateWordBank(
            Authentication authentication,
            @PathVariable Long id,
            @Valid @RequestBody WordBankUpdateRequest request
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        return Result.success("更新词库成功",
                wordBankService.updateWordBank(currentUser.getUserId(), id, request));
    }

    @Operation(summary = "软删除词库")
    @DeleteMapping("/{id}")
    public Result<Void> deleteWordBank(
            Authentication authentication,
            @PathVariable Long id
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        wordBankService.deleteWordBank(currentUser.getUserId(), id);
        return Result.success("删除词库成功", null);
    }

    @Operation(summary = "导入 TXT 单词到指定词库")
    @PostMapping(value = "/{id}/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Result<WordImportResponse> importWords(
            Authentication authentication,
            @PathVariable Long id,
            @RequestPart("file") MultipartFile file
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        WordImportResponse response = wordBankService.importWords(currentUser.getUserId(), id, file);
        return Result.success("TXT 导入完成", response);
    }

    @Operation(summary = "提交词库公开审核")
    @PostMapping("/{id}/submit-review")
    public Result<WordBankResponse> submitWordBankReview(
            Authentication authentication,
            @PathVariable Long id
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        return Result.success("词库已提交审核，请等待管理员处理",
                wordBankService.submitWordBankReview(currentUser.getUserId(), id));
    }

    @Operation(summary = "收藏公开词库")
    @PostMapping("/{id}/collect")
    public Result<Void> collectWordBank(
            Authentication authentication,
            @PathVariable Long id
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        wordBankService.collectWordBank(currentUser.getUserId(), id);
        return Result.success("收藏词库成功", null);
    }

    @Operation(summary = "取消收藏公开词库")
    @DeleteMapping("/{id}/collect")
    public Result<Void> cancelCollectWordBank(
            Authentication authentication,
            @PathVariable Long id
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        wordBankService.cancelCollectWordBank(currentUser.getUserId(), id);
        return Result.success("取消收藏成功", null);
    }

    private AuthenticatedUser requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问词库");
        }
        return authenticatedUser;
    }

    private AuthenticatedUser requireEditableUser(Authentication authentication) {
        AuthenticatedUser authenticatedUser = requireCurrentUser(authentication);
        if ("GUEST".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "游客模式不支持创建或编辑自定义词库");
        }
        return authenticatedUser;
    }
}
