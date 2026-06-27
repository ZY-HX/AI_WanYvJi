package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.english.common.BusinessException;
import com.english.dto.PageResponse;
import com.english.dto.StudyExportRecordResponse;
import com.english.dto.StudyOptionResponse;
import com.english.dto.StudyResultRequest;
import com.english.dto.StudyResultResponse;
import com.english.dto.StudyWordBankOptionResponse;
import com.english.dto.StudyWordResponse;
import com.english.entity.ErrorBook;
import com.english.entity.UserStudyRecord;
import com.english.entity.Word;
import com.english.entity.WordBank;
import com.english.resilience.ResilientRedisTemplate;
import com.english.mapper.ErrorBookMapper;
import com.english.mapper.UserStudyRecordMapper;
import com.english.mapper.WordBankMapper;
import com.english.mapper.WordMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
public class StudyService {

    private static final int[] REVIEW_INTERVAL_DAYS = {1, 2, 4, 7, 15, 30};
    private static final int ACTIVE_WORD_BANK_STATUS = 1;
    private static final int ACTIVE_STUDY_RECORD_STATUS = 1;
    private static final int ACTIVE_ERROR_BOOK_STATUS = 1;
    private static final int NOT_MASTERED_ERROR_BOOK = 0;
    private static final int PUBLIC_WORD_BANK = 2;
    private static final long PAGE_SIZE = 20L;
    private static final String DEFAULT_STUDY_MODE = "EN_TO_CN";
    private static final Set<String> ALLOWED_STUDY_MODES = Set.of("EN_TO_CN", "CN_TO_EN", "LISTEN", "SPELL");
    private static final Set<String> SUPPORTED_LANGUAGES = Set.of("EN", "JA", "KO", "DE", "FR", "ES");
    private static final DateTimeFormatter EXPORT_FILENAME_DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final DateTimeFormatter EXPORT_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final DecimalFormat ACCURACY_FORMAT = new DecimalFormat("0.00%");
    private static final String STUDY_EXPORT_RATE_LIMIT_KEY = "study:export:";

    private final WordBankMapper wordBankMapper;
    private final WordMapper wordMapper;
    private final UserStudyRecordMapper userStudyRecordMapper;
    private final ErrorBookMapper errorBookMapper;
    private final UserStudyPlanService userStudyPlanService;
    private final ResilientRedisTemplate resilientRedisTemplate;

    @Value("${app.study.export-rate-limit-seconds:60}")
    private int exportRateLimitSeconds;

    public List<StudyWordBankOptionResponse> getAvailableWordBanks(Long userId, String language) {
        return wordBankMapper.selectStudyWordBanks(userId, normalizeLanguage(language)).stream()
                .map(this::toWordBankOption)
                .toList();
    }

    @Transactional(rollbackFor = Exception.class)
    public PageResponse<StudyWordResponse> getTodayStudyWords(Long userId, Long wordBankId, String mode, long current) {
        long safeCurrent = Math.max(current, 1L);
        WordBank wordBank = requireAccessibleWordBank(userId, wordBankId);
        UserStudyPlanService.StudyPlanSettings planSettings = userStudyPlanService.getPlan(userId);
        long pageSize = planSettings.studySessionSize();

        LocalDateTime now = LocalDateTime.now();
        long readyCount = userStudyRecordMapper.countReadyRecords(userId, wordBankId, now);
        long unlearnedCount = wordMapper.countUnlearnedWords(userId, wordBankId);
        long total = readyCount + unlearnedCount;
        long offset = (safeCurrent - 1) * pageSize;

        if (offset < total) {
            long requiredReadyCount = Math.min(total, safeCurrent * pageSize);
            if (readyCount < requiredReadyCount) {
                createReadyStudyRecords(userId, wordBank.getId(), resolveStudyMode(mode), now, requiredReadyCount - readyCount);
            }
        }

        List<StudyWordResponse> records = offset >= total
                ? List.of()
                : userStudyRecordMapper.selectReadyStudyWords(userId, wordBankId, now, offset, pageSize);

        if (total == 0 && planSettings.allowSameDayReview()) {
            total = userStudyRecordMapper.countActiveRecords(userId, wordBankId);
            records = offset >= total
                    ? List.of()
                    : userStudyRecordMapper.selectContinuousStudyWords(userId, wordBankId, offset, pageSize);
        }

        PageResponse<StudyWordResponse> response = new PageResponse<>();
        response.setCurrent(safeCurrent);
        response.setSize(pageSize);
        response.setTotal(total);
        response.setRecords(records);
        return response;
    }

