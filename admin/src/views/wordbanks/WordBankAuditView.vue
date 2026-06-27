<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import dayjs from 'dayjs'
import { ElMessage, ElMessageBox } from 'element-plus'
import { auditWordBank, getPendingWordBanks, type WordBank, type WordBankAuditPayload } from '../../api/adminWordbanks'

const loading = ref(false)
const items = ref<WordBank[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const auditingId = ref<number | null>(null)

const query = reactive({
  current: 1,
  size: 10,
})

onMounted(async () => {
  await fetchList(1)
})

async function fetchList(page = currentPage.value) {
  loading.value = true
  try {
    query.current = page
    query.size = pageSize.value
    const result = await getPendingWordBanks(query)
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

async function handleApprove(item: WordBank) {
  if (auditingId.value) {
    return
  }
  auditingId.value = item.id
  try {
    const payload: WordBankAuditPayload = { approved: true }
    await auditWordBank(item.id, payload)
    ElMessage.success('审核已通过')
    await fetchList(currentPage.value)
  } finally {
    auditingId.value = null
  }
}

async function handleReject(item: WordBank) {
  if (auditingId.value) {
    return
  }

  const { value, action } = await ElMessageBox.prompt('请输入拒绝理由（必填）', '拒绝审核', {
    confirmButtonText: '确认拒绝',
    cancelButtonText: '取消',
    inputPlaceholder: '例如：词库内容不完整或不符合共享规范',
    inputType: 'textarea',
    inputValidator: (val: string) => {
      if (!val || !val.trim()) {
        return '拒绝理由不能为空'
      }
      if (val.trim().length > 500) {
        return '拒绝理由不能超过500个字符'
      }
      return true
    },
  }).catch(() => ({ value: '', action: 'cancel' as const }))

  if (action !== 'confirm') {
    return
  }

  auditingId.value = item.id
  try {
    const payload: WordBankAuditPayload = { approved: false, reason: value.trim() }
    await auditWordBank(item.id, payload)
    ElMessage.success('审核已拒绝')
    await fetchList(currentPage.value)
  } finally {
    auditingId.value = null
  }
}

async function handlePageChange(page: number) {
  await fetchList(page)
}
</script>

<template>
  <div class="page-placeholder">
    <div class="placeholder-card audit-card">
      <div class="audit-header">
        <div>
          <h1>共享词库审核</h1>
          <p>查看待审核的公开申请，并执行通过或拒绝操作。</p>
        </div>
      </div>

      <el-skeleton :rows="6" animated :loading="loading">
        <template #default>
          <el-empty v-if="total === 0" description="暂无待审核词库" />

          <el-table v-else :data="items" size="large" style="width: 100%">
            <el-table-column prop="name" label="词库名称" min-width="180" />
            <el-table-column prop="creatorName" label="创建者" min-width="120" />
            <el-table-column prop="category" label="分类" min-width="100" />
            <el-table-column prop="wordCount" label="单词数" min-width="90" />
            <el-table-column label="申请时间" min-width="160">
              <template #default="{ row }">
                {{ formatTime(row.updatedAt || row.createdAt) }}
              </template>
            </el-table-column>
            <el-table-column prop="description" label="描述" min-width="220" show-overflow-tooltip />
            <el-table-column label="操作" min-width="190" fixed="right">
              <template #default="{ row }">
                <div class="audit-actions">
                  <el-button
                    type="success"
                    size="small"
                    :loading="auditingId === row.id"
                    @click="handleApprove(row)"
                  >
                    通过
                  </el-button>
                  <el-button
                    type="danger"
                    size="small"
                    :loading="auditingId === row.id"
                    @click="handleReject(row)"
                  >
                    拒绝
                  </el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>

          <div v-if="total > 0" class="audit-pagination">
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
.audit-card {
  max-width: 1240px;
  text-align: left;
}

.audit-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 18px;
}

.audit-actions {
  display: flex;
  gap: 8px;
}

.audit-pagination {
  display: flex;
  justify-content: center;
  margin-top: 18px;
}
</style>
