import http from './http'

export interface ErrorBookItem {
  id: number
  wordId: number
  wordBankId: number
  wordBankName: string
  english: string
  phonetic?: string
  chinese: string
  example?: string
  errorType: string
  errorTimes: number
  isMastered: number
  createdAt?: string
  updatedAt?: string
}

export interface ErrorBookPageResponse<T> {
  current: number
  size: number
  total: number
  records: T[]
}

export interface ErrorBookListParams {
  current?: number
  size?: number
  wordBankId?: number
  errorType?: string
  is_mastered?: number
}

export interface ErrorBookClearParams {
  wordBankId?: number
  errorType?: string
  isMastered?: number
}

export function getErrorBookList(params: ErrorBookListParams) {
  return http
    .get<ErrorBookPageResponse<ErrorBookItem>>('/api/error-book', { params })
    .then((response) => response.data)
}

export function markErrorBookMastered(id: number) {
  return http.put<null>(`/api/error-book/${id}/master`).then((response) => response.data)
}

export function clearErrorBook(params: ErrorBookClearParams) {
  return http.post<number>('/api/user/error-book/clear', params).then((response) => response.data)
}
