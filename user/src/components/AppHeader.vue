<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getRecentNotifications,
  markAllNotificationsRead,
  markNotificationRead,
  type NotificationItem,
} from '../api/notifications'
import { logout as logoutRequest } from '../api/auth'
import { useUserStore } from '../stores/user'
import { useNotificationStore } from '../stores/notification'
import { currentTheme, toggleTheme } from '../shared/theme'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const notificationStore = useNotificationStore()

const isGuest = computed(() => userStore.userInfo?.role === 'GUEST')
const canShowNotifications = computed(() => userStore.isLoggedIn && !isGuest.value)
const showBadge = computed(() => canShowNotifications.value && notificationStore.unreadCount > 0)
const notificationMenuRef = ref<HTMLElement | null>(null)
const notificationMenuOpen = ref(false)
const recentNotifications = ref<NotificationItem[]>([])
const recentLoading = ref(false)
const markAllLoading = ref(false)
const displayName = computed(() => userStore.userInfo?.nickname || userStore.userInfo?.username || '用户')
const avatarInitial = computed(() => displayName.value.slice(0, 1).toUpperCase())
const isLightTheme = computed(() => currentTheme.value === 'light')
const themeSwitchLabel = computed(() => (isLightTheme.value ? '深色' : '浅色'))

function go(path: string) {
  notificationMenuOpen.value = false
  if (route.path === path) {
    return
  }
  void router.push(path)
}

async function logout() {
  const confirmed = await ElMessageBox.confirm('确认退出登录？', '提示', {
    type: 'warning',
    confirmButtonText: '退出',
    cancelButtonText: '取消',
  }).catch(() => false)

  if (!confirmed) {
    return
  }

  try {
    await logoutRequest()
  } catch {
    // 即使后端登出失败，也应清理本地会话状态。
  } finally {
    notificationStore.stopPolling()
    notificationStore.reset()
    userStore.clear()
    ElMessage.success('已退出登录')
    await router.push('/login')
  }
}

async function handleUserCommand(command: string | number | object) {
  if (command === 'profile') {
    go('/profile')
    return
  }

  if (command === 'logout') {
    await logout()
  }
}

