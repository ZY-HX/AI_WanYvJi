package com.english.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.english.entity.SensitiveWord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SensitiveWordMapper extends BaseMapper<SensitiveWord> {

    @Select("""
            SELECT word
            FROM sensitive_word
            WHERE status = 1
            ORDER BY LENGTH(word) DESC, id ASC
            """)
    List<String> selectEnabledWords();
}
