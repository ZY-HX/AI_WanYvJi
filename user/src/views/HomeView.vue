<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getCurrentUser, renewGuestToken } from '../api/auth'
import { getDashboardHome, type DashboardHomeData } from '../api/dashboard'
import { useUserStore } from '../stores/user'
import {
  getLearningLanguageLabel,
  getLearningLanguageOptions,
  getPreferredLearningLanguage,
  setPreferredLearningLanguage,
  type LearningLanguage,
} from '../shared/learningLanguage'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(true)
const dashboardLoading = ref(true)
const serverMessage = ref('正在校验当前登录态...')
const renewing = ref(false)
const now = ref(Date.now())
const dashboardData = ref<DashboardHomeData | null>(null)
let timer: number | undefined
const selectedLanguage = ref<LearningLanguage>(getPreferredLearningLanguage())
const languageOptions = getLearningLanguageOptions()

const isGuest = computed(() => userStore.userInfo?.role === 'GUEST')
const expiresAt = computed(() => userStore.userInfo?.expiresAt ?? 0)
const renewCountRemaining = computed(() => userStore.userInfo?.renewCountRemaining ?? 0)
const remainingMs = computed(() => Math.max(expiresAt.value - now.value, 0))
const shouldShowRenewReminder = computed(
  () => isGuest.value && remainingMs.value > 0 && remainingMs.value <= 24 * 60 * 60 * 1000 && renewCountRemaining.value > 0,
)

const formatRemaining = computed(() => {
  if (!isGuest.value || !expiresAt.value) {
    return '-'
  }

  const totalMinutes = Math.floor(remainingMs.value / (1000 * 60))
  const days = Math.floor(totalMinutes / (60 * 24))
  const hours = Math.floor((totalMinutes % (60 * 24)) / 60)
  const minutes = totalMinutes % 60

  if (days > 0) {
    return `${days}天${hours}小时`
  }

  return `${hours}小时${minutes}分钟`
})
const selectedLanguageLabel = computed(() => getLearningLanguageLabel(selectedLanguage.value))

onMounted(async () => {
  try {
    const result = await getCurrentUser()
    userStore.setUserInfo({
      ...userStore.userInfo,
      ...result,
    })
    serverMessage.value = '受保护接口访问成功，JWT 已随请求自动携带'
  } catch {
    serverMessage.value = '登录已失效，请重新登录'
  } finally {
    loading.value = false
  }

  await fetchDashboardData()

  timer = window.setInterval(() => {
    now.value = Date.now()
  }, 60000)
})

onBeforeUnmount(() => {
  if (timer) {
    window.clearInterval(timer)
  }
})

async function fetchDashboardData() {
  dashboardLoading.value = true
  try {
    const result = await getDashboardHome()
    dashboardData.value = result
  } catch (error: any) {
    console.error('获取仪表板数据失败:', error)
  } finally {
    dashboardLoading.value = false
  }
}


const handleGuestRenew = async () => {
  if (!userStore.token) {
    return
  }

  renewing.value = true
  try {
    const result = await renewGuestToken(userStore.token)
    userStore.setToken(result.token, false)
    userStore.setUserInfo({
      ...userStore.userInfo,
      userId: result.userId,
      username: result.username,
      nickname: result.nickname,
      role: result.role,
      expiresAt: result.expiresAt,
      validityDays: result.validityDays,
      renewLimit: result.renewLimit,
      renewCountRemaining: result.renewCountRemaining,
    })
    now.value = Date.now()
    ElMessage.success('游客 Token 续期成功')
  } finally {
    renewing.value = false
  }
}

const handleConvertToUser = async () => {
  await router.push('/register')
}

const handleLanguageChange = (language: LearningLanguage) => {
  setPreferredLearningLanguage(language)
  ElMessage.success(`已切换为${getLearningLanguageLabel(language)}`)
}

const goToStudy = async () => {
  await router.push(`/study?language=${selectedLanguage.value}`)
}

const goToMyWordBanks = async () => {
  await router.push(`/wordbanks?language=${selectedLanguage.value}`)
}

