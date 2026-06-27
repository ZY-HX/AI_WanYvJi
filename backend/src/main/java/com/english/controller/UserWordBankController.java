package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.WordBankAddWordRequest;
import com.english.dto.WordBankResponse;
import com.english.entity.Word;
import com.english.entity.WordBank;
import com.english.service.WordBankService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Tag(name = "用户词库扩展", description = "用户自定义词库扩展能力")
@Validated
@RestController
@RequestMapping("/api/user/word-banks")
@RequiredArgsConstructor
public class UserWordBankController {

    private final WordBankService wordBankService;

    @Operation(summary = "将单词加入指定自定义词库")
    @PostMapping("/{id}/add-word")
    public Result<WordBankResponse> addWordToWordBank(
            Authentication authentication,
            @PathVariable Long id,
            @Valid @RequestBody WordBankAddWordRequest request
    ) {
        AuthenticatedUser currentUser = requireEditableUser(authentication);
        return Result.success("添加单词成功", wordBankService.addWord(currentUser.getUserId(), id, request));
    }

    @Operation(summary = "下载共享词库为TXT文件")
    @GetMapping("/{id}/download")
    public void downloadWordBankAsTxt(
            Authentication authentication,
            @PathVariable Long id,
            HttpServletResponse response
    ) throws IOException {
        AuthenticatedUser currentUser = requireCurrentUser(authentication);

        WordBank wordBank = wordBankService.exportWordBankAsTxt(currentUser.getUserId(), id);
        List<Word> words = wordBankService.getWordsForExport(id);
        String txtContent = wordBankService.generateTxtContent(words);
        String fileName = wordBankService.generateDownloadFileName(wordBank);

        String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader(HttpHeaders.CONTENT_DISPOSITION,
                "attachment;filename=\"" + encodedFileName + "\";filename*=UTF-8''" + encodedFileName);
        response.setContentLength(txtContent.getBytes(StandardCharsets.UTF_8).length);

        try (OutputStream outputStream = response.getOutputStream()) {
            outputStream.write(txtContent.getBytes(StandardCharsets.UTF_8));
            outputStream.flush();
        }
    }

    private AuthenticatedUser requireCurrentUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持操作词库");
        }
        return authenticatedUser;
    }

    private AuthenticatedUser requireEditableUser(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持操作自定义词库");
        }
        if ("GUEST".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "游客模式不支持操作自定义词库");
        }
        return authenticatedUser;
    }
}