    public PageResponse<StudyWordResponse> getReviewWords(Long userId, Long wordBankId, long current, long size) {
        requireAccessibleWordBank(userId, wordBankId);

        long safeCurrent = Math.max(current, 1L);
        long safeSize = Math.max(size, 1L);
        long total = userStudyRecordMapper.countActiveRecords(userId, wordBankId);
        long offset = (safeCurrent - 1) * safeSize;

        List<StudyWordResponse> records = offset >= total
                ? List.of()
                : userStudyRecordMapper.selectReviewWords(userId, wordBankId, offset, safeSize);

        PageResponse<StudyWordResponse> response = new PageResponse<>();
        response.setCurrent(safeCurrent);
        response.setSize(safeSize);
        response.setTotal(total);
        response.setRecords(records);
        return response;
    }

    public List<StudyOptionResponse> getQuestionOptions(Long userId, Long wordBankId, Long currentWordId) {
        requireAccessibleWordBank(userId, wordBankId);
        return wordMapper.selectRandomWords(wordBankId, 24).stream()
                .filter(word -> currentWordId == null || !currentWordId.equals(word.getId()))
                .map(this::toStudyOptionResponse)
                .toList();
    }

    @Transactional(rollbackFor = Exception.class)
    public StudyResultResponse submitStudyResult(Long userId, StudyResultRequest request) {
        return submitStudyResult(userId, null, request);
    }

    @Transactional(rollbackFor = Exception.class)
    public StudyResultResponse submitStudyResult(Long userId, Long wordBankId, StudyResultRequest request) {
        UserStudyRecord record = userStudyRecordMapper.selectById(request.getRecordId());
        if (record == null || !userId.equals(record.getUserId()) || record.getStatus() == null
                || record.getStatus() != ACTIVE_STUDY_RECORD_STATUS) {
            throw new BusinessException(404, "学习记录不存在");
        }
        if (wordBankId != null && !wordBankId.equals(record.getWordBankId())) {
            throw new BusinessException(400, "学习记录与词库不匹配");
        }
        if (!request.getWordId().equals(record.getWordId())) {
            throw new BusinessException(400, "学习记录与单词不匹配");
        }

        String studyMode = resolveStudyMode(request.getMode());
        LocalDateTime now = LocalDateTime.now();
        if (record.getNextReviewTime() != null && record.getNextReviewTime().isAfter(now)) {
            throw new BusinessException(400, "该单词本轮已提交，请切换下一题");
        }
        LocalDateTime nextReviewTime = calculateNextReviewTime(Boolean.TRUE.equals(request.getCorrect()),
                record.getCorrectCount() == null ? 0 : record.getCorrectCount());

        record.setStudyMode(studyMode);
        record.setReviewCount((record.getReviewCount() == null ? 0 : record.getReviewCount()) + 1);
        if (Boolean.TRUE.equals(request.getCorrect())) {
            record.setCorrectCount((record.getCorrectCount() == null ? 0 : record.getCorrectCount()) + 1);
        } else {
            record.setWrongCount((record.getWrongCount() == null ? 0 : record.getWrongCount()) + 1);
            record.setCorrectCount(0);
            recordWrongAnswer(userId, request.getWordId(), studyMode);
        }
        record.setNextReviewTime(nextReviewTime);
        userStudyRecordMapper.updateById(record);

        return toStudyResultResponse(record);
    }

    @Transactional(rollbackFor = Exception.class)
    public StudyExportFile exportStudyRecords(Long userId, Long wordBankId) {
        WordBank wordBank = requireAccessibleWordBank(userId, wordBankId);
        ensureExportRateLimit(userId);

        List<StudyExportRecordResponse> records = userStudyRecordMapper.selectExportRecords(userId, wordBankId);
        byte[] content = buildCsv(records);

        String filename = buildExportFilename(wordBank.getName());
        return new StudyExportFile(filename, content);
    }

