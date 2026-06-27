package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.dto.PageResponse;
import com.english.dto.WordBankAddWordRequest;
import com.english.dto.WordBankCreateRequest;
import com.english.dto.WordImportFailure;
import com.english.dto.WordImportResponse;
import com.english.dto.WordBankResponse;
import com.english.dto.WordBankUpdateRequest;
import com.english.entity.User;
import com.english.entity.Word;
import com.english.entity.WordBank;
import com.english.entity.WordBankCollect;
import com.english.mapper.UserMapper;
import com.english.mapper.WordBankMapper;
import com.english.mapper.WordBankCollectMapper;
import com.english.mapper.WordMapper;
import com.english.util.SensitiveWordFilter;
import lombok.extern.slf4j.Slf4j;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.HashMap;
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
public class WordBankService {

    private static final long MAX_IMPORT_FILE_SIZE = 5 * 1024 * 1024L;
    private static final int ACTIVE_STATUS = 1;
    private static final int PRIVATE_WORD_BANK = 0;
    private static final int REVIEWING_WORD_BANK = 1;
    private static final int PUBLIC_WORD_BANK = 2;
    private static final int COLLECTED_STATUS = 1;
    private static final int UNCOLLECTED_STATUS = 0;
    private static final String DEFAULT_LANGUAGE = "EN";
    private static final Set<String> SUPPORTED_LANGUAGES = Set.of("EN", "JA", "KO", "DE", "FR", "ES");
    private static final Pattern JAPANESE_PATTERN = Pattern.compile(".*[\\p{IsHiragana}\\p{IsKatakana}\\p{IsHan}].*");
    private static final Pattern KOREAN_PATTERN = Pattern.compile(".*[\\p{IsHangul}].*");
    private static final Pattern ENGLISH_PATTERN = Pattern.compile(".*[A-Za-z].*");
    private static final Pattern GERMAN_PATTERN = Pattern.compile(".*[A-Za-zäöüßÄÖÜ].*");
    private static final Pattern FRENCH_PATTERN = Pattern.compile(".*[A-Za-zàâçéèêëîïôùûüÿæœÀÂÇÉÈÊËÎÏÔÙÛÜŸÆŒ].*");
    private static final Pattern SPANISH_PATTERN = Pattern.compile(".*[A-Za-záéíóúñÁÉÍÓÚÑ¿¡].*");

    private final WordBankMapper wordBankMapper;
    private final WordMapper wordMapper;
    private final WordBankCollectMapper wordBankCollectMapper;
    private final UserMapper userMapper;
    private final SensitiveWordFilter sensitiveWordFilter;

    public PageResponse<WordBankResponse> getCurrentUserWordBanks(Long userId, long current, long size, String language) {
        Page<WordBank> page = new Page<>(current, size);
        String normalizedLanguage = normalizeLanguage(language, false);
        LambdaQueryWrapper<WordBank> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WordBank::getUserId, userId)
                .eq(StringUtils.hasText(normalizedLanguage), WordBank::getLanguage, normalizedLanguage)
                .orderByDesc(WordBank::getCreatedAt);

