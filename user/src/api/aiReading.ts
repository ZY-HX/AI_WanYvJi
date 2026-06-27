import http, { type ApiResult } from './http'
import { pinia } from '../stores'
import { useUserStore } from '../stores/user'

export type AiDifficulty = 'EASY' | 'MEDIUM' | 'HARD'
export type AiLength = 'SHORT' | 'MEDIUM' | 'LONG'
export type AiApiKeySource = 'SYSTEM' | 'CUSTOM'
export type AiConfigMode = 'AUTO' | 'PROVIDER' | 'MANUAL'

export interface AiWordBankOption {
  id: number
  name: string
  category?: string
  language?: 'EN' | 'JA' | 'KO'
  wordCount: number
  isPublic: number
}

export interface AiArticleQuota {
  totalQuota: number
  usedCount: number
  remainingCount: number
  resetTime?: string
  systemApiKeyConfigured?: boolean
  defaultBaseUrl?: string
  defaultModel?: string
}

export interface AiProviderOption {
  providerCode: string
  providerName: string
  baseUrl: string
  defaultModel: string
  adapterType: string
  recommended?: boolean
}

export interface AiApiKeyAdaptResponse {
  providerCode: string
  providerName: string
  baseUrl: string
  defaultModel: string
  adapterType: string
  matched: boolean
  usedFallback: boolean
  reason: string
}

export interface AiTestConnectionResponse {
  success: boolean
  providerCode: string
  providerName: string
  detectedBaseUrl: string
  detectedModel: string
  message: string
  responseTimeMs?: number
}

export interface AiArticleHighlightWord {
  wordId: number
  english: string
  chinese: string
}

export interface GenerateAiArticlePayload {
  wordBankId: number
  theme?: string
  difficulty: AiDifficulty
  length: AiLength
  apiKeySource: AiApiKeySource
  customApiKey?: string
  configMode: AiConfigMode
  providerCode?: string
  apiBaseUrl?: string
  model?: string
}

export interface AiArticleGenerateResponse {
  logId: number
  wordBankId: number
  theme: string
  difficulty: AiDifficulty
  length: AiLength
  content: string
  highlightWords: AiArticleHighlightWord[]
  duration: number
  generatedAt?: string
  quota: AiArticleQuota
}

export interface AiArticleStreamProgressEvent {
  stage: string
  message: string
  progress: number
}

export interface AiArticleStreamErrorEvent {
  code: number
  message: string
}

export interface AiArticleHistoryItem {
  id: number
  wordBankId?: number
  wordBankName: string
  theme: string
  difficulty: AiDifficulty
  length: AiLength
  duration: number
  createdAt?: string
}

export interface AiArticleHistoryDetail extends AiArticleHistoryItem {
  content: string
  highlightWords: AiArticleHighlightWord[]
  translation?: string
}

export interface AiArticleHistoryPageResponse<T> {
  current: number
  size: number
  total: number
  records: T[]
}

export interface AiArticleHistoryListParams {
  current?: number
  size?: number
}

export function getAiReadingWordBanks(language?: 'EN' | 'JA' | 'KO') {
  return http
    .get<AiWordBankOption[]>('/api/study/wordbanks', {
      params: { language },
    })
    .then((response) => response.data)
}

export function getAiArticleQuota() {
  return http
    .get<AiArticleQuota>('/api/ai/article/quota')
    .then((response) => response.data)
}

export function getAiProviderOptions() {
  return http
    .get<AiProviderOption[]>('/api/ai/article/providers')
    .then((response) => response.data)
}

export function adaptAiApiKey(data: { apiKeySource: AiApiKeySource; customApiKey?: string }) {
  return http
    .post<AiApiKeyAdaptResponse>('/api/ai/article/adapt', data)
    .then((response) => response.data)
}

export function testAiConnection(data: { apiKey: string; baseUrl?: string; model?: string }) {
  return http
    .post<AiTestConnectionResponse>('/api/ai/article/test-connection', data)
    .then((response) => response.data)
}

