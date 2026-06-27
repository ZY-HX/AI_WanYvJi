<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { logout as logoutRequest } from '../api/auth'
import { useUserStore } from '../stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const displayName = computed(() => userStore.userInfo?.nickname || userStore.userInfo?.username || '管理员')

function go(path: string) {
  if (route.path === path) {
    return
  }
  void router.push(path)
}

async function logout() {
  const confirmed = await ElMessageBox.confirm('确认退出管理员登录？', '提示', {
    type: 'warning',
    confirmButtonText: '退出',
    cancelButtonText: '取消',
  }).catch(() => false)

  if (!confirmed) {
    return
  }

  await logoutRequest().catch(() => null)
  userStore.clear()
  await router.push('/login')
}
</script>

<template>
  <header class="admin-header">
    <div class="admin-header-inner">
      <div class="admin-header-left">
        <button class="admin-brand" type="button" @click="go('/dashboard')">EnglishLearningMate Admin</button>
        <nav class="admin-nav">
          <el-button text @click="go('/dashboard')">统计仪表板</el-button>
          <el-button text @click="go('/users')">用户管理</el-button>
          <el-button text @click="go('/wordbanks/audit')">共享词库审核</el-button>
          <el-button text @click="go('/vocabularies')">词库管理</el-button>
          <el-button text @click="go('/sensitive-words')">敏感词管理</el-button>
          <el-button text @click="go('/ai-config')">AI服务配置</el-button>
          <el-button text @click="go('/announcements')">系统公告</el-button>
        </nav>
      </div>

      <div class="admin-header-right">
        <span class="admin-user">{{ displayName }}</span>
        <el-button text @click="logout">退出</el-button>
      </div>
    </div>
  </header>
</template>

<style scoped>
.admin-header {
  height: var(--app-header-height, 56px);
  display: flex;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 20;
  background: rgba(17, 24, 39, 0.92);
  color: #fff;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.admin-header-inner {
  width: 100%;
  max-width: 1240px;
  margin: 0 auto;
  padding: 0 18px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
}

.admin-header-left,
.admin-header-right,
.admin-nav {
  display: flex;
  align-items: center;
  gap: 10px;
}

.admin-brand {
  border: none;
  background: transparent;
  color: #fff;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  padding: 0;
  white-space: nowrap;
}

.admin-user {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.85);
}
</style>
