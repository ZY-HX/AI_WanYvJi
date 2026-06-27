package com.english.service.ai;

public interface TtsEngine {

    byte[] synthesize(String text, String language, String voice);
}
