package com.english.common;

/**
 * 业务异常类
 * 用于封装业务逻辑中出现的各种异常情况
 */
public class BusinessException extends RuntimeException {

    private static final String DEFAULT_INTERNAL_MESSAGE = "系统繁忙，请稍后重试";

    /** 错误码 */
    private final int code;
    /** 附加数据 */
    private final Object data;
    /** 是否向用户暴露原始消息 */
    private final boolean exposeMessage;

    public BusinessException(String message) {
        this(500, message, null, false);
    }

    public BusinessException(int code, String message) {
        this(code, message, null, code < 500);
    }

    public BusinessException(int code, String message, Object data) {
        this(code, message, data, code < 500);
    }

    public BusinessException(int code, String message, boolean exposeMessage) {
        this(code, message, null, exposeMessage);
    }

    public BusinessException(int code, String message, Object data, boolean exposeMessage) {
        super(message);
        this.code = code;
        this.data = data;
        this.exposeMessage = exposeMessage;
    }

    public int getCode() {
        return code;
    }

    public Object getData() {
        return data;
    }

    public boolean isExposeMessage() {
        return exposeMessage;
    }

    public boolean isServerError() {
        return code >= 500;
    }

    public String getUserMessage() {
        return exposeMessage ? getMessage() : DEFAULT_INTERNAL_MESSAGE;
    }
}
