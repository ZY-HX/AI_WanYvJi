import http from './http'

export interface AdminUser {
  id: number
  username: string
  nickname: string
  email?: string
  phone?: string
  avatarUrl?: string
  role: string
  status: number
  createdAt?: string
  updatedAt?: string
}

export interface AdminUserDetail {
  userId: number
  username: string
  nickname: string
  email?: string
  phone?: string
  avatarUrl?: string
  role: string
  status: number
  createdAt?: string
  updatedAt?: string
  lastLoginAt?: string
  loginFailCount?: number
  // 学习配置
  studySessionSize?: number
  allowSameDayReview?: boolean
  // 学习统计
  totalStudySessions?: number
  totalWordsLearned?: number
  totalCorrectCount?: number
  totalWrongCount?: number
  accuracyRate?: number
  pendingReviewCount?: number
  masteredWordCount?: number
}

export interface PageResponse<T> {
  current: number
  size: number
  total: number
  records: T[]
}

export interface GetAdminUsersParams {
  current?: number
  size?: number
  status?: number
  startDate?: string
  endDate?: string
  keyword?: string
}

export function getAdminUsers(params: GetAdminUsersParams) {
  return http
    .get<PageResponse<AdminUser>>('/api/admin/users', { params })
    .then((response) => response.data)
}

export function getAdminUserDetail(userId: number) {
  return http
    .get<AdminUserDetail>(`/api/admin/users/${userId}`)
    .then((response) => response.data)
}

export function updateUserStatus(userId: number, status: number) {
  return http
    .put<void>(`/api/admin/users/${userId}/status`, null, { params: { status } })
    .then((response) => response.data)
}
