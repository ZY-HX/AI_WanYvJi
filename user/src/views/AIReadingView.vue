<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { Loading } from '@element-plus/icons-vue'
import dayjs from 'dayjs'
import {
  type AiConfigMode,
  adaptAiApiKey,
  deleteAiArticle,
  generateAiArticleStream,
  getAiArticleDetail,
  getAiArticleHistory,
  getAiArticleQuota,
  getAiProviderOptions,
  getAiReadingWordBanks,
  lookupWordTranslation,
  testAiConnection,
  translateAiArticle,
  type AiApiKeyAdaptResponse,
  type AiApiKeySource,
  type AiTestConnectionResponse,
  type AiArticleHistoryDetail,
  type AiArticleHistoryItem,
  type AiArticleHistoryPageResponse,
  type AiArticleGenerateResponse,
  type AiArticleHighlightWord,
  type AiArticleQuota,
  type AiArticleStreamProgressEvent,
  type AiDifficulty,
  type AiLength,
  type AiProviderOption,
  type AiWordBankOption,
} from '../api/aiReading'
import { addWordToMyWordBank, getMyWordBanks, type WordBank } from '../api/wordbanks'
import { useUserStore } from '../stores/user'
import {
  getLearningLanguageOptions,
  getPreferredLearningLanguage,
  setPreferredLearningLanguage,
  type LearningLanguage,
} from '../shared/learningLanguage'

const router = useRouter()
const userStore = useUserStore()
const AI_BASE_URL_STORAGE_KEY = 'elm-ai-base-url'
const AI_MODEL_STORAGE_KEY = 'elm-ai-model'
const AI_CONFIG_MODE_STORAGE_KEY = 'elm-ai-config-mode'
const AI_PROVIDER_CODE_STORAGE_KEY = 'elm-ai-provider-code'
const HISTORY_PAGE_SIZE = 6

const formRef = ref<FormInstance>()
const loading = ref(false)
const wordBankLoading = ref(false)
const quotaLoading = ref(false)
const articleLoading = ref(false)
const generating = ref(false)
const adapting = ref(false)
const testingConnection = ref(false)
const testConnectionResult = ref<AiTestConnectionResponse | null>(null)
const historyLoading = ref(false)
const historyDeletingId = ref<number | null>(null)
const addWordDialogVisible = ref(false)
const addWordOptionsLoading = ref(false)
const addWordSubmitting = ref(false)
const wordBanks = ref<AiWordBankOption[]>([])
const customWordBanks = ref<WordBank[]>([])
const providerOptions = ref<AiProviderOption[]>([])
const quota = ref<AiArticleQuota | null>(null)
const articleResult = ref<AiArticleHistoryDetail | null>(null)
const selectedHighlightWord = ref<AiArticleHighlightWord | null>(null)
const activeHistoryId = ref<number | null>(null)
const historyPage = ref<AiArticleHistoryPageResponse<AiArticleHistoryItem>>({
  current: 1,
  size: HISTORY_PAGE_SIZE,
  total: 0,
  records: [],
})
const adaptResult = ref<AiApiKeyAdaptResponse | null>(null)
const streamProgress = ref<AiArticleStreamProgressEvent | null>(null)
const streamingContent = ref('')
const streamingError = ref('')
const generatingWordBankName = ref('')
const selectedLanguage = ref<LearningLanguage>(getPreferredLearningLanguage())
const languageOptions = getLearningLanguageOptions()
const translation = ref('')
const translationArticleId = ref<number | null>(null)
const translating = ref(false)
const showTranslation = ref(false)
const wordTooltip = ref({
  visible: false,
  loading: false,
  english: '',
  chinese: '',
  phonetic: '',
  x: 0,
  y: 0,
})
let wordLookupTimer: number | undefined
let currentLookupWord = ''
let adaptTimer: number | undefined
let generateAbortController: AbortController | null = null
const addWordForm = reactive<{ wordBankId?: number }>({
  wordBankId: undefined,
})

const form = reactive<{
  wordBankId?: number
  theme: string
  difficulty: AiDifficulty
  length: AiLength
  apiKeySource: AiApiKeySource
  customApiKey: string
  configMode: AiConfigMode
  providerCode: string
  apiBaseUrl: string
  model: string
}>({
  wordBankId: undefined,
  theme: '',
  difficulty: 'MEDIUM',
  length: 'SHORT',
  apiKeySource: 'SYSTEM',
  customApiKey: '',
  configMode: 'AUTO',
  providerCode: '',
  apiBaseUrl: '',
  model: '',
})

const formRules: FormRules<typeof form> = {
  wordBankId: [{ required: true, message: '请选择词库', trigger: 'change' }],
  theme: [{ max: 50, message: '主题长度不能超过50个字符', trigger: 'blur' }],
}

const isGuest = computed(() => userStore.userInfo?.role === 'GUEST')
const remainingQuota = computed(() => quota.value?.remainingCount ?? 0)
const systemApiKeyConfigured = computed(() => Boolean(quota.value?.systemApiKeyConfigured))
const canUseSystemApiKey = computed(() => !isGuest.value && systemApiKeyConfigured.value)
const isProviderConfig = computed(() => form.configMode === 'PROVIDER')
const isManualConfig = computed(() => form.configMode === 'MANUAL')
const displayArticleContent = computed(() => streamingContent.value || articleResult.value?.content || '')
const displayHighlightWords = computed(() =>
  streamingContent.value ? [] : articleResult.value?.highlightWords || [],
)
const highlightedArticleHtml = computed(() =>
  renderHighlightedArticle(displayArticleContent.value, displayHighlightWords.value),
)
const activeProvider = computed(() =>
  providerOptions.value.find((item) => item.providerCode === form.providerCode) ?? null,
)
const autoResolvedConfig = computed(() => resolveAutoConfig())
const selectedAddWordBank = computed(() =>
  customWordBanks.value.find((item) => item.id === addWordForm.wordBankId) ?? null,
)

const difficultyOptions: Array<{ label: string; value: AiDifficulty; description: string }> = [
  { label: 'EASY', value: 'EASY', description: '简单句式，适合基础阅读' },
  { label: 'MEDIUM', value: 'MEDIUM', description: '中等难度，兼顾可读性与表达丰富度' },
  { label: 'HARD', value: 'HARD', description: '更复杂表达，适合进阶训练' },
]

const lengthOptions: Array<{ label: string; value: AiLength; description: string }> = [
  { label: '短篇', value: 'SHORT', description: '约 120-180 词' },
  { label: '中篇', value: 'MEDIUM', description: '约 220-320 词' },
  { label: '长篇', value: 'LONG', description: '约 380-520 词' },
]

onMounted(async () => {
  form.customApiKey = ''
  localStorage.removeItem('elm-ai-custom-api-key')
  form.configMode = (localStorage.getItem(AI_CONFIG_MODE_STORAGE_KEY) as AiConfigMode) || 'AUTO'
  form.providerCode = localStorage.getItem(AI_PROVIDER_CODE_STORAGE_KEY) ?? ''
  form.apiBaseUrl = localStorage.getItem(AI_BASE_URL_STORAGE_KEY) ?? ''
  form.model = localStorage.getItem(AI_MODEL_STORAGE_KEY) ?? ''
  loading.value = true
  try {
    setPreferredLearningLanguage(selectedLanguage.value)
    await fetchWordBanks()
    if (!isGuest.value) {
      await fetchProviderOptions()
      await fetchQuota()
      await fetchHistory(1, HISTORY_PAGE_SIZE, false)
    }
  } finally {
    loading.value = false
  }
})