const goToPublicWordBanks = async () => {
  await router.push(`/public-wordbanks?language=${selectedLanguage.value}`)
}

const goToReview = async () => {
  await router.push(`/review?language=${selectedLanguage.value}`)
}
</script>

<template>
  <div class="dashboard-page">
    <div v-if="isGuest" class="guest-banner">
      <div class="guest-banner-content">
        <div>
          <strong>当前为游客身份</strong>
          <p>剩余有效期：{{ formatRemaining }}，剩余续期次数：{{ renewCountRemaining }}</p>
        </div>
        <div class="guest-banner-actions">
          <el-button v-if="renewCountRemaining > 0" :loading="renewing" @click="handleGuestRenew">
            立即续期
          </el-button>
          <el-button type="primary" @click="handleConvertToUser">转为正式用户</el-button>
        </div>
      </div>
    </div>

    <el-alert
      v-if="shouldShowRenewReminder"
      title="游客 Token 即将过期，请及时续期"
      type="warning"
      :closable="false"
      show-icon
      class="dashboard-alert"
    />

    <div class="dashboard-welcome">
      <h1>欢迎回来，{{ userStore.userInfo?.nickname || userStore.userInfo?.username || '用户' }}！</h1>
      <p>今天是学习的第 {{ dashboardData?.consecutiveDays || 0 }} 天，继续加油！</p>
      <div class="language-switch">
        <span>学习语种：</span>
        <el-select v-model="selectedLanguage" style="width: 130px" @change="handleLanguageChange">
          <el-option v-for="item in languageOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <span class="language-switch__tip">当前语种：{{ selectedLanguageLabel }}</span>
      </div>
    </div>

    <el-skeleton animated :loading="dashboardLoading">
      <template #template>
        <div class="stats-skeleton">
          <div v-for="item in 5" :key="item" class="stats-skeleton__item" />
        </div>
      </template>
      <template #default>
        <div class="stats-cards">
          <el-card class="stat-card stat-card--review" shadow="hover">
            <div class="stat-card__icon">
              <span class="iconfont icon-review">📚</span>
            </div>
            <div class="stat-card__content">
              <div class="stat-card__value">{{ dashboardData?.todayReviewCount || 0 }}</div>
              <div class="stat-card__label">今日待复习</div>
            </div>
          </el-card>

          <el-card class="stat-card stat-card--streak" shadow="hover">
            <div class="stat-card__icon">
              <span class="iconfont icon-streak">🔥</span>
            </div>
            <div class="stat-card__content">
              <div class="stat-card__value">{{ dashboardData?.consecutiveDays || 0 }}</div>
              <div class="stat-card__label">连续学习天数</div>
            </div>
          </el-card>

          <el-card class="stat-card stat-card--time" shadow="hover">
            <div class="stat-card__icon">
              <span class="iconfont icon-time">⏱️</span>
            </div>
            <div class="stat-card__content">
              <div class="stat-card__value">{{ dashboardData?.todayStudyMinutes || 0 }}<small>分钟</small></div>
              <div class="stat-card__label">今日学习时长</div>
            </div>
          </el-card>

          <el-card class="stat-card stat-card--words" shadow="hover">
            <div class="stat-card__icon">
              <span class="iconfont icon-words">📝</span>
            </div>
            <div class="stat-card__content">
              <div class="stat-card__value">{{ dashboardData?.totalWordsLearned || 0 }}</div>
              <div class="stat-card__label">累计学习单词</div>
            </div>
          </el-card>

          <el-card class="stat-card stat-card--banks" shadow="hover">
            <div class="stat-card__icon">
              <span class="iconfont icon-banks">📖</span>
            </div>
            <div class="stat-card__content">
              <div class="stat-card__value">{{ dashboardData?.totalWordBanks || 0 }}</div>
              <div class="stat-card__label">活跃词库数</div>
            </div>
          </el-card>
        </div>
      </template>
    </el-skeleton>

    <div class="quick-actions">
      <h2>快捷入口</h2>
      <div class="action-grid">
        <el-card class="action-card" shadow="hover" @click="goToStudy">
          <div class="action-card__icon">✏️</div>
          <h3>开始学习</h3>
          <p>按艾宾浩斯计划复习单词</p>
        </el-card>

        <el-card class="action-card" shadow="hover" @click="goToReview">
          <div class="action-card__icon">🔄</div>
          <h3>单词复习</h3>
          <p>从已学单词中巩固练习</p>
        </el-card>

        <el-card class="action-card" shadow="hover" @click="goToMyWordBanks">
          <div class="action-card__icon">📚</div>
          <h3>我的词库</h3>
          <p>管理自定义词库</p>
        </el-card>

        <el-card class="action-card" shadow="hover" @click="goToPublicWordBanks">
          <div class="action-card__icon">🌐</div>
          <h3>词库广场</h3>
          <p>搜索并收藏公开词库</p>
        </el-card>

        <el-card class="action-card" shadow="hover" @click="router.push('/ai-reading')">
          <div class="action-card__icon">🤖</div>
          <h3>AI 阅读</h3>
          <p>智能生成阅读文章</p>
        </el-card>

        <el-card class="action-card" shadow="hover" @click="router.push('/error-book')">
          <div class="action-card__icon">❌</div>
          <h3>错题本</h3>
          <p>查看答错的单词</p>
        </el-card>

        <el-card class="action-card" shadow="hover" @click="router.push('/profile')">
          <div class="action-card__icon">👤</div>
          <h3>个人中心</h3>
          <p>管理个人信息</p>
        </el-card>

        <el-card class="action-card" shadow="hover" @click="router.push('/dashboard/detail')">
          <div class="action-card__icon">📊</div>
          <h3>详细数据</h3>
          <p>查看学习统计与趋势</p>
        </el-card>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ==================== 深色主题首页 ==================== */
