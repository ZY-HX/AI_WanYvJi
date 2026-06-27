import http from './http'

export interface AnnouncementPayload {
  title: string
  content: string
}

export function publishAnnouncement(payload: AnnouncementPayload) {
  return http
    .post<null>('/api/admin/notifications/announcement', payload)
    .then((response) => response.data)
}
