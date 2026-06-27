package com.english.common;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class GlobalExceptionHandlerTest {

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        LocalValidatorFactoryBean validator = new LocalValidatorFactoryBean();
        validator.afterPropertiesSet();
        mockMvc = MockMvcBuilders.standaloneSetup(new TestController())
                .setControllerAdvice(new GlobalExceptionHandler())
                .setValidator(validator)
                .setMessageConverters(new MappingJackson2HttpMessageConverter(new ObjectMapper()))
                .build();
    }

    @Test
    void shouldReturnOriginalMessageForClientBusinessException() throws Exception {
        mockMvc.perform(get("/test/business-client"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("请求参数有误"));
    }

    @Test
    void shouldHideInternalMessageForServerBusinessException() throws Exception {
        mockMvc.perform(get("/test/business-server"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("系统繁忙，请稍后重试"));
    }

    @Test
    void shouldKeepSafeMessageWhenServerBusinessExceptionExplicitlyExposed() throws Exception {
        mockMvc.perform(get("/test/business-server-exposed"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("头像上传失败，请稍后重试"));
    }

    @Test
    void shouldReturnValidationMessageForInvalidBody() throws Exception {
        mockMvc.perform(post("/test/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"name":""}
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("名称不能为空"));
    }

    @Test
    void shouldReturnBadRequestForMalformedJson() throws Exception {
        mockMvc.perform(post("/test/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("请求体格式错误"));
    }

    @Test
    void shouldReturnBadRequestForMissingRequestParam() throws Exception {
        mockMvc.perform(get("/test/required-param"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("缺少必要请求参数: keyword"));
    }

    @Test
    void shouldReturnBadRequestForTypeMismatch() throws Exception {
        mockMvc.perform(get("/test/type-mismatch").param("age", "abc"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("参数类型错误: age"));
    }

    @Test
    void shouldReturnMethodNotAllowedForUnsupportedMethod() throws Exception {
        mockMvc.perform(post("/test/get-only"))
                .andExpect(status().isMethodNotAllowed())
                .andExpect(jsonPath("$.code").value(405))
                .andExpect(jsonPath("$.message").value("请求方法不支持"));
    }

    @Test
    void shouldReturnBadRequestForIllegalArgumentException() throws Exception {
        mockMvc.perform(get("/test/illegal/abc"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("请求参数不合法"));
    }

    @Test
    void shouldReturnUnsupportedMediaTypeWhenContentTypeIsInvalid() throws Exception {
        mockMvc.perform(post("/test/validate")
                        .contentType(MediaType.TEXT_PLAIN)
                        .content("plain"))
                .andExpect(status().isUnsupportedMediaType())
                .andExpect(jsonPath("$.code").value(415))
                .andExpect(jsonPath("$.message").value("请求类型不支持"));
    }

    @Test
    void shouldReturnSafeMessageForUnhandledException() throws Exception {
        mockMvc.perform(get("/test/runtime"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("系统繁忙，请稍后重试"));
    }

    @Test
    void shouldReturnNotFoundForNoResourceFoundException() {
        GlobalExceptionHandler handler = new GlobalExceptionHandler();

        Result<Void> result = handler.handleNoResourceFoundException(
                new NoResourceFoundException(HttpMethod.GET, "/missing/resource")
        );

        assertEquals(404, result.getCode());
        assertEquals("请求地址不存在", result.getMessage());
    }

    @Test
    void shouldReturnPayloadTooLargeForMaxUploadSizeExceededException() {
        GlobalExceptionHandler handler = new GlobalExceptionHandler();

        Result<Void> result = handler.handleMaxUploadSizeExceededException(
                new MaxUploadSizeExceededException(1024)
        );

        assertEquals(413, result.getCode());
        assertEquals("上传文件过大", result.getMessage());
    }

    @RestController
    @RequestMapping("/test")
    static class TestController {

        @GetMapping("/business-client")
        public Result<Void> businessClient() {
            throw new BusinessException(400, "请求参数有误");
        }

        @GetMapping("/business-server")
        public Result<Void> businessServer() {
            throw new BusinessException(500, "数据库连接失败: timeout");
        }

        @GetMapping("/business-server-exposed")
        public Result<Void> businessServerExposed() {
            throw new BusinessException(500, "头像上传失败，请稍后重试", true);
        }

        @PostMapping(value = "/validate", consumes = MediaType.APPLICATION_JSON_VALUE)
        public Result<ValidationRequest> validate(@Valid @RequestBody ValidationRequest request) {
            return Result.success(request);
        }

        @GetMapping("/required-param")
        public Result<String> requiredParam(@RequestParam String keyword) {
            return Result.success(keyword);
        }

        @GetMapping("/type-mismatch")
        public Result<Integer> typeMismatch(@RequestParam Integer age) {
            return Result.success(age);
        }

        @GetMapping("/get-only")
        public Result<String> getOnly() {
            return Result.success("ok");
        }

        @GetMapping("/runtime")
        public Result<Void> runtime() {
            throw new RuntimeException("raw internal detail");
        }

        @GetMapping("/illegal/{id}")
        public Result<String> illegal(@PathVariable String id) {
            throw new IllegalArgumentException("illegal id: " + id);
        }
    }

    static class ValidationRequest {

        @NotBlank(message = "名称不能为空")
        private String name;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }
}