.dashboard-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(20px, 3vw, 36px) clamp(16px, 3vw, 28px) 56px;
  background: linear-gradient(180deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
}

.guest-banner {
  max-width: 1120px;
  margin: 0 auto 20px;
  background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 100%);
  border: 1px solid rgba(255, 255, 255, 0.22);
  border-radius: 16px;
  padding: 24px 32px;
  color: white;
  box-shadow: 0 10px 28px rgba(14, 165, 233, 0.25);
}

.guest-banner-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

.guest-banner strong {
  font-size: 18px;
}

.guest-banner p {
  margin: 8px 0 0;
  opacity: 0.95;
  color: #e2e8f0;
  text-shadow:
    0 0 6px rgba(226, 232, 240, 0.25),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.guest-banner-actions {
  display: flex;
  gap: 12px;
  flex-shrink: 0;
}

.dashboard-alert {
  max-width: 1120px;
  margin: 0 auto 20px;
}

.dashboard-welcome {
  max-width: 1120px;
  margin: 0 auto 28px;
  text-align: center;
}

.dashboard-welcome h1 {
  margin: 0 0 8px;
  font-size: 34px;
  color: #38bdf8;
  font-weight: 700;
  letter-spacing: 1px;
}

.dashboard-welcome p {
  margin: 0;
  color: #cbd5e1;
  font-size: 16px;
  text-shadow:
    0 0 6px rgba(148, 163, 184, 0.25),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.language-switch {
  margin-top: 14px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: #cbd5e1;
  text-shadow:
    0 0 6px rgba(148, 163, 184, 0.25),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.language-switch__tip {
  color: #94a3b8;
  font-size: 14px;
  text-shadow:
    0 0 5px rgba(148, 163, 184, 0.2),
    0 1px 2px rgba(0, 0, 0, 0.2);
}

/* ==================== 统计卡片 - 深色风格 ==================== */
.stats-cards {
  max-width: 1120px;
  margin: 0 auto 36px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
}

.stats-skeleton {
  max-width: 1120px;
  margin: 0 auto 36px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
}

.stats-skeleton__item {
  height: 104px;
  border-radius: 16px;
  border: 1px solid rgba(56, 189, 248, 0.16);
  background: linear-gradient(180deg, rgba(20, 50, 85, 0.4) 0%, rgba(15, 40, 75, 0.5) 100%);
}

.stat-card {
  border-radius: 16px;
  border: 1px solid rgba(56, 189, 248, 0.18);
  background: rgba(20, 50, 85, 0.32) !important;
  backdrop-filter: blur(12px);
  transition: all 0.3s ease;
  cursor: default;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 14px 36px rgba(56, 189, 248, 0.2);
  border-color: rgba(56, 189, 248, 0.5);
}

.stat-card :deep(.el-card__body) {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 24px;
}

.stat-card__icon {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  flex-shrink: 0;
}

.stat-card--review .stat-card__icon {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.35);
}

.stat-card--streak .stat-card__icon {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  box-shadow: 0 4px 12px rgba(249, 115, 22, 0.35);
}

.stat-card--time .stat-card__icon {
  background: linear-gradient(135deg, #38bdf8 0%, #0ea5e9 100%);
  box-shadow: 0 4px 12px rgba(56, 189, 248, 0.35);
}

.stat-card--words .stat-card__icon {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.35);
}

.stat-card--banks .stat-card__icon {
  background: linear-gradient(135deg, #a855f7 0%, #9333ea 100%);
  box-shadow: 0 4px 12px rgba(168, 85, 247, 0.35);
}

.stat-card__content {
  flex: 1;
}

.stat-card__value {
  font-size: 28px;
  font-weight: 700;
  color: #f1f5f9;
  line-height: 1.2;
  margin-bottom: 4px;
  text-shadow:
    0 0 10px rgba(241, 245, 249, 0.3),
    0 0 25px rgba(56, 189, 248, 0.2),
    0 1px 3px rgba(0, 0, 0, 0.4);
}

.stat-card__value small {
  font-size: 14px;
  font-weight: 400;
  color: #cbd5e1;
  margin-left: 4px;
  text-shadow:
    0 0 6px rgba(203, 213, 225, 0.3),
    0 0 12px rgba(56, 189, 248, 0.12);
}

.stat-card__label {
  font-size: 14px;
  color: #cbd5e1;
  font-weight: 500;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

/* ==================== 快捷入口 - 深色风格 ==================== */
.quick-actions {
  max-width: 1120px;
  margin: 0 auto 32px;
}

.quick-actions h2 {
  margin: 0 0 20px;
  font-size: 24px;
  color: #f1f5f9;
  font-weight: 600;
}

.action-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
  gap: 16px;
}

.action-card {
  border-radius: 16px;
  border: 1px solid rgba(56, 189, 248, 0.18);
  background: rgba(20, 50, 85, 0.32) !important;
  backdrop-filter: blur(12px);
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
  padding: 20px 16px;
}

.action-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(56, 189, 248, 0.2);
  border-color: rgba(56, 189, 248, 0.5);
}

.action-card :deep(.el-card__body) {
  padding: 0;
}

.action-card__icon {
  font-size: 40px;
  margin-bottom: 12px;
}

.action-card h3 {
  margin: 0 0 6px;
  font-size: 16px;
  color: #ffffff;
  font-weight: 600;
  text-shadow:
    0 0 8px rgba(255, 255, 255, 0.35),
    0 0 18px rgba(56, 189, 248, 0.2),
    0 1px 2px rgba(0, 0, 0, 0.35);
}

.action-card p {
  margin: 0;
  font-size: 13px;
  color: #cbd5e1;
  line-height: 1.5;
  text-shadow:
    0 0 5px rgba(203, 213, 225, 0.12),
    0 1px 2px rgba(0, 0, 0, 0.3);
}



/* ==================== 响应式适配 ==================== */
@media (max-width: 768px) {
  .dashboard-page {
    padding-bottom: 40px;
  }

  .guest-banner {
    padding: 18px 16px;
  }

  .guest-banner-content {
    flex-direction: column;
    text-align: center;
  }

  .guest-banner-actions {
    justify-content: center;
  }

  .stats-cards {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .stats-skeleton {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .stat-card__value {
    font-size: 22px;
  }

  .stat-card__icon {
    width: 48px;
    height: 48px;
    font-size: 24px;
  }

  .action-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .dashboard-welcome h1 {
    font-size: 26px;
  }
}
</style>
