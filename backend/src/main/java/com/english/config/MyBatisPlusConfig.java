package com.english.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.OptimisticLockerInnerInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;

/**
 * MyBatis-Plus配置类
 * 配置分页插件、乐观锁插件以及自动填充功能
 * 用于优化数据库操作，提供分页查询、并发控制和自动时间戳填充能力
 */
@Configuration
public class MyBatisPlusConfig implements MetaObjectHandler {

    /**
     * 配置MyBatis-Plus拦截器链
     * 包含以下插件：
     * 1. PaginationInnerInterceptor - 分页插件，支持MySQL数据库的物理分页
     * 2. OptimisticLockerInnerInterceptor - 乐观锁插件，用于处理并发更新冲突
     *
     * @return 配置好的MybatisPlusInterceptor实例
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        // 添加MySQL分页插件，实现物理分页而非内存分页
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        // 添加乐观锁插件，支持@Version注解的字段版本控制
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
        return interceptor;
    }

    /**
     * 插入操作自动填充
     * 在执行插入时自动设置createdAt和updatedAt字段为当前时间
     * 需要实体类字段添加@TableField(fill = FieldFill.INSERT)注解
     *
     * @param metaObject 元对象，包含实体类的字段信息
     */
    @Override
    public void insertFill(MetaObject metaObject) {
        // 自动填充创建时间为当前时间
        this.strictInsertFill(metaObject, "createdAt", LocalDateTime.class, LocalDateTime.now());
        // 自动填充更新时间为当前时间
        this.strictInsertFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
    }

    /**
     * 更新操作自动填充
     * 在执行更新时自动设置updatedAt字段为当前时间
     * 需要实体类字段添加@TableField(fill = FieldFill.UPDATE)注解
     *
     * @param metaObject 元对象，包含实体类的字段信息
     */
    @Override
    public void updateFill(MetaObject metaObject) {
        // 自动填充更新时间为当前时间
        this.strictUpdateFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
    }
}
