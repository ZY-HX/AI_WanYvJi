<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type UploadInstance, type UploadProps, type UploadRequestOptions } from 'element-plus'
import dayjs from 'dayjs'
import {
  getWordBankDetail,
  importWordBankTxt,
  submitWordBankReview,
  type WordBank,
  type WordImportResult,
} from '../api/wordbanks'
import { useUserStore } from '../stores/user'

const MAX_IMPORT_FILE_SIZE = 5 * 1024 * 1024
type UploadError = Parameters<UploadRequestOptions['onError']>[0]

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const importing = ref(false)
const reviewSubmitting = ref(false)
const uploadProgress = ref(0)
const wordBank = ref<WordBank | null>(null)
const importResult = ref<WordImportResult | null>(null)
const uploadRef = ref<UploadInstance>()

const isGuest = computed(() => userStore.userInfo?.role === 'GUEST')

const formattedCreatedAt = computed(() =>
  wordBank.value?.createdAt ? dayjs(wordBank.value.createdAt).format('YYYY-MM-DD HH:mm:ss') : '-',
)

const formattedUpdatedAt = computed(() =>
  wordBank.value?.updatedAt ? dayjs(wordBank.value.updatedAt).format('YYYY-MM-DD HH:mm:ss') : '-',
)

const visibilityTagType = computed(() => {
  if (wordBank.value?.isPublic === 2) {
    return 'success'
  }
  if (wordBank.value?.isPublic === 1) {
    return 'warning'
  }
  return 'info'
})

const visibilityText = computed(() => {
  if (wordBank.value?.isPublic === 2) {
    return '已公开'
  }
  if (wordBank.value?.isPublic === 1) {
    return '审核中'
  }
  return '私有词库'
})

onMounted(async () => {
  await fetchWordBankDetail()
})

async function fetchWordBankDetail() {
  const id = Number(route.params.id)
  if (!Number.isFinite(id)) {
    await router.replace('/wordbanks')
    return
  }

  loading.value = true
  try {
    const result = await getWordBankDetail(id)
    wordBank.value = result
  } finally {
    loading.value = false
  }
}

async function handleSubmitReview() {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持申请公开词库')
    return
  }
  if (!wordBank.value) {
    return
  }

  reviewSubmitting.value = true
  try {
    const result = await submitWordBankReview(wordBank.value.id)
    wordBank.value = result
    ElMessage.success('词库已提交审核，请等待管理员处理')
  } finally {
    reviewSubmitting.value = false
  }
}

const beforeImportUpload: UploadProps['beforeUpload'] = (rawFile) => {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持导入词库单词')
    return false
  }

  if (!rawFile.name.toLowerCase().endsWith('.txt')) {
    ElMessage.error('仅支持上传 .txt 文件')
    return false
  }

  if (rawFile.size > MAX_IMPORT_FILE_SIZE) {
    ElMessage.error('TXT 文件大小不能超过 5MB')
    return false
  }

  importResult.value = null
  uploadProgress.value = 0
  return true
}

async function handleImportRequest(options: UploadRequestOptions) {
  if (!wordBank.value) {
    options.onError(createUploadError('词库信息不存在'))
    return
  }

  importing.value = true
  uploadProgress.value = 0

  try {
    const result = await importWordBankTxt(wordBank.value.id, options.file, (event) => {
      const percent =
        typeof event.progress === 'number'
          ? event.progress * 100
          : event.total
            ? (event.loaded / event.total) * 100
            : 0
      uploadProgress.value = Math.max(0, Math.min(100, Math.round(percent)))
    })

    importResult.value = result
    uploadProgress.value = 100
    options.onSuccess(result)
    uploadRef.value?.clearFiles()
    await fetchWordBankDetail()

    ElMessage.success(
      `导入完成：成功 ${result.importedCount} 条，失败 ${result.failedCount} 条`,
    )
  } catch (error) {
    uploadProgress.value = 0
    const responseMessage =
      typeof error === 'object' &&
      error !== null &&
      'response' in error &&
      typeof error.response === 'object' &&
      error.response !== null &&
      'data' in error.response &&
      typeof error.response.data === 'object' &&
      error.response.data !== null &&
      'message' in error.response.data &&
      typeof error.response.data.message === 'string'
        ? error.response.data.message
        : null

    options.onError(
      createUploadError(responseMessage || (error instanceof Error ? error.message : 'TXT 导入失败')),
    )
  } finally {
    importing.value = false
  }
}

