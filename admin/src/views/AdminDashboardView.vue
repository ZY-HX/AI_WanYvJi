<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import * as echarts from 'echarts'
import type { ECharts, EChartsOption } from 'echarts'
import { ElMessage } from 'element-plus'
import {
  getAiUsage,
  getStatisticsOverview,
  getStudyActivity,
  getUserTrend,
  type StatisticsOverview,
  type StatisticsTrendPoint,
} from '../api/statistics'

type RangeOption = 7 | 30

const loading = ref(false)
const range = ref<RangeOption>(7)

const overview = ref<StatisticsOverview>({
  totalUsers: 0,
  todayNewUsers: 0,
  totalWordBanks: 0,
  todayStudyRecords: 0,
  totalAiGenerations: 0,
  todayAiGenerations: 0,
})

const userTrend = ref<StatisticsTrendPoint[]>([])
const studyActivity = ref<StatisticsTrendPoint[]>([])
const aiUsage = ref<StatisticsTrendPoint[]>([])

const userChartRef = ref<HTMLDivElement>()
const studyChartRef = ref<HTMLDivElement>()
const aiChartRef = ref<HTMLDivElement>()

let userChart: ECharts | null = null
let studyChart: ECharts | null = null
let aiChart: ECharts | null = null

const overviewCards = computed(() => [
  { label: '总用户数', value: overview.value.totalUsers, type: 'primary' },
  { label: '今日新增用户', value: overview.value.todayNewUsers, type: 'success' },
  { label: '总词库数', value: overview.value.totalWordBanks, type: 'warning' },
  { label: '今日学习提交量', value: overview.value.todayStudyRecords, type: 'danger' },
  { label: '累计 AI 生成量', value: overview.value.totalAiGenerations, type: 'info' },
  { label: '今日 AI 生成量', value: overview.value.todayAiGenerations, type: 'primary' },
])

onMounted(async () => {
  try {
    await fetchAll()
  } catch {
    ElMessage.error('仪表盘数据加载失败，请检查后端服务是否启动')
  }
  window.addEventListener('resize', resizeCharts)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', resizeCharts)
  disposeCharts()
})

watch(range, async () => {
  try {
    await fetchTrendData()
  } catch {
    ElMessage.error('趋势数据加载失败，请稍后重试')
  }
})

async function fetchAll() {
  loading.value = true
  try {
    await Promise.all([fetchOverview(), fetchTrendData()])
  } finally {
    loading.value = false
  }
}

async function fetchOverview() {
  const result = await getStatisticsOverview()
  overview.value = result
}

async function fetchTrendData() {
  loading.value = true
  try {
    const selectedDays = range.value
    const [userResult, studyResult, aiResult] = await Promise.all([
      getUserTrend(selectedDays),
      getStudyActivity(selectedDays),
      getAiUsage(selectedDays),
    ])

    userTrend.value = userResult ?? []
    studyActivity.value = studyResult ?? []
    aiUsage.value = aiResult ?? []

    await nextTick()
    renderCharts()
  } finally {
    loading.value = false
  }
}

function ensureChartInstance(target: HTMLDivElement | undefined, chart: ECharts | null) {
  if (!target) {
    return null
  }
  return chart ?? echarts.init(target)
}

function renderCharts() {
  userChart = ensureChartInstance(userChartRef.value, userChart)
  studyChart = ensureChartInstance(studyChartRef.value, studyChart)
  aiChart = ensureChartInstance(aiChartRef.value, aiChart)

  userChart?.setOption(buildLineOption('用户增长趋势', userTrend.value, '#409eff', '每日注册用户数'))
  studyChart?.setOption(buildBarOption('学习活跃度', studyActivity.value, '#67c23a', '每日学习记录提交量'))
  aiChart?.setOption(buildLineOption('AI 调用趋势', aiUsage.value, '#8b5cf6', '每日 AI 文章生成量'))
}

function buildLineOption(
  title: string,
  points: StatisticsTrendPoint[],
  color: string,
  seriesName: string,
): EChartsOption {
  return {
    color: [color],
    tooltip: {
      trigger: 'axis',
    },
    grid: {
      left: 24,
      right: 24,
      top: 52,
      bottom: 24,
      containLabel: true,
    },
    title: {
      text: title,
      left: 18,
      top: 12,
      textStyle: {
        fontSize: 16,
        fontWeight: 600,
      },
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: points.map((item) => item.date.slice(5)),
    },
    yAxis: {
      type: 'value',
      minInterval: 1,
    },
    series: [
      {
        name: seriesName,
        type: 'line',
        smooth: true,
        areaStyle: {
          opacity: 0.12,
        },
        data: points.map((item) => item.value),
      },
    ],
  }
}

