package com.english.controller;

import com.english.common.BusinessException;
import com.english.dto.AuthenticatedUser;
import com.english.service.StudyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;

@Tag(name = "用户导出模块", description = "用户学习记录导出接口")
@RestController
@RequestMapping("/api/user/export")
@RequiredArgsConstructor
public class UserExportController {

    private final StudyService studyService;

    @Operation(summary = "导出指定词库学习记录 CSV")
    @GetMapping("/study-records")
    public ResponseEntity<byte[]> exportStudyRecords(
            Authentication authentication,
            @RequestParam Long wordBankId
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        StudyService.StudyExportFile exportFile = studyService.exportStudyRecords(currentUser.getUserId(), wordBankId);

        ContentDisposition disposition = ContentDisposition.attachment()
                .filename(exportFile.filename(), StandardCharsets.UTF_8)
                .build();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
                .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .body(exportFile.content());
    }

    private AuthenticatedUser requireEditableUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持导出学习记录");
        }
        if ("GUEST".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "游客模式不支持导出学习记录");
        }
        return authenticatedUser;
    }
}