function createUploadError(message: string): UploadError {
  return {
    name: 'UploadError',
    message,
    status: 400,
    method: 'POST',
    url: '',
  } as UploadError
}
</script>

<template>
  <div class="wordbank-detail-page">
    <div class="wordbank-detail-page__header">
      <div>
        <h1>词库详情</h1>
        <p>查看当前词库信息，并通过 TXT 文件批量导入单词。</p>
      </div>
      <div class="wordbank-detail-page__actions">
        <el-button @click="router.push('/wordbanks')">返回我的词库</el-button>
        <el-button
          v-if="wordBank?.isPublic === 0"
          type="success"
          plain
          :loading="reviewSubmitting"
          :disabled="isGuest"
          @click="handleSubmitReview"
        >
          申请公开
        </el-button>
        <el-button v-else-if="wordBank?.isPublic === 1" type="warning" plain disabled>审核中</el-button>
        <el-button v-else-if="wordBank?.isPublic === 2" type="success" plain disabled>已公开</el-button>
        <el-button type="primary" plain @click="router.push('/')">返回首页</el-button>
      </div>
    </div>

    <el-alert
      v-if="isGuest"
      title="游客模式仅支持查看词库，不支持 TXT 导入。"
      type="warning"
      :closable="false"
      show-icon
      class="wordbank-detail-alert"
    />

    <el-skeleton :loading="loading" animated :rows="8">
      <template #default>
        <el-card v-if="wordBank" class="wordbank-detail-card" shadow="hover">
          <div class="wordbank-detail-card__head">
            <div>
              <h2>{{ wordBank.name }}</h2>
              <p>{{ wordBank.description || '暂无描述' }}</p>
            </div>
            <el-tag :type="visibilityTagType" size="large">
              {{ visibilityText }}
            </el-tag>
          </div>

          <div class="wordbank-detail-grid">
            <div class="detail-item">
              <span>分类</span>
              <strong>{{ wordBank.category || '自定义' }}</strong>
            </div>
            <div class="detail-item">
              <span>单词数量</span>
              <strong>{{ wordBank.wordCount }}</strong>
            </div>
            <div class="detail-item">
              <span>创建时间</span>
              <strong>{{ formattedCreatedAt }}</strong>
            </div>
            <div class="detail-item">
              <span>更新时间</span>
              <strong>{{ formattedUpdatedAt }}</strong>
            </div>
          </div>

          <el-alert
            v-if="wordBank.isPublic === 1"
            title="该词库已进入审核队列，请等待管理员审核通过后向其他用户公开。"
            type="warning"
            :closable="false"
            show-icon
            class="wordbank-detail-review-alert"
          />

          <div class="wordbank-detail-section">
            <div class="wordbank-detail-section__title">
              <div>
                <h3>TXT 批量导入</h3>
                <p>支持 UTF-8 编码的 `.txt` 文件，每行格式为“英文,中文”或“英文 中文”。</p>
              </div>
              <el-tag type="info">单文件上限 5MB</el-tag>
            </div>

            <el-upload
              ref="uploadRef"
              class="wordbank-import-upload"
              accept=".txt,text/plain"
              :show-file-list="true"
              :limit="1"
              :auto-upload="true"
              :before-upload="beforeImportUpload"
              :http-request="handleImportRequest"
              :disabled="importing || isGuest"
            >
              <el-button type="primary" :loading="importing" :disabled="isGuest">
                选择 TXT 文件并导入
              </el-button>
              <template #tip>
                <div class="wordbank-import-tip">
                  示例：`apple,苹果` 或 `apple 苹果`
                </div>
              </template>
            </el-upload>

            <el-progress
              v-if="importing || uploadProgress > 0"
              :percentage="uploadProgress"
              :stroke-width="10"
              :status="importing ? undefined : 'success'"
              class="wordbank-import-progress"
            />

            <div v-if="importResult" class="wordbank-import-result">
              <div class="wordbank-import-result__summary">
                <div class="detail-item">
                  <span>文件总行数</span>
                  <strong>{{ importResult.totalLines }}</strong>
                </div>
                <div class="detail-item">
                  <span>成功导入</span>
                  <strong>{{ importResult.importedCount }}</strong>
                </div>
                <div class="detail-item">
                  <span>失败行数</span>
                  <strong>{{ importResult.failedCount }}</strong>
                </div>
                <div class="detail-item">
                  <span>当前词库单词数</span>
                  <strong>{{ importResult.wordCount }}</strong>
                </div>
              </div>

              <el-alert
                :title="
                  importResult.failedCount
                    ? '部分行未导入，请根据下方失败原因修正后重新上传。'
                    : '本次导入全部成功，词库单词数量已更新。'
                "
                :type="importResult.failedCount ? 'warning' : 'success'"
                :closable="false"
                show-icon
              />

              <el-table
                v-if="importResult.failedLines.length"
                :data="importResult.failedLines"
                size="small"
                max-height="320"
                class="wordbank-import-table"
              >
                <el-table-column prop="lineNumber" label="行号" width="90" />
                <el-table-column prop="content" label="原始内容" min-width="220" show-overflow-tooltip />
                <el-table-column prop="reason" label="失败原因" min-width="220" />
              </el-table>
            </div>
          </div>

          <el-alert
            title="单词列表展示将在后续模块补充；当前模块已支持 TXT 批量入库与词库数量刷新。"
            type="info"
            :closable="false"
            show-icon
            class="wordbank-detail-placeholder"
          />
        </el-card>
      </template>
    </el-skeleton>
  </div>
