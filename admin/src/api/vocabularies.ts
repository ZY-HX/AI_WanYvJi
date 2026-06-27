import http from './http'

export interface Vocabulary {
  id: number
  userId: number
  name: string
  description?: string
  category?: string
  wordCount: number
  isPublic: number
  creatorName?: string
  createdAt?: string
  updatedAt?: string
}

export interface PageResponse<T> {
  current: number
  size: number
  total: number
  records: T[]
}

export interface GetVocabulariesParams {
  current?: number
  size?: number
}

export interface CreateVocabularyPayload {
  name: string
  description?: string
  category: string
  language?: string
}

export interface UpdateVocabularyPayload {
  name: string
  description?: string
  category: string
  language?: string
}

export function getPublicVocabularies(params: GetVocabulariesParams) {
  return http
    .get<PageResponse<Vocabulary>>('/api/admin/vocabularies', { params })
    .then((response) => response.data)
}

export function getVocabularyDetail(id: number) {
  return http
    .get<Vocabulary>(`/api/admin/vocabularies/${id}`)
    .then((response) => response.data)
}

export function createVocabulary(payload: CreateVocabularyPayload) {
  return http
    .post<Vocabulary>('/api/admin/vocabularies', payload)
    .then((response) => response.data)
}

export function updateVocabulary(id: number, payload: UpdateVocabularyPayload) {
  return http
    .put<Vocabulary>(`/api/admin/vocabularies/${id}`, payload)
    .then((response) => response.data)
}

export function deleteVocabulary(id: number) {
  return http
    .delete<void>(`/api/admin/vocabularies/${id}`)
    .then((response) => response.data)
}
