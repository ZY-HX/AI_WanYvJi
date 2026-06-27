package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.dto.PageResponse;
import com.english.dto.WordBankAuditRequest;
import com.english.dto.WordBankResponse;
import com.english.entity.User;
import com.english.entity.Word;
import com.english.entity.WordBank;
import com.english.mapper.UserMapper;
import com.english.mapper.WordBankMapper;
import com.english.mapper.WordMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminWordBankService {

    private static final int ACTIVE_STATUS = 1;
    private static final int PRIVATE_WORD_BANK = 0;
    private static final int REVIEWING_WORD_BANK = 1;
    private static final int PUBLIC_WORD_BANK = 2;
    private static final String AUDIT_NOTIFICATION_TYPE = "AUDIT";
    private static final String TARGET_TYPE_WORDBANK = "WORDBANK";
    private static final String OPERATION_APPROVE = "WORDBANK_APPROVE";
    private static final String OPERATION_REJECT = "WORDBANK_REJECT";

    private final WordBankMapper wordBankMapper;
    private final WordMapper wordMapper;
    private final UserMapper userMapper;
    private final NotificationService notificationService;
    private final OperationLogService operationLogService;

    public PageResponse<WordBankResponse> getPendingWordBanks(long current, long size) {
        Page<WordBank> page = new Page<>(Math.max(current, 1L), Math.max(size, 1L));
        LambdaQueryWrapper<WordBank> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WordBank::getStatus, ACTIVE_STATUS)
                .eq(WordBank::getIsPublic, REVIEWING_WORD_BANK)
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
    public WordBankResponse auditWordBank(Long adminId, Long wordBankId, WordBankAuditRequest request, String ipAddress) {
        WordBank wordBank = requirePendingWordBank(wordBankId);
        int activeWordCount = countActiveWords(wordBankId);
        if (activeWordCount <= 0) {
            throw new BusinessException(400, "待审核词库为空，无法完成审核");
        }

        String reason = normalizeOptional(request.getReason());
        if (!Boolean.TRUE.equals(request.getApproved()) && !StringUtils.hasText(reason)) {
            throw new BusinessException(400, "拒绝审核时必须填写理由");
        }

        wordBank.setWordCount(activeWordCount);
        if (Boolean.TRUE.equals(request.getApproved())) {
            wordBank.setIsPublic(PUBLIC_WORD_BANK);
            wordBankMapper.updateById(wordBank);
            notificationService.createNotification(
                    wordBank.getUserId(),
                    "词库公开审核通过",
                    "你提交公开审核的词库《" + wordBank.getName() + "》已通过审核，现已在共享词库广场公开展示。",
                    AUDIT_NOTIFICATION_TYPE
            );
            operationLogService.createLog(
                    adminId,
                    OPERATION_APPROVE,
                    TARGET_TYPE_WORDBANK,
                    wordBankId,
                    "审核通过词库《" + wordBank.getName() + "》",
                    ipAddress
            );
        } else {
            wordBank.setIsPublic(PRIVATE_WORD_BANK);
            wordBankMapper.updateById(wordBank);
            notificationService.createNotification(
                    wordBank.getUserId(),
                    "词库公开审核未通过",
                    "你提交公开审核的词库《" + wordBank.getName() + "》未通过审核。拒绝理由：" + reason,
                    AUDIT_NOTIFICATION_TYPE
            );
            operationLogService.createLog(
                    adminId,
                    OPERATION_REJECT,
                    TARGET_TYPE_WORDBANK,
                    wordBankId,
                    "审核拒绝词库《" + wordBank.getName() + "》，理由：" + reason,
                    ipAddress
            );
        }

        return toResponse(wordBank, Map.of(wordBankId, activeWordCount), getCreatorNameMap(List.of(wordBank)));
    }

    private WordBank requirePendingWordBank(Long wordBankId) {
        LambdaQueryWrapper<WordBank> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WordBank::getId, wordBankId)
                .eq(WordBank::getStatus, ACTIVE_STATUS)
                .eq(WordBank::getIsPublic, REVIEWING_WORD_BANK);
        WordBank wordBank = wordBankMapper.selectOne(wrapper);
        if (wordBank == null) {
            throw new BusinessException(404, "待审核词库不存在");
        }
        return wordBank;
    }

    private int countActiveWords(Long wordBankId) {
        LambdaQueryWrapper<Word> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Word::getWordBankId, wordBankId)
                .eq(Word::getStatus, ACTIVE_STATUS);
        return Math.toIntExact(wordMapper.selectCount(wrapper));
    }

    private Map<Long, Integer> getWordCountMap(List<WordBank> wordBanks) {
        List<Long> wordBankIds = wordBanks.stream()
                .map(WordBank::getId)
                .filter(Objects::nonNull)
                .toList();
        if (wordBankIds.isEmpty()) {
            return Map.of();
        }

        LambdaQueryWrapper<Word> wrapper = new LambdaQueryWrapper<>();
        wrapper.select(Word::getWordBankId)
                .in(Word::getWordBankId, wordBankIds)
                .eq(Word::getStatus, ACTIVE_STATUS);

        return wordMapper.selectList(wrapper).stream()
                .collect(Collectors.groupingBy(Word::getWordBankId, Collectors.summingInt(item -> 1)));
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
                .collect(Collectors.toMap(User::getId, this::resolveCreatorName, (left, right) -> left,
                        LinkedHashMap::new));
    }

    private WordBankResponse toResponse(WordBank wordBank, Map<Long, Integer> wordCountMap,
                                        Map<Long, String> creatorNameMap) {
        WordBankResponse response = new WordBankResponse();
        response.setId(wordBank.getId());
        response.setUserId(wordBank.getUserId());
        response.setName(wordBank.getName());
        response.setDescription(wordBank.getDescription());
        response.setCategory(wordBank.getCategory());
        response.setLanguage(wordBank.getLanguage());
        response.setWordCount(wordCountMap.getOrDefault(wordBank.getId(), wordBank.getWordCount() == null ? 0 : wordBank.getWordCount()));
        response.setIsPublic(wordBank.getIsPublic());
        response.setCreatorName(creatorNameMap.get(wordBank.getUserId()));
        response.setCollected(false);
        response.setEditable(false);
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

    private String normalizeOptional(String value) {
        String normalized = StringUtils.trimWhitespace(value);
        return StringUtils.hasText(normalized) ? normalized : null;
    }
}
