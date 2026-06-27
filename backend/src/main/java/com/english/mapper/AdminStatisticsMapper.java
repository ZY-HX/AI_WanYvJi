package com.english.mapper;

import com.english.dto.AdminStatisticsTrendPointResponse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface AdminStatisticsMapper {

    @Select("""
            SELECT COUNT(*)
            FROM user
            WHERE status = 1
              AND role = 'USER'
            """)
    Long countTotalUsers();

    @Select("""
            SELECT COUNT(*)
            FROM user
            WHERE status = 1
              AND role = 'USER'
              AND created_at >= #{start}
              AND created_at < #{end}
            """)
    Long countNewUsersBetween(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Select("""
            SELECT COUNT(*)
            FROM word_bank
            WHERE status = 1
            """)
    Long countTotalWordBanks();

    @Select("""
            SELECT COUNT(*)
            FROM user_study_record
            WHERE updated_at >= #{start}
              AND updated_at < #{end}
              AND status IN (1, 2)
            """)
    Long countStudyRecordsBetween(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Select("""
            SELECT COUNT(*)
            FROM ai_article_log
            WHERE status = 1
            """)
    Long countTotalAiGenerations();

    @Select("""
            SELECT COUNT(*)
            FROM ai_article_log
            WHERE status = 1
              AND created_at >= #{start}
              AND created_at < #{end}
            """)
    Long countAiGenerationsBetween(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Select("""
            SELECT DATE_FORMAT(created_at, '%Y-%m-%d') AS date,
                   COUNT(*) AS value
            FROM user
            WHERE status = 1
              AND role = 'USER'
              AND created_at >= #{start}
              AND created_at < #{end}
            GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d')
            ORDER BY DATE_FORMAT(created_at, '%Y-%m-%d') ASC
            """)
    List<AdminStatisticsTrendPointResponse> selectUserTrend(
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end
    );

    @Select("""
            SELECT DATE_FORMAT(updated_at, '%Y-%m-%d') AS date,
                   COUNT(*) AS value
            FROM user_study_record
            WHERE updated_at >= #{start}
              AND updated_at < #{end}
              AND status IN (1, 2)
            GROUP BY DATE_FORMAT(updated_at, '%Y-%m-%d')
            ORDER BY DATE_FORMAT(updated_at, '%Y-%m-%d') ASC
            """)
    List<AdminStatisticsTrendPointResponse> selectStudyActivity(
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end
    );

    @Select("""
            SELECT DATE_FORMAT(created_at, '%Y-%m-%d') AS date,
                   COUNT(*) AS value
            FROM ai_article_log
            WHERE status = 1
              AND created_at >= #{start}
              AND created_at < #{end}
            GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d')
            ORDER BY DATE_FORMAT(created_at, '%Y-%m-%d') ASC
            """)
    List<AdminStatisticsTrendPointResponse> selectAiUsage(
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end
    );
}
