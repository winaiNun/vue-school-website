<template>
  <section v-if="stats" class="py-14 bg-gradient-to-br from-slate-50 to-blue-50">
    <div class="max-w-6xl mx-auto px-4">

      <!-- Header -->
      <div class="text-center mb-10">
        <VineDivider :variant="props.variant" :stem-color="props.stemColor" :leaf-color="props.leafColor" class="mb-3">
          <span class="text-xl">🎓</span>
          <span class="w-px h-5 mx-0.5" :style="{ background: props.stemColor + '99' }"></span>
          <h2 class="text-xl font-extrabold tracking-wide text-gray-800">{{ props.title }}</h2>
        </VineDivider>
        <p class="text-gray-400 text-sm">{{ props.subtitle || ('ข้อมูล ณ ' + sessionLabel) }}</p>
      </div>

      <!-- Big 4 stats -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center hover:shadow-md transition-shadow">
          <p class="text-xs text-gray-400 mb-1">นักเรียนทั้งหมด</p>
          <p class="text-4xl font-black text-blue-600">{{ stats.total?.toLocaleString() }}</p>
          <p class="text-xs text-gray-400 mt-1">คน</p>
        </div>
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center hover:shadow-md transition-shadow">
          <p class="text-xs text-gray-400 mb-1">👦 นักเรียนชาย</p>
          <p class="text-4xl font-black text-sky-500">{{ stats.male?.toLocaleString() }}</p>
          <p class="text-xs text-gray-400 mt-1">{{ stats.total ? Math.round(stats.male/stats.total*100) : 0 }}%</p>
        </div>
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center hover:shadow-md transition-shadow">
          <p class="text-xs text-gray-400 mb-1">👧 นักเรียนหญิง</p>
          <p class="text-4xl font-black text-pink-500">{{ stats.female?.toLocaleString() }}</p>
          <p class="text-xs text-gray-400 mt-1">{{ stats.total ? Math.round(stats.female/stats.total*100) : 0 }}%</p>
        </div>
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center hover:shadow-md transition-shadow">
          <p class="text-xs text-gray-400 mb-1">🏫 ห้องเรียน</p>
          <p class="text-4xl font-black text-purple-600">{{ roomCount }}</p>
          <p class="text-xs text-gray-400 mt-1">ห้อง</p>
        </div>
      </div>

      <!-- Education group bars -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-6">
        <h3 class="text-sm font-semibold text-gray-500 mb-5 text-center tracking-wide uppercase">จำนวนนักเรียนแยกตามระดับการศึกษา</h3>
        <div class="space-y-4">
          <div v-for="g in eduGroups" :key="g.key">
            <div class="flex items-center justify-between mb-1.5">
              <span class="text-sm font-semibold text-gray-700">{{ g.label }}</span>
              <span class="text-sm font-bold text-gray-900">
                {{ groupStats(g.levels).total.toLocaleString() }}
                <span class="text-xs text-gray-400 font-normal">คน</span>
                <span class="text-xs text-gray-300 mx-1">·</span>
                <span class="text-xs text-sky-500">{{ groupStats(g.levels).male }}ช</span>
                <span class="text-xs text-gray-300 mx-0.5">/</span>
                <span class="text-xs text-pink-500">{{ groupStats(g.levels).female }}ญ</span>
              </span>
            </div>
            <div class="w-full bg-gray-100 rounded-full h-3 overflow-hidden">
              <div :class="['h-3 rounded-full transition-all duration-700', g.color]"
                :style="`width:${stats.total ? Math.round(groupStats(g.levels).total/stats.total*100) : 0}%`"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- CTA button -->
      <div class="text-center">
        <router-link to="/students-info"
          class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold px-8 py-3 rounded-2xl shadow-lg shadow-blue-200 transition-all hover:shadow-xl hover:-translate-y-0.5">
          📊 ดูสารสนเทศข้อมูลนักเรียนทั้งหมด
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
          </svg>
        </router-link>
      </div>

    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'
import VineDivider from './VineDivider.vue'

const props = defineProps({
  title:     { type: String, default: 'ข้อมูลนักเรียน' },
  subtitle:  { type: String, default: '' },
  variant:   { type: String, default: 'circuit' },
  stemColor: { type: String, default: '#3b82f6' },
  leafColor: { type: String, default: '#93c5fd' },
})

const stats        = ref(null)
const sessionLabel = ref('')


const eduGroups = [
  { key: 'kinder', label: 'อนุบาล',            levels: ['อ.1','อ.2','อ.3'], color: 'bg-emerald-400' },
  { key: 'pri-lo', label: 'ประถมศึกษาตอนต้น',   levels: ['ป.1','ป.2','ป.3'], color: 'bg-blue-400'    },
  { key: 'pri-hi', label: 'ประถมศึกษาตอนปลาย',  levels: ['ป.4','ป.5','ป.6'], color: 'bg-indigo-400'  },
  { key: 'sec-lo', label: 'มัธยมศึกษาตอนต้น',   levels: ['ม.1','ม.2','ม.3'], color: 'bg-violet-400'  },
  { key: 'sec-hi', label: 'มัธยมศึกษาตอนปลาย',  levels: ['ม.4','ม.5','ม.6'], color: 'bg-pink-400'    },
]

function groupStats(levels) {
  if (!stats.value?.byLevel) return { total: 0, male: 0, female: 0 }
  const byRoom = stats.value?.byRoom || {}
  let total = 0, male = 0, female = 0
  for (const [key, data] of Object.entries(byRoom)) {
    const lvl = key.split('/')[0]
    if (levels.includes(lvl)) {
      total  += data.total  || 0
      male   += data.male   || 0
      female += data.female || 0
    }
  }
  return { total, male, female }
}

const roomCount = computed(() =>
  Object.keys(stats.value?.byRoom || {}).length
)

onMounted(async () => {
  const { data } = await supabase.rpc('get_current_student_stats')
  stats.value = data || null
  sessionLabel.value = 'นักเรียนปัจจุบัน'
})
</script>
