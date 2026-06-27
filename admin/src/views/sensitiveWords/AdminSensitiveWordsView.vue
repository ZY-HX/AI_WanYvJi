<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import dayjs from 'dayjs'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  createSensitiveWord,
  deleteSensitiveWord,
  getSensitiveWords,
  updateSensitiveWord,
  type SensitiveWord,
} from '../../api/sensitiveWords'

const loading = ref(false)
const submitting = ref(false)
const items = ref<SensitiveWord[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const editingId = ref<number | null>(null)
const formRef = ref<FormInstance>()

const query = reactive({
  keyword: '',
  status: undefined as number | undefined,
})

const form = reactive({
  word: '',
  status: 1,
})

const rules: FormRules<typeof form> = {
  word: [
    { required: true, message: '请输入敏感词', trigger: 'blur' },
    { max: 100, message: '敏感词长度不能超过 100 个字符', trigger: 'blur' },
  ],
}

onMounted(async () => {
  await fetchList(1)
})

async function fetchList(page = currentPage.value) {
  loading.value = true
  try {
    const result = await getSensitiveWords({
      current: page,
      size: pageSize.value,
      keyword: query.keyword.trim() || undefined,
      status: query.status,
    })
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
  return status === 1 ? '启用' : '禁用'
}

function resetForm() {
  form.word = ''
  form.status = 1
}

function openCreateDialog() {
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

function openEditDialog(item: SensitiveWord) {
  editingId.value = item.id
  form.word = item.word
  form.status = item.status
  dialogVisible.value = true
}

async function submitForm() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) {
    return
  }

  submitting.value = true
  try {
    const payload = {
      word: form.word.trim(),
      status: form.status,
    }
    if (editingId.value) {
      await updateSensitiveWord(editingId.value, payload)
      ElMessage.success('敏感词更新成功')
    } else {
      await createSensitiveWord(payload)
      ElMessage.success('敏感词新增成功')
    }
    dialogVisible.value = false
    await fetchList(editingId.value ? currentPage.value : 1)
  } finally {
    submitting.value = false
  }
}

async function handleToggleStatus(item: SensitiveWord, enabled: boolean | string | number) {
  const nextStatus = enabled ? 1 : 0
  await updateSensitiveWord(item.id, { status: nextStatus })
  ElMessage.success(`已${nextStatus === 1 ? '启用' : '禁用'}敏感词`)
  await fetchList(currentPage.value)
}

async function handleDelete(item: SensitiveWord) {
  const confirmed = await ElMessageBox.confirm(`确认删除敏感词“${item.word}”吗？`, '删除确认', {
    type: 'warning',
    confirmButtonText: '删除',
    cancelButtonText: '取消',
  }).catch(() => false)

  if (!confirmed) {
    return
  }

  await deleteSensitiveWord(item.id)
  ElMessage.success('敏感词删除成功')
  const nextPage = items.value.length === 1 && currentPage.value > 1 ? currentPage.value - 1 : currentPage.value
  await fetchList(nextPage)
}

async function handleSearch() {
  await fetchList(1)
}

async function handleReset() {
  query.keyword = ''
  query.status = undefined
  await fetchList(1)
}

async function handlePageChange(page: number) {
  await fetchList(page)
}
</script>

<template>
  <div class="page-placeholder">
    <div class="placeholder-card sensitive-card">
      <div class="page-header">
        <div>
          <h1>敏感词管理</h1>
          <p>管理员可维护敏感词列表，并用于词库名称与 AI 主题过滤。</p>
        </div>

        <el-button type="primary" @click="openCreateDialog">新增敏感词</el-button>
      </div>

      <div class="filter-bar">
        <el-input
          v-model="query.keyword"
          placeholder="按敏感词内容搜索"
          clearable
          @keyup.enter="handleSearch"
        />

        <el-select v-model="query.status" placeholder="全部状态" clearable>
          <el-option :value="1" label="启用" />
          <el-option :value="0" label="禁用" />
        </el-select>

        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>

      <el-skeleton :rows="6" animated :loading="loading">
        <template #default>
          <el-empty v-if="total === 0" description="暂无敏感词数据" />

          <template v-else>
            <el-table :data="items" size="large" style="width: 100%">
              <el-table-column prop="word" label="敏感词" min-width="220" />
              <el-table-column label="状态" min-width="140">
                <template #default="{ row }">
                  <div class="status-cell">
                    <el-tag :type="row.status === 1 ? 'success' : 'info'">
                      {{ getStatusLabel(row.status) }}
                    </el-tag>
                    <el-switch
                      :model-value="row.status === 1"
                      inline-prompt
                      active-text="启用"
                      inactive-text="禁用"
                      @change="handleToggleStatus(row, $event)"
                    />
                  </div>
                </template>
              </el-table-column>
              <el-table-column label="创建时间" min-width="180">
                <template #default="{ row }">
                  {{ formatTime(row.createdAt) }}
                </template>
              </el-table-column>
              <el-table-column label="更新时间" min-width="180">
                <template #default="{ row }">
                  {{ formatTime(row.updatedAt) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" min-width="180" fixed="right">
                <template #default="{ row }">
                  <div class="table-actions">
                    <el-button type="primary" link @click="openEditDialog(row)">编辑</el-button>
                    <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
                  </div>
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

    <el-dialog
      v-model="dialogVisible"
      :title="editingId ? '编辑敏感词' : '新增敏感词'"
      width="480px"
      destroy-on-close
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="敏感词" prop="word">
          <el-input v-model="form.word" maxlength="100" show-word-limit placeholder="请输入敏感词" />
        </el-form-item>

        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitForm">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.sensitive-card {
  max-width: 1240px;
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
  grid-template-columns: minmax(240px, 1fr) 160px auto auto;
  gap: 12px;
  margin-bottom: 20px;
}

.status-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.table-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.pagination-bar {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

@media (max-width: 900px) {
  .page-header {
    flex-direction: column;
    align-items: stretch;
  }

  .filter-bar {
    grid-template-columns: 1fr;
  }
}
</style>
