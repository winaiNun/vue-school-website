<template>
  <section class="py-16" :style="bgCss">
    <div class="max-w-7xl mx-auto px-4">

      <!-- Section Header -->
      <div class="text-center mb-10">
        <VineDivider :variant="variant" :stem-color="stemColor" :leaf-color="leafColor" class="mb-3">
          <span class="text-xl">{{ icon }}</span>
          <span class="w-px h-5 mx-0.5" :style="{ background: stemColor + '99' }"></span>
          <h2 class="text-xl font-extrabold tracking-wide" :style="{ color: titleColor }">{{ title }}</h2>
        </VineDivider>
        <p class="text-gray-400 text-sm">{{ subtitle }}</p>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
        <div v-for="i in 6" :key="i" class="animate-pulse flex items-center gap-4 bg-white/80 border border-gray-100 rounded-2xl px-4 py-3.5">
          <div class="w-12 h-12 rounded-xl bg-gray-200 flex-shrink-0"></div>
          <div class="flex-1 space-y-2">
            <div class="h-3 bg-gray-200 rounded w-3/4"></div>
            <div class="h-2 bg-gray-200 rounded w-1/2"></div>
          </div>
        </div>
      </div>

      <!-- Card Grid -->
      <div v-else-if="activities.length" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
        <a v-for="(item, idx) in activities" :key="item.id"
          :href="item.link_url || '#'"
          :target="item.link_url ? '_blank' : '_self'"
          rel="noopener noreferrer"
          @click="incrementViews(item)"
          class="group flex items-center gap-4 bg-white border border-gray-200 rounded-2xl px-4 py-3.5 hover:border-orange-300 hover:shadow-md transition-all no-underline">
          <!-- Icon -->
          <div :class="['w-12 h-12 rounded-xl flex items-center justify-center text-2xl flex-shrink-0 transition-transform group-hover:scale-110', FOLDER_COLORS[idx % FOLDER_COLORS.length]]">
            {{ item.cover_emoji || '📁' }}
          </div>
          <!-- Info -->
          <div class="min-w-0 flex-1">
            <h3 class="text-sm font-semibold text-gray-900 group-hover:text-orange-600 transition-colors line-clamp-1">
              {{ item.title }}
            </h3>
            <div class="flex items-center gap-2 mt-1 flex-wrap">
              <span :class="['px-2 py-0.5 rounded-full text-xs font-medium', linkMeta(item).badgeCls]">
                {{ linkMeta(item).short }}
              </span>
              <span v-if="item.activity_date" class="text-xs text-gray-400">{{ formatDate(item.activity_date) }}</span>
              <span class="text-xs text-gray-400 ml-auto">👁 {{ (item.views || 0).toLocaleString() }}</span>
            </div>
          </div>
          <span class="text-gray-300 group-hover:text-orange-400 group-hover:translate-x-0.5 transition-all flex-shrink-0">→</span>
        </a>
      </div>

      <div v-else class="text-center py-16 text-gray-400">
        <div class="text-6xl mb-4">📁</div>
        <p>ยังไม่มีภาพกิจกรรม</p>
      </div>

      <!-- View all -->
      <div class="text-center mt-8">
        <RouterLink to="/activities"
          class="inline-flex items-center gap-2 px-7 py-3 rounded-2xl border-2 border-orange-200 text-orange-600 font-semibold text-sm hover:bg-orange-500 hover:text-white hover:border-orange-500 transition-all duration-300">
          ดูภาพกิจกรรมทั้งหมด <span>→</span>
        </RouterLink>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { supabase } from '../../lib/supabase'
import VineDivider from './VineDivider.vue'
import { getSectionBgStyle, getTitleColor } from '../../utils/sectionBg.js'

const props = defineProps({
  title:     { type: String, default: 'ภาพกิจกรรม' },
  subtitle:  { type: String, default: 'บรรยากาศกิจกรรมและความทรงจำของโรงเรียน' },
  icon:      { type: String, default: '🖼️' },
  variant:   { type: String, default: 'diamond' },
  stemColor: { type: String, default: '#f97316' },
  leafColor: { type: String, default: '#fdba74' },
  bgStyle:   { type: String, default: 'gray' },
  bgImage:   { type: String, default: '' },
  bgOverlay: { type: String, default: 'light' },
  darkColor: { type: String, default: '#1e3a5f' },
})

const bgCss      = computed(() => getSectionBgStyle(props.bgStyle, props.stemColor, props.bgImage, props.bgOverlay, props.darkColor))
const titleColor = computed(() => getTitleColor(props.stemColor, props.bgStyle, props.bgOverlay))

const FOLDER_COLORS = [
  'bg-orange-100', 'bg-blue-100', 'bg-green-100', 'bg-purple-100',
  'bg-pink-100', 'bg-yellow-100', 'bg-teal-100', 'bg-red-100',
]

const LINK_TYPES = {
  drive:    { short: '🗂️ Drive',    badgeCls: 'bg-blue-100 text-blue-700' },
  photos:   { short: '📷 Photos',   badgeCls: 'bg-teal-100 text-teal-700' },
  facebook: { short: '📘 Facebook',  badgeCls: 'bg-indigo-100 text-indigo-700' },
  flickr:   { short: '📸 Flickr',   badgeCls: 'bg-pink-100 text-pink-700' },
  youtube:  { short: '▶️ YouTube',   badgeCls: 'bg-red-100 text-red-700' },
  link:     { short: '🔗 ลิงค์',    badgeCls: 'bg-gray-100 text-gray-600' },
  none:     { short: '📁 อัลบั้ม',  badgeCls: 'bg-white/60 text-gray-500' },
}

function detectType(url) {
  if (!url) return 'none'
  if (/drive\.google\.com/i.test(url))    return 'drive'
  if (/photos\.google\.com/i.test(url))   return 'photos'
  if (/facebook\.com|fb\.com/i.test(url)) return 'facebook'
  if (/flickr\.com/i.test(url))           return 'flickr'
  if (/youtube\.com|youtu\.be/i.test(url)) return 'youtube'
  return 'link'
}

function linkMeta(item) { return LINK_TYPES[detectType(item.link_url)] }

function formatDate(d) {
  return d ? new Date(d).toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric' }) : ''
}

const activities = ref([])
const loading    = ref(true)

function incrementViews(item) {
  if (item.link_url) {
    item.views = (item.views || 0) + 1
    supabase.rpc('increment_activity_views', { album_id: item.id }).catch(() => {})
  }
}

onMounted(async () => {
  loading.value = true
  const { data } = await supabase.from('activities')
    .select('id,title,cover_emoji,link_url,activity_date,views')
    .eq('is_published', true)
    .order('activity_date', { ascending: false, nullsFirst: false })
    .order('created_at', { ascending: false })
    .limit(8)
  activities.value = data || []
  loading.value = false
})
</script>
