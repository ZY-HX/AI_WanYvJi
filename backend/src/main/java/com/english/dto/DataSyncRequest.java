package com.english.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class DataSyncRequest {

    @NotBlank(message = "游客Token不能为空")
    private String guestToken;
}
