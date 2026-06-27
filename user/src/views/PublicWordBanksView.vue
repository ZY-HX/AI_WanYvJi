<script setup lang="ts">
/** 词库广场页面组件 - 展示所有公开的公共词库 */
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import dayjs from 'dayjs'
import {
  cancelCollectWordBank,
  collectWordBank,
  downloadWordBankAsTxt,
  getPublicWordBanks,
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

/** 路由实例 */
const router = useRouter()
const route = useRoute()
/** 用户信息 Store */
const userStore = useUserStore()

/** 页面加载状态 */
const loading = ref(false)
/** 收藏/取消收藏操作中的词库ID */
const togglingId = ref<number | null>(null)
/** 当前分页页码 */
const currentPage = ref(1)
/** 每页显示数量 */
const pageSize = ref(9)
/** 总记录数 */
const total = ref(0)
/** 搜索关键词 */
const keyword = ref('')
const selectedLanguage = ref<LearningLanguage>(getPreferredLearningLanguage())
/** 搜索表单数据 */
const searchForm = reactive({
  keyword: '',
  language: selectedLanguage.value as LearningLanguage,
})
const languageOptions = getLearningLanguageOptions()
/** 公开词库列表 */
const wordBanks = ref<WordBank[]>([])

/** 判断当前用户是否为游客身份 */
const isGuest = computed(() => userStore.userInfo?.role === 'GUEST')
/** 当前登录用户的ID */
const currentUserId = computed(() => userStore.userInfo?.userId)

/** 组件挂载完成后初始化：加载公开词库列表 */
onMounted(async () => {
  const queryLanguage = typeof route.query.language === 'string' ? route.query.language.toUpperCase() : ''
  if (queryLanguage === 'EN' || queryLanguage === 'JA' || queryLanguage === 'KO' || queryLanguage === 'DE' || queryLanguage === 'FR' || queryLanguage === 'ES') {
    selectedLanguage.value = queryLanguage
    searchForm.language = queryLanguage
    setPreferredLearningLanguage(queryLanguage)
  }
  await fetchWordBanks()
})

/**
 * 获取公开词库列表（分页）
 * @param page 页码，默认使用当前页码
 */
async function fetchWordBanks(page = currentPage.value) {
  loading.value = true
  try {
    /** 调用后端接口获取公开词库列表 */
    const result = await getPublicWordBanks({
      current: page,
      size: pageSize.value,
      keyword: keyword.value || undefined,
      language: selectedLanguage.value,
    })
    
    /** 
     * 🔧 兼容多种数据格式
     * - 标准格式：{ code, message, data: { current, size, total, records } }
     * - 直接数据格式：{ current, size, total, records }
     */
    const responseData = result
    
    if (!responseData) {
      console.warn('[词库广场] API返回数据为空')
      wordBanks.value = []
      total.value = 0
      return
    }
    
    /** 更新分页状态和词库数据 */
    currentPage.value = Number(responseData.current || page)
    pageSize.value = Number(responseData.size || pageSize.value)
    total.value = Number(responseData.total ?? 0)
    wordBanks.value = responseData.records ?? (Array.isArray(responseData) ? responseData : [])
    
    /** 🔍 调试日志：输出获取到的词库数量 */
    console.log(`[词库广场] 成功获取 ${wordBanks.value.length} 个公开词库 (总计: ${total.value})`)
    if (wordBanks.value.length > 0) {
      console.log('[词库广场] 词库名称:', wordBanks.value.map(wb => wb.name))
    }
  } catch (error) {
    /** 错误处理：捕获 API 调用异常并显示友好提示 */
    console.error('[词库广场] 获取公开词库失败:', error)
    ElMessage.error('获取公开词库失败，请检查网络连接或刷新页面重试')
    wordBanks.value = []
    total.value = 0
  } finally {
    /** 无论成功失败都要关闭加载状态 */
    loading.value = false
  }
}

/** 处理搜索操作：根据关键词搜索公开词库 */
async function handleSearch() {
  keyword.value = searchForm.keyword.trim()
  selectedLanguage.value = searchForm.language
  setPreferredLearningLanguage(searchForm.language)
  currentPage.value = 1
  await fetchWordBanks(1)
}

/** 处理语言切换：选择不同语言后自动刷新词库列表 */
async function handleLanguageChange(language: LearningLanguage) {
  selectedLanguage.value = language
  searchForm.language = language
  setPreferredLearningLanguage(language)
  currentPage.value = 1
  await fetchWordBanks(1)
}

/** 处理重置操作：清空搜索条件并重新加载 */
async function handleReset() {
  searchForm.keyword = ''
  searchForm.language = getPreferredLearningLanguage()
  keyword.value = ''
  selectedLanguage.value = searchForm.language
  currentPage.value = 1
  await fetchWordBanks(1)
}

/** 判断词库是否为当前用户自己创建的 */
function isOwnWordBank(item: WordBank) {
  return currentUserId.value === item.userId
}

/**
 * 处理收藏/取消收藏操作
 * 用户可以收藏公开词库，收藏后可在"我的词库-我收藏的"中查看
 */
async function handleToggleCollect(item: WordBank) {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持收藏共享词库')
    return
  }
  if (isOwnWordBank(item)) {
    ElMessage.info('自己创建的公开词库无需重复收藏')
    return
  }

  togglingId.value = item.id
  try {
    if (item.collected) {
      await cancelCollectWordBank(item.id)
      item.collected = false
      ElMessage.success('已取消收藏')
    } else {
      await collectWordBank(item.id)
      item.collected = true
      ElMessage.success('收藏成功，已加入“我的词库-我收藏的”')
    }
  } finally {
    togglingId.value = null
  }
}

