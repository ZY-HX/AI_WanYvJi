<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { Microphone, VideoPause, Clock, DocumentCopy, Loading } from '@element-plus/icons-vue'
import dayjs from 'dayjs'
import {
  createTranslationSession,
  endTranslationSession,
  getTranslationSessionHistory,
  processAudioTranslate,
  LANGUAGE_OPTIONS,
  type TranslationLanguageOption,
  type TranslationSessionInfo,
  type TranslationSessionPageResponse,
  type AudioTranslateResult,
} from '../api/simultaneousTranslation'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()
const HISTORY_PAGE_SIZE = 8

const formRef = ref<FormInstance>()
const loading = ref(false)
const sessionCreating = ref(false)
const sessionEnding = ref(false)
const isRecording = ref(false)
const currentSessionId = ref<string | null>(null)
const durationSeconds = ref(0)
let durationTimer: number | undefined

let recognition: SpeechRecognition | null = null
let currentRecognitionText = ref('')

const form = reactive<{
  sourceLang: string
  targetLang: string
}>({
  sourceLang: 'ZH',
  targetLang: 'EN',
})

const formRules: FormRules<typeof form> = {
  sourceLang: [{ required: true, message: '请选择源语言', trigger: 'change' }],
  targetLang: [{ required: true, message: '请选择目标语言', trigger: 'change' }],
}

interface TranscriptItem {
  id: number
  sourceText: string
  targetText: string
  timestamp: number
  isTranslating: boolean
  sourceLangName: string
  targetLangName: string
}

const recognizedTexts = ref<TranscriptItem[]>([])
let transcriptIdCounter = 0
const historyLoading = ref(false)
const historyDeletingId = ref<number | null>(null)
const historyPage = ref<TranslationSessionPageResponse>({
  current: 1,
  size: HISTORY_PAGE_SIZE,
  total: 0,
  records: [],
})
const activeHistoryId = ref<number | null>(null)

const isGuest = computed(() => userStore.userInfo?.role === 'GUEST')
const canStartSession = computed(
  () => !isGuest.value && !isRecording.value && form.sourceLang && form.targetLang && form.sourceLang !== form.targetLang,
)
const formattedDuration = computed(() => {
  const minutes = Math.floor(durationSeconds.value / 60)
  const seconds = durationSeconds.value % 60
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
})
const latestResult = computed(() => (recognizedTexts.value.length > 0 ? recognizedTexts.value[recognizedTexts.value.length - 1] : null))
const sourceLangName = computed(() => LANGUAGE_OPTIONS.find(item => item.code === form.sourceLang)?.name || form.sourceLang)
const targetLangName = computed(() => LANGUAGE_OPTIONS.find(item => item.code === form.targetLang)?.name || form.targetLang)

function getSpeechRecognitionLanguage(langCode: string): string {
  const langMap: Record<string, string> = {
    ZH: 'zh-CN',
    EN: 'en-US',
    JA: 'ja-JP',
    KO: 'ko-KR',
    FR: 'fr-FR',
    DE: 'de-DE',
    ES: 'es-ES',
  }
  return langMap[langCode] || 'zh-CN'
}

function checkSpeechRecognitionSupport(): boolean {
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
  if (!SpeechRecognition) {
    ElMessage.error('您的浏览器不支持语音识别功能，请使用Chrome浏览器')
    return false
  }
  return true
}

onMounted(async () => {
  loading.value = true
  try {
    if (!isGuest.value) {
      await fetchHistory(1, HISTORY_PAGE_SIZE, false)
    }
  } finally {
    loading.value = false
  }
})

onBeforeUnmount(() => {
  stopSpeechRecognition()
  clearDurationTimer()
})

watch([() => form.sourceLang, () => form.targetLang], () => {
  if (form.sourceLang === form.targetLang && form.sourceLang) {
    ElMessage.warning('源语言和目标语言不能相同')
  }
})