function formatTime(value: string) {
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) {
    return value
  }

  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hour = String(date.getHours()).padStart(2, '0')
  const minute = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day} ${hour}:${minute}`
}

async function fetchRecentNotifications() {
  if (!canShowNotifications.value) {
    recentNotifications.value = []
    return
  }

  recentLoading.value = true
  try {
    const result = await getRecentNotifications(5)
    recentNotifications.value = result?.records ?? []
  } finally {
    recentLoading.value = false
  }
}

async function toggleNotificationMenu() {
  if (!canShowNotifications.value) {
    return
  }

  notificationMenuOpen.value = !notificationMenuOpen.value
  if (notificationMenuOpen.value) {
    await fetchRecentNotifications()
  }
}

async function handleNotificationClick(item: NotificationItem) {
  if (item.isRead === 0) {
    try {
      await markNotificationRead(item.id)
      item.isRead = 1
      await notificationStore.refreshUnreadCount()
    } catch {
      return
    }
  }

  notificationMenuOpen.value = false
  await router.push('/notifications')
}

async function handleReadAllNotifications() {
  if (markAllLoading.value || !recentNotifications.value.length) {
    return
  }

  markAllLoading.value = true
  try {
    await markAllNotificationsRead()
    recentNotifications.value = recentNotifications.value.map((item) => ({ ...item, isRead: 1 }))
    await notificationStore.refreshUnreadCount()
    ElMessage.success('最近消息已全部标记为已读')
  } finally {
    markAllLoading.value = false
  }
}

function handleDocumentClick(event: MouseEvent) {
  const target = event.target
  if (!(target instanceof Node)) {
    return
  }
  if (!notificationMenuRef.value?.contains(target)) {
    notificationMenuOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleDocumentClick)
  if (notificationStore.shouldEnableNotifications) {
    notificationStore.startPolling()
  }
})

watch(
  () => userStore.token,
  (value) => {
    if (!value) {
      notificationMenuOpen.value = false
      recentNotifications.value = []
      notificationStore.stopPolling()
      notificationStore.reset()
      return
    }

    if (notificationStore.shouldEnableNotifications) {
      notificationStore.startPolling()
    } else {
      notificationStore.stopPolling()
      notificationStore.reset()
    }
  },
)

onBeforeUnmount(() => {
  document.removeEventListener('click', handleDocumentClick)
  notificationStore.stopPolling()
})
</script>

<template>
  <header class="app-header">
    <div class="app-header-inner">
      <div class="app-header-left">
        <button class="app-brand" type="button" @click="go('/')">万语集</button>
        <nav class="app-nav">
          <el-button text @click="go('/study')">学习</el-button>
          <el-button text @click="go('/wordbanks')">词库</el-button>
          <el-button text @click="go('/ai-reading')">AI阅读</el-button>
          <el-button text @click="go('/simultaneous-translation')">同声翻译</el-button>
          <div v-if="canShowNotifications" ref="notificationMenuRef" class="notification-entry">
            <el-badge :value="notificationStore.unreadCount" :hidden="!showBadge" :max="99">
              <button
                class="notification-bell-button"
                type="button"
                aria-label="查看最近消息"
                @click.stop="toggleNotificationMenu"
              >
                <svg viewBox="0 0 24 24" class="notification-bell-icon" aria-hidden="true">
                  <path
                    d="M12 3a4 4 0 0 0-4 4v1.1c0 .7-.2 1.3-.5 1.9L6 13.5V15h12v-1.5l-1.5-3.5A4.8 4.8 0 0 1 16 8.1V7a4 4 0 0 0-4-4zm0 18a2.5 2.5 0 0 0 2.4-2H9.6A2.5 2.5 0 0 0 12 21z"
                    fill="currentColor"
                  />
                </svg>
              </button>
            </el-badge>

            <div v-if="notificationMenuOpen" class="notification-dropdown" @click.stop>
              <div class="notification-dropdown-header">
                <span>最近消息</span>
                <div class="notification-dropdown-actions">
                  <button class="notification-text-button" type="button" @click="go('/notifications')">
                    查看全部
                  </button>
                  <button
                    class="notification-text-button"
                    type="button"
                    :disabled="markAllLoading || !recentNotifications.length"
                    @click="handleReadAllNotifications"
                  >
                    全部已读
                  </button>
                </div>
              </div>

              <div v-if="recentLoading" class="notification-dropdown-state">加载中...</div>
              <div v-else-if="!recentNotifications.length" class="notification-dropdown-state">暂无消息</div>
              <button
                v-for="item in recentNotifications"
                :key="item.id"
                class="notification-dropdown-item"
                type="button"
                @click="handleNotificationClick(item)"
              >
                <div class="notification-dropdown-item-head">
                  <span class="notification-dropdown-title">{{ item.title }}</span>
                  <span v-if="item.isRead === 0" class="notification-unread-dot">未读</span>
                </div>
                <div class="notification-dropdown-content">{{ item.content }}</div>
                <div class="notification-dropdown-time">{{ formatTime(item.createdAt) }}</div>
              </button>
            </div>
          </div>
        </nav>
      </div>

      <div class="app-header-right">
        <button
          class="theme-switch-button"
          type="button"
          :aria-label="`切换到${themeSwitchLabel}主题`"
          @click="toggleTheme"
        >
          {{ themeSwitchLabel }}
        </button>
        <el-dropdown trigger="click" @command="handleUserCommand">
          <button class="user-menu-trigger" type="button">
            <el-avatar v-if="userStore.resolvedAvatarUrl" :src="userStore.resolvedAvatarUrl" :size="32" />
            <span v-else class="user-avatar-fallback">{{ avatarInitial }}</span>
            <span class="user-menu-name">{{ displayName }}</span>
          </button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">个人中心</el-dropdown-item>
              <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
  </header>
</template>

<style scoped>
/* ==================== 深色主题导航栏 ==================== */
.app-header {
  height: var(--app-header-height, 56px);
  display: flex;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 20;
  background: var(--header-bg, rgba(15, 23, 42, 0.95));
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--header-border, rgba(51, 65, 85, 0.6));
}

.app-header-inner {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
}

.app-header-left {
  display: flex;
  align-items: center;
  gap: 14px;
  min-width: 0;
}

.app-brand {
  border: none;
  background: transparent;
  font-size: 16px;
  font-weight: 700;
  color: var(--header-brand, #38bdf8);
  cursor: pointer;
  padding: 0;
  white-space: nowrap;
  letter-spacing: 1px;
}

.app-nav {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.app-nav :deep(.el-button) {
  color: var(--header-nav, #94a3b8) !important;
  font-weight: 500;
}

.app-nav :deep(.el-button:hover) {
  color: var(--header-brand, #38bdf8) !important;
}

.notification-entry {
  position: relative;
}

.notification-bell-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 999px;
  background: transparent;
  color: var(--header-nav, #94a3b8);
  cursor: pointer;
  transition: all 0.2s ease;
}

.notification-bell-button:hover {
  background: var(--header-hover-bg, rgba(56, 189, 248, 0.12));
  color: var(--header-brand, #38bdf8);
}

.notification-bell-icon {
  width: 20px;
  height: 20px;
}

.notification-dropdown {
  position: absolute;
  top: calc(100% + 10px);
  right: 0;
  width: 320px;
  max-height: 420px;
  overflow-y: auto;
  background: #1e293b;
  border: 1px solid rgba(51, 65, 85, 0.6);
  border-radius: 14px;
  box-shadow: 0 14px 36px rgba(0, 0, 0, 0.4);
  padding: 8px;
}

.notification-dropdown-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 8px 10px 12px;
  font-size: 14px;
  font-weight: 600;
  color: #e2e8f0;
}

.notification-dropdown-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.notification-text-button {
  border: none;
  background: transparent;
  padding: 0;
  font-size: 13px;
  color: #38bdf8;
  cursor: pointer;
}

.notification-text-button:disabled {
  color: #475569;
  cursor: not-allowed;
}

.notification-dropdown-state {
  padding: 28px 0;
  text-align: center;
  color: #64748b;
  font-size: 14px;
}

.notification-dropdown-item {
  width: 100%;
  border: none;
  background: transparent;
  padding: 12px 10px;
  border-radius: 10px;
  text-align: left;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.notification-dropdown-item:hover {
  background: rgba(56, 189, 248, 0.08);
}

.notification-dropdown-item + .notification-dropdown-item {
  margin-top: 4px;
}

.notification-dropdown-item-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.notification-dropdown-title {
  font-size: 14px;
  font-weight: 600;
  color: #e2e8f0;
}

.notification-unread-dot {
  font-size: 12px;
  color: #fbbf24;
  white-space: nowrap;
}

.notification-dropdown-content {
  margin-top: 6px;
  font-size: 13px;
  line-height: 1.5;
  color: #94a3b8;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.notification-dropdown-time {
  margin-top: 8px;
  font-size: 12px;
  color: #475569;
}

.app-header-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.theme-switch-button {
  min-width: 56px;
  height: 32px;
  padding: 0 10px;
  border: 1px solid var(--header-switch-border, rgba(148, 163, 184, 0.35));
  border-radius: 999px;
  background: var(--header-switch-bg, rgba(15, 23, 42, 0.35));
  color: var(--header-switch-text, #cbd5e1);
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.theme-switch-button:hover {
  border-color: var(--header-brand, #38bdf8);
  color: var(--header-brand, #38bdf8);
}

.user-menu-trigger {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  border: none;
  background: transparent;
  padding: 6px 8px;
  border-radius: 999px;
  cursor: pointer;
  color: var(--header-user, #e2e8f0);
  transition: all 0.2s ease;
}

.user-menu-trigger:hover {
  background: var(--header-user-hover, rgba(255, 255, 255, 0.08));
}

.user-avatar-fallback {
  width: 32px;
  height: 32px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  background: linear-gradient(135deg, #38bdf8 0%, #0ea5e9 100%);
  color: #ffffff;
  font-size: 13px;
  font-weight: 600;
}

.user-menu-name {
  font-size: 14px;
  font-weight: 500;
  white-space: nowrap;
  color: var(--header-user-name, #cbd5e1);
}

@media (max-width: 900px) {
  .app-header-inner {
    padding: 0 14px;
    gap: 10px;
  }

  .app-brand {
    font-size: 15px;
    letter-spacing: 0.5px;
  }

  .app-nav {
    gap: 4px;
  }

  .user-menu-trigger {
    padding: 4px 6px;
  }

  .theme-switch-button {
    min-width: 50px;
    height: 30px;
    padding: 0 8px;
  }
}

@media (max-width: 640px) {
  .app-header {
    height: 52px;
  }

  .app-header-inner {
    padding: 0 10px;
  }

  .user-menu-name {
    display: none;
  }

  .notification-dropdown {
    right: -42px;
    width: min(320px, calc(100vw - 20px));
  }
}
</style>
