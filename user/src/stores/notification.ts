import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { getNotificationUnreadCount } from '../api/notifications'
import { useUserStore } from './user'

export const useNotificationStore = defineStore('notification', () => {
  const unreadCount = ref(0)
  const polling = ref(false)
  let timer: number | undefined

  const shouldEnableNotifications = computed(() => {
    const userStore = useUserStore()
    if (!userStore.isLoggedIn) {
      return false
    }
    return !userStore.isGuest
  })

  function reset() {
    unreadCount.value = 0
  }

  async function refreshUnreadCount() {
    if (!shouldEnableNotifications.value) {
      reset()
      return
    }

    try {
      const result = await getNotificationUnreadCount()
      unreadCount.value = Math.max(0, Number(result.unreadCount ?? 0))
    } catch {
      // Ignore polling errors; keep the existing unreadCount.
    }
  }

  function startPolling(intervalMs = 30000) {
    if (timer) {
      return
    }
    polling.value = true
    void refreshUnreadCount()
    timer = window.setInterval(() => {
      void refreshUnreadCount()
    }, intervalMs)
  }

  function stopPolling() {
    if (timer) {
      window.clearInterval(timer)
      timer = undefined
    }
    polling.value = false
  }

  return {
    unreadCount,
    polling,
    shouldEnableNotifications,
    reset,
    refreshUnreadCount,
    startPolling,
    stopPolling,
  }
})
