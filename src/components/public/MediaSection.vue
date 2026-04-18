<template>
  <section class="py-16" :style="bgCss">
    <div class="max-w-7xl mx-auto px-4">

      <!-- Section Header -->
      <div class="text-center mb-12">
        <VineDivider :variant="variant" :stem-color="stemColor" :leaf-color="leafColor" class="mb-3">
          <span class="text-xl">{{ icon }}</span>
          <span class="w-px h-5 mx-0.5" :style="{ background: stemColor + '99' }"></span>
          <h2 class="text-xl font-extrabold tracking-wide" :style="{ color: titleColor }">{{ title }}</h2>
        </VineDivider>
        <p class="text-gray-400 text-sm">{{ subtitle }}</p>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="grid grid-cols-2 md:grid-cols-4 gap-6">
        <div v-for="i in 4" :key="i" class="bg-gray-50 rounded-3xl overflow-hidden animate-pulse">
          <div class="aspect-video bg-gray-200"></div>
          <div class="p-4 space-y-2">
            <div class="h-3 bg-gray-200 rounded-full w-2/3"></div>
            <div class="h-4 bg-gray-200 rounded-full"></div>
          </div>
        </div>
      </div>

      <!-- Empty -->
      <div v-else-if="!mediaItems.length" class="text-center py-16 text-gray-300">
        <div class="text-6xl mb-4">📭</div>
        <p class="text-gray-400">ยังไม่มีสื่อการเรียนรู้</p>
      </div>

      <!-- Grid -->
      <div v-else class="grid grid-cols-2 md:grid-cols-4 gap-6">
        <RouterLink v-for="item in mediaItems" :key="item.id" :to="`/media/${item.id}`"
          class="group bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-xl hover:-translate-y-1.5 transition-all duration-300">
          <!-- Thumb -->
          <div class="aspect-video bg-gradient-to-br from-indigo-50 to-purple-50 relative overflow-hidden">
            <img v-if="item.thumbnail_url" :src="item.thumbnail_url"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
            <div v-else class="absolute inset-0 flex items-center justify-center">
              <span class="text-5xl opacity-40">{{ typeIcon(item) }}</span>
            </div>
            <!-- Type badge -->
            <span :class="['absolute top-3 left-3 px-2.5 py-1 rounded-full text-xs font-semibold text-white shadow-sm', typeBgColor(item)]">
              {{ typeIcon(item) }} {{ typeShortLabel(item) }}
            </span>
            <span v-if="item.is_featured" class="absolute top-3 right-3 text-yellow-400 drop-shadow text-sm">⭐</span>
          </div>
          <!-- Info -->
          <div class="p-4">
            <div class="flex items-center gap-1.5 flex-wrap mb-1">
              <span class="text-xs text-indigo-600 font-medium">{{ item.category }}</span>
              <span v-if="item.subject_area" class="text-xs text-purple-600 font-medium">· {{ item.subject_area }}</span>
              <span v-if="item.grade_level" class="text-xs text-green-600 bg-green-50 px-1.5 py-0.5 rounded-full font-medium">{{ item.grade_level }}</span>
            </div>
            <h3 class="text-sm font-bold text-gray-900 line-clamp-2 group-hover:text-indigo-700 transition-colors leading-snug">
              {{ item.title }}
            </h3>
            <p v-if="item.description" class="text-xs text-gray-400 mt-1 line-clamp-1">{{ item.description }}</p>
            <div class="flex items-center justify-between mt-2">
              <span v-if="item.author_name" class="text-xs text-gray-400 truncate max-w-[65%]">👤 {{ item.author_name }}</span>
              <span v-if="item.views != null" class="text-xs text-gray-400 ml-auto flex items-center gap-0.5">
                👁 {{ (item.views || 0).toLocaleString() }} ครั้ง
              </span>
            </div>
          </div>
        </RouterLink>
      </div>

      <!-- View all -->
      <div class="text-center mt-10">
        <RouterLink to="/media"
          class="inline-flex items-center gap-2 px-7 py-3 rounded-2xl border-2 border-indigo-200 text-indigo-700 font-semibold text-sm hover:bg-indigo-600 hover:text-white hover:border-indigo-600 transition-all duration-300">
          ดูคลังสื่อทั้งหมด <span>→</span>
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
  title:     { type: String, default: 'คลังสื่อการเรียนรู้' },
  subtitle:  { type: String, default: 'วิดีโอ สื่อนำเสนอ เอกสาร และแหล่งเรียนรู้ออนไลน์' },
  icon:      { type: String, default: '📚' },
  variant:   { type: String, default: 'wave' },
  stemColor: { type: String, default: '#6366f1' },
  leafColor: { type: String, default: '#a5b4fc' },
  bgStyle:   { type: String, default: 'white' },
  bgImage:   { type: String, default: '' },
  bgOverlay: { type: String, default: 'light' },
  darkColor: { type: String, default: '#1e3a5f' },
})

const bgCss     = computed(() => getSectionBgStyle(props.bgStyle, props.stemColor, props.bgImage, props.bgOverlay, props.darkColor))
const titleColor = computed(() => getTitleColor(props.stemColor, props.bgStyle, props.bgOverlay))

const mediaItems = ref([])
const loading    = ref(true)

function detectType(item) {
  if (item.media_type === 'link') return 'link'
  const url = item.content || ''
  const src = url.match(/<iframe[^>]+src=["']([^"']+)["']/i)?.[1] || url
  if (/youtu/.test(src)) return 'youtube'
  if (/docs\.google\.com\/presentation/.test(src)) return 'slides'
  if (/drive\.google\.com/.test(src)) return 'pdf'
  if (/canva\.com/.test(src)) return 'canva'
  return 'embed'
}
function typeIcon(item) {
  return { youtube:'▶️', slides:'📊', pdf:'📄', canva:'🎨', link:'🌐', embed:'🔗' }[detectType(item)] || '🔗'
}
function typeShortLabel(item) {
  return { youtube:'Video', slides:'Slides', pdf:'PDF', canva:'Canva', link:'Link', embed:'Embed' }[detectType(item)] || 'Embed'
}
function typeBgColor(item) {
  return { youtube:'bg-red-500', slides:'bg-green-600', pdf:'bg-orange-500', canva:'bg-purple-600', link:'bg-blue-600', embed:'bg-gray-600' }[detectType(item)] || 'bg-gray-600'
}

onMounted(async () => {
  const { data } = await supabase.from('media')
    .select('id,title,description,thumbnail_url,category,subject_area,grade_level,author_name,views,media_type,content,is_featured')
    .eq('is_published', true)
    .order('is_featured', { ascending: false })
    .order('created_at', { ascending: false })
    .limit(4)
  mediaItems.value = data || []
  loading.value = false
})
</script>
