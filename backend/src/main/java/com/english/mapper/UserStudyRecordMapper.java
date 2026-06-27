package com.english.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.english.dto.DashboardDetailResponse.TrendPoint;
import com.english.dto.StudyExportRecordResponse;
import com.english.dto.StudyWordResponse;
import com.english.entity.UserStudyRecord;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 用户学习记录数据访问层（Mapper）接口
 * 继承MyBatis-Plus的BaseMapper，提供用户学习记录的CRUD操作
 * 主要功能：
 * - 查询待学习的单词（艾宾浩斯遗忘曲线算法）
 * - 统计学习数据（学习天数、正确率、单词数等）
 * - 导出学习记录
 * - 删除学习记录
 *
 * 对应数据库表：user_study_record
 * 关联表：word_bank（词库）、word（单词）
 */
@Mapper
public interface UserStudyRecordMapper extends BaseMapper<UserStudyRecord> {

    /**
     * 统计待复习/学习的单词数量
     * 根据艾宾浩斯遗忘曲线算法，查询next_review_time <= 当前时间的记录
     * 只统计状态为活跃（status=1）且词库和单词都正常的记录
     *
     * @param userId 用户ID
     * @param wordBankId 词库ID
     * @param now 当前时间（用于判断是否到期）
     * @return 待学习/复习的单词数量
     */
    @Select("""
            SELECT COUNT(*)
            FROM user_study_record usr
            JOIN word_bank wb ON wb.id = usr.word_bank_id AND wb.status = 1
            JOIN word w ON w.id = usr.word_id AND w.status = 1
                      AND w.word_bank_id = wb.id AND w.language = wb.language
            WHERE usr.user_id = #{userId}
              AND usr.word_bank_id = #{wordBankId}
              AND usr.status = 1
              AND usr.next_review_time <= #{now}
            """)
    long countReadyRecords(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId,
            @Param("now") LocalDateTime now
    );

    /**
     * 分页查询待学习的单词列表
     * 用于获取需要学习的单词及其详细信息（英文、音标、中文释义、例句等）
     * 按照下次复习时间升序排列，优先复习最紧急的单词
     *
     * @param userId 用户ID
     * @param wordBankId 词库ID
     * @param now 当前时间（用于筛选到期的记录）
     * @param offset 分页偏移量（起始位置）
     * @param size 每页大小（查询数量限制）
     * @return 待学习单词的详细信息列表
     */
    @Select("""
            SELECT usr.id AS recordId,
                   usr.word_id AS wordId,
                   usr.word_bank_id AS wordBankId,
                   usr.study_mode AS studyMode,
                   usr.next_review_time AS nextReviewTime,
                   w.english,
                   w.phonetic,
                   w.chinese,
                   w.example
            FROM user_study_record usr
            JOIN word_bank wb ON wb.id = usr.word_bank_id AND wb.status = 1
            JOIN word w ON w.id = usr.word_id AND w.status = 1
                      AND w.word_bank_id = wb.id AND w.language = wb.language
            WHERE usr.user_id = #{userId}
              AND usr.word_bank_id = #{wordBankId}
              AND usr.status = 1
              AND usr.next_review_time <= #{now}
            ORDER BY usr.next_review_time ASC, usr.id ASC
            LIMIT #{offset}, #{size}
            """)
    List<StudyWordResponse> selectReadyStudyWords(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId,
            @Param("now") LocalDateTime now,
            @Param("offset") long offset,
            @Param("size") long size
    );

    /**
     * 统计用户在指定词库中的活跃学习记录总数
     * 活跃记录指状态为正常（status=1）的学习记录
     *
     * @param userId 用户ID
     * @param wordBankId 词库ID
     * @return 活跃学习记录数量
     */
    @Select("""
            SELECT COUNT(*)
            FROM user_study_record usr
            JOIN word_bank wb ON wb.id = usr.word_bank_id AND wb.status = 1
            JOIN word w ON w.id = usr.word_id AND w.status = 1
                      AND w.word_bank_id = wb.id AND w.language = wb.language
            WHERE usr.user_id = #{userId}
              AND usr.word_bank_id = #{wordBankId}
              AND usr.status = 1
            """)
    long countActiveRecords(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId
    );