onBeforeUnmount(() => {
  if (adaptTimer) {
    window.clearTimeout(adaptTimer)
  }
  if (wordLookupTimer) {
    window.clearTimeout(wordLookupTimer)
  }
  generateAbortController?.abort()
  generateAbortController = null
})

watch(
  () => selectedLanguage.value,
  (value) => {
    setPreferredLearningLanguage(value)
    form.wordBankId = undefined
    void fetchWordBanks()
  },
)

watch(
  () => form.configMode,
  (value) => {
    localStorage.setItem(AI_CONFIG_MODE_STORAGE_KEY, value)
    if (value === 'AUTO') {
      scheduleAutoAdapt()
    }
    if (value === 'PROVIDER') {
      syncProviderFields()
    }
    if (value === 'MANUAL') {
      syncManualFieldsFromAuto()
    }
  },
)

watch(
  () => form.providerCode,
  (value) => {
    if (value) {
      localStorage.setItem(AI_PROVIDER_CODE_STORAGE_KEY, value)
    } else {
      localStorage.removeItem(AI_PROVIDER_CODE_STORAGE_KEY)
    }
    if (form.configMode === 'PROVIDER') {
      syncProviderFields()
    }
  },
)

watch(
  () => form.customApiKey,
  () => {
    if (form.configMode === 'AUTO') {
      scheduleAutoAdapt()
    }
  },
)

// 监听API Key来源变化
watch(
  () => form.apiKeySource,
  (value) => {
    // 当切换到"项目提供"时，重置配置模式为AUTO并清除适配结果
    if (value === 'SYSTEM') {
      form.configMode = 'AUTO'
      adaptResult.value = null
      testConnectionResult.value = null
    }

    // 当切换到"我自己提供"时，如果之前是系统模式，触发自动适配
    if (value === 'CUSTOM' && form.configMode === 'AUTO') {
      scheduleAutoAdapt()
    }
  },
)

watch(
  () => form.apiBaseUrl,
  (value) => {
    if (value.trim()) {
      localStorage.setItem(AI_BASE_URL_STORAGE_KEY, value.trim())
      return
    }
    localStorage.removeItem(AI_BASE_URL_STORAGE_KEY)
  },
)

watch(
  () => form.model,
  (value) => {
    if (value.trim()) {
      localStorage.setItem(AI_MODEL_STORAGE_KEY, value.trim())
      return
    }
    localStorage.removeItem(AI_MODEL_STORAGE_KEY)
  },
)

async function fetchWordBanks() {
  wordBankLoading.value = true
  try {
    const result = await getAiReadingWordBanks(selectedLanguage.value)
    wordBanks.value = result ?? []
    if (!form.wordBankId && wordBanks.value.length) {
      form.wordBankId = wordBanks.value[0].id
      return
    }
    if (form.wordBankId && !wordBanks.value.some((item) => item.id === form.wordBankId)) {
      form.wordBankId = wordBanks.value[0]?.id
    }
  } finally {
    wordBankLoading.value = false
  }
}

async function fetchProviderOptions() {
  const result = await getAiProviderOptions()
  providerOptions.value = result ?? []
  if (!form.providerCode && providerOptions.value.length) {
    const recommendedProvider = providerOptions.value.find((item) => item.recommended) ?? providerOptions.value[0]
    form.providerCode = recommendedProvider.providerCode
  }
}

async function fetchHistory(current = historyPage.value.current, size = historyPage.value.size, preserveSelection = true) {
  if (isGuest.value) {
    historyPage.value = {
      current: 1,
      size: HISTORY_PAGE_SIZE,
      total: 0,
      records: [],
    }
    return
  }

  historyLoading.value = true
  try {
    const result = await getAiArticleHistory({ current, size })
    const pageData = result ?? {
      current,
      size,
      total: 0,
      records: [],
    }
    historyPage.value = pageData

    if (!pageData.records.length) {
      if (pageData.total === 0) {
        activeHistoryId.value = null
        articleResult.value = null
      }
      return
    }

    const hasActiveItem = activeHistoryId.value
      ? pageData.records.some((item) => item.id === activeHistoryId.value)
      : false

    if (!preserveSelection || !activeHistoryId.value || !hasActiveItem) {
      await loadArticleDetail(pageData.records[0].id)
    }
  } finally {
    historyLoading.value = false
  }
}

async function fetchQuota() {
  if (isGuest.value) {
    quota.value = null
    return
  }

  quotaLoading.value = true
  try {
    const result = await getAiArticleQuota()
    quota.value = result ?? null
    const data = result
    if (data) {
      if (!form.apiBaseUrl && data.defaultBaseUrl) {
        form.apiBaseUrl = data.defaultBaseUrl
      }
      if (!form.model && data.defaultModel) {
        form.model = data.defaultModel
      }
      if (!data.systemApiKeyConfigured && form.apiKeySource === 'SYSTEM') {
        form.apiKeySource = 'CUSTOM'
      }
    }
    if (form.configMode === 'AUTO') {
      await runAutoAdapt()
    } else if (form.configMode === 'PROVIDER') {
      syncProviderFields()
    }
  } finally {
    quotaLoading.value = false
  }
}

async function handleGenerate() {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持 AI 阅读强化功能')
    return
  }

  if (!formRef.value) {
    return
  }

  const valid = await formRef.value.validate().catch(() => false)
  if (!valid || !form.wordBankId) {
    return
  }

  if (form.apiKeySource === 'SYSTEM' && !systemApiKeyConfigured.value) {
    ElMessage.warning('项目提供的 API Key 当前未配置，请切换为“我自己提供”')
    return
  }

  if (form.apiKeySource === 'CUSTOM' && !form.customApiKey.trim()) {
    ElMessage.warning('请输入你自己的 API Key')
    return
  }

  if (isManualConfig.value) {
    if (!form.apiBaseUrl.trim()) {
      ElMessage.warning('请输入 AI 服务地址')
      return
    }

    if (!form.model.trim()) {
      ElMessage.warning('请输入模型名称')
      return
    }
  }

  if (isProviderConfig.value && !form.providerCode) {
    ElMessage.warning('请选择服务商')
    return
  }

  generating.value = true
  resetStreamingState()
  articleResult.value = null
  activeHistoryId.value = null
  translation.value = ''
  translationArticleId.value = null
  showTranslation.value = false
  generatingWordBankName.value = wordBanks.value.find((item) => item.id === form.wordBankId)?.name || '当前词库'
  streamProgress.value = {
    stage: 'PREPARING',
    message: '准备开始生成定制文章',
    progress: 0,
  }
  
  generateAbortController?.abort()
  generateAbortController = new AbortController()
  const currentSignal = generateAbortController.signal
  
  try {
    const result = await generateAiArticleStream(
      {
        wordBankId: form.wordBankId,
        theme: form.theme.trim() || undefined,
        difficulty: form.difficulty,
        length: form.length,
        apiKeySource: form.apiKeySource,
        customApiKey: form.apiKeySource === 'CUSTOM' ? form.customApiKey.trim() : undefined,
        configMode: form.configMode,
        providerCode: isProviderConfig.value ? form.providerCode : undefined,
        apiBaseUrl: isManualConfig.value ? form.apiBaseUrl.trim() : undefined,
        model: isManualConfig.value ? form.model.trim() : undefined,
      },
      {
        onProgress: (event) => {
          streamProgress.value = event
        },
        onChunk: (content) => {
          streamingContent.value += stripHtmlTags(content)
        },
        onComplete: (generated) => {
          const generatedArticle = toHistoryDetail(generated)
          articleResult.value = generatedArticle
          activeHistoryId.value = generatedArticle.id
          quota.value = generated.quota
          translation.value = ''
          translationArticleId.value = null
          showTranslation.value = false
          streamingContent.value = ''
          streamProgress.value = {
            stage: 'DONE',
            message: '文章生成完成，正在同步历史记录',
            progress: 100,
          }
        },
        onAbort: () => {
          streamProgress.value = {
            stage: 'ERROR',
            message: '生成请求已取消',
            progress: 0,
          }
        },
      },
      currentSignal,
    )
    if (!articleResult.value) {
      const generatedArticle = toHistoryDetail(result)
      articleResult.value = generatedArticle
      activeHistoryId.value = generatedArticle.id
      quota.value = result.quota
      translation.value = ''
      translationArticleId.value = null
      showTranslation.value = false
    }
    await fetchHistory(1, HISTORY_PAGE_SIZE, true)
    resetStreamingState()
    ElMessage.success(`文章生成成功，已保存到历史记录，今日剩余 ${result.quota.remainingCount} 次`)
  } catch (error) {
    streamingError.value = error instanceof Error ? error.message : '文章生成失败，请稍后重试'
    if (!streamProgress.value) {
      streamProgress.value = {
        stage: 'ERROR',
        message: streamingError.value,
        progress: 0,
      }
    }
    ElMessage.error(streamingError.value)
  } finally {
    generating.value = false
  }
}

