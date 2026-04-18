<template>
  <section class="py-16 relative overflow-hidden" :style="bgCss">
    <!-- Background decoration -->
    <div v-if="isDark" class="absolute inset-0 opacity-10">
      <div class="absolute top-0 left-1/4 w-96 h-96 rounded-full bg-white blur-3xl"></div>
      <div class="absolute bottom-0 right-1/4 w-96 h-96 rounded-full bg-indigo-300 blur-3xl"></div>
    </div>

    <div class="relative max-w-7xl mx-auto px-4">
      <!-- Section Header -->
      <div class="text-center mb-12">
        <VineDivider :variant="variant" :stem-color="stemColor" :leaf-color="leafColor" class="mb-3">
          <span class="text-xl">{{ icon }}</span>
          <span class="w-px h-5 mx-0.5" :style="{ background: stemColor + '99' }"></span>
          <h2 class="text-xl font-extrabold tracking-wide" :style="{ color: titleColor }">{{ title }}</h2>
        </VineDivider>
        <p :class="['text-sm', isDark ? 'text-blue-200' : 'text-gray-400']">{{ subtitle }}</p>
      </div>

      <div v-if="!systems.length" :class="['text-center py-10 text-sm opacity-50', isDark ? 'text-white' : 'text-gray-400']">
        ยังไม่มีระบบงาน — เพิ่มได้ที่ Admin → จัดการระบบงาน
      </div>
      <div v-else class="flex flex-wrap justify-center gap-4">
        <component
          v-for="system in systems" :key="system.id"
          :is="system.is_external ? 'a' : RouterLink"
          v-bind="system.is_external ? { href: system.url, target: '_blank', rel: 'noopener noreferrer' } : { to: system.url }"
          :class="['group flex flex-col items-center p-6 rounded-2xl transition-all duration-300 cursor-pointer hover:shadow-xl w-[calc(50%-8px)] sm:w-[calc(33.333%-11px)] lg:w-[calc(25%-12px)]', isDark ? 'bg-white/10 backdrop-blur-sm border border-white/10 hover:bg-white/20 hover:border-white/30' : 'bg-white border border-gray-200 hover:border-gray-300 shadow-sm']">
          <div class="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl mb-3 transition-all duration-300 group-hover:scale-110 group-hover:-translate-y-1 shadow-lg"
            :style="{ background: system.icon_bg || '#3b82f6' }">
            {{ system.icon || '🔗' }}
          </div>
          <h3 :class="['font-semibold text-sm text-center transition-colors', isDark ? 'text-white group-hover:text-yellow-300' : 'text-gray-800 group-hover:text-blue-600']">
            {{ system.label }}
          </h3>
          <p :class="['text-xs mt-1 text-center', isDark ? 'text-blue-200' : 'text-gray-500']">{{ system.description }}</p>
        </component>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import VineDivider from './VineDivider.vue'
import { getSectionBgStyle, isBgDark, getTitleColor } from '../../utils/sectionBg.js'
import { supabase } from '../../lib/supabase'

const props = defineProps({
  title:     { type: String, default: 'ระบบงานโรงเรียน' },
  subtitle:  { type: String, default: 'เข้าถึงระบบงานต่างๆ ของโรงเรียน' },
  icon:      { type: String, default: '🏫' },
  variant:   { type: String, default: 'chevron' },
  stemColor: { type: String, default: '#fbbf24' },
  leafColor: { type: String, default: '#fde68a' },
  bgStyle:   { type: String, default: 'dark' },
  bgImage:   { type: String, default: '' },
  bgOverlay: { type: String, default: 'light' },
  darkColor: { type: String, default: '#1e3a5f' },
})

const bgCss      = computed(() => getSectionBgStyle(props.bgStyle, props.stemColor, props.bgImage, props.bgOverlay, props.darkColor))
const isDark     = computed(() => isBgDark(props.bgStyle))
const titleColor = computed(() => getTitleColor(props.stemColor, props.bgStyle, props.bgOverlay))

const systems = ref([])

onMounted(async () => {
  const { data } = await supabase
    .from('nav_systems')
    .select('id,label,description,url,icon,icon_bg,is_external')
    .eq('is_active', true)
    .neq('show_in_grid', false)
    .order('sort_order')
  systems.value = data || []
})
</script>
