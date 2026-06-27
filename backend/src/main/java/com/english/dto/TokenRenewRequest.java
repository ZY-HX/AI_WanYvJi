package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TokenRenewRequest {

    @NotBlank(message = "Token不能为空")
    private String token;
}
