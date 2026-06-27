import { createRouter, createWebHistory } from 'vue-router'
import { pinia } from '../stores'
import { useUserStore } from '../stores/user'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      redirect: '/dashboard',
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
      path: '/403',
      name: 'forbidden',
      component: () => import('../views/ForbiddenView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('../views/AdminDashboardView.vue'),
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/wordbanks/audit',
      name: 'wordbank-audit',
      component: () => import('../views/wordbanks/WordBankAuditView.vue'),
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/sensitive-words',
      name: 'sensitive-words',
      component: () => import('../views/sensitiveWords/AdminSensitiveWordsView.vue'),
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/users',
      name: 'users',
      component: () => import('../views/users/AdminUsersView.vue'),
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/vocabularies',
      name: 'vocabularies',
      component: () => import('../views/vocabularies/VocabularyManageView.vue'),
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/announcements',
      name: 'announcements',
      component: () => import('../views/notifications/AnnouncementView.vue'),
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/ai-config',
      name: 'ai-config',
      component: () => import('../views/aiConfig/AdminAiConfigView.vue'),
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/dashboard',
    },
  ],
})

router.beforeEach((to) => {
  const userStore = useUserStore(pinia)
  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth)
  const requiresAdmin = to.matched.some((record) => record.meta.requiresAdmin)
  const publicOnly = to.matched.some((record) => record.meta.publicOnly)

  if (publicOnly) {
    if (userStore.isLoggedIn && userStore.isAdmin) {
      return '/dashboard'
    }
    if (userStore.isLoggedIn) {
      return '/403'
    }
    return true
  }

  if (requiresAuth && !userStore.isLoggedIn) {
    return {
      path: '/login',
      query: to.fullPath !== '/' ? { redirect: to.fullPath } : undefined,
    }
  }

  if (to.path === '/403') {
    return userStore.isAdmin ? '/dashboard' : true
  }

  if (requiresAdmin && !userStore.isAdmin) {
    return '/403'
  }

  return true
})

export default router