export async function generateAiArticleStream(
  data: GenerateAiArticlePayload,
  handlers: {
    onProgress?: (event: AiArticleStreamProgressEvent) => void
    onChunk?: (content: string) => void
    onComplete?: (result: AiArticleGenerateResponse) => void
    onAbort?: () => void
  },
  signal?: AbortSignal,
) {
  const userStore = useUserStore(pinia)
  const endpoint = resolveApiEndpoint('/api/user/ai/generate-article')
  
  const controller = new AbortController()
  if (signal?.aborted) {
    handlers.onAbort?.()
    throw new DOMException('请求已取消', 'AbortError')
  }
  signal?.addEventListener('abort', () => controller.abort(), { once: true })

  let response: Response
  try {
    response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'text/event-stream',
        ...(userStore.token ? { Authorization: `Bearer ${userStore.token}` } : {}),
      },
      body: JSON.stringify(data),
      signal: controller.signal,
    })
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      handlers.onAbort?.()
      throw new Error('生成请求已取消')
    }
    if (error instanceof TypeError && error.message.includes('fetch')) {
      throw new Error('网络连接失败，请检查网络后重试')
    }
    throw error
  }

  const contentType = response.headers.get('content-type') ?? ''
  if (contentType.includes('application/json')) {
    const result = (await response.json()) as ApiResult<AiArticleGenerateResponse | null>
    if (result.code !== 200) {
      throw new Error(result.message || '文章生成失败')
    }
    if (!result.data) {
      throw new Error('文章生成结果为空')
    }
    handlers.onComplete?.(result.data)
    return result.data
  }

  if (!response.ok) {
    const message = await response.text()
    throw new Error(message || '文章生成失败')
  }

  if (!response.body) {
    throw new Error('浏览器当前不支持流式响应')
  }

  const reader = response.body.getReader()
  const decoder = new TextDecoder()
  let buffer = ''
  let completedResult: AiArticleGenerateResponse | null = null

  try {
    while (true) {
      if (signal?.aborted) {
        handlers.onAbort?.()
        reader.cancel()
        throw new DOMException('请求已取消', 'AbortError')
      }

      const { done, value } = await reader.read()
      if (done) {
        break
      }

      buffer += decoder.decode(value, { stream: true }).replace(/\r\n/g, '\n')
      let boundaryIndex = buffer.indexOf('\n\n')
      while (boundaryIndex !== -1) {
        const rawEvent = buffer.slice(0, boundaryIndex).trim()
        buffer = buffer.slice(boundaryIndex + 2)
        if (rawEvent) {
          const parsed = parseSseEvent(rawEvent)
          if (parsed.event === 'progress') {
            handlers.onProgress?.(parsed.data as AiArticleStreamProgressEvent)
          } else if (parsed.event === 'chunk') {
            handlers.onChunk?.((parsed.data as { content?: string }).content ?? '')
          } else if (parsed.event === 'complete') {
            completedResult = parsed.data as AiArticleGenerateResponse
            handlers.onComplete?.(completedResult)
          } else if (parsed.event === 'error') {
            const errorPayload = parsed.data as AiArticleStreamErrorEvent
            throw new Error(errorPayload.message || '文章生成失败')
          }
        }
        boundaryIndex = buffer.indexOf('\n\n')
      }
    }
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      handlers.onAbort?.()
      throw new Error('生成请求已取消')
    }
    reader.cancel().catch(() => {})
    throw error
  }

  if (buffer.trim()) {
    const parsed = parseSseEvent(buffer.trim())
    if (parsed.event === 'complete') {
      completedResult = parsed.data as AiArticleGenerateResponse
      handlers.onComplete?.(completedResult)
    } else if (parsed.event === 'error') {
      const errorPayload = parsed.data as AiArticleStreamErrorEvent
      throw new Error(errorPayload.message || '文章生成失败')
    }
  }

  if (!completedResult) {
    throw new Error('文章生成中断，请重试')
  }
  return completedResult
}

function resolveApiEndpoint(path: string) {
  const baseURL = (http.defaults.baseURL as string | undefined)?.trim()
  if (baseURL && /^https?:\/\//i.test(baseURL)) {
    return new URL(path, baseURL).toString()
  }
  if (!baseURL || baseURL === '/') {
    return new URL(path, window.location.origin).toString()
  }
  return new URL(path, new URL(baseURL, window.location.origin)).toString()
}

function parseSseEvent(rawEvent: string) {
  const lines = rawEvent.split('\n')
  let event = 'message'
  const dataLines: string[] = []

  for (const line of lines) {
    if (line.startsWith('event:')) {
      event = line.slice(6).trim()
      continue
    }
    if (line.startsWith('data:')) {
      dataLines.push(line.slice(5).trim())
    }
  }

  const dataText = dataLines.join('\n')
  return {
    event,
    data: dataText ? JSON.parse(dataText) : null,
  }
}

export function getAiArticleHistory(params: AiArticleHistoryListParams) {
  return http
    .get<AiArticleHistoryPageResponse<AiArticleHistoryItem>>('/api/ai/article/history', { params })
    .then((response) => response.data)
}

export function getAiArticleDetail(id: number) {
  return http.get<AiArticleHistoryDetail>(`/api/ai/article/${id}`).then((response) => response.data)
}

export function deleteAiArticle(id: number) {
  return http.delete<null>(`/api/ai/article/${id}`).then((response) => response.data)
}

export interface AiArticleTranslatePayload {
  customApiKey?: string
  apiBaseUrl?: string
  model?: string
}

export function translateAiArticle(id: number, data: AiArticleTranslatePayload) {
  return http
    .post<string>(`/api/ai/article/${id}/translate`, data)
    .then((response) => response.data)
}

export interface WordLookupPayload {
  word: string
  language?: 'EN' | 'JA' | 'KO'
  customApiKey?: string
  apiBaseUrl?: string
  model?: string
}

export interface WordLookupResponse {
  english: string
  chinese: string
  phonetic?: string
}

export function lookupWordTranslation(data: WordLookupPayload) {
  return http
    .post<WordLookupResponse>('/api/ai/article/word/lookup', data)
    .then((response) => response.data)
}
