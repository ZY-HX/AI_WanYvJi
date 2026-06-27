package com.english.controller;

import com.english.common.BusinessException;
import com.english.dto.AiArticleGenerateRequest;
import com.english.dto.AiArticleGenerateResponse;
import com.english.dto.AuthenticatedUser;
import com.english.service.AiArticleService;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Tag(name = "生成 AI 定制文章", description = "生成 AI 定制文章流式接口")
@Validated
@RestController
@RequestMapping("/api/user/ai")
@RequiredArgsConstructor
public class UserAiArticleController {

    private final AiArticleService aiArticleService;
    private final ObjectMapper objectMapper;

    @Operation(summary = "流式生成 AI 定制文章")
    @PostMapping(value = "/generate-article", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter generateArticle(
            Authentication authentication,
            @Valid @RequestBody AiArticleGenerateRequest request
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        SseEmitter emitter = new SseEmitter(0L);
        emitter.onTimeout(emitter::complete);

        CompletableFuture.runAsync(() -> aiArticleService.generateArticleStream(
                currentUser.getUserId(),
                request,
                new AiArticleService.StreamObserver() {
                    @Override
                    public void onProgress(String stage, String message, int progress) {
                        sendEvent(emitter, "progress", Map.of(
                                "stage", stage,
                                "message", message,
                                "progress", progress
                        ));
                    }

                    @Override
                    public void onChunk(String content) {
                        sendEvent(emitter, "chunk", Map.of("content", content));
                    }

                    @Override
                    public void onComplete(AiArticleGenerateResponse response) {
                        sendEvent(emitter, "complete", response);
                        emitter.complete();
                    }

                    @Override
                    public void onError(int code, String message) {
                        sendEvent(emitter, "error", Map.of(
                                "code", code,
                                "message", message
                        ));
                        emitter.complete();
                    }
                }
        )).exceptionally(throwable -> {
            log.warn("异步生成 AI 定制文章失败", throwable);
            safelyCompleteWithError(emitter, throwable);
            return null;
        });

        return emitter;
    }

    private void sendEvent(SseEmitter emitter, String eventName, Object payload) {
        try {
            emitter.send(SseEmitter.event()
                    .name(eventName)
                    .data(objectMapper.writeValueAsString(payload)));
        } catch (IOException e) {
            throw new IllegalStateException("发送流式事件失败", e);
        }
    }

    private void safelyCompleteWithError(SseEmitter emitter, Throwable throwable) {
        try {
            sendEvent(emitter, "error", Map.of(
                    "code", 500,
                    "message", "流式连接已中断，请重试"
            ));
        } catch (Exception ex) {
            log.debug("推送流式错误事件失败", ex);
        } finally {
            emitter.completeWithError(throwable);
        }
    }

    private AuthenticatedUser requireEditableUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问 AI 阅读");
        }
        if ("GUEST".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "游客模式不支持 AI 阅读强化功能");
        }
        return authenticatedUser;
    }
}
