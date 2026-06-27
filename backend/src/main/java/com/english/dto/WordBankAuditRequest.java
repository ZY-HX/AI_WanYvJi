package com.english.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class WordBankAuditRequest {

    @NotNull(message = "审核结果不能为空")
    private Boolean approved;

    @Size(max = 500, message = "拒绝理由不能超过500个字符")
    private String reason;
}
