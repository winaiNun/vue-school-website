<template>
  <PublicLayout>
    <!-- Hero -->
    <div class="bg-gradient-to-r from-blue-800 via-blue-700 to-indigo-700 text-white py-10 px-4">
      <div class="max-w-5xl mx-auto text-center">
        <h1 class="text-2xl md:text-3xl font-bold">🎓 สารสนเทศข้อมูลนักเรียน</h1>
        <p class="text-blue-200 mt-1 text-sm">{{ config?.name_th || 'โรงเรียน' }}</p>
        <p v-if="selectedSession" class="text-blue-300 text-xs mt-1">
          ข้อมูล ณ {{ selectedSession.checkpoint_label }} ปีการศึกษา {{ selectedSession.academic_year }}
        </p>
      </div>
    </div>

    <div class="max-w-5xl mx-auto px-4 py-8">

      <!-- Health Banner -->
      <RouterLink to="/students-health"
        class="flex items-center gap-4 bg-gradient-to-r from-green-600 to-teal-600 text-white rounded-2xl p-4 mb-6 hover:from-green-700 hover:to-teal-700 transition shadow-sm group">
        <div class="text-3xl">🏥</div>
        <div class="flex-1">
          <p class="font-bold text-sm">สารสนเทศสุขภาพนักเรียน (BMI)</p>
          <p class="text-green-200 text-xs mt-0.5">ดูสถิติน้ำหนัก ส่วนสูง และดัชนีมวลกายแยกตามชั้นเรียน</p>
        </div>
        <svg class="w-5 h-5 text-green-300 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
        </svg>
      </RouterLink>

      <!-- Session selector -->
      <div v-if="sessions.length" class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-6">
        <p class="text-xs font-semibold text-gray-500 mb-3 text-center">📅 เลือกช่วงข้อมูล</p>
        <div class="flex flex-wrap justify-center gap-2">
          <button v-for="s in sessions" :key="s.id"
            @click="selectSession(s)"
            :class="['px-4 py-2 rounded-xl text-sm font-medium transition-all border-2',
              selectedSession?.id === s.id
                ? 'border-blue-500 bg-blue-50 text-blue-700'
                : 'border-gray-200 text-gray-600 hover:border-blue-200']">
            ปี {{ s.academic_year }} · {{ s.checkpoint_label }}
            <span class="ml-1 text-xs text-gray-400">{{ Number(s.total_rows).toLocaleString() }} คน</span>
          </button>
        </div>
      </div>

      <div v-if="loading" class="py-20 text-center text-gray-400">
        <div class="w-12 h-12 border-4 border-blue-400 border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
        <p>กำลังโหลด...</p>
      </div>

      <div v-else-if="!stats" class="py-20 text-center text-gray-400">
        <div class="text-5xl mb-3">📊</div>
        <p>ยังไม่มีข้อมูลนักเรียน</p>
      </div>

      <template v-else>

        <!-- ===== FILTER TOOLS (centered, responsive) ===== -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 mb-6">
          <p class="text-sm font-semibold text-gray-600 text-center mb-4">🔍 กรองข้อมูลนักเรียน</p>

          <!-- Education group chips -->
          <div class="flex flex-wrap justify-center gap-2 mb-4">
            <button
              @click="selectGroup('')"
              :class="['px-4 py-2 rounded-xl text-sm font-medium border-2 transition-all',
                filterGroup === ''
                  ? 'border-blue-500 bg-blue-500 text-white'
                  : 'border-gray-200 text-gray-600 hover:border-blue-300']">
              ทั้งหมด
            </button>
            <button v-for="g in eduGroups" :key="g.key"
              @click="selectGroup(g.key)"
              :class="['px-4 py-2 rounded-xl text-sm font-medium border-2 transition-all',
                filterGroup === g.key
                  ? 'border-blue-500 bg-blue-50 text-blue-700'
                  : 'border-gray-200 text-gray-600 hover:border-blue-300']">
              {{ g.label }}
              <span class="ml-1 text-xs opacity-60">({{ groupCount(g.key) }})</span>
            </button>
          </div>

          <!-- Grade + Room dropdowns -->
          <div class="flex flex-wrap justify-center gap-3">
            <select v-model="filterLevel" @change="filterRoom=''"
              class="border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 min-w-[140px]">
              <option value="">— ทุกระดับชั้น —</option>
              <option v-for="l in filteredLevels" :key="l" :value="l">{{ l }}</option>
            </select>
            <select v-model="filterRoom"
              class="border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 min-w-[120px]">
              <option value="">— ทุกห้อง —</option>
              <option v-for="r in roomsForLevel" :key="r" :value="r">ห้อง {{ r }}</option>
            </select>
            <button v-if="filterGroup || filterLevel || filterRoom"
              @click="clearFilter"
              class="px-4 py-2 rounded-xl text-sm border-2 border-red-200 text-red-500 hover:bg-red-50 transition-all">
              ✕ ล้างตัวกรอง
            </button>
          </div>
        </div>

        <!-- ===== REAL-TIME SUMMARY DASHBOARD ===== -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <p class="text-xs text-gray-400 mb-1">นักเรียนทั้งหมด</p>
            <p class="text-4xl font-black text-blue-600">{{ filteredTotals.total.toLocaleString() }}</p>
            <p class="text-xs text-gray-400 mt-1">
              <span v-if="isFiltered" class="text-blue-500">จาก {{ stats.total?.toLocaleString() }} คน</span>
              <span v-else>คน</span>
            </p>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <p class="text-xs text-gray-400 mb-1">👦 นักเรียนชาย</p>
            <p class="text-4xl font-black text-sky-500">{{ filteredTotals.male.toLocaleString() }}</p>
            <p class="text-xs text-gray-400 mt-1">
              {{ filteredTotals.total ? Math.round(filteredTotals.male/filteredTotals.total*100) : 0 }}%
            </p>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <p class="text-xs text-gray-400 mb-1">👧 นักเรียนหญิง</p>
            <p class="text-4xl font-black text-pink-500">{{ filteredTotals.female.toLocaleString() }}</p>
            <p class="text-xs text-gray-400 mt-1">
              {{ filteredTotals.total ? Math.round(filteredTotals.female/filteredTotals.total*100) : 0 }}%
            </p>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <p class="text-xs text-gray-400 mb-1">🏫 ห้องเรียน</p>
            <p class="text-4xl font-black text-purple-600">{{ filteredRoomCount }}</p>
            <p class="text-xs text-gray-400 mt-1">ห้อง</p>
          </div>
        </div>

        <!-- Level summary cards (real-time) -->
        <div v-if="!filterLevel" class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3 mb-6">
          <div v-for="[lvl, cnt] in filteredByLevel" :key="lvl"
            @click="filterLevel = lvl; filterRoom = ''"
            class="bg-white rounded-xl border border-gray-100 shadow-sm p-4 text-center cursor-pointer hover:border-blue-300 hover:bg-blue-50/30 transition-all">
            <p class="font-bold text-gray-800 text-lg">{{ lvl }}</p>
            <p class="text-2xl font-black text-blue-600 mt-1">{{ cnt.total.toLocaleString() }}</p>
            <p class="text-xs text-gray-400 mt-0.5">
              <span class="text-sky-500">{{ cnt.male }}</span> /
              <span class="text-pink-500">{{ cnt.female }}</span>
            </p>
          </div>
        </div>

        <!-- By Level/Room Table -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 class="font-bold text-gray-900">📊 จำนวนนักเรียนแยกตามชั้น-ห้อง</h3>
            <span class="text-xs text-gray-400">{{ filteredTotals.total.toLocaleString() }} คน · {{ filteredRoomCount }} ห้อง</span>
          </div>
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 text-gray-500 text-xs uppercase tracking-wide">
                <tr>
                  <th class="py-3 px-5 text-left">ชั้น-ห้อง</th>
                  <th class="py-3 px-5 text-center">👦 ชาย</th>
                  <th class="py-3 px-5 text-center">👧 หญิง</th>
                  <th class="py-3 px-5 text-center font-bold text-gray-700">รวม</th>
                  <th class="py-3 px-5 text-left hidden md:table-cell">สัดส่วน</th>
                </tr>
              </thead>
              <tbody>
                <template v-for="row in filteredTableRows" :key="row.key">
                  <tr v-if="row.isLevel" class="bg-blue-50">
                    <td class="py-2 px-5 font-bold text-blue-800" colspan="5">{{ row.label }}</td>
                  </tr>
                  <tr v-else class="border-b border-gray-50 hover:bg-gray-50/50">
                    <td class="py-2 px-5 pl-8 text-gray-700">{{ row.label }}</td>
                    <td class="py-2 px-5 text-center text-sky-600 font-medium">{{ row.male }}</td>
                    <td class="py-2 px-5 text-center text-pink-500 font-medium">{{ row.female }}</td>
                    <td class="py-2 px-5 text-center font-bold text-gray-900">{{ row.total }}</td>
                    <td class="py-2 px-5 hidden md:table-cell">
                      <div class="flex items-center gap-2">
                        <div class="w-24 bg-gray-100 rounded-full h-2 overflow-hidden">
                          <div class="h-2 bg-sky-400 rounded-l-full"
                            :style="`width:${row.total ? Math.round(row.male/row.total*100) : 0}%`"></div>
                        </div>
                        <span class="text-xs text-gray-400">
                          {{ row.total ? Math.round(row.male/row.total*100) : 0 }}% ชาย
                        </span>
                      </div>
                    </td>
                  </tr>
                </template>
                <tr class="bg-blue-600 text-white">
                  <td class="py-3 px-5 font-bold">รวมทั้งหมด</td>
                  <td class="py-3 px-5 text-center font-bold">{{ filteredTotals.male.toLocaleString() }}</td>
                  <td class="py-3 px-5 text-center font-bold">{{ filteredTotals.female.toLocaleString() }}</td>
                  <td class="py-3 px-5 text-center font-black text-lg">{{ filteredTotals.total.toLocaleString() }}</td>
                  <td class="py-3 px-5 hidden md:table-cell text-blue-200 text-xs">
                    ชาย {{ filteredTotals.total ? Math.round(filteredTotals.male/filteredTotals.total*100) : 0 }}%
                    · หญิง {{ filteredTotals.total ? Math.round(filteredTotals.female/filteredTotals.total*100) : 0 }}%
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

      </template>
    </div>
  </PublicLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import PublicLayout from '../../layouts/PublicLayout.vue'
