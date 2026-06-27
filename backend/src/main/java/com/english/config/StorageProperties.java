package com.english.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 文件存储属性配置类
 * 从application.yml中读取文件上传相关的配置项
 */
@Data
@ConfigurationProperties(prefix = "app.upload")
public class StorageProperties {

    /** 文件存储基础目录 */
    private String baseDir = "uploads";

    /** 文件访问的基础URL路径 */
    private String publicBaseUrl = "/uploads";
}
