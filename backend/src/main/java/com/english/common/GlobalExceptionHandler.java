package com.english.common;

import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.MultipartException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import jakarta.validation.ConstraintViolationException;
import java.util.stream.Collectors;

/**
 * 全局异常处理器
 * 统一处理所有Controller层抛出的异常，返回标准格式的错误响应
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 处理业务异常
     * 根据错误码判断是否为服务器端错误，记录不同级别的日志
     */

    @ExceptionHandler(BusinessException.class)
    public Result<Object> handleBusinessException(BusinessException e) {
        if (e.isServerError()) {
            log.error("业务异常 code={}, message={}", e.getCode(), e.getMessage(), e);
        } else {
            log.warn("业务异常 code={}, message={}", e.getCode(), e.getMessage());
        }
        return Result.error(e.getCode(), e.getUserMessage(), e.getData());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining(", "));
        log.warn("参数校验异常: {}", message);
        return Result.error(400, message);
    }

    @ExceptionHandler(BindException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleBindException(BindException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining(", "));
        log.warn("绑定异常: {}", message);
        return Result.error(400, message);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleConstraintViolationException(ConstraintViolationException e) {
        String message = e.getConstraintViolations().stream()
                .map(violation -> violation.getMessage())
                .collect(Collectors.joining(", "));
        log.warn("约束校验异常: {}", message);
        return Result.error(400, message);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleHttpMessageNotReadableException(HttpMessageNotReadableException e) {
        log.warn("请求体解析异常: {}", e.getMessage());
        return Result.error(400, "请求体格式错误");
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleMissingServletRequestParameterException(MissingServletRequestParameterException e) {
        log.warn("缺少请求参数: {}", e.getParameterName());
        return Result.error(400, "缺少必要请求参数: " + e.getParameterName());
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleMethodArgumentTypeMismatchException(MethodArgumentTypeMismatchException e) {
        log.warn("参数类型不匹配: {}", e.getName());
        return Result.error(400, "参数类型错误: " + e.getName());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleIllegalArgumentException(IllegalArgumentException e) {
        log.warn("非法参数异常: {}", e.getMessage());
        return Result.error(400, "请求参数不合法");
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    @ResponseStatus(HttpStatus.METHOD_NOT_ALLOWED)
    public Result<Void> handleHttpRequestMethodNotSupportedException(HttpRequestMethodNotSupportedException e) {
        log.warn("请求方法不支持: {}", e.getMethod());
        return Result.error(405, "请求方法不支持");
    }

    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    @ResponseStatus(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
    public Result<Void> handleHttpMediaTypeNotSupportedException(HttpMediaTypeNotSupportedException e) {
        log.warn("请求类型不支持: {}", e.getContentType());
        return Result.error(415, "请求类型不支持");
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    @ResponseStatus(HttpStatus.PAYLOAD_TOO_LARGE)
    public Result<Void> handleMaxUploadSizeExceededException(MaxUploadSizeExceededException e) {
        log.warn("上传文件过大", e);
        return Result.error(413, "上传文件过大");
    }

    @ExceptionHandler(MultipartException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleMultipartException(MultipartException e) {
        log.warn("上传请求解析异常: {}", e.getMessage());
        return Result.error(400, "文件上传请求无效");
    }

    @ExceptionHandler(NoResourceFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public Result<Void> handleNoResourceFoundException(NoResourceFoundException e) {
        log.warn("请求地址不存在: {}", e.getResourcePath());
        return Result.error(404, "请求地址不存在");
    }

    @ExceptionHandler({DuplicateKeyException.class, DataIntegrityViolationException.class})
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleDuplicateKeyException(Exception e) {
        String rawMessage = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
        String message = "数据已存在，请勿重复提交";

        if (rawMessage.contains("username")) {
            message = "用户名已存在";
        } else if (rawMessage.contains("email")) {
            message = "邮箱已被注册";
        } else if (rawMessage.contains("duplicate")) {
            message = "用户名或邮箱已存在";
        }

        log.warn("唯一约束冲突: {}", e.getMessage());
        return Result.error(400, message);
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public Result<Void> handleException(Exception e) {
        log.error("系统异常", e);
        return Result.error(500, "系统繁忙，请稍后重试");
    }
}