        Page<WordBank> result = wordBankMapper.selectPage(page, wrapper);
        return buildWordBankPageResponse(userId, result.getCurrent(), result.getSize(), result.getTotal(),
                result.getRecords(), false, true);
    }

    /**
     * 分页查询公开词库列表
     * 注意：由于 status 字段有 @TableLogic 注解，MyBatis-Plus 会自动添加逻辑删除条件
     * 因此不需要手动添加 status 条件，避免重复或冲突
     */
    public PageResponse<WordBankResponse> getPublicWordBanks(
            Long userId,
            long current,
            long size,
            String keyword,
            String language
    ) {
        Page<WordBank> page = new Page<>(current, size);
        String normalizedLanguage = normalizeLanguage(language, false);
        LambdaQueryWrapper<WordBank> wrapper = new LambdaQueryWrapper<>();
        /** 只查询公开状态的词库（is_public=2），status 条件由 @TableLogic 自动处理 */
        wrapper.eq(WordBank::getIsPublic, PUBLIC_WORD_BANK)
                .eq(StringUtils.hasText(normalizedLanguage), WordBank::getLanguage, normalizedLanguage)
                .and(StringUtils.hasText(keyword), query -> query
                        .like(WordBank::getName, keyword)
                        .or()
                        .like(WordBank::getDescription, keyword))
                .orderByDesc(WordBank::getUpdatedAt)
                .orderByDesc(WordBank::getId);

        Page<WordBank> result = wordBankMapper.selectPage(page, wrapper);
        return buildWordBankPageResponse(userId, result.getCurrent(), result.getSize(), result.getTotal(),
                result.getRecords(), true, false);
    }

    public PageResponse<WordBankResponse> getCollectedWordBanks(Long userId, long current, long size, String language) {
        long safeCurrent = Math.max(current, 1L);
        long safeSize = Math.max(size, 1L);
        String normalizedLanguage = normalizeLanguage(language, false);
        long total = wordBankCollectMapper.countVisibleCollectedWordBanks(userId, normalizedLanguage);

        List<WordBank> records = List.of();
        if (total > 0) {
            long offset = (safeCurrent - 1) * safeSize;
            List<Long> wordBankIds =
                    wordBankCollectMapper.selectVisibleCollectedWordBankIds(userId, normalizedLanguage, offset, safeSize);
            records = getWordBanksInOrder(wordBankIds);
        }

        return buildWordBankPageResponse(userId, safeCurrent, safeSize, total, records, true, false);
    }

    public WordBankResponse getWordBankDetail(Long userId, Long wordBankId) {
        WordBank wordBank = requireOwnedWordBank(userId, wordBankId);
        return toResponse(wordBank, getWordCountMap(List.of(wordBankId)), Map.of(), Set.of(), false, true);
    }

    @Transactional(rollbackFor = Exception.class)
    public WordBankResponse createWordBank(Long userId, WordBankCreateRequest request) {
        WordBank wordBank = new WordBank();
        wordBank.setUserId(userId);
        String name = normalizeRequired(request.getName(), "????????");
        validateWordBankName(name);
        wordBank.setName(name);
        wordBank.setDescription(normalizeOptional(request.getDescription()));
        wordBank.setCategory("自定义");
        wordBank.setLanguage(normalizeLanguage(request.getLanguage(), true));
        wordBank.setWordCount(0);
        wordBank.setIsPublic(PRIVATE_WORD_BANK);
        wordBank.setStatus(1);
        wordBank.setVersion(0);

        wordBankMapper.insert(wordBank);
        return getWordBankDetail(userId, wordBank.getId());
    }

    @Transactional(rollbackFor = Exception.class)
    public WordBankResponse updateWordBank(Long userId, Long wordBankId, WordBankUpdateRequest request) {
        WordBank wordBank = requireOwnedWordBank(userId, wordBankId);
        String name = normalizeRequired(request.getName(), "????????");
        validateWordBankName(name);
        wordBank.setName(name);
        wordBank.setDescription(normalizeOptional(request.getDescription()));
        wordBank.setLanguage(normalizeLanguage(request.getLanguage(), true));
        wordBankMapper.updateById(wordBank);
        return getWordBankDetail(userId, wordBankId);
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteWordBank(Long userId, Long wordBankId) {
        WordBank wordBank = requireOwnedWordBank(userId, wordBankId);
        wordBankMapper.deleteById(wordBank.getId());

        LambdaUpdateWrapper<Word> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Word::getWordBankId, wordBankId)
                .set(Word::getStatus, 0);
        wordMapper.update(null, updateWrapper);
    }

    @Transactional(rollbackFor = Exception.class)
    public WordBankResponse submitWordBankReview(Long userId, Long wordBankId) {
        WordBank wordBank = requireOwnedWordBank(userId, wordBankId);
        int activeWordCount = countActiveWords(wordBankId);
        if (activeWordCount <= 0) {
            throw new BusinessException(400, "空词库不能申请公开，请先导入单词");
        }
        if (!Objects.equals(wordBank.getIsPublic(), PRIVATE_WORD_BANK)) {
            if (Objects.equals(wordBank.getIsPublic(), REVIEWING_WORD_BANK)) {
                throw new BusinessException(400, "该词库正在审核中，请勿重复提交");
            }
            throw new BusinessException(400, "已公开的词库无需重复提交审核");
        }

        wordBank.setIsPublic(REVIEWING_WORD_BANK);
        wordBank.setWordCount(activeWordCount);
        wordBankMapper.updateById(wordBank);
        return getWordBankDetail(userId, wordBankId);
    }

    @Transactional(rollbackFor = Exception.class)
    public void collectWordBank(Long userId, Long wordBankId) {
        WordBank wordBank = requireCollectablePublicWordBank(userId, wordBankId);
        WordBankCollect existing = wordBankCollectMapper.selectAnyByUserIdAndWordBankId(userId, wordBankId);
        if (existing == null) {
            WordBankCollect collect = new WordBankCollect();
            collect.setUserId(userId);
            collect.setWordBankId(wordBank.getId());
            collect.setStatus(COLLECTED_STATUS);
            wordBankCollectMapper.insert(collect);
            return;
        }

        if (Objects.equals(existing.getStatus(), COLLECTED_STATUS)) {
            return;
        }
        wordBankCollectMapper.updateStatusByUserIdAndWordBankId(userId, wordBankId, COLLECTED_STATUS);
    }

    @Transactional(rollbackFor = Exception.class)
    public void cancelCollectWordBank(Long userId, Long wordBankId) {
        WordBankCollect existing = wordBankCollectMapper.selectAnyByUserIdAndWordBankId(userId, wordBankId);
        if (existing == null || Objects.equals(existing.getStatus(), UNCOLLECTED_STATUS)) {
            return;
        }
        wordBankCollectMapper.updateStatusByUserIdAndWordBankId(userId, wordBankId, UNCOLLECTED_STATUS);
    }

    @Transactional(rollbackFor = Exception.class)
    public WordImportResponse importWords(Long userId, Long wordBankId, MultipartFile file) {
        try {
            WordBank wordBank = requireOwnedWordBank(userId, wordBankId);
            validateImportFile(file);

            List<String> lines = readImportLines(file);
            if (lines.isEmpty()) {
                throw new BusinessException(400, "TXT 文件内容为空");
            }

            Set<String> existingEnglishKeys = getExistingEnglishKeys(wordBankId);
            Set<String> currentFileEnglishKeys = new HashSet<>();
            List<WordImportFailure> failedLines = new ArrayList<>();
            List<Word> wordsToInsert = new ArrayList<>();

            for (int index = 0; index < lines.size(); index++) {
                int lineNumber = index + 1;
                String rawLine = stripBom(lines.get(index));
                String trimmedLine = StringUtils.trimWhitespace(rawLine);

                if (!StringUtils.hasText(trimmedLine)) {
                    failedLines.add(buildFailure(lineNumber, rawLine, "该行内容为空"));
                    continue;
                }

                ParsedWordLine parsedWordLine = parseWordLine(trimmedLine);
                if (parsedWordLine == null) {
                    failedLines.add(buildFailure(lineNumber, rawLine, "格式错误，请使用“英文,中文”或“英文 中文”"));
                    continue;
                }

                String english = normalizeRequired(parsedWordLine.english(), "英文单词不能为空");
                String chinese = normalizeRequired(parsedWordLine.chinese(), "中文释义不能为空");
                if (!isWordTextCompatible(english, wordBank.getLanguage())) {
                    failedLines.add(buildFailure(lineNumber, rawLine,
                            "词条与词库语种不匹配，当前词库语种为：" + wordBank.getLanguage()));
                    continue;
                }
                String englishKey = english.toLowerCase(Locale.ROOT);

                if (existingEnglishKeys.contains(englishKey)) {
                    failedLines.add(buildFailure(lineNumber, rawLine, "该词库中已存在相同英文单词"));
                    continue;
                }
                if (!currentFileEnglishKeys.add(englishKey)) {
                    failedLines.add(buildFailure(lineNumber, rawLine, "文件内存在重复英文单词"));
                    continue;
                }

                Word word = new Word();
                word.setWordBankId(wordBankId);
                word.setEnglish(english);
                word.setLanguage(wordBank.getLanguage());
                word.setChinese(chinese);
                word.setStatus(1);
                wordsToInsert.add(word);
            }

            for (Word word : wordsToInsert) {
                wordMapper.insert(word);
            }

            int wordCount = refreshWordBankWordCount(userId, wordBankId);

            WordImportResponse response = new WordImportResponse();
            response.setTotalLines(lines.size());
            response.setImportedCount(wordsToInsert.size());
            response.setFailedCount(failedLines.size());
            response.setWordCount(wordCount);
            response.setFailedLines(failedLines);
            return response;
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.error("TXT 导入失败, userId={}, wordBankId={}", userId, wordBankId, e);
            throw new BusinessException(500, "TXT 导入失败，请稍后重试", true);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public WordBankResponse addWord(Long userId, Long wordBankId, WordBankAddWordRequest request) {
        WordBank wordBank = requireOwnedWordBank(userId, wordBankId);

        String english = normalizeRequired(request.getEnglish(), "英文单词不能为空");
        String chinese = normalizeRequired(request.getChinese(), "中文释义不能为空");
        if (!isWordTextCompatible(english, wordBank.getLanguage())) {
            throw new BusinessException(400, "词条与词库语种不匹配，当前词库语种为：" + wordBank.getLanguage());
        }
        String englishKey = english.toLowerCase(Locale.ROOT);
        if (getExistingEnglishKeys(wordBankId).contains(englishKey)) {
            throw new BusinessException(400, "该词库中已存在相同英文单词");
        }

        Word word = new Word();
        word.setWordBankId(wordBankId);
        word.setEnglish(english);
        word.setLanguage(wordBank.getLanguage());
        word.setPhonetic(normalizeOptional(request.getPhonetic()));
        word.setChinese(chinese);
        word.setExample(normalizeOptional(request.getExample()));
        word.setStatus(ACTIVE_STATUS);
        wordMapper.insert(word);

        refreshWordBankWordCount(userId, wordBankId);
        return getWordBankDetail(userId, wordBankId);
    }

    private WordBank requireOwnedWordBank(Long userId, Long wordBankId) {
        WordBank wordBank = wordBankMapper.selectById(wordBankId);
        if (wordBank == null) {
            throw new BusinessException(404, "词库不存在");
        }
        if (!wordBank.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权操作该词库");
        }
        return wordBank;
    }

    private WordBank requireCollectablePublicWordBank(Long userId, Long wordBankId) {
        LambdaQueryWrapper<WordBank> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WordBank::getId, wordBankId)
                .eq(WordBank::getStatus, ACTIVE_STATUS)
                .eq(WordBank::getIsPublic, PUBLIC_WORD_BANK);

        WordBank wordBank = wordBankMapper.selectOne(wrapper);
        if (wordBank == null) {
            throw new BusinessException(404, "公开词库不存在或暂不可收藏");
        }
        if (Objects.equals(wordBank.getUserId(), userId)) {
            throw new BusinessException(400, "不能收藏自己创建的词库");
        }
        return wordBank;
    }

    private PageResponse<WordBankResponse> buildWordBankPageResponse(
            Long currentUserId,
            long current,
            long size,
            long total,
            List<WordBank> wordBanks,
            boolean includeCollectedState,
            boolean editable
    ) {
        List<Long> wordBankIds = wordBanks.stream()
                .map(WordBank::getId)
                .filter(Objects::nonNull)
                .toList();
        Map<Long, Integer> wordCountMap = getWordCountMap(wordBankIds);
        Map<Long, String> creatorNameMap = getCreatorNameMap(wordBanks);
        Set<Long> collectedWordBankIds = includeCollectedState
                ? getCollectedWordBankIds(currentUserId, wordBankIds)
                : Set.of();

        PageResponse<WordBankResponse> response = new PageResponse<>();
        response.setCurrent(current);
        response.setSize(size);
        response.setTotal(total);
        response.setRecords(wordBanks.stream()
                .map(wordBank -> toResponse(wordBank, wordCountMap, creatorNameMap, collectedWordBankIds,
                        includeCollectedState, editable))
                .collect(Collectors.toList()));
        return response;
    }

    private Map<Long, Integer> getWordCountMap(List<Long> wordBankIds) {
        if (wordBankIds.isEmpty()) {
            return Map.of();
        }

        QueryWrapper<Word> queryWrapper = new QueryWrapper<>();
        queryWrapper.select("word_bank_id", "COUNT(*) AS word_count")
                .in("word_bank_id", wordBankIds)
                .eq("status", 1)
                .groupBy("word_bank_id");

        Map<Long, Integer> countMap = new HashMap<>();
        List<Map<String, Object>> rows = wordMapper.selectMaps(queryWrapper);
        for (Map<String, Object> row : rows) {
            Object bankIdValue = row.get("word_bank_id");
            Object countValue = row.get("word_count");
            if (bankIdValue instanceof Number bankId && countValue instanceof Number count) {
                countMap.put(bankId.longValue(), count.intValue());
            }
        }
        return countMap;
    }

    private Map<Long, String> getCreatorNameMap(List<WordBank> wordBanks) {
        List<Long> userIds = wordBanks.stream()
                .map(WordBank::getUserId)
                .filter(Objects::nonNull)
                .distinct()
                .toList();
        if (userIds.isEmpty()) {
            return Map.of();
        }

        return userMapper.selectBatchIds(userIds).stream()
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(User::getId))
                .collect(Collectors.toMap(
                        User::getId,
                        this::resolveCreatorName,
                        (left, right) -> left,
                        LinkedHashMap::new
                ));
    }

    private Set<Long> getCollectedWordBankIds(Long userId, List<Long> wordBankIds) {
        if (wordBankIds.isEmpty()) {
            return Set.of();
        }

        LambdaQueryWrapper<WordBankCollect> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WordBankCollect::getUserId, userId)
                .eq(WordBankCollect::getStatus, COLLECTED_STATUS)
                .in(WordBankCollect::getWordBankId, wordBankIds);

        return wordBankCollectMapper.selectList(wrapper).stream()
                .map(WordBankCollect::getWordBankId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
    }

    private List<WordBank> getWordBanksInOrder(List<Long> wordBankIds) {
        if (wordBankIds.isEmpty()) {
            return List.of();
        }

        List<WordBank> wordBanks = wordBankMapper.selectBatchIds(wordBankIds);
        Map<Long, WordBank> wordBankMap = wordBanks.stream()
                .filter(wordBank -> wordBank.getStatus() != null && wordBank.getStatus() == ACTIVE_STATUS)
                .filter(wordBank -> wordBank.getIsPublic() != null && wordBank.getIsPublic() == PUBLIC_WORD_BANK)
                .collect(Collectors.toMap(WordBank::getId, wordBank -> wordBank, (left, right) -> left));

        return wordBankIds.stream()
                .map(wordBankMap::get)
                .filter(Objects::nonNull)
                .toList();
    }

    private WordBankResponse toResponse(
            WordBank wordBank,
            Map<Long, Integer> wordCountMap,
            Map<Long, String> creatorNameMap,
            Set<Long> collectedWordBankIds,
            boolean includeCollectedState,
            boolean editable
    ) {
        WordBankResponse response = new WordBankResponse();
        response.setId(wordBank.getId());
        response.setUserId(wordBank.getUserId());
        response.setName(wordBank.getName());
        response.setDescription(wordBank.getDescription());
        response.setCategory(wordBank.getCategory());
        response.setLanguage(wordBank.getLanguage());
        response.setWordCount(wordCountMap.getOrDefault(wordBank.getId(), 0));
        response.setIsPublic(wordBank.getIsPublic());
        response.setCreatorName(creatorNameMap.get(wordBank.getUserId()));
        response.setCollected(includeCollectedState && collectedWordBankIds.contains(wordBank.getId()));
        response.setEditable(editable);
        response.setCreatedAt(wordBank.getCreatedAt());
        response.setUpdatedAt(wordBank.getUpdatedAt());
        return response;
    }

    private String resolveCreatorName(User user) {
        if (StringUtils.hasText(user.getNickname())) {
            return user.getNickname().trim();
        }
        if (StringUtils.hasText(user.getUsername())) {
            return user.getUsername().trim();
        }
        return "未知用户";
    }

    private void validateImportFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(400, "请选择要导入的 TXT 文件");
        }
        if (file.getSize() > MAX_IMPORT_FILE_SIZE) {
            throw new BusinessException(400, "TXT 文件大小不能超过5MB");
        }

        String filename = file.getOriginalFilename();
        if (!StringUtils.hasText(filename) || !filename.toLowerCase(Locale.ROOT).endsWith(".txt")) {
            throw new BusinessException(400, "仅支持导入 .txt 格式文件");
        }
    }

    private List<String> readImportLines(MultipartFile file) {
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(file.getInputStream(), StandardCharsets.UTF_8))) {
            return reader.lines().toList();
        } catch (IOException e) {
            throw new BusinessException(400, "TXT 文件读取失败，请确认文件编码为 UTF-8");
        }
    }

    private Set<String> getExistingEnglishKeys(Long wordBankId) {
        QueryWrapper<Word> queryWrapper = new QueryWrapper<>();
        queryWrapper.select("english")
                .eq("word_bank_id", wordBankId)
                .eq("status", 1)
                .apply("language = (SELECT language FROM word_bank WHERE id = {0})", wordBankId);

        return wordMapper.selectObjs(queryWrapper).stream()
                .filter(Objects::nonNull)
                .map(String::valueOf)
                .filter(StringUtils::hasText)
                .map(value -> value.trim().toLowerCase(Locale.ROOT))
                .collect(Collectors.toSet());
    }

    private int countActiveWords(Long wordBankId) {
        LambdaQueryWrapper<Word> countWrapper = new LambdaQueryWrapper<>();
        countWrapper.eq(Word::getWordBankId, wordBankId)
                .eq(Word::getStatus, 1)
                .apply("language = (SELECT language FROM word_bank WHERE id = {0})", wordBankId);
        return Math.toIntExact(wordMapper.selectCount(countWrapper));
    }

    private int refreshWordBankWordCount(Long userId, Long wordBankId) {
        int wordCount = countActiveWords(wordBankId);
        WordBank wordBank = requireOwnedWordBank(userId, wordBankId);
        wordBank.setWordCount(wordCount);
        wordBankMapper.updateById(wordBank);
        return wordCount;
    }

    private WordImportFailure buildFailure(int lineNumber, String content, String reason) {
        WordImportFailure failure = new WordImportFailure();
        failure.setLineNumber(lineNumber);
        failure.setContent(content);
        failure.setReason(reason);
        return failure;
    }

    private ParsedWordLine parseWordLine(String line) {
        String[] parts;
        if (line.contains(",")) {
            parts = line.split("\\s*,\\s*", 2);
        } else {
            parts = line.split("\\s+", 2);
        }

        if (parts.length < 2) {
            return null;
        }

        String english = StringUtils.trimWhitespace(parts[0]);
        String chinese = StringUtils.trimWhitespace(parts[1]);
        if (!StringUtils.hasText(english) || !StringUtils.hasText(chinese)) {
            return null;
        }
        return new ParsedWordLine(english, chinese);
    }

    private String stripBom(String value) {
        if (value != null && !value.isEmpty() && value.charAt(0) == '\uFEFF') {
            return value.substring(1);
        }
        return value;
    }

    private String normalizeRequired(String value, String emptyMessage) {
        String normalized = StringUtils.trimWhitespace(value);
        if (!StringUtils.hasText(normalized)) {
            throw new BusinessException(400, emptyMessage);
        }
        return normalized;
    }

    private void validateWordBankName(String name) {
        String matchedWord = sensitiveWordFilter.findFirstMatch(name);
        if (matchedWord != null) {
            throw new BusinessException(400, "词库名称包含敏感词：" + matchedWord);
        }
    }

    private String normalizeOptional(String value) {
        String normalized = StringUtils.trimWhitespace(value);
        return StringUtils.hasText(normalized) ? normalized : null;
    }

    private String normalizeLanguage(String language, boolean useDefaultWhenEmpty) {
        String normalized = StringUtils.trimWhitespace(language);
        if (!StringUtils.hasText(normalized)) {
            return useDefaultWhenEmpty ? DEFAULT_LANGUAGE : null;
        }
        String uppercaseLanguage = normalized.toUpperCase(Locale.ROOT);
        if (!SUPPORTED_LANGUAGES.contains(uppercaseLanguage)) {
            throw new BusinessException(400, "暂不支持该语种，仅支持 EN、JA、KO、DE、FR、ES");
        }
        return uppercaseLanguage;
    }

    private boolean isWordTextCompatible(String text, String language) {
        if (!StringUtils.hasText(text)) {
            return false;
        }
        String normalizedLanguage = normalizeLanguage(language, true);
        return switch (normalizedLanguage) {
            case "JA" -> JAPANESE_PATTERN.matcher(text).matches();
            case "KO" -> KOREAN_PATTERN.matcher(text).matches();
            case "DE" -> GERMAN_PATTERN.matcher(text).matches();
            case "FR" -> FRENCH_PATTERN.matcher(text).matches();
            case "ES" -> SPANISH_PATTERN.matcher(text).matches();
            default -> ENGLISH_PATTERN.matcher(text).matches();
        };
    }

    private record ParsedWordLine(String english, String chinese) {
    }

    public WordBank exportWordBankAsTxt(Long userId, Long wordBankId) {
        WordBank wordBank = wordBankMapper.selectById(wordBankId);
        if (wordBank == null) {
            throw new BusinessException(404, "词库不存在");
        }
        if (wordBank.getStatus() == null || wordBank.getStatus() != ACTIVE_STATUS) {
            throw new BusinessException(404, "词库不存在或已下架");
        }
        if (wordBank.getIsPublic() == null || wordBank.getIsPublic() != PUBLIC_WORD_BANK) {
            throw new BusinessException(400, "仅支持下载已公开的共享词库");
        }
        return wordBank;
    }

    public List<Word> getWordsForExport(Long wordBankId) {
        LambdaQueryWrapper<Word> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Word::getWordBankId, wordBankId)
                .eq(Word::getStatus, ACTIVE_STATUS)
                .apply("language = (SELECT language FROM word_bank WHERE id = {0})", wordBankId)
                .orderByAsc(Word::getId);
        return wordMapper.selectList(wrapper);
    }

    public String generateTxtContent(List<Word> words) {
        StringBuilder sb = new StringBuilder();
        for (Word word : words) {
            String line = word.getEnglish();
            if (StringUtils.hasText(word.getPhonetic())) {
                line += " " + word.getPhonetic();
            }
            line += " " + word.getChinese();
            sb.append(line).append("\n");
        }
        return sb.toString();
    }

    public String generateDownloadFileName(WordBank wordBank) {
        String safeName = wordBank.getName().replaceAll("[\\\\/:*?\"<>|]", "_");
        return safeName + ".txt";
    }
}
