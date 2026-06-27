package com.english.dto;

import lombok.Data;

@Data
public class ErrorBookClearRequest {

    private Long wordBankId;

    private String errorType;

    private Integer isMastered;
}