async function loadArticleDetail(id: number) {
  articleLoading.value = true
  try {
    resetStreamingState()
    translation.value = ''
    showTranslation.value = false
    const result = await getAiArticleDetail(id)
    articleResult.value = result
    activeHistoryId.value = result?.id ?? null
    if (result?.translation) {
      translation.value = result.translation
      translationArticleId.value = result.id
    } else {
      translationArticleId.value = null
    }
  } finally {
    articleLoading.value = false
  }
}

function handleSelectHistory(item: AiArticleHistoryItem) {
  if (activeHistoryId.value === item.id && articleResult.value?.id === item.id) {
    return
  }
  void loadArticleDetail(item.id)
}

async function handleDeleteHistory(item: AiArticleHistoryItem) {
  try {
    await ElMessageBox.confirm(`确定删除主题为“${item.theme}”的历史记录吗？删除后不可恢复。`, '删除历史记录', {
      type: 'warning',
      confirmButtonText: '删除',
      cancelButtonText: '取消',
    })
  } catch {
    return
  }

  historyDeletingId.value = item.id
  try {
    await deleteAiArticle(item.id)
    const deletedActive = activeHistoryId.value === item.id
    if (deletedActive) {
      activeHistoryId.value = null
      articleResult.value = null
    }

    const targetPage =
      historyPage.value.current > 1 && historyPage.value.records.length === 1
        ? historyPage.value.current - 1
        : historyPage.value.current

    await fetchHistory(targetPage, historyPage.value.size, !deletedActive)
    ElMessage.success('历史记录已删除')
  } finally {
    historyDeletingId.value = null
  }
}

async function ensureCustomWordBanks(force = false) {
  if (addWordOptionsLoading.value || (!force && customWordBanks.value.length)) {
    return
  }

  addWordOptionsLoading.value = true
  try {
    const result = await getMyWordBanks({ current: 1, size: 100 })
    const filteredByLanguage = (result?.records ?? []).filter(
      (item) => !item.language || item.language === selectedLanguage.value,
    )
    customWordBanks.value = filteredByLanguage
  } finally {
    addWordOptionsLoading.value = false
  }
}

function findHighlightWord(wordId: number) {
  return articleResult.value?.highlightWords.find((item) => item.wordId === wordId) ?? null
}

async function openAddWordDialog(word: AiArticleHighlightWord) {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持加入自定义词库')
    return
  }

  selectedHighlightWord.value = word
  addWordForm.wordBankId = undefined
  addWordDialogVisible.value = true
  await ensureCustomWordBanks()

  if (!customWordBanks.value.length) {
    return
  }

  const defaultWordBankId = customWordBanks.value.some((item) => item.id === articleResult.value?.wordBankId)
    ? articleResult.value?.wordBankId
    : customWordBanks.value[0].id
  addWordForm.wordBankId = defaultWordBankId
}

function handleHighlightWordClick(word: AiArticleHighlightWord) {
  void openAddWordDialog(word)
}

function handleArticleWordClick(event: MouseEvent) {
  const target = event.target as HTMLElement | null
  const mark = target?.closest('mark.ai-word-highlight') as HTMLElement | null
  if (!mark) {
    return
  }

  const wordId = Number(mark.dataset.wordId)
  if (!wordId) {
    return
  }

  const word = findHighlightWord(wordId)
  if (!word) {
    return
  }

  void openAddWordDialog(word)
}

function handleArticleMouseOver(event: MouseEvent) {
  const target = event.target as HTMLElement | null
  const mark = target?.closest('mark.ai-word-highlight') as HTMLElement | null
  if (!mark) {
    return
  }

  const chinese = mark.dataset.chinese
  const english = mark.dataset.english
  if (!chinese || !english) {
    return
  }

  const rect = mark.getBoundingClientRect()
  wordTooltip.value = {
    visible: true,
    loading: false,
    english,
    chinese,
    phonetic: '',
    x: rect.left + rect.width / 2,
    y: rect.top - 8,
  }
}

function handleArticleMouseOut(event: MouseEvent) {
  const target = event.target as HTMLElement | null
  const mark = target?.closest('mark.ai-word-highlight') as HTMLElement | null
  if (!mark) {
    return
  }

  const relatedTarget = event.relatedTarget as HTMLElement | null
  if (relatedTarget?.closest('.ai-word-tooltip')) {
    return
  }

  wordTooltip.value.visible = false
}

function handleArticleMouseUp(event: MouseEvent) {
  const selection = window.getSelection()
  const selectedText = selection?.toString().trim()
  if (!selectedText || selectedText.split(/\s+/).length > 3) {
    return
  }

  const target = event.target as HTMLElement | null
  const articleContent = target?.closest('.ai-article-content') as HTMLElement | null
  if (!articleContent) {
    return
  }

  const word = selectedText.trim()
  const normalizedWord = word.toLowerCase()

  const range = selection?.getRangeAt(0)
  if (!range) {
    return
  }
  const rect = range.getBoundingClientRect()

  const foundWord = displayHighlightWords.value.find(
    (item) => item.english.toLowerCase() === normalizedWord,
  )

  if (foundWord) {
    wordTooltip.value = {
      visible: true,
      loading: false,
      english: foundWord.english,
      chinese: foundWord.chinese,
      phonetic: '',
      x: rect.left + rect.width / 2,
      y: rect.bottom + 12,
    }
    return
  }

  if (wordLookupTimer) {
    window.clearTimeout(wordLookupTimer)
  }

  if (currentLookupWord === normalizedWord && wordTooltip.value.visible) {
    return
  }

  wordTooltip.value = {
    visible: true,
    loading: true,
    english: word,
    chinese: '查询中...',
    phonetic: '',
    x: rect.left + rect.width / 2,
    y: rect.bottom + 12,
  }

  currentLookupWord = normalizedWord

  wordLookupTimer = window.setTimeout(async () => {
    try {
      const result = await lookupWordTranslation({
        word,
        language: selectedLanguage.value,
        customApiKey: form.apiKeySource === 'CUSTOM' ? form.customApiKey.trim() : undefined,
        apiBaseUrl: isManualConfig.value ? form.apiBaseUrl.trim() : undefined,
        model: isManualConfig.value ? form.model.trim() : undefined,
      })

      const data = result
      if (data && currentLookupWord === normalizedWord) {
        wordTooltip.value = {
          visible: true,
          loading: false,
          english: data.english || word,
          chinese: data.chinese || '未找到释义',
          phonetic: data.phonetic || '',
          x: rect.left + rect.width / 2,
          y: rect.bottom + 12,
        }
      }
    } catch {
      if (currentLookupWord === normalizedWord) {
        wordTooltip.value = {
          visible: true,
          loading: false,
          english: word,
          chinese: '查询失败，请重试',
          phonetic: '',
          x: rect.left + rect.width / 2,
          y: rect.bottom + 12,
        }
      }
    }
  }, 300)
}

