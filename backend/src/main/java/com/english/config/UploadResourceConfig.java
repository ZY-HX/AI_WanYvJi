package com.english.config;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;

/**
 * 上传资源配置类
 * 配置静态资源映射，使上传的文件可以通过URL访问
 */
@Configuration
@RequiredArgsConstructor
@EnableConfigurationProperties(StorageProperties.class)
public class UploadResourceConfig implements WebMvcConfigurer {

    /** 文件存储属性配置 */
    private final StorageProperties storageProperties;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String resourceLocation = Path.of(storageProperties.getBaseDir()).toAbsolutePath().normalize().toUri().toString();
        String publicBaseUrl = storageProperties.getPublicBaseUrl();
        if (publicBaseUrl == null || publicBaseUrl.isBlank()) {
            publicBaseUrl = "/uploads";
        }
        if (!publicBaseUrl.startsWith("/")) {
            publicBaseUrl = "/" + publicBaseUrl;
        }
        if (publicBaseUrl.endsWith("/")) {
            publicBaseUrl = publicBaseUrl.substring(0, publicBaseUrl.length() - 1);
        }

        registry.addResourceHandler(publicBaseUrl + "/**")
                .addResourceLocations(resourceLocation.endsWith("/") ? resourceLocation : resourceLocation + "/");
    }
}
