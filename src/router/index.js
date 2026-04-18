import { createRouter, createWebHashHistory } from 'vue-router'
import { waitForAuth, useAuth } from '../composables/useAuth'

const routes = [
  // Public
  { path: '/',            name: 'Home',        component: () => import('../pages/public/HomePage.vue') },
  { path: '/news',        name: 'News',        component: () => import('../pages/public/NewsPage.vue') },
  { path: '/news/:id',    name: 'NewsDetail',  component: () => import('../pages/public/NewsDetailPage.vue') },
  { path: '/activities',  name: 'Activities',  component: () => import('../pages/public/ActivitiesPage.vue') },
  { path: '/media',       name: 'Media',       component: () => import('../pages/public/MediaPage.vue') },
  { path: '/media/:id',   name: 'MediaDetail', component: () => import('../pages/public/MediaDetailPage.vue') },
  { path: '/personnel',       name: 'Personnel',      component: () => import('../pages/public/PersonnelPage.vue') },
  { path: '/personnel/stats', name: 'PersonnelStats', component: () => import('../pages/public/PersonnelStatsPage.vue') },
  { path: '/about/:slug', name: 'OrgDetail',  component: () => import('../pages/public/OrgDetailPage.vue') },
  { path: '/wpa-public',  name: 'WpaPublic',  component: () => import('../pages/public/WpaPublicPage.vue') },
  { path: '/calendar',    name: 'Calendar',   component: () => import('../pages/public/CalendarPage.vue') },
  { path: '/documents',          name: 'Documents',       component: () => import('../pages/public/DocumentsPage.vue') },
  { path: '/school-documents',   name: 'SchoolDocuments', component: () => import('../pages/public/SchoolDocumentsPublicPage.vue') },

  // Auth
  { path: '/login',          name: 'Login',         component: () => import('../pages/auth/LoginPage.vue'),        meta: { requiresGuest: true } },
  { path: '/register',       name: 'Register',      component: () => import('../pages/auth/RegisterPage.vue'),     meta: { requiresGuest: true } },
  { path: '/request-access', name: 'RequestAccess', component: () => import('../pages/auth/RequestAccessPage.vue'), meta: { requiresAuth: true } },

  // Admin
  { path: '/admin',              name: 'AdminDashboard',  component: () => import('../pages/admin/AdminDashboard.vue'),      meta: { requiresAdmin: true } },
  { path: '/admin/config',       name: 'AdminConfig',     component: () => import('../pages/admin/ConfigPage.vue'),          meta: { requiresAdmin: true } },
  { path: '/admin/users',        name: 'AdminUsers',      component: () => import('../pages/admin/UsersPage.vue'),           meta: { requiresAdmin: true } },
  { path: '/admin/teachers',     name: 'AdminTeachers',   component: () => import('../pages/admin/TeachersPage.vue'),        meta: { requiresAdmin: true } },
  { path: '/admin/students',     name: 'AdminStudents',   component: () => import('../pages/admin/StudentsPage.vue'),        meta: { requiresAdmin: true } },
  { path: '/admin/news',         name: 'AdminNews',       component: () => import('../pages/admin/NewsManagePage.vue'),      meta: { requiresAdmin: true } },
  { path: '/admin/media',        name: 'AdminMedia',      component: () => import('../pages/admin/MediaManagePage.vue'),     meta: { requiresAdmin: true } },
  { path: '/admin/activities',   name: 'AdminActivities', component: () => import('../pages/admin/ActivitiesManagePage.vue'), meta: { requiresAdmin: true } },
  { path: '/admin/org-pages',    name: 'AdminOrgPages',   component: () => import('../pages/admin/OrgPagesManagePage.vue'),   meta: { requiresAdmin: true } },
  { path: '/admin/nav-systems',  name: 'AdminNavSystems', component: () => import('../pages/admin/NavSystemsManagePage.vue'), meta: { requiresAdmin: true } },
  { path: '/admin/wpa',          name: 'AdminWpa',        component: () => import('../pages/admin/WpaAdminPage.vue'),         meta: { requiresAdmin: true } },
  { path: '/admin/calendar',     name: 'AdminCalendar',   component: () => import('../pages/admin/CalendarAdminPage.vue'),    meta: { requiresAdmin: true } },
  { path: '/admin/documents',    name: 'AdminDocuments',  component: () => import('../pages/admin/DocumentsAdminPage.vue'),   meta: { requiresAdmin: true } },
  { path: '/admin/sis',          name: 'AdminSis',        component: () => import('../pages/admin/SisPage.vue'),              meta: { requiresAdmin: true } },
  { path: '/admin/sis/import',   name: 'AdminSisImport',  component: () => import('../pages/admin/SisImportPage.vue'),        meta: { requiresAdmin: true } },
  { path: '/admin/api-keys',          name: 'AdminApiKeys',       component: () => import('../pages/admin/ApiKeysPage.vue'),              meta: { requiresAdmin: true } },
  { path: '/admin/school-documents', name: 'AdminSchoolDocuments', component: () => import('../pages/admin/SchoolDocumentsAdminPage.vue'), meta: { requiresAdmin: true } },
  { path: '/students-info',      name: 'StudentsInfo',    component: () => import('../pages/public/StudentsDashboardPage.vue') },
  { path: '/students-health',   name: 'StudentsHealth',  component: () => import('../pages/public/StudentHealthPage.vue') },
  { path: '/calendar',           name: 'Calendar',        component: () => import('../pages/public/CalendarPage.vue') },

  // Teacher
  { path: '/dashboard', name: 'Dashboard', component: () => import('../pages/teacher/DashboardPage.vue'), meta: { requiresApproved: true } },
  { path: '/students',  name: 'Students',  component: () => import('../pages/teacher/StudentsPage.vue'),  meta: { requiresApproved: true } },
  { path: '/profile',   name: 'Profile',   component: () => import('../pages/teacher/ProfilePage.vue'),   meta: { requiresApproved: true } },
  { path: '/wpa',       name: 'Wpa',       component: () => import('../pages/teacher/WpaPage.vue'),       meta: { requiresApproved: true } },

  { path: '/:pathMatch(.*)*', redirect: '/' },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 }),
})