    /**
     * 分页查询用户的复习单词列表
     * 获取所有已学过的单词（包括已掌握和未掌握），用于复习页面展示
     * 按更新时间降序排列，最近学习的单词排在前面
     *
     * @param userId 用户ID
     * @param wordBankId 词库ID
     * @param offset 分页偏移量
     * @param size 每页大小
     * @return 复习单词列表（包含单词详情和学习进度信息）
     */
    @Select("""
            SELECT usr.id AS recordId,
                   usr.word_id AS wordId,
                   usr.word_bank_id AS wordBankId,
                   usr.study_mode AS studyMode,
                   usr.next_review_time AS nextReviewTime,
                   w.english,
                   w.phonetic,
                   w.chinese,
                   w.example
            FROM user_study_record usr
            JOIN word_bank wb ON wb.id = usr.word_bank_id AND wb.status = 1
            JOIN word w ON w.id = usr.word_id AND w.status = 1
                      AND w.word_bank_id = wb.id AND w.language = wb.language
            WHERE usr.user_id = #{userId}
              AND usr.word_bank_id = #{wordBankId}
              AND usr.status = 1
            ORDER BY usr.updated_at DESC, usr.id DESC
            LIMIT #{offset}, #{size}
            """)
    List<StudyWordResponse> selectReviewWords(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId,
            @Param("offset") long offset,
            @Param("size") long size
    );

    /**
     * 分页查询连续学习单词列表
     * 与selectReviewWords类似，用于连续学习模式下的单词获取
     * 按更新时间降序排列
     *
     * @param userId 用户ID
     * @param wordBankId 词库ID
     * @param offset 分页偏移量
     * @param size 每页大小
     * @return 连续学习单词列表
     */
    @Select("""
            SELECT usr.id AS recordId,
                   usr.word_id AS wordId,
                   usr.word_bank_id AS wordBankId,
                   usr.study_mode AS studyMode,
                   usr.next_review_time AS nextReviewTime,
                   w.english,
                   w.phonetic,
                   w.chinese,
                   w.example
            FROM user_study_record usr
            JOIN word_bank wb ON wb.id = usr.word_bank_id AND wb.status = 1
            JOIN word w ON w.id = usr.word_id AND w.status = 1
                      AND w.word_bank_id = wb.id AND w.language = wb.language
            WHERE usr.user_id = #{userId}
              AND usr.word_bank_id = #{wordBankId}
              AND usr.status = 1
            ORDER BY usr.updated_at DESC, usr.id DESC
            LIMIT #{offset}, #{size}
            """)
    List<StudyWordResponse> selectContinuousStudyWords(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId,
            @Param("offset") long offset,
            @Param("size") long size
    );

    /**
     * 查询用户在指定词库中的所有学习记录（用于导出功能）
     * 包含单词信息和学习统计数据（复习次数、正确次数、错误次数、下次复习时间）
     * 包含已掌握（status=2）和未掌握（status=1）的记录
     *
     * @param userId 用户ID
     * @param wordBankId 词库ID
     * @return 学习记录导出数据列表
     */
    @Select("""
            SELECT w.english,
                   w.chinese,
                   usr.study_mode AS studyMode,
                   usr.review_count AS reviewCount,
                   usr.correct_count AS correctCount,
                   usr.wrong_count AS wrongCount,
                   usr.next_review_time AS nextReviewTime
            FROM user_study_record usr
            JOIN word_bank wb ON wb.id = usr.word_bank_id AND wb.status = 1
            JOIN word w ON w.id = usr.word_id AND w.status = 1
                      AND w.word_bank_id = wb.id AND w.language = wb.language
            WHERE usr.user_id = #{userId}
              AND usr.word_bank_id = #{wordBankId}
              AND usr.status IN (1, 2)
            ORDER BY w.english ASC, usr.id ASC
            """)
    List<StudyExportRecordResponse> selectExportRecords(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId
    );

