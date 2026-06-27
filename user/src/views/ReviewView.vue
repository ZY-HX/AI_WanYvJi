<script setup lang="ts">
/** 复习功能页面组件 - 基于已学过单词进行复习 */
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
/** Vue Router 路由相关 */
import { useRoute, useRouter } from 'vue-router'
/** Element Plus 消息提示组件 */
import { ElMessage } from 'element-plus'
/** 日期时间处理库 */
import dayjs from 'dayjs'
/** 学习模块相关的 API 接口 */
import {
  getReviewWords,
  getStudyQuestionOptions,
  getStudyWordBanks,
  submitStudyResult,
  type StudyOption,
  type StudyResultResponse,
  type StudyWord,
  type StudyWordBankOption,
} from '../api/study'
import {
  getLearningLanguageLabel,
  getLearningLanguageOptions,
  getPreferredLearningLanguage,
  setPreferredLearningLanguage,
  type LearningLanguage,
} from '../shared/learningLanguage'

/** 路由实例 */
const router = useRouter()
/** 当前路由对象 */
const route = useRoute()

/** 页面数据加载状态 */
const loading = ref(false)
/** 答案提交中状态 */
const submitting = ref(false)
/** 词库列表加载状态 */
const wordBankLoading = ref(false)
/** 可学习的词库列表 */
const wordBanks = ref<StudyWordBankOption[]>([])
/** 当前页待复习的单词列表 */
const reviewWords = ref<StudyWord[]>([])
/** 当前选中的学习语种 */
const selectedLanguage = ref<LearningLanguage>(getPreferredLearningLanguage())
/** 当前选中的词库 ID */
const selectedWordBankId = ref<number>()
/** 当前选择的学习模式，默认为'看词选义' */
const selectedMode = ref('EN_TO_CN')
/** 当前分页页码 */
const currentPage = ref(1)
/** 每页显示数量 */
const pageSize = ref(20)
/** 总复习单词数 */
const total = ref(0)
/** 当前批次初始单词总数 */
const pageInitialCount = ref(0)
/** 当前批次已完成单词数 */
const pageCompletedCount = ref(0)
/** 选择题选项列表 */
const questionOptions = ref<string[]>([])
/** 干扰项选项池 */
const optionPool = ref<StudyOption[]>([])
/** 用户选择的答案 */
const selectedChoice = ref('')
/** 拼写模式下的用户输入答案 */
const spellingAnswer = ref('')
/** 是否已提交当前题目答案 */
const answerSubmitted = ref(false)
/** 当前题目是否回答正确 */
const answerCorrect = ref<boolean | null>(null)
/** 提交结果详情 */
const submitResult = ref<StudyResultResponse | null>(null)
/** 请求序号：用于忽略过期响应，避免并发请求覆盖新状态 */
const fetchReviewWordsSeq = ref(0)

/** 学习模式配置选项 */
const modeOptions = [
  { label: '看词选义', value: 'EN_TO_CN' },
  { label: '看义选词', value: 'CN_TO_EN' },
  { label: '听音选义', value: 'LISTEN' },
  { label: '单词拼写', value: 'SPELL' },
]
const languageOptions = getLearningLanguageOptions()

/** 当前正在复习的单词（取列表第一项） */
const currentWord = computed(() => reviewWords.value[0] ?? null)
/** 已完成题目数量 */
const completedCount = computed(() => pageCompletedCount.value)
/** 剩余待复习数量 */
const remainingCount = computed(() => total.value)
/** 进度文本显示（如：3/10） */
const progressText = computed(() =>
  pageInitialCount.value ? `${pageCompletedCount.value}/${pageInitialCount.value}` : '0/0',
)
/** 学习进度百分比（0-100） */
const progressPercentage = computed(() => {
  if (!pageInitialCount.value) {
    return 0
  }
  return Math.min((pageCompletedCount.value / pageInitialCount.value) * 100, 100)
})
/** 当前学习模式的中文标签 */
const currentModeLabel = computed(
  () => modeOptions.find((item) => item.value === selectedMode.value)?.label ?? '看词选义',
)
const currentLanguageLabel = computed(() => {
  return getLearningLanguageLabel(selectedLanguage.value)
})
/** 判断当前模式是否为选择题模式（非拼写） */
const isChoiceMode = computed(() =>
  ['EN_TO_CN', 'CN_TO_EN', 'LISTEN'].includes(selectedMode.value),
)
/** 判断浏览器是否支持语音合成功能（用于发音播放） */
const pronunciationSupported = computed(
  () => typeof window !== 'undefined' && 'speechSynthesis' in window,
)
/** 反馈标题（根据答题结果显示正确或错误） */
const feedbackTitle = computed(() => (answerCorrect.value ? '回答正确' : '回答错误'))
/** 反馈类型（成功为绿色，错误为红色） */
const feedbackType = computed(() => (answerCorrect.value ? 'success' : 'error'))