function hideWordTooltip() {
  wordTooltip.value.visible = false
}

async function handleSubmitAddWord() {
  if (!selectedHighlightWord.value) {
    return
  }
  if (!addWordForm.wordBankId) {
    ElMessage.warning('请选择要加入的词库')
    return
  }

  addWordSubmitting.value = true
  try {
    const result = await addWordToMyWordBank(addWordForm.wordBankId, {
      english: selectedHighlightWord.value.english,
      chinese: selectedHighlightWord.value.chinese,
    })
    const updatedWordBank = result
    if (updatedWordBank) {
      const customWordBankIndex = customWordBanks.value.findIndex((item) => item.id === updatedWordBank.id)
      if (customWordBankIndex >= 0) {
        customWordBanks.value[customWordBankIndex] = {
          ...customWordBanks.value[customWordBankIndex],
          ...updatedWordBank,
        }
      }

      const aiWordBank = wordBanks.value.find((item) => item.id === updatedWordBank.id)
      if (aiWordBank && typeof updatedWordBank.wordCount === 'number') {
        aiWordBank.wordCount = updatedWordBank.wordCount
      }
    }

    const bankName = selectedAddWordBank.value?.name || '目标词库'
    const english = selectedHighlightWord.value.english
    addWordDialogVisible.value = false
    ElMessage.success(`已将 ${english} 加入“${bankName}”`)
  } catch (error) {
    ElMessage.error(error instanceof Error ? error.message : '加入词库失败，请稍后重试')
  } finally {
    addWordSubmitting.value = false
  }
}

function handleAddWordDialogClosed() {
  selectedHighlightWord.value = null
  addWordForm.wordBankId = undefined
}

function handleHistoryPageChange(page: number) {
  void fetchHistory(page, historyPage.value.size, false)
}

function formatTime(value?: string) {
  return value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-'
}

function copyArticle() {
  if (!displayArticleContent.value) {
    return
  }

  navigator.clipboard
    .writeText(displayArticleContent.value)
    .then(() => ElMessage.success('文章内容已复制'))
    .catch(() => ElMessage.warning('复制失败，请手动选择内容复制'))
}

function renderHighlightedArticle(content: string, words: AiArticleHighlightWord[]) {
  if (!content) {
    return ''
  }

  const tokens = [...words].sort((a, b) => b.english.length - a.english.length)
  const paragraphs = content.split(/\n{2,}/).map((item) => item.trim()).filter(Boolean)

  return paragraphs
    .map((paragraph) => {
      let html = escapeHtml(stripHtmlTags(paragraph))
      for (const word of tokens) {
        const escapedWord = escapeRegExp(word.english)
        const matcher = new RegExp(`\\b(${escapedWord})\\b`, 'gi')
        html = html.replace(
          matcher,
          `<mark class="ai-word-highlight" data-word-id="${word.wordId}" data-chinese="${escapeHtml(word.chinese)}" data-english="${escapeHtml(word.english)}" title="点击加入自定义词库">$1</mark>`,
        )
      }
      return `<p>${html}</p>`
    })
    .join('')
}

function stripHtmlTags(value: string): string {
  if (!value) return ''
  
  let cleaned = value
  cleaned = cleaned.replaceAll(/<mark[^>]*>[\s\S]*?<\/mark>/gi, (match) => {
    return match.replaceAll(/<[^>]+>/g, '')
  })
  cleaned = cleaned.replaceAll(/<[^>]+>/g, '')
  cleaned = cleaned.replaceAll(/&lt;/gi, '<')
  cleaned = cleaned.replaceAll(/&gt;/gi, '>')
  cleaned = cleaned.replaceAll(/&amp;/gi, '&')
  cleaned = cleaned.replaceAll(/&quot;/gi, '"')
  cleaned = cleaned.replaceAll(/&#39;/gi, "'")
  cleaned = cleaned.replaceAll(/\s{2,}/g, ' ')
  
  return cleaned.trim()
}

function resolveAutoConfig() {
  if (adaptResult.value) {
    return {
      label: adaptResult.value.providerName,
      baseUrl: adaptResult.value.baseUrl,
      model: adaptResult.value.defaultModel,
      reason: adaptResult.value.reason,
    }
  }

  if (form.apiKeySource === 'SYSTEM') {
    return {
      label: '项目默认配置',
      baseUrl: quota.value?.defaultBaseUrl || form.apiBaseUrl || '未配置',
      model: quota.value?.defaultModel || form.model || '未配置',
      reason: '使用项目当前默认 AI 配置',
    }
  }

  return {
    label: '按项目默认 OpenAI 兼容配置处理',
    baseUrl: quota.value?.defaultBaseUrl || form.apiBaseUrl || 'https://api.openai.com/v1',
    model: quota.value?.defaultModel || form.model || 'gpt-4o-mini',
    reason: '等待自动适配结果',
  }
}

function syncManualFieldsFromAuto() {
  form.apiBaseUrl = autoResolvedConfig.value.baseUrl === '未配置' ? '' : autoResolvedConfig.value.baseUrl
  form.model = autoResolvedConfig.value.model === '未配置' ? '' : autoResolvedConfig.value.model
}

function syncProviderFields() {
  if (!activeProvider.value) {
    return
  }
  form.apiBaseUrl = activeProvider.value.baseUrl
  form.model = activeProvider.value.defaultModel
}

function scheduleAutoAdapt() {
  if (adaptTimer) {
    window.clearTimeout(adaptTimer)
  }
  adaptTimer = window.setTimeout(() => {
    void runAutoAdapt()
  }, 400)
}

async function runAutoAdapt() {
  if (isGuest.value || form.configMode !== 'AUTO') {
    return
  }

  if (form.apiKeySource === 'CUSTOM' && !form.customApiKey.trim()) {
    adaptResult.value = null
    return
  }

  adapting.value = true
  try {
    const result = await adaptAiApiKey({
      apiKeySource: form.apiKeySource,
      customApiKey: form.apiKeySource === 'CUSTOM' ? form.customApiKey.trim() : undefined,
    })
    adaptResult.value = result
    syncManualFieldsFromAuto()
  } catch {
    adaptResult.value = null
  } finally {
    adapting.value = false
  }
}

async function handleTestConnection() {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持测试连接')
    return
  }

  if (!form.customApiKey.trim()) {
    ElMessage.warning('请先输入 API Key')
    return
  }

  testingConnection.value = true
  testConnectionResult.value = null
  try {
    const result = await testAiConnection({
      apiKey: form.customApiKey.trim(),
      baseUrl: form.apiBaseUrl.trim() || undefined,
      model: form.model.trim() || undefined,
    })
    testConnectionResult.value = result

    if (result.success) {
      ElMessage.success(`连接成功！识别到服务商：${result.providerName}（${result.responseTimeMs}ms）`)
      if (!form.apiBaseUrl.trim()) {
        form.apiBaseUrl = result.detectedBaseUrl
      }
      if (!form.model.trim()) {
        form.model = result.detectedModel
      }
    } else {
      ElMessage.error(`连接失败：${result.message}`)
    }
  } catch (error) {
    testConnectionResult.value = null
    ElMessage.error(error instanceof Error ? error.message : '测试连接失败，请稍后重试')
  } finally {
    testingConnection.value = false
  }
}

