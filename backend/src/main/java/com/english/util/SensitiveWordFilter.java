package com.english.util;

import com.english.mapper.SensitiveWordMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Locale;

@Component
@RequiredArgsConstructor
public class SensitiveWordFilter {

    private final SensitiveWordMapper sensitiveWordMapper;

    public boolean contains(String text) {
        return findFirstMatch(text) != null;
    }

    public String findFirstMatch(String text) {
        if (!StringUtils.hasText(text)) {
            return null;
        }

        String normalizedText = text.trim().toLowerCase(Locale.ROOT);
        List<String> sensitiveWords = sensitiveWordMapper.selectEnabledWords();
        for (String sensitiveWord : sensitiveWords) {
            if (!StringUtils.hasText(sensitiveWord)) {
                continue;
            }

            String normalizedWord = sensitiveWord.trim().toLowerCase(Locale.ROOT);
            if (!normalizedWord.isEmpty() && normalizedText.contains(normalizedWord)) {
                return sensitiveWord.trim();
            }
        }
        return null;
    }
}
