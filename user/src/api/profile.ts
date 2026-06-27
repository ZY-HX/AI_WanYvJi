import http from './http'
import type { UploadRequestOptions } from 'element-plus'

export interface UserProfile {
  userId: number
  username: string
  nickname?: string
  email: string
  phone?: string
  role: string
  avatarUrl?: string
  studySessionSize?: number
  allowSameDayReview?: boolean
  createdAt?: string
}

export interface UpdateProfilePayload {
  username: string
  nickname: string
  email: string
  studySessionSize: number
  allowSameDayReview: boolean
}

export interface ChangePasswordPayload {
  oldPassword: string
  newPassword: string
  confirmPassword: string
}

export interface AvatarUploadResponse {
  avatarUrl: string
}

export function getProfile() {
  return http.get<UserProfile>('/api/user/profile').then((response) => response.data)
}

export function updateProfile(payload: UpdateProfilePayload) {
  return http.put<UserProfile>('/api/user/profile', payload).then((response) => response.data)
}

export function changePassword(payload: ChangePasswordPayload) {
  return http.post<null>('/api/user/change-password', payload).then((response) => response.data)
}

export function uploadAvatar(file: UploadRequestOptions['file']) {
  const formData = new FormData()
  formData.append('file', file)

  return http
    .post<AvatarUploadResponse>('/api/user/avatar', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
    .then((response) => response.data)
}
