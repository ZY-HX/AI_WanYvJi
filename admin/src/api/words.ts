import http from './http'

export interface Word {
  id: number
  wordBankId: number
  english: string
  phonetic: string
  chinese: string
  example: string
  createdAt: string
  updatedAt: string
}

export interface WordCreatePayload {
  english: string
  phonetic?: string
  chinese: string
  example?: string
}

export interface WordUpdatePayload {
  english: string
  phonetic?: string
  chinese: string
  example?: string
}

export function getAdminWords(wordBankId: number, params: { current: number; size: number }) {
  return http.get('/api/admin/words', { params: { wordBankId, ...params } })
}

export function getAdminWordDetail(wordId: number) {
  return http.get(`/api/admin/words/${wordId}`)
}

export function createAdminWord(wordBankId: number, data: WordCreatePayload) {
  return http.post('/api/admin/words', data, { params: { wordBankId } })
}

export function updateAdminWord(wordId: number, data: WordUpdatePayload) {
  return http.put(`/api/admin/words/${wordId}`, data)
}

export function deleteAdminWord(wordId: number) {
  return http.delete(`/api/admin/words/${wordId}`)
}

export interface WordImportResult {
  totalCount: number
  successCount: number
  failCount: number
  failures: Array<{
    lineNumber: number
    content: string
    reason: string
  }>
}

export function importWordsFromFile(wordBankId: number, file: File) {
  const formData = new FormData()
  formData.append('file', file)
  return http.post('/api/admin/words/import', formData, {
    params: { wordBankId },
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