async function handleStartSession() {
  if (isGuest.value) {
    ElMessage.warning('游客模式不支持同声翻译功能')
    return
  }

  if (!formRef.value) return

  if (!checkSpeechRecognitionSupport()) return

  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  if (form.sourceLang === form.targetLang) {
    ElMessage.warning('源语言和目标语言不能相同')
    return
  }

  sessionCreating.value = true
  try {
    const result = await createTranslationSession({
      sourceLang: form.sourceLang,
      targetLang: form.targetLang,
    })
    currentSessionId.value = result.sessionId
    recognizedTexts.value = []
    currentRecognitionText.value = ''
    durationSeconds.value = 0
    startDurationTimer()
    await startSpeechRecognition()
    ElMessage.success(`翻译会话已创建，开始${sourceLangName.value}语音识别`)
  } catch (error) {
    ElMessage.error(error instanceof Error ? error.message : '创建会话失败')
  } finally {
    sessionCreating.value = false
  }
}

async function handleEndSession() {
  if (!currentSessionId.value) return

  sessionEnding.value = true
  try {
    stopSpeechRecognition()
    clearDurationTimer()
    
    if (currentRecognitionText.value.trim()) {
      await translateAndAddTranscript(currentRecognitionText.value.trim())
    }
    
    await endTranslationSession(currentSessionId.value)
    ElMessage.success(`翻译会话已结束，时长 ${formattedDuration.value}`)
    currentSessionId.value = null
    await fetchHistory(1, HISTORY_PAGE_SIZE, false)
  } catch (error) {
    ElMessage.error(error instanceof Error ? error.message : '结束会话失败')
  } finally {
    sessionEnding.value = false
  }
}

async function startSpeechRecognition() {
  const SpeechRecognitionAPI = window.SpeechRecognition || window.webkitSpeechRecognition
  if (!SpeechRecognitionAPI) {
    ElMessage.error('您的浏览器不支持语音识别')
    return
  }

  recognition = new SpeechRecognitionAPI()
  recognition.lang = getSpeechRecognitionLanguage(form.sourceLang)
  recognition.interimResults = true
  recognition.continuous = true
  recognition.maxAlternatives = 1

  recognition.onstart = () => {
    isRecording.value = true
    console.log('语音识别已启动')
  }

  recognition.onresult = async (event: SpeechRecognitionEvent) => {
    let finalTranscript = ''
    let interimTranscript = ''

    for (let i = event.resultIndex; i < event.results.length; i++) {
      const result = event.results[i]
      if (result.isFinal) {
        finalTranscript += result[0].transcript
      } else {
        interimTranscript += result[0].transcript
      }
    }

    currentRecognitionText.value = finalTranscript || interimTranscript

    if (finalTranscript.trim()) {
      await translateAndAddTranscript(finalTranscript.trim())
      currentRecognitionText.value = ''
    }
  }

  recognition.onerror = (event: Event) => {
    console.error('语音识别错误:', event)
    const errorEvent = event as SpeechRecognitionErrorEvent
    if (errorEvent.error === 'no-speech') {
      console.log('未检测到语音')
    } else if (errorEvent.error === 'aborted') {
      console.log('语音识别已停止')
    } else {
      ElMessage.warning(`语音识别错误: ${errorEvent.error}`)
    }
  }

  recognition.onend = () => {
    if (isRecording.value) {
      try {
        recognition?.start()
      } catch (e) {
        console.warn('重启语音识别失败:', e)
        isRecording.value = false
      }
    }
  }

  try {
    recognition.start()
  } catch (error) {
    console.error('启动语音识别失败:', error)
    ElMessage.error('无法启动语音识别，请检查麦克风权限')
    isRecording.value = false
  }
}

function stopSpeechRecognition() {
  if (recognition) {
    recognition.onend = null
    recognition.stop()
    recognition = null
  }
  isRecording.value = false
}

