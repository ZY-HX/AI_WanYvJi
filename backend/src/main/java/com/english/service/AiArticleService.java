package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.dto.AiApiKeyAdaptRequest;
import com.english.dto.AiApiKeyAdaptResponse;
import com.english.dto.AiArticleGenerateRequest;
import com.english.dto.AiArticleGenerateResponse;
import com.english.dto.AiArticleHistoryDetailResponse;
import com.english.dto.AiArticleHistoryItemResponse;
import com.english.dto.AiArticleHighlightWordResponse;
import com.english.dto.AiArticleQuotaResponse;
import com.english.dto.PageResponse;
import com.english.dto.WordLookupRequest;
import com.english.dto.WordLookupResponse;
import com.english.entity.AiArticleLog;
import com.english.entity.UserQuota;
import com.english.entity.Word;
import com.english.entity.WordBank;
import com.english.mapper.AiArticleLogMapper;
import com.english.resilience.ResilientRedisTemplate;
import com.english.util.SensitiveWordFilter;
import com.english.mapper.UserQuotaMapper;
import com.english.mapper.WordBankMapper;
import com.english.mapper.WordMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiArticleService {

    private static final int ACTIVE_WORD_BANK_STATUS = 1;
    private static final int PUBLIC_WORD_BANK = 2;
    private static final int ARTICLE_LOG_SUCCESS = 1;
    private static final int ARTICLE_LOG_FAILED = 0;
    private static final String QUOTA_TYPE_AI_ARTICLE = "AI_ARTICLE";
    private static final Set<String> ALLOWED_DIFFICULTIES = Set.of("EASY", "MEDIUM", "HARD");
    private static final Set<String> ALLOWED_LENGTHS = Set.of("SHORT", "MEDIUM", "LONG");
    private static final String API_KEY_SOURCE_SYSTEM = "SYSTEM";
    private static final String API_KEY_SOURCE_CUSTOM = "CUSTOM";
    private static final String CONFIG_MODE_AUTO = "AUTO";
    private static final String CONFIG_MODE_PROVIDER = "PROVIDER";
    private static final String CONFIG_MODE_MANUAL = "MANUAL";
    private static final String LANGUAGE_EN = "EN";
    private static final String LANGUAGE_JA = "JA";
    private static final String LANGUAGE_KO = "KO";
    private static final String LANGUAGE_DE = "DE";
    private static final String LANGUAGE_FR = "FR";
    private static final String LANGUAGE_ES = "ES";
    private static final Set<String> SUPPORTED_LANGUAGES = Set.of(LANGUAGE_EN, LANGUAGE_JA, LANGUAGE_KO, LANGUAGE_DE, LANGUAGE_FR, LANGUAGE_ES);
    private static final String AI_GENERATE_RATE_LIMIT_KEY = "ai:article:generate:";

    private final WordBankMapper wordBankMapper;
    private final WordMapper wordMapper;
    private final UserQuotaMapper userQuotaMapper;
    private final AiArticleLogMapper aiArticleLogMapper;
    private final SystemConfigService systemConfigService;
    private final AiArticleClient aiArticleClient;
    private final ApiKeyAutoAdaptService apiKeyAutoAdaptService;
    private final ObjectMapper objectMapper;
    private final SensitiveWordFilter sensitiveWordFilter;
    private final ResilientRedisTemplate resilientRedisTemplate;

    @Value("${app.ai.word-sample-size:10}")
    private int wordSampleSize;

    @Value("${app.ai.generate-rate-limit-seconds:10}")
    private int generateRateLimitSeconds;

    public interface StreamObserver {

        default void onProgress(String stage, String message, int progress) {
        }

        default void onChunk(String content) {
        }

        default void onComplete(AiArticleGenerateResponse response) {
        }

        default void onError(int code, String message) {
        }
    }

    public AiArticleQuotaResponse getTodayQuota(Long userId) {
        return toQuotaResponse(getOrCreateTodayQuota(userId));
    }

    public AiApiKeyAdaptResponse adaptApiKey(AiApiKeyAdaptRequest request) {
        String apiKeySource = normalizeApiKeySource(request.getApiKeySource());
        if (API_KEY_SOURCE_SYSTEM.equals(apiKeySource)) {
            if (!aiArticleClient.hasSystemApiKey()) {
                throw new BusinessException(400, "项目提供的 API Key 当前未配置，请切换为自定义 Key");
            }
            return apiKeyAutoAdaptService.adaptForProjectDefault();
        }
        return apiKeyAutoAdaptService.adaptByApiKey(request.getCustomApiKey());
    }

    public PageResponse<AiArticleHistoryItemResponse> getHistory(Long userId, long current, long size) {
        long safeCurrent = Math.max(current, 1L);
        long safeSize = Math.max(size, 1L);
        Page<AiArticleLog> page = new Page<>(safeCurrent, safeSize);
        LambdaQueryWrapper<AiArticleLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AiArticleLog::getUserId, userId)
                .eq(AiArticleLog::getStatus, ARTICLE_LOG_SUCCESS)
                .orderByDesc(AiArticleLog::getCreatedAt)
                .orderByDesc(AiArticleLog::getId);

        Page<AiArticleLog> result = aiArticleLogMapper.selectPage(page, wrapper);
        PageResponse<AiArticleHistoryItemResponse> response = new PageResponse<>();
        response.setCurrent(result.getCurrent());
        response.setSize(result.getSize());
        response.setTotal(result.getTotal());
        response.setRecords(toHistoryItemResponses(result.getRecords()));
        return response;
    }

    public AiArticleHistoryDetailResponse getArticleDetail(Long userId, Long id) {
        AiArticleLog articleLog = requireOwnedSuccessArticle(userId, id);
        return toHistoryDetailResponse(articleLog, getWordBankNameMap(List.of(articleLog.getWordBankId())));
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteArticle(Long userId, Long id) {
        LambdaQueryWrapper<AiArticleLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AiArticleLog::getId, id)
                .eq(AiArticleLog::getUserId, userId);
        int deleted = aiArticleLogMapper.delete(wrapper);
        if (deleted == 0) {
            throw new BusinessException(404, "AI 阅读历史记录不存在");
        }
    }

    public String translateArticle(Long userId, Long id, String customApiKey, String overrideBaseUrl, String overrideModel) {
        AiArticleLog articleLog = requireOwnedSuccessArticle(userId, id);
        if (StringUtils.hasText(articleLog.getTranslation())) {
            return articleLog.getTranslation();
        }

        String content = articleLog.getContent();
        if (!StringUtils.hasText(content)) {
            throw new BusinessException(400, "文章内容为空，无法翻译");
        }

        String resolvedApiKey = StringUtils.hasText(customApiKey) ? customApiKey.trim() : null;
        String resolvedBaseUrl = StringUtils.hasText(overrideBaseUrl) ? overrideBaseUrl.trim() : null;
        String resolvedModel = StringUtils.hasText(overrideModel) ? overrideModel.trim() : null;

        String translationPrompt = buildTranslationPrompt(content);
        String translation;
        try {
            translation = aiArticleClient.generateArticle(
                    translationPrompt,
                    resolvedApiKey,
                    resolvedBaseUrl,
                    resolvedModel,
                    null
            );
        } catch (BusinessException e) {
            log.error("翻译 AI 文章失败 userId={}, articleId={}", userId, id, e);
            throw new BusinessException(500, "翻译失败：" + e.getUserMessage());
        }

        articleLog.setTranslation(translation);
        aiArticleLogMapper.updateById(articleLog);
        return translation;
    }

    private String buildTranslationPrompt(String englishContent) {
        return """
                Please translate the following English article into natural, fluent Chinese.
                Requirements:
                1. Maintain the original paragraph structure and formatting
                2. Use natural Chinese expressions that are easy for Chinese learners to understand
                3. Keep the meaning accurate and complete
                4. Do not add any explanations, notes, or extra content
                5. Return only the Chinese translation

                English article:
                %s
                """.formatted(englishContent);
    }

    public WordLookupResponse lookupWord(WordLookupRequest request) {
        String word = request.getWord();
        if (!StringUtils.hasText(word)) {
            throw new BusinessException(400, "请输入要查询的单词");
        }

        String normalizedWord = word.trim();
        if (normalizedWord.split("\\s+").length > 3) {
            throw new BusinessException(400, "一次只能查询一个单词或短语");
        }

        Word dbWord = wordMapper.selectByEnglish(normalizedWord);
        if (dbWord != null && StringUtils.hasText(dbWord.getChinese())) {
            log.info("单词从数据库查找到: {} -> {}", normalizedWord, dbWord.getChinese());
            WordLookupResponse response = new WordLookupResponse();
            response.setEnglish(dbWord.getEnglish());
            response.setChinese(dbWord.getChinese());
            response.setPhonetic(dbWord.getPhonetic());
            return response;
        }

        log.info("数据库未找到单词: {}, 转用 AI 查询", normalizedWord);

        String customApiKey = StringUtils.hasText(request.getCustomApiKey()) ? request.getCustomApiKey().trim() : null;
        String apiBaseUrl = StringUtils.hasText(request.getApiBaseUrl()) ? request.getApiBaseUrl().trim() : null;
        String model = StringUtils.hasText(request.getModel()) ? request.getModel().trim() : null;

        String language = normalizeLanguage(request.getLanguage());
        String prompt = buildWordLookupPrompt(normalizedWord, language);
        String response;
        try {
            response = aiArticleClient.generateArticle(
                    prompt,
                    customApiKey,
                    apiBaseUrl,
                    model,
                    null
            );
        } catch (BusinessException e) {
            log.error("查询单词释义失败 word={}", normalizedWord, e);
            throw new BusinessException(500, "查询单词释义失败：" + e.getUserMessage());
        }

        return parseWordLookupResponse(normalizedWord, response);
    }

    private String buildWordLookupPrompt(String word, String language) {
        String languageHint = switch (language) {
            case LANGUAGE_JA -> "Japanese";
            case LANGUAGE_KO -> "Korean";
            case LANGUAGE_DE -> "German";
            case LANGUAGE_FR -> "French";
            case LANGUAGE_ES -> "Spanish";
            default -> "English";
        };
        return """
                You are a %s-Chinese dictionary assistant. Look up the following word and provide its Chinese translation.

                Word: %s

                Please respond in this exact JSON format (no markdown, no code blocks):
                {"english": "%s", "chinese": "中文释义", "phonetic": "/音标/"}

                Rules:
                1. Provide the most common and accurate Chinese translation
                2. Include phonetic transcription if available
                3. If multiple meanings exist, provide common meanings with semicolon separation
                4. Return ONLY the JSON object, nothing else
                """.formatted(languageHint, word, word);
    }

    private WordLookupResponse parseWordLookupResponse(String originalWord, String aiResponse) {
        if (!StringUtils.hasText(aiResponse)) {
            throw new BusinessException(500, "AI 返回结果为空", true);
        }

        String cleanedResponse = aiResponse.trim();

        if (cleanedResponse.startsWith("```")) {
            int firstNewline = cleanedResponse.indexOf('\n');
            int lastBacktick = cleanedResponse.lastIndexOf("```");
            if (firstNewline > 0 && lastBacktick > firstNewline) {
                cleanedResponse = cleanedResponse.substring(firstNewline + 1, lastBacktick).trim();
            }
        }

        try {
            ObjectMapper mapper = new ObjectMapper();
            WordLookupResponse parsed = mapper.readValue(cleanedResponse, WordLookupResponse.class);

            if (!StringUtils.hasText(parsed.getChinese())) {
                parsed.setChinese("未找到释义");
            }
            if (!StringUtils.hasText(parsed.getEnglish())) {
                parsed.setEnglish(originalWord);
            }
            return parsed;
        } catch (Exception e) {
            log.warn("解析单词查询 AI 响应失败，尝试提取文本内容 raw={}", cleanedResponse, e);
            WordLookupResponse fallback = new WordLookupResponse();
            fallback.setEnglish(originalWord);
            fallback.setChinese(cleanedResponse.length() > 100 ? cleanedResponse.substring(0, 100) + "..." : cleanedResponse);
            return fallback;
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public AiArticleGenerateResponse generateArticle(Long userId, AiArticleGenerateRequest request) {
        ensureGenerateRateLimit(userId);
        return generateArticleInternal(userId, request, null);
    }

    public void generateArticleStream(Long userId, AiArticleGenerateRequest request, StreamObserver observer) {
        try {
            AiArticleGenerateResponse response = generateArticleInternal(userId, request, observer);
            if (observer != null) {
                observer.onComplete(response);
            }
        } catch (BusinessException e) {
            if (observer != null) {
                observer.onError(e.getCode(), e.getUserMessage());
            }
        } catch (Exception e) {
            log.error("流式生成 AI 文章失败 userId={}", userId, e);
            if (observer != null) {
                observer.onError(500, "AI 文章生成失败，请稍后重试");
            }
        }
    }

    @Transactional(rollbackFor = Exception.class)
    private AiArticleGenerateResponse generateArticleInternal(
            Long userId,
            AiArticleGenerateRequest request,
            StreamObserver observer
    ) {
        emitProgress(observer, "VALIDATING", "正在校验词库、主题和配额", 10);
        WordBank wordBank = requireAccessibleWordBank(userId, request.getWordBankId());
        String theme = normalizeTheme(request.getTheme());
        String difficulty = normalizeDifficulty(request.getDifficulty());
        String length = normalizeLength(request.getLength());

        UserQuota quota = getOrCreateTodayQuota(userId);
        int dailyQuota = Math.max(systemConfigService.getAiArticleDailyQuota(), 1);
        ensureQuotaLimit(quota, dailyQuota);

        emitProgress(observer, "PROMPT", "正在整理词库词汇与生成提示词", 25);
        List<Word> selectedWords = selectPromptWords(wordBank.getId());
        String prompt = buildPrompt(wordBank, selectedWords, theme, difficulty, length);
        String customApiKey = resolveCustomApiKey(request);
        ProviderConfig providerConfig = resolveProviderConfig(request, customApiKey);
        emitProgress(observer, "QUOTA", "正在锁定今日配额", 35);
        incrementQuotaUsage(quota.getId(), dailyQuota);
        UserQuota latestQuota = userQuotaMapper.selectById(quota.getId());
        if (latestQuota == null) {
            throw new BusinessException(500, "配额数据异常，请稍后重试");
        }

        long start = System.currentTimeMillis();
        String content;
        try {
            emitProgress(observer, "GENERATING", "正在连接大模型并生成文章", 45);
            content = aiArticleClient.generateArticle(
                    prompt,
                    customApiKey,
                    providerConfig.baseUrl(),
                    providerConfig.model(),
                    chunk -> emitChunk(observer, chunk)
            );
        } catch (BusinessException e) {
            saveFailedLog(userId, wordBank.getId(), theme, difficulty, length, e.getMessage(),
                    (int) (System.currentTimeMillis() - start));
            throw e;
        }

        emitProgress(observer, "POST_PROCESS", "正在提取高亮词汇并写入日志", 85);
        content = cleanHtmlTags(content);
        List<AiArticleHighlightWordResponse> highlightWords = extractHighlightWords(
                selectedWords,
                content,
                normalizeLanguage(wordBank.getLanguage())
        );
        if (highlightWords.isEmpty()) {
            saveFailedLog(userId, wordBank.getId(), theme, difficulty, length, "AI 结果未包含目标词汇",
                    (int) (System.currentTimeMillis() - start));
            throw new BusinessException(500, "生成结果未包含目标词汇，请稍后重试", true);
        }

        int duration = (int) (System.currentTimeMillis() - start);
        emitProgress(observer, "SAVING", "正在保存结果", 95);

        AiArticleLog logRecord = new AiArticleLog();
        logRecord.setUserId(userId);
        logRecord.setWordBankId(wordBank.getId());
        logRecord.setTheme(theme);
        logRecord.setDifficulty(difficulty);
        logRecord.setLength(length);
        logRecord.setContent(content);
        logRecord.setHighlightWords(writeHighlightWords(highlightWords));
        logRecord.setDuration(duration);
        logRecord.setStatus(ARTICLE_LOG_SUCCESS);
        logRecord.setCreatedAt(LocalDateTime.now());
        aiArticleLogMapper.insert(logRecord);

        AiArticleGenerateResponse response = new AiArticleGenerateResponse();
        response.setLogId(logRecord.getId());
        response.setWordBankId(wordBank.getId());
        response.setTheme(theme);
        response.setDifficulty(difficulty);
        response.setLength(length);
        response.setContent(content);
        response.setHighlightWords(highlightWords);
        response.setDuration(duration);
        response.setGeneratedAt(logRecord.getCreatedAt());
        response.setQuota(toQuotaResponse(latestQuota));
        return response;
    }

    private void incrementQuotaUsage(Long quotaId, int dailyQuota) {
        UpdateWrapper<UserQuota> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", quotaId)
                .lt("used_count", dailyQuota)
                .set("total_quota", dailyQuota)
                .setSql("used_count = used_count + 1");
        int updated = userQuotaMapper.update(null, updateWrapper);
        if (updated == 0) {
            throw new BusinessException(400, "今日次数已用完");
        }
    }

    private void ensureGenerateRateLimit(Long userId) {
        Duration expireDuration = Duration.ofSeconds(Math.max(generateRateLimitSeconds, 1));
        String rateLimitKey = AI_GENERATE_RATE_LIMIT_KEY + userId;
        try {
            Boolean acquired = resilientRedisTemplate.setIfAbsent(rateLimitKey, "1", expireDuration);
            if (Boolean.FALSE.equals(acquired)) {
                throw new BusinessException(429, "生成请求过于频繁，请10秒后再试");
            }
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Redis 不可用，AI 文章生成限流降级为放行模式（Redis恢复后将自动启用限流） userId={}", userId);
        }
    }

    private void ensureQuotaLimit(UserQuota quota, int dailyQuota) {
        quota.setTotalQuota(dailyQuota);
        int usedCount = quota.getUsedCount() == null ? 0 : quota.getUsedCount();
        if (usedCount >= dailyQuota) {
            throw new BusinessException(400, "今日次数已用完");
        }
    }

    private List<Word> selectPromptWords(Long wordBankId) {
        long sampleSize = Math.max(wordSampleSize, 1);
        List<Word> words = wordMapper.selectRandomWords(wordBankId, sampleSize);
        if (words == null || words.isEmpty()) {
            throw new BusinessException(400, "当前词库暂无可用单词，无法生成文章");
        }
        return words;
    }

    private WordBank requireAccessibleWordBank(Long userId, Long wordBankId) {
        LambdaQueryWrapper<WordBank> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WordBank::getId, wordBankId)
                .eq(WordBank::getStatus, ACTIVE_WORD_BANK_STATUS)
                .and(query -> query.eq(WordBank::getUserId, userId).or().eq(WordBank::getIsPublic, PUBLIC_WORD_BANK));

        WordBank wordBank = wordBankMapper.selectOne(wrapper);
        if (wordBank == null) {
            throw new BusinessException(404, "词库不存在或当前用户无权访问");
        }
        return wordBank;
    }

    private AiArticleLog requireOwnedSuccessArticle(Long userId, Long id) {
        LambdaQueryWrapper<AiArticleLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AiArticleLog::getId, id)
                .eq(AiArticleLog::getUserId, userId)
                .eq(AiArticleLog::getStatus, ARTICLE_LOG_SUCCESS)
                .last("LIMIT 1");

        AiArticleLog articleLog = aiArticleLogMapper.selectOne(wrapper);
        if (articleLog == null) {
            throw new BusinessException(404, "AI 阅读历史记录不存在");
        }
        return articleLog;
    }

    private UserQuota getOrCreateTodayQuota(Long userId) {
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LambdaQueryWrapper<UserQuota> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserQuota::getUserId, userId)
                .eq(UserQuota::getQuotaType, QUOTA_TYPE_AI_ARTICLE)
                .eq(UserQuota::getResetTime, todayStart)
                .last("LIMIT 1");

        UserQuota quota = userQuotaMapper.selectOne(wrapper);
        if (quota != null) {
            quota.setTotalQuota(Math.max(systemConfigService.getAiArticleDailyQuota(), 1));
            return quota;
        }

        UserQuota newQuota = new UserQuota();
        newQuota.setUserId(userId);
        newQuota.setQuotaType(QUOTA_TYPE_AI_ARTICLE);
        newQuota.setTotalQuota(Math.max(systemConfigService.getAiArticleDailyQuota(), 1));
        newQuota.setUsedCount(0);
        newQuota.setResetTime(todayStart);
        try {
            userQuotaMapper.insert(newQuota);
            return newQuota;
        } catch (DuplicateKeyException e) {
            log.warn("创建今日 AI 配额记录重复，改为重新查询 userId={}", userId);
            UserQuota existedQuota = userQuotaMapper.selectOne(wrapper);
            if (existedQuota == null) {
                throw new BusinessException(500, "配额初始化失败，请稍后重试");
            }
            return existedQuota;
        }
    }

    private String buildPrompt(
            WordBank wordBank,
            List<Word> selectedWords,
            String theme,
            String difficulty,
            String length
    ) {
        String language = normalizeLanguage(wordBank.getLanguage());
        List<String> vocabulary = selectedWords.stream()
                .map(Word::getEnglish)
                .filter(StringUtils::hasText)
                .distinct()
                .toList();
        int requiredWordCount = Math.max(Math.min(vocabulary.size(), 8), Math.min(vocabulary.size(), 3));

        String taskLanguageHint = switch (language) {
            case LANGUAGE_JA -> "Japanese";
            case LANGUAGE_KO -> "Korean";
            case LANGUAGE_DE -> "German";
            case LANGUAGE_FR -> "French";
            case LANGUAGE_ES -> "Spanish";
            default -> "English";
        };
        return """
                Please write a readable %s article for Chinese vocabulary learners.
                Requirements:
                1. Theme: %s
                2. Difficulty: %s
                3. Length: %s
                4. The article should naturally use at least %d words from this vocabulary list, and use the exact original forms whenever possible:
                %s
                5. Do not output a title, bullet list, JSON, markdown, or explanations.
                6. Return plain %s article content only, with 2-4 short paragraphs.
                Reference word bank: %s
                """.formatted(
                taskLanguageHint,
                theme,
                describeDifficulty(difficulty),
                describeLength(length),
                requiredWordCount,
                String.join(", ", vocabulary),
                taskLanguageHint,
                wordBank.getName()
        );
    }

    private List<AiArticleHistoryItemResponse> toHistoryItemResponses(List<AiArticleLog> records) {
        if (records == null || records.isEmpty()) {
            return List.of();
        }

        Map<Long, String> wordBankNameMap = getWordBankNameMap(records.stream()
                .map(AiArticleLog::getWordBankId)
                .filter(Objects::nonNull)
                .distinct()
                .toList());

        return records.stream()
                .map(record -> toHistoryItemResponse(record, wordBankNameMap))
                .toList();
    }

    private AiArticleHistoryItemResponse toHistoryItemResponse(AiArticleLog record, Map<Long, String> wordBankNameMap) {
        AiArticleHistoryItemResponse response = new AiArticleHistoryItemResponse();
        response.setId(record.getId());
        response.setWordBankId(record.getWordBankId());
        response.setWordBankName(resolveWordBankName(record.getWordBankId(), wordBankNameMap));
        response.setTheme(record.getTheme());
        response.setDifficulty(record.getDifficulty());
        response.setLength(record.getLength());
        response.setDuration(record.getDuration());
        response.setCreatedAt(record.getCreatedAt());
        return response;
    }

    private AiArticleHistoryDetailResponse toHistoryDetailResponse(AiArticleLog record, Map<Long, String> wordBankNameMap) {
        AiArticleHistoryDetailResponse response = new AiArticleHistoryDetailResponse();
        response.setId(record.getId());
        response.setWordBankId(record.getWordBankId());
        response.setWordBankName(resolveWordBankName(record.getWordBankId(), wordBankNameMap));
        response.setTheme(record.getTheme());
        response.setDifficulty(record.getDifficulty());
        response.setLength(record.getLength());
        response.setDuration(record.getDuration());
        response.setContent(record.getContent());
        response.setHighlightWords(readHighlightWords(record.getHighlightWords()));
        response.setTranslation(record.getTranslation());
        response.setCreatedAt(record.getCreatedAt());
        return response;
    }

    private List<AiArticleHighlightWordResponse> extractHighlightWords(
            List<Word> selectedWords,
            String content,
            String language
    ) {
        Map<String, AiArticleHighlightWordResponse> matches = new LinkedHashMap<>();
        for (Word word : selectedWords) {
            if (!StringUtils.hasText(word.getEnglish())) {
                continue;
            }

            if (!containsWordInContent(content, word.getEnglish(), language)) {
                continue;
            }

            String key = word.getEnglish().toLowerCase(Locale.ROOT);
            matches.computeIfAbsent(key, unused -> toHighlightWord(word));
        }
        return new ArrayList<>(matches.values());
    }

    private boolean containsWordInContent(String content, String targetWord, String language) {
        if (!StringUtils.hasText(content) || !StringUtils.hasText(targetWord)) {
            return false;
        }

        if (LANGUAGE_JA.equals(language) || LANGUAGE_KO.equals(language)) {
            // CJK 文本不适用 \b 单词边界，直接按子串判断更稳定。
            return content.contains(targetWord);
        }

        Pattern pattern = Pattern.compile("\\b" + Pattern.quote(targetWord) + "\\b", Pattern.CASE_INSENSITIVE);
        return pattern.matcher(content).find();
    }

    private Map<Long, String> getWordBankNameMap(List<Long> wordBankIds) {
        if (wordBankIds == null || wordBankIds.isEmpty()) {
            return Map.of();
        }

        return wordBankMapper.selectBatchIds(wordBankIds).stream()
                .filter(Objects::nonNull)
                .collect(Collectors.toMap(
                        WordBank::getId,
                        wordBank -> StringUtils.hasText(wordBank.getName()) ? wordBank.getName() : "未知词库",
                        (left, right) -> left,
                        LinkedHashMap::new
                ));
    }

    private String resolveWordBankName(Long wordBankId, Map<Long, String> wordBankNameMap) {
        if (wordBankId == null) {
            return "未关联词库";
        }
        return wordBankNameMap.getOrDefault(wordBankId, "词库已删除");
    }

    private AiArticleHighlightWordResponse toHighlightWord(Word word) {
        AiArticleHighlightWordResponse response = new AiArticleHighlightWordResponse();
        response.setWordId(word.getId());
        response.setEnglish(word.getEnglish());
        response.setChinese(word.getChinese());
        return response;
    }

    private void emitProgress(StreamObserver observer, String stage, String message, int progress) {
        if (observer == null) {
            return;
        }
        observer.onProgress(stage, message, progress);
    }

    private void emitChunk(StreamObserver observer, String chunk) {
        if (observer == null || !StringUtils.hasText(chunk)) {
            return;
        }
        observer.onChunk(chunk);
    }

    private String writeHighlightWords(List<AiArticleHighlightWordResponse> highlightWords) {
        try {
            return objectMapper.writeValueAsString(highlightWords);
        } catch (JsonProcessingException e) {
            throw new BusinessException(500, "高亮词汇保存失败，请稍后重试", true);
        }
    }

    private List<AiArticleHighlightWordResponse> readHighlightWords(String highlightWords) {
        if (!StringUtils.hasText(highlightWords)) {
            return List.of();
        }
        try {
            return objectMapper.readValue(highlightWords, new TypeReference<List<AiArticleHighlightWordResponse>>() {
            });
        } catch (JsonProcessingException e) {
            log.warn("解析 AI 阅读高亮词失败，raw={}", highlightWords, e);
            return List.of();
        }
    }

    private void saveFailedLog(
            Long userId,
            Long wordBankId,
            String theme,
            String difficulty,
            String length,
            String content,
            int duration
    ) {
        AiArticleLog logRecord = new AiArticleLog();
        logRecord.setUserId(userId);
        logRecord.setWordBankId(wordBankId);
        logRecord.setTheme(theme);
        logRecord.setDifficulty(difficulty);
        logRecord.setLength(length);
        logRecord.setContent(content);
        logRecord.setHighlightWords("[]");
        logRecord.setDuration(Math.max(duration, 0));
        logRecord.setStatus(ARTICLE_LOG_FAILED);
        logRecord.setCreatedAt(LocalDateTime.now());
        aiArticleLogMapper.insert(logRecord);
    }

    private AiArticleQuotaResponse toQuotaResponse(UserQuota quota) {
        AiArticleQuotaResponse response = new AiArticleQuotaResponse();
        int totalQuota = quota.getTotalQuota() == null ? 0 : quota.getTotalQuota();
        int usedCount = quota.getUsedCount() == null ? 0 : quota.getUsedCount();
        response.setTotalQuota(totalQuota);
        response.setUsedCount(usedCount);
        response.setRemainingCount(Math.max(totalQuota - usedCount, 0));
        response.setResetTime(quota.getResetTime());
        response.setSystemApiKeyConfigured(aiArticleClient.hasSystemApiKey());
        response.setDefaultBaseUrl(aiArticleClient.getDefaultBaseUrl());
        response.setDefaultModel(aiArticleClient.getDefaultModel());
        return response;
    }

    private String resolveCustomApiKey(AiArticleGenerateRequest request) {
        String apiKeySource = normalizeApiKeySource(request.getApiKeySource());
        if (API_KEY_SOURCE_SYSTEM.equals(apiKeySource)) {
            if (!aiArticleClient.hasSystemApiKey()) {
                throw new BusinessException(400, "项目提供的 API Key 当前未配置，请切换为自定义 Key");
            }
            return null;
        }

        String customApiKey = request.getCustomApiKey();
        if (!StringUtils.hasText(customApiKey)) {
            throw new BusinessException(400, "请输入你自己的 API Key");
        }
        return customApiKey.trim();
    }

    private String normalizeApiKeySource(String value) {
        if (!StringUtils.hasText(value)) {
            throw new BusinessException(400, "请选择 API Key 来源");
        }

        String normalized = value.trim().toUpperCase(Locale.ROOT);
        if (!API_KEY_SOURCE_SYSTEM.equals(normalized) && !API_KEY_SOURCE_CUSTOM.equals(normalized)) {
            throw new BusinessException(400, "API Key 来源仅支持 SYSTEM 或 CUSTOM");
        }
        return normalized;
    }

    private ProviderConfig resolveProviderConfig(AiArticleGenerateRequest request, String customApiKey) {
        String configMode = normalizeConfigMode(request.getConfigMode());
        if (CONFIG_MODE_MANUAL.equals(configMode)) {
            String apiBaseUrl = normalizeOptionalText(request.getApiBaseUrl());
            String model = normalizeOptionalText(request.getModel());
            if (!StringUtils.hasText(apiBaseUrl)) {
                throw new BusinessException(400, "请输入 AI 服务地址");
            }
            if (!StringUtils.hasText(model)) {
                throw new BusinessException(400, "请输入模型名称");
            }
            return new ProviderConfig(apiBaseUrl, model);
        }

        if (CONFIG_MODE_PROVIDER.equals(configMode)) {
            ApiKeyAutoAdaptService.ProviderConfig provider = apiKeyAutoAdaptService.resolveByProviderCode(request.getProviderCode());
            return new ProviderConfig(provider.baseUrl(), provider.defaultModel());
        }

        AiApiKeyAdaptResponse adapted = API_KEY_SOURCE_CUSTOM.equals(normalizeApiKeySource(request.getApiKeySource()))
                ? apiKeyAutoAdaptService.adaptByApiKey(customApiKey)
                : apiKeyAutoAdaptService.adaptForProjectDefault();
        return new ProviderConfig(adapted.getBaseUrl(), adapted.getDefaultModel());
    }

    private String normalizeConfigMode(String value) {
        if (!StringUtils.hasText(value)) {
            throw new BusinessException(400, "请选择配置方式");
        }

        String normalized = value.trim().toUpperCase(Locale.ROOT);
        if (!CONFIG_MODE_AUTO.equals(normalized)
                && !CONFIG_MODE_PROVIDER.equals(normalized)
                && !CONFIG_MODE_MANUAL.equals(normalized)) {
            throw new BusinessException(400, "配置方式仅支持 AUTO、PROVIDER 或 MANUAL");
        }
        return normalized;
    }

    private String normalizeOptionalText(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private String normalizeTheme(String theme) {
        if (!StringUtils.hasText(theme)) {
            return "General";
        }

        String normalized = theme.trim();
        String matchedWord = sensitiveWordFilter.findFirstMatch(normalized);
        if (matchedWord != null) {
            throw new BusinessException(400, "AI文章主题包含敏感词：" + matchedWord);
        }
        return normalized;
    }

    private String normalizeDifficulty(String difficulty) {
        String normalized = normalizeEnumValue(difficulty);
        if (!ALLOWED_DIFFICULTIES.contains(normalized)) {
            throw new BusinessException(400, "难度仅支持 EASY、MEDIUM、HARD");
        }
        return normalized;
    }

    private String normalizeLength(String length) {
        String normalized = normalizeEnumValue(length);
        if (!ALLOWED_LENGTHS.contains(normalized)) {
            throw new BusinessException(400, "长度仅支持 SHORT、MEDIUM、LONG");
        }
        return normalized;
    }

    private String normalizeEnumValue(String value) {
        if (!StringUtils.hasText(value)) {
            return "";
        }
        return value.trim().toUpperCase(Locale.ROOT);
    }

    private String normalizeLanguage(String language) {
        String normalized = StringUtils.hasText(language) ? language.trim().toUpperCase(Locale.ROOT) : LANGUAGE_EN;
        if (!SUPPORTED_LANGUAGES.contains(normalized)) {
            return LANGUAGE_EN;
        }
        return normalized;
    }

    private String describeDifficulty(String difficulty) {
        return switch (difficulty) {
            case "EASY" -> "easy level, short sentences, simple grammar";
            case "HARD" -> "advanced level, richer expressions, but still natural and readable";
            default -> "intermediate level, suitable for high school learners";
        };
    }

    private String describeLength(String length) {
        return switch (length) {
            case "SHORT" -> "about 120-180 words";
            case "LONG" -> "about 380-520 words";
            default -> "about 220-320 words";
        };
    }

    private String cleanHtmlTags(String content) {
        if (!StringUtils.hasText(content)) {
            return content;
        }

        String cleaned = content;
        cleaned = cleaned.replaceAll("<[^>]+>", "")
                .replaceAll("&lt;", "<")
                .replaceAll("&gt;", ">")
                .replaceAll("&amp;", "&")
                .replaceAll("&quot;", "\"")
                .replaceAll("&#39;", "'")
                .replaceAll("\\s{2,}", " ")
                .trim();

        return cleaned;
    }

    private record ProviderConfig(String baseUrl, String model) {
    }
}
