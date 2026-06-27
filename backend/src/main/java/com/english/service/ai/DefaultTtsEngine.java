package com.english.service.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class DefaultTtsEngine implements TtsEngine {

    @Override
    public byte[] synthesize(String text, String language, String voice) {
        log.info("TTS语音合成处理 text={} language={} voice={}", text != null ? text.substring(0, Math.min(text.length(), 30)) : "", language, voice);

        if (text == null || text.isBlank()) {
            return new byte[0];
        }

        try {
            Thread.sleep(20);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        return new byte[]{0};
    }
}