function buildBarOption(
  title: string,
  points: StatisticsTrendPoint[],
  color: string,
  seriesName: string,
): EChartsOption {
  return {
    color: [color],
    tooltip: {
      trigger: 'axis',
    },
    grid: {
      left: 24,
      right: 24,
      top: 52,
      bottom: 24,
      containLabel: true,
    },
    title: {
      text: title,
      left: 18,
      top: 12,
      textStyle: {
        fontSize: 16,
        fontWeight: 600,
      },
    },
    xAxis: {
      type: 'category',
      data: points.map((item) => item.date.slice(5)),
    },
    yAxis: {
      type: 'value',
      minInterval: 1,
    },
    series: [
      {
        name: seriesName,
        type: 'bar',
        barMaxWidth: 36,
        data: points.map((item) => item.value),
      },
    ],
  }
}

function resizeCharts() {
  userChart?.resize()
  studyChart?.resize()
  aiChart?.resize()
}

function disposeCharts() {
  userChart?.dispose()
  studyChart?.dispose()
  aiChart?.dispose()
  userChart = null
  studyChart = null
  aiChart = null
}
</script>

<template>
  <div class="dashboard-page">
    <div class="dashboard-shell">
      <section class="dashboard-hero">
        <div>
          <h1>统计仪表板</h1>
          <p>展示平台用户增长、学习活跃度、词库规模与 AI 生成量等核心指标。</p>
        </div>

        <div class="range-switch">
          <span>时间范围</span>
          <el-radio-group v-model="range" size="large">
            <el-radio-button :value="7">最近 7 天</el-radio-button>
            <el-radio-button :value="30">最近 30 天</el-radio-button>
          </el-radio-group>
        </div>
      </section>

      <section class="overview-grid" v-loading="loading">
        <article
          v-for="card in overviewCards"
          :key="card.label"
          class="overview-card"
          :class="`overview-card--${card.type}`"
        >
          <div class="overview-label">{{ card.label }}</div>
          <div class="overview-value">{{ card.value }}</div>
        </article>
      </section>

      <section class="chart-grid" v-loading="loading">
        <article class="chart-card chart-card--wide">
          <div ref="userChartRef" class="chart-box" />
        </article>
        <article class="chart-card">
          <div ref="studyChartRef" class="chart-box" />
        </article>
        <article class="chart-card">
          <div ref="aiChartRef" class="chart-box" />
        </article>
      </section>
    </div>
  </div>
</template>

<style scoped>
.dashboard-page {
  min-height: calc(100vh - var(--app-header-height));
  padding: 24px;
}

.dashboard-shell {
  max-width: 1240px;
  margin: 0 auto;
  display: grid;
  gap: 20px;
}

.dashboard-hero {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;
  padding: 28px 32px;
  border-radius: 24px;
  background: linear-gradient(135deg, #111827 0%, #1d4ed8 100%);
  color: #fff;
  box-shadow: 0 18px 40px rgba(15, 23, 42, 0.12);
}

.dashboard-hero h1 {
  margin: 0 0 8px;
  font-size: 32px;
}

.dashboard-hero p {
  margin: 0;
  color: rgba(255, 255, 255, 0.78);
}

.range-switch {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
}

.range-switch span {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.78);
}

.overview-grid {
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  gap: 16px;
}

.overview-card {
  min-height: 126px;
  padding: 22px 20px;
  border-radius: 20px;
  background: #fff;
  box-shadow: 0 16px 36px rgba(15, 23, 42, 0.08);
}

.overview-card--primary {
  background: linear-gradient(180deg, #eff6ff 0%, #ffffff 100%);
}

.overview-card--success {
  background: linear-gradient(180deg, #ecfdf5 0%, #ffffff 100%);
}

.overview-card--warning {
  background: linear-gradient(180deg, #fff7ed 0%, #ffffff 100%);
}

.overview-card--danger {
  background: linear-gradient(180deg, #fef2f2 0%, #ffffff 100%);
}

.overview-card--info {
  background: linear-gradient(180deg, #f5f3ff 0%, #ffffff 100%);
}

.overview-label {
  color: #6b7280;
  font-size: 14px;
}

.overview-value {
  margin-top: 18px;
  color: #111827;
  font-size: 34px;
  font-weight: 700;
  line-height: 1;
}

.chart-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20px;
}

.chart-card {
  min-height: 360px;
  padding: 12px;
  border-radius: 24px;
  background: #fff;
  box-shadow: 0 18px 40px rgba(15, 23, 42, 0.08);
}

.chart-card--wide {
  grid-column: 1 / -1;
}

.chart-box {
  width: 100%;
  height: 336px;
}

@media (max-width: 1100px) {
  .overview-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 900px) {
  .dashboard-hero {
    align-items: flex-start;
    flex-direction: column;
  }

  .chart-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 640px) {
  .dashboard-page {
    padding: 16px;
  }

  .dashboard-hero,
  .overview-card,
  .chart-card {
    border-radius: 18px;
  }

  .overview-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
