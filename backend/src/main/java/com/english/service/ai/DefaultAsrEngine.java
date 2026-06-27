package com.english.service.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class DefaultAsrEngine implements AsrEngine {

    @Override
    public String recognize(String audioData, String format) {
        log.debug("ASR语音识别处理 audioSize={} format={}", audioData != null ? audioData.length() : 0, format);

        if (audioData == null || audioData.isBlank()) {
            return "";
        }

        try {
            Thread.sleep(50);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        return "[语音识别结果 - 实际部署时对接真实ASR服务]";
    }
}
