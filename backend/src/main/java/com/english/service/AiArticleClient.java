package com.english.service;

import com.english.common.BusinessException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpConnectTimeoutException;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.function.Consumer;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiArticleClient {

    private final ObjectMapper objectMapper;
    private final SystemConfigService systemConfigService;

    @Value("${app.ai.base-url:https://api.openai.com/v1}")
    private String defaultBaseUrl;

    @Value("${app.ai.model:gpt-4o-mini}")
    private String defaultModel;

    @Value("${app.ai.api-key:}")
    private String defaultApiKey;

    @Value("${app.ai.connect-timeout-ms:5000}")
    private int connectTimeoutMs;

    @Value("${app.ai.read-timeout-ms:30000}")
    private int readTimeoutMs;

    @Value("${app.ai.max-retries:2}")
    private int maxRetries;

    public boolean hasSystemApiKey() {
        String resolvedApiKey = resolveDynamicApiKey();
        return StringUtils.hasText(resolvedApiKey);
    }

    public String getDefaultBaseUrl() {
        return normalizeBaseUrl(resolveDynamicBaseUrl());
    }

    public String getDefaultModel() {
        String resolvedModel = resolveDynamicModel();
        return StringUtils.hasText(resolvedModel) ? resolvedModel.trim() : "";
    }

    private String resolveDynamicApiKey() {
        String dbApiKey = systemConfigService.getAiApiKey();
        if (StringUtils.hasText(dbApiKey)) {
            return dbApiKey.trim();
        }
        return StringUtils.hasText(defaultApiKey) ? defaultApiKey.trim() : "";
    }

    private String resolveDynamicBaseUrl() {
        String dbBaseUrl = systemConfigService.getAiBaseUrl();
        if (StringUtils.hasText(dbBaseUrl)) {
            return dbBaseUrl.trim();
        }
        return defaultBaseUrl;
    }

    private String resolveDynamicModel() {
        String dbModel = systemConfigService.getAiModel();
        if (StringUtils.hasText(dbModel)) {
            return dbModel.trim();
        }
        return defaultModel;
    }

    public String generateArticle(String prompt, String customApiKey, String overrideBaseUrl, String overrideModel) {
        return generateArticle(prompt, customApiKey, overrideBaseUrl, overrideModel, null);
    }

    public String generateArticle(
            String prompt,
            String customApiKey,
            String overrideBaseUrl,
            String overrideModel,
            Consumer<String> deltaConsumer
    ) {
        String resolvedApiKey = resolveApiKey(customApiKey);
        if (!StringUtils.hasText(resolvedApiKey)) {
            throw new BusinessException(500, "AI 服务未配置 API Key，暂时无法生成文章");
        }

        String resolvedBaseUrl = resolveBaseUrl(overrideBaseUrl);
        String resolvedModel = resolveModel(overrideModel);

        HttpClient httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofMillis(Math.max(connectTimeoutMs, 1000)))
                .build();

        String endpoint = resolvedBaseUrl + "/chat/completions";
        int maxAttempts = Math.max(maxRetries, 0) + 1;

        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            try {
                String requestBody = buildRequestBody(prompt, resolvedModel, true);
                HttpRequest request = HttpRequest.newBuilder()
                        .uri(URI.create(endpoint))
                        .timeout(Duration.ofMillis(Math.max(readTimeoutMs, 3000)))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + resolvedApiKey)
                        .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                        .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                        .build();

                HttpResponse<InputStream> response = httpClient.send(request, HttpResponse.BodyHandlers.ofInputStream());
                if (response.statusCode() >= 200 && response.statusCode() < 300) {
                    return extractArticle(response.body(), deltaConsumer);
                }

                String errorMessage = extractErrorMessage(readBodyAsString(response.body()), response.statusCode());
                if (!shouldRetry(response.statusCode()) || attempt == maxAttempts) {
                    throw new BusinessException(500, errorMessage);
                }
                throw new RetriableAiException(errorMessage);
            } catch (RetriableAiException e) {
                if (attempt == maxAttempts) {
                    throw new BusinessException(500, e.getMessage());
                }
                log.warn("AI 服务调用异常，准备重试，第{}次：{}", attempt, e.getMessage());
            } catch (IOException | InterruptedException e) {
                if (e instanceof InterruptedException) {
                    Thread.currentThread().interrupt();
                }
                if (attempt == maxAttempts) {
                    throw buildNetworkException(endpoint, e);
                }
                log.warn("AI 服务调用异常，准备重试，第{}次：{}", attempt, e.getMessage());
            }

            sleepBeforeRetry(attempt);
        }

        throw new BusinessException(500, "AI 服务调用失败，请稍后重试");
    }

    private String resolveApiKey(String customApiKey) {
        if (StringUtils.hasText(customApiKey)) {
            return customApiKey.trim();
        }
        return resolveDynamicApiKey();
    }

    private String resolveBaseUrl(String overrideBaseUrl) {
        String candidate = StringUtils.hasText(overrideBaseUrl) ? overrideBaseUrl.trim() : resolveDynamicBaseUrl();
        if (!StringUtils.hasText(candidate)) {
            throw new BusinessException(400, "AI 服务地址不能为空");
        }
        return normalizeBaseUrl(candidate);
    }

    private String resolveModel(String overrideModel) {
        String candidate = StringUtils.hasText(overrideModel) ? overrideModel.trim() : resolveDynamicModel();
        if (!StringUtils.hasText(candidate)) {
            throw new BusinessException(400, "模型名称不能为空");
        }
        return candidate.trim();
    }

    private String buildRequestBody(String prompt, String resolvedModel, boolean stream) throws IOException {
        ObjectNode requestNode = objectMapper.createObjectNode();
        requestNode.put("model", resolvedModel);
        requestNode.put("temperature", 0.8);
        requestNode.put("top_p", 0.9);
        requestNode.put("stream", stream);

        ArrayNode messages = requestNode.putArray("messages");
        ObjectNode systemMessage = messages.addObject();
        systemMessage.put("role", "system");
        systemMessage.put("content", "You are a professional English writing assistant.");

        ObjectNode userMessage = messages.addObject();
        userMessage.put("role", "user");
        userMessage.put("content", prompt);
        return objectMapper.writeValueAsString(requestNode);
    }

    private String extractArticle(InputStream responseStream, Consumer<String> deltaConsumer) throws IOException {
        StringBuilder rawResponse = new StringBuilder();
        StringBuilder contentBuilder = new StringBuilder();
        boolean hasStreamPayload = false;

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(responseStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                rawResponse.append(line).append('\n');
                if (!line.startsWith("data:")) {
                    continue;
                }

                hasStreamPayload = true;
                String data = line.substring(5).trim();
                if ("[DONE]".equals(data)) {
                    break;
                }
                appendStreamContent(data, contentBuilder, deltaConsumer);
            }
        }

        if (hasStreamPayload) {
            String article = normalizeArticle(contentBuilder.toString());
            if (!StringUtils.hasText(article)) {
                throw new RetriableAiException("AI 服务未返回有效文章内容");
            }
            return article;
        }

        String responseBody = rawResponse.toString().trim();
        String article = extractArticle(responseBody);
        if (deltaConsumer != null && StringUtils.hasText(article)) {
            deltaConsumer.accept(article);
        }
        return article;
    }

    private String extractArticle(String responseBody) throws IOException {
        JsonNode rootNode = objectMapper.readTree(responseBody);
        String content = readContentNode(rootNode.path("choices").path(0).path("message").path("content"));
        if (!StringUtils.hasText(content)) {
            throw new RetriableAiException("AI 服务未返回有效文章内容");
        }
        return normalizeArticle(content);
    }

    private void appendStreamContent(String data, StringBuilder contentBuilder, Consumer<String> deltaConsumer)
            throws IOException {
        JsonNode rootNode = objectMapper.readTree(data);
        JsonNode errorNode = rootNode.path("error").path("message");
        if (errorNode.isTextual() && StringUtils.hasText(errorNode.asText())) {
            throw new BusinessException(500, "AI 服务调用失败: " + errorNode.asText());
        }

        JsonNode choiceNode = rootNode.path("choices").path(0);
        String delta = readContentNode(choiceNode.path("delta").path("content"));
        if (!StringUtils.hasText(delta)) {
            delta = readContentNode(choiceNode.path("message").path("content"));
        }
        if (!StringUtils.hasText(delta)) {
            return;
        }

        contentBuilder.append(delta);
        if (deltaConsumer != null) {
            deltaConsumer.accept(delta);
        }
    }

    private String readContentNode(JsonNode contentNode) {
        if (contentNode == null || contentNode.isMissingNode() || contentNode.isNull()) {
            return null;
        }
        if (contentNode.isTextual()) {
            return contentNode.asText();
        }
        if (!contentNode.isArray()) {
            return null;
        }

        StringBuilder builder = new StringBuilder();
        for (JsonNode item : contentNode) {
            if (item.isTextual()) {
                builder.append(item.asText());
                continue;
            }
            JsonNode textNode = item.path("text");
            if (textNode.isTextual()) {
                builder.append(textNode.asText());
            }
        }
        return builder.toString();
    }

    private String normalizeArticle(String content) {
        String normalized = content.trim();
        if (normalized.startsWith("```")) {
            int firstNewLine = normalized.indexOf('\n');
            int lastFence = normalized.lastIndexOf("```");
            if (firstNewLine > -1 && lastFence > firstNewLine) {
                normalized = normalized.substring(firstNewLine + 1, lastFence).trim();
            }
        }
        return normalized;
    }

    private String extractErrorMessage(String responseBody, int statusCode) {
        try {
            JsonNode rootNode = objectMapper.readTree(responseBody);
            JsonNode messageNode = rootNode.path("error").path("message");
            if (messageNode.isTextual() && StringUtils.hasText(messageNode.asText())) {
                return "AI 服务调用失败: " + messageNode.asText();
            }
        } catch (IOException e) {
            log.debug("解析 AI 错误响应失败", e);
        }
        return statusCode == 429 ? "AI 服务繁忙，请稍后重试" : "AI 服务调用失败，请稍后重试";
    }

    private String readBodyAsString(InputStream inputStream) throws IOException {
        try (InputStream bodyStream = inputStream) {
            return new String(bodyStream.readAllBytes(), StandardCharsets.UTF_8);
        }
    }

    private boolean shouldRetry(int statusCode) {
        return statusCode == 429 || statusCode >= 500;
    }

    private String normalizeBaseUrl(String value) {
        String normalized = value == null ? "" : value.trim();
        if (normalized.endsWith("/")) {
            normalized = normalized.substring(0, normalized.length() - 1);
        }
        return normalized;
    }

    private void sleepBeforeRetry(int attempt) {
        try {
            Thread.sleep(Math.min(500L * attempt, 1500L));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private BusinessException buildNetworkException(String endpoint, Exception exception) {
        String endpointHint = shortenEndpoint(endpoint);
        if (exception instanceof HttpConnectTimeoutException || containsIgnoreCase(exception.getMessage(), "connect timed out")) {
            return new BusinessException(500, "连接 AI 服务超时，请检查服务地址或网络: " + endpointHint);
        }
        if (containsIgnoreCase(exception.getMessage(), "handshake")) {
            return new BusinessException(500, "连接 AI 服务失败，请检查 HTTPS 证书或代理配置: " + endpointHint);
        }
        return new BusinessException(500, "AI 服务调用失败，请检查服务地址、模型或网络: " + endpointHint);
    }

    private boolean containsIgnoreCase(String text, String keyword) {
        return text != null && text.toLowerCase().contains(keyword.toLowerCase());
    }

    private String shortenEndpoint(String endpoint) {
        return endpoint.length() > 120 ? endpoint.substring(0, 120) + "..." : endpoint;
    }

    public AiTestConnectionResult testConnection(String testApiKey, String testBaseUrl, String testModel) {
        if (!StringUtils.hasText(testApiKey)) {
            throw new BusinessException(400, "请输入 API Key");
        }

        String resolvedApiKey = testApiKey.trim();
        String resolvedBaseUrl = StringUtils.hasText(testBaseUrl) ? normalizeBaseUrl(testBaseUrl.trim()) : resolveDynamicBaseUrl();
        String resolvedModel = StringUtils.hasText(testModel) ? testModel.trim() : (StringUtils.hasText(resolveDynamicModel()) ? resolveDynamicModel() : "gpt-4o-mini");

        HttpClient httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofMillis(Math.max(connectTimeoutMs, 1000)))
                .build();

        String endpoint = resolvedBaseUrl + "/chat/completions";
        long startTime = System.currentTimeMillis();

        try {
            String requestBody = buildTestRequestBody(resolvedModel);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .timeout(Duration.ofMillis(Math.max(readTimeoutMs, 3000)))
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + resolvedApiKey)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpResponse<InputStream> response = httpClient.send(request, HttpResponse.BodyHandlers.ofInputStream());
            long responseTime = System.currentTimeMillis() - startTime;

            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                String body = readBodyAsString(response.body());
                String detectedModel = extractModelFromResponse(body);
                return new AiTestConnectionResult(true, resolvedBaseUrl, detectedModel != null ? detectedModel : resolvedModel,
                        "连接成功，API Key 有效", responseTime);
            }

            String errorMessage = extractErrorMessage(readBodyAsString(response.body()), response.statusCode());
            return new AiTestConnectionResult(false, resolvedBaseUrl, resolvedModel, errorMessage, responseTime);
        } catch (Exception e) {
            long responseTime = System.currentTimeMillis() - startTime;
            if (e instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
            String errorHint = buildConnectionErrorHint(endpoint, e);
            return new AiTestConnectionResult(false, resolvedBaseUrl, resolvedModel, errorHint, responseTime);
        }
    }

    private String buildTestRequestBody(String resolvedModel) throws IOException {
        ObjectNode requestNode = objectMapper.createObjectNode();
        requestNode.put("model", resolvedModel);
        requestNode.put("temperature", 0.7);
        requestNode.put("max_tokens", 5);

        ArrayNode messages = requestNode.putArray("messages");
        ObjectNode userMessage = messages.addObject();
        userMessage.put("role", "user");
        userMessage.put("content", "Hi");
        return objectMapper.writeValueAsString(requestNode);
    }

    private String extractModelFromResponse(String responseBody) {
        try {
            JsonNode rootNode = objectMapper.readTree(responseBody);
            return rootNode.path("model").asText(null);
        } catch (IOException e) {
            log.debug("解析模型名称失败", e);
            return null;
        }
    }

    private String buildConnectionErrorHint(String endpoint, Exception exception) {
        if (exception instanceof HttpConnectTimeoutException || containsIgnoreCase(exception.getMessage(), "connect timed out")) {
            return "连接超时，请检查服务地址是否正确: " + shortenEndpoint(endpoint);
        }
        if (containsIgnoreCase(exception.getMessage(), "handshake")) {
            return "SSL握手失败，请检查HTTPS配置: " + shortenEndpoint(endpoint);
        }
        return "连接失败: " + exception.getMessage();
    }

    public record AiTestConnectionResult(
            boolean success,
            String baseUrl,
            String model,
            String message,
            long responseTimeMs
    ) {}

    private static class RetriableAiException extends RuntimeException {
        private RetriableAiException(String message) {
            super(message);
        }
    }
}
