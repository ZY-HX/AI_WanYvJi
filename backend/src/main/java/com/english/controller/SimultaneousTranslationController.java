package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AudioTranslateRequest;
import com.english.dto.AudioTranslateResponse;
import com.english.dto.AuthenticatedUser;
import com.english.dto.PageResponse;
import com.english.dto.TranslationSessionCreateRequest;
import com.english.dto.TranslationSessionResponse;
import com.english.service.SimultaneousTranslationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Tag(name = "同声翻译", description = "实时语音识别、翻译与合成接口")
@Validated
@RestController
@RequestMapping("/api/translation")
@RequiredArgsConstructor
public class SimultaneousTranslationController {

    private final SimultaneousTranslationService simultaneousTranslationService;

    @Operation(summary = "创建翻译会话")
    @PostMapping("/session")
    public Result<TranslationSessionResponse> createSession(
            Authentication authentication,
            @Valid @RequestBody TranslationSessionCreateRequest request
    ) {
        AuthenticatedUser currentUser = requireUser(authentication);
        return Result.success("创建翻译会话成功",
                simultaneousTranslationService.createSession(currentUser.getUserId(), request));
    }

    @Operation(summary = "结束翻译会话")
    @PostMapping("/session/{sessionId}/end")
    public Result<Void> endSession(
            Authentication authentication,
            @PathVariable String sessionId
    ) {
        AuthenticatedUser currentUser = requireUser(authentication);
        simultaneousTranslationService.endSession(currentUser.getUserId(), sessionId);
        return Result.success("结束翻译会话成功", null);
    }

    @Operation(summary = "获取翻译会话历史")
    @GetMapping("/sessions")
    public Result<PageResponse<TranslationSessionResponse>> getSessionHistory(
            Authentication authentication,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size
    ) {
        AuthenticatedUser currentUser = requireUser(authentication);
        return Result.success("获取翻译历史成功",
                simultaneousTranslationService.getSessionHistory(currentUser.getUserId(), current, size));
    }

    @Operation(summary = "处理音频片段并返回识别和翻译结果")
    @PostMapping("/audio")
    public Result<AudioTranslateResponse> processAudio(
            Authentication authentication,
            @Valid @RequestBody AudioTranslateRequest request
    ) {
        requireUser(authentication);
        return Result.success("音频处理成功",
                simultaneousTranslationService.processAudioChunk(authentication, request));
    }

    private AuthenticatedUser requireUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(401, "未认证");
        }
        if ("GUEST".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "游客模式不支持同声翻译功能");
        }
        return authenticatedUser;
    }
}
