package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.ErrorBookResponse;
import com.english.dto.PageResponse;
import com.english.service.ErrorBookService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "错题本", description = "错题列表查询、标记掌握与批量清空接口")
@Validated
@RestController
@RequestMapping("/api/error-book")
@RequiredArgsConstructor
public class ErrorBookController {

    private final ErrorBookService errorBookService;

    @Operation(summary = "分页获取当前用户错题本列表")
    @GetMapping
    public Result<PageResponse<ErrorBookResponse>> getErrorBooks(
            Authentication authentication,
            @RequestParam(required = false) Long wordBankId,
            @RequestParam(required = false) String errorType,
            @RequestParam(name = "is_mastered", required = false) Integer isMastered,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取错题本成功",
                errorBookService.getErrorBooks(currentUser.getUserId(), wordBankId, errorType, isMastered, current, size));
    }

    @Operation(summary = "将指定错题标记为已掌握")
    @PutMapping("/{id}/master")
    public Result<Void> markMastered(
            Authentication authentication,
            @PathVariable Long id
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        errorBookService.markMastered(currentUser.getUserId(), id);
        return Result.success("已标记为掌握", null);
    }

    @Operation(summary = "按条件批量清空当前用户错题本")
    @DeleteMapping("/clear")
    public Result<Integer> clearErrorBooks(
            Authentication authentication,
            @RequestParam(required = false) Long wordBankId,
            @RequestParam(required = false) String errorType,
            @RequestParam(name = "is_mastered", required = false) Integer isMastered
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        int deletedCount = errorBookService.clearErrorBooks(currentUser.getUserId(), wordBankId, errorType, isMastered);
        return Result.success("清空错题本成功", deletedCount);
    }

    private AuthenticatedUser requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问错题本");
        }
        return authenticatedUser;
    }
}
