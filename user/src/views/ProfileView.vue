<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules, type UploadProps, type UploadRequestOptions } from 'element-plus'
import dayjs from 'dayjs'
import http from '../api/http'
import {
  changePassword,
  getProfile,
  updateProfile,
  uploadAvatar,
  type ChangePasswordPayload,
  type UpdateProfilePayload,
  type UserProfile,
} from '../api/profile'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const saving = ref(false)
const uploading = ref(false)
const passwordSubmitting = ref(false)
const passwordDialogVisible = ref(false)

const profile = ref<UserProfile | null>(null)
const profileFormRef = ref<FormInstance>()
const passwordFormRef = ref<FormInstance>()

const profileForm = reactive<UpdateProfilePayload>({
  username: '',
  nickname: '',
  email: '',
  studySessionSize: 20,
  allowSameDayReview: true,
})

const passwordForm = reactive<ChangePasswordPayload>({
  oldPassword: '',
  newPassword: '',
  confirmPassword: '',
})

const profileRules: FormRules<UpdateProfilePayload> = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度为3-20个字符', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '用户名只能包含字母、数字和下划线', trigger: 'blur' },
  ],
  nickname: [{ max: 50, message: '昵称长度不能超过50个字符', trigger: 'blur' }],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '邮箱格式不正确', trigger: 'blur' },
  ],
  studySessionSize: [
    { required: true, message: '请输入单次学习题量', trigger: 'change' },
    { type: 'number', min: 5, max: 100, message: '单次学习题量范围为 5-100', trigger: 'change' },
  ],
}

const passwordRules: FormRules<ChangePasswordPayload> = {
  oldPassword: [{ required: true, message: '请输入旧密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '新密码长度为6-20个字符', trigger: 'blur' },
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (_rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次新密码输入不一致'))
          return
        }
        callback()
      },
      trigger: 'blur',
    },
  ],
}

const isGuest = computed(() => (profile.value?.role ?? userStore.userInfo?.role) === 'GUEST')
const avatarUrl = computed(() => {
  const value = profile.value?.avatarUrl
  if (!value) {
    return ''
  }
  if (/^https?:\/\//.test(value)) {
    return value
  }
  const base = (http.defaults.baseURL ?? '').replace(/\/+$/, '')
  if (!base) {
    return value
  }
  const path = value.replace(/^\/+/, '')
  return `${base}/${path}`
})
const displayName = computed(() => profile.value?.nickname || profile.value?.username || '未命名用户')
const formattedCreatedAt = computed(() =>
  profile.value?.createdAt ? dayjs(profile.value.createdAt).format('YYYY-MM-DD HH:mm:ss') : '-',
)

onMounted(async () => {
  await fetchProfile()
})

async function fetchProfile() {
  loading.value = true
  try {
    const result = await getProfile()
    const userData = result
    if (userData) {
      applyProfile(userData)
    } else {
      console.warn('无法获取用户数据')
    }
  } catch (error) {
    console.error('获取个人信息失败:', error)
  } finally {
    loading.value = false
  }
}

function applyProfile(data: UserProfile) {
  profile.value = data
  profileForm.username = data.username ?? ''
  profileForm.nickname = data.nickname ?? ''
  profileForm.email = data.email ?? ''
  profileForm.studySessionSize = data.studySessionSize ?? 20
  profileForm.allowSameDayReview = data.allowSameDayReview ?? true
  userStore.setUserInfo({
    ...userStore.userInfo,
    userId: data.userId,
    username: data.username,
    nickname: data.nickname,
    email: data.email,
    role: data.role,
    avatarUrl: data.avatarUrl,
  })
}

async function handleSaveProfile() {
  if (!profileFormRef.value || isGuest.value) {
    return
  }

  const valid = await profileFormRef.value.validate().catch(() => false)
  if (!valid) {
    return
  }

  saving.value = true
  try {
    const result = await updateProfile(profileForm)
    const userData = result
    if (userData) {
      applyProfile(userData)
      ElMessage.success('个人资料已更新')
    } else {
      ElMessage.warning('保存成功，但返回数据异常')
    }
  } finally {
    saving.value = false
  }
}

const beforeAvatarUpload: UploadProps['beforeUpload'] = (rawFile) => {
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp']
  if (!allowedTypes.includes(rawFile.type)) {
    ElMessage.error('头像仅支持 JPG、PNG、WEBP 格式')
    return false
  }
  if (rawFile.size / 1024 / 1024 > 2) {
    ElMessage.error('头像大小不能超过 2MB')
    return false
  }
  return true
}