/** 组件挂载完成后初始化：加载可学习的词库列表 */
onMounted(async () => {
  await fetchWordBanks()
})

/** 组件卸载前清理：停止语音播放 */
onBeforeUnmount(() => {
  stopPronunciation()
})

/** 监听路由参数变化：当 URL 中携带 wordBankId 时自动选中对应词库 */
watch(
  () => route.query.wordBankId,
  (value) => {
    const nextId = Number(value)
    if (Number.isFinite(nextId) && nextId > 0) {
      selectedWordBankId.value = nextId
    }
  },
  { immediate: true },
)

watch(
  () => route.query.language,
  (value) => {
    const nextLanguage = typeof value === 'string' ? value.toUpperCase() : ''
    if (nextLanguage === 'EN' || nextLanguage === 'JA' || nextLanguage === 'KO' || nextLanguage === 'DE' || nextLanguage === 'FR' || nextLanguage === 'ES') {
      selectedLanguage.value = nextLanguage
      setPreferredLearningLanguage(nextLanguage)
    }
  },
  { immediate: true },
)

/**
 * 获取当前用户可学习的词库列表
 * 包含用户自己创建的私有词库 + 所有公开词库
 */
async function fetchWordBanks() {
  wordBankLoading.value = true
  try {
    const result = await getStudyWordBanks(selectedLanguage.value)
    const filteredWordBanks = result.filter((item) => isSameLanguage(item.language, selectedLanguage.value))
    wordBanks.value = filteredWordBanks

    /** 如果没有可学习的词库，清空所有复习状态并显示空状态提示 */
    if (!wordBanks.value.length) {
      reviewWords.value = []
      total.value = 0
      pageInitialCount.value = 0
      pageCompletedCount.value = 0
      resetQuestionState()
      console.warn('[复习功能] 未找到可学习的词库，请检查数据库是否有公开词库或用户自有词库')
      return
    }

    /**
     * 自动选择词库逻辑：
     * 1. 如果之前没选过词库，或者之前选的词库不在新列表中了，就自动选中第一个
     * 2. 这样可以保证用户总能看到一个默认选中的词库
     */
    if (wordBanks.value.length > 0) {
      if (!selectedWordBankId.value || !wordBanks.value.some((item) => item.id === selectedWordBankId.value)) {
        selectedWordBankId.value = wordBanks.value[0].id
      }

      /** 加载选中词库的已学单词用于复习 */
      await fetchReviewWords(1)
    } else {
      /** 没有可用词库时清空所有状态 */
      selectedWordBankId.value = undefined
      reviewWords.value = []
      total.value = 0
      pageInitialCount.value = 0
      pageCompletedCount.value = 0
      resetQuestionState()
      console.warn('[复习功能] 当前没有可学习的词库（无公开词库且用户未创建私有词库）')
    }
  } catch (error) {
    /** 错误处理：捕获 API 调用异常并显示友好提示 */
    console.error('[复习功能] 获取词库列表失败:', error)
    ElMessage.error('获取词库列表失败，请检查网络连接或刷新页面重试')
    wordBanks.value = []
  } finally {
    /** 无论成功失败都要关闭加载状态 */
    wordBankLoading.value = false
  }
}

function isSameLanguage(rawLanguage: string | undefined, currentLanguage: LearningLanguage) {
  if (!rawLanguage) {
    return false
  }
  return rawLanguage.toUpperCase() === currentLanguage
}

/**
 * 获取指定词库的已学单词列表用于复习
 * @param page 页码，默认使用当前页码
 */
