<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import dayjs from 'dayjs'
import { ElMessage } from 'element-plus'
import {
  getNotifications,
  markAllNotificationsRead,
  markNotificationRead,
  type NotificationItem,
} from '../api/notifications'
import { useNotificationStore } from '../stores/notification'

type FilterMode = 'all' | 'unread' | 'read'

const notificationStore = useNotificationStore()

const loading = ref(false)
const items = ref<NotificationItem[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const filterMode = ref<FilterMode>('all')
const activeNames = ref<string[]>([])
const lastActiveNames = ref<string[]>([])
const readAllLoading = ref(false)

const isEmpty = computed(() => !loading.value && total.value === 0)
const isReadFilterParam = computed(() => {
  if (filterMode.value === 'unread') {
    return 0
  }
  if (filterMode.value === 'read') {
    return 1
  }
  return undefined
})

onMounted(async () => {
  await fetchNotifications(1)
  void notificationStore.refreshUnreadCount()
})

watch(filterMode, async () => {
  activeNames.value = []
  lastActiveNames.value = []
  await fetchNotifications(1)
})

async function fetchNotifications(page = currentPage.value) {
  loading.value = true
  try {
    const result = await getNotifications({
      current: page,
      size: pageSize.value,
      is_read: isReadFilterParam.value,
    })

    currentPage.value = Number(result?.current || page)
    pageSize.value = Number(result?.size || pageSize.value)
    total.value = Number(result?.total || 0)
    items.value = result?.records ?? []
  } finally {
    loading.value = false
  }
}

async function handlePageChange(page: number) {
  activeNames.value = []
  lastActiveNames.value = []
  await fetchNotifications(page)
}

async function handleCollapseChange(next: string[] | string) {
  const nextNames = Array.isArray(next) ? next : [next]
  const prev = new Set(lastActiveNames.value)
  const newlyOpened = nextNames.filter((name) => !prev.has(name))
  lastActiveNames.value = nextNames

  if (!newlyOpened.length) {
    return
  }

  for (const opened of newlyOpened) {
    const id = Number(opened)
    const target = items.value.find((item) => item.id === id)
    if (!target || target.isRead === 1) {
      continue
    }

    try {
      await markNotificationRead(id)
      if (filterMode.value === 'unread') {
        items.value = items.value.filter((item) => item.id !== id)
        total.value = Math.max(total.value - 1, 0)
        activeNames.value = activeNames.value.filter((name) => name !== opened)
        lastActiveNames.value = lastActiveNames.value.filter((name) => name !== opened)
      } else {
        target.isRead = 1
      }
      void notificationStore.refreshUnreadCount()
    } catch {
      // Error message handled by axios interceptor.
    }
  }
}

async function handleReadAll() {
  if (readAllLoading.value || total.value <= 0) {
    return
  }

  readAllLoading.value = true
  try {
    await markAllNotificationsRead()
    if (filterMode.value === 'unread') {
      items.value = []
      total.value = 0
      activeNames.value = []
      lastActiveNames.value = []
    } else {
      items.value = items.value.map((item) => ({ ...item, isRead: 1 }))
    }
    ElMessage.success('已全部标记为已读')
    void notificationStore.refreshUnreadCount()
  } finally {
    readAllLoading.value = false
  }
}

function formatTime(value: string) {
  const parsed = dayjs(value)
  if (!parsed.isValid()) {
    return value
  }
  return parsed.format('YYYY-MM-DD HH:mm')
}
</script>

<template>
  <div class="page-placeholder">
    <div class="placeholder-card notification-card">
      <div class="notification-header">
        <div>
          <h1>消息中心</h1>
          <p>点击标题可展开详情，展开后会自动标记为已读。</p>
        </div>

        <div class="notification-actions">
          <el-radio-group v-model="filterMode" size="small">
            <el-radio-button value="all">全部</el-radio-button>
            <el-radio-button value="unread">未读</el-radio-button>
            <el-radio-button value="read">已读</el-radio-button>
          </el-radio-group>
          <el-button :loading="readAllLoading" @click="handleReadAll">全部已读</el-button>
        </div>
      </div>

      <el-skeleton :rows="6" animated :loading="loading">
        <template #default>
          <el-empty v-if="isEmpty" description="暂无消息" />

          <el-collapse v-else v-model="activeNames" @change="handleCollapseChange">
            <el-collapse-item v-for="item in items" :key="item.id" :name="String(item.id)">
              <template #title>
                <div class="notification-title">
                  <span class="notification-title-text">{{ item.title }}</span>
                  <div class="notification-meta">
                    <el-tag v-if="item.isRead === 0" size="small" type="warning">未读</el-tag>
                    <el-tag v-else size="small" type="success">已读</el-tag>
                    <span class="notification-time">{{ formatTime(item.createdAt) }}</span>
                  </div>
                </div>
              </template>

              <div class="notification-content">
                <div class="notification-type">类型：{{ item.type }}</div>
                <div class="notification-body">{{ item.content }}</div>
              </div>
            </el-collapse-item>
          </el-collapse>

          <div v-if="total > 0" class="notification-pagination">
            <el-pagination
              background
              layout="prev, pager, next"
              :current-page="currentPage"
              :page-size="pageSize"
              :total="total"
              @current-change="handlePageChange"
            />
          </div>
        </template>
      </el-skeleton>
    </div>
  </div>
</template>

<style scoped>
.notification-card {
  max-width: 860px;
  text-align: left;
}

.notification-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 18px;
}

.notification-actions {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.notification-title {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.notification-title-text {
  font-weight: 600;
  color: #111827;
}

.notification-meta {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #6b7280;
  font-size: 12px;
}

.notification-time {
  white-space: nowrap;
}

.notification-content {
  padding: 4px 0 10px;
  color: #374151;
}

.notification-type {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 10px;
}

.notification-body {
  white-space: pre-wrap;
  line-height: 1.7;
}

.notification-pagination {
  display: flex;
  justify-content: center;
  margin-top: 18px;
}

@media (max-width: 768px) {
  .notification-header {
    flex-direction: column;
    align-items: stretch;
  }

  .notification-actions {
    justify-content: space-between;
  }

  .notification-title {
    align-items: flex-start;
    flex-direction: column;
  }
}
</style>
