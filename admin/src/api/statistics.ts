import http from './http'

export interface StatisticsOverview {
  totalUsers: number
  todayNewUsers: number
  totalWordBanks: number
  todayStudyRecords: number
  totalAiGenerations: number
  todayAiGenerations: number
}

export interface StatisticsTrendPoint {
  date: string
  value: number
}

export function getStatisticsOverview() {
  return http
    .get<StatisticsOverview>('/api/admin/statistics/overview')
    .then((response) => response.data)
}

export function getUserTrend(days: number) {
  return http
    .get<StatisticsTrendPoint[]>('/api/admin/statistics/user-trend', {
      params: { days },
    })
    .then((response) => response.data)
}

export function getStudyActivity(days: number) {
  return http
    .get<StatisticsTrendPoint[]>('/api/admin/statistics/study-activity', {
      params: { days },
    })
    .then((response) => response.data)
}

export function getAiUsage(days: number) {
  return http
    .get<StatisticsTrendPoint[]>('/api/admin/statistics/ai-usage', {
      params: { days },
    })
    .then((response) => response.data)
}
