import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'
import { pinia } from '../stores'
import router from '../router'

interface ApiResult<T> {
  code: number
  message: string
  data: T
}

const apiBaseURL = (import.meta.env.VITE_API_BASE_URL as string | undefined)?.trim() || '/'

const http = axios.create({
  baseURL: apiBaseURL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

http.interceptors.request.use((config) => {
  const userStore = useUserStore(pinia)

  if (userStore.token && userStore.isLoggedIn) {
    config.headers.Authorization = `Bearer ${userStore.token}`
  } else if (userStore.token && !userStore.isLoggedIn) {
    userStore.clear()
  }

  // Let the browser generate the correct multipart boundary for FormData uploads.
  if (typeof FormData !== 'undefined' && config.data instanceof FormData) {
    delete config.headers['Content-Type']
  }

  return config
})

http.interceptors.response.use(
  (response) => {
    if (response.config.responseType === 'blob') {
      return response
    }

    const result = response.data as ApiResult<unknown>

    if (result.code !== 200) {
      ElMessage.error(result.message || '请求失败')
      return Promise.reject(new Error(result.message || '请求失败'))
    }

    response.data = result.data
    return response
  },
  async (error) => {
    if (error.response?.status === 401) {
      const userStore = useUserStore(pinia)
      const currentPath = router.currentRoute.value.fullPath

      userStore.clear()

      if (!['/login', '/register', '/guest-entry'].includes(router.currentRoute.value.path)) {
        void router.replace({
          path: '/login',
          query: currentPath && currentPath !== '/login' ? { redirect: currentPath } : undefined,
        })
      }
    }

    let message = error.response?.data?.message || error.message || '网络异常，请稍后重试'
    const responseData = error.response?.data
    if (typeof Blob !== 'undefined' && responseData instanceof Blob) {
      try {
        const rawText = await responseData.text()
        const parsed = JSON.parse(rawText) as Partial<ApiResult<unknown>>
        if (typeof parsed.message === 'string' && parsed.message) {
          message = parsed.message
        }
        error.response.data = parsed
      } catch {
        // Ignore blob parse failure and keep the fallback message.
      }
    }

    ElMessage.error(message)
    return Promise.reject(error)
  },
)

export default http
export type { ApiResult }