/** 跳转到学习页面并自动选中指定词库 */
function goToStudy(item: WordBank) {
  void router.push(`/study?wordBankId=${item.id}&language=${item.language}`)
}

/**
 * 下载词库为 TXT 文件
 * @param item 要下载的词库对象
 */
async function handleDownload(item: WordBank) {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持下载共享词库')
    return
  }
  try {
    const fileName = `${item.name}.txt`
    await downloadWordBankAsTxt(item.id, fileName)
    ElMessage.success(`词库「${item.name}」下载成功`)
  } catch (error: any) {
    ElMessage.error(error?.response?.data?.message || '下载失败，请稍后重试')
  }
}

/** 格式化时间显示：将时间戳转为易读的日期时间格式 */
function formatTime(value?: string) {
  return value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-'
}

function getLanguageText(language: LearningLanguage) {
  return getLearningLanguageLabel(language)
}
</script>

<template>
  <div class="public-wordbank-page">
    <div class="public-wordbank-page__header">
      <div>
        <h1>词库广场</h1>
        <p>搜索已审核通过的公开词库，收藏后可在“我的词库 - 我收藏的”中继续学习。</p>
      </div>
      <div class="public-wordbank-page__actions">
        <el-button @click="router.push('/')">返回首页</el-button>
        <el-button type="primary" plain @click="router.push('/wordbanks')">我的词库</el-button>
      </div>
    </div>

    <el-alert
      v-if="isGuest"
      title="游客模式可浏览公开词库，但不能执行收藏操作。"
      type="warning"
      :closable="false"
      show-icon
      class="public-wordbank-alert"
    />

    <el-card class="public-wordbank-panel" shadow="never">
      <div class="public-wordbank-search">
        <el-input
          v-model.trim="searchForm.keyword"
          placeholder="搜索词库名称或描述"
          clearable
          @keyup.enter="handleSearch"
        />
        <el-select v-model="searchForm.language" placeholder="选择语种" @change="handleLanguageChange">
          <el-option v-for="item in languageOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>

      <div class="public-wordbank-toolbar">
        <div>
          <strong>{{ total }}</strong>
          <span> 个公开词库</span>
        </div>
        <el-button text @click="fetchWordBanks()">刷新列表</el-button>
      </div>

      <el-skeleton :loading="loading" animated :rows="8">
        <template #default>
          <el-empty v-if="!wordBanks.length" description="未搜索到符合条件的公开词库，换个关键词试试。" />

          <div v-else class="public-wordbank-grid">
            <el-card v-for="item in wordBanks" :key="item.id" class="public-wordbank-card" shadow="hover">
              <div class="public-wordbank-card__top">
                <div>
                  <h3>{{ item.name }}</h3>
                  <p>{{ item.description || '暂无描述' }}</p>
                </div>
                <el-tag type="success">已公开</el-tag>
              </div>

              <div class="public-wordbank-card__meta">
                <span>作者：{{ item.creatorName || `用户 #${item.userId}` }}</span>
                <span>单词数：{{ item.wordCount }}</span>
                <span>分类：{{ item.category || '未分类' }}</span>
                <span>语种：{{ getLanguageText(item.language) }}</span>
                <span>更新时间：{{ formatTime(item.updatedAt) }}</span>
              </div>

              <div class="public-wordbank-card__footer">
                <el-button link type="warning" @click="goToStudy(item)">开始学习</el-button>
                <el-button
                  link
                  type="success"
                  :disabled="isGuest"
                  @click="handleDownload(item)"
                >
                  下载词库
                </el-button>
                <el-button
                  v-if="isOwnWordBank(item)"
                  link
                  disabled
                >
                  自己创建
                </el-button>
                <el-button
                  v-else
                  link
                  :type="item.collected ? 'danger' : 'primary'"
                  :loading="togglingId === item.id"
                  :disabled="isGuest"
                  @click="handleToggleCollect(item)"
                >
                  {{ item.collected ? '取消收藏' : '收藏词库' }}
                </el-button>
              </div>
            </el-card>
          </div>
        </template>
      </el-skeleton>

      <div class="public-wordbank-pagination">
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
  </div>
