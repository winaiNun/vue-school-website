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

      <!-- Loading skeleton -->
      <div v-if="loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <div v-for="i in 4" :key="i" class="bg-gray-50 rounded-3xl overflow-hidden animate-pulse">
          <div class="bg-gray-200 aspect-[4/3]"></div>
          <div class="p-5 space-y-3">
            <div class="h-3 bg-gray-200 rounded-full w-1/3"></div>
            <div class="h-4 bg-gray-200 rounded-full"></div>
            <div class="h-4 bg-gray-200 rounded-full w-4/5"></div>
          </div>
        </div>
      </div>

      <!-- News grid -->
      <div v-else-if="news.length" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <RouterLink v-for="item in news" :key="item.id" :to="`/news/${item.id}`"
          class="group bg-white rounded-3xl shadow-md border border-gray-200/80 overflow-hidden hover:shadow-xl hover:-translate-y-1.5 transition-all duration-300 flex flex-col">
          <!-- Cover -->
          <div class="aspect-[4/3] overflow-hidden bg-gray-100 relative flex-shrink-0">
            <img v-if="item.cover_image_url" :src="item.cover_image_url" :alt="item.title"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
            <div v-else class="w-full h-full bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center text-5xl">📰</div>
            <span class="absolute top-3 left-3 text-xs font-semibold text-white bg-blue-600/90 backdrop-blur-sm px-2.5 py-1 rounded-full">
              {{ item.category }}
            </span>
            <span v-if="item.is_pinned" class="absolute top-3 right-3 text-yellow-400 text-sm drop-shadow">📌</span>
          </div>
          <!-- Info -->
          <div class="p-5 flex flex-col flex-1">
            <h3 class="font-bold text-gray-900 leading-snug group-hover:text-blue-700 transition-colors line-clamp-2 mb-2">
              {{ item.title }}
            </h3>
            <p v-if="item.excerpt" class="text-sm text-gray-500 line-clamp-2 flex-1 leading-relaxed">{{ item.excerpt }}</p>
            <p v-else class="text-sm text-gray-400 flex-1 italic">คลิกเพื่ออ่านรายละเอียด →</p>
            <p class="text-xs text-gray-400 mt-4 pt-3 border-t border-gray-50">📅 {{ formatDate(item.published_at) }}</p>
          </div>
        </RouterLink>
      </div>

      <div v-else class="text-center py-16 text-gray-300">
        <div class="text-6xl mb-4">📰</div>
        <p class="text-gray-400">ยังไม่มีข่าวประชาสัมพันธ์</p>
      </div>

      <!-- View all -->
      <div class="text-center mt-10">
        <RouterLink to="/news"
          class="inline-flex items-center gap-2 px-7 py-3 rounded-2xl border-2 border-blue-200 text-blue-700 font-semibold text-sm hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all duration-300">
          ดูข่าวทั้งหมด <span>→</span>
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
  title:     { type: String, default: 'ข่าวประชาสัมพันธ์' },
  subtitle:  { type: String, default: 'ข่าวสารและประกาศจากโรงเรียน' },
  icon:      { type: String, default: '📰' },
  variant:   { type: String, default: 'circuit' },
  stemColor: { type: String, default: '#3b82f6' },
  leafColor: { type: String, default: '#93c5fd' },
  bgStyle:   { type: String, default: 'white' },
  bgImage:   { type: String, default: '' },
  bgOverlay: { type: String, default: 'light' },
  darkColor: { type: String, default: '#1e3a5f' },
})

const bgCss     = computed(() => getSectionBgStyle(props.bgStyle, props.stemColor, props.bgImage, props.bgOverlay, props.darkColor))
const titleColor = computed(() => getTitleColor(props.stemColor, props.bgStyle, props.bgOverlay))

const news = ref([])
const loading = ref(true)

function formatDate(d) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('th-TH', { year: 'numeric', month: 'long', day: 'numeric' })
}

function getExcerpt(item) {
  if (item.excerpt) return item.excerpt
  if (!item.content || item.content_type !== 'text') return ''
  return item.content.replace(/<[^>]*>/g, '').replace(/\s+/g, ' ').trim().slice(0, 120)
}

onMounted(async () => {
  try {
    const { data } = await supabase
      .from('news')
      .select('id, title, excerpt, cover_image_url, category, published_at, is_pinned')
      .eq('is_published', true)
      .order('is_pinned', { ascending: false })
      .order('published_at', { ascending: false })
      .limit(4)
    news.value = data || []
  } finally {
    loading.value = false
  }
})
</script>
