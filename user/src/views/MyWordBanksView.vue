<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules, type TabsPaneContext } from 'element-plus'
import dayjs from 'dayjs'
import {
  cancelCollectWordBank,
  createWordBank,
  deleteWordBank,
  getCollectedWordBanks,
  getMyWordBanks,
  submitWordBankReview,
  updateWordBank,
  type CreateWordBankPayload,
  type UpdateWordBankPayload,
  type WordBank,
} from '../api/wordbanks'
import { useUserStore } from '../stores/user'
import {
  getLearningLanguageLabel,
  getLearningLanguageOptions,
  getPreferredLearningLanguage,
  setPreferredLearningLanguage,
  type LearningLanguage,
} from '../shared/learningLanguage'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const loading = ref(false)
const submitting = ref(false)
const reviewSubmittingId = ref<number | null>(null)
const collectSubmittingId = ref<number | null>(null)
const dialogVisible = ref(false)
const dialogMode = ref<'create' | 'edit'>('create')
const activeTab = ref<'created' | 'collected'>('created')
const currentPage = ref(1)
const pageSize = ref(9)
const total = ref(0)
const wordBanks = ref<WordBank[]>([])
const selectedLanguage = ref<LearningLanguage>(getPreferredLearningLanguage())
const editingId = ref<number | null>(null)
const formRef = ref<FormInstance>()
const languageOptions = getLearningLanguageOptions()

const form = reactive<CreateWordBankPayload & UpdateWordBankPayload>({
  name: '',
  description: '',
  language: 'EN',
})

const formRules: FormRules<typeof form> = {
  name: [
    { required: true, message: '请输入词库名称', trigger: 'blur' },
    { max: 100, message: '词库名称不能超过100个字符', trigger: 'blur' },
  ],
  description: [{ max: 500, message: '词库描述不能超过500个字符', trigger: 'blur' }],
}

const isGuest = computed(() => userStore.userInfo?.role === 'GUEST')
const dialogTitle = computed(() => (dialogMode.value === 'create' ? '新建词库' : '编辑词库'))
const tabCountLabel = computed(() => (activeTab.value === 'created' ? '我创建的词库' : '我收藏的词库'))
const emptyDescription = computed(() =>
  activeTab.value === 'created'
    ? '你还没有创建词库，点击右上角开始新建吧。'
    : '你还没有收藏公开词库，去词库广场挑选感兴趣的内容吧。',
)

onMounted(async () => {
  const queryLanguage = typeof route.query.language === 'string' ? route.query.language.toUpperCase() : ''
  if (queryLanguage === 'EN' || queryLanguage === 'JA' || queryLanguage === 'KO' || queryLanguage === 'DE' || queryLanguage === 'FR' || queryLanguage === 'ES') {
    selectedLanguage.value = queryLanguage
    setPreferredLearningLanguage(queryLanguage)
  }
  await fetchWordBanks()
})

async function fetchWordBanks(page = currentPage.value) {
  loading.value = true
  try {
    const result =
      activeTab.value === 'created'
        ? await getMyWordBanks({
            current: page,
            size: pageSize.value,
            language: selectedLanguage.value,
          })
        : await getCollectedWordBanks({
            current: page,
            size: pageSize.value,
            language: selectedLanguage.value,
          })

    const responseData = result
    
    if (!responseData) {
      console.warn('[我的词库] API返回数据为空')
      wordBanks.value = []
      total.value = 0
      return
    }
    
    currentPage.value = Number(responseData.current || page)
    pageSize.value = Number(responseData.size || pageSize.value)
    total.value = Number(responseData.total ?? 0)
    wordBanks.value = responseData.records ?? []
  } finally {
    loading.value = false
  }
}

async function handleTabChange(_pane: TabsPaneContext) {
  currentPage.value = 1
  await fetchWordBanks(1)
}

async function handleLanguageChange(language: LearningLanguage) {
  setPreferredLearningLanguage(language)
  currentPage.value = 1
  await fetchWordBanks(1)
}

