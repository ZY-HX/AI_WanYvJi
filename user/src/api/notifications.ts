import http from './http'

export interface NotificationItem {
  id: number
  title: string
  content: string
  isRead: number
  type: string
  createdAt: string
}

export interface PageResponse<T> {
  current: number
  size: number
  total: number
  records: T[]
}

export interface NotificationListParams {
  current?: number
  size?: number
  is_read?: number
}

export interface NotificationUnreadCountResponse {
  unreadCount: number
}

export function getNotifications(params: NotificationListParams) {
  return http
    .get<PageResponse<NotificationItem>>('/api/notifications', { params })
    .then((response) => response.data)
}

export function getRecentNotifications(size = 5) {
  return getNotifications({ current: 1, size })
}

export function markNotificationRead(id: number) {
  return http.put<null>(`/api/notifications/${id}/read`).then((response) => response.data)
}

export function markAllNotificationsRead() {
  return http.put<number>('/api/notifications/read-all').then((response) => response.data)
}

export function getNotificationUnreadCount() {
  return http
    .get<NotificationUnreadCountResponse>('/api/user/notifications/unread-count')
    .then((response) => response.data)
}
