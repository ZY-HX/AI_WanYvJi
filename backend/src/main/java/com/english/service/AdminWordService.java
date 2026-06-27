package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.dto.PageResponse;
import com.english.dto.WordCreateRequest;
import com.english.dto.WordImportFailure;
import com.english.dto.WordImportResponse;
import com.english.dto.WordResponse;
import com.english.dto.WordUpdateRequest;
import com.english.entity.Word;
import com.english.entity.WordBank;
import com.english.mapper.WordBankMapper;
import com.english.mapper.WordMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminWordService {

    private static final int ACTIVE_STATUS = 1;
    private static final String TARGET_TYPE_WORD = "WORD";
    private static final String OPERATION_CREATE = "WORD_CREATE";
    private static final String OPERATION_UPDATE = "WORD_UPDATE";
    private static final String OPERATION_DELETE = "WORD_DELETE";
    private static final String OPERATION_IMPORT = "WORD_IMPORT";
    private static final int MAX_IMPORT_SIZE = 1000;
    private static final Pattern JAPANESE_PATTERN = Pattern.compile(".*[\\p{IsHiragana}\\p{IsKatakana}\\p{IsHan}].*");
    private static final Pattern KOREAN_PATTERN = Pattern.compile(".*[\\p{IsHangul}].*");
    private static final Pattern ENGLISH_PATTERN = Pattern.compile(".*[A-Za-z].*");
    private static final Pattern GERMAN_PATTERN = Pattern.compile(".*[A-Za-zäöüßÄÖÜ].*");
    private static final Pattern FRENCH_PATTERN = Pattern.compile(".*[A-Za-zàâçéèêëîïôùûüÿæœÀÂÇÉÈÊËÎÏÔÙÛÜŸÆŒ].*");
    private static final Pattern SPANISH_PATTERN = Pattern.compile(".*[A-Za-záéíóúñÁÉÍÓÚÑ¿¡].*");

    private final WordMapper wordMapper;
    private final WordBankMapper wordBankMapper;
    private final OperationLogService operationLogService;

    public PageResponse<WordResponse> getWordsByWordBankId(Long wordBankId, long current, long size) {
        requireWordBankExists(wordBankId);

        Page<Word> page = new Page<>(Math.max(current, 1L), Math.max(size, 1L));
        LambdaQueryWrapper<Word> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Word::getWordBankId, wordBankId)
                .eq(Word::getStatus, ACTIVE_STATUS)
                .apply("language = (SELECT language FROM word_bank WHERE id = {0})", wordBankId)
                .orderByAsc(Word::getId);

        Page<Word> result = wordMapper.selectPage(page, wrapper);

        PageResponse<WordResponse> response = new PageResponse<>();
        response.setCurrent(result.getCurrent());
        response.setSize(result.getSize());
        response.setTotal(result.getTotal());
        response.setRecords(result.getRecords().stream()
                .map(this::toResponse)
                .toList());
        return response;
    }

    @Transactional(rollbackFor = Exception.class)
    public WordResponse createWord(Long adminId, Long wordBankId, WordCreateRequest request, String ipAddress) {
        WordBank wordBank = requireWordBankExists(wordBankId);

        Word word = new Word();
        if (existsActiveEnglish(wordBankId, request.getEnglish().trim(), null)) {
            throw new BusinessException(400, "当前词库已存在相同英文单词");
        }
        word.setWordBankId(wordBankId);
        word.setEnglish(request.getEnglish().trim());
        validateWordTextByLanguage(word.getEnglish(), wordBank.getLanguage());
        word.setLanguage(wordBank.getLanguage());
        word.setPhonetic(StringUtils.hasText(request.getPhonetic()) ? request.getPhonetic().trim() : null);
        word.setChinese(request.getChinese().trim());
        word.setExample(StringUtils.hasText(request.getExample()) ? request.getExample().trim() : null);
        word.setStatus(ACTIVE_STATUS);

        wordMapper.insert(word);

        updateWordBankCount(wordBankId);

        operationLogService.createLog(
                adminId,
                OPERATION_CREATE,
                TARGET_TYPE_WORD,
                word.getId(),
                "在词库《" + wordBank.getName() + "》中添加单词：" + word.getEnglish(),
                ipAddress
        );

        return toResponse(word);
    }

    @Transactional(rollbackFor = Exception.class)
    public WordResponse updateWord(Long adminId, Long wordId, WordUpdateRequest request, String ipAddress) {
        Word word = requireWordExists(wordId);
        WordBank wordBank = requireWordBankExists(word.getWordBankId());
        if (existsActiveEnglish(word.getWordBankId(), request.getEnglish().trim(), wordId)) {
            throw new BusinessException(400, "当前词库已存在相同英文单词");
        }

        word.setEnglish(request.getEnglish().trim());
        validateWordTextByLanguage(word.getEnglish(), wordBank.getLanguage());
        word.setLanguage(wordBank.getLanguage());
        word.setPhonetic(StringUtils.hasText(request.getPhonetic()) ? request.getPhonetic().trim() : null);
        word.setChinese(request.getChinese().trim());
        word.setExample(StringUtils.hasText(request.getExample()) ? request.getExample().trim() : null);

        wordMapper.updateById(word);

        operationLogService.createLog(
                adminId,
                OPERATION_UPDATE,
                TARGET_TYPE_WORD,
                wordId,
                "在词库《" + wordBank.getName() + "》中修改单词：" + word.getEnglish(),
                ipAddress
        );

        return toResponse(word);
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteWord(Long adminId, Long wordId, String ipAddress) {
        Word word = requireWordExists(wordId);
        WordBank wordBank = requireWordBankExists(word.getWordBankId());

        log.info("🗑️ 开始删除单词 id={}, english={}, 当前status={}", wordId, word.getEnglish(), word.getStatus());

        int rows = wordMapper.deleteByLogic(wordId);
        log.info("🗑️ 删除单词完成 影响行数={}", rows);

        if (rows == 0) {
            throw new BusinessException(500, "删除单词失败，请稍后重试");
        }

        updateWordBankCount(word.getWordBankId());

        operationLogService.createLog(
                adminId,
                OPERATION_DELETE,
                TARGET_TYPE_WORD,
                wordId,
                "从词库《" + wordBank.getName() + "》中删除单词：" + word.getEnglish(),
                ipAddress
        );
    }

    public WordResponse getWordDetail(Long wordId) {
        Word word = requireWordExists(wordId);
        return toResponse(word);
    }

    @Transactional(rollbackFor = Exception.class)
    public WordImportResponse importWordsFromFile(Long adminId, Long wordBankId, MultipartFile file, String ipAddress) {
        WordBank wordBank = requireWordBankExists(wordBankId);

        if (file.isEmpty()) {
            throw new BusinessException(400, "导入文件不能为空");
        }

        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || !originalFilename.toLowerCase().endsWith(".txt")) {
            throw new BusinessException(400, "仅支持TXT文本文件");
        }

        if (file.getSize() > 5 * 1024 * 1024) {
            throw new BusinessException(400, "文件大小不能超过5MB");
        }

        List<WordImportFailure> failures = new ArrayList<>();
        Set<String> existingEnglishSet = new HashSet<>();
        for (String english : wordMapper.selectActiveEnglishByWordBankId(wordBankId)) {
            if (StringUtils.hasText(english)) {
                existingEnglishSet.add(english.trim().toLowerCase(Locale.ROOT));
            }
        }
        int successCount = 0;
        int lineNumber = 0;

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(file.getInputStream(), StandardCharsets.UTF_8))) {

            String line;
            while ((line = reader.readLine()) != null) {
                lineNumber++;

                String trimmedLine = line.trim();
                if (trimmedLine.isEmpty()) {
                    continue;
                }

                if (lineNumber > MAX_IMPORT_SIZE) {
                    failures.add(new WordImportFailure(
                            lineNumber,
                            trimmedLine,
                            "超过最大导入限制（" + MAX_IMPORT_SIZE + "行）"
                    ));
                    continue;
                }

                try {
                    String[] parts = trimmedLine.split("\t");
                    if (parts.length < 3) {
                        failures.add(new WordImportFailure(
                                lineNumber,
                                trimmedLine,
                                "格式错误：至少需要英文单词、音标、中文释义三列（用Tab分隔）"
                        ));
                        continue;
                    }

                    String english = parts[0].trim();
                    String phonetic = parts[1].trim();
                    String chinese = parts[2].trim();
                    String example = parts.length > 3 ? parts[3].trim() : null;

                    if (english.isEmpty() || chinese.isEmpty()) {
                        failures.add(new WordImportFailure(
                                lineNumber,
                                trimmedLine,
                                "英文单词和中文释义不能为空"
                        ));
                        continue;
                    }

                    if (english.length() > 100 || chinese.length() > 500) {
                        failures.add(new WordImportFailure(
                                lineNumber,
                                trimmedLine,
                                "内容长度超出限制"
                        ));
                        continue;
                    }
                    String normalizedEnglish = english.toLowerCase(Locale.ROOT);
                    if (existingEnglishSet.contains(normalizedEnglish)) {
                        failures.add(new WordImportFailure(
                                lineNumber,
                                trimmedLine,
                                "重复单词：当前词库已存在该英文单词"
                        ));
                        continue;
                    }

                    Word word = new Word();
                    word.setWordBankId(wordBankId);
                    word.setEnglish(english);
                    validateWordTextByLanguage(word.getEnglish(), wordBank.getLanguage());
                    word.setLanguage(wordBank.getLanguage());
                    word.setPhonetic(StringUtils.hasText(phonetic) ? phonetic : null);
                    word.setChinese(chinese);
                    word.setExample(StringUtils.hasText(example) ? example : null);
                    word.setStatus(ACTIVE_STATUS);

                    wordMapper.insert(word);
                    existingEnglishSet.add(normalizedEnglish);
                    successCount++;
                } catch (Exception e) {
                    failures.add(new WordImportFailure(
                            lineNumber,
                            trimmedLine,
                            "解析失败：" + e.getMessage()
                    ));
                }
            }
        } catch (IOException e) {
            throw new BusinessException(500, "读取文件失败：" + e.getMessage());
        }

        updateWordBankCount(wordBankId);

        operationLogService.createLog(
                adminId,
                OPERATION_IMPORT,
                TARGET_TYPE_WORD,
                wordBankId,
                "批量导入单词到词库《" + wordBank.getName() + "》，成功" + successCount + "条，失败" + failures.size() + "条",
                ipAddress
        );

        WordImportResponse response = new WordImportResponse();
        response.setTotalCount(lineNumber);
        response.setSuccessCount(successCount);
        response.setFailCount(failures.size());
        response.setFailures(failures);
        return response;
    }

    private WordBank requireWordBankExists(Long wordBankId) {
        WordBank wordBank = wordBankMapper.selectById(wordBankId);
        if (wordBank == null || wordBank.getStatus() != ACTIVE_STATUS) {
            throw new BusinessException(404, "词库不存在");
        }
        return wordBank;
    }

    private Word requireWordExists(Long wordId) {
        Word word = wordMapper.selectById(wordId);
        if (word == null || word.getStatus() != ACTIVE_STATUS) {
            throw new BusinessException(404, "单词不存在");
        }
        return word;
    }

    private void updateWordBankCount(Long wordBankId) {
        LambdaQueryWrapper<Word> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Word::getWordBankId, wordBankId)
                .eq(Word::getStatus, ACTIVE_STATUS)
                .apply("language = (SELECT language FROM word_bank WHERE id = {0})", wordBankId);
        Long count = wordMapper.selectCount(wrapper);

        log.info("📊 更新词库单词数 wordBankId={}, 新count={}", wordBankId, count);

        int rows = wordBankMapper.updateWordCount(wordBankId, count.intValue());
        if (rows == 0) {
            log.warn("⚠️ 更新词库单词数失败（可能词库已被删除） wordBankId={}", wordBankId);
        }
    }

    private WordResponse toResponse(Word word) {
        WordResponse response = new WordResponse();
        response.setId(word.getId());
        response.setWordBankId(word.getWordBankId());
        response.setEnglish(word.getEnglish());
        response.setLanguage(word.getLanguage());
        response.setPhonetic(word.getPhonetic());
        response.setChinese(word.getChinese());
        response.setExample(word.getExample());
        response.setCreatedAt(word.getCreatedAt());
        response.setUpdatedAt(word.getUpdatedAt());
        return response;
    }

    private boolean existsActiveEnglish(Long wordBankId, String english, Long excludeWordId) {
        String normalizedEnglish = english.trim().toLowerCase(Locale.ROOT);
        LambdaQueryWrapper<Word> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Word::getWordBankId, wordBankId)
                .eq(Word::getStatus, ACTIVE_STATUS)
                .apply("language = (SELECT language FROM word_bank WHERE id = {0})", wordBankId)
                .apply("LOWER(english) = {0}", normalizedEnglish);
        if (excludeWordId != null) {
            wrapper.ne(Word::getId, excludeWordId);
        }
        return wordMapper.selectCount(wrapper) > 0;
    }

    private void validateWordTextByLanguage(String text, String language) {
        if (!StringUtils.hasText(text)) {
            throw new BusinessException(400, "词条不能为空");
        }
        if (!isWordTextCompatible(text, language)) {
            throw new BusinessException(400, "词条与词库语种不匹配，当前词库语种为：" + language);
        }
    }

    private boolean isWordTextCompatible(String text, String language) {
        if ("JA".equalsIgnoreCase(language)) {
            return JAPANESE_PATTERN.matcher(text).matches();
        }
        if ("KO".equalsIgnoreCase(language)) {
            return KOREAN_PATTERN.matcher(text).matches();
        }
        if ("DE".equalsIgnoreCase(language)) {
            return GERMAN_PATTERN.matcher(text).matches();
        }
        if ("FR".equalsIgnoreCase(language)) {
            return FRENCH_PATTERN.matcher(text).matches();
        }
        if ("ES".equalsIgnoreCase(language)) {
            return SPANISH_PATTERN.matcher(text).matches();
        }
        return ENGLISH_PATTERN.matcher(text).matches();
    }
}
