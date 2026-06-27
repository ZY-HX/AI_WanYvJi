<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { register, type RegisterPayload } from '../api/auth'

const router = useRouter()
const formRef = ref<FormInstance>()
const submitting = ref(false)
const agreedToTerms = ref(false)

const form = reactive<RegisterPayload>({
  username: '',
  nickname: '',
  email: '',
  password: '',
  confirmPassword: '',
})

const validateConfirmPassword = (_rule: unknown, value: string, callback: (error?: Error) => void) => {
  if (!value) {
    callback(new Error('请再次输入确认密码'))
    return
  }

  if (value !== form.password) {
    callback(new Error('两次密码输入不一致'))
    return
  }

  callback()
}

const rules: FormRules<RegisterPayload> = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度为3-20个字符', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '用户名只能包含字母、数字和下划线', trigger: 'blur' },
  ],
  nickname: [
    { max: 50, message: '昵称长度不能超过50个字符', trigger: 'blur' },
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '邮箱格式不正确', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20个字符', trigger: 'blur' },
  ],
  confirmPassword: [
    { required: true, message: '请输入确认密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' },
  ],
}

const handleRegister = async () => {
  if (!formRef.value) {
    return
  }

  if (!agreedToTerms.value) {
    ElMessage.warning('请先阅读并同意用户协议')
    return
  }

  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) {
    return
  }

  submitting.value = true
  try {
    await register(form)
    ElMessage.success('注册成功，即将跳转到登录页')
    await router.push('/login')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="register-page">
    <!-- 背景图片层 -->
    <div class="register-background">
      <img src="/P/register.jpg" alt="注册背景" class="bg-image" />
      <div class="bg-overlay" />
    </div>

    <!-- 注册卡片容器 -->
    <div class="register-container">
      <div class="register-card">
        <!-- 标题区域 -->
        <div class="register-header">
          <h1 class="register-title">CREATE YOUR ACCOUNT</h1>
          <h2 class="register-subtitle">加入万语集</h2>
        </div>

        <!-- 表单区域 -->
        <el-form
          ref="formRef"
          :model="form"
          :rules="rules"
          label-position="top"
          size="large"
          class="register-form"
        >
          <el-form-item label="用户名" prop="username">
            <el-input
              v-model.trim="form.username"
              placeholder="请输入3-20位用户名"
              prefix-icon="User"
            />
          </el-form-item>

          <el-form-item label="昵称（可选）" prop="nickname">
            <el-input
              v-model.trim="form.nickname"
              placeholder="请输入昵称，不填则默认使用用户名"
              prefix-icon="Star"
            />
          </el-form-item>

          <el-form-item label="邮箱" prop="email">
            <el-input
              v-model.trim="form.email"
              placeholder="请输入邮箱地址"
              prefix-icon="Message"
            />
          </el-form-item>

          <el-form-item label="密码" prop="password">
            <el-input
              v-model="form.password"
              type="password"
              show-password
              placeholder="请输入6-20位密码"
              prefix-icon="Lock"
            />
          </el-form-item>

          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input
              v-model="form.confirmPassword"
              type="password"
              show-password
              placeholder="请再次输入密码"
              prefix-icon="Lock"
              @keyup.enter="handleRegister"
            />
          </el-form-item>

          <!-- 用户协议 -->
          <div class="terms-agreement">
            <el-checkbox v-model="agreedToTerms">我已阅读并同意《用户协议》</el-checkbox>
          </div>

          <!-- 注册按钮 -->
          <el-form-item class="submit-item">
            <el-button
              type="primary"
              :loading="submitting"
              class="register-button"
              @click="handleRegister"
            >
              立即注册
            </el-button>
          </el-form-item>
        </el-form>

        <!-- 底部登录链接 -->
        <div class="register-footer">
          <span class="footer-text">已有账号？</span>
          <router-link to="/login" class="login-link">去登录 →</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ==================== 注册页面 - 毛玻璃卡片设计 ==================== */
.register-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

/* ==================== 背景图片层 ==================== */
.register-background {
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
    rgba(255, 248, 240, 0.15) 0%,
    rgba(255, 245, 230, 0.1) 50%,
    rgba(255, 250, 245, 0.18) 100%
  );
}

/* ==================== 注册卡片容器 ==================== */
.register-container {
  position: relative;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
  width: auto;
  max-width: 480px;
  padding: 20px;
}

/* 毛玻璃卡片效果 - 紧凑版 */
.register-card {
  width: 460px;
  max-width: 460px;
  padding: 28px 30px 22px;
  background: rgba(255, 255, 255, 0.88);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.7);
  box-shadow:
    0 8px 32px rgba(180, 140, 100, 0.12),
    0 2px 8px rgba(0, 0, 0, 0.04);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.register-card:hover {
  transform: translateY(-4px);
  box-shadow:
    0 12px 40px rgba(180, 140, 100, 0.18),
    0 4px 12px rgba(0, 0, 0, 0.06);
}