import { useSchoolConfig } from '../../composables/useSchoolConfig'
import { supabase } from '../../lib/supabase'

const { config } = useSchoolConfig()
const loading         = ref(true)
const sessions        = ref([])
const stats           = ref(null)
const selectedSession = ref(null)

const filterGroup = ref('')
const filterLevel = ref('')
const filterRoom  = ref('')

// กลุ่มการศึกษา
const eduGroups = [
  { key: 'kinder',  label: 'อนุบาล',           levels: ['อ.1','อ.2','อ.3'] },
  { key: 'pri-lo',  label: 'ประถมต้น',          levels: ['ป.1','ป.2','ป.3'] },
  { key: 'pri-hi',  label: 'ประถมปลาย',         levels: ['ป.4','ป.5','ป.6'] },
  { key: 'sec-lo',  label: 'มัธยมศึกษาตอนต้น',  levels: ['ม.1','ม.2','ม.3'] },
  { key: 'sec-hi',  label: 'มัธยมศึกษาตอนปลาย', levels: ['ม.4','ม.5','ม.6'] },
]

function levelOrder(lvl) {
  if (!lvl) return 9999
  const n = parseInt(lvl.replace(/\D/g, '')) || 0
  if (lvl.startsWith('อ')) return n
  if (lvl.startsWith('ป')) return 100 + n
  if (lvl.startsWith('ม')) return 200 + n
  return 500 + n
}

