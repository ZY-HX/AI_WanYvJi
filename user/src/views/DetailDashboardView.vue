<script setup lang="ts">
import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import type { ECharts, EChartsOption } from 'echarts'
import {
  getDashboardDetail,
  type DashboardDetailData,
  type TrendPoint,
} from '../api/dashboard'

const router = useRouter()
const loading = ref(false)
const detailData = ref<DashboardDetailData | null>(null)
const activeTab = ref<'daily' | 'weekly' | 'monthly'>('daily')

const studyChartRef = ref<HTMLDivElement>()
const accuracyChartRef = ref<HTMLDivElement>()
let studyChart: ECharts | null = null
let accuracyChart: ECharts | null = null

onMounted(async () => {
  await fetchDetailData()
  window.addEventListener('resize', resizeCharts)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', resizeCharts)
  disposeCharts()
})

watch(activeTab, async () => {
  await nextTick()
  setTimeout(() => renderCharts(), 50)
})

watch(detailData, async () => {
  if (detailData.value) {
    await nextTick()
    setTimeout(() => renderCharts(), 100)
  }
})

async function fetchDetailData() {
  loading.value = true
  try {
    const result = await getDashboardDetail()
    detailData.value = result
  } catch (error: any) {
    console.error('获取详细数据失败:', error)
  } finally {
    loading.value = false
  }
}

function getActiveTrend(): TrendPoint[] {
  if (!detailData.value) return []
  switch (activeTab.value) {
    case 'daily':
      return detailData.value.dailyTrend ?? []
    case 'weekly':
      return detailData.value.weeklyTrend ?? []
    case 'monthly':
      return detailData.value.monthlyTrend ?? []
    default:
      return []
  }
}

function ensureChartInstance(target: HTMLDivElement | undefined, chart: ECharts | null) {
  if (!target) {
    console.warn('图表容器不存在')
    return null
  }

  if (target.offsetWidth === 0 || target.offsetHeight === 0) {
    console.warn('图表容器尺寸为0', { width: target.offsetWidth, height: target.offsetHeight })
    return null
  }

  if (chart) {
    chart.resize()
    return chart
  }

  console.log('初始化ECharts实例', target.className)
  return echarts.init(target)
}

function renderCharts() {
  if (!detailData.value) {
    console.warn('detailData为空，跳过渲染')
    return
  }

  const trend = getActiveTrend()
  console.log('渲染图表，趋势数据条数:', trend.length)

  studyChart = ensureChartInstance(studyChartRef.value, studyChart)
  if (studyChart && trend.length > 0) {
    studyChart.setOption(buildStudyTrendOption(trend), true)
  } else if (studyChart) {
    studyChart.setOption(buildStudyTrendOption([]), true)
  }

  accuracyChart = ensureChartInstance(accuracyChartRef.value, accuracyChart)
  if (accuracyChart) {
    accuracyChart.setOption(buildAccuracyOption(), true)
  }
}

function buildStudyTrendOption(points: TrendPoint[] | undefined): EChartsOption {
  const safePoints = points ?? []

  return {
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'cross' },
    },
    legend: {
      data: ['学习次数', '正确数', '错误数', '新学单词'],
      top: 0,
    },
    grid: {
      left: 24,
      right: 24,
      top: 52,
      bottom: 24,
      containLabel: true,
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: safePoints.map((item) => item.date),
      axisLabel: {
        rotate: safePoints.length > 15 ? 45 : 0,
      },
    },
    yAxis: [
      {
        type: 'value',
        name: '次数',
        minInterval: 1,
        position: 'left',
      },
      {
        type: 'value',
        name: '单词数',
        minInterval: 1,
        position: 'right',
      },
    ],
    series: [
      {
        name: '学习次数',
        type: 'line',
        smooth: true,
        data: safePoints.map((item) => item.studyCount),
        itemStyle: { color: '#409eff' },
        areaStyle: { opacity: 0.12 },
      },
      {
        name: '正确数',
        type: 'line',
        smooth: true,
        data: safePoints.map((item) => item.correctCount),
        itemStyle: { color: '#67c23a' },
      },
      {
        name: '错误数',
        type: 'line',
        smooth: true,
        data: safePoints.map((item) => item.wrongCount),
        itemStyle: { color: '#f56c6c' },
      },
      {
        name: '新学单词',
        type: 'bar',
        yAxisIndex: 1,
        barMaxWidth: 30,
        data: safePoints.map((item) => item.newWordsCount),
        itemStyle: { color: '#e6a23c' },
      },
    ],
  }
}

function buildAccuracyOption(): EChartsOption {
  if (!detailData.value) return {}

  return {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)',
    },
    legend: {
      orient: 'vertical',
      right: '5%',
      top: 'center',
    },
    series: [
      {
        name: '答题统计',
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['40%', '50%'],
        avoidLabelOverlap: false,
        label: {
          show: true,
          formatter: '{b}\n{d}%',
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 16,
            fontWeight: 'bold',
          },
        },
        data: [
          { value: detailData.value.totalCorrectCount, name: '正确', itemStyle: { color: '#67c23a' } },
          { value: detailData.value.totalWrongCount, name: '错误', itemStyle: { color: '#f56c6c' } },
        ],
      },
    ],
  }
}

function resizeCharts() {
  studyChart?.resize()
  accuracyChart?.resize()
}

function disposeCharts() {
  studyChart?.dispose()
  accuracyChart?.dispose()
  studyChart = null
  accuracyChart = null
}
</script>

