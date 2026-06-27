import http from './http'

export interface AdminAiConfig {
  baseUrl: string
  model: string
  apiKeyMasked?: string
  apiKeyConfigured: boolean
}

export interface AdminAiConfigUpdatePayload {
  baseUrl?: string
  model?: string
  apiKey?: string | null
}

export function getAdminAiConfig() {
  return http
    .get<AdminAiConfig>('/api/admin/ai-config')
    .then((response) => response.data)
}

export function updateAdminAiConfig(payload: AdminAiConfigUpdatePayload) {
  return http
    .put<null>('/api/admin/ai-config', payload)
    .then((response) => response.data)
}
