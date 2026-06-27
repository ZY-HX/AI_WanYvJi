import http from './http'

export interface WordBank {
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

export interface GetPendingWordBanksParams {
  current?: number
  size?: number
}

export interface WordBankAuditPayload {
  approved: boolean
  reason?: string
}

export function getPendingWordBanks(params: GetPendingWordBanksParams) {
  return http
    .get<PageResponse<WordBank>>('/api/admin/wordbanks/pending', { params })
    .then((response) => response.data)
}

export function auditWordBank(id: number, payload: WordBankAuditPayload) {
  return http
    .post<WordBank>(`/api/admin/wordbanks/${id}/audit`, payload)
    .then((response) => response.data)
}

