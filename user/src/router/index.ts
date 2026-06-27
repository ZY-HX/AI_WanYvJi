import { createRouter, createWebHistory } from 'vue-router'
import { ElMessage } from 'element-plus'
import { pinia } from '../stores'
import { useUserStore } from '../stores/user'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: () => import('../views/HomeView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/dashboard/detail',
      name: 'dashboard-detail',
      component: () => import('../views/DetailDashboardView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/profile',
      name: 'profile',
      component: () => import('../views/ProfileView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/wordbanks',
      name: 'my-wordbanks',
      component: () => import('../views/MyWordBanksView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/public-wordbanks',
      name: 'public-wordbanks',
      component: () => import('../views/PublicWordBanksView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/wordbanks/:id',
      name: 'wordbank-detail',
      component: () => import('../views/WordBankDetailView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/study',
      name: 'study',
      component: () => import('../views/StudyView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/review',
      name: 'review',
      component: () => import('../views/ReviewView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/error-book',
      name: 'error-book',
      component: () => import('../views/ErrorBookView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/ai-reading',
      name: 'ai-reading',
      component: () => import('../views/AIReadingView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/simultaneous-translation',
      name: 'simultaneous-translation',
      component: () => import('../views/SimultaneousTranslationView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/notifications',
      name: 'notifications',
      component: () => import('../views/NotificationView.vue'),
      meta: {
        requiresAuth: true,
        allowGuest: false,
      },
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/LoginView.vue'),
      meta: {
        publicOnly: true,
      },
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('../views/RegisterView.vue'),
      meta: {
        publicOnly: true,
      },
    },
    {
      path: '/guest-entry',
      name: 'guest-entry',
      component: () => import('../views/GuestEntryView.vue'),
      meta: {
        publicOnly: true,
      },
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('../views/NotFoundView.vue'),
    },
  ],
})

router.beforeEach((to) => {
  const userStore = useUserStore(pinia)
  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth)
  const publicOnly = to.matched.some((record) => record.meta.publicOnly)
  const disallowGuest = to.matched.some((record) => record.meta.allowGuest === false)

  if (userStore.isLoggedIn && publicOnly) {
    return '/'
  }

  if (requiresAuth && !userStore.isLoggedIn) {
    return {
      path: '/login',
      query: to.fullPath !== '/' ? { redirect: to.fullPath } : undefined,
    }
  }

  if (requiresAuth && disallowGuest && userStore.isGuest) {
    ElMessage.warning('游客模式暂不支持访问该页面')
    return '/'
  }

  return true
})

export default router
