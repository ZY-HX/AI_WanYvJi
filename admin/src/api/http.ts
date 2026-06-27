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
    if (error.response?.status === 401 || error.response?.status === 403) {
      const userStore = useUserStore(pinia)
      const currentPath = router.currentRoute.value.fullPath
      if (error.response?.status === 401) {
        userStore.clear()
      }
      if (error.response?.status === 403) {
        if (router.currentRoute.value.path !== '/403') {
          void router.replace('/403')
        }
        return Promise.reject(error)
      }
      if (router.currentRoute.value.path !== '/login') {
        void router.replace({
          path: '/login',
          query: currentPath && currentPath !== '/login' ? { redirect: currentPath } : undefined,
        })
      }
    }

    const message = error.response?.data?.message || error.message || '网络异常，请稍后重试'
    ElMessage.error(message)
    return Promise.reject(error)
  },
)

export default http
export type { ApiResult }
