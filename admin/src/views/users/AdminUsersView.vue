<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import dayjs from 'dayjs'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAdminUsers, getAdminUserDetail, updateUserStatus, type AdminUser, type AdminUserDetail } from '../../api/users'

const loading = ref(false)
const items = ref<AdminUser[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 用户详情相关
const detailDialogVisible = ref(false)
const detailLoading = ref(false)
const currentUserDetail = ref<AdminUserDetail | null>(null)

const query = reactive({
  keyword: '',
  status: undefined as number | undefined,
  dateRange: [] as string[],
})

onMounted(async () => {
  await fetchList(1)
})

async function fetchList(page = currentPage.value) {
  loading.value = true
  try {
    const params: Record<string, unknown> = {
      current: page,
      size: pageSize.value,
    }

    if (query.status !== undefined) {
      params.status = query.status
    }

    if (query.dateRange && query.dateRange.length === 2) {
      params.startDate = query.dateRange[0]
      params.endDate = query.dateRange[1]
    }

    if (query.keyword.trim()) {
      params.keyword = query.keyword.trim()
    }

    const result = await getAdminUsers(params)
    currentPage.value = Number(result.current || page)
    pageSize.value = Number(result.size || pageSize.value)
    total.value = Number(result.total || 0)
    items.value = result.records ?? []
  } finally {
    loading.value = false
  }
}

function formatTime(value?: string) {
  if (!value) {
    return '-'
  }
  const parsed = dayjs(value)
  return parsed.isValid() ? parsed.format('YYYY-MM-DD HH:mm') : value
}

function getStatusLabel(status: number) {
  switch (status) {
    case 1:
      return '正常'
    case 2:
      return '已禁用'
    default:
      return '未知'
  }
}

function getStatusType(status: number): 'success' | 'danger' | 'info' {
  if (status === 1) return 'success'
  if (status === 2) return 'danger'
  return 'info'
}

function getRoleLabel(role: string) {
  switch (role) {
    case 'ADMIN':
      return '管理员'
    case 'USER':
      return '普通用户'
    default:
      return role
  }
}

function getRoleType(role: string): '' | 'warning' | 'info' {
  switch (role) {
    case 'ADMIN':
      return 'warning'
    case 'USER':
      return ''
    default:
      return 'info'
  }
}

async function handleSearch() {
  await fetchList(1)
}

async function handleReset() {
  query.keyword = ''
  query.status = undefined
  query.dateRange = []
  await fetchList(1)
}

async function handlePageChange(page: number) {
  await fetchList(page)
}

async function handleToggleStatus(user: AdminUser) {
  const currentStatus = user.status
  const newStatus = currentStatus === 1 ? 2 : 1
  const action = newStatus === 2 ? '禁用' : '启用'

  console.log('=== 禁用/启用操作开始 ===')
  console.log('用户:', user.username, '当前状态:', currentStatus, '目标状态:', newStatus)

  try {
    await ElMessageBox.confirm(
      `确定要${action}用户 "${user.nickname || user.username}" 吗？`,
      `${action}用户`,
      {
        confirmButtonText: `确认${action}`,
        cancelButtonText: '取消',
        type: 'warning',
      }
    )

    console.log('用户确认，准备调用API...')
    const result = await updateUserStatus(user.id, newStatus)
    console.log('API返回结果:', result)

    // 只有API成功后才更新本地状态
    user.status = newStatus
    console.log('本地状态已更新为:', user.status)
    ElMessage.success(`用户已${action}`)
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error(`${action}用户失败:`, error)
      ElMessage.error(`${action}用户失败`)
    } else {
      console.log('用户取消了操作')
    }
  }
}

// el-switch 的 before-change 钩子：返回 false 阻止自动切换
function handleSwitchBeforeChange(user: AdminUser) {
  console.log('before-change 触发，用户:', user.username)
  // 不在这里改变状态，而是触发确认对话框
  handleToggleStatus(user)
  return false  // 返回 false 阻止 el-switch 自动切换
}

async function handleViewDetail(user: AdminUser) {
  detailDialogVisible.value = true
  detailLoading.value = true
  currentUserDetail.value = null

  try {
    const result = await getAdminUserDetail(user.id)
    currentUserDetail.value = result
  } catch (error) {
    console.error('获取用户详情失败:', error)
    ElMessage.error('获取用户详情失败')
  } finally {
    detailLoading.value = false
  }
}

function handleCloseDetail() {
  detailDialogVisible.value = false
  currentUserDetail.value = null
}
</script>