function openCreateDialog() {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持创建自定义词库')
    return
  }
  dialogMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.description = ''
  form.language = selectedLanguage.value
  dialogVisible.value = true
  formRef.value?.clearValidate()
}

function openEditDialog(item: WordBank) {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持编辑自定义词库')
    return
  }
  dialogMode.value = 'edit'
  editingId.value = item.id
  form.name = item.name
  form.description = item.description || ''
  form.language = item.language
  dialogVisible.value = true
  formRef.value?.clearValidate()
}

function handleDialogClosed() {
  formRef.value?.resetFields()
  editingId.value = null
}

async function handleSubmit() {
  if (!formRef.value) {
    return
  }

  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) {
    return
  }

  submitting.value = true
  try {
    if (dialogMode.value === 'create') {
      await createWordBank({
        name: form.name,
        description: form.description,
        language: form.language,
      })
      currentPage.value = 1
      ElMessage.success('词库创建成功')
    } else if (editingId.value) {
      await updateWordBank(editingId.value, {
        name: form.name,
        description: form.description,
        language: form.language,
      })
      ElMessage.success('词库更新成功')
    }

    dialogVisible.value = false
    await fetchWordBanks(currentPage.value)
  } finally {
    submitting.value = false
  }
}

async function handleDelete(item: WordBank) {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持删除自定义词库')
    return
  }

  await ElMessageBox.confirm(
    `确认删除词库“${item.name}”吗？删除后该词库及其关联单词将不再显示。`,
    '删除确认',
    {
      type: 'warning',
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
    },
  )

  await deleteWordBank(item.id)
  ElMessage.success('词库已删除')

  const nextPage =
    wordBanks.value.length === 1 && currentPage.value > 1 ? currentPage.value - 1 : currentPage.value
  await fetchWordBanks(nextPage)
}

async function handleCancelCollect(item: WordBank) {
  collectSubmittingId.value = item.id
  try {
    await cancelCollectWordBank(item.id)
    ElMessage.success('已取消收藏')

    const nextPage =
      wordBanks.value.length === 1 && currentPage.value > 1 ? currentPage.value - 1 : currentPage.value
    await fetchWordBanks(nextPage)
  } finally {
    collectSubmittingId.value = null
  }
}

function getVisibilityTagType(isPublic: number) {
  if (isPublic === 2) {
    return 'success'
  }
  if (isPublic === 1) {
    return 'warning'
  }
  return 'info'
}

function getVisibilityText(isPublic: number) {
  if (isPublic === 2) {
    return '已公开'
  }
  if (isPublic === 1) {
    return '审核中'
  }
  return '私有'
}

async function handleSubmitReview(item: WordBank) {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持申请公开词库')
    return
  }

  reviewSubmittingId.value = item.id
  try {
    const result = await submitWordBankReview(item.id)
    const updatedWordBank = result
    wordBanks.value = wordBanks.value.map((wordBank) =>
      wordBank.id === item.id ? updatedWordBank : wordBank,
    )
    ElMessage.success('词库已提交审核，请等待管理员处理')
  } finally {
    reviewSubmittingId.value = null
  }
}

function goToDetail(item: WordBank) {
  if (!item.editable) {
    return
  }
  void router.push(`/wordbanks/${item.id}`)
}

function goToStudy(item: WordBank) {
  void router.push(`/study?wordBankId=${item.id}&language=${item.language}`)
}

function formatTime(value?: string) {
  return value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-'
}

function getLanguageText(language: LearningLanguage) {
  return getLearningLanguageLabel(language)
}
</script>

