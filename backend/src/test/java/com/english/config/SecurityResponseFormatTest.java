package com.english.config;

import com.english.common.Result;
import com.english.filter.JwtAuthenticationFilter;
import com.english.mapper.UserMapper;
import com.english.service.TokenBlacklistService;
import com.english.util.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.core.annotation.Order;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.test.web.servlet.MockMvc;

import java.io.IOException;

import static org.mockito.Mockito.mock;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(classes = SecurityResponseFormatTest.TestApplication.class)
@AutoConfigureMockMvc
class SecurityResponseFormatTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldReturnUnauthorizedInUnifiedFormat() throws Exception {
        mockMvc.perform(get("/secure/hello"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(401))
                .andExpect(jsonPath("$.message").value("未登录或Token已过期"));
    }

    @Test
    @WithMockUser(username = "user", roles = "USER")
    void shouldReturnForbiddenInUnifiedFormat() throws Exception {
        mockMvc.perform(get("/secure/admin"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value(403))
                .andExpect(jsonPath("$.message").value("无权访问该资源"));
    }

    @SpringBootConfiguration
    @EnableAutoConfiguration
    @Import({SecurityConfig.class, TestController.class, TestSecurityChainConfig.class})
    static class TestApplication {

        @Bean
        JwtAuthenticationFilter jwtAuthenticationFilter() {
            return new JwtAuthenticationFilter(new JwtUtil(), mock(TokenBlacklistService.class), mock(UserMapper.class));
        }
    }

    @RestController
    @RequestMapping("/secure")
    static class TestController {

        @GetMapping("/hello")
        public Result<String> hello() {
            return Result.success("ok");
        }

        @GetMapping("/admin")
        public Result<String> admin() {
            return Result.success("admin");
        }
    }

    @TestConfiguration
    static class TestSecurityChainConfig {

        @Bean
        @Order(0)
        SecurityFilterChain adminOnlySecurityFilterChain(HttpSecurity http, ObjectMapper objectMapper) throws Exception {
            http
                    .securityMatcher("/secure/admin")
                    .csrf(AbstractHttpConfigurer::disable)
                    .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                    .exceptionHandling(exception -> exception
                            .authenticationEntryPoint((request, response, authException) ->
                                    writeJsonError(objectMapper, response, 401, "未登录或Token已过期"))
                            .accessDeniedHandler((request, response, accessDeniedException) ->
                                    writeJsonError(objectMapper, response, 403, "无权访问该资源"))
                    )
                    .authorizeHttpRequests(auth -> auth.anyRequest().hasRole("ADMIN"));
            return http.build();
        }

        private static void writeJsonError(
                ObjectMapper objectMapper,
                jakarta.servlet.http.HttpServletResponse response,
                int code,
                String message
        ) throws IOException {
            response.setStatus(code);
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(objectMapper.writeValueAsString(Result.error(code, message)));
        }
    }
}
