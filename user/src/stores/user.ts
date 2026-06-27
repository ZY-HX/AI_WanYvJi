import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL as string | undefined)?.trim() || ''

export interface UserInfo {
  userId?: number
  username?: string
  email?: string
  nickname?: string
  role?: string
  avatarUrl?: string
  expiresAt?: number
  validityDays?: number
  renewLimit?: number
  renewCountRemaining?: number
}

const TOKEN_KEY = 'elm-user-token'
const USER_KEY = 'elm-user-info'

function readStoredValue(key: string) {
  return localStorage.getItem(key) ?? sessionStorage.getItem(key) ?? ''
}

function getActiveStorage() {
  if (localStorage.getItem(TOKEN_KEY)) {
    return localStorage
  }
  return sessionStorage
}

function safeParseUserInfo(value: string): UserInfo | null {
  if (!value) {
    return null
  }
  try {
    return JSON.parse(value) as UserInfo
  } catch {
    localStorage.removeItem(USER_KEY)
    sessionStorage.removeItem(USER_KEY)
    return null
  }
}

function parseTokenExpMs(token: string): number | null {
  if (!token) {
    return null
  }
  const parts = token.split('.')
  if (parts.length !== 3) {
    return null
  }
  try {
    const base64 = parts[1].replace(/-/g, '+').replace(/_/g, '/')
    const normalized = base64.padEnd(base64.length + ((4 - (base64.length % 4)) % 4), '=')
    const payload = JSON.parse(atob(normalized)) as { exp?: number }
    if (!payload.exp) {
      return null
    }
    return payload.exp * 1000
  } catch {
    return null
  }
}

function isTokenValid(token: string) {
  if (!token) {
    return false
  }
  const expMs = parseTokenExpMs(token)
  if (!expMs) {
    return true
  }
  return expMs > Date.now()
}

export const useUserStore = defineStore('user', () => {
  const token = ref(readStoredValue(TOKEN_KEY))
  const userInfo = ref<UserInfo | null>(safeParseUserInfo(readStoredValue(USER_KEY)))

  const isLoggedIn = computed(() => isTokenValid(token.value))
  const isGuest = computed(() => userInfo.value?.role === 'GUEST')
  const resolvedAvatarUrl = computed(() => {
    const value = userInfo.value?.avatarUrl
    if (!value) {
      return ''
    }
    if (/^https?:\/\//.test(value)) {
      return value
    }
    const base = API_BASE_URL.replace(/\/+$/, '')
    const path = value.replace(/^\/+/, '')
    return `${base}/${path}`
  })

  function setToken(value: string, rememberMe = true) {
    token.value = value
    localStorage.removeItem(TOKEN_KEY)
    sessionStorage.removeItem(TOKEN_KEY)
    const storage = rememberMe ? localStorage : sessionStorage
    storage.setItem(TOKEN_KEY, value)
  }

  function setUserInfo(value: UserInfo | null) {
    userInfo.value = value

    if (value) {
      localStorage.removeItem(USER_KEY)
      sessionStorage.removeItem(USER_KEY)
      getActiveStorage().setItem(USER_KEY, JSON.stringify(value))
      return
    }

    localStorage.removeItem(USER_KEY)
    sessionStorage.removeItem(USER_KEY)
  }

  function clear() {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(USER_KEY)
    sessionStorage.removeItem(TOKEN_KEY)
    sessionStorage.removeItem(USER_KEY)
  }

  return {
    token,
    userInfo,
    isLoggedIn,
    isGuest,
    resolvedAvatarUrl,
    setToken,
    setUserInfo,
    clear,
  }
})
