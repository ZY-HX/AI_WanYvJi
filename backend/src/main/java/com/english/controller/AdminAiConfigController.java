package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AdminAiConfigResponse;
import com.english.dto.AdminAiConfigUpdateRequest;
import com.english.service.AiArticleClient;
import com.english.service.SystemConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "管理端-AI配置", description = "管理员配置AI服务的API Key、地址和模型")
@Validated
@RestController
@RequestMapping("/api/admin/ai-config")
@RequiredArgsConstructor
public class AdminAiConfigController {

    private final SystemConfigService systemConfigService;
    private final AiArticleClient aiArticleClient;

    @Operation(summary = "获取当前AI服务配置")
    @GetMapping
    public Result<AdminAiConfigResponse> getAiConfig(Authentication authentication) {
        requireAdmin(authentication);

        AdminAiConfigResponse response = new AdminAiConfigResponse();
        String apiKey = systemConfigService.getAiApiKey();
        response.setBaseUrl(systemConfigService.getAiBaseUrl());
        response.setModel(systemConfigService.getAiModel());
        response.setApiKeyMasked(maskApiKey(apiKey));
        response.setApiKeyConfigured(aiArticleClient.hasSystemApiKey());

        return Result.success("获取AI配置成功", response);
    }

    @Operation(summary = "更新AI服务配置")
    @PutMapping
    public Result<Void> updateAiConfig(
            Authentication authentication,
            @Valid @RequestBody AdminAiConfigUpdateRequest request
    ) {
        requireAdmin(authentication);

        if (request.getBaseUrl() != null && !request.getBaseUrl().isBlank()) {
            String normalizedUrl = normalizeBaseUrl(request.getBaseUrl().trim());
            systemConfigService.updateStringConfig("ai_base_url", normalizedUrl);
        }

        if (request.getModel() != null && !request.getModel().isBlank()) {
            systemConfigService.updateStringConfig("ai_model", request.getModel().trim());
        }

        if (request.getApiKey() != null) {
            if (request.getApiKey().isBlank()) {
                systemConfigService.deleteConfig("ai_api_key");
            } else {
                systemConfigService.updateStringConfig("ai_api_key", request.getApiKey().trim());
            }
        }

        return Result.success("AI配置更新成功", null);
    }

    private void requireAdmin(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new BusinessException(401, "请先登录");
        }

        Object principal = authentication.getPrincipal();
        if (!(principal instanceof com.english.dto.AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "无权访问");
        }

        if (!"ADMIN".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "仅管理员可操作AI配置");
        }
    }

    private String normalizeBaseUrl(String url) {
        String normalized = url.trim();
        if (normalized.endsWith("/")) {
            normalized = normalized.substring(0, normalized.length() - 1);
        }
        return normalized;
    }

    private String maskApiKey(String apiKey) {
        if (apiKey == null || apiKey.isBlank()) {
            return null;
        }
        if (apiKey.length() <= 8) {
            return "****";
        }
        return apiKey.substring(0, 4) + "****" + apiKey.substring(apiKey.length() - 4);
    }
}