async function translateAndAddTranscript(text: string) {
  if (!text.trim()) return

  const newItem: TranscriptItem = {
    id: ++transcriptIdCounter,
    sourceText: text,
    targetText: '',
    timestamp: Date.now(),
    isTranslating: true,
    sourceLangName: sourceLangName.value,
    targetLangName: targetLangName.value,
  }

  recognizedTexts.value.push(newItem)

  if (recognizedTexts.value.length > 50) {
    recognizedTexts.value = recognizedTexts.value.slice(-30)
  }

  try {
    const sourceLangCode = getTranslationApiLang(form.sourceLang)
    const targetLangCode = getTranslationApiLang(form.targetLang)

    const response = await fetch(
      `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${sourceLangCode}|${targetLangCode}`
    )
    
    const data = await response.json()
    
    let translation = ''
    
    if (data.responseStatus === 200 && data.responseData?.translatedText) {
      translation = data.responseData.translatedText
    }

    if (!translation || translation === text) {
      try {
        const fallbackResponse = await fetch(
          `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${targetLangCode}|${sourceLangCode}`
        )
        const fallbackData = await fallbackResponse.json()
        if (fallbackData.responseStatus === 200 && fallbackData.responseData?.translatedText) {
          translation = `[反向验证] ${fallbackData.responseData.translatedText}`
        }
      } catch (e) {
        console.warn('备用翻译失败:', e)
      }
    }

    if (!translation) {
      translation = `[${targetLangName.value}] ${text}`
    }

    if (currentSessionId.value) {
      try {
        await processAudioTranslate({
          audioData: '',
          format: 'text',
          sessionId: currentSessionId.value,
        })
      } catch (e) {
        console.log('后端记录保存:', e)
      }
    }

    const itemIndex = recognizedTexts.value.findIndex(item => item.id === newItem.id)
    if (itemIndex !== -1) {
      recognizedTexts.value[itemIndex].targetText = translation
      recognizedTexts.value[itemIndex].isTranslating = false
    }
  } catch (error) {
    console.error('翻译失败:', error)
    const itemIndex = recognizedTexts.value.findIndex(item => item.id === newItem.id)
    if (itemIndex !== -1) {
      recognizedTexts.value[itemIndex].targetText = '[网络错误，请检查连接]'
      recognizedTexts.value[itemIndex].isTranslating = false
    }
  }
}

function getTranslationApiLang(langCode: string): string {
  const langMap: Record<string, string> = {
    ZH: 'zh-CN',
    EN: 'en-GB',
    JA: 'ja-JP',
    KO: 'ko-KR',
    FR: 'fr-FR',
    DE: 'de-DE',
    ES: 'es-ES',
  }
  return langMap[langCode] || 'en-GB'
}

function startDurationTimer() {
  clearDurationTimer()
  durationTimer = window.setInterval(() => {
    durationSeconds.value++
  }, 1000)
}

function clearDurationTimer() {
  if (durationTimer) {
    clearInterval(durationTimer)
    durationTimer = undefined
  }
}

async function fetchHistory(current = historyPage.value.current, size = historyPage.value.size, preserveSelection = true) {
  if (isGuest.value) {
    historyPage.value = { current: 1, size: HISTORY_PAGE_SIZE, total: 0, records: [] }
    return
  }

  historyLoading.value = true
  try {
    const result = await getTranslationSessionHistory({ current, size })
    historyPage.value = result ?? { current, size, total: 0, records: [] }

    if (!preserveSelection || !activeHistoryId.value) {
      activeHistoryId.value = result?.records[0]?.id ?? null
    }
  } finally {
    historyLoading.value = false
  }
}

function formatTime(value?: string) {
  return value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-'
}

function copyText(text: string) {
  navigator.clipboard.writeText(text).then(() => ElMessage.success('已复制')).catch(() => ElMessage.warning('复制失败'))
}
</script>

