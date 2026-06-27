import type { AxiosProgressEvent } from 'axios'
import http from './http'

export interface WordBank {
  id: number
  userId: number
  name: string
  description?: string
  category?: string
  language: 'EN' | 'JA' | 'KO'
  wordCount: number
  isPublic: number
  creatorName?: string
  collected?: boolean
  editable?: boolean
  createdAt?: string
  updatedAt?: string
}

export interface PageResponse<T> {
  current: number
  size: number
  total: number
  records: T[]
}

export interface WordBankListParams {
  current?: number
  size?: number
  keyword?: string
  language?: 'EN' | 'JA' | 'KO'
}

export interface CreateWordBankPayload {
  name: string
  description: string
  language: 'EN' | 'JA' | 'KO'
}

export interface UpdateWordBankPayload {
  name: string
  description: string
  language: 'EN' | 'JA' | 'KO'
}

export interface WordImportFailure {
  lineNumber: number
  content: string
  reason: string
}

export interface WordImportResult {
  totalLines: number
  importedCount: number
  failedCount: number
  wordCount: number
  failedLines: WordImportFailure[]
}

export interface AddWordToWordBankPayload {
  english: string
  chinese: string
  phonetic?: string
  example?: string
}

export function getMyWordBanks(params: WordBankListParams) {
  return http
    .get<PageResponse<WordBank>>('/api/wordbanks', { params })
    .then((response) => response.data)
}

export function getPublicWordBanks(params: WordBankListParams) {
  return http
    .get<PageResponse<WordBank>>('/api/wordbanks/public', { params })
    .then((response) => response.data)
}

export function getCollectedWordBanks(params: WordBankListParams) {
  return http
    .get<PageResponse<WordBank>>('/api/wordbanks/collected', { params })
    .then((response) => response.data)
}

export function getWordBankDetail(id: number) {
  return http.get<WordBank>(`/api/wordbanks/${id}`).then((response) => response.data)
}

export function createWordBank(payload: CreateWordBankPayload) {
  return http.post<WordBank>('/api/wordbanks', payload).then((response) => response.data)
}

export function updateWordBank(id: number, payload: UpdateWordBankPayload) {
  return http.put<WordBank>(`/api/wordbanks/${id}`, payload).then((response) => response.data)
}

export function deleteWordBank(id: number) {
  return http.delete<null>(`/api/wordbanks/${id}`).then((response) => response.data)
}

export function importWordBankTxt(
  id: number,
  file: File,
  onUploadProgress?: (event: AxiosProgressEvent) => void,
) {
  const formData = new FormData()
  formData.append('file', file)

  return http
    .post<WordImportResult>(`/api/wordbanks/${id}/import`, formData, {
      timeout: 60000,
      onUploadProgress,
    })
    .then((response) => response.data)
}

export function submitWordBankReview(id: number) {
  return http.post<WordBank>(`/api/wordbanks/${id}/submit-review`).then((response) => response.data)
}

export function collectWordBank(id: number) {
  return http.post<null>(`/api/wordbanks/${id}/collect`).then((response) => response.data)
}

export function cancelCollectWordBank(id: number) {
  return http.delete<null>(`/api/wordbanks/${id}/collect`).then((response) => response.data)
}

export function addWordToMyWordBank(id: number, payload: AddWordToWordBankPayload) {
  return http
    .post<WordBank>(`/api/user/word-banks/${id}/add-word`, payload)
    .then((response) => response.data)
}

export function downloadWordBankAsTxt(id: number, fileName?: string): Promise<void> {
  return http
    .get(`/api/user/word-banks/${id}/download`, {
      responseType: 'blob',
    })
    .then((response) => {
      const blob = new Blob([response.data], { type: 'text/plain;charset=utf-8' })
      const url = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = fileName || `wordbank_${id}.txt`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(url)
    })
}
