package com.english.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.english.entity.Word;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface WordMapper extends BaseMapper<Word> {

    @Select("""
            SELECT COUNT(*)
            FROM word w
            WHERE w.word_bank_id = #{wordBankId}
              AND w.status = 1
              AND w.language = (SELECT wb.language FROM word_bank wb WHERE wb.id = #{wordBankId} LIMIT 1)
              AND NOT EXISTS (
                    SELECT 1
                    FROM user_study_record usr
                    WHERE usr.user_id = #{userId}
                      AND usr.word_bank_id = #{wordBankId}
                      AND usr.word_id = w.id
              )
            """)
    long countUnlearnedWords(@Param("userId") Long userId, @Param("wordBankId") Long wordBankId);

    @Select("""
            SELECT w.id,
                   w.word_bank_id AS wordBankId,
                   w.english,
                   w.language,
                   w.phonetic,
                   w.chinese,
                   w.example,
                   w.status,
                   w.created_at AS createdAt,
                   w.updated_at AS updatedAt
            FROM word w
            WHERE w.word_bank_id = #{wordBankId}
              AND w.status = 1
              AND w.language = (SELECT wb.language FROM word_bank wb WHERE wb.id = #{wordBankId} LIMIT 1)
              AND NOT EXISTS (
                    SELECT 1
                    FROM user_study_record usr
                    WHERE usr.user_id = #{userId}
                      AND usr.word_bank_id = #{wordBankId}
                      AND usr.word_id = w.id
              )
            ORDER BY w.id ASC
            LIMIT #{limit}
            """)
    List<Word> selectFirstUnlearnedWords(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId,
            @Param("limit") long limit
    );

    @Select("""
            SELECT w.id,
                   w.word_bank_id AS wordBankId,
                   w.english,
                   w.language,
                   w.phonetic,
                   w.chinese,
                   w.example,
                   w.status,
                   w.created_at AS createdAt,
                   w.updated_at AS updatedAt
            FROM word w
            WHERE w.word_bank_id = #{wordBankId}
              AND w.status = 1
              AND w.language = (SELECT wb.language FROM word_bank wb WHERE wb.id = #{wordBankId} LIMIT 1)
            ORDER BY RAND()
            LIMIT #{limit}
            """)
    List<Word> selectRandomWords(
            @Param("wordBankId") Long wordBankId,
            @Param("limit") long limit
    );

    @Select("""
            SELECT w.id,
                   w.word_bank_id AS wordBankId,
                   w.english,
                   w.language,
                   w.phonetic,
                   w.chinese,
                   w.example,
                   w.status,
                   w.created_at AS createdAt,
                   w.updated_at AS updatedAt
            FROM word w
            WHERE LOWER(w.english) = LOWER(#{english})
              AND w.status = 1
            LIMIT 1
            """)
    Word selectByEnglish(@Param("english") String english);

    @Select("""
            SELECT english
            FROM word
            WHERE word_bank_id = #{wordBankId}
              AND status = 1
              AND language = (SELECT wb.language FROM word_bank wb WHERE wb.id = #{wordBankId} LIMIT 1)
            """)
    List<String> selectActiveEnglishByWordBankId(@Param("wordBankId") Long wordBankId);

    @Update("""
            UPDATE word
            SET status = 0
            WHERE id = #{id}
              AND status = 1
            """)
    int deleteByLogic(@Param("id") Long id);
}
