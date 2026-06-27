package com.english.dto;

import lombok.Data;

import java.util.Collections;
import java.util.List;

@Data
public class PageResponse<T> {

    private long current;
    private long size;
    private long total;
    private List<T> records = Collections.emptyList();
}