async function fetchReviewWords(page = currentPage.value) {
  /** 如果没有选中词库，直接返回不加载 */
  if (!selectedWordBankId.value) {
    return
  }
  const requestSeq = ++fetchReviewWordsSeq.value

  loading.value = true
  try {
    const result = await getReviewWords({
      wordBankId: selectedWordBankId.value,
      current: page,
      size: pageSize.value,
    })
    if (requestSeq !== fetchReviewWordsSeq.value) {
      return
    }

    /** 解析返回的分页数据：总复习数、每页大小、当前页码 */
    const nextTotal = Number(result.total || 0)
    pageSize.value = Number(result.size || pageSize.value || 20)
    const maxPage = Math.max(Math.ceil(nextTotal / pageSize.value), 1)

    /**
     * 防止页码超出范围：
     * 如果请求的页码大于最大页码，自动跳转到最后一页
     */
    if (nextTotal > 0 && page > maxPage) {
      await fetchReviewWords(maxPage)
      return
    }

    /** 更新分页状态和单词数据 */
    currentPage.value = Number(result.current || page)
    total.value = nextTotal
    reviewWords.value = result.records ?? []
    pageInitialCount.value = reviewWords.value.length
    pageCompletedCount.value = 0

    /** 🔍 调试日志 */
    console.log(`[复习功能] 成功加载 ${reviewWords.value.length} 个已学单词 (总计: ${total.value})`)

    /** 准备当前题目的选项和显示内容 */
    await prepareCurrentQuestion()
    if (requestSeq !== fetchReviewWordsSeq.value) {
      return
    }

    /**
     * 将当前选中的词库 ID 同步到 URL 参数中
     * 这样刷新页面或分享链接时能记住用户的选择
     */
    const urlQuery = {
      ...route.query,
      wordBankId: String(selectedWordBankId.value),
      language: selectedLanguage.value,
    }
    if (route.query.wordBankId !== urlQuery.wordBankId || route.query.language !== urlQuery.language) {
      await router.replace({ path: '/review', query: urlQuery })
    }
  } catch (error) {
    /** 错误处理：加载单词失败时给出提示 */
    console.error('[复习功能] 获取复习单词失败:', error)
    ElMessage.error('加载复习内容失败，请稍后重试')
  } finally {
    if (requestSeq === fetchReviewWordsSeq.value) {
      loading.value = false
    }
  }
}

async function handleLanguageChange(language: LearningLanguage) {
  setPreferredLearningLanguage(language)
  currentPage.value = 1
  await fetchWordBanks()
}

/** 处理词库切换事件：重置到第一页重新加载 */
async function handleWordBankChange() {
  currentPage.value = 1
  await fetchReviewWords(1)
}

/** 处理学习模式切换事件：停止语音播放后重新加载题目 */
async function handleModeChange() {
  currentPage.value = 1
  stopPronunciation()
  await fetchReviewWords(1)
}

/** 处理分页切换事件：停止语音后加载新页面 */
async function handlePageChange(page: number) {
  stopPronunciation()
  await fetchReviewWords(page)
}

/** 重置当前题目的答题状态，清空所有选项和答案 */
function resetQuestionState() {
  questionOptions.value = []
  optionPool.value = []
  selectedChoice.value = ''
  spellingAnswer.value = ''
  answerSubmitted.value = false
  answerCorrect.value = null
  submitResult.value = null
}

/**
 * 准备当前题目的显示内容和选项
 * 根据学习模式加载不同的题目类型（选择题/拼写题）
 */
async function prepareCurrentQuestion() {
  resetQuestionState()
  if (!currentWord.value) {
    return
  }

  if (isChoiceMode.value) {
    await loadQuestionOptions(currentWord.value)
    questionOptions.value = buildQuestionOptions(currentWord.value, selectedMode.value)
    if (questionOptions.value.length !== 4) {
      ElMessage.warning('当前词库可用干扰项不足，选择题需要至少 4 个不同单词')
    }
  }

  if (selectedMode.value === 'LISTEN') {
    playPronunciation(true)
  }
}

/**
 * 从后端加载选择题的干扰项选项
 * 用于构建 4 选 1 的选择题（1 个正确答案 + 3 个干扰项）
 */
async function loadQuestionOptions(word: StudyWord) {
  const result = await getStudyQuestionOptions(word.wordBankId, word.wordId)
  optionPool.value = result
}

/**
 * 构建选择题的 4 个选项
 * 包含 1 个正确答案和 3 个从干扰项池中随机选取的错误选项
 */
