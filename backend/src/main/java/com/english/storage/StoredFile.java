package com.english.storage;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class StoredFile {

    String filename;

    String relativePath;

    String url;

    long size;

    String contentType;
}