<template>
  <div class="detail-dashboard">
    <div class="dashboard-header">
      <div>
        <h1>详细数据看板</h1>
        <p>查看您的学习统计数据和趋势分析</p>
      </div>
      <el-button @click="router.push('/')">返回首页</el-button>
    </div>

    <el-skeleton :rows="8" animated :loading="loading">
      <template #default>
        <section v-if="detailData" class="stats-overview">
          <article class="stat-card stat-card--vocabulary">
            <div class="stat-icon">📚</div>
            <div class="stat-content">
              <div class="stat-value">{{ detailData.totalVocabulary }}</div>
              <div class="stat-label">累计词汇量</div>
            </div>
          </article>

          <article class="stat-card stat-card--accuracy">
            <div class="stat-icon">🎯</div>
            <div class="stat-content">
              <div class="stat-value">{{ detailData.totalAccuracyRate }}%</div>
              <div class="stat-label">总正确率</div>
            </div>
          </article>

          <article class="stat-card stat-card--correct">
            <div class="stat-icon">✅</div>
            <div class="stat-content">
              <div class="stat-value">{{ detailData.totalCorrectCount }}</div>
              <div class="stat-label">总正确数</div>
            </div>
          </article>

          <article class="stat-card stat-card--wrong">
            <div class="stat-icon">❌</div>
            <div class="stat-content">
              <div class="stat-value">{{ detailData.totalWrongCount }}</div>
              <div class="stat-label">总错误数</div>
            </div>
          </article>

          <article class="stat-card stat-card--errors">
            <div class="stat-icon">📝</div>
            <div class="stat-content">
              <div class="stat-value">{{ detailData.errorBookCount }}</div>
              <div class="stat-label">错题本数量</div>
            </div>
          </article>
        </section>

        <section class="trend-section">
          <div class="trend-header">
            <h2>学习趋势分析</h2>
            <el-radio-group v-model="activeTab" size="large">
              <el-radio-button value="daily">日趋势</el-radio-button>
              <el-radio-button value="weekly">周趋势</el-radio-button>
              <el-radio-button value="monthly">月趋势</el-radio-button>
            </el-radio-group>
          </div>

          <div class="chart-grid">
            <article class="chart-card chart-card--wide">
              <h3>学习活动趋势</h3>
              <div ref="studyChartRef" class="chart-box" />
            </article>

            <article class="chart-card">
              <h3>正确率分布</h3>
              <div ref="accuracyChartRef" class="chart-box" />
            </article>
          </div>
        </section>
      </template>
    </el-skeleton>
  </div>
</template>

<style scoped>
.detail-dashboard {
  min-height: calc(100vh - var(--app-header-height));
  padding: clamp(16px, 2.4vw, 24px);
  background: linear-gradient(180deg, #f8fbff 0%, #edf4ff 100%);
}

.dashboard-header {
  max-width: 1240px;
  margin: 0 auto 28px;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;
  padding: 28px 32px;
  border-radius: 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  box-shadow: 0 18px 40px rgba(15, 23, 42, 0.12);
}

.dashboard-header h1 {
  margin: 0 0 8px;
  font-size: 32px;
  font-weight: 600;
}

.dashboard-header p {
  margin: 0;
  color: rgba(255, 255, 255, 0.85);
  font-size: 15px;
}

.stats-overview {
  max-width: 1240px;
  margin: 0 auto 28px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.stat-card {
  padding: 24px;
  border-radius: 20px;
  background: #fff;
  box-shadow: 0 16px 36px rgba(15, 23, 42, 0.08);
  display: flex;
  align-items: center;
  gap: 18px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30px;
  flex-shrink: 0;
}

.stat-card--vocabulary .stat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-card--accuracy .stat-icon {
  background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
}

.stat-card--correct .stat-icon {
  background: linear-gradient(135deg, #56ab2f 0%, #a8e063 100%);
}

.stat-card--wrong .stat-icon {
  background: linear-gradient(135deg, #ff416c 0%, #ff4b2b 100%);
}

.stat-card--errors .stat-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 30px;
  font-weight: 700;
  color: #1f2d3d;
  line-height: 1.2;
  margin-bottom: 6px;
}

.stat-label {
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
}

.trend-section {
  max-width: 1240px;
  margin: 0 auto;
}

.trend-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;
  padding: 0 8px;
}

.trend-header h2 {
  margin: 0;
  font-size: 24px;
  color: #1f2d3d;
  font-weight: 600;
}

.chart-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20px;
}

.chart-card {
  min-height: 420px;
  padding: 20px;
  border-radius: 24px;
  background: #fff;
  box-shadow: 0 18px 40px rgba(15, 23, 42, 0.08);
}

.chart-card--wide {
  grid-column: 1 / -1;
}

.chart-card h3 {
  margin: 0 0 16px;
  font-size: 18px;
  color: #1f2d3d;
  font-weight: 600;
}

.chart-box {
  width: 100%;
  height: 360px;
}

@media (max-width: 1100px) {
  .stats-overview {
    grid-template-columns: repeat(2, minmax(180px, 1fr));
  }

  .chart-grid {
    grid-template-columns: 1fr;
  }

  .chart-card--wide {
    grid-column: auto;
  }
}

@media (max-width: 768px) {
  .dashboard-header {
    flex-direction: column;
    align-items: flex-start;
    padding: 20px 18px;
  }

  .trend-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .stats-overview {
    grid-template-columns: 1fr;
  }

  .stat-value {
    font-size: 26px;
  }

  .dashboard-header h1 {
    font-size: 26px;
  }
}
</style>