<template>
  <div class="simultaneous-translation-page">
    <div class="st-page__header">
      <div>
        <h1>同声翻译</h1>
        <p>实时语音识别与智能翻译，支持多语言互译，适用于会议、直播、学习等多种场景。</p>
      </div>
      <div class="st-page__actions">
        <el-button @click="router.push('/')">返回首页</el-button>
        <el-button plain type="primary" @click="router.push('/ai-reading')">AI 阅读</el-button>
        <el-button plain @click="router.push('/study')">今日学习</el-button>
      </div>
    </div>

    <el-alert v-if="isGuest" title="游客模式不支持同声翻译功能，请注册或登录正式账号后使用。" type="warning" :closable="false" show-icon class="st-page__alert" />

    <div class="st-layout" v-loading="loading">
      <el-card class="st-control-panel" shadow="never">
        <template #header>
          <div class="st-card-header">
            <span>翻译设置</span>
            <el-tag v-if="currentSessionId" type="success" effect="plain">会话进行中</el-tag>
          </div>
        </template>

        <el-skeleton :loading="loading" animated :rows="5">
          <template #default>
            <el-form ref="formRef" :model="form" :rules="formRules" label-position="top">
              <el-form-item label="源语言（说话人）" prop="sourceLang">
                <el-select v-model="form.sourceLang" placeholder="请选择源语言" :disabled="isGuest || isRecording">
                  <el-option v-for="item in LANGUAGE_OPTIONS" :key="item.code" :label="`${item.flag} ${item.name}`" :value="item.code" />
                </el-select>
              </el-form-item>

              <el-form-item label="目标语言（翻译结果）" prop="targetLang">
                <el-select v-model="form.targetLang" placeholder="请选择目标语言" :disabled="isGuest || isRecording">
                  <el-option v-for="item in LANGUAGE_OPTIONS" :key="item.code" :label="`${item.flag} ${item.name}`" :value="item.code" />
                </el-select>
              </el-form-item>

              <div class="st-duration-display" v-if="isRecording">
                <el-icon><Clock /></el-icon>
                <span>{{ formattedDuration }}</span>
                <span class="st-recording-indicator"></span>
              </div>

              <div class="st-current-recognizing" v-if="isRecording && currentRecognitionText">
                <div class="st-current-recognizing__label">正在识别...</div>
                <div class="st-current-recognizing__text">{{ currentRecognitionText }}</div>
              </div>

              <el-button
                type="primary"
                size="large"
                class="st-start-btn"
                :class="{ 'st-start-btn--recording': isRecording }"
                :loading="sessionCreating"
                :disabled="!canStartSession"
                @click="handleStartSession"
              >
                <el-icon v-if="!sessionCreating"><Microphone /></el-icon>
                {{ isRecording ? '🎤 正在录音...' : '开始同声翻译' }}
              </el-button>

              <el-button
                v-if="isRecording"
                type="danger"
                size="large"
                class="st-end-btn"
                :loading="sessionEnding"
                @click="handleEndSession"
              >
                <el-icon><VideoPause /></el-icon>
                结束翻译
              </el-button>

              <div class="st-tip" v-if="!isRecording">
                <p>点击开始后将使用浏览器语音识别功能，请确保：</p>
                <p>① 使用 Chrome / Edge 浏览器以获得最佳体验</p>
                <p>② 允许浏览器访问麦克风权限</p>
                <p>③ 系统将自动识别语音并实时翻译为目标语言</p>
              </div>
            </el-form>
          </template>
        </el-skeleton>
      </el-card>

      <div class="st-main-area">
        <el-card class="st-result-panel" shadow="never">
          <template #header>
            <div class="st-card-header">
              <span>实时翻译结果</span>
              <el-tag v-if="isRecording" type="success" effect="dark">实时处理中</el-tag>
              <el-tag v-else type="info" effect="plain">等待开始</el-tag>
            </div>
          </template>

          <div v-if="!recognizedTexts.length && !isRecording" class="st-empty-state">
            <el-empty description="开始同声翻译后，识别文本和翻译结果将在此处显示。" />
          </div>

          <div v-else class="st-result-list">
            <TransitionGroup name="st-fade" tag="div" class="st-transcript-list">
              <div v-for="(item, index) in recognizedTexts" :key="item.id" class="st-transcript-item">
                <div class="st-transcript-item__header">
                  <span class="st-transcript-item__index">#{{ index + 1 }}</span>
                  <span class="st-transcript-item__time">{{ dayjs(item.timestamp).format('HH:mm:ss') }}</span>
                  <el-button text size="small" @click="copyText(`${item.sourceLangName}: ${item.sourceText}\n---\n${item.targetLangName}: ${item.targetText}`)">
                    <el-icon><DocumentCopy /></el-icon>
                  </el-button>
                </div>
                
                <div class="st-transcript-item__source">
                  <span class="st-lang-tag st-lang-tag--source">{{ item.sourceLangName }}</span>
                  <span class="st-text">{{ item.sourceText }}</span>
                </div>
                
                <div class="st-transcript-item__target">
                  <span class="st-lang-tag st-lang-tag--target">{{ item.targetLangName }}</span>
                  <span v-if="item.isTranslating" class="st-text st-text--loading">
                    <el-icon class="is-loading"><Loading /></el-icon>
                    翻译中...
                  </span>
                  <span v-else class="st-text">{{ item.targetText }}</span>
                </div>
              </div>
            </TransitionGroup>
          </div>
        </el-card>

        <el-card class="st-history-panel" shadow="never">
          <template #header>
            <div class="st-card-header">
              <span>历史会话</span>
              <el-button text :loading="historyLoading" @click="fetchHistory(historyPage.current, historyPage.size, true)">刷新</el-button>
            </div>
          </template>

          <div class="st-history-subtitle">展示您的历史同声翻译会话记录。</div>

          <el-empty v-if="!historyPage.records.length" description="暂无历史记录，开始一次同声翻译吧。" />

          <div v-else class="st-history-list" v-loading="historyLoading">
            <button
              v-for="item in historyPage.records"
              :key="item.id"
              type="button"
              class="st-history-item"
              :class="{ 'st-history-item--active': activeHistoryId === item.id }"
              @click="activeHistoryId = item.id"
            >
              <div class="st-history-item__content">
                <strong>{{ item.sourceLangName }} → {{ item.targetLangName }}</strong>
                <p>{{ item.duration }}秒 · {{ item.status === 'ACTIVE' ? '进行中' : '已结束' }}</p>
                <p>{{ formatTime(item.createdAt) }}</p>
              </div>
            </button>
          </div>

          <div v-if="historyPage.total > historyPage.size" class="st-history-pagination">
            <el-pagination
              background
              layout="prev, pager, next"
              :current-page="historyPage.current"
              :page-size="historyPage.size"
              :total="historyPage.total"
              @current-change="(page: number) => fetchHistory(page, historyPage.size, false)"
            />
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<style scoped>
.simultaneous-translation-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(20px, 3vw, 40px) clamp(16px, 3vw, 24px) 56px;
  background: linear-gradient(180deg, #f0f4ff 0%, #e8efff 100%);
}

