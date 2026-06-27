package com.english.storage;

import com.english.config.StorageProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LocalFileStorageService implements FileStorageService {

    private final StorageProperties storageProperties;

    @Override
    public StoredFile store(MultipartFile file, String directory, String filenamePrefix) throws IOException {
        String normalizedDirectory = normalizeRelativePath(directory);
        Path targetDirectory = resolveDirectory(normalizedDirectory);
        Files.createDirectories(targetDirectory);

        String safePrefix = sanitizeFilenamePart(filenamePrefix);
        if (!StringUtils.hasText(safePrefix)) {
            safePrefix = "file";
        }

        String filename = safePrefix + "_" + UUID.randomUUID().toString().replace("-", "") + resolveExtension(file);
        Path targetPath = targetDirectory.resolve(filename).normalize();
        if (!targetPath.startsWith(targetDirectory)) {
            throw new IOException("文件存储路径非法");
        }

        file.transferTo(targetPath);

        String relativePath = normalizedDirectory.isEmpty() ? filename : normalizedDirectory + "/" + filename;
        return StoredFile.builder()
                .filename(filename)
                .relativePath(relativePath)
                .url(buildPublicUrl(relativePath))
                .size(file.getSize())
                .contentType(file.getContentType())
                .build();
    }

    @Override
    public void delete(String fileUrl) throws IOException {
        if (!StringUtils.hasText(fileUrl)) {
            return;
        }

        String publicBaseUrl = normalizePublicBaseUrl();
        if (!fileUrl.startsWith(publicBaseUrl + "/")) {
            return;
        }

        String relativePath = fileUrl.substring(publicBaseUrl.length() + 1);
        if (!StringUtils.hasText(relativePath)) {
            return;
        }

        Files.deleteIfExists(resolveStoragePath(relativePath));
    }

    private Path resolveDirectory(String directory) throws IOException {
        return directory.isEmpty() ? resolveBaseDirectory() : resolveStoragePath(directory);
    }

    private Path resolveBaseDirectory() {
        return Path.of(storageProperties.getBaseDir()).toAbsolutePath().normalize();
    }

    private Path resolveStoragePath(String relativePath) throws IOException {
        String normalizedPath = normalizeRelativePath(relativePath);
        Path baseDirectory = resolveBaseDirectory();
        Path targetPath = baseDirectory.resolve(normalizedPath).normalize();
        if (!targetPath.startsWith(baseDirectory)) {
            throw new IOException("文件存储路径非法");
        }
        return targetPath;
    }

    private String buildPublicUrl(String relativePath) {
        return normalizePublicBaseUrl() + "/" + relativePath.replace("\\", "/");
    }

    private String normalizePublicBaseUrl() {
        String publicBaseUrl = storageProperties.getPublicBaseUrl();
        if (!StringUtils.hasText(publicBaseUrl)) {
            return "/uploads";
        }
        String normalized = publicBaseUrl.trim();
        if (!normalized.startsWith("/")) {
            normalized = "/" + normalized;
        }
        return normalized.endsWith("/") ? normalized.substring(0, normalized.length() - 1) : normalized;
    }

    private String normalizeRelativePath(String path) throws IOException {
        if (!StringUtils.hasText(path)) {
            return "";
        }

        String normalized = path.replace("\\", "/").trim();
        while (normalized.startsWith("/")) {
            normalized = normalized.substring(1);
        }

        Path relativePath = Path.of(normalized).normalize();
        if (relativePath.isAbsolute() || relativePath.startsWith("..")) {
            throw new IOException("文件存储路径非法");
        }
        return relativePath.toString().replace("\\", "/");
    }

    private String sanitizeFilenamePart(String value) {
        if (!StringUtils.hasText(value)) {
            return "";
        }
        return value.trim().replaceAll("[^a-zA-Z0-9_-]", "_");
    }

    private String resolveExtension(MultipartFile file) {
        String originalFilename = file.getOriginalFilename();
        if (StringUtils.hasText(originalFilename)) {
            int extensionIndex = originalFilename.lastIndexOf('.');
            if (extensionIndex >= 0 && extensionIndex < originalFilename.length() - 1) {
                return originalFilename.substring(extensionIndex).toLowerCase();
            }
        }

        String contentType = file.getContentType();
        if ("image/png".equals(contentType)) {
            return ".png";
        }
        if ("image/webp".equals(contentType)) {
            return ".webp";
        }
        return ".jpg";
    }
}
