<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AppHeader from './components/AppHeader.vue'
import { useUserStore } from './stores/user'

const route = useRoute()
const userStore = useUserStore()
const whiteList = new Set(['/login', '/register', '/guest-entry'])

const showHeader = computed(() => userStore.isLoggedIn && !whiteList.has(route.path))
</script>

<template>
  <div class="app-shell">
    <AppHeader v-if="showHeader" />
    <router-view />
  </div>
</template>

<style scoped>
.app-shell {
  min-height: 100vh;
  background: #f3f6fb;
}
</style>
