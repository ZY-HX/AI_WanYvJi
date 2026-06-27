package com.english.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAPI（Swagger）配置类
 * 用于自动生成RESTful API接口文档，提供在线测试功能
 * 配置内容包括：API基本信息、JWT认证方案等
 * 访问地址：http://localhost:端口/swagger-ui.html
 */
@Configuration
public class OpenApiConfig {

    /**
     * 创建并配置OpenAPI Bean
     * 定义API文档的基本信息和安全认证方案：
     * 1. 设置API标题、描述和版本号
     * 2. 配置JWT Bearer Token认证机制
     * 3. 全局启用认证要求
     *
     * @return 配置完成的OpenAPI实例
     */
    @Bean
    public OpenAPI englishLearningMateOpenApi() {
        // 定义安全方案的名称
        String securitySchemeName = "bearerAuth";
        return new OpenAPI()
                // 配置API基本信息
                .info(new Info()
                        .title("English Learning Mate API")                    // API标题
                        .description("AI驱动的英语词汇学习平台后端接口文档")      // API描述
                        .version("1.0.0"))                                     // API版本号
                // 配置安全组件：定义JWT Bearer Token认证方案
                .components(new Components().addSecuritySchemes(
                        securitySchemeName,
                        new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP)   // HTTP认证类型
                                .scheme("bearer")                  // Bearer Token方案
                                .bearerFormat("JWT")              // Token格式为JWT
                ))
                // 添加全局安全要求：所有接口都需要携带JWT Token
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName));
    }
}