    @Transactional(rollbackFor = Exception.class)
    public int resetStudyPlan(Long userId, Long wordBankId) {
        requireAccessibleWordBank(userId, wordBankId);
        return userStudyRecordMapper.deleteByUserIdAndWordBankId(userId, wordBankId);
    }

    private void createReadyStudyRecords(
            Long userId,
            Long wordBankId,
            String studyMode,
            LocalDateTime nextReviewTime,
            long count
    ) {
        if (count <= 0) {
            return;
        }

        List<Word> newWords = wordMapper.selectFirstUnlearnedWords(userId, wordBankId, count);
        for (Word word : newWords) {
            UserStudyRecord record = new UserStudyRecord();
            record.setUserId(userId);
            record.setWordBankId(wordBankId);
            record.setWordId(word.getId());
            record.setStudyMode(studyMode);
            record.setCorrectCount(0);
            record.setWrongCount(0);
            record.setNextReviewTime(nextReviewTime);
            record.setReviewCount(0);
            record.setStatus(ACTIVE_STUDY_RECORD_STATUS);
            userStudyRecordMapper.insert(record);
        }
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

    private StudyWordBankOptionResponse toWordBankOption(WordBank wordBank) {
        StudyWordBankOptionResponse response = new StudyWordBankOptionResponse();
        response.setId(wordBank.getId());
        response.setName(wordBank.getName());
        response.setCategory(wordBank.getCategory());
        response.setLanguage(wordBank.getLanguage());
        response.setWordCount(wordBank.getWordCount());
        response.setIsPublic(wordBank.getIsPublic());
        return response;
    }

    private String normalizeLanguage(String language) {
        if (!StringUtils.hasText(language)) {
            return null;
        }
        String normalized = language.trim().toUpperCase(Locale.ROOT);
        if (!SUPPORTED_LANGUAGES.contains(normalized)) {
            throw new BusinessException(400, "暂不支持该语种，仅支持 EN、JA、KO");
        }
        return normalized;
    }

    private StudyOptionResponse toStudyOptionResponse(Word word) {
        StudyOptionResponse response = new StudyOptionResponse();
        response.setWordId(word.getId());
        response.setEnglish(word.getEnglish());
        response.setChinese(word.getChinese());
        return response;
    }

    private void ensureExportRateLimit(Long userId) {
        Duration expireDuration = Duration.ofSeconds(Math.max(exportRateLimitSeconds, 1));
        String rateLimitKey = STUDY_EXPORT_RATE_LIMIT_KEY + userId;
        try {
            Boolean acquired = resilientRedisTemplate.setIfAbsent(rateLimitKey, "1", expireDuration);
            if (Boolean.FALSE.equals(acquired)) {
                throw new BusinessException(429, "导出请求过于频繁，请1分钟后再试");
            }
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Redis 不可用，学习记录导出限流降级为放行模式（Redis恢复后将自动启用限流） userId={}", userId, e);
        }
    }

    private byte[] buildCsv(List<StudyExportRecordResponse> records) {
        StringBuilder builder = new StringBuilder();
        builder.append('\uFEFF');
        builder.append("English,Chinese,Study Mode,Study Count,Correct Count,Wrong Count,Accuracy Rate,Next Review Time\r\n");
        for (StudyExportRecordResponse record : records) {
            int reviewCount = safeInt(record.getReviewCount());
            int correctCount = safeInt(record.getCorrectCount());
            int wrongCount = safeInt(record.getWrongCount());
            builder.append(csvEscape(record.getEnglish())).append(',')
                    .append(csvEscape(record.getChinese())).append(',')
                    .append(csvEscape(record.getStudyMode())).append(',')
                    .append(reviewCount).append(',')
                    .append(correctCount).append(',')
                    .append(wrongCount).append(',')
                    .append(csvEscape(formatAccuracy(correctCount, wrongCount))).append(',')
                    .append(csvEscape(formatDateTime(record.getNextReviewTime())))
                    .append("\r\n");
        }
        return builder.toString().getBytes(StandardCharsets.UTF_8);
    }

    private String buildExportFilename(String wordBankName) {
        String safeWordBankName = sanitizeFilename(wordBankName);
        String date = LocalDate.now().format(EXPORT_FILENAME_DATE_FORMATTER);
        return safeWordBankName + "_study_record_" + date + ".csv";
    }

    private String sanitizeFilename(String value) {
        if (!StringUtils.hasText(value)) {
            return "wordbank";
        }
        return value.trim().replaceAll("[\\\\/:*?\"<>|]", "_");
    }

    private int safeInt(Integer value) {
        return value == null ? 0 : value;
    }

    private String formatAccuracy(int correctCount, int wrongCount) {
        int total = correctCount + wrongCount;
        if (total <= 0) {
            return "0.00%";
        }
        return ACCURACY_FORMAT.format((double) correctCount / total);
    }

    private String formatDateTime(LocalDateTime value) {
        return value == null ? "" : value.format(EXPORT_TIME_FORMATTER);
    }

    private String csvEscape(String value) {
        if (value == null) {
            return "";
        }
        String escaped = value.replace("\"", "\"\"");
        if (escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") || escaped.contains("\r")) {
            return "\"" + escaped + "\"";
        }
        return escaped;
    }

    private void recordWrongAnswer(Long userId, Long wordId, String studyMode) {
        LambdaQueryWrapper<ErrorBook> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ErrorBook::getUserId, userId)
                .eq(ErrorBook::getWordId, wordId)
                .eq(ErrorBook::getErrorType, studyMode);

        ErrorBook errorBook = errorBookMapper.selectOne(wrapper);
        if (errorBook == null) {
            ErrorBook newErrorBook = new ErrorBook();
            newErrorBook.setUserId(userId);
            newErrorBook.setWordId(wordId);
            newErrorBook.setErrorType(studyMode);
            newErrorBook.setErrorTimes(1);
            newErrorBook.setIsMastered(NOT_MASTERED_ERROR_BOOK);
            newErrorBook.setStatus(ACTIVE_ERROR_BOOK_STATUS);
            errorBookMapper.insert(newErrorBook);
            return;
        }

        errorBook.setErrorTimes((errorBook.getErrorTimes() == null ? 0 : errorBook.getErrorTimes()) + 1);
        errorBook.setIsMastered(NOT_MASTERED_ERROR_BOOK);
        errorBook.setStatus(ACTIVE_ERROR_BOOK_STATUS);
        errorBookMapper.updateById(errorBook);
    }