const allLevels = computed(() =>
  Object.keys(stats.value?.byLevel || {}).sort((a, b) => levelOrder(a) - levelOrder(b))
)

// ระดับชั้นที่กรองตาม group
const filteredLevels = computed(() => {
  if (!filterGroup.value) return allLevels.value
  const g = eduGroups.find(g => g.key === filterGroup.value)
  return g ? allLevels.value.filter(l => g.levels.includes(l)) : allLevels.value
})

const isFiltered = computed(() => !!(filterGroup.value || filterLevel.value || filterRoom.value))

// นับจำนวนนักเรียนใน group
function groupCount(key) {
  const g = eduGroups.find(g => g.key === key)
  if (!g || !stats.value?.byLevel) return 0
  return g.levels.reduce((s, l) => s + (stats.value.byLevel[l] || 0), 0)
}

function selectGroup(key) {
  filterGroup.value = key
  filterLevel.value = ''
  filterRoom.value  = ''
}

function clearFilter() {
  filterGroup.value = ''
  filterLevel.value = ''
  filterRoom.value  = ''
}

const roomsForLevel = computed(() => {
  if (!filterLevel.value || !stats.value?.byRoom) return []
  return Object.keys(stats.value.byRoom)
    .filter(k => k.startsWith(filterLevel.value + '/'))
    .map(k => parseInt(k.split('/')[1]))
    .sort((a, b) => a - b)
})

