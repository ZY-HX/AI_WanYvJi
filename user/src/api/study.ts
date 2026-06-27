import http, { type ApiResult } from './http'
import { pinia } from '../stores'
import { useUserStore } from '../stores/user'

export interface StudyWordBankOption {
  id: number
  name: string
  category?: string
  language: 'EN' | 'JA' | 'KO'
  wordCount: number
  isPublic: number
}

export interface StudyWord {
  recordId: number
  wordId: number
  wordBankId: number
  studyMode: string
  nextReviewTime?: string
  english: string
  phonetic?: string
  chinese: string
  example?: string
}

export interface StudyOption {
  wordId: number
  english: string
  chinese: string
}

export interface StudyPageResponse<T> {
  current: number
  size: number
  total: number
  records: T[]
}

export interface StudyResultRequest {
  recordId: number
  wordId: number
  correct: boolean
  mode: string
}

export interface StudyResultResponse {
  recordId: number
  wordId: number
  wordBankId: number
  studyMode: string
  correctCount: number
  wrongCount: number
  reviewCount: number
  nextReviewTime?: string
}

export interface GetTodayStudyParams {
  wordBankId: number
  mode?: string
  current?: number
}

export function getStudyWordBanks(language?: 'EN' | 'JA' | 'KO') {
  return http
    .get<StudyWordBankOption[]>('/api/study/wordbanks', {
      params: { language },
    })
    .then((response) => response.data)
}

export function getTodayStudyWords(params: GetTodayStudyParams) {
  return http
    .get<StudyPageResponse<StudyWord>>('/api/study/today', { params })
    .then((response) => response.data)
}

export interface GetReviewParams {
  wordBankId: number
  current?: number
  size?: number
}

export function getReviewWords(params: GetReviewParams) {
  return http
    .get<StudyPageResponse<StudyWord>>('/api/study/review', { params })
    .then((response) => response.data)
}

export function getStudyQuestionOptions(wordBankId: number, currentWordId?: number) {
  return http
    .get<StudyOption[]>('/api/study/options', {
      params: { wordBankId, currentWordId },
    })
    .then((response) => response.data)
}

export function submitStudyResult(wordBankId: number, data: StudyResultRequest) {
  return http
    .post<StudyResultResponse>(`/api/user/study/${wordBankId}/submit`, data)
    .then((response) => response.data)
}

export function resetStudyPlan(wordBankId: number) {
  return http.post<number>(`/api/user/study/${wordBankId}/reset`).then((response) => response.data)
}

export async function downloadStudyRecordCsv(wordBankId: number) {
  const userStore = useUserStore(pinia)
  const endpoint = new URL('/api/user/export/study-records', http.defaults.baseURL ?? window.location.origin)
  endpoint.searchParams.set('wordBankId', String(wordBankId))

  const response = await fetch(endpoint.toString(), {
    method: 'GET',
    headers: {
      Accept: 'text/csv',
      ...(userStore.token ? { Authorization: `Bearer ${userStore.token}` } : {}),
    },
  })

  if (response.ok) {
    return {
      blob: await response.blob(),
      fileName: resolveFilename(response.headers.get('content-disposition') ?? undefined),
    }
  }

  const errorMessage = await resolveExportErrorMessage(response)
  throw new Error(errorMessage || '导出学习记录失败')
}

async function resolveExportErrorMessage(response: Response) {
  const contentType = response.headers.get('content-type') ?? ''
  if (contentType.includes('application/json')) {
    const result = (await response.json()) as Partial<ApiResult<unknown>>
    return typeof result.message === 'string' && result.message ? result.message : '导出学习记录失败'
  }

  const text = await response.text()
  return text || '导出学习记录失败'
}

function resolveFilename(contentDisposition?: string) {
  if (!contentDisposition) {
    return 'study_record.csv'
  }

  const utf8Match = contentDisposition.match(/filename\*=UTF-8''([^;]+)/i)
  if (utf8Match?.[1]) {
    return decodeURIComponent(utf8Match[1])
  }

  const plainMatch = contentDisposition.match(/filename="?([^"]+)"?/i)
  if (plainMatch?.[1]) {
    return plainMatch[1]
  }

  return 'study_record.csv'
}
