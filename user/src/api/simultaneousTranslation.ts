import http, { type ApiResult } from './http'

export interface TranslationLanguageOption {
  code: string
  name: string
  flag?: string
}

export interface TranslationSessionInfo {
  id: number
  sessionId: string
  sourceLang: string
  targetLang: string
  status: string
  duration: number
  sourceLangName: string
  targetLangName: string
  createdAt?: string
}

export interface TranslationSessionPageResponse {
  current: number
  size: number
  total: number
  records: TranslationSessionInfo[]
}

export interface CreateSessionPayload {
  sourceLang: string
  targetLang: string
}

export interface AudioTranslatePayload {
  audioData: string
  format?: string
  sessionId?: string
}

export interface AudioTranslateResult {
  text: string
  translation: string
  confidence: string
  timestamp: number
  isFinal: boolean
}

export const LANGUAGE_OPTIONS: TranslationLanguageOption[] = [
  { code: 'ZH', name: '中文', flag: '🇨🇳' },
  { code: 'EN', name: '英语', flag: '🇺🇸' },
  { code: 'JA', name: '日语', flag: '🇯🇵' },
  { code: 'KO', name: '韩语', flag: '🇰🇷' },
  { code: 'FR', name: '法语', flag: '🇫🇷' },
  { code: 'DE', name: '德语', flag: '🇩🇪' },
  { code: 'ES', name: '西班牙语', flag: '🇪🇸' },
]

export function createTranslationSession(data: CreateSessionPayload) {
  return http
    .post<TranslationSessionInfo>('/api/translation/session', data)
    .then((response) => response.data)
}

export function endTranslationSession(sessionId: string) {
  return http
    .post<null>(`/api/translation/session/${sessionId}/end`)
    .then((response) => response.data)
}

export function getTranslationSessionHistory(params: { current?: number; size?: number }) {
  return http
    .get<TranslationSessionPageResponse>('/api/translation/sessions', { params })
    .then((response) => response.data)
}

export function processAudioTranslate(data: AudioTranslatePayload) {
  return http
    .post<AudioTranslateResult>('/api/translation/audio', data)
    .then((response) => response.data)
}
