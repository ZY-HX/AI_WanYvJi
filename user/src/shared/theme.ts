import { ref } from 'vue'

export type AppTheme = 'dark' | 'light'

const THEME_STORAGE_KEY = 'elm-user-theme'
const DEFAULT_THEME: AppTheme = 'dark'

export const currentTheme = ref<AppTheme>(DEFAULT_THEME)

function normalizeTheme(value: string | null | undefined): AppTheme {
  return value === 'light' ? 'light' : 'dark'
}

function persistTheme(theme: AppTheme) {
  if (typeof window === 'undefined') {
    return
  }
  window.localStorage.setItem(THEME_STORAGE_KEY, theme)
}

export function applyTheme(theme: AppTheme) {
  currentTheme.value = theme
  if (typeof document !== 'undefined') {
    document.documentElement.setAttribute('data-theme', theme)
  }
}

export function initTheme() {
  if (typeof window === 'undefined') {
    return DEFAULT_THEME
  }
  const saved = normalizeTheme(window.localStorage.getItem(THEME_STORAGE_KEY))
  applyTheme(saved)
  return saved
}

export function setTheme(theme: AppTheme) {
  applyTheme(theme)
  persistTheme(theme)
}

export function toggleTheme() {
  const nextTheme: AppTheme = currentTheme.value === 'dark' ? 'light' : 'dark'
  setTheme(nextTheme)
}