</template>

<style scoped>
/* ==================== 深色主题 - 词库广场 ==================== */
.public-wordbank-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(20px, 3vw, 40px) clamp(16px, 3vw, 24px) 56px;
  background: linear-gradient(180deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
}

.public-wordbank-page__header,
.public-wordbank-alert,
.public-wordbank-panel {
  max-width: 1120px;
  margin: 0 auto;
}

.public-wordbank-page__header {
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  gap: 16px;
}

.public-wordbank-page__header h1 {
  margin: 0 0 8px;
  font-size: 30px;
  color: #38bdf8;
  font-weight: 700;
}

.public-wordbank-page__header p {
  margin: 0;
  color: #cbd5e1;
  text-shadow:
    0 0 6px rgba(148, 163, 184, 0.25),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.public-wordbank-page__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.public-wordbank-alert {
  margin-bottom: 16px;
}

.public-wordbank-panel {
  border-radius: 20px;
}

.public-wordbank-search {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 130px auto auto;
  gap: 12px;
  margin-bottom: 18px;
}

.public-wordbank-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  color: #cbd5e1;
  text-shadow:
    0 0 6px rgba(148, 163, 184, 0.25),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.public-wordbank-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.public-wordbank-card {
  border-radius: 18px;
  border: 1px solid rgba(56, 189, 248, 0.18);
  background: rgba(20, 50, 85, 0.32) !important;
  backdrop-filter: blur(12px);
  transition: all 0.3s ease;
}

.public-wordbank-card:hover {
  border-color: rgba(56, 189, 248, 0.5);
  box-shadow: 0 14px 36px rgba(56, 189, 248, 0.2);
  background: rgba(25, 65, 110, 0.45) !important;
}

.public-wordbank-card__top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 18px;
}

.public-wordbank-card__top h3 {
  margin: 0 0 10px;
  font-size: 20px;
  color: #ffffff;
  font-weight: 600;
  text-shadow:
    0 0 8px rgba(56, 189, 248, 0.5),
    0 0 20px rgba(56, 189, 248, 0.25),
    0 1px 2px rgba(0, 0, 0, 0.4);
}

.public-wordbank-card__top p {
  margin: 0;
  color: #e2e8f0;
  line-height: 1.7;
  font-size: 14px;
  text-shadow:
    0 0 6px rgba(226, 232, 240, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.35);
}

.public-wordbank-card__meta {
  display: grid;
  gap: 8px;
  color: #e2e8f0;
  font-size: 13.5px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.public-wordbank-card__footer {
  margin-top: 18px;
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.public-wordbank-pagination {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 1080px) {
  .public-wordbank-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .public-wordbank-page__header {
    flex-direction: column;
  }

  .public-wordbank-page__actions {
    width: 100%;
    justify-content: flex-start;
  }

  .public-wordbank-page__actions :deep(.el-button) {
    flex: 1 1 calc(50% - 8px);
    min-width: 0;
  }

  .public-wordbank-search {
    grid-template-columns: 1fr;
  }

  .public-wordbank-grid {
    grid-template-columns: 1fr;
  }

  .public-wordbank-pagination {
    justify-content: center;
  }
}
</style>