function buildQuestionOptions(word: StudyWord, mode: string) {
  const correctAnswer = getCorrectAnswer(word, mode)
  if (!correctAnswer) {
    return []
  }

  const optionSource = [
    ...reviewWords.value
      .filter((item) => item.wordId !== word.wordId)
      .map((item) => getCorrectAnswer(item, mode)),
    ...optionPool.value
      .filter((item) => item.wordId !== word.wordId)
      .map((item) => getCorrectAnswer(item, mode)),
  ]
    .filter((item): item is string => Boolean(item))
    .filter((item) => !looksLikeExample(item, correctAnswer))
    
  const distractors = Array.from(new Set(optionSource)).filter((item) => item !== correctAnswer)
  if (distractors.length < 3) {
    return []
  }

  return shuffleArray([correctAnswer, ...shuffleArray(distractors).slice(0, 3)])
}

/**
 * 检查文本是否看起来像是例句而非释义
 * 用于过滤掉错误地被当作释义的例句
 */
function looksLikeExample(text: string, correctAnswer?: string): boolean {
  if (!text || text === correctAnswer) return false
  
  const trimmed = text.trim()
  
  // 如果文本过长（超过50字符），很可能是例句
  if (trimmed.length > 50) return true
  
  // 如果包含常见的例句模式，认为是例句
  const examplePatterns = [
    /^[A-Z][a-z]+.*\.$/,           // 英文句子（首字母大写，句号结尾）
    /^I\s+(am|have|can|will|like)/i, // 常见英文句式开头
    /\s(be|is|are|was|were|have|has|had|do|does|did|can|could|will|would|should)\s/i,
    /,\s*(and|but|or|so)/i,          // 包含连词
    /^\w+\s+\w+\s+\w+\s*\./,         // 多个单词组成的句子
  ]
  
  return examplePatterns.some(pattern => pattern.test(trimmed))
}

/**
 * 根据学习模式获取正确答案
 * 看英选中/听音选中：返回中文释义
 * 看中选英/拼写：返回英文单词
 */
function getCorrectAnswer(word: Pick<StudyWord, 'english' | 'chinese'>, mode: string) {
  if (mode === 'CN_TO_EN' || mode === 'SPELL') {
    return word.english
  }
  return word.chinese
}

/** Fisher-Yates 洗牌算法：随机打乱数组顺序 */
function shuffleArray<T>(items: T[]) {
  const nextItems = [...items]
  for (let index = nextItems.length - 1; index > 0; index -= 1) {
    const randomIndex = Math.floor(Math.random() * (index + 1))
    ;[nextItems[index], nextItems[randomIndex]] = [nextItems[randomIndex], nextItems[index]]
  }
  return nextItems
}

/** 标准化用户输入的答案：去除首尾空格、合并多余空格、转为小写 */
function normalizeAnswer(value: string) {
  return value.trim().replace(/\s+/g, ' ').toLowerCase()
}

/** 停止当前正在播放的语音 */
function stopPronunciation() {
  if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
    window.speechSynthesis.cancel()
  }
}

/**
 * 播放当前单词的英文发音
 * @param silent 是否静默模式（静默模式下不支持时不显示提示）
 */
function playPronunciation(silent = false) {
  const english = currentWord.value?.english?.trim()
  if (!english) {
    return
  }

  if (!pronunciationSupported.value) {
    if (!silent) {
      ElMessage.warning('当前环境不支持语音播放')
    }
    return
  }

  stopPronunciation()
  const utterance = new SpeechSynthesisUtterance(english)
  utterance.lang =
    selectedLanguage.value === 'JA'
      ? 'ja-JP'
      : selectedLanguage.value === 'KO'
        ? 'ko-KR'
        : 'en-US'
  utterance.rate = 0.9
  window.speechSynthesis.speak(utterance)
}

/**
 * 处理选择题答案提交
 * @param option 用户选择的选项文本
 */
async function handleChoiceAnswer(option: string) {
  if (!currentWord.value || answerSubmitted.value || submitting.value) {
    return
  }

  selectedChoice.value = option
  await submitCurrentAnswer(option === getCorrectAnswer(currentWord.value, selectedMode.value))
}

/** 处理拼写题答案提交：验证用户输入的英文拼写是否正确 */
async function handleSpellingSubmit() {
  if (!currentWord.value || answerSubmitted.value || submitting.value) {
    return
  }

  if (!spellingAnswer.value.trim()) {
    ElMessage.warning('请先输入拼写答案')
    return
  }

  await submitCurrentAnswer(
    normalizeAnswer(spellingAnswer.value) === normalizeAnswer(currentWord.value.english || ''),
  )
}

