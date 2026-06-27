<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AdminHeader from './components/AdminHeader.vue'
import { useUserStore } from './stores/user'

const route = useRoute()
const userStore = useUserStore()

const showHeader = computed(() => userStore.isLoggedIn && !['/login', '/403'].includes(route.path))
</script>

<template>
  <div class="app-shell">
    <AdminHeader v-if="showHeader" />
    <router-view />
  </div>
</template>

<style scoped>
.app-shell {
  min-height: 100vh;
}
</style>
