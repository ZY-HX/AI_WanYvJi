package com.english.common;

import lombok.Data;
import lombok.NoArgsConstructor;

import static lombok.AccessLevel.PRIVATE;

/**
 * 统一响应结果封装类
 * 所有API接口的返回值都使用此类进行封装，确保响应格式一致
 */
@Data
@NoArgsConstructor(access = PRIVATE)
public class Result<T> {

    /** 成功状态码 */
    private static final int SUCCESS_CODE = 200;
    /** 默认错误状态码 */
    private static final int ERROR_CODE = 500;
    /** 成功消息 */
    private static final String SUCCESS_MESSAGE = "success";

    /** 响应状态码 */
    private int code;
    /** 响应消息 */
    private String message;
    /** 响应数据 */
    private T data;

    public static <T> Result<T> success() {
        Result<T> result = new Result<>();
        result.setCode(SUCCESS_CODE);
        result.setMessage(SUCCESS_MESSAGE);
        return result;
    }

    public static <T> Result<T> success(T data) {
        Result<T> result = new Result<>();
        result.setCode(SUCCESS_CODE);
        result.setMessage(SUCCESS_MESSAGE);
        result.setData(data);
        return result;
    }

    public static <T> Result<T> success(String message, T data) {
        Result<T> result = new Result<>();
        result.setCode(SUCCESS_CODE);
        result.setMessage(message);
        result.setData(data);
        return result;
    }

    public static <T> Result<T> error(String message) {
        Result<T> result = new Result<>();
        result.setCode(ERROR_CODE);
        result.setMessage(message);
        return result;
    }

    public static <T> Result<T> error(int code, String message) {
        Result<T> result = new Result<>();
        result.setCode(code);
        result.setMessage(message);
        return result;
    }

    public static <T> Result<T> error(int code, String message, T data) {
        Result<T> result = new Result<>();
        result.setCode(code);
        result.setMessage(message);
        result.setData(data);
        return result;
    }
}
