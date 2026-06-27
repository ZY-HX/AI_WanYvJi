package com.english.service;

import com.english.common.BusinessException;
import com.english.dto.WordBankAddWordRequest;
import com.english.dto.WordBankResponse;
import com.english.entity.Word;
import com.english.entity.WordBank;
import com.english.mapper.UserMapper;
import com.english.mapper.WordBankCollectMapper;
import com.english.mapper.WordBankMapper;
import com.english.mapper.WordMapper;
import com.english.util.SensitiveWordFilter;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class WordBankServiceTest {

    @Mock
    private WordBankMapper wordBankMapper;

    @Mock
    private WordMapper wordMapper;

    @Mock
    private WordBankCollectMapper wordBankCollectMapper;

    @Mock
    private UserMapper userMapper;

    @Mock
    private SensitiveWordFilter sensitiveWordFilter;

    private WordBankService wordBankService;

    @BeforeEach
    void setUp() {
        wordBankService = new WordBankService(
                wordBankMapper,
                wordMapper,
                wordBankCollectMapper,
                userMapper,
                sensitiveWordFilter
        );
    }

    @Test
    void shouldAddWordToOwnedWordBank() {
        WordBank wordBank = buildWordBank(1L, 100L);
        WordBank updatedWordBank = buildWordBank(1L, 100L);
        updatedWordBank.setWordCount(3);
        WordBankAddWordRequest request = new WordBankAddWordRequest();
        request.setEnglish(" harvest ");
        request.setChinese(" 收获 ");
        request.setPhonetic("  /harvest/  ");
        request.setExample("  Farmers harvest crops in autumn.  ");

        when(wordBankMapper.selectById(100L)).thenReturn(wordBank, updatedWordBank);
        when(wordMapper.selectObjs(any())).thenReturn(List.of());
        when(wordMapper.selectCount(any())).thenReturn(3L);
        when(wordMapper.selectMaps(any())).thenReturn(List.of(Map.of(
                "word_bank_id", 100L,
                "word_count", 3
        )));

        WordBankResponse response = wordBankService.addWord(1L, 100L, request);

        ArgumentCaptor<Word> captor = ArgumentCaptor.forClass(Word.class);
        verify(wordMapper).insert(captor.capture());
        Word insertedWord = captor.getValue();
        assertEquals(100L, insertedWord.getWordBankId());
        assertEquals("harvest", insertedWord.getEnglish());
        assertEquals("收获", insertedWord.getChinese());
        assertEquals("/harvest/", insertedWord.getPhonetic());
        assertEquals("Farmers harvest crops in autumn.", insertedWord.getExample());
        assertEquals(1, insertedWord.getStatus());
        assertNotNull(response);
        assertEquals(3, response.getWordCount());
    }

    @Test
    void shouldRejectDuplicateWordInSameWordBank() {
        WordBank wordBank = buildWordBank(1L, 100L);
        WordBankAddWordRequest request = new WordBankAddWordRequest();
        request.setEnglish("Harvest");
        request.setChinese("收获");

        when(wordBankMapper.selectById(100L)).thenReturn(wordBank);
        when(wordMapper.selectObjs(any())).thenReturn(List.of("harvest"));

        BusinessException exception = expectBusinessException(() -> wordBankService.addWord(1L, 100L, request));

        assertEquals(400, exception.getCode());
        assertEquals("该词库中已存在相同英文单词", exception.getMessage());
        verify(wordMapper, never()).insert(any(Word.class));
    }

    @Test
    void shouldRejectAddingWordToOtherUsersWordBank() {
        WordBank wordBank = buildWordBank(2L, 100L);
        WordBankAddWordRequest request = new WordBankAddWordRequest();
        request.setEnglish("harvest");
        request.setChinese("收获");

        when(wordBankMapper.selectById(100L)).thenReturn(wordBank);

        BusinessException exception = expectBusinessException(() -> wordBankService.addWord(1L, 100L, request));

        assertEquals(403, exception.getCode());
        assertEquals("无权操作该词库", exception.getMessage());
        verify(wordMapper, never()).insert(any(Word.class));
    }

    private WordBank buildWordBank(Long userId, Long wordBankId) {
        WordBank wordBank = new WordBank();
        wordBank.setId(wordBankId);
        wordBank.setUserId(userId);
        wordBank.setName("我的词库");
        wordBank.setStatus(1);
        wordBank.setIsPublic(0);
        wordBank.setWordCount(2);
        return wordBank;
    }

    private BusinessException expectBusinessException(Runnable runnable) {
        try {
            runnable.run();
        } catch (BusinessException exception) {
            return exception;
        }
        fail("预期抛出 BusinessException");
        return null;
    }
}
