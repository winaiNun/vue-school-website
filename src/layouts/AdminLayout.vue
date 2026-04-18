<template>
  <div class="min-h-screen flex bg-gray-50">

    <!-- Mobile Overlay -->
    <div v-if="isMobile && sidebarOpen"
      class="fixed inset-0 z-40 bg-black/50 lg:hidden"
      @click="sidebarOpen = false"
    />

    <!-- Sidebar -->
    <aside :class="[
      'fixed inset-y-0 left-0 z-50 flex flex-col bg-gradient-to-b from-blue-900 to-blue-800 text-white shadow-xl transition-all duration-300',
      isMobile
        ? (sidebarOpen ? 'w-64 translate-x-0' : 'w-64 -translate-x-full')
        : (sidebarOpen ? 'w-64' : 'w-16')
    ]">
      <!-- Logo -->
      <div class="flex items-center h-16 px-4 border-b border-blue-700">
        <img v-if="config?.logo_url" :src="config.logo_url" class="w-8 h-8 rounded-full object-cover flex-shrink-0" />
        <div v-else class="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center flex-shrink-0">
          <span class="text-xs font-bold">ร</span>
        </div>
        <span v-if="sidebarOpen" class="ml-3 text-sm font-bold truncate">{{ config?.name_th || 'โรงเรียน' }}</span>
        <button v-if="!isMobile" @click="sidebarOpen = !sidebarOpen" class="ml-auto text-blue-300 hover:text-white">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
          </svg>
        </button>
        <button v-else @click="sidebarOpen = false" class="ml-auto text-blue-300 hover:text-white">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>

      <!-- Nav Items -->
      <nav class="flex-1 py-3 overflow-y-auto">
        <template v-for="group in navGroups" :key="group.label">
          <!-- Group Label -->
          <div v-if="sidebarOpen && group.label"
            class="px-4 pt-4 pb-1 text-[10px] font-semibold tracking-widest text-blue-400 uppercase select-none">
            {{ group.label }}
          </div>
          <div v-else-if="!sidebarOpen && group.label" class="my-2 mx-3 border-t border-blue-700/60"></div>

          <!-- Group Items -->
          <router-link v-for="item in group.items" :key="item.to" :to="item.to"
            @click="isMobile && (sidebarOpen = false)"
            :class="['flex items-center gap-3 px-4 py-2.5 text-sm transition-all duration-200 hover:bg-blue-700/50',
              $route.path === item.to ? 'bg-blue-700 border-r-4 border-yellow-400 text-white' : 'text-blue-200']"
          >
            <span class="text-base flex-shrink-0">{{ item.icon }}</span>
            <span v-if="sidebarOpen" class="truncate">{{ item.label }}</span>
          </router-link>
        </template>
      </nav>

      <!-- Bottom -->
      <div class="border-t border-blue-700 p-4">
        <button @click="handleSignOut"
          class="flex items-center gap-3 text-sm text-blue-200 hover:text-white transition-colors w-full"
        >
          <span class="text-lg">🚪</span>
          <span v-if="sidebarOpen">ออกจากระบบ</span>
        </button>
      </div>
    </aside>

    <!-- Main -->
    <div :class="[
      'flex-1 flex flex-col transition-all duration-300',
      isMobile ? 'ml-0' : (sidebarOpen ? 'ml-64' : 'ml-16')
    ]">
      <!-- Top Bar -->
      <header class="h-16 bg-white border-b border-gray-200 flex items-center px-4 md:px-6 shadow-sm sticky top-0 z-30">
        <!-- Hamburger (mobile only) -->
        <button @click="sidebarOpen = true" class="lg:hidden mr-3 p-2 rounded-lg hover:bg-gray-100 text-gray-600">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
          </svg>
        </button>
        <div class="flex-1">
          <h1 class="text-base md:text-lg font-semibold text-gray-800 truncate">{{ pageTitle }}</h1>
        </div>
        <div class="flex items-center gap-2 md:gap-3">
          <!-- Storage Usage (admin only) -->
          <div v-if="isAdmin && storageUsed !== null" class="hidden md:flex items-center gap-2 bg-gray-50 border border-gray-200 rounded-xl px-3 py-1.5 cursor-default"
            :title="`${storageFiles} ไฟล์ · ${formatBytes(storageUsed)} จาก 1 GB`">
            <svg class="w-3.5 h-3.5 text-gray-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2"/>
            </svg>
            <div class="flex flex-col gap-0.5">
              <div class="flex items-center gap-1.5">
                <span class="text-xs text-gray-600 font-medium">{{ formatBytes(storageUsed) }}</span>
                <span class="text-[10px] text-gray-400">/ 1 GB</span>
              </div>
              <div class="w-16 h-1 bg-gray-200 rounded-full overflow-hidden">
                <div :class="['h-full rounded-full transition-all', storageColor]"
                  :style="{ width: storagePercent + '%' }"/>
              </div>
            </div>
            <button @click="fetchStorageUsage" class="text-gray-300 hover:text-gray-500 transition-colors" title="รีเฟรช">
              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
              </svg>
            </button>
          </div>

          <div class="text-right hidden sm:block">
            <p class="text-sm font-medium text-gray-800">{{ profile?.full_name || user?.email }}</p>
            <p class="text-xs text-gray-500">{{ isAdmin ? 'ผู้ดูแลระบบ' : 'ครู' }}</p>
          </div>
          <!-- Avatar: แสดงรูปโปรไฟล์ถ้ามี -->
          <div class="w-9 h-9 rounded-full overflow-hidden flex-shrink-0">
            <img v-if="profile?.profile_image_url" :src="profile.profile_image_url" class="w-full h-full object-cover" />
            <div v-else class="w-full h-full bg-blue-600 flex items-center justify-center text-white font-bold text-sm">
              {{ (profile?.full_name || user?.email || 'A').charAt(0).toUpperCase() }}
            </div>
          </div>
        </div>
      </header>

      <!-- Content -->
      <main class="flex-1 p-4 md:p-6">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuth } from '../composables/useAuth'
