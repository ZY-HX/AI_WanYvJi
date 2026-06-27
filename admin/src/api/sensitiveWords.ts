import http from './http'

export interface SensitiveWord {
  id: number
  word: string
  status: number
  createdAt?: string
  updatedAt?: string
}

export interface PageResponse<T> {
  current: number
  size: number
  total: number
  records: T[]
}

export interface GetSensitiveWordsParams {
  current?: number
  size?: number
  status?: number
  keyword?: string
}

export interface SensitiveWordPayload {
  word?: string
  status?: number
}

export function getSensitiveWords(params: GetSensitiveWordsParams) {
  return http
    .get<PageResponse<SensitiveWord>>('/api/admin/sensitive-words', { params })
    .then((response) => response.data)
}

export function createSensitiveWord(payload: SensitiveWordPayload) {
  return http
    .post<SensitiveWord>('/api/admin/sensitive-words', payload)
    .then((response) => response.data)
}

export function updateSensitiveWord(id: number, payload: SensitiveWordPayload) {
  return http
    .put<SensitiveWord>(`/api/admin/sensitive-words/${id}`, payload)
    .then((response) => response.data)
}

export function deleteSensitiveWord(id: number) {
  return http
    .delete<null>(`/api/admin/sensitive-words/${id}`)
    .then((response) => response.data)
}
