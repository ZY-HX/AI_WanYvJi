package com.english.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.english.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {

    @Update({
            "<script>",
            "UPDATE notification",
            "SET is_read = 1",
            "WHERE status = 1",
            "AND user_id = #{userId}",
            "AND is_read = 0",
            "</script>"
    })
    int markAllReadByUserId(@Param("userId") Long userId);
}
