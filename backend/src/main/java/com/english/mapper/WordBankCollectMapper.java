package com.english.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.english.entity.WordBankCollect;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface WordBankCollectMapper extends BaseMapper<WordBankCollect> {

    @Select("""
            SELECT id,
                   user_id AS userId,
                   word_bank_id AS wordBankId,
                   status,
                   created_at AS createdAt,
                   updated_at AS updatedAt
            FROM word_bank_collect
            WHERE user_id = #{userId}
              AND word_bank_id = #{wordBankId}
            LIMIT 1
            """)
    WordBankCollect selectAnyByUserIdAndWordBankId(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId
    );

    @Update("""
            UPDATE word_bank_collect
            SET status = #{status},
                updated_at = CURRENT_TIMESTAMP
            WHERE user_id = #{userId}
              AND word_bank_id = #{wordBankId}
            """)
    int updateStatusByUserIdAndWordBankId(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId,
            @Param("status") Integer status
    );

    @Select("""
            SELECT COUNT(*)
            FROM word_bank_collect wbc
            INNER JOIN word_bank wb ON wb.id = wbc.word_bank_id
            WHERE wbc.user_id = #{userId}
              AND wbc.status = 1
              AND wb.status = 1
              AND wb.is_public = 2
              AND (#{language} IS NULL OR #{language} = '' OR wb.language = #{language})
            """)
    long countVisibleCollectedWordBanks(@Param("userId") Long userId, @Param("language") String language);

    @Select("""
            SELECT wbc.word_bank_id
            FROM word_bank_collect wbc
            INNER JOIN word_bank wb ON wb.id = wbc.word_bank_id
            WHERE wbc.user_id = #{userId}
              AND wbc.status = 1
              AND wb.status = 1
              AND wb.is_public = 2
              AND (#{language} IS NULL OR #{language} = '' OR wb.language = #{language})
            ORDER BY wbc.updated_at DESC, wbc.id DESC
            LIMIT #{offset}, #{size}
            """)
    List<Long> selectVisibleCollectedWordBankIds(
            @Param("userId") Long userId,
            @Param("language") String language,
            @Param("offset") long offset,
            @Param("size") long size
    );
}
