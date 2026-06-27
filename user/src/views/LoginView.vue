<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { guestLogin, login, type LoginPayload } from '../api/auth'
import { useUserStore } from '../stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const formRef = ref<FormInstance>()
const submitting = ref(false)
const guestSubmitting = ref(false)

const form = reactive<LoginPayload>({
  username: '',
  password: '',
  rememberMe: true,
})

const rules: FormRules<LoginPayload> = {
  username: [{ required: true, message: '请输入用户名或邮箱', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
}

const handleLogin = async () => {
  if (!formRef.value) {
    return
  }

  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) {
    return
  }

  submitting.value = true
  try {
    const result = await login(form)
    console.log('登录响应数据:', result)

    if (!result) {
      throw new Error('登录响应为空')
    }

    const userData = (result as any).data || result
    if (!userData.token) {
      throw new Error('登录响应中缺少token字段，完整数据: ' + JSON.stringify(result))
    }

    userStore.setToken(userData.token, form.rememberMe)
    userStore.setUserInfo({
      userId: userData.userId,
      username: userData.username,
      nickname: userData.nickname,
      email: userData.email,
      role: userData.role,
      avatarUrl: userData.avatarUrl,
    })

    ElMessage.success('登录成功')

    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/'
    await router.replace(redirect || '/')
  } finally {
    submitting.value = false
  }
}

const handleGuestLogin = async () => {
  guestSubmitting.value = true
  try {
    const result = await guestLogin()
    console.log('游客登录响应数据:', result)

    if (!result) {
      throw new Error('游客登录响应为空')
    }

    const userData = (result as any).data || result
    if (!userData.token) {
      throw new Error('游客登录响应中缺少token字段')
    }

    userStore.setToken(userData.token, false)
    userStore.setUserInfo({
      userId: userData.userId,
      username: userData.username,
      nickname: userData.nickname,
      role: userData.role,
      expiresAt: userData.expiresAt,
      validityDays: userData.validityDays,
      renewLimit: userData.renewLimit,
      renewCountRemaining: userData.renewCountRemaining,
    })

    ElMessage.success('游客登录成功')
    await router.replace('/')
  } finally {
    guestSubmitting.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <!-- 背景图片层 -->
    <div class="login-background">
      <img src="/P/login.jpg" alt="登录背景" class="bg-image" />
      <div class="bg-overlay" />
    </div>

    <!-- 登录卡片容器 -->
    <div class="login-container">
      <div class="login-card">
        <!-- 标题区域 -->
        <div class="login-header">
          <h1 class="login-title">用户登录</h1>
          <p class="login-subtitle">支持用户名或邮箱 + 密码登录，登录后自动保持本地登录态</p>
        </div>

        <!-- 表单区域 -->
        <el-form
          ref="formRef"
          :model="form"
          :rules="rules"
          label-position="top"
          size="large"
          class="login-form"
        >
          <el-form-item label="用户名或邮箱" prop="username">
            <el-input
              v-model.trim="form.username"
              placeholder="请输入手机号或或用户名"
              prefix-icon="User"
            />
          </el-form-item>

          <el-form-item label="登录密码" prop="password">
            <el-input
              v-model="form.password"
              type="password"
              show-password
              placeholder="请输入密码"
              prefix-icon="Lock"
              @keyup.enter="handleLogin"
            />
          </el-form-item>

          <!-- 选项行：记住密码 + 忘记密码 -->
          <div class="form-options">
            <el-checkbox v-model="form.rememberMe">记住密码</el-checkbox>
            <a href="#" class="forgot-link">忘记密码</a>
          </div>

          <!-- 登录按钮 -->
          <el-form-item class="submit-item">
            <el-button
              type="primary"
              :loading="submitting"
              class="login-button"
              @click="handleLogin"
            >
              立即登录
            </el-button>
          </el-form-item>

          <!-- 游客体验按钮 -->
          <el-form-item class="guest-item">
            <el-button
              plain
              :loading="guestSubmitting"
              class="guest-button"
              @click="handleGuestLogin"
            >
              游客体验
            </el-button>
          </el-form-item>
        </el-form>

        <!-- 底部注册链接 -->
        <div class="login-footer">
          <span class="footer-text">没有账号？</span>
          <router-link to="/register" class="register-link">去注册 →</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ==================== 登录页面 - 毛玻璃卡片设计 ==================== */
.login-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  overflow: hidden;
}

/* ==================== 背景图片层 ==================== */
.login-background {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  z-index: 0;
}

.bg-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
}

.bg-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  background: linear-gradient(
    135deg,
    rgba(255, 255, 255, 0.1) 0%,
    rgba(255, 255, 255, 0.05) 50%,
    rgba(240, 248, 255, 0.15) 100%
  );
}

/* ==================== 登录卡片容器 ==================== */
.login-container {
  position: relative;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  max-width: 520px;
  padding: 40px 60px 40px 40px;
  margin-right: 8%;
}

