import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

export interface UserInfo {
  userId?: number
  username?: string
  email?: string
  nickname?: string
  role?: string
  avatarUrl?: string
}

const TOKEN_KEY = 'elm-admin-token'
const USER_KEY = 'elm-admin-user-info'

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

function readStoredValue(key: string) {
  return localStorage.getItem(key) ?? sessionStorage.getItem(key) ?? ''
}

function getActiveStorage() {
  if (localStorage.getItem(TOKEN_KEY)) {
    return localStorage
  }
  return sessionStorage
}

export const useUserStore = defineStore('user', () => {
  const token = ref(readStoredValue(TOKEN_KEY))
  const userInfo = ref<UserInfo | null>(safeParseUserInfo(readStoredValue(USER_KEY)))

  const isLoggedIn = computed(() => isTokenValid(token.value))
  const isAdmin = computed(() => userInfo.value?.role === 'ADMIN')

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
    isAdmin,
    setToken,
    setUserInfo,
    clear,
  }
})
