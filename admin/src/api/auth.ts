import http from './http'
import type { UserInfo } from '../stores/user'

export interface LoginPayload {
  username: string
  password: string
  rememberMe: boolean
}

export interface LoginResponse extends UserInfo {
  token: string
}

export function login(payload: LoginPayload) {
  return http.post<LoginResponse>('/api/auth/login', payload).then((response) => response.data)
}

export function logout() {
  return http.post<null>('/api/auth/logout').then((response) => response.data)
}

