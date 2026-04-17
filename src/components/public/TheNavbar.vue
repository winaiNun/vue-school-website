<template>
  <header class="sticky top-0 z-50">
    <!-- Top bar -->
    <div v-if="config?.topbar_enabled !== false" class="text-white text-xs py-1.5 px-4 flex justify-between items-center" :style="navStyle.topBar">
      <span>{{ config?.topbar_text || config?.affiliation || 'สำนักงานคณะกรรมการการศึกษาขั้นพื้นฐาน' }}</span>
      <div class="flex gap-4">
        <a v-if="config?.social_facebook" :href="config.social_facebook" target="_blank" class="hover:text-yellow-300 transition-colors">Facebook</a>
        <RouterLink to="/login" class="hover:text-yellow-300 transition-colors">เข้าสู่ระบบ</RouterLink>
      </div>
    </div>

    <!-- Main Nav -->
    <nav class="bg-white shadow-md">
      <div class="max-w-7xl mx-auto px-4">
        <div class="flex items-center h-16 gap-4">
          <!-- Logo + Name -->
          <RouterLink to="/" class="flex items-center gap-3 flex-shrink-0">
            <img v-if="config?.logo_url" :src="config.logo_url" class="w-12 h-12 object-contain" />
            <div v-else class="w-12 h-12 rounded-full flex items-center justify-center" :style="navStyle.loginBtn">
              <span class="text-white text-lg font-bold">ร</span>
            </div>
            <div class="block">
              <p class="font-bold text-gray-900 text-sm leading-tight line-clamp-1 max-w-[160px] sm:max-w-xs md:max-w-none">{{ config?.name_th || 'โรงเรียน' }}</p>
              <p class="text-xs text-gray-500 hidden md:block">{{ config?.area_name || '' }}</p>
            </div>
          </RouterLink>

          <!-- Desktop Menu -->
          <div class="hidden lg:flex items-center gap-1 ml-auto">
            <NavLink v-for="item in menuItems" :key="item.label" :item="item" />
          </div>

          <!-- Login Button (desktop) -->
          <RouterLink to="/login"
            class="hidden lg:flex items-center gap-2 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors ml-2"
            :style="navStyle.loginBtn"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
            </svg>
            เข้าสู่ระบบ
          </RouterLink>

          <!-- Mobile Burger -->
          <button @click="mobileOpen = !mobileOpen" class="lg:hidden ml-auto p-2 rounded-lg hover:bg-gray-100">
            <svg class="w-6 h-6 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path v-if="!mobileOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
              <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        </div>
      </div>

      <!-- Mobile Menu -->
      <Transition name="slide-down">
        <div v-if="mobileOpen" class="lg:hidden border-t border-gray-100 bg-white shadow-lg">
          <div class="px-4 py-3 space-y-1">
            <RouterLink v-for="item in flatMenu" :key="item.to || item.label" :to="item.to"
              @click="mobileOpen = false"
              class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-gray-700 hover:bg-blue-50 hover:text-blue-700 transition-colors text-sm"
            >
              <span>{{ item.icon }}</span>{{ item.label }}
            </RouterLink>
            <RouterLink to="/login" @click="mobileOpen = false"
              class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-white text-sm font-medium mt-2"
              :style="navStyle.mobileBtn"
            >
              <span>👤</span>เข้าสู่ระบบ
            </RouterLink>
          </div>
        </div>
      </Transition>
    </nav>
  </header>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useSchoolConfig } from '../../composables/useSchoolConfig'
import { supabase } from '../../lib/supabase'
import NavLink from './NavLink.vue'

const { config } = useSchoolConfig()
const mobileOpen = ref(false)

// คำนวณ gradient style จาก nav_color
const navStyle = computed(() => {
  const hex = config.value?.nav_color || '#1e3a8a'
  const h   = hex.replace('#', '')
  const r   = parseInt(h.slice(0,2), 16), g = parseInt(h.slice(2,4), 16), b = parseInt(h.slice(4,6), 16)
  const clamp = (v) => Math.min(255, Math.max(0, Math.round(v)))
  const toHex = (v) => clamp(v).toString(16).padStart(2,'0')
  const darker  = `#${toHex(r*.70)}${toHex(g*.70)}${toHex(b*.78)}`
  const lighter = `#${toHex(r*1.15)}${toHex(g*1.12)}${toHex(b*1.20)}`
  return {
    topBar:    { background: `linear-gradient(135deg, ${darker} 0%, ${hex} 100%)` },
    loginBtn:  { backgroundColor: hex },
    mobileBtn: { backgroundColor: hex },
  }
})

const orgPages   = ref([])  // ข้อมูลพื้นฐาน
const navSystems = ref([])  // ระบบงาน

onMounted(async () => {
  const [{ data: pages }, { data: systems }] = await Promise.all([
    supabase.from('org_pages').select('slug,title,icon').eq('is_published', true).order('sort_order').order('created_at'),
    supabase.from('nav_systems').select('label,url,icon,is_external').eq('is_active', true).order('sort_order', { ascending: true }),
  ])
  orgPages.value   = pages   || []
  navSystems.value = systems || []
})

const menuItems = computed(() => [
  { label: 'หน้าแรก', to: '/', icon: '🏠' },
  ...(orgPages.value.length ? [{
    label: 'ข้อมูลพื้นฐาน',
    icon: '📄',
    children: orgPages.value.map(p => ({ label: p.title, to: `/about/${p.slug}`, icon: p.icon || '📄' }))
  }] : []),
  { label: 'ข่าวสาร', to: '/news', icon: '📰' },
  { label: 'กิจกรรม', to: '/activities', icon: '🖼️' },
  { label: 'คลังสื่อ', to: '/media', icon: '📚' },
  { label: 'บุคลากร', to: '/personnel', icon: '👨‍🏫' },
  ...(navSystems.value.length ? [{
    label: 'ระบบงาน',
    icon: '🏫',
    children: navSystems.value.map(s => ({
      label: s.label,
      icon: s.icon || '🔗',
      ...(s.is_external ? { href: s.url } : { to: s.url }),
    }))
  }] : []),
  { label: 'ติดต่อเรา', to: '/#contact', icon: '📞' },
])

const flatMenu = computed(() => [
  { label: 'หน้าแรก', to: '/', icon: '🏠' },
  ...orgPages.value.map(p => ({ label: p.title, to: `/about/${p.slug}`, icon: p.icon || '📄' })),
  { label: 'ข่าวสาร', to: '/news', icon: '📰' },
  { label: 'กิจกรรม', to: '/activities', icon: '🖼️' },
  { label: 'คลังสื่อ', to: '/media', icon: '📚' },
  { label: 'บุคลากร', to: '/personnel', icon: '👨‍🏫' },
  ...navSystems.value.filter(s => !s.is_external).map(s => ({ label: s.label, to: s.url, icon: s.icon || '🔗' })),
  { label: 'ติดต่อเรา', to: '/#contact', icon: '📞' },
])
</script>

<style scoped>
.slide-down-enter-active, .slide-down-leave-active { transition: all 0.25s ease; }
.slide-down-enter-from, .slide-down-leave-to { opacity: 0; transform: translateY(-10px); }
</style>