/* 毛玻璃卡片效果 */
.login-card {
  width: 100%;
  max-width: 440px;
  padding: 48px 40px 36px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-radius: 24px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow:
    0 8px 32px rgba(31, 38, 135, 0.15),
    0 2px 8px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.login-card:hover {
  transform: translateY(-4px);
  box-shadow:
    0 12px 40px rgba(31, 38, 135, 0.2),
    0 4px 12px rgba(0, 0, 0, 0.08);
}

/* ==================== 标题区域 ==================== */
.login-header {
  text-align: center;
  margin-bottom: 36px;
}

.login-title {
  margin: 0 0 12px;
  font-size: 32px;
  font-weight: 700;
  color: #1a1a1a;
  letter-spacing: 1px;
}

.login-subtitle {
  margin: 0;
  font-size: 14px;
  color: #666;
  line-height: 1.6;
}

/* ==================== 表单样式 ==================== */
.login-form {
  width: 100%;
}

/* 输入框标签样式优化 */
.login-form :deep(.el-form-item__label) {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  padding-bottom: 8px;
}

/* 输入框样式优化 */
.login-form :deep(.el-input__wrapper) {
  border-radius: 12px;
  padding: 4px 16px;
  box-shadow: 0 0 0 1px #dcdfe6 inset;
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.9);
}

.login-form :deep(.el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px #c0c4cc inset;
}

.login-form :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 2px #409eff inset !important;
}

/* 选项行布局 */
.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  font-size: 13px;
}

.form-options .el-checkbox {
  color: #666;
}

.forgot-link {
  color: #409eff;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s ease;
}

.forgot-link:hover {
  color: #66b1ff;
  text-decoration: underline;
}

/* ==================== 按钮样式 ==================== */
.submit-item {
  margin-bottom: 12px !important;
}

.guest-item {
  margin-bottom: 0 !important;
}

.login-button {
  width: 100%;
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 12px;
  background: linear-gradient(135deg, #409eff 0%, #337ecc 100%);
  border: none;
  letter-spacing: 2px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

.login-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(64, 158, 255, 0.4);
}

.login-button:active {
  transform: translateY(0);
}

.guest-button {
  width: 100%;
  height: 44px;
  font-size: 14px;
  border-radius: 12px;
  border: 1px solid #dcdfe6;
  background: rgba(255, 255, 255, 0.6);
  color: #606266;
  transition: all 0.3s ease;
}

.guest-button:hover {
  border-color: #409eff;
  color: #409eff;
  background: rgba(64, 158, 255, 0.05);
}

/* ==================== 底部注册链接 ==================== */
.login-footer {
  text-align: center;
  margin-top: 28px;
  padding-top: 24px;
  border-top: 1px solid rgba(220, 223, 230, 0.5);
}

.footer-text {
  font-size: 14px;
  color: #909399;
}

.register-link {
  font-size: 14px;
  color: #409eff;
  text-decoration: none;
  font-weight: 600;
  margin-left: 4px;
  transition: all 0.2s ease;
}

.register-link:hover {
  color: #66b1ff;
  text-decoration: underline;
  transform: translateX(2px);
  display: inline-block;
}

/* ==================== 响应式适配 ==================== */

/* 平板设备 */
@media (max-width: 1200px) {
  .login-container {
    margin-right: 5%;
    padding: 30px 40px 30px 30px;
  }

  .login-card {
    padding: 40px 32px 28px;
  }
}

/* 手机设备 */
@media (max-width: 768px) {
  .login-page {
    justify-content: center;
    align-items: flex-end;
    height: 100vh;
    height: 100dvh;
  }

  .bg-image {
    object-position: center 30%;
  }

  .login-container {
    width: 100%;
    max-width: 100%;
    margin: 0;
    padding: 20px;
    padding-bottom: max(20px, env(safe-area-inset-bottom));
    height: auto;
    max-height: 90vh;
    overflow-y: auto;
  }

  .login-card {
    max-width: 100%;
    padding: 28px 20px 20px;
    border-radius: 20px 20px 0 0;
    backdrop-filter: blur(16px);
  }

  .login-title {
    font-size: 28px;
  }

  .login-subtitle {
    font-size: 13px;
  }

  .login-header {
    margin-bottom: 28px;
  }

  .login-button {
    height: 46px;
    font-size: 15px;
  }

  .form-options {
    flex-direction: column;
    gap: 8px;
    align-items: flex-start;
  }
}

/* 小屏手机 */
@media (max-width: 480px) {
  .login-card {
    padding: 24px 16px 16px;
    border-radius: 18px 18px 0 0;
  }

  .login-title {
    font-size: 24px;
    margin-bottom: 8px;
  }

  .login-subtitle {
    font-size: 12px;
    margin-bottom: 20px;
  }

  .login-header {
    margin-bottom: 20px;
  }

  .login-form :deep(.el-input__wrapper) {
    border-radius: 10px;
  }

  .login-button,
  .guest-button {
    border-radius: 10px;
  }

  .login-button {
    height: 42px;
    font-size: 14px;
  }
}
</style>
