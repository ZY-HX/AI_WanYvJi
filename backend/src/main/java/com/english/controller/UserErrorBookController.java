package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.ErrorBookClearRequest;
import com.english.service.ErrorBookService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "用户错题本", description = "用户错题本批量清空接口")
@RestController
@RequestMapping("/api/user/error-book")
@RequiredArgsConstructor
public class UserErrorBookController {

    private final ErrorBookService errorBookService;

    @Operation(summary = "批量清空当前用户错题本")
    @PostMapping("/clear")
    public Result<Integer> clearErrorBooks(
            Authentication authentication,
            @Valid @RequestBody(required = false) ErrorBookClearRequest request
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        ErrorBookClearRequest safeRequest = request == null ? new ErrorBookClearRequest() : request;
        int deletedCount = errorBookService.clearErrorBooks(
                currentUser.getUserId(),
                safeRequest.getWordBankId(),
                safeRequest.getErrorType(),
                safeRequest.getIsMastered()
        );
        return Result.success("清空错题本成功", deletedCount);
    }

    private AuthenticatedUser requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问错题本");
        }
        return authenticatedUser;
    }
}