import { useSchoolConfig } from '../composables/useSchoolConfig'
import { supabase } from '../lib/supabase'

const route = useRoute()
const router = useRouter()
const { user, profile, isAdmin, signOut } = useAuth()
const { config } = useSchoolConfig()

const isMobile = ref(false)
const sidebarOpen = ref(true)
const storageUsed = ref(null)   // bytes
const storageFiles = ref(0)
const STORAGE_LIMIT = 1024 * 1024 * 1024  // 1 GB (free tier)

function formatBytes(bytes) {
  if (bytes === null) return '...'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}
const storagePercent = computed(() => {
  if (!storageUsed.value) return 0
  return Math.min((storageUsed.value / STORAGE_LIMIT) * 100, 100)
})
const storageColor = computed(() => {
  const p = storagePercent.value
  if (p >= 80) return 'bg-red-500'
  if (p >= 50) return 'bg-yellow-500'
  return 'bg-green-500'
})

async function fetchStorageUsage() {
  try {
    const { data } = await supabase.rpc('get_storage_usage')
    if (data?.[0]) {
      storageUsed.value = Number(data[0].total_size)
      storageFiles.value = data[0].file_count
    }
  } catch {}
}

function checkMobile() {
  isMobile.value = window.innerWidth < 1024
  if (isMobile.value) sidebarOpen.value = false
  else sidebarOpen.value = true
}

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
  fetchStorageUsage()
})
onUnmounted(() => window.removeEventListener('resize', checkMobile))

const adminNavGroups = [
  {
    label: '',
    items: [
      { to: '/admin', icon: '📊', label: 'แดชบอร์ด' },
    ],
  },
  {
    label: 'บุคลากร',
    items: [
      { to: '/admin/users',    icon: '👥', label: 'จัดการผู้ใช้' },
      { to: '/admin/teachers', icon: '👨‍🏫', label: 'จัดการครู' },
      { to: '/admin/wpa',      icon: '📋', label: 'วPA ครู' },
    ],
  },
  {
    label: 'นักเรียน',
    items: [
      { to: '/admin/students', icon: '🎓', label: 'จัดการนักเรียน' },
      { to: '/admin/calendar', icon: '📅', label: 'ปฏิทินวิชาการ' },
    ],
  },
  {
    label: 'เนื้อหาสาธารณะ',
    items: [
      { to: '/admin/org-pages',  icon: '📄', label: 'ข้อมูลพื้นฐาน' },
      { to: '/admin/news',       icon: '📰', label: 'จัดการข่าว' },
      { to: '/admin/media',      icon: '📚', label: 'คลังสื่อ' },
      { to: '/admin/activities', icon: '🖼️', label: 'จัดการกิจกรรม' },
      { to: '/admin/documents',        icon: '📂', label: 'เอกสาร/ดาวน์โหลด' },
      { to: '/admin/school-documents', icon: '📋', label: 'คำสั่ง/ประกาศ' },
    ],
  },
  {
    label: 'ระบบ',
    items: [
      { to: '/admin/config',      icon: '⚙️', label: 'ตั้งค่าโรงเรียน' },
      { to: '/admin/nav-systems', icon: '🔗', label: 'เมนูระบบงาน' },
      { to: '/admin/api-keys',    icon: '🔑', label: 'API Keys' },
    ],
  },
]

const teacherNavGroups = [
  {
    label: '',
    items: [
      { to: '/dashboard', icon: '🏠', label: 'หน้าหลัก' },
      { to: '/profile',   icon: '👤', label: 'โปรไฟล์ของฉัน' },
      { to: '/students',  icon: '🎓', label: 'รายชื่อนักเรียน' },
      { to: '/wpa',       icon: '📋', label: 'วPA ของฉัน' },
    ],
  },
]

const navGroups = computed(() => isAdmin.value ? adminNavGroups : teacherNavGroups)

const allPageTitles = {
  '/admin': 'แดชบอร์ด',
  '/admin/config': 'ตั้งค่าโรงเรียน',
  '/admin/users': 'จัดการผู้ใช้',
  '/admin/teachers': 'จัดการครู',
  '/admin/students': 'จัดการนักเรียน',
  '/admin/org-pages': 'ข้อมูลพื้นฐาน',
  '/admin/news': 'จัดการข่าว',
  '/admin/media': 'คลังสื่อ',
  '/admin/activities': 'จัดการกิจกรรม',
  '/admin/sis': 'ข้อมูลนักเรียน (SIS)',
  '/admin/sis/import': 'นำเข้าข้อมูลนักเรียน',
  '/admin/calendar': 'ปฏิทินวิชาการ',
  '/admin/wpa': 'วPA ครู',
  '/admin/nav-systems': 'เมนูระบบงาน',
  '/admin/documents':        'เอกสาร/ดาวน์โหลด',
  '/admin/school-documents': 'คำสั่ง/ประกาศโรงเรียน',
  '/dashboard': 'หน้าหลัก',
  '/profile': 'โปรไฟล์ของฉัน',
  '/wpa': 'วPA ของฉัน',
  '/students': 'รายชื่อนักเรียน',
}
const pageTitle = computed(() => allPageTitles[route.path] || '')

async function handleSignOut() {
  await signOut()
  router.push('/login')
}
</script>
