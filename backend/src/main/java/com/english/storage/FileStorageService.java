package com.english.storage;

import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface FileStorageService {

    StoredFile store(MultipartFile file, String directory, String filenamePrefix) throws IOException;

    void delete(String fileUrl) throws IOException;
}