    /**
     * 删除用户在指定词库中的所有学习记录
     * 通常在用户退出词库或重置学习进度时调用
     *
     * @param userId 用户ID
     * @param wordBankId 词库ID
     * @return 删除的记录数量
     */
    @Delete("""
            DELETE FROM user_study_record
            WHERE user_id = #{userId}
              AND word_bank_id = #{wordBankId}
            """)
    int deleteByUserIdAndWordBankId(
            @Param("userId") Long userId,
            @Param("wordBankId") Long wordBankId
    );

    /**
     * 统计用户今日需要复习的单词总数（跨所有词库）
     * 用于仪表盘显示今日复习任务量
     *
     * @param userId 用户ID
     * @param now 当前时间
     * @return 今日待复习单词数量
     */
    @Select("""
            SELECT COUNT(*)
            FROM user_study_record usr
            JOIN word_bank wb ON wb.id = usr.word_bank_id AND wb.status = 1
            JOIN word w ON w.id = usr.word_id AND w.status = 1
                      AND w.word_bank_id = wb.id AND w.language = wb.language
            WHERE usr.user_id = #{userId}
              AND usr.status = 1
              AND usr.next_review_time <= #{now}
            """)
    long countTodayReviewWords(
            @Param("userId") Long userId,
            @Param("now") LocalDateTime now
    );