/**
 * 提交当前题目的答案到后端
 * @param correct 用户答案是否正确
 */
async function submitCurrentAnswer(correct: boolean) {
  if (!currentWord.value || submitting.value || answerSubmitted.value) {
    return
  }

  const word = currentWord.value
  submitting.value = true
  try {
    const result = await submitStudyResult(word.wordBankId, {
      recordId: word.recordId,
      wordId: word.wordId,
      correct,
      mode: selectedMode.value,
    })

    submitResult.value = result
    answerSubmitted.value = true
    answerCorrect.value = correct
    pageCompletedCount.value += 1

    const nextReviewTime = formatReviewTime(result.nextReviewTime)
    if (correct) {
      ElMessage.success(`回答正确，下次复习时间：${nextReviewTime}`)
    } else {
      ElMessage.warning(`回答错误，下次复习时间：${nextReviewTime}`)
    }
  } finally {
    submitting.value = false
  }
}

/**
 * 处理"下一题"按钮点击事件
 * 移除当前已完成的单词，加载下一个单词或下一页
 */
async function handleNextQuestion() {
  if (!answerSubmitted.value) {
    return
  }

  stopPronunciation()
  reviewWords.value = reviewWords.value.slice(1)

  if (reviewWords.value.length) {
    await prepareCurrentQuestion()
    return
  }

  const nextPage = Math.min(currentPage.value, Math.max(Math.ceil(Math.max(total.value, 1) / pageSize.value), 1))
  await fetchReviewWords(nextPage)
  if (reviewWords.value.length) {
    return
  }

  resetQuestionState()
  ElMessage.success('本轮复习完成，继续保持。')
}

/**
 * 根据答题结果解析选项的样式类名
 * 正确答案显示绿色，错误选择显示红色，其他选项变灰
 */
function resolveOptionClass(option: string) {
  if (!answerSubmitted.value || !currentWord.value) {
    return ''
  }

  const correctAnswer = getCorrectAnswer(currentWord.value, selectedMode.value)
  if (option === correctAnswer) {
    return 'study-option--correct'
  }
  if (option === selectedChoice.value && !answerCorrect.value) {
    return 'study-option--wrong'
  }
  return 'study-option--muted'
}

/** 格式化复习时间显示：将时间戳转为易读的日期时间格式 */
function formatReviewTime(value?: string) {
  return value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '立即学习'
}
</script>

