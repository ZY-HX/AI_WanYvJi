package com.english.service;

import com.english.common.BusinessException;
import com.english.dto.AiApiKeyAdaptResponse;
import com.english.dto.AiProviderOptionResponse;
import com.english.dto.AiTestConnectionResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class ApiKeyAutoAdaptService {

    private static final String ADAPTER_TYPE_OPENAI_COMPATIBLE = "OPENAI_COMPATIBLE";

    private static final ProviderDefinition OPENAI = new ProviderDefinition(
            "OPENAI", "OpenAI", "https://api.openai.com/v1", "gpt-4o-mini", ADAPTER_TYPE_OPENAI_COMPATIBLE, true
    );
    private static final ProviderDefinition DEEPSEEK = new ProviderDefinition(
            "DEEPSEEK", "DeepSeek", "https://api.deepseek.com/v1", "deepseek-chat", ADAPTER_TYPE_OPENAI_COMPATIBLE, true
    );
    private static final ProviderDefinition ZHIPU = new ProviderDefinition(
            "ZHIPU", "智谱 GLM", "https://open.bigmodel.cn/api/paas/v4", "glm-4-flash", ADAPTER_TYPE_OPENAI_COMPATIBLE, true
    );
    private static final ProviderDefinition QWEN = new ProviderDefinition(
            "QWEN", "通义千问", "https://dashscope.aliyuncs.com/compatible-mode/v1", "qwen-turbo", ADAPTER_TYPE_OPENAI_COMPATIBLE, false
    );

    private static final List<ProviderDefinition> PROVIDERS = List.of(OPENAI, DEEPSEEK, ZHIPU, QWEN);

    private final AiArticleClient aiArticleClient;

    public List<AiProviderOptionResponse> listProviders() {
        return PROVIDERS.stream()
                .map(this::toProviderOption)
                .toList();
    }

    public AiApiKeyAdaptResponse adaptForProjectDefault() {
        AiApiKeyAdaptResponse response = new AiApiKeyAdaptResponse();
        response.setProviderCode("PROJECT_DEFAULT");
        response.setProviderName("项目默认配置");
        response.setBaseUrl(aiArticleClient.getDefaultBaseUrl());
        response.setDefaultModel(aiArticleClient.getDefaultModel());
        response.setAdapterType(ADAPTER_TYPE_OPENAI_COMPATIBLE);
        response.setMatched(true);
        response.setUsedFallback(false);
        response.setReason("使用项目当前默认 AI 配置");
        return response;
    }

    public AiApiKeyAdaptResponse adaptByApiKey(String customApiKey) {
        if (!StringUtils.hasText(customApiKey)) {
            throw new BusinessException(400, "请输入你自己的 API Key");
        }

        String normalizedKey = customApiKey.trim();
        ProviderDefinition matchedProvider = detectStrongFeatureProvider(normalizedKey);
        if (matchedProvider != null) {
            return toAdaptResponse(matchedProvider, true, false, "已根据 API Key 特征识别服务商");
        }

        return buildFallbackResponse();
    }

    public ProviderConfig resolveByProviderCode(String providerCode) {
        if (!StringUtils.hasText(providerCode)) {
            throw new BusinessException(400, "请选择服务商");
        }

        String normalized = providerCode.trim().toUpperCase(Locale.ROOT);
        ProviderDefinition matchedProvider = PROVIDERS.stream()
                .filter(item -> item.code().equals(normalized))
                .findFirst()
                .orElseThrow(() -> new BusinessException(400, "暂不支持该服务商"));

        return new ProviderConfig(
                matchedProvider.code(),
                matchedProvider.name(),
                matchedProvider.baseUrl(),
                matchedProvider.defaultModel(),
                matchedProvider.adapterType()
        );
    }

    private AiApiKeyAdaptResponse buildFallbackResponse() {
        AiApiKeyAdaptResponse response = new AiApiKeyAdaptResponse();
        response.setProviderCode("FALLBACK_DEFAULT");
        response.setProviderName("默认 OpenAI 兼容配置");
        response.setBaseUrl(aiArticleClient.getDefaultBaseUrl());
        response.setDefaultModel(aiArticleClient.getDefaultModel());
        response.setAdapterType(ADAPTER_TYPE_OPENAI_COMPATIBLE);
        response.setMatched(false);
        response.setUsedFallback(true);
        response.setReason("未能根据 API Key 强特征识别服务商，已回退到项目默认兼容配置");
        return response;
    }

    private ProviderDefinition detectStrongFeatureProvider(String apiKey) {
        if (looksLikeZhipuApiKey(apiKey)) {
            return ZHIPU;
        }
        if (looksLikeDeepSeekApiKey(apiKey)) {
            return DEEPSEEK;
        }
        if (looksLikeOpenAIApiKey(apiKey)) {
            return OPENAI;
        }
        if (looksLikeQwenApiKey(apiKey)) {
            return QWEN;
        }
        return null;
    }

    private boolean looksLikeZhipuApiKey(String apiKey) {
        int dotIndex = apiKey.indexOf('.');
        return dotIndex > 0
                && dotIndex == apiKey.lastIndexOf('.')
                && !apiKey.startsWith("sk-")
                && dotIndex < apiKey.length() - 1;
    }

    private boolean looksLikeDeepSeekApiKey(String apiKey) {
        return apiKey.startsWith("sk-")
                && apiKey.length() == 35
                && apiKey.substring(3).chars().allMatch(ch -> Character.isDigit(ch) || (ch >= 'a' && ch <= 'f'));
    }

    private boolean looksLikeOpenAIApiKey(String apiKey) {
        return apiKey.startsWith("sk-")
                && apiKey.length() >= 40
                && apiKey.length() <= 60;
    }

    private boolean looksLikeQwenApiKey(String apiKey) {
        return apiKey.startsWith("sk-")
                && apiKey.length() == 32
                && apiKey.substring(3).chars().allMatch(Character::isLetterOrDigit);
    }

    private AiProviderOptionResponse toProviderOption(ProviderDefinition provider) {
        AiProviderOptionResponse response = new AiProviderOptionResponse();
        response.setProviderCode(provider.code());
        response.setProviderName(provider.name());
        response.setBaseUrl(provider.baseUrl());
        response.setDefaultModel(provider.defaultModel());
        response.setAdapterType(provider.adapterType());
        response.setRecommended(provider.recommended());
        return response;
    }

    private AiApiKeyAdaptResponse toAdaptResponse(
            ProviderDefinition provider,
            boolean matched,
            boolean usedFallback,
            String reason
    ) {
        AiApiKeyAdaptResponse response = new AiApiKeyAdaptResponse();
        response.setProviderCode(provider.code());
        response.setProviderName(provider.name());
        response.setBaseUrl(provider.baseUrl());
        response.setDefaultModel(provider.defaultModel());
        response.setAdapterType(provider.adapterType());
        response.setMatched(matched);
        response.setUsedFallback(usedFallback);
        response.setReason(reason);
        return response;
    }

    public record ProviderConfig(
            String providerCode,
            String providerName,
            String baseUrl,
            String defaultModel,
            String adapterType
    ) {
    }

    public AiTestConnectionResponse testConnectionAndIdentify(String apiKey, String baseUrl, String model) {
        if (!StringUtils.hasText(apiKey)) {
            throw new BusinessException(400, "请输入 API Key");
        }

        String normalizedKey = apiKey.trim();
        ProviderDefinition matchedProvider = detectStrongFeatureProvider(normalizedKey);

        String resolvedBaseUrl = StringUtils.hasText(baseUrl) ? baseUrl.trim() : null;
        String resolvedModel = StringUtils.hasText(model) ? model.trim() : null;

        if (matchedProvider != null) {
            if (resolvedBaseUrl == null) {
                resolvedBaseUrl = matchedProvider.baseUrl();
            }
            if (resolvedModel == null) {
                resolvedModel = matchedProvider.defaultModel();
            }
        }

        AiArticleClient.AiTestConnectionResult testResult = aiArticleClient.testConnection(
                normalizedKey, resolvedBaseUrl, resolvedModel);

        AiTestConnectionResponse response = new AiTestConnectionResponse();
        response.setSuccess(testResult.success());
        response.setDetectedBaseUrl(testResult.baseUrl());
        response.setDetectedModel(testResult.model());
        response.setMessage(testResult.message());
        response.setResponseTimeMs(testResult.responseTimeMs());

        if (testResult.success()) {
            if (matchedProvider != null) {
                response.setProviderCode(matchedProvider.code());
                response.setProviderName(matchedProvider.name());
            } else {
                ProviderDefinition detectedByBase = detectProviderByUrl(testResult.baseUrl());
                if (detectedByBase != null) {
                    response.setProviderCode(detectedByBase.code());
                    response.setProviderName(detectedByBase.name());
                } else {
                    response.setProviderCode("UNKNOWN");
                    response.setProviderName("未知服务商（OpenAI 兼容）");
                }
            }
        } else {
            if (matchedProvider != null) {
                response.setProviderCode(matchedProvider.code());
                response.setProviderName(matchedProvider.name());
            } else {
                response.setProviderCode("UNKNOWN");
                response.setProviderName("未识别");
            }
        }

        return response;
    }

    private ProviderDefinition detectProviderByUrl(String url) {
        if (!StringUtils.hasText(url)) {
            return null;
        }
        String lowerUrl = url.toLowerCase();
        for (ProviderDefinition provider : PROVIDERS) {
            if (lowerUrl.contains(provider.baseUrl().toLowerCase().replace("https://", "").replace("http://", "").split("/")[0])) {
                return provider;
            }
        }
        return null;
    }

    private record ProviderDefinition(
            String code,
            String name,
            String baseUrl,
            String defaultModel,
            String adapterType,
            boolean recommended
    ) {
    }
}
