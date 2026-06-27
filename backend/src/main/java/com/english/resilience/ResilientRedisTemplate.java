package com.english.resilience;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

@Slf4j
@Component
public class ResilientRedisTemplate {

    private final RedisTemplate<String, Object> redisTemplate;
    private final RedisCircuitBreaker circuitBreaker;

    private final Map<String, CacheEntry> localCache = new ConcurrentHashMap<>();
    private final ScheduledExecutorService cleanupScheduler;

    @org.springframework.beans.factory.annotation.Value("${redis.local-cache.max-size:10000}")
    private int maxLocalCacheSize;

    @org.springframework.beans.factory.annotation.Value("${redis.local-cache.cleanup-interval-seconds:60}")
    private long cleanupIntervalSeconds;

    public ResilientRedisTemplate(RedisTemplate<String, Object> redisTemplate,
                                  RedisCircuitBreaker circuitBreaker) {
        this.redisTemplate = redisTemplate;
        this.circuitBreaker = circuitBreaker;
        this.cleanupScheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread thread = new Thread(r, "redis-local-cache-cleanup");
            thread.setDaemon(true);
            return thread;
        });
    }

    @PostConstruct
    public void init() {
        startCleanupTask();
        log.info("✅ ResilientRedisTemplate 初始化完成 (maxLocalCacheSize={}, cleanupInterval={}s)",
                maxLocalCacheSize, cleanupIntervalSeconds);
    }

    public Boolean hasKey(String key) {
        return executeWithFallback(
                "hasKey",
                () -> redisTemplate.hasKey(key),
                () -> getFromLocalCache(key) != null
        );
    }

    public void set(String key, Object value, Duration ttl) {
        if (!circuitBreaker.allowRequest()) {
            setToLocalCache(key, value, ttl);
            log.debug("📦 Redis 熔断中，写入本地缓存 key={}", key);
            return;
        }

        try {
            redisTemplate.opsForValue().set(key, value, ttl);
            circuitBreaker.recordSuccess();
            removeFromLocalCache(key);
        } catch (Exception e) {
            circuitBreaker.recordFailure();
            setToLocalCache(key, value, ttl);
            log.warn("⚠️ Redis 写入失败，降级到本地缓存 key={}", key);
        }
    }

    public Boolean setIfAbsent(String key, Object value, Duration ttl) {
        if (!circuitBreaker.allowRequest()) {
            Boolean localResult = setIfAbsentLocal(key, value, ttl);
            log.debug("📦 Redis 熔断中，本地限流检查 key={}", key);
            return localResult;
        }

        try {
            Boolean result = redisTemplate.opsForValue().setIfAbsent(key, value, ttl);
            circuitBreaker.recordSuccess();
            return result;
        } catch (Exception e) {
            circuitBreaker.recordFailure();
            Boolean localResult = setIfAbsentLocal(key, value, ttl);
            log.warn("⚠️ Redis 限流操作失败，降级到本地内存 key={}", key);
            return localResult;
        }
    }

    public Object get(String key) {
        return executeWithFallback(
                "get",
                () -> redisTemplate.opsForValue().get(key),
                () -> getFromLocalCache(key)
        );
    }

    public void delete(String key) {
        if (!circuitBreaker.allowRequest()) {
            removeFromLocalCache(key);
            return;
        }

        try {
            redisTemplate.delete(key);
            circuitBreaker.recordSuccess();
        } catch (Exception e) {
            circuitBreaker.recordFailure();
            removeFromLocalCache(key);
            log.warn("⚠️ Redis 删除失败，仅删除本地缓存 key={}", key);
        }
    }

    private <T> T executeWithFallback(String operation, Supplier<T> redisOperation, Supplier<T> fallbackOperation) {
        if (!circuitBreaker.allowRequest()) {
            T fallbackResult = fallbackOperation.get();
            log.debug("🔒 Redis 熎断中，使用本地缓存 operation={}", operation);
            return fallbackResult;
        }

        try {
            T result = redisOperation.get();
            circuitBreaker.recordSuccess();
            return result;
        } catch (Exception e) {
            circuitBreaker.recordFailure();
            T fallbackResult = fallbackOperation.get();
            log.warn("⚠️ Redis 操作失败，降级到本地缓存 operation={}", operation);
            return fallbackResult;
        }
    }

    private void setToLocalCache(String key, Object value, Duration ttl) {
        if (localCache.size() >= maxLocalCacheSize) {
            evictOldestEntries();
        }

        long expireAt = System.currentTimeMillis() + ttl.toMillis();
        localCache.put(key, new CacheEntry(value, expireAt));
    }

    private Boolean setIfAbsentLocal(String key, Object value, Duration ttl) {
        if (localCache.containsKey(key)) {
            CacheEntry existing = localCache.get(key);
            if (existing != null && !existing.isExpired()) {
                return false;
            }
        }

        if (localCache.size() >= maxLocalCacheSize) {
            evictOldestEntries();
        }

        long expireAt = System.currentTimeMillis() + ttl.toMillis();
        localCache.put(key, new CacheEntry(value, expireAt));
        return true;
    }

    private Object getFromLocalCache(String key) {
        CacheEntry entry = localCache.get(key);
        if (entry == null) {
            return null;
        }

        if (entry.isExpired()) {
            localCache.remove(key);
            return null;
        }

        return entry.getValue();
    }

    private void removeFromLocalCache(String key) {
        localCache.remove(key);
    }

    private void evictOldestEntries() {
        int toEvict = Math.max(1, localCache.size() / 10);
        localCache.entrySet().stream()
                .sorted(Map.Entry.comparingByValue())
                .limit(toEvict)
                .forEach(entry -> localCache.remove(entry.getKey()));

        log.debug("🧹 本地缓存空间不足，清理了 {} 条记录", toEvict);
    }

    private void startCleanupTask() {
        cleanupScheduler.scheduleAtFixedRate(
                this::cleanupExpiredEntries,
                cleanupIntervalSeconds,
                cleanupIntervalSeconds,
                TimeUnit.SECONDS
        );
    }

    private void cleanupExpiredEntries() {
        long now = System.currentTimeMillis();
        int beforeSize = localCache.size();

        localCache.entrySet().removeIf(entry -> entry.getValue().isExpired());

        int removed = beforeSize - localCache.size();
        if (removed > 0) {
            log.debug("🧹 定期清理过期缓存条目: 移除 {} 条，剩余 {} 条", removed, localCache.size());
        }
    }

    public RedisCircuitBreaker.CircuitBreakerStats getCircuitBreakerStats() {
        return circuitBreaker.getStats();
    }

    public int getLocalCacheSize() {
        return localCache.size();
    }

    private static class CacheEntry implements Comparable<CacheEntry> {
        private final Object value;
        private final long expireAt;

        public CacheEntry(Object value, long expireAt) {
            this.value = value;
            this.expireAt = expireAt;
        }

        public Object getValue() {
            return value;
        }

        public boolean isExpired() {
            return System.currentTimeMillis() > expireAt;
        }

        @Override
        public int compareTo(CacheEntry other) {
            return Long.compare(this.expireAt, other.expireAt);
        }
    }
}