<template>
  <div class="study-page">
    <div class="study-page__header">
      <div>
        <h1>单词复习</h1>
        <p>从您已经学过的单词中进行复习巩固，支持与学习时相同的四维度答题模式。</p>
      </div>
      <div class="study-page__actions">
        <el-button @click="router.push('/')">返回首页</el-button>
        <el-button plain @click="router.push('/study')">今日学习</el-button>
        <el-button plain @click="router.push('/error-book')">错题本</el-button>
      </div>
    </div>

    <div class="study-layout">
      <el-card class="study-toolbar" shadow="never">
        <div class="study-toolbar__title">复习控制台</div>
        <div class="study-toolbar__row">
        <div class="study-toolbar__field">
          <span>学习语种</span>
          <el-select v-model="selectedLanguage" style="width: 130px" @change="handleLanguageChange">
            <el-option v-for="item in languageOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </div>

        <div class="study-toolbar__field">
          <span>选择词库</span>
          <el-select
            v-model="selectedWordBankId"
            placeholder="请选择词库"
            :loading="wordBankLoading"
            :disabled="wordBankLoading || !wordBanks.length"
            @change="handleWordBankChange"
          >
            <el-option
              v-for="item in wordBanks"
              :key="item.id"
              :label="`${item.name}（${item.wordCount}词）`"
              :value="item.id"
            />
          </el-select>
        </div>

        </div>

        <div class="study-toolbar__stats">
          <span>当前页：{{ currentPage }}</span>
          <span>总已学单词：{{ total }}</span>
          <span>本页进度：{{ progressText }}</span>
          <span>已完成：{{ completedCount }}</span>
          <span>剩余：{{ remainingCount }}</span>
        </div>

        <div class="study-toolbar__progress">
          <span>当前批次进度</span>
          <el-progress :percentage="progressPercentage" :stroke-width="10" :show-text="false" />
        </div>
      </el-card>

      <el-empty
        v-if="!wordBankLoading && !wordBanks.length"
        description="当前没有可学习的词库，请先创建词库或选择公开词库。"
        class="study-empty"
      />

      <div v-else class="study-main">
        <div class="study-mode-bar">
          <span class="study-mode-bar__label">复习模式</span>
          <el-radio-group v-model="selectedMode" @change="handleModeChange">
            <el-radio-button v-for="item in modeOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </el-radio-button>
          </el-radio-group>
        </div>

        <el-card class="study-card-panel" shadow="never">
          <el-skeleton :loading="loading" animated :rows="8">
            <template #default>
          <el-empty
            v-if="!reviewWords.length"
            description="该词库暂无已学单词，请先进行学习后再来复习。"
          />

          <div v-else class="study-card-wrapper">
            <div class="study-card">
              <div class="study-card__meta">
                <div class="study-card__badge">学习记录 ID：{{ currentWord?.recordId }}</div>
                <div class="study-card__mode">{{ currentModeLabel }}</div>
              </div>
              <div class="study-card__body">
                <p class="study-card__hint">
                  {{
                    selectedMode === 'EN_TO_CN'
                      ? `请根据${currentLanguageLabel}词汇选择正确中文释义`
                      : selectedMode === 'CN_TO_EN'
                        ? `请根据中文选择对应${currentLanguageLabel}词汇`
                        : selectedMode === 'LISTEN'
                          ? '请播放发音后选择正确中文释义'
                          : `请根据中文拼写对应${currentLanguageLabel}词汇`
                  }}
                </p>

                <h2 v-if="selectedMode === 'EN_TO_CN'">{{ currentWord?.english }}</h2>
                <h2 v-else-if="selectedMode === 'CN_TO_EN'">{{ currentWord?.chinese }}</h2>
                <h2 v-else-if="selectedMode === 'LISTEN'">请听发音并作答</h2>
                <h2 v-else>{{ currentWord?.chinese }}</h2>

                <p
                  v-if="selectedMode === 'EN_TO_CN' && currentWord?.phonetic"
                  class="study-card__phonetic"
                >
                  {{ currentWord?.phonetic }}
                </p>
                <p v-if="selectedMode === 'LISTEN'" class="study-card__subtext">
                  可多次播放发音后再作答
                </p>
                <p v-if="selectedMode === 'SPELL'" class="study-card__subtext">
                  忽略大小写差异，按回车也可提交
                </p>
              </div>

              <div v-if="selectedMode === 'LISTEN'" class="study-listen">
                <el-button type="primary" plain :disabled="submitting" @click="playPronunciation()">
                  播放发音
                </el-button>
                <span v-if="!pronunciationSupported" class="study-listen__fallback">
                  当前环境不支持语音播放
                </span>
              </div>

              <div v-if="isChoiceMode && questionOptions.length === 4" class="study-options">
                <button
                  v-for="option in questionOptions"
                  :key="option"
                  type="button"
                  class="study-option"
                  :class="resolveOptionClass(option)"
                  :disabled="submitting || answerSubmitted"
                  @click="handleChoiceAnswer(option)"
                >
                  {{ option }}
                </button>
              </div>

              <el-alert
                v-else-if="isChoiceMode"
                title="当前词库可用干扰项不足"
                type="warning"
                :closable="false"
                show-icon
                class="study-feedback"
              >
                <p>选择题需要固定 4 个选项，其中 1 个正确、3 个干扰项。</p>
                <p>请补充词库单词后再继续该题型。</p>
              </el-alert>

              <div v-else class="study-spell">
                <el-input
                  v-model="spellingAnswer"
                  size="large"
                  maxlength="100"
                  :placeholder="`请输入${currentLanguageLabel}拼写`"
                  :disabled="submitting || answerSubmitted"
                  @keyup.enter="handleSpellingSubmit"
                />
              </div>

              <el-alert
                v-if="answerSubmitted && currentWord && submitResult"
                :title="feedbackTitle"
                :type="feedbackType"
                :closable="false"
                show-icon
                class="study-feedback"
              >
                <p>正确答案：{{ currentWord.english }} / {{ currentWord.chinese }}</p>
                <p v-if="selectedMode === 'SPELL'">你的答案：{{ spellingAnswer || '未作答' }}</p>
                <p v-if="currentWord.example">例句：{{ currentWord.example }}</p>
                <p>下次复习时间：{{ formatReviewTime(submitResult.nextReviewTime) }}</p>
              </el-alert>

              <div class="study-card__footer">
                <span>预计复习时间：{{ formatReviewTime(currentWord?.nextReviewTime) }}</span>
                <span>模式：{{ currentModeLabel }}</span>
              </div>
            </div>

            <div class="study-actions">
              <el-button
                v-if="selectedMode === 'SPELL' && !answerSubmitted"
                size="large"
                type="primary"
                :loading="submitting"
                @click="handleSpellingSubmit"
              >
                提交答案
              </el-button>
              <el-button
                v-if="selectedMode === 'LISTEN'"
                size="large"
                plain
                :disabled="submitting"
                @click="playPronunciation()"
              >
                再听一次
              </el-button>
              <el-button
                v-if="answerSubmitted"
                size="large"
                type="success"
                :disabled="submitting"
                @click="handleNextQuestion"
              >
                下一题
              </el-button>
            </div>
          </div>
            </template>
          </el-skeleton>

          <div class="study-pagination">
            <el-pagination
              background
              layout="prev, pager, next, total"
              :current-page="currentPage"
              :page-size="pageSize"
              :total="total"
              @current-change="handlePageChange"
            />
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ==================== 深色主题 - 复习页 ==================== */
.study-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(20px, 3vw, 40px) clamp(16px, 3vw, 24px) 56px;
  background: linear-gradient(180deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
}

