package com.english.controller;

import com.english.common.BusinessException;
import com.english.common.Result;
import com.english.dto.RegisterRequest;
import com.english.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "用户管理", description = "用户注册相关接口")
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @Operation(summary = "用户注册")
    @PostMapping("/register")
    public Result<Void> register(@Valid @RequestBody RegisterRequest request) {
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new BusinessException(400, "两次密码输入不一致");
        }

        userService.register(request.getUsername(), request.getPassword(), request.getEmail(), request.getNickname());
        return Result.success("注册成功", null);
    }
}