function escapeHtml(value: string) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;')
}

function escapeRegExp(value: string) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

function toHistoryDetail(article: AiArticleGenerateResponse): AiArticleHistoryDetail {
  return {
    id: article.logId,
    wordBankId: article.wordBankId,
    wordBankName: wordBanks.value.find((item) => item.id === article.wordBankId)?.name || '当前词库',
    theme: article.theme,
    difficulty: article.difficulty,
    length: article.length,
    duration: article.duration,
    createdAt: article.generatedAt,
    content: article.content,
    highlightWords: article.highlightWords,
  }
}

function resetStreamingState() {
  streamProgress.value = null
  streamingContent.value = ''
  streamingError.value = ''
}

async function handleTranslate() {
  if (!articleResult.value || translating.value) {
    return
  }

  if (isGuest.value) {
    ElMessage.warning('游客模式不支持翻译功能')
    return
  }

  if (translation.value && translationArticleId.value === articleResult.value.id) {
    showTranslation.value = !showTranslation.value
    return
  }

  translating.value = true
  try {
    const result = await translateAiArticle(articleResult.value.id, {
      customApiKey: form.apiKeySource === 'CUSTOM' ? form.customApiKey.trim() : undefined,
      apiBaseUrl: isManualConfig.value ? form.apiBaseUrl.trim() : undefined,
      model: isManualConfig.value ? form.model.trim() : undefined,
    })
    translation.value = result
    translationArticleId.value = articleResult.value.id
    showTranslation.value = true
    ElMessage.success('翻译完成')
  } catch (error) {
    ElMessage.error(error instanceof Error ? error.message : '翻译失败，请稍后重试')
  } finally {
    translating.value = false
  }
}
</script>

