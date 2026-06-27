package com.english.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.english.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    @Select("SELECT * FROM user WHERE id = #{userId}")
    User selectByIdIncludingDeleted(Long userId);

    @Update("UPDATE user SET status = #{status}, updated_at = NOW() WHERE id = #{userId}")
    int updateStatusById(@Param("userId") Long userId, @Param("status") Integer status);
}
