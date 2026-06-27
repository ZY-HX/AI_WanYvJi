package com.english.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WordImportFailure {

    private Integer lineNumber;
    private String content;
    private String reason;
}