<template>
  <div class="ai-reading-page">
    <div class="ai-reading-page__header">
      <div>
        <h1>AI 阅读强化</h1>
        <p>选择词库、主题、难度和长度，生成包含目标词汇的英文文章，并自动记录本次生成日志。</p>
      </div>
      <div class="ai-reading-page__actions">
        <el-button @click="router.push('/')">返回首页</el-button>
        <el-button plain type="primary" @click="router.push('/study')">今日学习</el-button>
        <el-button plain @click="router.push('/wordbanks')">我的词库</el-button>
      </div>
    </div>

    <el-alert
      v-if="isGuest"
      title="游客模式不支持 AI 阅读强化，请注册或登录正式账号后使用。"
      type="warning"
      :closable="false"
      show-icon
      class="ai-reading-page__alert"
    />

    <div class="ai-reading-layout" v-loading="loading">
      <el-card class="ai-reading-sidebar" shadow="never">
        <template #header>
          <div class="ai-card-header">
            <span>生成设置</span>
            <el-tag v-if="!isGuest" :type="systemApiKeyConfigured ? 'success' : 'warning'" effect="plain">
              {{ systemApiKeyConfigured ? '项目 Key 已配置' : '项目 Key 未配置' }}
            </el-tag>
          </div>
        </template>

        <el-skeleton :loading="wordBankLoading || quotaLoading" animated :rows="6">
          <template #default>
            <el-form ref="formRef" :model="form" :rules="formRules" label-position="top">
              <el-form-item label="学习语种">
                <el-select v-model="selectedLanguage" :disabled="isGuest">
                  <el-option v-for="item in languageOptions" :key="item.value" :label="item.label" :value="item.value" />
                </el-select>
              </el-form-item>

              <el-form-item label="词库" prop="wordBankId">
                <el-select
                  v-model="form.wordBankId"
                  placeholder="请选择词库"
                  :disabled="isGuest || !wordBanks.length"
                >
                  <el-option
                    v-for="item in wordBanks"
                    :key="item.id"
                    :label="`${item.name}（${item.wordCount}词）`"
                    :value="item.id"
                  />
                </el-select>
              </el-form-item>

              <el-form-item label="主题">
                <el-input
                  v-model="form.theme"
                  maxlength="50"
                  show-word-limit
                  placeholder="可选，例如：校园、科技、旅行、职场"
                  :disabled="isGuest"
                />
              </el-form-item>

              <el-form-item label="API Key 来源">
                <el-radio-group v-model="form.apiKeySource" :disabled="isGuest">
                  <el-radio-button value="SYSTEM" :disabled="!canUseSystemApiKey">项目提供</el-radio-button>
                  <el-radio-button value="CUSTOM">我自己提供</el-radio-button>
                </el-radio-group>
                <div class="ai-reading-tip">
                  {{
                    form.apiKeySource === 'SYSTEM'
                      ? '使用项目后端配置的 API Key，不向前端暴露真实值。'
                      : '你的 API Key 仅保存在当前浏览器本地，并在生成时随本次请求发送。'
                  }}
                </div>
              </el-form-item>

              <el-form-item v-if="form.apiKeySource === 'CUSTOM'" label="自定义 API Key">
                <el-input
                  v-model="form.customApiKey"
                  type="password"
                  show-password
                  placeholder="请输入你自己的 API Key"
                  :disabled="isGuest"
                >
                  <template #append>
                    <el-button
                      :loading="testingConnection"
                      :disabled="isGuest || !form.customApiKey.trim()"
                      @click="handleTestConnection"
                    >
                      测试连接
                    </el-button>
                  </template>
                </el-input>
                <div class="ai-reading-tip" v-if="!isGuest">
                  输入 API Key 后可点击"测试连接"验证有效性并自动识别服务商
                </div>

                <!-- 测试连接结果显示 - 紧贴在自定义API Key输入框下方 -->
                <el-alert
                  v-if="testConnectionResult"
                  :title="testConnectionResult.success ? '测试连接成功' : '测试连接失败'"
                  :type="testConnectionResult.success ? 'success' : 'error'"
                  :closable="true"
                  show-icon
                  class="ai-reading-inline-alert"
                  @close="testConnectionResult = null"
                >
                  <template #default>
                    <div class="ai-auto-config">
                      <span>服务商：{{ testConnectionResult.providerName }}</span>
                      <span>地址：{{ testConnectionResult.detectedBaseUrl }}</span>
                      <span>模型：{{ testConnectionResult.detectedModel }}</span>
                      <span v-if="testConnectionResult.responseTimeMs">响应时间：{{ testConnectionResult.responseTimeMs }}ms</span>
                      <span>{{ testConnectionResult.message }}</span>
                    </div>
                  </template>
                </el-alert>
              </el-form-item>

              <el-form-item v-if="form.apiKeySource === 'CUSTOM'" label="配置方式">
                <el-radio-group v-model="form.configMode" :disabled="isGuest">
                  <el-radio-button value="AUTO">自动适配</el-radio-button>
                  <el-radio-button value="PROVIDER">服务商选择</el-radio-button>
                  <el-radio-button value="MANUAL">手动配置</el-radio-button>
                </el-radio-group>
                <div class="ai-reading-tip">
                  {{
                    form.configMode === 'AUTO'
                      ? '推荐给普通客户，只输入 API Key，系统会自动匹配常见服务商并回退到项目默认配置。'
                      : form.configMode === 'PROVIDER'
                        ? '适合大多数客服场景，直接选择服务商，系统自动填充地址和默认模型。'
                        : '保留给懂技术的客户或客服，可手动指定服务地址与模型。'
                  }}
                </div>
              </el-form-item>

              <!-- 项目提供API Key时的系统配置提示 -->
              <el-alert
                v-if="form.apiKeySource === 'SYSTEM' && systemApiKeyConfigured"
                title="当前使用项目提供的 API Key"
                type="success"
                :closable="false"
                show-icon
                class="ai-reading-inline-alert"
              >
                <template #default>
                  <div class="ai-auto-config">
                    <span>地址：{{ quota?.defaultBaseUrl || '已由管理员配置' }}</span>
                    <span>模型：{{ quota?.defaultModel || '已由管理员配置' }}</span>
                    <span>说明：使用项目后端统一配置的 AI 服务，无需手动设置</span>
                  </div>
                </template>
              </el-alert>

              <el-alert
                v-if="form.configMode === 'AUTO' && form.apiKeySource === 'CUSTOM'"
                :title="`自动适配结果：${autoResolvedConfig.label}`"
                type="info"
                :closable="false"
                show-icon
                class="ai-reading-inline-alert"
              >
                <template #default>
                  <div class="ai-auto-config">
                    <span>地址：{{ autoResolvedConfig.baseUrl }}</span>
                    <span>模型：{{ autoResolvedConfig.model }}</span>
                    <span>{{ autoResolvedConfig.reason }}</span>
                  </div>
                </template>
              </el-alert>

              <el-alert
                v-if="form.configMode === 'AUTO' && form.apiKeySource === 'CUSTOM' && adapting"
                title="正在根据 API Key 自动适配服务商..."
                type="info"
                :closable="false"
                show-icon
                class="ai-reading-inline-alert"
              />

              <el-form-item v-if="isProviderConfig && form.apiKeySource === 'CUSTOM'" label="服务商选择">
                <div class="ai-provider-presets">
                  <button
                    v-for="item in providerOptions"
                    :key="item.providerCode"
                    type="button"
                    class="ai-provider-card"
                    :class="{ 'ai-provider-card--active': form.providerCode === item.providerCode }"
                    @click="form.providerCode = item.providerCode"
                  >
                    <strong>{{ item.providerName }}</strong>
                    <span>{{ item.defaultModel }}</span>
                    <em>{{ item.baseUrl }}</em>
                  </button>
                </div>
              </el-form-item>

              <el-alert
                v-if="isProviderConfig && form.apiKeySource === 'CUSTOM' && activeProvider"
                :title="`当前服务商：${activeProvider.providerName}`"
                type="success"
                :closable="false"
                show-icon
                class="ai-reading-inline-alert"
              >
                <template #default>
                  <div class="ai-auto-config">
                    <span>地址：{{ activeProvider.baseUrl }}</span>
                    <span>模型：{{ activeProvider.defaultModel }}</span>
                  </div>
                </template>
              </el-alert>

              <el-form-item v-if="isManualConfig && form.apiKeySource === 'CUSTOM'" label="服务商预设">
                <div class="ai-provider-presets">
                  <button
                    v-for="item in providerOptions"
                    :key="item.providerCode"
                    type="button"
                    class="ai-provider-card"
                    @click="
                      form.providerCode = item.providerCode;
                      syncProviderFields()
                    "
                  >
                    <strong>{{ item.providerName }}</strong>
                    <span>{{ item.defaultModel }}</span>
                    <em>{{ item.baseUrl }}</em>
                  </button>
                </div>
              </el-form-item>

              <el-form-item v-if="isManualConfig && form.apiKeySource === 'CUSTOM'" label="AI 服务地址">
                <el-input
                  v-model="form.apiBaseUrl"
                  placeholder="例如：https://api.openai.com/v1"
                  :disabled="isGuest"
                />
              </el-form-item>

              <el-form-item v-if="isManualConfig && form.apiKeySource === 'CUSTOM'" label="模型名称">
                <el-input
                  v-model="form.model"
                  placeholder="例如：gpt-4o-mini / glm-4-flash"
                  :disabled="isGuest"
                />
              </el-form-item>

              <el-form-item label="难度">
                <el-radio-group v-model="form.difficulty" :disabled="isGuest">
                  <el-radio-button v-for="item in difficultyOptions" :key="item.value" :value="item.value">
                    {{ item.label }}
                  </el-radio-button>
                </el-radio-group>
                <div class="ai-reading-tip">
                  {{ difficultyOptions.find((item) => item.value === form.difficulty)?.description }}
                </div>
              </el-form-item>

              <el-form-item label="长度">
                <el-radio-group v-model="form.length" :disabled="isGuest">
                  <el-radio-button v-for="item in lengthOptions" :key="item.value" :value="item.value">
                    {{ item.label }}
                  </el-radio-button>
                </el-radio-group>
                <div class="ai-reading-tip">
                  {{ lengthOptions.find((item) => item.value === form.length)?.description }}
                </div>
              </el-form-item>

              <el-button
                type="primary"
                size="large"
                class="ai-reading-generate"
                :loading="generating"
                :disabled="
                  isGuest ||
                  !wordBanks.length ||
                  remainingQuota <= 0 ||
                  (form.apiKeySource === 'SYSTEM' && !systemApiKeyConfigured) ||
                  (form.apiKeySource === 'CUSTOM' && !form.customApiKey.trim()) ||
                  (isManualConfig && !form.apiBaseUrl.trim()) ||
                  (isManualConfig && !form.model.trim())
                "
                @click="handleGenerate"
              >
                生成文章
              </el-button>
            </el-form>

            <div class="ai-reading-quota" v-if="!isGuest && quota">
              <div>
                <span>今日总配额</span>
                <strong>{{ quota.totalQuota }}</strong>
              </div>
              <div>
                <span>已使用</span>
                <strong>{{ quota.usedCount }}</strong>
              </div>
              <div>
                <span>剩余</span>
                <strong>{{ quota.remainingCount }}</strong>
              </div>
            </div>

            <el-alert
              v-if="!isGuest && !systemApiKeyConfigured"
              title="当前项目侧未配置 API Key，请选择“我自己提供”后再生成。"
              type="warning"
              :closable="false"
              show-icon
              class="ai-reading-inline-alert"
            />

            <el-empty
              v-if="!wordBanks.length"
              description="当前没有可用词库，请先创建词库或学习公开词库。"
            />
          </template>
        </el-skeleton>
      </el-card>

      <div class="ai-reading-main">
        <el-card class="ai-reading-result" shadow="never" v-loading="articleLoading">
          <template #header>
            <div class="ai-card-header">
              <span>生成结果</span>
              <div class="ai-reading-result__actions">
                <el-button text :disabled="!displayArticleContent" @click="copyArticle">复制文章</el-button>
                <el-button
                  text
                  type="primary"
                  :disabled="!articleResult || translating"
                  :loading="translating"
                  @click="handleTranslate"
                >
                  {{ showTranslation ? '隐藏翻译' : (translation ? '显示翻译' : '中文翻译') }}
                </el-button>
              </div>
            </div>
          </template>

          <el-alert
            v-if="streamingError"
            :title="streamingError"
            type="error"
            :closable="false"
            show-icon
            class="ai-reading-inline-alert"
          />

          <div v-if="streamProgress" class="ai-generation-progress">
            <div class="ai-generation-progress__header">
              <span>{{ streamProgress.message }}</span>
              <strong>{{ streamProgress.progress }}%</strong>
            </div>
            <el-progress :percentage="streamProgress.progress" :stroke-width="10" />
            <div class="ai-reading-tip">
              本次参数：{{ generatingWordBankName || '当前词库' }} / {{ form.theme.trim() || 'General' }} / {{ form.difficulty }} /
              {{ form.length }}
            </div>
          </div>

          <el-empty
            v-if="!articleResult && !displayArticleContent && !streamProgress"
            description="生成成功后，文章会显示在这里，并自动高亮词库中的目标单词。"
          />

          <template v-else>
            <div class="ai-meta">
              <el-tag v-if="articleResult" effect="plain">日志 ID：{{ articleResult.id }}</el-tag>
              <el-tag effect="plain">词库：{{ articleResult?.wordBankName || generatingWordBankName || '当前词库' }}</el-tag>
              <el-tag effect="plain" type="success">主题：{{ articleResult?.theme || form.theme.trim() || 'General' }}</el-tag>
              <el-tag effect="plain" type="warning">难度：{{ articleResult?.difficulty || form.difficulty }}</el-tag>
              <el-tag effect="plain" type="info">长度：{{ articleResult?.length || form.length }}</el-tag>
              <el-tag v-if="articleResult" effect="plain">耗时：{{ articleResult.duration }}ms</el-tag>
              <el-tag v-else effect="plain" type="primary">状态：生成中</el-tag>
            </div>

            <div v-if="articleResult?.highlightWords?.length" class="ai-highlight-words">
              <span>高亮词汇</span>
              <el-tag
                v-for="item in articleResult.highlightWords"
                :key="item.wordId"
                type="warning"
                effect="dark"
                class="ai-highlight-tag"
                @click="handleHighlightWordClick(item)"
              >
                {{ item.english }} / {{ item.chinese }}
              </el-tag>
              <span class="ai-highlight-words__tip">点击高亮词或正文中的高亮单词，可加入指定自定义词库。</span>
            </div>

            <div
              class="ai-article-content"
              v-html="highlightedArticleHtml"
              @click="handleArticleWordClick"
              @mouseover="handleArticleMouseOver"
              @mouseout="handleArticleMouseOut"
              @mouseup="handleArticleMouseUp"
            ></div>

            <Teleport to="body">
              <Transition name="tooltip-fade">
                <div
                  v-if="wordTooltip.visible"
                  class="ai-word-tooltip"
                  :class="{ 'ai-word-tooltip--loading': wordTooltip.loading }"
                  :style="{
                    left: wordTooltip.x + 'px',
                    top: wordTooltip.y + 'px',
                  }"
                  @mouseenter="() => {}"
                  @mouseleave="hideWordTooltip"
                >
                  <div class="ai-word-tooltip__english">
                    {{ wordTooltip.english }}
                    <span v-if="wordTooltip.phonetic" class="ai-word-tooltip__phonetic">{{ wordTooltip.phonetic }}</span>
                  </div>
                  <div class="ai-word-tooltip__chinese">
                    <template v-if="wordTooltip.loading">
                      <el-icon class="is-loading" style="margin-right: 6px; vertical-align: middle"><Loading /></el-icon>
                      {{ wordTooltip.chinese }}
                    </template>
                    <template v-else>{{ wordTooltip.chinese }}</template>
                  </div>
                </div>
              </Transition>
            </Teleport>

            <div v-if="showTranslation && translation" class="ai-translation-content">
              <div class="ai-translation-header">
                <span>中文翻译</span>
              </div>
              <div class="ai-translation-text">{{ translation }}</div>
            </div>

            <div class="ai-reading-note">
              <span>{{ articleResult ? '已保存到历史记录' : '正在实时写入文章内容' }}</span>
              <span>{{ articleResult ? `生成时间：${formatTime(articleResult.createdAt)}` : streamProgress?.message || '请稍候' }}</span>
            </div>
          </template>
        </el-card>

        <el-card class="ai-reading-history" shadow="never">
          <template #header>
            <div class="ai-card-header">
              <span>历史记录</span>
              <el-button text :loading="historyLoading" @click="fetchHistory(historyPage.current, historyPage.size, true)">
                刷新
              </el-button>
            </div>
          </template>

          <div class="ai-history-subtitle">展示当前用户已生成的 AI 文章，按时间倒序排列。</div>

          <el-empty v-if="!historyPage.records.length" description="暂无记录，先生成一篇专属文章吧。" />

          <div v-else class="ai-history-list" v-loading="historyLoading">
            <button
              v-for="item in historyPage.records"
              :key="item.id"
              type="button"
              class="ai-history-item"
              :class="{ 'ai-history-item--active': activeHistoryId === item.id }"
              @click="handleSelectHistory(item)"
            >
              <div class="ai-history-item__content">
                <strong>{{ item.theme }}</strong>
                <p>
                  {{ item.wordBankName }}
                </p>
                <p>{{ item.difficulty }} / {{ item.length }} / {{ item.duration }}ms</p>
              </div>
              <div class="ai-history-item__side">
                <span>{{ formatTime(item.createdAt) }}</span>
                <el-button
                  text
                  type="danger"
                  :loading="historyDeletingId === item.id"
                  @click.stop="handleDeleteHistory(item)"
                >
                  删除
                </el-button>
              </div>
            </button>
          </div>

          <div v-if="historyPage.total > historyPage.size" class="ai-history-pagination">
            <el-pagination
              background
              layout="prev, pager, next"
              :current-page="historyPage.current"
              :page-size="historyPage.size"
              :total="historyPage.total"
              @current-change="handleHistoryPageChange"
            />
          </div>
        </el-card>
      </div>
    </div>

    <el-dialog
      v-model="addWordDialogVisible"
      title="加入自定义词库"
      width="480px"
      @closed="handleAddWordDialogClosed"
    >
      <div v-if="selectedHighlightWord" class="ai-add-word-dialog">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="英文单词">{{ selectedHighlightWord.english }}</el-descriptions-item>
          <el-descriptions-item label="中文释义">{{ selectedHighlightWord.chinese }}</el-descriptions-item>
        </el-descriptions>

        <el-form label-position="top" class="ai-add-word-form">
          <el-form-item label="选择要加入的词库">
            <el-select
              v-model="addWordForm.wordBankId"
              placeholder="请选择自定义词库"
              style="width: 100%"
              :loading="addWordOptionsLoading"
              :disabled="!customWordBanks.length"
            >
              <el-option
                v-for="item in customWordBanks"
                :key="item.id"
                :label="`${item.name}（${item.wordCount}词）`"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
        </el-form>

        <el-empty v-if="!addWordOptionsLoading && !customWordBanks.length" description="你还没有自定义词库，请先创建一个词库。">
          <el-button type="primary" @click="addWordDialogVisible = false; router.push('/wordbanks')">前往创建词库</el-button>
        </el-empty>
      </div>

      <template #footer>
        <el-button @click="addWordDialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="addWordSubmitting"
          :disabled="!selectedHighlightWord || !customWordBanks.length"
          @click="handleSubmitAddWord"
        >
          加入词库
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.ai-reading-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(20px, 3vw, 40px) clamp(16px, 3vw, 24px) 56px;
  background: linear-gradient(180deg, #f8fbff 0%, #eef4ff 100%);
}

