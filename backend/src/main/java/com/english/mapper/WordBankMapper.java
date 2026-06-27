package com.english.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.english.entity.WordBank;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface WordBankMapper extends BaseMapper<WordBank> {

    @Select("""
            SELECT id,
                   user_id AS userId,
                   name,
                   description,
                   category,
                   language,
                   word_count AS wordCount,
                   is_public AS isPublic,
                   status,
                   version,
                   created_at AS createdAt,
                   updated_at AS updatedAt
            FROM word_bank
            WHERE status = 1
              AND (user_id = #{userId} OR is_public = 2)
              AND (#{language} IS NULL OR #{language} = '' OR language = #{language})
            ORDER BY CASE WHEN user_id = #{userId} THEN 0 ELSE 1 END,
                     created_at DESC,
                     id DESC
            """)
    List<WordBank> selectStudyWordBanks(@Param("userId") Long userId, @Param("language") String language);

    @Update("""
            UPDATE word_bank
            SET status = 0
            WHERE id = #{id}
              AND status = 1
            """)
    int deleteByLogic(@Param("id") Long id);

    @Update("""
            UPDATE word_bank
            SET word_count = #{count},
                updated_at = NOW()
            WHERE id = #{id}
              AND status = 1
            """)
    int updateWordCount(@Param("id") Long id, @Param("count") int count);
}