/* ==================== 标题区域 ==================== */
.register-header {
  text-align: center;
  margin-bottom: 18px;
}

.register-title {
  margin: 0 0 4px;
  font-size: 20px;
  font-weight: 700;
  color: #d4875c;
  letter-spacing: 1.2px;
  line-height: 1.2;
}

.register-subtitle {
  margin: 0;
  font-size: 17px;
  font-weight: 600;
  color: #8b6914;
  letter-spacing: 2px;
}

/* ==================== 表单样式 ==================== */
.register-form {
  width: 100%;
}

/* 输入框标签样式优化 */
.register-form :deep(.el-form-item__label) {
  font-size: 12px;
  font-weight: 600;
  color: #555;
  padding-bottom: 4px;
}

/* 输入框样式优化 */
.register-form :deep(.el-input__wrapper) {
  border-radius: 8px;
  padding: 3px 12px;
  box-shadow: 0 0 0 1px #e8dcc8 inset;
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.95);
}

.register-form :deep(.el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px #d4c4a8 inset;
}

.register-form :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 2px #e6a86c inset !important;
}

/* 减小表单项间距 */
.register-form :deep(.el-form-item) {
  margin-bottom: 12px;
}

/* 用户协议 */
.terms-agreement {
  margin-bottom: 14px;
  font-size: 11px;
}

.terms-agreement .el-checkbox {
  color: #666;
}

/* ==================== 按钮样式 ==================== */
.submit-item {
  margin-bottom: 0 !important;
}

.register-button {
  width: 100%;
  height: 40px;
  font-size: 14px;
  font-weight: 600;
  border-radius: 8px;
  background: linear-gradient(135deg, #f5b89a 0%, #e6996f 100%);
  border: none;
  letter-spacing: 2px;
  color: #fff;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(230, 153, 111, 0.35);
}

.register-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(230, 153, 111, 0.45);
  background: linear-gradient(135deg, #f0a885 0%, #dd8a5f 100%);
}

.register-button:active {
  transform: translateY(0);
}

/* ==================== 底部登录链接 ==================== */
.register-footer {
  text-align: center;
  margin-top: 14px;
  padding-top: 12px;
  border-top: 1px solid rgba(220, 210, 195, 0.5);
}

.footer-text {
  font-size: 14px;
  color: #909399;
}

.login-link {
  font-size: 14px;
  color: #e6996f;
  text-decoration: none;
  font-weight: 600;
  margin-left: 4px;
  transition: all 0.2s ease;
}

.login-link:hover {
  color: #d4875c;
  text-decoration: underline;
  transform: translateX(2px);
  display: inline-block;
}

/* ==================== 响应式适配 ==================== */

/* 平板设备 */
@media (max-width: 1200px) {
  .register-container {
    padding: 20px;
  }

  .register-card {
    padding: 28px 26px 22px;
  }
}

/* 手机设备 */
@media (max-width: 768px) {
  .register-page {
    justify-content: center;
    align-items: flex-end;
    height: 100vh;
    height: 100dvh;
  }

  .bg-image {
    object-position: center 35%;
  }

  .register-container {
    width: 100%;
    max-width: 100%;
    margin: 0;
    padding: 16px;
    padding-bottom: max(12px, env(safe-area-inset-bottom));
    height: auto;
    max-height: 95vh;
    overflow-y: auto;
  }

  .register-card {
    max-width: 100%;
    padding: 24px 18px 18px;
    border-radius: 18px 18px 0 0;
    backdrop-filter: blur(16px);
  }

  .register-title {
    font-size: 20px;
  }

  .register-subtitle {
    font-size: 17px;
  }

  .register-header {
    margin-bottom: 20px;
  }

  .register-button {
    height: 42px;
    font-size: 14px;
  }

  .terms-agreement {
    margin-bottom: 14px;
  }
}

/* 小屏手机 */
@media (max-width: 480px) {
  .register-card {
    padding: 20px 14px 14px;
    border-radius: 16px 16px 0 0;
  }

  .register-title {
    font-size: 18px;
    margin-bottom: 4px;
  }

  .register-subtitle {
    font-size: 16px;
  }

  .register-header {
    margin-bottom: 16px;
  }

  .register-form :deep(.el-input__wrapper) {
    border-radius: 8px;
  }

  .register-button {
    border-radius: 8px;
    height: 40px;
    font-size: 13px;
  }
}
</style>
