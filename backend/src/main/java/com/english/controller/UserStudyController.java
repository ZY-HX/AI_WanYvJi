package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.StudyResultRequest;
import com.english.dto.StudyResultResponse;
import com.english.service.StudyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "学习模块", description = "用户学习结果提交接口")
@RestController
@RequestMapping("/api/user/study")
@RequiredArgsConstructor
public class UserStudyController {

    private final StudyService studyService;

    @Operation(summary = "按词库提交单词学习结果")
    @PostMapping("/{wordBankId}/submit")
    public Result<StudyResultResponse> submitStudyResult(
            Authentication authentication,
            @PathVariable Long wordBankId,
            @Valid @RequestBody StudyResultRequest request
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("学习结果提交成功",
                studyService.submitStudyResult(currentUser.getUserId(), wordBankId, request));
    }

    @Operation(summary = "手动重置词库复习计划")
    @PostMapping("/{wordBankId}/reset")
    public Result<Integer> resetStudyPlan(
            Authentication authentication,
            @PathVariable Long wordBankId
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        int deletedCount = studyService.resetStudyPlan(currentUser.getUserId(), wordBankId);
        return Result.success("词库复习计划重置成功", deletedCount);
    }

    private AuthenticatedUser requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问学习模块");
        }
        return authenticatedUser;
    }
}
