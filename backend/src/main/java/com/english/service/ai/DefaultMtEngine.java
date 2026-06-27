package com.english.service.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class DefaultMtEngine implements MtEngine {

    @Override
    public String translate(String text, String sourceLang, String targetLang) {
        log.info("MT机器翻译处理 text={} {}->{}", text != null ? text.substring(0, Math.min(text.length(), 50)) : "", sourceLang, targetLang);

        if (text == null || text.isBlank()) {
            return "";
        }

        try {
            Thread.sleep(30);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        String sourceName = getLanguageName(sourceLang);
        String targetName = getLanguageName(targetLang);

        return String.format("[%s→%s] %s", sourceName, targetName, text);
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
}
