package com.english.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * Redis配置类
 * 配置RedisTemplate的序列化方式，确保数据在Redis中的存储格式统一
 * 使用String序列化器处理Key，JSON序列化器处理Value，方便查看和调试
 */
@Configuration
public class RedisConfig {

    /**
     * 配置RedisTemplate Bean
     * 自定义序列化方式，解决默认JDK序列化导致的存储内容不可读问题：
     * - Key使用StringRedisSerializer：将Key序列化为可读字符串
     * - Value使用GenericJackson2JsonRedisSerializer：将Value序列化为JSON格式
     * - HashKey和HashValue也采用相同的序列化策略
     *
     * @param connectionFactory Redis连接工厂，由Spring Boot自动配置
     * @return 配置好的RedisTemplate实例
     */
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> redisTemplate = new RedisTemplate<>();
        // 创建String序列化器，用于序列化Key
        StringRedisSerializer stringSerializer = new StringRedisSerializer();
        // 创建JSON序列化器，用于序列化Value（支持复杂对象）
        GenericJackson2JsonRedisSerializer jsonSerializer = new GenericJackson2JsonRedisSerializer();

        // 设置Redis连接工厂
        redisTemplate.setConnectionFactory(connectionFactory);
        // 设置Key的序列化方式为String
        redisTemplate.setKeySerializer(stringSerializer);
        // 设置Hash Key的序列化方式为String
        redisTemplate.setHashKeySerializer(stringSerializer);
        // 设置Value的序列化方式为JSON
        redisTemplate.setValueSerializer(jsonSerializer);
        // 设置Hash Value的序列化方式为JSON
        redisTemplate.setHashValueSerializer(jsonSerializer);
        // 执行属性设置后的初始化操作
        redisTemplate.afterPropertiesSet();
        return redisTemplate;
    }
}
