package com.english.resilience;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.locks.ReentrantLock;

@Slf4j
@Component
public class RedisCircuitBreaker {

    public enum State {
        CLOSED,    // 正常状态，允许所有请求
        OPEN,      // 熔断状态，拒绝所有请求
        HALF_OPEN  // 半开状态，允许探测性请求
    }

    @Value("${redis.circuit-breaker.failure-threshold:5}")
    private int failureThreshold;

    @Value("${redis.circuit-breaker.reset-timeout-seconds:30}")
    private long resetTimeoutSeconds;

    @Value("${redis.circuit-breaker.half-open-max-probes:3}")
    private int halfOpenMaxProbes;

    private final AtomicReference<State> state = new AtomicReference<>(State.CLOSED);
    private final AtomicInteger failureCount = new AtomicInteger(0);
    private final AtomicInteger halfOpenProbeCount = new AtomicInteger(0);
    private volatile long lastFailureTime = 0;
    private final ReentrantLock lock = new ReentrantLock();

    public boolean allowRequest() {
        State currentState = state.get();

        switch (currentState) {
            case CLOSED:
                return true;

            case OPEN:
                if (shouldAttemptReset()) {
                    transitionToHalfOpen();
                    return true;
                }
                return false;

            case HALF_OPEN:
                if (halfOpenProbeCount.get() < halfOpenMaxProbes) {
                    halfOpenProbeCount.incrementAndGet();
                    return true;
                }
                return false;

            default:
                return false;
        }
    }

    public void recordSuccess() {
        lock.lock();
        try {
            if (state.get() == State.HALF_OPEN) {
                log.info("✅ Redis 连接恢复，熔断器从 HALF_OPEN 切换到 CLOSED");
                state.set(State.CLOSED);
                resetCounters();
            } else if (state.get() == State.CLOSED) {
                failureCount.set(0);
            }
        } finally {
            lock.unlock();
        }
    }

    public void recordFailure() {
        lock.lock();
        try {
            lastFailureTime = System.currentTimeMillis();
            int failures = failureCount.incrementAndGet();

            if (state.get() == State.HALF_OPEN) {
                log.warn("⚠️ Redis 半开探测失败，重新进入熔断状态 failures={}", failures);
                state.set(State.OPEN);
                resetHalfOpenCounters();
            } else if (failures >= failureThreshold && state.get() == State.CLOSED) {
                log.error("🚨 Redis 连续失败 {} 次，触发熔断机制", failures);
                state.set(State.OPEN);
            }
        } finally {
            lock.unlock();
        }
    }

    public State getState() {
        State currentState = state.get();

        if (currentState == State.OPEN && shouldAttemptReset()) {
            transitionToHalfOpen();
            return State.HALF_OPEN;
        }

        return currentState;
    }

    public boolean isAvailable() {
        return getState() != State.OPEN || shouldAttemptReset();
    }

    private boolean shouldAttemptReset() {
        return System.currentTimeMillis() - lastFailureTime > resetTimeoutSeconds * 1000L;
    }

    private void transitionToHalfOpen() {
        log.info("🔄 Redis 熔断超时，尝试半开探测");
        state.set(State.HALF_OPEN);
        halfOpenProbeCount.set(0);
    }

    private void resetCounters() {
        failureCount.set(0);
        halfOpenProbeCount.set(0);
        lastFailureTime = 0;
    }

    private void resetHalfOpenCounters() {
        halfOpenProbeCount.set(0);
        failureCount.set(0);
    }

    public void reset() {
        lock.lock();
        try {
            log.info("🔧 手动重置 Redis 熔断器");
            state.set(State.CLOSED);
            resetCounters();
        } finally {
            lock.unlock();
        }
    }

    public CircuitBreakerStats getStats() {
        return new CircuitBreakerStats(
                state.get(),
                failureCount.get(),
                halfOpenProbeCount.get(),
                lastFailureTime,
                failureThreshold,
                resetTimeoutSeconds,
                halfOpenMaxProbes
        );
    }

    public record CircuitBreakerStats(
            State state,
            int failureCount,
            int halfOpenProbeCount,
            long lastFailureTime,
            int failureThreshold,
            long resetTimeoutSeconds,
            int halfOpenMaxProbes
    ) {}
}
