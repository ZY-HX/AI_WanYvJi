<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()

function goLogin() {
  userStore.clear()
  void router.replace('/login')
}

function goHome() {
  userStore.clear()
  void router.replace('/login')
}
</script>

<template>
  <div class="page-shell">
    <div class="forbidden-card">
      <div class="forbidden-code">403</div>
      <h1>无权访问管理端</h1>
      <p>当前账号已登录，但不具备管理员权限，无法访问此页面。</p>

      <div class="forbidden-actions">
        <el-button type="primary" @click="goLogin">切换管理员账号</el-button>
        <el-button @click="goHome">返回首页</el-button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.forbidden-card {
  width: min(520px, 100%);
  margin: 80px auto;
  padding: 48px 36px;
  border-radius: 20px;
  background: #ffffff;
  box-shadow: 0 20px 50px rgba(15, 23, 42, 0.12);
  text-align: center;
}

.forbidden-code {
  font-size: 56px;
  font-weight: 700;
  line-height: 1;
  color: #2563eb;
}

.forbidden-card h1 {
  margin: 20px 0 12px;
  font-size: 28px;
  color: #111827;
}

.forbidden-card p {
  margin: 0;
  line-height: 1.7;
  color: #4b5563;
}

.forbidden-actions {
  margin-top: 28px;
  display: flex;
  justify-content: center;
  gap: 12px;
  flex-wrap: wrap;
}
</style>
