package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.dto.PageResponse;
import com.english.dto.VocabularyCreateRequest;
import com.english.dto.VocabularyUpdateRequest;
import com.english.dto.WordBankResponse;
import com.english.entity.User;
import com.english.entity.WordBank;
import com.english.mapper.UserMapper;
import com.english.mapper.WordBankMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminVocabularyService {

    private static final int ACTIVE_STATUS = 1;
    private static final int PUBLIC_WORD_BANK = 2;
    private static final String TARGET_TYPE_VOCABULARY = "VOCABULARY";
    private static final String OPERATION_CREATE = "VOCABULARY_CREATE";
    private static final String OPERATION_UPDATE = "VOCABULARY_UPDATE";
    private static final String OPERATION_DELETE = "VOCABULARY_DELETE";

    private final WordBankMapper wordBankMapper;
    private final UserMapper userMapper;
    private final OperationLogService operationLogService;

    public PageResponse<WordBankResponse> getPublicVocabularies(long current, long size) {
        Page<WordBank> page = new Page<>(Math.max(current, 1L), Math.max(size, 1L));
        LambdaQueryWrapper<WordBank> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WordBank::getStatus, ACTIVE_STATUS)
                .eq(WordBank::getIsPublic, PUBLIC_WORD_BANK)
                .orderByDesc(WordBank::getUpdatedAt)
                .orderByDesc(WordBank::getId);

        Page<WordBank> result = wordBankMapper.selectPage(page, wrapper);
        Map<Long, Integer> wordCountMap = getWordCountMap(result.getRecords());
        Map<Long, String> creatorNameMap = getCreatorNameMap(result.getRecords());

        PageResponse<WordBankResponse> response = new PageResponse<>();
        response.setCurrent(result.getCurrent());
        response.setSize(result.getSize());
        response.setTotal(result.getTotal());
        response.setRecords(result.getRecords().stream()
                .map(wordBank -> toResponse(wordBank, wordCountMap, creatorNameMap))
                .toList());
        return response;
    }

    @Transactional(rollbackFor = Exception.class)
    public WordBankResponse createPublicVocabulary(Long adminId, VocabularyCreateRequest request, String ipAddress) {
        WordBank vocabulary = new WordBank();
        vocabulary.setUserId(adminId);
        vocabulary.setName(request.getName().trim());
        vocabulary.setDescription(StringUtils.hasText(request.getDescription()) ? request.getDescription().trim() : null);
        vocabulary.setCategory(request.getCategory().trim());
        vocabulary.setLanguage(StringUtils.hasText(request.getLanguage()) ? request.getLanguage().trim().toUpperCase() : "EN");
        vocabulary.setWordCount(0);
        vocabulary.setIsPublic(PUBLIC_WORD_BANK);
        vocabulary.setStatus(ACTIVE_STATUS);

        wordBankMapper.insert(vocabulary);

        operationLogService.createLog(
                adminId,
                OPERATION_CREATE,
                TARGET_TYPE_VOCABULARY,
                vocabulary.getId(),
                "发布公共词库《" + vocabulary.getName() + "》",
                ipAddress
        );

        return toResponse(vocabulary, Map.of(vocabulary.getId(), 0), getCreatorNameMap(List.of(vocabulary)));
    }

    @Transactional(rollbackFor = Exception.class)
    public WordBankResponse updatePublicVocabulary(Long adminId, Long vocabularyId, VocabularyUpdateRequest request, String ipAddress) {
        WordBank vocabulary = requirePublicVocabulary(vocabularyId);

        vocabulary.setName(request.getName().trim());
        vocabulary.setDescription(StringUtils.hasText(request.getDescription()) ? request.getDescription().trim() : null);
        vocabulary.setCategory(request.getCategory().trim());

        wordBankMapper.updateById(vocabulary);

        operationLogService.createLog(
                adminId,
                OPERATION_UPDATE,
                TARGET_TYPE_VOCABULARY,
                vocabularyId,
                "更新公共词库《" + vocabulary.getName() + "》",
                ipAddress
        );

        return toResponse(vocabulary, Map.of(vocabularyId, vocabulary.getWordCount()), getCreatorNameMap(List.of(vocabulary)));
    }

    @Transactional(rollbackFor = Exception.class)
    public void deletePublicVocabulary(Long adminId, Long vocabularyId, String ipAddress) {
        WordBank vocabulary = requirePublicVocabulary(vocabularyId);

        log.info("🗑️ 开始删除公共词库 id={}, name={}, 当前status={}, version={}",
                vocabularyId, vocabulary.getName(), vocabulary.getStatus(), vocabulary.getVersion());

        int rows = wordBankMapper.deleteByLogic(vocabularyId);
        log.info("🗑️ 删除操作完成 影响行数={}", rows);

        if (rows == 0) {
            throw new BusinessException(500, "删除词库失败，请稍后重试");
        }

        operationLogService.createLog(
                adminId,
                OPERATION_DELETE,
                TARGET_TYPE_VOCABULARY,
                vocabularyId,
                "删除公共词库《" + vocabulary.getName() + "》",
                ipAddress
        );
    }

    public WordBankResponse getVocabularyDetail(Long vocabularyId) {
        WordBank vocabulary = requirePublicVocabulary(vocabularyId);
        Map<Long, Integer> wordCountMap = Map.of(vocabularyId, vocabulary.getWordCount() == null ? 0 : vocabulary.getWordCount());
        Map<Long, String> creatorNameMap = getCreatorNameMap(List.of(vocabulary));
        return toResponse(vocabulary, wordCountMap, creatorNameMap);
    }

    private WordBank requirePublicVocabulary(Long vocabularyId) {
        WordBank vocabulary = wordBankMapper.selectById(vocabularyId);
        if (vocabulary == null || vocabulary.getStatus() != ACTIVE_STATUS) {
            throw new BusinessException(404, "公共词库不存在");
        }
        if (vocabulary.getIsPublic() != PUBLIC_WORD_BANK) {
            throw new BusinessException(400, "该词库不是公共词库");
        }
        return vocabulary;
    }

    private Map<Long, Integer> getWordCountMap(List<WordBank> vocabularies) {
        List<Long> vocabularyIds = vocabularies.stream()
                .map(WordBank::getId)
                .filter(Objects::nonNull)
                .toList();
        if (vocabularyIds.isEmpty()) {
            return Map.of();
        }
        return vocabularies.stream()
                .collect(Collectors.toMap(
                        WordBank::getId,
                        wb -> wb.getWordCount() == null ? 0 : wb.getWordCount(),
                        (left, right) -> left,
                        LinkedHashMap::new
                ));
    }

    private Map<Long, String> getCreatorNameMap(List<WordBank> vocabularies) {
        List<Long> userIds = vocabularies.stream()
                .map(WordBank::getUserId)
                .filter(Objects::nonNull)
                .distinct()
                .toList();
        if (userIds.isEmpty()) {
            return Map.of();
        }

        return userMapper.selectBatchIds(userIds).stream()
                .filter(Objects::nonNull)
                .collect(Collectors.toMap(User::getId, this::resolveCreatorName, (left, right) -> left,
                        LinkedHashMap::new));
    }

    private WordBankResponse toResponse(WordBank vocabulary, Map<Long, Integer> wordCountMap,
                                        Map<Long, String> creatorNameMap) {
        WordBankResponse response = new WordBankResponse();
        response.setId(vocabulary.getId());
        response.setUserId(vocabulary.getUserId());
        response.setName(vocabulary.getName());
        response.setDescription(vocabulary.getDescription());
        response.setCategory(vocabulary.getCategory());
        response.setWordCount(wordCountMap.getOrDefault(vocabulary.getId(), vocabulary.getWordCount() == null ? 0 : vocabulary.getWordCount()));
        response.setIsPublic(vocabulary.getIsPublic());
        response.setCreatorName(creatorNameMap.get(vocabulary.getUserId()));
        response.setCollected(false);
        response.setEditable(false);
        response.setCreatedAt(vocabulary.getCreatedAt());
        response.setUpdatedAt(vocabulary.getUpdatedAt());
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
}