<template>
  <div class="wordbank-page">
    <div class="wordbank-page__header">
      <div>
        <h1>我的词库</h1>
        <p>管理我创建的自定义词库，或查看已收藏的公开词库并直接进入学习。</p>
      </div>
      <div class="wordbank-page__actions">
        <el-button @click="router.push('/')">返回首页</el-button>
        <el-button plain @click="router.push('/public-wordbanks')">词库广场</el-button>
        <el-button v-if="activeTab === 'created'" type="primary" @click="openCreateDialog">新建词库</el-button>
      </div>
    </div>

    <el-alert
      v-if="isGuest"
      title="游客模式仅支持查看词库，不支持创建、编辑、删除或收藏操作。"
      type="warning"
      :closable="false"
      show-icon
      class="wordbank-alert"
    />

    <el-card class="wordbank-panel" shadow="never">
      <el-tabs v-model="activeTab" class="wordbank-tabs" @tab-change="handleTabChange">
        <el-tab-pane label="我创建的" name="created" />
        <el-tab-pane label="我收藏的" name="collected" />
      </el-tabs>

      <div class="wordbank-panel__toolbar">
        <div>
          <strong>{{ total }}</strong>
          <span> 个{{ tabCountLabel }}</span>
        </div>
        <div class="wordbank-panel__toolbar-actions">
          <el-select v-model="selectedLanguage" style="width: 130px" @change="handleLanguageChange">
            <el-option v-for="item in languageOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
          <el-button text @click="fetchWordBanks()">刷新列表</el-button>
        </div>
      </div>

      <el-skeleton :loading="loading" animated :rows="8">
        <template #default>
          <el-empty v-if="!wordBanks.length" :description="emptyDescription" />

          <div v-else class="wordbank-grid">
            <el-card
              v-for="item in wordBanks"
              :key="item.id"
              class="wordbank-card"
              :class="{ 'wordbank-card--readonly': !item.editable }"
              shadow="hover"
              @click="goToDetail(item)"
            >
              <div class="wordbank-card__top">
                <div>
                  <h3>{{ item.name }}</h3>
                  <p>{{ item.description || '暂无描述' }}</p>
                </div>
                <el-tag :type="getVisibilityTagType(item.isPublic)">
                  {{ getVisibilityText(item.isPublic) }}
                </el-tag>
              </div>

              <div class="wordbank-card__meta">
                <span v-if="activeTab === 'collected'">作者：{{ item.creatorName || `用户 #${item.userId}` }}</span>
                <span>单词数：{{ item.wordCount }}</span>
                <span>分类：{{ item.category || '自定义' }}</span>
                <span>语种：{{ getLanguageText(item.language) }}</span>
                <span>更新时间：{{ formatTime(item.updatedAt) }}</span>
              </div>

              <div class="wordbank-card__footer" @click.stop>
                <el-button v-if="item.editable" link type="primary" @click="goToDetail(item)">查看详情</el-button>
                <el-button link type="warning" @click="goToStudy(item)">开始学习</el-button>

                <template v-if="activeTab === 'created'">
                  <el-button
                    v-if="item.isPublic === 0"
                    link
                    type="success"
                    :loading="reviewSubmittingId === item.id"
                    :disabled="isGuest"
                    @click="handleSubmitReview(item)"
                  >
                    申请公开
                  </el-button>
                  <el-button v-else-if="item.isPublic === 1" link disabled>审核中</el-button>
                  <el-button link @click="openEditDialog(item)" :disabled="isGuest">编辑</el-button>
                  <el-button link type="danger" @click="handleDelete(item)" :disabled="isGuest">删除</el-button>
                </template>

                <template v-else>
                  <el-button
                    link
                    type="danger"
                    :loading="collectSubmittingId === item.id"
                    :disabled="isGuest"
                    @click="handleCancelCollect(item)"
                  >
                    取消收藏
                  </el-button>
                </template>
              </div>
            </el-card>
          </div>
        </template>
      </el-skeleton>

      <div class="wordbank-pagination">
        <el-pagination
          background
          layout="prev, pager, next, total"
          :current-page="currentPage"
          :page-size="pageSize"
          :total="total"
          @current-change="fetchWordBanks"
        />
      </div>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="520px" @closed="handleDialogClosed">
      <el-form ref="formRef" :model="form" :rules="formRules" label-position="top">
        <el-form-item label="词库名称" prop="name">
          <el-input v-model.trim="form.name" maxlength="100" show-word-limit placeholder="例如：雅思高频词汇" />
        </el-form-item>

        <el-form-item label="词库描述" prop="description">
          <el-input
            v-model.trim="form.description"
            type="textarea"
            :rows="4"
            maxlength="500"
            show-word-limit
            placeholder="简要描述这个词库的用途或来源"
          />
        </el-form-item>
        <el-form-item label="学习语种" prop="language">
          <el-select v-model="form.language" placeholder="请选择语种">
            <el-option v-for="item in languageOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
