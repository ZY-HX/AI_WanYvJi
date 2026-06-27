<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { login, type LoginPayload } from '../api/auth'
import { useUserStore } from '../stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const formRef = ref<FormInstance>()
const submitting = ref(false)

const form = reactive<LoginPayload>({
  username: '',
  password: '',
  rememberMe: true,
})

const rules: FormRules<LoginPayload> = {
  username: [{ required: true, message: '请输入管理员用户名或邮箱', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
}

async function handleLogin() {
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
    if (result.role !== 'ADMIN') {
      userStore.clear()
      ElMessage.error('当前账号不是管理员，无法登录管理员端')
      return
    }

    userStore.setToken(result.token, form.rememberMe)
    userStore.setUserInfo({
      userId: result.userId,
      username: result.username,
      nickname: result.nickname,
      email: result.email,
      role: result.role,
      avatarUrl: result.avatarUrl,
    })

    ElMessage.success('管理员登录成功')
    const redirect =
      typeof route.query.redirect === 'string' ? route.query.redirect : '/wordbanks/audit'
    await router.replace(redirect || '/wordbanks/audit')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="page-shell">
    <div class="auth-card">
      <div class="auth-header">
        <h1 class="auth-title">管理员登录</h1>
        <p class="auth-subtitle">仅支持 ADMIN 角色登录，登录后进入共享词库审核台。</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" label-position="top" size="large">
        <el-form-item label="管理员账号" prop="username">
          <el-input v-model.trim="form.username" placeholder="请输入管理员用户名或邮箱" />
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input
            v-model="form.password"
            type="password"
            show-password
            placeholder="请输入密码"
            @keyup.enter="handleLogin"
          />
        </el-form-item>

        <div class="auth-options">
          <el-checkbox v-model="form.rememberMe">保持登录</el-checkbox>
        </div>

        <el-form-item>
          <el-button type="primary" :loading="submitting" style="width: 100%" @click="handleLogin">
            登录管理台
          </el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>
