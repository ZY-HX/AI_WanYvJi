package com.english.controller;

import com.english.common.Result;
import com.english.resilience.RedisCircuitBreaker;
import com.english.resilience.ResilientRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    private final RedisCircuitBreaker circuitBreaker;
    private final ResilientRedisTemplate resilientRedisTemplate;

    public HealthController(RedisCircuitBreaker circuitBreaker,
                           ResilientRedisTemplate resilientRedisTemplate) {
        this.circuitBreaker = circuitBreaker;
        this.resilientRedisTemplate = resilientRedisTemplate;
    }

    @GetMapping("/health")
    public Result<String> health() {
        return Result.success("OK");
    }

    @GetMapping("/health/redis")
    public Result<Map<String, Object>> redisHealth() {
        Map<String, Object> status = new HashMap<>();

        RedisCircuitBreaker.CircuitBreakerStats stats = resilientRedisTemplate.getCircuitBreakerStats();
        status.put("circuitBreaker", Map.of(
                "state", stats.state().name(),
                "failureCount", stats.failureCount(),
                "halfOpenProbeCount", stats.halfOpenProbeCount(),
                "lastFailureTime", stats.lastFailureTime(),
                "isAvailable", circuitBreaker.isAvailable()
        ));

        status.put("localCache", Map.of(
                "size", resilientRedisTemplate.getLocalCacheSize(),
                "maxSize", 10000
        ));

        return Result.success(status);
    }

    @PostMapping("/health/redis/reset")
    public Result<String> resetCircuitBreaker() {
        circuitBreaker.reset();
        return Result.success("Redis 熔断器已重置");
    }
}