</template>

<style scoped>
.wordbank-detail-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(20px, 3vw, 40px) clamp(16px, 3vw, 24px) 56px;
  background: linear-gradient(180deg, #f6f8fc 0%, #eef3ff 100%);
}

.wordbank-detail-alert,
.wordbank-detail-card {
  max-width: 1080px;
  margin: 0 auto;
}

.wordbank-detail-page__header {
  max-width: 1080px;
  margin: 0 auto 20px;
  display: flex;
  justify-content: space-between;
  gap: 16px;
}

.wordbank-detail-page__header h1 {
  margin: 0 0 8px;
  font-size: 30px;
  color: #1f2d3d;
}

.wordbank-detail-page__header p {
  margin: 0;
  color: #5b6475;
}

.wordbank-detail-page__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.wordbank-detail-alert {
  margin-bottom: 16px;
}

.wordbank-detail-card {
  border-radius: 20px;
}

.wordbank-detail-card__head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 24px;
}

.wordbank-detail-card__head h2 {
  margin: 0 0 10px;
  font-size: 28px;
  color: #1f2d3d;
}

.wordbank-detail-card__head p {
  margin: 0;
  color: #5b6475;
}

.wordbank-detail-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.wordbank-detail-section {
  margin-bottom: 24px;
  padding: 24px;
  border-radius: 18px;
  background: #f8faff;
}

.wordbank-detail-section__title {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 18px;
}

.wordbank-detail-section__title h3 {
  margin: 0 0 8px;
  font-size: 20px;
  color: #1f2d3d;
}

.wordbank-detail-section__title p {
  margin: 0;
  color: #5b6475;
  line-height: 1.6;
}

.wordbank-import-tip {
  margin-top: 8px;
  color: #7b8798;
  line-height: 1.6;
}

.wordbank-import-progress {
  margin-top: 16px;
}

.wordbank-import-result {
  margin-top: 20px;
}

.wordbank-import-result__summary {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
  margin-bottom: 16px;
}

.wordbank-import-table {
  margin-top: 16px;
}

.wordbank-detail-placeholder {
  margin-top: 8px;
}

.wordbank-detail-review-alert {
  margin-bottom: 24px;
}

.detail-item {
  padding: 18px 20px;
  border-radius: 16px;
  background: #f7f9ff;
}

.detail-item span {
  display: block;
  margin-bottom: 10px;
  color: #7b8798;
}

.detail-item strong {
  font-size: 18px;
  color: #1f2d3d;
}

@media (max-width: 900px) {
  .wordbank-detail-page__header {
    flex-direction: column;
  }

  .wordbank-detail-page__actions {
    width: 100%;
    justify-content: flex-start;
  }

  .wordbank-detail-grid {
    grid-template-columns: 1fr;
  }

  .wordbank-detail-section__title {
    flex-direction: column;
  }

  .wordbank-import-result__summary {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 640px) {
  .wordbank-import-result__summary {
    grid-template-columns: 1fr;
  }
}
</style>