/* ==================== 深色主题 - 我的词库 ==================== */
.wordbank-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(20px, 3vw, 40px) clamp(16px, 3vw, 24px) 56px;
  background: linear-gradient(180deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
}

.wordbank-page__header {
  max-width: 1120px;
  margin: 0 auto 20px;
  display: flex;
  justify-content: space-between;
  gap: 16px;
}

.wordbank-page__header h1 {
  margin: 0 0 8px;
  font-size: 30px;
  color: #38bdf8;
  font-weight: 700;
}

.wordbank-page__header p {
  margin: 0;
  color: #cbd5e1;
  text-shadow:
    0 0 6px rgba(148, 163, 184, 0.25),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.wordbank-toolbar__field {
  display: grid;
  gap: 10px;
  color: #cbd5e1;
  text-shadow:
    0 0 6px rgba(148, 163, 184, 0.25),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.wordbank-page__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.wordbank-alert,
.wordbank-panel {
  max-width: 1120px;
  margin: 0 auto;
}

.wordbank-alert {
  margin-bottom: 16px;
}

.wordbank-panel {
  border-radius: 20px;
}

.wordbank-tabs {
  margin-bottom: 12px;
}

.wordbank-panel__toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 20px;
  color: #94a3b8;
}

.wordbank-panel__toolbar-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.wordbank-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.wordbank-card {
  border-radius: 18px;
  border: 1px solid rgba(56, 189, 248, 0.18);
  background: rgba(20, 50, 85, 0.32) !important;
  backdrop-filter: blur(12px);
  cursor: pointer;
  transition: all 0.3s ease;
}

.wordbank-card:hover {
  transform: translateY(-2px);
  border-color: rgba(56, 189, 248, 0.5);
  box-shadow: 0 12px 28px rgba(56, 189, 248, 0.2);
  background: rgba(25, 65, 110, 0.45) !important;
}

.wordbank-card--readonly {
  cursor: default;
}

.wordbank-card__top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 18px;
}

.wordbank-card__top h3 {
  margin: 0 0 10px;
  font-size: 20px;
  color: #ffffff;
  font-weight: 600;
  text-shadow:
    0 0 8px rgba(56, 189, 248, 0.5),
    0 0 20px rgba(56, 189, 248, 0.25),
    0 1px 2px rgba(0, 0, 0, 0.4);
}

.wordbank-card__top p {
  margin: 0;
  color: #e2e8f0;
  line-height: 1.7;
  font-size: 14px;
  text-shadow:
    0 0 6px rgba(226, 232, 240, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.35);
}

.wordbank-card__meta {
  display: grid;
  gap: 8px;
  color: #e2e8f0;
  font-size: 13.5px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.wordbank-card__footer {
  margin-top: 18px;
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.wordbank-pagination {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 1080px) {
  .wordbank-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .wordbank-page__header {
    flex-direction: column;
  }

  .wordbank-page__actions {
    width: 100%;
    flex-wrap: wrap;
    justify-content: flex-start;
  }

  .wordbank-page__actions :deep(.el-button) {
    flex: 1 1 calc(50% - 8px);
    min-width: 0;
  }

  .wordbank-panel__toolbar {
    align-items: flex-start;
  }

  .wordbank-grid {
    grid-template-columns: 1fr;
  }

  .wordbank-pagination {
    justify-content: center;
  }
}
</style>
