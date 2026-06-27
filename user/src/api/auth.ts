import http from './http'
import type { UserInfo } from '../stores/user'

export interface RegisterPayload {
  username: string
  nickname?: string
  email: string
  password: string
  confirmPassword: string
}

export interface LoginPayload {
  username: string
  password: string
  rememberMe: boolean
}

export interface LoginResponse extends UserInfo {
  token: string
}

export interface GuestLoginResponse extends UserInfo {
  token: string
}

export function register(payload: RegisterPayload) {
  return http.post<null>('/api/auth/register', payload).then((response) => response.data)
}

export function login(payload: LoginPayload) {
  return http.post<LoginResponse>('/api/auth/login', payload).then((response) => response.data)
}

export function guestLogin() {
  return http.post<GuestLoginResponse>('/api/auth/guest').then((response) => response.data)
}

export function logout() {
  return http.post<null>('/api/auth/logout').then((response) => response.data)
}

export function renewGuestToken(token: string) {
  return http
    .post<GuestLoginResponse>('/api/auth/guest/renew', { token })
    .then((response) => response.data)
}

export function getCurrentUser() {
  return http.get<UserInfo>('/api/users/me').then((response) => response.data)
}

export function healthCheck() {
  return http.get<string>('/api/health').then((response) => response.data)
}