// สร้าง rows ทั้งหมด
const allTableRows = computed(() => {
  if (!stats.value?.byRoom) return []
  const levelGroups = {}
  for (const [key, data] of Object.entries(stats.value.byRoom)) {
    const [level, room] = key.split('/')
    if (!levelGroups[level]) levelGroups[level] = []
    levelGroups[level].push({ room: parseInt(room), ...data, key })
  }
  const rows = []
  for (const level of Object.keys(levelGroups).sort((a, b) => levelOrder(a) - levelOrder(b))) {
    rows.push({ isLevel: true, label: level, key: 'hd-' + level, levelKey: level })
    for (const r of levelGroups[level].sort((a, b) => a.room - b.room)) {
      rows.push({
        isLevel: false, label: `ห้อง ${r.room}`,
        key: r.key, levelKey: level, roomKey: r.room,
        total: r.total, male: r.male, female: r.female,
      })
    }
  }
  return rows
})

const filteredTableRows = computed(() => {
  const groupLevels = filterGroup.value
    ? (eduGroups.find(g => g.key === filterGroup.value)?.levels || [])
    : null

  return allTableRows.value.filter(row => {
    if (row.isLevel) {
      if (groupLevels && !groupLevels.includes(row.levelKey)) return false
      if (filterLevel.value && row.levelKey !== filterLevel.value) return false
      return true
    }
    if (groupLevels && !groupLevels.includes(row.levelKey)) return false
    if (filterLevel.value && row.levelKey !== filterLevel.value) return false
    if (filterRoom.value && row.roomKey !== parseInt(filterRoom.value)) return false
    return true
  })
})

const filteredTotals = computed(() => {
  const dataRows = filteredTableRows.value.filter(r => !r.isLevel)
  return {
    total:  dataRows.reduce((s, r) => s + (r.total  || 0), 0),
    male:   dataRows.reduce((s, r) => s + (r.male   || 0), 0),
    female: dataRows.reduce((s, r) => s + (r.female || 0), 0),
  }
})

const filteredRoomCount = computed(() =>
  filteredTableRows.value.filter(r => !r.isLevel).length
)

// cards สรุปต่อชั้น (real-time ตาม group) — คืนเป็น array of [lvl, {total,male,female}]
const filteredByLevel = computed(() => {
  const groupLevels = filterGroup.value
    ? (eduGroups.find(g => g.key === filterGroup.value)?.levels || null)
    : null

  const acc = {}
  allTableRows.value
    .filter(r => !r.isLevel && (!groupLevels || groupLevels.includes(r.levelKey)))
    .forEach(r => {
      if (!acc[r.levelKey]) acc[r.levelKey] = { total: 0, male: 0, female: 0 }
      acc[r.levelKey].total  += r.total  || 0
      acc[r.levelKey].male   += r.male   || 0
      acc[r.levelKey].female += r.female || 0
    })
  return Object.entries(acc).sort((a, b) => levelOrder(a[0]) - levelOrder(b[0]))
})

async function selectSession(s) {
  selectedSession.value = s
  loading.value = true
  filterGroup.value = ''
  filterLevel.value = ''
  filterRoom.value  = ''
  const { data } = await supabase.rpc('get_checkpoint_stats', { p_session_id: s.id })
  stats.value = data || null
  loading.value = false
}

onMounted(async () => {
  const { data: sess } = await supabase.rpc('get_sis_sessions')
  sessions.value = Array.isArray(sess) ? sess : (sess || [])
  if (sessions.value.length) {
    await selectSession(sessions.value[0])
  } else {
    loading.value = false
  }
})
</script>
