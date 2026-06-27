<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import dayjs from 'dayjs'
import {
  clearErrorBook,
  getErrorBookList,
  markErrorBookMastered,
  type ErrorBookClearParams,
  type ErrorBookItem,
} from '../api/errorBook'
import { getStudyWordBanks, type StudyWordBankOption } from '../api/study'

const router = useRouter()
type ClearScope = 'currentWordBank' | 'currentFilters'

const loading = ref(false)
const optionsLoading = ref(false)
const submittingId = ref<number | null>(null)
const clearDialogVisible = ref(false)
const clearing = ref(false)
const errorBooks = ref<ErrorBookItem[]>([])
const wordBankOptions = ref<StudyWordBankOption[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const selectedWordBankId = ref<number>()
const selectedErrorType = ref('')
const selectedMastered = ref<number | undefined>(0)
const clearScope = ref<ClearScope>('currentFilters')

const errorTypeOptions = [
  { label: '全部类型', value: '' },
  { label: '看词选错', value: 'EN_TO_CN' },
  { label: '听音选错', value: 'LISTEN' },
  { label: '看义选错', value: 'CN_TO_EN' },
  { label: '拼写错误', value: 'SPELL' },
]

const masteredOptions = [
  { label: '未掌握', value: 0 },
  { label: '已掌握', value: 1 },
]

const masteredCount = computed(() => errorBooks.value.filter((item) => item.isMastered === 1).length)
const unmasteredCount = computed(() => errorBooks.value.filter((item) => item.isMastered !== 1).length)
const selectedWordBankName = computed(() => {
  return wordBankOptions.value.find((item) => item.id === selectedWordBankId.value)?.name ?? ''
})
const hasSelectedWordBank = computed(() => selectedWordBankId.value !== undefined)
const canOpenClearDialog = computed(() => hasSelectedWordBank.value || total.value > 0)
const currentFilterSummary = computed(() => {
  const masteredText =
    selectedMastered.value === 1 ? '已掌握' : selectedMastered.value === 0 ? '未掌握' : '全部状态'

  return [
    `词库：${selectedWordBankName.value || '全部词库'}`,
    `类型：${selectedErrorType.value ? getErrorTypeText(selectedErrorType.value) : '全部类型'}`,
    `状态：${masteredText}`,
  ].join(' / ')
})

onMounted(async () => {
  try {
    await Promise.all([fetchWordBankOptions(), fetchErrorBooks(1)])
  } catch {
    errorBooks.value = []
    total.value = 0
  }
})

async function fetchWordBankOptions() {
  optionsLoading.value = true
  try {
    const result = await getStudyWordBanks()
    wordBankOptions.value = result ?? []
  } finally {
    optionsLoading.value = false
  }
}

async function fetchErrorBooks(page = currentPage.value) {
  loading.value = true
  try {
    const result = await getErrorBookList({
      current: page,
      size: pageSize.value,
      wordBankId: selectedWordBankId.value,
      errorType: selectedErrorType.value || undefined,
      is_mastered: selectedMastered.value,
    })

    const nextTotal = Number(result.total || 0)
    const maxPage = Math.max(Math.ceil(nextTotal / pageSize.value), 1)
    if (nextTotal > 0 && page > maxPage) {
      await fetchErrorBooks(maxPage)
      return
    }

    currentPage.value = Number(result.current || page)
    pageSize.value = Number(result.size || pageSize.value)
    total.value = nextTotal
    errorBooks.value = result.records ?? []
  } finally {
    loading.value = false
  }
}

async function handleSearch() {
  currentPage.value = 1
  try {
    await fetchErrorBooks(1)
  } catch {
    errorBooks.value = []
    total.value = 0
  }
}

async function handleReset() {
  selectedWordBankId.value = undefined
  selectedErrorType.value = ''
  selectedMastered.value = 0
  currentPage.value = 1
  try {
    await fetchErrorBooks(1)
  } catch {
    errorBooks.value = []
    total.value = 0
  }
}

async function handlePageChange(page: number) {
  try {
    await fetchErrorBooks(page)
  } catch {
    errorBooks.value = []
    total.value = 0
  }
}

function openClearDialog() {
  if (!canOpenClearDialog.value) {
    ElMessage.warning('当前没有可清空的错题记录')
    return
  }

  clearScope.value = hasSelectedWordBank.value ? 'currentWordBank' : 'currentFilters'
  clearDialogVisible.value = true
}

function buildClearParams(scope: ClearScope): ErrorBookClearParams {
  if (scope === 'currentWordBank') {
    return {
      wordBankId: selectedWordBankId.value,
    }
  }

  return {
    wordBankId: selectedWordBankId.value,
    errorType: selectedErrorType.value || undefined,
    isMastered: selectedMastered.value,
  }
}

function getClearScopeTitle(scope: ClearScope) {
  if (scope === 'currentWordBank') {
    return selectedWordBankName.value ? `当前词库“${selectedWordBankName.value}”` : '当前词库'
  }
  return '当前筛选结果'
}

function getClearScopeDescription(scope: ClearScope) {
  if (scope === 'currentWordBank') {
    return selectedWordBankName.value
      ? `清空词库“${selectedWordBankName.value}”下的全部错题，不区分错误类型和掌握状态。`
      : '请先选择一个词库后再使用此范围。'
  }
  return `按当前筛选条件清空错题：${currentFilterSummary.value}`
}

async function handleClear() {
  if (clearScope.value === 'currentWordBank' && !hasSelectedWordBank.value) {
    ElMessage.warning('请先选择词库后再清空当前词库')
    return
  }

  const scopeTitle = getClearScopeTitle(clearScope.value)
  await ElMessageBox.confirm(`确认清空${scopeTitle}中的错题记录吗？此操作不可撤销。`, '二次确认', {
    type: 'warning',
    confirmButtonText: '确认清空',
    cancelButtonText: '取消',
  })

  clearing.value = true
  try {
    const result = await clearErrorBook(buildClearParams(clearScope.value))
    const deletedCount = Number(result ?? 0)
    ElMessage.success(
      deletedCount > 0 ? `已清空 ${deletedCount} 条错题记录` : '没有符合条件的错题记录可清空',
    )
    clearDialogVisible.value = false
    await fetchErrorBooks(currentPage.value)
  } finally {
    clearing.value = false
  }
}

async function handleMarkMastered(item: ErrorBookItem) {
  if (item.isMastered === 1 || submittingId.value) {
    return
  }

  submittingId.value = item.id
  try {
    await markErrorBookMastered(item.id)
    ElMessage.success(`已将“${item.english}”标记为掌握`)

    if (selectedMastered.value === 0) {
      const nextPage =
        errorBooks.value.length === 1 && currentPage.value > 1 ? currentPage.value - 1 : currentPage.value
      try {
        await fetchErrorBooks(nextPage)
      } catch {
        errorBooks.value = []
        total.value = 0
      }
      return
    }

    try {
      await fetchErrorBooks(currentPage.value)
    } catch {
      errorBooks.value = []
      total.value = 0
    }
  } finally {
    submittingId.value = null
  }
}

function getErrorTypeText(value: string) {
  switch (value) {
    case 'EN_TO_CN':
      return '看词选错'
    case 'LISTEN':
      return '听音选错'
    case 'CN_TO_EN':
      return '看义选错'
    case 'SPELL':
      return '拼写错误'
    default:
      return value || '-'
  }
}

function getMasteredTagType(value: number) {
  return value === 1 ? 'success' : 'warning'
}

function getMasteredText(value: number) {
  return value === 1 ? '已掌握' : '未掌握'
}

function formatTime(value?: string) {
  return value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-'
}
</script>

<template>
  <div class="error-book-page">
    <div class="error-book-page__header">
      <div>
        <h1>错题本</h1>
        <p>查看当前账号的错题记录，支持按词库、错误类型和掌握状态筛选，并快速标记已掌握。</p>
      </div>
      <div class="error-book-page__actions">
        <el-button @click="router.push('/')">返回首页</el-button>
        <el-button plain @click="router.push('/study')">继续学习</el-button>
      </div>
    </div>

    <el-card class="error-book-filters" shadow="never">
      <div class="error-book-filters__row">
        <div class="error-book-filters__field">
          <span>词库筛选</span>
          <el-select
            v-model="selectedWordBankId"
            clearable
            filterable
            placeholder="全部词库"
            :loading="optionsLoading"
          >
            <el-option v-for="item in wordBankOptions" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </div>

        <div class="error-book-filters__field">
          <span>错误类型</span>
          <el-select v-model="selectedErrorType" placeholder="全部类型">
            <el-option v-for="item in errorTypeOptions" :key="item.value || 'all'" :label="item.label" :value="item.value" />
          </el-select>
        </div>

        <div class="error-book-filters__field">
          <span>掌握状态</span>
          <el-select v-model="selectedMastered" placeholder="请选择掌握状态">
            <el-option v-for="item in masteredOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </div>
      </div>

      <div class="error-book-filters__actions">
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
        <el-button type="danger" plain :disabled="!canOpenClearDialog" @click="openClearDialog">清空</el-button>
        <el-button text @click="fetchErrorBooks()">刷新列表</el-button>
      </div>

      <div class="error-book-filters__summary">
        <span>当前页：{{ currentPage }}</span>
        <span>总记录：{{ total }}</span>
        <span>未掌握：{{ unmasteredCount }}</span>
        <span>已掌握：{{ masteredCount }}</span>
      </div>
    </el-card>

    <el-card class="error-book-table-card" shadow="never">
      <el-skeleton :loading="loading" animated :rows="8">
        <template #default>
          <el-empty v-if="!errorBooks.length" description="当前筛选条件下暂无错题记录。" />

          <template v-else>
            <el-table :data="errorBooks" stripe class="error-book-table">
              <el-table-column label="单词" min-width="220">
                <template #default="{ row }">
                  <div class="error-book-word">
                    <strong>{{ row.english }}</strong>
                    <span v-if="row.phonetic">{{ row.phonetic }}</span>
                    <small>{{ row.chinese }}</small>
                  </div>
                </template>
              </el-table-column>

              <el-table-column prop="wordBankName" label="词库" min-width="160" />

              <el-table-column label="错误类型" min-width="120">
                <template #default="{ row }">
                  <el-tag effect="plain">{{ getErrorTypeText(row.errorType) }}</el-tag>
                </template>
              </el-table-column>

              <el-table-column prop="errorTimes" label="错误次数" min-width="100" />

              <el-table-column label="掌握状态" min-width="110">
                <template #default="{ row }">
                  <el-tag :type="getMasteredTagType(row.isMastered)">
                    {{ getMasteredText(row.isMastered) }}
                  </el-tag>
                </template>
              </el-table-column>

              <el-table-column label="最近更新时间" min-width="170">
                <template #default="{ row }">
                  {{ formatTime(row.updatedAt) }}
                </template>
              </el-table-column>

              <el-table-column label="操作" width="140" fixed="right">
                <template #default="{ row }">
                  <el-button
                    v-if="row.isMastered !== 1"
                    type="success"
                    link
                    :loading="submittingId === row.id"
                    @click="handleMarkMastered(row)"
                  >
                    标记掌握
                  </el-button>
                  <span v-else class="error-book-mastered-text">已掌握</span>
                </template>
              </el-table-column>
            </el-table>

            <div class="error-book-pagination">
              <el-pagination
                background
                layout="prev, pager, next, total"
                :current-page="currentPage"
                :page-size="pageSize"
                :total="total"
                @current-change="handlePageChange"
              />
            </div>
          </template>
        </template>
      </el-skeleton>
    </el-card>

    <el-dialog
      v-model="clearDialogVisible"
      title="清空错题本"
      width="520px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <div class="error-book-clear">
        <p class="error-book-clear__tip">请选择清空范围，提交前还会进行一次确认。</p>
        <el-radio-group v-model="clearScope" class="error-book-clear__options">
          <el-radio value="currentWordBank" :disabled="!hasSelectedWordBank">
            <div class="error-book-clear__option">
              <strong>当前词库</strong>
              <span>{{ getClearScopeDescription('currentWordBank') }}</span>
            </div>
          </el-radio>
          <el-radio value="currentFilters">
            <div class="error-book-clear__option">
              <strong>当前筛选结果</strong>
              <span>{{ getClearScopeDescription('currentFilters') }}</span>
            </div>
          </el-radio>
        </el-radio-group>
      </div>

      <template #footer>
        <div class="error-book-clear__footer">
          <el-button @click="clearDialogVisible = false">取消</el-button>
          <el-button type="danger" :loading="clearing" @click="handleClear">确认清空</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.error-book-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(20px, 3vw, 40px) clamp(16px, 3vw, 24px) 56px;
  background: linear-gradient(180deg, #f8fbff 0%, #eef4ff 100%);
}

.error-book-page__header,
.error-book-filters,
.error-book-table-card {
  max-width: 1180px;
  margin: 0 auto;
}

.error-book-page__header {
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  gap: 16px;
}

.error-book-page__header h1 {
  margin: 0 0 8px;
  font-size: 30px;
  color: #1f2d3d;
}

.error-book-page__header p {
  margin: 0;
  color: #5b6475;
}

.error-book-page__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.error-book-filters {
  margin-bottom: 20px;
  border-radius: 20px;
}

.error-book-filters__row {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}

.error-book-filters__field {
  display: grid;
  gap: 10px;
  color: #4b5563;
}

.error-book-filters__field :deep(.el-select) {
  width: 100%;
}

.error-book-filters__actions,
.error-book-filters__summary {
  margin-top: 18px;
  display: flex;
  flex-wrap: wrap;
  gap: 12px 16px;
  align-items: center;
}

.error-book-filters__summary {
  color: #6b7280;
  font-size: 14px;
}

.error-book-table-card {
  border-radius: 24px;
}

.error-book-table {
  width: 100%;
}

.error-book-word {
  display: grid;
  gap: 6px;
}

.error-book-word strong {
  font-size: 16px;
  color: #18212f;
}

.error-book-word span {
  color: #4f6db5;
}

.error-book-word small {
  color: #5b6475;
  font-size: 13px;
  line-height: 1.6;
}

.error-book-mastered-text {
  color: #67c23a;
  font-size: 13px;
}

.error-book-pagination {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

.error-book-clear {
  display: grid;
  gap: 16px;
}

.error-book-clear__tip {
  margin: 0;
  color: #5b6475;
}

.error-book-clear__options {
  display: grid;
  gap: 14px;
}

.error-book-clear__option {
  display: grid;
  gap: 6px;
  padding-top: 2px;
}

.error-book-clear__option strong {
  color: #1f2d3d;
  font-size: 15px;
}

.error-book-clear__option span {
  color: #6b7280;
  font-size: 13px;
  line-height: 1.6;
}

.error-book-clear__footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

@media (max-width: 900px) {
  .error-book-filters__row {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .error-book-page__header,
  .error-book-page__actions,
  .error-book-pagination {
    flex-direction: column;
    align-items: stretch;
  }

  .error-book-filters__actions :deep(.el-button) {
    flex: 1 1 calc(50% - 8px);
    min-width: 0;
  }
}
</style>
