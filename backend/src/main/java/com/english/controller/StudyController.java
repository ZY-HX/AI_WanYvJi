package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.PageResponse;
import com.english.dto.StudyOptionResponse;
import com.english.dto.StudyResultRequest;
import com.english.dto.StudyResultResponse;
import com.english.dto.StudyWordBankOptionResponse;
import com.english.dto.StudyWordResponse;
import com.english.service.StudyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "学习模块", description = "今日待学习单词与学习词库接口")
@Validated
@RestController
@RequestMapping("/api/study")
@RequiredArgsConstructor
public class StudyController {

    private final StudyService studyService;

    @Operation(summary = "获取当前用户可用于学习的词库列表")
    @GetMapping("/wordbanks")
    public Result<List<StudyWordBankOptionResponse>> getStudyWordBanks(
            Authentication authentication,
            @RequestParam(required = false) String language
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取学习词库成功", studyService.getAvailableWordBanks(currentUser.getUserId(), language));
    }

    @Operation(summary = "分页获取今日待学习单词")
    @GetMapping("/today")
    public Result<PageResponse<StudyWordResponse>> getTodayStudyWords(
            Authentication authentication,
            @RequestParam Long wordBankId,
            @RequestParam(required = false) String mode,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取今日待学习单词成功",
                studyService.getTodayStudyWords(currentUser.getUserId(), wordBankId, mode, current));
    }

    @Operation(summary = "分页获取已学单词（用于复习）")
    @GetMapping("/review")
    public Result<PageResponse<StudyWordResponse>> getReviewWords(
            Authentication authentication,
            @RequestParam Long wordBankId,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "20") @Min(value = 1, message = "每页数量必须大于0") long size
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取复习单词成功",
                studyService.getReviewWords(currentUser.getUserId(), wordBankId, current, size));
    }

    @Operation(summary = "获取学习题目的候选选项")
    @GetMapping("/options")
    public Result<List<StudyOptionResponse>> getStudyOptions(
            Authentication authentication,
            @RequestParam Long wordBankId,
            @RequestParam(required = false) Long currentWordId
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("获取题目选项成功",
                studyService.getQuestionOptions(currentUser.getUserId(), wordBankId, currentWordId));
    }

    @Operation(summary = "提交单词学习结果")
    @PostMapping("/result")
    public Result<StudyResultResponse> submitStudyResult(
            Authentication authentication,
            @Valid @RequestBody StudyResultRequest request
    ) {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);
        return Result.success("学习结果提交成功",
                studyService.submitStudyResult(currentUser.getUserId(), request));
    }

    private AuthenticatedUser requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问学习模块");
        }
        return authenticatedUser;
    }
}