.ai-reading-page__header,
.ai-reading-page__alert,
.ai-reading-layout {
  max-width: 1200px;
  margin: 0 auto;
}

.ai-reading-page__header {
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  gap: 16px;
}

.ai-reading-page__header h1 {
  margin: 0 0 8px;
  font-size: 30px;
  color: #1f2d3d;
}

.ai-reading-page__header p {
  margin: 0;
  color: #5b6475;
}

.ai-reading-page__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.ai-reading-page__alert {
  margin-bottom: 20px;
}

.ai-reading-layout {
  display: grid;
  grid-template-columns: 340px minmax(0, 1fr);
  gap: 20px;
  align-items: start;
}

.ai-reading-sidebar,
.ai-reading-result,
.ai-reading-history {
  border-radius: 20px;
}

.ai-reading-main {
  display: grid;
  gap: 20px;
}

.ai-reading-result__actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.ai-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.ai-reading-tip {
  margin-top: 8px;
  color: #6b7280;
  font-size: 13px;
}

.ai-provider-presets {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.ai-provider-card {
  padding: 12px 14px;
  border: 1px solid #dbe5ff;
  border-radius: 14px;
  background: #f8fbff;
  display: grid;
  gap: 6px;
  text-align: left;
  cursor: pointer;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.ai-provider-card--active,
.ai-provider-card:hover {
  border-color: #6a94ff;
  box-shadow: 0 10px 20px rgba(56, 91, 190, 0.08);
}

.ai-provider-card strong {
  color: #1f2d3d;
  font-size: 14px;
}

.ai-provider-card span,
.ai-provider-card em {
  color: #6b7280;
  font-size: 12px;
  font-style: normal;
}

.ai-auto-config {
  display: grid;
  gap: 6px;
  font-size: 13px;
  color: #5b6475;
}

.ai-reading-generate {
  width: 100%;
}

.ai-reading-quota {
  margin-top: 20px;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
}

.ai-reading-inline-alert {
  margin-top: 16px;
}

.ai-generation-progress {
  margin-top: 8px;
  padding: 16px 18px;
  border-radius: 18px;
  background: #f5f8ff;
  border: 1px solid #dbe5ff;
}

.ai-generation-progress__header {
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  color: #1f2d3d;
}

.ai-reading-quota > div {
  padding: 14px 12px;
  border-radius: 16px;
  background: #f7faff;
  display: grid;
  gap: 8px;
  text-align: center;
}

.ai-reading-quota span,
.ai-history-subtitle {
  color: #6b7280;
  font-size: 13px;
}

.ai-history-subtitle {
  margin-bottom: 12px;
}

.ai-reading-quota strong {
  font-size: 20px;
  color: #1f2d3d;
}

.ai-meta,
.ai-highlight-words,
.ai-reading-note {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.ai-highlight-words {
  margin-top: 18px;
  align-items: center;
}

.ai-highlight-tag {
  cursor: pointer;
}

.ai-highlight-words__tip {
  font-size: 13px;
}

.ai-highlight-words > span,
.ai-reading-note {
  color: #5b6475;
}

.ai-article-content {
  margin-top: 20px;
  padding: 24px;
  border-radius: 20px;
  background: #fffdf4;
  color: #1f2d3d;
  line-height: 1.9;
  font-size: 16px;
}

.ai-article-content :deep(p) {
  margin: 0 0 16px;
}

.ai-article-content :deep(p:last-child) {
  margin-bottom: 0;
}

.ai-article-content :deep(mark.ai-word-highlight) {
  padding: 0 4px;
  border-radius: 6px;
  background: #ffe58f;
  color: #7a4b00;
  cursor: pointer;
  transition: background-color 0.2s ease, box-shadow 0.2s ease;
}

.ai-article-content :deep(mark.ai-word-highlight:hover) {
  background: #ffd666;
  box-shadow: 0 2px 8px rgba(250, 173, 20, 0.3);
}

.ai-word-tooltip {
  position: fixed;
  z-index: 9999;
  transform: translate(-50%, -100%);
  padding: 12px 16px;
  border-radius: 12px;
  background: linear-gradient(135deg, #1f2d3d 0%, #2d3e50 100%);
  color: #fff;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.18), 0 2px 8px rgba(0, 0, 0, 0.12);
  pointer-events: auto;
  white-space: nowrap;
}

.ai-word-tooltip__english {
  font-size: 15px;
  font-weight: 600;
  color: #ffd666;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.ai-word-tooltip__phonetic {
  font-size: 13px;
  font-weight: 400;
  color: #a0aec0;
  font-style: normal;
}

.ai-word-tooltip--loading {
  min-width: 140px;
}

.ai-word-tooltip__chinese {
  font-size: 14px;
  color: #e8ecf1;
  display: flex;
  align-items: center;
}

.tooltip-fade-enter-active,
.tooltip-fade-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.tooltip-fade-enter-from,
.tooltip-fade-leave-to {
  opacity: 0;
  transform: translate(-50%, -100%) scale(0.95);
}

.ai-translation-content {
  margin-top: 20px;
  padding: 24px;
  border-radius: 20px;
  background: linear-gradient(180deg, #f0fdf4 0%, #ecfdf5 100%);
  border: 1px solid #bbf7d0;
}

.ai-translation-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  color: #166534;
  font-size: 16px;
  font-weight: 600;
}

.ai-translation-text {
  color: #1f2d3d;
  line-height: 1.9;
  font-size: 16px;
  white-space: pre-wrap;
}

.ai-add-word-dialog,
.ai-add-word-form {
  display: grid;
  gap: 16px;
}

.ai-reading-note {
  margin-top: 20px;
  justify-content: space-between;
}

.ai-history-list {
  display: grid;
  gap: 12px;
}

.ai-history-item {
  width: 100%;
  padding: 14px 16px;
  border: 1px solid #dbe5ff;
  border-radius: 16px;
  background: #f8fbff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  text-align: left;
  cursor: pointer;
  transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
}

.ai-history-item:hover {
  transform: translateY(-1px);
  border-color: #9bb8ff;
  box-shadow: 0 12px 24px rgba(56, 91, 190, 0.08);
}

.ai-history-item--active {
  border-color: #6a94ff;
  background: #eef4ff;
}

.ai-history-item__content,
.ai-history-item__side {
  display: grid;
  gap: 4px;
}

.ai-history-item__side {
  justify-items: end;
}

.ai-history-item strong {
  color: #1f2d3d;
}

.ai-history-item p,
.ai-history-item span {
  margin: 4px 0 0;
  color: #6b7280;
  font-size: 13px;
}

.ai-history-pagination {
  margin-top: 16px;
  display: flex;
  justify-content: center;
}

@media (max-width: 960px) {
  .ai-reading-page__header {
    flex-direction: column;
  }

  .ai-reading-page__actions {
    width: 100%;
    flex-wrap: wrap;
    justify-content: flex-start;
  }

  .ai-reading-layout {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .ai-reading-page {
    padding: 28px 16px 40px;
  }

  .ai-reading-quota,
  .ai-reading-note,
  .ai-history-item {
    grid-template-columns: 1fr;
    flex-direction: column;
    align-items: flex-start;
  }

  .ai-history-item__side {
    width: 100%;
    justify-items: start;
  }
}
</style>
