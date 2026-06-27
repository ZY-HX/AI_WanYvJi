<template>
  <div class="page-shell">
    <div class="auth-card">
      <div class="auth-header">
        <h1 class="auth-title">游客入口</h1>
        <p class="auth-subtitle">游客模式将在下一个模块继续实现，这里先保留免登录访问入口。</p>
      </div>

      <el-alert title="当前阶段已完成登录白名单预留，下一阶段会接入真实游客 Token。" type="info" :closable="false" show-icon />

      <div class="guest-actions">
        <router-link to="/login">
          <el-button type="primary" style="width: 100%">返回登录</el-button>
        </router-link>
      </div>
    </div>
  </div>
</template>
