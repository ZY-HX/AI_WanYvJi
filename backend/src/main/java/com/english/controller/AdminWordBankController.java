package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.AuthenticatedUser;
import com.english.dto.PageResponse;
import com.english.dto.WordBankAuditRequest;
import com.english.dto.WordBankResponse;
import com.english.service.AdminWordBankService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

@Tag(name = "管理端-共享词库审核", description = "管理员审核用户提交公开的词库")
@Validated
@RestController
@RequestMapping("/api/admin/wordbanks")
@RequiredArgsConstructor
public class AdminWordBankController {

    private final AdminWordBankService adminWordBankService;

    @Operation(summary = "分页查询待审核词库")
    @GetMapping("/pending")
    public Result<PageResponse<WordBankResponse>> getPendingWordBanks(
            Authentication authentication,
            @RequestParam(defaultValue = "1") @Min(value = 1, message = "页码必须大于0") long current,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "每页条数必须大于0") long size
    ) {
        requireAdmin(authentication);
        return Result.success("获取待审核词库成功", adminWordBankService.getPendingWordBanks(current, size));
    }

    @Operation(summary = "审核词库（通过/拒绝）")
    @PostMapping("/{id}/audit")
    public Result<WordBankResponse> auditWordBank(
            Authentication authentication,
            HttpServletRequest request,
            @PathVariable Long id,
            @Valid @RequestBody WordBankAuditRequest auditRequest
    ) {
        AuthenticatedUser admin = requireAdmin(authentication);
        String ipAddress = resolveIp(request);
        WordBankResponse response = adminWordBankService.auditWordBank(admin.getUserId(), id, auditRequest, ipAddress);
        return Result.success("审核完成", response);
    }

    private AuthenticatedUser requireAdmin(Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof AuthenticatedUser authenticatedUser)) {
            throw new BusinessException(403, "当前身份不支持访问管理端接口");
        }
        if (!"ADMIN".equals(authenticatedUser.getRole())) {
            throw new BusinessException(403, "仅管理员可访问");
        }
        return authenticatedUser;
    }

    private String resolveIp(HttpServletRequest request) {
        if (request == null) {
            return "unknown";
        }
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            String first = forwarded.split(",")[0].trim();
            if (!first.isBlank()) {
                return first;
            }
        }
        String realIp = request.getHeader("X-Real-IP");
        if (realIp != null && !realIp.isBlank()) {
            return realIp.trim();
        }
        return request.getRemoteAddr();
    }
}
