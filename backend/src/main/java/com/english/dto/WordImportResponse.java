package com.english.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WordImportResponse {

    private int totalCount;
    private int successCount;
    private int failCount;
    private List<WordImportFailure> failures;

    private int totalLines;
    private int importedCount;
    private int failedCount;
    private int wordCount;
    private List<WordImportFailure> failedLines;
}