.study-page__header,
.study-toolbar,
.study-card-panel,
.study-empty {
  max-width: 1120px;
  margin: 0 auto;
}

.study-page__header {
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  gap: 16px;
}

.study-layout {
  max-width: 1180px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 248px minmax(0, 1fr);
  gap: 16px;
  align-items: start;
}

.study-main {
  min-width: 0;
}

.study-mode-bar {
  margin-bottom: 14px;
  padding: 12px 14px;
  border-radius: 14px;
  border: 1px solid rgba(249, 115, 22, 0.25);
  background: rgba(15, 23, 42, 0.45);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  flex-wrap: wrap;
}

.study-mode-bar__label {
  color: #cbd5e1;
  font-size: 14px;
  font-weight: 600;
}

.study-page__header h1 {
  margin: 0 0 8px;
  font-size: 30px;
  color: #f97316;
  font-weight: 700;
}

.study-page__header p {
  margin: 0;
  color: #cbd5e1;
  font-size: 15px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.study-page__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.study-toolbar {
  margin-bottom: 0;
  border-radius: 20px;
  border: 1px solid rgba(249, 115, 22, 0.2);
  background: rgba(15, 23, 42, 0.55) !important;
  backdrop-filter: blur(10px);
  overflow: hidden;
  position: sticky;
  top: calc(var(--app-header-height) + 12px);
}

.study-toolbar__title {
  margin-bottom: 14px;
  color: #f1f5f9;
  font-size: 16px;
  font-weight: 700;
}

.study-toolbar :deep(.el-card__body) {
  background: transparent;
}

.study-toolbar__row {
  display: grid;
  gap: 14px;
}

.study-toolbar__field {
  display: grid;
  gap: 10px;
  min-width: 0;
  color: #e2e8f0;
  font-size: 14px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.study-toolbar__field :deep(.el-select) {
  width: 100%;
}

.study-toolbar__field :deep(.el-radio-group) {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.study-toolbar__stats {
  margin-top: 18px;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
  color: #e2e8f0;
  font-size: 14px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.study-toolbar__stats span {
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid rgba(148, 163, 184, 0.25);
  background: rgba(15, 23, 42, 0.35);
}

.study-toolbar__progress {
  margin-top: 18px;
  display: grid;
  gap: 10px;
  color: #e2e8f0;
  font-size: 14px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.study-card-panel {
  border-radius: 24px;
  border: 1px solid rgba(249, 115, 22, 0.2);
  background: rgba(15, 23, 42, 0.5) !important;
  backdrop-filter: blur(10px);
  overflow: hidden;
}

.study-card-panel :deep(.el-card__body) {
  background: transparent;
}

.study-main :deep(.el-skeleton__item),
.study-card-panel :deep(.el-skeleton__item) {
  border-radius: 10px;
  background: var(--app-skeleton-base, rgba(37, 52, 74, 0.78)) !important;
}

.study-card-wrapper {
  display: grid;
  gap: 20px;
}

.study-card {
  min-height: 420px;
  padding: 32px;
  border: 1px solid rgba(56, 189, 248, 0.18);
  border-radius: 28px;
  background: linear-gradient(180deg, rgba(20, 55, 95, 0.42) 0%, rgba(15, 40, 75, 0.52) 100%);
  backdrop-filter: blur(12px);
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.study-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 18px 36px rgba(249, 115, 22, 0.2);
  border-color: rgba(249, 115, 22, 0.5);
}

.study-card__meta {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.study-card__badge {
  display: inline-flex;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(249, 115, 22, 0.12);
  color: #f97316;
  font-size: 13px;
}

.study-card__mode {
  display: inline-flex;
  align-items: center;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(148, 163, 184, 0.1);
  color: #cbd5e1;
  font-size: 13px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.study-card__body {
  margin-top: 28px;
  display: grid;
  justify-items: center;
  text-align: center;
}

.study-card__hint {
  margin: 0 0 14px;
  color: #cbd5e1;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.study-card__body h2 {
  margin: 0;
  font-size: 44px;
  color: #ffffff;
  text-shadow:
    0 0 12px rgba(255, 255, 255, 0.4),
    0 0 30px rgba(249, 115, 22, 0.25),
    0 1px 3px rgba(0, 0, 0, 0.35);
}

.study-card__phonetic {
  margin: 14px 0 0;
  color: #f97316;
  font-size: 20px;
  text-shadow:
    0 0 10px rgba(249, 115, 22, 0.5),
    0 0 20px rgba(249, 115, 22, 0.25);
}

.study-card__subtext {
  margin: 14px 0 0;
  color: #e2e8f0;
  font-size: 15px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.study-listen {
  margin-top: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  flex-wrap: wrap;
}

.study-listen__fallback {
  color: #cbd5e1;
  font-size: 14px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.study-options {
  margin-top: 28px;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.study-option {
  min-height: 64px;
  padding: 16px 18px;
  border: 1px solid rgba(56, 189, 248, 0.18);
  border-radius: 18px;
  background: rgba(20, 50, 85, 0.25);
  color: #e2e8f0;
  font-size: 16px;
  line-height: 1.6;
  cursor: pointer;
  transition: all 0.2s ease;
}

.study-option:hover:not(:disabled) {
  border-color: #fdba74;
  box-shadow: 0 10px 24px rgba(249, 115, 22, 0.2);
  transform: translateY(-1px);
}

.study-option:disabled {
  cursor: not-allowed;
}

.study-option--correct {
  border-color: #67c23a;
  background: #f0f9eb;
  color: #2f7d1c;
}

.study-option--wrong {
  border-color: #f56c6c;
  background: #fef0f0;
  color: #c45656;
}

.study-option--muted {
  opacity: 0.72;
}

.study-spell {
  margin-top: 28px;
  max-width: 520px;
  margin-left: auto;
  margin-right: auto;
}

.study-feedback {
  margin-top: 28px;
}

.study-feedback :deep(p) {
  margin: 4px 0;
}

.study-card__footer {
  margin-top: 32px;
  display: flex;
  justify-content: space-between;
  gap: 16px;
  color: #cbd5e1;
  font-size: 14px;
  text-shadow:
    0 0 8px rgba(148, 163, 184, 0.35),
    0 0 16px rgba(56, 189, 248, 0.15),
    0 1px 2px rgba(0, 0, 0, 0.25);
}

.study-actions {
  display: flex;
  justify-content: center;
  gap: 16px;
}

.study-pagination {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 768px) {
  .study-layout {
    grid-template-columns: 1fr;
  }

  .study-toolbar {
    position: static;
  }

  .study-page__header {
    flex-direction: column;
  }

  .study-page__actions {
    width: 100%;
    justify-content: flex-start;
  }

  .study-toolbar__field :deep(.el-select) {
    width: 100%;
  }

  .study-card {
    min-height: 360px;
    padding: 24px;
  }

  .study-card__body h2 {
    font-size: 34px;
  }

  .study-options {
    grid-template-columns: 1fr;
  }

  .study-card__footer,
  .study-actions,
  .study-pagination {
    flex-direction: column;
    align-items: stretch;
  }

  .study-page__actions :deep(.el-button),
  .study-actions :deep(.el-button) {
    width: 100%;
  }

  .study-mode-bar {
    align-items: stretch;
  }
}
</style>
