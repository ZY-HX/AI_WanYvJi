package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.dto.ErrorBookResponse;
import com.english.dto.PageResponse;
import com.english.entity.ErrorBook;
import com.english.entity.Word;
import com.english.entity.WordBank;
import com.english.mapper.ErrorBookMapper;
import com.english.mapper.WordBankMapper;
import com.english.mapper.WordMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ErrorBookService {

    private static final int ACTIVE_ERROR_BOOK_STATUS = 1;
    private static final int DELETED_ERROR_BOOK_STATUS = 0;
    private static final int MASTERED_ERROR_BOOK = 1;
    private static final Set<String> ALLOWED_ERROR_TYPES = Set.of("EN_TO_CN", "CN_TO_EN", "LISTEN", "SPELL");

    private final ErrorBookMapper errorBookMapper;
    private final WordMapper wordMapper;
    private final WordBankMapper wordBankMapper;

    public PageResponse<ErrorBookResponse> getErrorBooks(
            Long userId,
            Long wordBankId,
            String errorType,
            Integer isMastered,
            long current,
            long size
    ) {
        validateIsMastered(isMastered);
        String normalizedErrorType = normalizeErrorType(errorType);
        long safeCurrent = Math.max(current, 1L);
        long safeSize = Math.max(size, 1L);
        List<Long> filteredWordIds = resolveWordIdsByWordBankId(wordBankId);
        if (wordBankId != null && filteredWordIds.isEmpty()) {
            return buildEmptyPage(safeCurrent, safeSize);
        }

        Page<ErrorBook> page = new Page<>(safeCurrent, safeSize);
        LambdaQueryWrapper<ErrorBook> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ErrorBook::getUserId, userId)
                .eq(ErrorBook::getStatus, ACTIVE_ERROR_BOOK_STATUS)
                .eq(isMastered != null, ErrorBook::getIsMastered, isMastered)
                .eq(StringUtils.hasText(normalizedErrorType), ErrorBook::getErrorType, normalizedErrorType)
                .in(wordBankId != null, ErrorBook::getWordId, filteredWordIds)
                .orderByAsc(ErrorBook::getIsMastered)
                .orderByDesc(ErrorBook::getUpdatedAt)
                .orderByDesc(ErrorBook::getId);

        Page<ErrorBook> result = errorBookMapper.selectPage(page, wrapper);
        PageResponse<ErrorBookResponse> response = new PageResponse<>();
        response.setCurrent(result.getCurrent());
        response.setSize(result.getSize());
        response.setTotal(result.getTotal());
        response.setRecords(toResponses(result.getRecords()));
        return response;
    }

    @Transactional(rollbackFor = Exception.class)
    public int clearErrorBooks(Long userId, Long wordBankId, String errorType, Integer isMastered) {
        validateIsMastered(isMastered);
        String normalizedErrorType = normalizeErrorType(errorType);
        List<Long> filteredWordIds = null;
        if (wordBankId != null) {
            filteredWordIds = resolveWordIdsByWordBankId(wordBankId);
            if (filteredWordIds.isEmpty()) {
                return 0;
            }
        }

        LambdaUpdateWrapper<ErrorBook> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(ErrorBook::getUserId, userId)
                .eq(ErrorBook::getStatus, ACTIVE_ERROR_BOOK_STATUS)
                .eq(isMastered != null, ErrorBook::getIsMastered, isMastered)
                .eq(StringUtils.hasText(normalizedErrorType), ErrorBook::getErrorType, normalizedErrorType)
                .in(wordBankId != null, ErrorBook::getWordId, filteredWordIds)
                .set(ErrorBook::getStatus, DELETED_ERROR_BOOK_STATUS)
                .set(ErrorBook::getUpdatedAt, LocalDateTime.now());

        return errorBookMapper.update(null, updateWrapper);
    }

    @Transactional(rollbackFor = Exception.class)
    public void markMastered(Long userId, Long id) {
        LambdaQueryWrapper<ErrorBook> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ErrorBook::getId, id)
                .eq(ErrorBook::getUserId, userId)
                .eq(ErrorBook::getStatus, ACTIVE_ERROR_BOOK_STATUS);

        ErrorBook errorBook = errorBookMapper.selectOne(wrapper);
        if (errorBook == null) {
            throw new BusinessException(404, "错题记录不存在");
        }

        if (MASTERED_ERROR_BOOK == (errorBook.getIsMastered() == null ? 0 : errorBook.getIsMastered())) {
            return;
        }

        errorBook.setIsMastered(MASTERED_ERROR_BOOK);
        errorBookMapper.updateById(errorBook);
    }

    private void validateIsMastered(Integer isMastered) {
        if (isMastered != null && isMastered != 0 && isMastered != 1) {
            throw new BusinessException(400, "掌握状态参数不合法");
        }
    }

    private String normalizeErrorType(String errorType) {
        if (!StringUtils.hasText(errorType)) {
            return null;
        }

        String normalized = errorType.trim().toUpperCase(Locale.ROOT);
        if (!ALLOWED_ERROR_TYPES.contains(normalized)) {
            throw new BusinessException(400, "错误类型参数不合法");
        }
        return normalized;
    }

    private List<Long> resolveWordIdsByWordBankId(Long wordBankId) {
        if (wordBankId == null) {
            return Collections.emptyList();
        }

        QueryWrapper<Word> queryWrapper = new QueryWrapper<>();
        queryWrapper.select("id")
                .eq("word_bank_id", wordBankId)
                .eq("status", ACTIVE_ERROR_BOOK_STATUS);

        return wordMapper.selectObjs(queryWrapper).stream()
                .filter(Objects::nonNull)
                .map(value -> ((Number) value).longValue())
                .toList();
    }

    private List<ErrorBookResponse> toResponses(List<ErrorBook> errorBooks) {
        if (errorBooks == null || errorBooks.isEmpty()) {
            return List.of();
        }

        List<Long> wordIds = errorBooks.stream()
                .map(ErrorBook::getWordId)
                .filter(Objects::nonNull)
                .distinct()
                .toList();

        Map<Long, Word> wordMap = wordMapper.selectBatchIds(wordIds).stream()
                .collect(Collectors.toMap(Word::getId, word -> word, (left, right) -> left, LinkedHashMap::new));

        List<Long> wordBankIds = wordMap.values().stream()
                .map(Word::getWordBankId)
                .filter(Objects::nonNull)
                .distinct()
                .toList();

        Map<Long, WordBank> wordBankMap = wordBankMapper.selectBatchIds(wordBankIds).stream()
                .collect(Collectors.toMap(WordBank::getId, wordBank -> wordBank, (left, right) -> left, LinkedHashMap::new));

        return errorBooks.stream()
                .map(errorBook -> buildResponse(errorBook, wordMap.get(errorBook.getWordId()), wordBankMap))
                .filter(Objects::nonNull)
                .toList();
    }

    private ErrorBookResponse buildResponse(ErrorBook errorBook, Word word, Map<Long, WordBank> wordBankMap) {
        if (word == null) {
            return null;
        }

        WordBank wordBank = wordBankMap.get(word.getWordBankId());
        if (wordBank == null) {
            return null;
        }

        ErrorBookResponse response = new ErrorBookResponse();
        response.setId(errorBook.getId());
        response.setWordId(errorBook.getWordId());
        response.setWordBankId(word.getWordBankId());
        response.setWordBankName(wordBank.getName());
        response.setEnglish(word.getEnglish());
        response.setPhonetic(word.getPhonetic());
        response.setChinese(word.getChinese());
        response.setExample(word.getExample());
        response.setErrorType(errorBook.getErrorType());
        response.setErrorTimes(errorBook.getErrorTimes());
        response.setIsMastered(errorBook.getIsMastered());
        response.setCreatedAt(errorBook.getCreatedAt());
        response.setUpdatedAt(errorBook.getUpdatedAt());
        return response;
    }

    private PageResponse<ErrorBookResponse> buildEmptyPage(long current, long size) {
        PageResponse<ErrorBookResponse> response = new PageResponse<>();
        response.setCurrent(current);
        response.setSize(size);
        response.setTotal(0);
        response.setRecords(List.of());
        return response;
    }
}