    /**
     * 统计用户在指定日期范围内的学习天数
     * 通过计算有更新记录的不重复日期数量来确定学习天数
     * 用于连续学习和学习坚持度统计
     *
     * @param userId 用户ID
     * @param startDate 开始日期（包含）
     * @param endDate 结束日期（不包含）
     * @return 学习天数
     */
    @Select("""
            SELECT COUNT(DISTINCT DATE(usr.updated_at))
            FROM user_study_record usr
            WHERE usr.user_id = #{userId}
              AND usr.updated_at >= #{startDate}
              AND usr.updated_at < #{endDate}
            """)
    int countStudyDaysInRange(
            @Param("userId") Long userId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    /**
     * 统计用户今日的学习记录总数
     * 用于仪表盘显示今日学习活动量
     *
     * @param userId 用户ID
     * @param todayStart 今日开始时间（00:00:00）
     * @param todayEnd 今日结束时间（23:59:59.999）
     * @return 今日学习记录数量
     */
    @Select("""
            SELECT COUNT(*)
            FROM user_study_record usr
            WHERE usr.user_id = #{userId}
              AND usr.updated_at >= #{todayStart}
              AND usr.updated_at < #{todayEnd}
            """)
    long countTodayStudyRecords(
            @Param("userId") Long userId,
            @Param("todayStart") LocalDateTime todayStart,
            @Param("todayEnd") LocalDateTime todayEnd
    );

    /**
     * 统计用户总共学习过的不同单词数量
     * 包括已掌握（status=2）和学习中（status=1）的单词
     * 去重统计，同一单词只计数一次
     *
     * @param userId 用户ID
     * @return 总共学习过的单词数量
     */
    @Select("""
            SELECT COUNT(DISTINCT usr.word_id)
            FROM user_study_record usr
            WHERE usr.user_id = #{userId}
              AND usr.status IN (1, 2)
            """)
    long countTotalLearnedWords(@Param("userId") Long userId);

    /**
     * 统计用户当前正在学习的活跃词库数量
     * 活跃词库指该用户在该词库中有学习记录且状态为正常（status=1）
     *
     * @param userId 用户ID
     * @return 活跃词库数量
     */
    @Select("""
            SELECT COUNT(DISTINCT usr.word_bank_id)
            FROM user_study_record usr
            WHERE usr.user_id = #{userId}
              AND usr.status = 1
            """)
    long countActiveWordBanks(@Param("userId") Long userId);

    /**
     * 统计用户所有学习记录的总正确次数
     * 用于计算整体正确率和学习效果分析
     *
     * @param userId 用户ID
     * @return 总正确次数
     */
    @Select("""
            SELECT COALESCE(SUM(usr.correct_count), 0)
            FROM user_study_record usr
            WHERE usr.user_id = #{userId}
              AND usr.status IN (1, 2)
            """)
    int sumTotalCorrectCount(@Param("userId") Long userId);

    /**
     * 统计用户所有学习记录的总错误次数
     * 用于计算错误率和薄弱点分析
     *
     * @param userId 用户ID
     * @return 总错误次数
     */
    @Select("""
            SELECT COALESCE(SUM(usr.wrong_count), 0)
            FROM user_study_record usr
            WHERE usr.user_id = #{userId}
              AND usr.status IN (1, 2)
            """)
    int sumTotalWrongCount(@Param("userId") Long userId);

    /**
     * 按日查询用户学习趋势数据
     * 统计每天的学习次数、正确次数、错误次数和新学单词数
     * 用于生成学习曲线图表（按天维度）
     *
     * @param userId 用户ID
     * @param startDate 统计开始日期
     * @param endDate 统计结束日期
     * @return 按日分组的学习统计数据列表，包含date、studyCount、correctCount、wrongCount、newWordsCount字段
     */
    @Select("""
            SELECT DATE(usr.updated_at) AS date,
                   COUNT(*) AS studyCount,
                   COALESCE(SUM(usr.correct_count), 0) AS correctCount,
                   COALESCE(SUM(usr.wrong_count), 0) AS wrongCount,
                   COUNT(DISTINCT CASE WHEN usr.review_count = 0 THEN usr.word_id END) AS newWordsCount
            FROM user_study_record usr
            WHERE usr.user_id = #{userId}
              AND usr.updated_at >= #{startDate}
              AND usr.updated_at < #{endDate}
            GROUP BY DATE(usr.updated_at)
            ORDER BY date ASC
            """)
    List<Map<String, Object>> selectDailyTrend(
            @Param("userId") Long userId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    /**
     * 按周查询用户学习趋势数据
     * 统计每周的学习情况，使用ISO周格式（%Y-%u）
     * 用于生成长期学习趋势图表（按周维度）
     *
     * @param userId 用户ID
     * @param startDate 统计开始日期
     * @param endDate 统计结束日期
     * @return 按周分组的学习统计数据列表
     */
    @Select("""
            SELECT DATE_FORMAT(usr.updated_at, '%Y-%u') AS weekDate,
                   COUNT(*) AS studyCount,
                   COALESCE(SUM(usr.correct_count), 0) AS correctCount,
                   COALESCE(SUM(usr.wrong_count), 0) AS wrongCount,
                   COUNT(DISTINCT CASE WHEN usr.review_count = 0 THEN usr.word_id END) AS newWordsCount
            FROM user_study_record usr
            WHERE usr.user_id = #{userId}
              AND usr.updated_at >= #{startDate}
              AND usr.updated_at < #{endDate}
            GROUP BY DATE_FORMAT(usr.updated_at, '%Y-%u')
            ORDER BY weekDate ASC
            """)
    List<Map<String, Object>> selectWeeklyTrend(
            @Param("userId") Long userId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    /**
     * 按月查询用户学习趋势数据
     * 统计每月的学习情况，格式为YYYY-MM
     * 用于生成月度学习报告和长期趋势分析（按月维度）
     *
     * @param userId 用户ID
     * @param startDate 统计开始日期
     * @param endDate 统计结束日期
     * @return 按月分组的学习统计数据列表
     */
    @Select("""
            SELECT DATE_FORMAT(usr.updated_at, '%Y-%m') AS monthDate,
                   COUNT(*) AS studyCount,
                   COALESCE(SUM(usr.correct_count), 0) AS correctCount,
                   COALESCE(SUM(usr.wrong_count), 0) AS wrongCount,
                   COUNT(DISTINCT CASE WHEN usr.review_count = 0 THEN usr.word_id END) AS newWordsCount
            FROM user_study_record usr
            WHERE usr.user_id = #{userId}
              AND usr.updated_at >= #{startDate}
              AND usr.updated_at < #{endDate}
            GROUP BY DATE_FORMAT(usr.updated_at, '%Y-%m')
            ORDER BY monthDate ASC
            """)
    List<Map<String, Object>> selectMonthlyTrend(
            @Param("userId") Long userId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );
}