<template>
  <div class="page-placeholder">
    <div class="placeholder-card users-card">
      <div class="page-header">
        <div>
          <h1>用户管理</h1>
          <p>查看平台所有注册用户，支持按状态、时间和关键词筛选。</p>
        </div>
      </div>

      <div class="filter-bar">
        <el-input
          v-model="query.keyword"
          placeholder="搜索用户名/昵称/邮箱/手机号"
          clearable
          @keyup.enter="handleSearch"
        />

        <el-select v-model="query.status" placeholder="全部状态" clearable>
          <el-option :value="1" label="正常" />
          <el-option :value="2" label="禁用" />
        </el-select>

        <el-date-picker
          v-model="query.dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="YYYY-MM-DD"
          :shortcuts="[
            {
              text: '最近一周',
              value: () => {
                const end = new Date()
                const start = new Date()
                start.setTime(start.getTime() - 3600 * 1000 * 24 * 7)
                return [start, end]
              },
            },
            {
              text: '最近一月',
              value: () => {
                const end = new Date()
                const start = new Date()
                start.setTime(start.getTime() - 3600 * 1000 * 24 * 30)
                return [start, end]
              },
            },
            {
              text: '最近三月',
              value: () => {
                const end = new Date()
                const start = new Date()
                start.setTime(start.getTime() - 3600 * 1000 * 24 * 90)
                return [start, end]
              },
            },
          ]"
        />

        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>

      <el-skeleton :rows="8" animated :loading="loading">
        <template #default>
          <el-empty v-if="total === 0" description="暂无用户数据" />

          <template v-else>
            <el-table :data="items" size="large" style="width: 100%">
              <el-table-column prop="id" label="ID" width="80" />

              <el-table-column label="用户信息" min-width="220">
                <template #default="{ row }">
                  <div class="user-info-cell">
                    <el-avatar
                      :size="40"
                      :src="row.avatarUrl"
                      style="flex-shrink: 0"
                    >
                      {{ (row.nickname || row.username || '?').charAt(0).toUpperCase() }}
                    </el-avatar>
                    <div class="user-text">
                      <div class="user-name">{{ row.nickname || row.username }}</div>
                      <div class="user-username">@{{ row.username }}</div>
                    </div>
                  </div>
                </template>
              </el-table-column>

              <el-table-column prop="email" label="邮箱" min-width="180">
                <template #default="{ row }">
                  {{ row.email || '-' }}
                </template>
              </el-table-column>

              <el-table-column prop="phone" label="手机号" min-width="130">
                <template #default="{ row }">
                  {{ row.phone || '-' }}
                </template>
              </el-table-column>

              <el-table-column label="角色" min-width="100">
                <template #default="{ row }">
                  <el-tag :type="getRoleType(row.role)">
                    {{ getRoleLabel(row.role) }}
                  </el-tag>
                </template>
              </el-table-column>

              <el-table-column label="状态" min-width="100">
                <template #default="{ row }">
                  <el-tag :type="getStatusType(row.status)">
                    {{ getStatusLabel(row.status) }}
                  </el-tag>
                </template>
              </el-table-column>

              <el-table-column label="注册时间" min-width="170">
                <template #default="{ row }">
                  {{ formatTime(row.createdAt) }}
                </template>
              </el-table-column>

              <el-table-column label="更新时间" min-width="170">
                <template #default="{ row }">
                  {{ formatTime(row.updatedAt) }}
                </template>
              </el-table-column>

              <el-table-column label="操作" width="200" fixed="right">
                <template #default="{ row }">
                  <el-button type="primary" link @click="handleViewDetail(row)">
                    查看详情
                  </el-button>
                  <el-switch
                    v-model="row.status"
                    :active-value="1"
                    :inactive-value="2"
                    active-text="正常"
                    inactive-text="禁用"
                    :disabled="row.role === 'ADMIN'"
                    style="margin-left: 12px;"
                    :before-change="() => handleSwitchBeforeChange(row)"
                  />
                </template>
              </el-table-column>
            </el-table>

            <div class="pagination-bar">
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
        </template>
      </el-skeleton>
    </div>

    <!-- 用户详情对话框 -->
    <el-dialog
      v-model="detailDialogVisible"
      :title="`用户详情 - ${currentUserDetail?.nickname || currentUserDetail?.username || ''}`"
      width="800px"
      @close="handleCloseDetail"
    >
      <el-skeleton :rows="12" animated :loading="detailLoading">
        <template #default>
          <div v-if="currentUserDetail" class="user-detail-content">
            <!-- 基本信息 -->
            <el-descriptions :column="2" border class="detail-section">
              <el-descriptions-item label="用户ID">{{ currentUserDetail.userId }}</el-descriptions-item>
              <el-descriptions-item label="用户名">{{ currentUserDetail.username }}</el-descriptions-item>
              <el-descriptions-item label="昵称">{{ currentUserDetail.nickname || '-' }}</el-descriptions-item>
              <el-descriptions-item label="邮箱">{{ currentUserDetail.email || '-' }}</el-descriptions-item>
              <el-descriptions-item label="手机号">{{ currentUserDetail.phone || '-' }}</el-descriptions-item>
              <el-descriptions-item label="角色">
                <el-tag :type="getRoleType(currentUserDetail.role)">
                  {{ getRoleLabel(currentUserDetail.role) }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="状态">
                <el-tag :type="getStatusType(currentUserDetail.status)">
                  {{ getStatusLabel(currentUserDetail.status) }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="登录失败次数">{{ currentUserDetail.loginFailCount ?? 0 }}</el-descriptions-item>
              <el-descriptions-item label="注册时间">{{ formatTime(currentUserDetail.createdAt) }}</el-descriptions-item>
              <el-descriptions-item label="最后更新">{{ formatTime(currentUserDetail.updatedAt) }}</el-descriptions-item>
              <el-descriptions-item label="最后登录">{{ formatTime(currentUserDetail.lastLoginAt) }}</el-descriptions-item>
            </el-descriptions>

            <!-- 学习配置 -->
            <h3 class="detail-subtitle">学习配置</h3>
            <el-descriptions :column="2" border class="detail-section">
              <el-descriptions-item label="单次学习题量">{{ currentUserDetail.studySessionSize ?? 20 }} 题</el-descriptions-item>
              <el-descriptions-item label="允许当天复习">
                <el-tag :type="currentUserDetail.allowSameDayReview ? 'success' : 'info'">
                  {{ currentUserDetail.allowSameDayReview ? '是' : '否' }}
                </el-tag>
              </el-descriptions-item>
            </el-descriptions>

            <!-- 学习统计 -->
            <h3 class="detail-subtitle">学习统计</h3>
            <el-row :gutter="20" class="stats-grid">
              <el-col :span="8">
                <el-statistic title="总学习次数" :value="currentUserDetail.totalStudySessions ?? 0" />
              </el-col>
              <el-col :span="8">
                <el-statistic title="学习单词数" :value="currentUserDetail.totalWordsLearned ?? 0" />
              </el-col>
              <el-col :span="8">
                <el-statistic title="正确率" :value="currentUserDetail.accuracyRate ?? 0" suffix="%" :precision="1" />
              </el-col>
            </el-row>

            <el-row :gutter="20" class="stats-grid" style="margin-top: 20px;">
              <el-col :span="8">
                <el-statistic title="总正确次数" :value="currentUserDetail.totalCorrectCount ?? 0" />
              </el-col>
              <el-col :span="8">
                <el-statistic title="总错误次数" :value="currentUserDetail.totalWrongCount ?? 0" />
              </el-col>
              <el-col :span="8">
                <el-statistic title="已掌握单词" :value="currentUserDetail.masteredWordCount ?? 0" />
              </el-col>
            </el-row>

            <el-row :gutter="20" class="stats-grid" style="margin-top: 20px;">
              <el-col :span="12">
                <el-alert
                  :title="`待复习单词：${currentUserDetail.pendingReviewCount ?? 0} 个`"
                  type="warning"
                  :closable="false"
                  show-icon
                />
              </el-col>
            </el-row>
          </div>
        </template>
      </el-skeleton>
    </el-dialog>
  </div>
</template>

<style scoped>
.users-card {
  max-width: 1400px;
  text-align: left;
}

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;
}

.filter-bar {
  display: grid;
  grid-template-columns: minmax(260px, 1fr) 140px auto auto auto;
  gap: 12px;
  margin-bottom: 20px;
}

.user-info-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow: hidden;
}

.user-name {
  font-weight: 500;
  color: var(--el-text-color-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-username {
  font-size: 12px;
  color: var(--el-text-color-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.pagination-bar {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

@media (max-width: 1100px) {
  .page-header {
    flex-direction: column;
    align-items: stretch;
  }

  .filter-bar {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 768px) {
  .filter-bar {
    grid-template-columns: 1fr;
  }
}

.user-detail-content {
  padding: 10px 0;
}

.detail-section {
  margin-bottom: 24px;
}

.detail-subtitle {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 24px 0 16px;
  padding-bottom: 8px;
  border-bottom: 2px solid var(--el-border-color-lighter);
}

.stats-grid {
  background: var(--el-fill-color-lighter);
  padding: 20px;
  border-radius: 12px;
}
</style>
