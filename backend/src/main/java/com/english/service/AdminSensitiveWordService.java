package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.dto.PageResponse;
import com.english.dto.SensitiveWordRequest;
import com.english.dto.SensitiveWordResponse;
import com.english.entity.SensitiveWord;
import com.english.mapper.SensitiveWordMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class AdminSensitiveWordService {

    private static final int ENABLED_STATUS = 1;
    private static final int DISABLED_STATUS = 0;
    private static final String TARGET_TYPE_SENSITIVE_WORD = "SENSITIVE_WORD";
    private static final String OPERATION_CREATE = "SENSITIVE_WORD_CREATE";
    private static final String OPERATION_UPDATE = "SENSITIVE_WORD_UPDATE";
    private static final String OPERATION_DELETE = "SENSITIVE_WORD_DELETE";

    private final SensitiveWordMapper sensitiveWordMapper;
    private final OperationLogService operationLogService;

    public PageResponse<SensitiveWordResponse> getSensitiveWords(long current, long size, Integer status, String keyword) {
        Page<SensitiveWord> page = new Page<>(Math.max(current, 1L), Math.max(size, 1L));
        LambdaQueryWrapper<SensitiveWord> wrapper = new LambdaQueryWrapper<>();
        if (status != null) {
            wrapper.eq(SensitiveWord::getStatus, normalizeStatus(status));
        }
        wrapper.like(StringUtils.hasText(keyword), SensitiveWord::getWord, keyword == null ? null : keyword.trim())
                .orderByDesc(SensitiveWord::getUpdatedAt)
                .orderByDesc(SensitiveWord::getId);

        Page<SensitiveWord> result = sensitiveWordMapper.selectPage(page, wrapper);
        PageResponse<SensitiveWordResponse> response = new PageResponse<>();
        response.setCurrent(result.getCurrent());
        response.setSize(result.getSize());
        response.setTotal(result.getTotal());
        response.setRecords(result.getRecords().stream().map(this::toResponse).toList());
        return response;
    }

    @Transactional(rollbackFor = Exception.class)
    public SensitiveWordResponse createSensitiveWord(Long adminId, SensitiveWordRequest request, String ipAddress) {
        SensitiveWord sensitiveWord = new SensitiveWord();
        sensitiveWord.setWord(normalizeRequiredWord(request.getWord()));
        sensitiveWord.setStatus(normalizeStatusOrDefault(request.getStatus(), ENABLED_STATUS));

        insertSensitiveWord(sensitiveWord);
        operationLogService.createLog(
                adminId,
                OPERATION_CREATE,
                TARGET_TYPE_SENSITIVE_WORD,
                sensitiveWord.getId(),
                "新增敏感词：" + sensitiveWord.getWord(),
                ipAddress
        );
        return toResponse(sensitiveWord);
    }

    @Transactional(rollbackFor = Exception.class)
    public SensitiveWordResponse updateSensitiveWord(Long adminId, Long id, SensitiveWordRequest request, String ipAddress) {
        SensitiveWord sensitiveWord = requireSensitiveWord(id);
        boolean changed = false;

        if (request.getWord() != null) {
            sensitiveWord.setWord(normalizeRequiredWord(request.getWord()));
            changed = true;
        }
        if (request.getStatus() != null) {
            sensitiveWord.setStatus(normalizeStatus(request.getStatus()));
            changed = true;
        }
        if (!changed) {
            throw new BusinessException(400, "请至少提供一个需要更新的字段");
        }

        updateSensitiveWordRecord(sensitiveWord);
        operationLogService.createLog(
                adminId,
                OPERATION_UPDATE,
                TARGET_TYPE_SENSITIVE_WORD,
                sensitiveWord.getId(),
                "更新敏感词：" + sensitiveWord.getWord() + "，状态=" + sensitiveWord.getStatus(),
                ipAddress
        );
        return toResponse(requireSensitiveWord(sensitiveWord.getId()));
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteSensitiveWord(Long adminId, Long id, String ipAddress) {
        SensitiveWord sensitiveWord = requireSensitiveWord(id);
        sensitiveWordMapper.deleteById(id);
        operationLogService.createLog(
                adminId,
                OPERATION_DELETE,
                TARGET_TYPE_SENSITIVE_WORD,
                id,
                "删除敏感词：" + sensitiveWord.getWord(),
                ipAddress
        );
    }

    private void insertSensitiveWord(SensitiveWord sensitiveWord) {
        try {
            sensitiveWordMapper.insert(sensitiveWord);
        } catch (DuplicateKeyException ex) {
            throw new BusinessException(400, "敏感词已存在");
        }
    }

    private void updateSensitiveWordRecord(SensitiveWord sensitiveWord) {
        try {
            sensitiveWordMapper.updateById(sensitiveWord);
        } catch (DuplicateKeyException ex) {
            throw new BusinessException(400, "敏感词已存在");
        }
    }

    private SensitiveWord requireSensitiveWord(Long id) {
        SensitiveWord sensitiveWord = sensitiveWordMapper.selectById(id);
        if (sensitiveWord == null) {
            throw new BusinessException(404, "敏感词不存在");
        }
        return sensitiveWord;
    }

    private String normalizeRequiredWord(String word) {
        String normalized = StringUtils.trimWhitespace(word);
        if (!StringUtils.hasText(normalized)) {
            throw new BusinessException(400, "敏感词不能为空");
        }
        return normalized;
    }

    private int normalizeStatusOrDefault(Integer status, int defaultValue) {
        return status == null ? defaultValue : normalizeStatus(status);
    }

    private int normalizeStatus(Integer status) {
        if (status == null || (status != ENABLED_STATUS && status != DISABLED_STATUS)) {
            throw new BusinessException(400, "状态仅支持 0 或 1");
        }
        return status;
    }

    private SensitiveWordResponse toResponse(SensitiveWord sensitiveWord) {
        SensitiveWordResponse response = new SensitiveWordResponse();
        response.setId(sensitiveWord.getId());
        response.setWord(sensitiveWord.getWord());
        response.setStatus(sensitiveWord.getStatus());
        response.setCreatedAt(sensitiveWord.getCreatedAt());
        response.setUpdatedAt(sensitiveWord.getUpdatedAt());
        return response;
    }
}