const handleAvatarUpload: UploadProps['httpRequest'] = async (options: UploadRequestOptions) => {
  if (isGuest.value) {
    ElMessage.warning('游客模式仅支持查看资料')
    return
  }

  uploading.value = true
  try {
    const result = await uploadAvatar(options.file)
    const avatarData = result
    if (!avatarData?.avatarUrl) {
      ElMessage.error('头像上传失败，返回数据异常')
      return
    }

    const nextProfile: UserProfile = {
      ...(profile.value as UserProfile),
      avatarUrl: avatarData.avatarUrl,
    }
    applyProfile(nextProfile)
    options.onSuccess?.(avatarData)
    ElMessage.success('头像上传成功')
  } catch {
  } finally {
    uploading.value = false
  }
}

function openPasswordDialog() {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持修改密码')
    return
  }
  passwordDialogVisible.value = true
}

function resetPasswordForm() {
  passwordForm.oldPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
  passwordFormRef.value?.clearValidate()
}

async function handleChangePassword() {
  if (!passwordFormRef.value) {
    return
  }

  const valid = await passwordFormRef.value.validate().catch(() => false)
  if (!valid) {
    return
  }

  passwordSubmitting.value = true
  try {
    await changePassword(passwordForm)
    passwordDialogVisible.value = false
    resetPasswordForm()
    userStore.clear()
    ElMessage.success('密码修改成功，请重新登录')
    await router.replace('/login')
  } finally {
    passwordSubmitting.value = false
  }
}
</script>

<template>
  <div class="profile-page">
    <div class="profile-page__header">
      <div>
        <h1>个人中心</h1>
        <p>查看并维护当前账号的头像、用户名、邮箱、密码与学习计划。</p>
      </div>
      <div class="profile-page__actions">
        <el-button @click="router.push('/')">返回首页</el-button>
        <el-button type="primary" plain @click="openPasswordDialog">修改密码</el-button>
      </div>
    </div>

    <el-alert
      v-if="isGuest"
      title="当前为游客模式，仅支持查看个人资料，无法修改头像、用户名、邮箱和密码。"
      type="warning"
      :closable="false"
      show-icon
      class="profile-alert"
    />

    <el-skeleton :loading="loading" animated :rows="8">
      <template #default>
        <div v-if="profile" class="profile-layout">
          <el-card class="profile-card profile-card--summary" shadow="hover">
            <div class="summary-panel">
              <el-avatar :size="96" :src="avatarUrl">
                {{ displayName.slice(0, 1).toUpperCase() }}
              </el-avatar>
              <div class="summary-panel__meta">
                <h2>{{ displayName }}</h2>
                <p>用户名：{{ profile.username }}</p>
                <p>邮箱：{{ profile.email }}</p>
                <p>角色：{{ profile.role }}</p>
                <p>注册时间：{{ formattedCreatedAt }}</p>
              </div>
            </div>

            <el-upload
              class="avatar-upload"
              :show-file-list="false"
              :disabled="isGuest || uploading"
              :before-upload="beforeAvatarUpload"
              :http-request="handleAvatarUpload"
            >
              <el-button :loading="uploading" :disabled="isGuest">上传新头像</el-button>
            </el-upload>
          </el-card>

          <el-card class="profile-card" shadow="hover">
            <template #header>
              <div class="profile-card__header">
                <span>基本资料</span>
                <span class="profile-card__tip">修改成功后会同步刷新本地登录信息和学习计划</span>
              </div>
            </template>

            <el-form
              ref="profileFormRef"
              :model="profileForm"
              :rules="profileRules"
              label-position="top"
              size="large"
            >
              <el-form-item label="用户名" prop="username">
                <el-input v-model.trim="profileForm.username" :disabled="isGuest" placeholder="请输入用户名" />
              </el-form-item>

              <el-form-item label="昵称" prop="nickname">
                <el-input v-model.trim="profileForm.nickname" :disabled="isGuest" placeholder="请输入昵称" />
              </el-form-item>

              <el-form-item label="邮箱" prop="email">
                <el-input v-model.trim="profileForm.email" :disabled="isGuest" placeholder="请输入邮箱" />
              </el-form-item>

              <el-divider content-position="left">学习计划</el-divider>

              <el-form-item label="单次学习题量" prop="studySessionSize">
                <el-input-number
                  v-model="profileForm.studySessionSize"
                  :min="5"
                  :max="100"
                  :step="5"
                  :disabled="isGuest"
                />
                <div class="profile-form__tip">控制学习页每次拉取和展示的题目数量</div>
              </el-form-item>

              <el-form-item label="学完后允许当天继续复习">
                <el-switch v-model="profileForm.allowSameDayReview" :disabled="isGuest" />
                <div class="profile-form__tip">开启后，即使当天计划做完，也可继续滚动复习已学过的单词</div>
              </el-form-item>

              <el-form-item>
                <el-button type="primary" :loading="saving" :disabled="isGuest" @click="handleSaveProfile">
                  保存资料
                </el-button>
              </el-form-item>
            </el-form>
          </el-card>
        </div>
      </template>
    </el-skeleton>

    <el-dialog
      v-model="passwordDialogVisible"
      title="修改密码"
      width="460px"
      @closed="resetPasswordForm"
    >
      <el-form
        ref="passwordFormRef"
        :model="passwordForm"
        :rules="passwordRules"
        label-position="top"
      >
        <el-form-item label="旧密码" prop="oldPassword">
          <el-input v-model="passwordForm.oldPassword" type="password" show-password placeholder="请输入旧密码" />
        </el-form-item>

        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="passwordForm.newPassword" type="password" show-password placeholder="请输入新密码" />
        </el-form-item>

        <el-form-item label="确认新密码" prop="confirmPassword">
          <el-input
            v-model="passwordForm.confirmPassword"
            type="password"
            show-password
            placeholder="请再次输入新密码"
            @keyup.enter="handleChangePassword"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="passwordDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="passwordSubmitting" @click="handleChangePassword">
          确认修改
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
/* ==================== 深色主题 - 个人中心 ==================== */
.profile-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(20px, 3vw, 40px) clamp(16px, 3vw, 24px) 56px;
  background: linear-gradient(180deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
}

