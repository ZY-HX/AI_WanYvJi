package com.english.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.english.common.BusinessException;
import com.english.dto.AudioTranslateRequest;
import com.english.dto.AudioTranslateResponse;
import com.english.dto.PageResponse;
import com.english.dto.TranslationSessionCreateRequest;
import com.english.dto.TranslationSessionResponse;
import com.english.entity.TranslationSession;
import com.english.mapper.TranslationSessionMapper;
import com.english.service.ai.AsrEngine;
import com.english.service.ai.MtEngine;
import com.english.service.ai.TtsEngine;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class SimultaneousTranslationService {

    private final TranslationSessionMapper translationSessionMapper;
    private final AsrEngine asrEngine;
    private final MtEngine mtEngine;
    private final TtsEngine ttsEngine;

    private static final String SESSION_STATUS_ACTIVE = "ACTIVE";
    private static final String SESSION_STATUS_ENDED = "ENDED";
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    public TranslationSessionResponse createSession(Long userId, TranslationSessionCreateRequest request) {
        String sessionId = UUID.randomUUID().toString().replace("-", "").substring(0, 16);

        TranslationSession session = new TranslationSession();
        session.setUserId(userId);
        session.setSessionId(sessionId);
        session.setSourceLang(request.getSourceLang());
        session.setTargetLang(request.getTargetLang());
        session.setStatus(SESSION_STATUS_ACTIVE);
        session.setDuration(0);
        session.setCreatedAt(LocalDateTime.now());
        session.setUpdatedAt(LocalDateTime.now());

        translationSessionMapper.insert(session);
        log.info("创建同声翻译会话成功 userId={} sessionId={}", userId, sessionId);

        return toSessionResponse(session);
    }

    @Transactional(rollbackFor = Exception.class)
    public void endSession(Long userId, String sessionId) {
        TranslationSession session = requireActiveSession(userId, sessionId);
        session.setStatus(SESSION_STATUS_ENDED);
        session.setUpdatedAt(LocalDateTime.now());
        translationSessionMapper.updateById(session);
        log.info("结束同声翻译会话 userId={} sessionId={}", userId, sessionId);
    }

    public PageResponse<TranslationSessionResponse> getSessionHistory(Long userId, long current, long size) {
        long safeCurrent = Math.max(current, 1L);
        long safeSize = Math.max(size, 1L);
        Page<TranslationSession> page = new Page<>(safeCurrent, safeSize);

        LambdaQueryWrapper<TranslationSession> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TranslationSession::getUserId, userId)
                .orderByDesc(TranslationSession::getUpdatedAt)
                .orderByDesc(TranslationSession::getId);

        Page<TranslationSession> result = translationSessionMapper.selectPage(page, wrapper);
        PageResponse<TranslationSessionResponse> response = new PageResponse<>();
        response.setCurrent(result.getCurrent());
        response.setSize(result.getSize());
        response.setTotal(result.getTotal());
        response.setRecords(result.getRecords().stream()
                .map(this::toSessionResponse)
                .toList());
        return response;
    }

    public AudioTranslateResponse processAudioChunk(Authentication authentication, AudioTranslateRequest request) {
        Long userId = extractUserId(authentication);
        String sessionId = request.getSessionId();

        if (sessionId != null && !sessionId.isBlank()) {
            TranslationSession session = getActiveSession(userId, sessionId);
            if (session != null) {
                int currentDuration = session.getDuration() != null ? session.getDuration() : 0;
                session.setDuration(currentDuration + 1);
                session.setUpdatedAt(LocalDateTime.now());
                translationSessionMapper.updateById(session);
            }
        }

        try {
            String audioData = request.getAudioData();
            String format = request.getFormat() != null ? request.getFormat() : "wav";

            String recognizedText = asrEngine.recognize(audioData, format);
            if (recognizedText == null || recognizedText.isBlank()) {
                return buildEmptyResponse();
            }

            String translatedText = mtEngine.translate(recognizedText,
                    request.getSessionId() != null ? getSessionSourceLang(userId, request.getSessionId()) : "ZH",
                    request.getSessionId() != null ? getSessionTargetLang(userId, request.getSessionId()) : "EN");

            AudioTranslateResponse response = new AudioTranslateResponse();
            response.setText(recognizedText);
            response.setTranslation(translatedText);
            response.setConfidence("0.95");
            response.setTimestamp(System.currentTimeMillis());
            response.setIsFinal(true);

            if (sessionId != null && !sessionId.isBlank()) {
                updateSessionTranscript(userId, sessionId, recognizedText, translatedText);
            }

            return response;
        } catch (Exception e) {
            log.error("处理音频片段失败", e);
            throw new BusinessException(500, "音频处理失败：" + e.getMessage());
        }
    }

    private void updateSessionTranscript(Long userId, String sessionId, String text, String translation) {
        TranslationSession session = getActiveSession(userId, sessionId);
        if (session == null) return;

        String currentTranscript = session.getTranscript() != null ? session.getTranscript() : "";
        String currentTranslation = session.getTranslation() != null ? session.getTranslation() : "";

        session.setTranscript(currentTranscript + (currentTranscript.isEmpty() ? "" : "\n") + text);
        session.setTranslation(currentTranslation + (currentTranslation.isEmpty() ? "" : "\n") + translation);
        session.setUpdatedAt(LocalDateTime.now());
        translationSessionMapper.updateById(session);
    }

    private TranslationSession requireActiveSession(Long userId, String sessionId) {
        TranslationSession session = getActiveSession(userId, sessionId);
        if (session == null) {
            throw new BusinessException(404, "翻译会话不存在或已结束");
        }
        return session;
    }

    private TranslationSession getActiveSession(Long userId, String sessionId) {
        LambdaQueryWrapper<TranslationSession> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TranslationSession::getUserId, userId)
                .eq(TranslationSession::getSessionId, sessionId)
                .eq(TranslationSession::getStatus, SESSION_STATUS_ACTIVE)
                .last("LIMIT 1");
        return translationSessionMapper.selectOne(wrapper);
    }

    private String getSessionSourceLang(Long userId, String sessionId) {
        TranslationSession session = getActiveSession(userId, sessionId);
        return session != null ? session.getSourceLang() : "ZH";
    }

    private String getSessionTargetLang(Long userId, String sessionId) {
        TranslationSession session = getActiveSession(userId, sessionId);
        return session != null ? session.getTargetLang() : "EN";
    }

    private Long extractUserId(Authentication authentication) {
        if (authentication.getPrincipal() instanceof com.english.dto.AuthenticatedUser user) {
            return user.getUserId();
        }
        throw new BusinessException(401, "未认证");
    }

    private TranslationSessionResponse toSessionResponse(TranslationSession session) {
        TranslationSessionResponse response = new TranslationSessionResponse();
        response.setId(session.getId());
        response.setSessionId(session.getSessionId());
        response.setSourceLang(session.getSourceLang());
        response.setTargetLang(session.getTargetLang());
        response.setStatus(session.getStatus());
        response.setDuration(session.getDuration());
        response.setSourceLangName(getLanguageName(session.getSourceLang()));
        response.setTargetLangName(getLanguageName(session.getTargetLang()));
        response.setCreatedAt(session.getCreatedAt() != null ?
                session.getCreatedAt().format(FORMATTER) : null);
        return response;
    }

    private String getLanguageName(String code) {
        if (code == null) return "未知";
        return switch (code.toUpperCase()) {
            case "ZH" -> "中文";
            case "EN" -> "英语";
            case "JA" -> "日语";
            case "KO" -> "韩语";
            case "FR" -> "法语";
            case "DE" -> "德语";
            case "ES" -> "西班牙语";
            default -> code;
        };
    }

    private AudioTranslateResponse buildEmptyResponse() {
        AudioTranslateResponse response = new AudioTranslateResponse();
        response.setText("");
        response.setTranslation("");
        response.setConfidence("0");
        response.setTimestamp(System.currentTimeMillis());
        response.setIsFinal(false);
        return response;
    }
}
