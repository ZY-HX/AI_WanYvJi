package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AiArticleGenerateRequest;
import com.english.dto.AiArticleGenerateResponse;
import com.english.dto.AiArticleHistoryDetailResponse;
import com.english.dto.AiArticleHistoryItemResponse;
import com.english.dto.AiArticleQuotaResponse;
import com.english.dto.AiApiKeyAdaptRequest;
import com.english.dto.AiApiKeyAdaptResponse;
import com.english.dto.AiTestConnectionRequest;
import com.english.dto.AiTestConnectionResponse;
import com.english.dto.AiProviderOptionResponse;
import com.english.dto.AiArticleTranslateRequest;
import com.english.dto.AuthenticatedUser;
import com.english.dto.PageResponse;
import com.english.dto.WordLookupRequest;
import com.english.dto.WordLookupResponse;
import com.english.service.ApiKeyAutoAdaptService;
import com.english.service.AiArticleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "AI 阅读强化", description = "AI 阅读文章生成与每日配额接口")
@Validated
@RestController
@RequestMapping("/api/ai/article")
@RequiredArgsConstructor
public class AiArticleController {

    private final AiArticleService aiArticleService;
    private final ApiKeyAutoAdaptService apiKeyAutoAdaptService;

    @Operation(summary = "查询今日 AI 阅读生成剩余配额")
    @GetMapping("/quota")
    public Result<AiArticleQuotaResponse> getTodayQuota(Authentication authentication) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        return Result.success("获取今日配额成功", aiArticleService.getTodayQuota(currentUser.getUserId()));
    }

    @Operation(summary = "查询可选 AI 服务商")
    @GetMapping("/providers")
    public Result<java.util.List<AiProviderOptionResponse>> getProviders(Authentication authentication) {
        requireEditableUser(authentication);
        return Result.success("获取服务商列表成功", apiKeyAutoAdaptService.listProviders());
    }

    @Operation(summary = "根据 API Key 自动适配服务商")
    @PostMapping("/adapt")
    public Result<AiApiKeyAdaptResponse> adaptApiKey(
            Authentication authentication,
            @Valid @RequestBody AiApiKeyAdaptRequest request
    ) {
        requireEditableUser(authentication);
        return Result.success("自动适配成功", aiArticleService.adaptApiKey(request));
    }

    @Operation(summary = "测试 API Key 连接并识别服务商")
    @PostMapping("/test-connection")
    public Result<AiTestConnectionResponse> testConnection(
            Authentication authentication,
            @Valid @RequestBody AiTestConnectionRequest request
    ) {
        requireEditableUser(authentication);
        return Result.success("测试完成", apiKeyAutoAdaptService.testConnectionAndIdentify(
                request.getApiKey(), request.getBaseUrl(), request.getModel()));
    }

    @Operation(summary = "生成 AI 阅读文章")
    @PostMapping("/generate")
    public Result<AiArticleGenerateResponse> generateArticle(
            Authentication authentication,
            @Valid @RequestBody AiArticleGenerateRequest request
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        return Result.success("AI 阅读文章生成成功",
                aiArticleService.generateArticle(currentUser.getUserId(), request));
    }

    @Operation(summary = "分页获取当前用户 AI 阅读历史")
    @GetMapping("/history")
    public Result<PageResponse<AiArticleHistoryItemResponse>> getHistory(
            Authentication authentication,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        return Result.success("获取 AI 阅读历史成功", aiArticleService.getHistory(currentUser.getUserId(), current, size));
    }

    @Operation(summary = "获取当前用户指定 AI 阅读文章详情")
    @GetMapping("/{id}")
    public Result<AiArticleHistoryDetailResponse> getArticleDetail(
            Authentication authentication,
            @PathVariable Long id
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        return Result.success("获取 AI 阅读文章详情成功", aiArticleService.getArticleDetail(currentUser.getUserId(), id));
    }

    @Operation(summary = "删除当前用户指定 AI 阅读历史记录")
    @DeleteMapping("/{id}")
    public Result<Void> deleteArticle(
            Authentication authentication,
            @PathVariable Long id
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        aiArticleService.deleteArticle(currentUser.getUserId(), id);
        return Result.success("删除 AI 阅读历史成功", null);
    }

    @Operation(summary = "翻译 AI 阅读文章为中文")
    @PostMapping("/{id}/translate")
    public Result<String> translateArticle(
            Authentication authentication,
            @PathVariable Long id,
            @Valid @RequestBody AiArticleTranslateRequest request
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        String translation = aiArticleService.translateArticle(
                currentUser.getUserId(),
                id,
                request.getCustomApiKey(),
                request.getApiBaseUrl(),
                request.getModel()
        );
        return Result.success("文章翻译成功", translation);
    }

    @Operation(summary = "查询单词中文释义")
    @PostMapping("/word/lookup")
    public Result<WordLookupResponse> lookupWord(
            Authentication authentication,
            @Valid @RequestBody WordLookupRequest request
    ) {
        requireEditableUser(authentication);
        return Result.success("查询成功", aiArticleService.lookupWord(request));
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