.profile-page__header {
  max-width: 1080px;
  margin: 0 auto 20px;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
}

.profile-page__header h1 {
  margin: 0 0 8px;
  font-size: 30px;
  color: #38bdf8;
  font-weight: 700;
}

.profile-page__header p {
  margin: 0;
  color: #94a3b8;
}

.profile-page__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.profile-alert {
  max-width: 1080px;
  margin: 0 auto 20px;
}

.profile-layout {
  max-width: 1080px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 320px minmax(0, 1fr);
  gap: 20px;
}

.profile-card {
  border-radius: 20px;
  border: 1px solid rgba(56, 189, 248, 0.18);
  background: rgba(20, 50, 85, 0.32) !important;
  backdrop-filter: blur(12px);
  transition: all 0.3s ease;
}

.profile-card:hover {
  border-color: rgba(56, 189, 248, 0.5);
  box-shadow: 0 10px 28px rgba(56, 189, 248, 0.2);
}

.profile-card--summary {
  height: fit-content;
}

.summary-panel {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 20px;
}

.summary-panel__meta h2 {
  margin: 0 0 12px;
  font-size: 24px;
  color: #ffffff;
  font-weight: 600;
  text-shadow:
    0 0 10px rgba(56, 189, 248, 0.5),
    0 0 25px rgba(56, 189, 248, 0.2),
    0 1px 3px rgba(0, 0, 0, 0.4);
}

.summary-panel__meta p {
  margin: 8px 0 0;
  color: #e2e8f0;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.avatar-upload {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.profile-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  font-weight: 600;
  color: #e2e8f0;
}

.profile-card__tip {
  font-size: 13px;
  font-weight: 400;
  color: #64748b;
}

.profile-form__tip {
  margin-top: 8px;
  color: #64748b;
  font-size: 13px;
  line-height: 1.6;
}

/* Element Plus 深色覆盖 */
.profile-page :deep(.el-form-item__label) {
  color: #cbd5e1;
  font-weight: 500;
}

.profile-page :deep(.el-input__wrapper) {
  background: rgba(15, 23, 42, 0.6) !important;
  box-shadow: 0 0 0 1px rgba(51, 65, 85, 0.7) inset !important;
}

.profile-page :deep(.el-input__inner) {
  color: #f1f5f9;
}

.profile-page :deep(.el-input__inner::placeholder) {
  color: #475569;
}

.profile-page :deep(.el-divider__text) {
  color: #94a3b8;
  background-color: transparent;
}

@media (max-width: 900px) {
  .profile-page__header,
  .profile-layout {
    max-width: 100%;
  }

  .profile-page__header {
    flex-direction: column;
  }

  .profile-layout {
    grid-template-columns: 1fr;
  }

  .profile-page__actions {
    width: 100%;
    justify-content: flex-start;
  }
}
</style>
