import http from './http'

export interface DashboardHomeData {
  todayReviewCount: number
  consecutiveDays: number
  todayStudyMinutes: number
  totalWordsLearned: number
  totalWordBanks: number
}

export function getDashboardHome() {
  return http.get<DashboardHomeData>('/api/user/dashboard/home').then((response) => response.data)
}

export interface TrendPoint {
  date: string
  studyCount: number
  correctCount: number
  wrongCount: number
  newWordsCount: number
}

export interface DashboardDetailData {
  totalVocabulary: number
  totalAccuracyRate: number
  totalCorrectCount: number
  totalWrongCount: number
  errorBookCount: number
  dailyTrend: TrendPoint[]
  weeklyTrend: TrendPoint[]
  monthlyTrend: TrendPoint[]
}

export function getDashboardDetail() {
  return http.get<DashboardDetailData>('/api/user/dashboard/detail').then((response) => response.data)
}