.st-page__header,
.st-page__alert,
.st-layout {
  max-width: 1200px;
  margin: 0 auto;
}

.st-page__header {
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  gap: 16px;
}

.st-page__header h1 {
  margin: 0 0 8px;
  font-size: 30px;
  color: #1f2d3d;
}

.st-page__header p {
  margin: 0;
  color: #5b6475;
}

.st-page__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.st-page__alert {
  margin-bottom: 20px;
}

.st-layout {
  display: grid;
  grid-template-columns: 360px minmax(0, 1fr);
  gap: 20px;
  align-items: start;
}

.st-control-panel,
.st-result-panel,
.st-history-panel {
  border-radius: 20px;
}

.st-main-area {
  display: grid;
  gap: 20px;
}

.st-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.st-duration-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 18px;
  margin-bottom: 16px;
  border-radius: 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  font-size: 28px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  position: relative;
}

.st-recording-indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #ff4757;
  animation: blink 1s ease-in-out infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}

.st-current-recognizing {
  margin-bottom: 16px;
  padding: 14px 16px;
  border-radius: 14px;
  background: linear-gradient(180deg, #fff5e6 0%, #ffe8cc 100%);
  border: 1px solid #ffd591;
}

.st-current-recognizing__label {
  font-size: 13px;
  color: #ad6800;
  font-weight: 600;
  margin-bottom: 6px;
}

.st-current-recognizing__text {
  font-size: 15px;
  color: #1f2d3d;
  line-height: 1.6;
}

.st-start-btn {
  width: 100%;
  height: 54px;
  font-size: 17px;
  border-radius: 16px;
  transition: all 0.3s ease;
}

.st-start-btn--recording {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  animation: pulse-glow 2s ease-in-out infinite;
}

@keyframes pulse-glow {
  0%, 100% { box-shadow: 0 0 0 0 rgba(102, 126, 234, 0.4); }
  50% { box-shadow: 0 0 0 14px rgba(102, 126, 234, 0); }
}

.st-end-btn {
  width: 100%;
  height: 48px;
  font-size: 15px;
  border-radius: 14px;
  margin-top: 12px;
}

.st-tip {
  margin-top: 16px;
  padding: 14px;
  border-radius: 14px;
  background: #f7faff;
  border: 1px solid #dbe5ff;
}

.st-tip p {
  margin: 5px 0;
  color: #6b7280;
  font-size: 13px;
  line-height: 1.6;
}

.st-empty-state {
  padding: 40px 0;
}

.st-result-list {
  max-height: 550px;
  overflow-y: auto;
  padding-right: 8px;
}

.st-transcript-list {
  display: grid;
  gap: 16px;
}

.st-transcript-item {
  padding: 18px 20px;
  border-radius: 18px;
  background: linear-gradient(180deg, #ffffff 0%, #fafbff 100%);
  border: 1px solid #e8ecff;
  box-shadow: 0 2px 10px rgba(56, 91, 190, 0.05);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.st-transcript-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(56, 91, 190, 0.1);
}

.st-transcript-item__header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 14px;
  color: #9bb8ff;
  font-size: 13px;
}

.st-transcript-item__index {
  font-weight: 700;
  color: #6a94ff;
  background: #eef4ff;
  padding: 2px 10px;
  border-radius: 10px;
}

.st-transcript-item__time {
  margin-left: auto;
}

.st-transcript-item__source,
.st-transcript-item__target {
  display: flex;
  gap: 10px;
  align-items: flex-start;
  line-height: 1.7;
}

.st-transcript-item__source {
  margin-bottom: 10px;
}

.st-transcript-item__target {
  padding: 12px 14px;
  border-radius: 14px;
  background: linear-gradient(180deg, #f0fdf4 0%, #ecfdf5 100%);
  border: 1px solid #bbf7d0;
}

.st-lang-tag {
  flex-shrink: 0;
  padding: 3px 10px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 700;
}

.st-lang-tag--source {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
}

.st-lang-tag--target {
  background: linear-gradient(135deg, #38bdf8 0%, #0ea5e9 100%);
  color: #fff;
}

.st-text {
  font-size: 15px;
  color: #1f2d3d;
  word-break: break-word;
}

.st-text--loading {
  color: #166534;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.st-history-subtitle {
  margin-bottom: 12px;
  color: #6b7280;
  font-size: 13px;
}

.st-history-list {
  display: grid;
  gap: 10px;
}

.st-history-item {
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
  transition: all 0.2s ease;
}

.st-history-item:hover {
  transform: translateY(-1px);
  border-color: #9bb8ff;
  box-shadow: 0 8px 24px rgba(56, 91, 190, 0.06);
}

.st-history-item--active {
  border-color: #6a94ff;
  background: #eef4ff;
}

.st-history-item__content,
.st-history-item__side {
  display: grid;
  gap: 4px;
}

.st-history-item strong {
  color: #1f2d3d;
  font-size: 15px;
}

.st-history-item p,
.st-history-item span {
  margin: 4px 0 0;
  color: #6b7280;
  font-size: 13px;
}

.st-history-pagination {
  margin-top: 16px;
  display: flex;
  justify-content: center;
}

.st-fade-enter-active {
  transition: all 0.4s ease-out;
}

.st-fade-leave-active {
  transition: all 0.2s ease-in;
}

.st-fade-enter-from {
  opacity: 0;
  transform: translateY(12px);
}

.st-fade-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}

@media (max-width: 960px) {
  .st-page__header {
    flex-direction: column;
  }

  .st-page__actions {
    width: 100%;
    flex-wrap: wrap;
    justify-content: flex-start;
  }

  .st-layout {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .simultaneous-translation-page {
    padding: 28px 16px 40px;
  }
}
</style>