    private LocalDateTime calculateNextReviewTime(boolean correct, int currentCorrectCount) {
        if (!correct) {
            return LocalDateTime.now().plusDays(1);
        }

        int nextCorrectCount = currentCorrectCount + 1;
        int intervalIndex = Math.min(nextCorrectCount - 1, REVIEW_INTERVAL_DAYS.length - 1);
        return LocalDateTime.now().plusDays(REVIEW_INTERVAL_DAYS[intervalIndex]);
    }

    private StudyResultResponse toStudyResultResponse(UserStudyRecord record) {
        StudyResultResponse response = new StudyResultResponse();
        response.setRecordId(record.getId());
        response.setWordId(record.getWordId());
        response.setWordBankId(record.getWordBankId());
        response.setStudyMode(record.getStudyMode());
        response.setCorrectCount(record.getCorrectCount());
        response.setWrongCount(record.getWrongCount());
        response.setReviewCount(record.getReviewCount());
        response.setNextReviewTime(record.getNextReviewTime());
        return response;
    }

    private String resolveStudyMode(String mode) {
        if (!StringUtils.hasText(mode)) {
            return DEFAULT_STUDY_MODE;
        }

        String normalized = mode.trim().toUpperCase(Locale.ROOT);
        if (!ALLOWED_STUDY_MODES.contains(normalized)) {
            return DEFAULT_STUDY_MODE;
        }
        return normalized;
    }

    public record StudyExportFile(String filename, byte[] content) {
    }
}
