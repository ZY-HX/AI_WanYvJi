package com.english.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.english.entity.ErrorBook;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface ErrorBookMapper extends BaseMapper<ErrorBook> {

    @Select("""
            SELECT COUNT(*)
            FROM error_book
            WHERE user_id = #{userId}
              AND status = 1
            """)
    long countUserErrorBooks(@Param("userId") Long userId);
}