router.beforeEach(async (to) => {
  // หน้า public ไม่ต้องเช็ค auth
  const publicRoutes = ['Home', 'News', 'NewsDetail', 'Activities', 'Media', 'MediaDetail', 'Personnel', 'PersonnelStats', 'OrgDetail', 'WpaPublic', 'StudentsInfo', 'StudentsHealth', 'Calendar', 'Documents', 'SchoolDocuments']
  if (publicRoutes.includes(to.name)) return

  // รอให้ initAuth() เสร็จก่อน (ป้องกัน auth-lock ชนกัน)
  await waitForAuth()

  // ใช้ค่า reactive จาก useAuth — ไม่ query Supabase ซ้ำ
  const { user, profile } = useAuth()

  const isLoggedIn = !!user.value
  const isAdmin    = profile.value?.role === 'admin' && profile.value?.is_approved === true
  const isApproved = profile.value?.is_approved === true

  // ผู้ใช้ login แล้ว ไม่ควรอยู่หน้า guest
  if (to.meta.requiresGuest && isLoggedIn) {
    return isAdmin ? { name: 'AdminDashboard' } : { name: 'Dashboard' }
  }

  // ต้อง login
  if ((to.meta.requiresAuth || to.meta.requiresAdmin || to.meta.requiresApproved) && !isLoggedIn) {
    return { name: 'Login' }
  }

  // ต้องเป็น admin
  if (to.meta.requiresAdmin && !isAdmin) {
    return isLoggedIn ? { name: 'RequestAccess' } : { name: 'Login' }
  }

  // ต้อง approved
  if (to.meta.requiresApproved && !isApproved) {
    return { name: 'RequestAccess' }
  }

  // อยู่หน้า request-access แต่ approved แล้ว
  if (to.name === 'RequestAccess' && isApproved) {
    return isAdmin ? { name: 'AdminDashboard' } : { name: 'Dashboard' }
  }
})

export default router
