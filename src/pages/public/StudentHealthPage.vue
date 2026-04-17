<template>
  <PublicLayout>

    <!-- Hero -->
    <div class="bg-gradient-to-r from-green-700 via-teal-600 to-blue-700 text-white py-10 px-4">
      <div class="max-w-5xl mx-auto text-center">
        <div class="text-4xl mb-2">🏥</div>
        <h1 class="text-2xl md:text-3xl font-bold">สารสนเทศสุขภาพนักเรียน</h1>
        <p class="text-green-200 mt-1 text-sm">{{ config?.name_th || 'โรงเรียน' }}</p>
        <p v-if="latestImport" class="text-green-300 text-xs mt-1">
          ข้อมูล ณ {{ latestImport.label }} · ปีการศึกษา {{ latestImport.academic_year }}
        </p>
      </div>
    </div>

    <div class="max-w-5xl mx-auto px-4 py-8">

      <!-- Import selector -->
      <div v-if="allImports.length > 1" class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-6">
        <p class="text-xs font-semibold text-gray-500 mb-3 text-center">📅 เลือกรอบข้อมูล</p>
        <div class="flex flex-wrap justify-center gap-2">
          <button v-for="imp in allImports" :key="imp.id"
            @click="selectImport(imp)"
            :class="['px-4 py-2 rounded-xl text-sm font-medium transition-all border-2',
              selectedImport?.id === imp.id
                ? 'border-green-500 bg-green-50 text-green-700'
                : 'border-gray-200 text-gray-600 hover:border-green-300']">
            ปี {{ imp.academic_year }} · ภาคเรียน {{ imp.semester }}
            <span class="ml-1 text-xs text-gray-400">{{ Number(imp.total_count).toLocaleString() }} คน</span>
          </button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="py-20 text-center text-gray-400">
        <div class="w-12 h-12 border-4 border-green-400 border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
        <p>กำลังโหลดข้อมูลสุขภาพ...</p>
      </div>

      <!-- No data -->
      <div v-else-if="!latestImport" class="py-20 text-center text-gray-400">
        <div class="text-5xl mb-3">📊</div>
        <p>ยังไม่มีข้อมูลนักเรียน</p>
      </div>

      <template v-else>

        <!-- Grade Filter -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-6">
          <p class="text-xs font-semibold text-gray-500 mb-3 text-center">🔍 กรองตามชั้นเรียน</p>
          <div class="flex flex-wrap justify-center gap-2">
            <button @click="fGrade=''"
              :class="['px-4 py-2 rounded-xl text-sm font-medium border-2 transition-all',
                fGrade===''?'border-green-500 bg-green-500 text-white':'border-gray-200 text-gray-600 hover:border-green-300']">
              ทั้งหมด
            </button>
            <button v-for="g in gradeOpts" :key="g" @click="fGrade=g"
              :class="['px-4 py-2 rounded-xl text-sm font-medium border-2 transition-all',
                fGrade===g?'border-green-500 bg-green-50 text-green-700':'border-gray-200 text-gray-600 hover:border-green-300']">
              {{ g }}
            </button>
          </div>
        </div>

        <!-- Summary Cards -->
        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3 mb-6">
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 text-center sm:col-span-1 lg:col-span-2">
            <div class="text-3xl font-black text-gray-800">{{ bmiStats.length.toLocaleString() }}</div>
            <div class="text-xs text-gray-400 mt-1">นักเรียนที่มีข้อมูล BMI</div>
            <div class="text-[10px] text-gray-300 mt-0.5">จากทั้งหมด {{ filtered.length.toLocaleString() }} คน</div>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 text-center">
            <div class="text-3xl font-black text-blue-600">{{ bmiAvg !== null ? bmiAvg.toFixed(1) : '-' }}</div>
            <div class="text-xs text-gray-400 mt-1">BMI เฉลี่ย</div>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 text-center">
            <div class="text-3xl font-black text-indigo-600">{{ avgWeight !== null ? avgWeight.toFixed(1) : '-' }}</div>
            <div class="text-xs text-gray-400 mt-1">น้ำหนักเฉลี่ย (กก.)</div>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 text-center">
            <div class="text-3xl font-black text-teal-600">{{ avgHeight !== null ? avgHeight.toFixed(1) : '-' }}</div>
            <div class="text-xs text-gray-400 mt-1">ส่วนสูงเฉลี่ย (ซม.)</div>
          </div>
          <div class="bg-green-50 border border-green-200 rounded-2xl p-4 text-center">
            <div class="text-3xl font-black text-green-600">{{ bmiStats.length ? ((bmiCounts['สมส่วน']||0)/bmiStats.length*100).toFixed(0) : 0 }}%</div>
            <div class="text-xs text-gray-500 mt-1">สมส่วน</div>
          </div>
        </div>

        <!-- BMI Distribution + Gender -->
        <div class="grid grid-cols-1 lg:grid-cols-5 gap-5 mb-6">

          <!-- Distribution Bar Chart -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 lg:col-span-3">
            <h2 class="font-bold text-gray-800 mb-5 flex items-center gap-2">
              <span class="w-1.5 h-5 bg-green-500 rounded-full inline-block"></span>
              การกระจาย BMI
            </h2>
            <div class="space-y-4">
              <div v-for="cat in BMI_CATS" :key="cat.key">
                <div class="flex items-center justify-between mb-1.5">
                  <div class="flex items-center gap-2">
                    <div :class="['w-3 h-3 rounded-full flex-shrink-0', cat.color]"></div>
                    <span class="text-sm font-semibold text-gray-700">{{ cat.key }}</span>
                    <span class="text-xs text-gray-400">
                      <template v-if="cat.key==='ผอม'">BMI &lt; 18.5</template>
                      <template v-else-if="cat.key==='สมส่วน'">18.5–22.9</template>
                      <template v-else-if="cat.key==='น้ำหนักเกิน'">23.0–27.4</template>
                      <template v-else>≥ 27.5</template>
                    </span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="text-sm font-bold text-gray-800">{{ (bmiCounts[cat.key]||0).toLocaleString() }} คน</span>
                    <span :class="['text-xs px-2 py-0.5 rounded-full font-semibold', cat.light, cat.text]">
                      {{ bmiStats.length ? ((bmiCounts[cat.key]||0)/bmiStats.length*100).toFixed(1) : 0 }}%
                    </span>
                  </div>
                </div>
                <div class="w-full bg-gray-100 rounded-full h-6 overflow-hidden">
                  <div :class="[cat.color, 'h-full rounded-full transition-all duration-700 flex items-center justify-end pr-2']"
                    :style="{ width: bmiStats.length ? `${Math.max(2,(bmiCounts[cat.key]||0)/bmiStats.length*100)}%` : '0%' }">
                    <span v-if="bmiStats.length&&((bmiCounts[cat.key]||0)/bmiStats.length*100)>8" class="text-white text-xs font-bold">
                      {{ ((bmiCounts[cat.key]||0)/bmiStats.length*100).toFixed(1) }}%
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Gender BMI -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 lg:col-span-2">
            <h2 class="font-bold text-gray-800 mb-5 flex items-center gap-2">
              <span class="w-1.5 h-5 bg-blue-500 rounded-full inline-block"></span>
              จำแนกตามเพศ
            </h2>
            <div class="space-y-4">
              <!-- ชาย -->
              <div class="bg-blue-50 rounded-2xl p-4">
                <div class="flex items-center justify-between mb-2">
                  <span class="font-semibold text-blue-700 text-sm">👦 ชาย</span>
                  <span class="text-xs text-blue-500 font-medium">{{ bmiGender.male.length.toLocaleString() }} คน</span>
                </div>
                <div class="text-2xl font-black text-blue-700 mb-2">
                  {{ bmiGender.male.length ? (bmiGender.male.reduce((a,s)=>a+s.bmi,0)/bmiGender.male.length).toFixed(1) : '-' }}
                  <span class="text-sm font-normal text-blue-400 ml-1">BMI เฉลี่ย</span>
                </div>
                <div class="grid grid-cols-2 gap-1.5">
                  <div v-for="cat in BMI_CATS" :key="'m-'+cat.key"
                    :class="['text-center rounded-lg py-1.5', cat.light]">
                    <div :class="['text-sm font-bold', cat.text]">{{ bmiGender.male.filter(s=>bmiCategory(s.bmi)===cat.key).length }}</div>
                    <div class="text-[10px] text-gray-500">{{ cat.key }}</div>
                  </div>
                </div>
              </div>
              <!-- หญิง -->
              <div class="bg-pink-50 rounded-2xl p-4">
                <div class="flex items-center justify-between mb-2">
                  <span class="font-semibold text-pink-600 text-sm">👧 หญิง</span>
                  <span class="text-xs text-pink-400 font-medium">{{ bmiGender.female.length.toLocaleString() }} คน</span>
                </div>
                <div class="text-2xl font-black text-pink-600 mb-2">
                  {{ bmiGender.female.length ? (bmiGender.female.reduce((a,s)=>a+s.bmi,0)/bmiGender.female.length).toFixed(1) : '-' }}
                  <span class="text-sm font-normal text-pink-300 ml-1">BMI เฉลี่ย</span>
                </div>
                <div class="grid grid-cols-2 gap-1.5">
                  <div v-for="cat in BMI_CATS" :key="'f-'+cat.key"
                    :class="['text-center rounded-lg py-1.5', cat.light]">
                    <div :class="['text-sm font-bold', cat.text]">{{ bmiGender.female.filter(s=>bmiCategory(s.bmi)===cat.key).length }}</div>
                    <div class="text-[10px] text-gray-500">{{ cat.key }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- By Grade Bar Chart -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-6">
          <h2 class="font-bold text-gray-800 mb-5 flex items-center gap-2">
            <span class="w-1.5 h-5 bg-indigo-500 rounded-full inline-block"></span>
            สุขภาพแยกตามชั้นเรียน
          </h2>
          <div v-if="bmiByGrade.length === 0" class="text-center py-8 text-gray-300">ไม่มีข้อมูล</div>
          <div v-else class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead>
                <tr class="bg-gray-50 border-b border-gray-100">
                  <th class="px-4 py-3 text-left font-semibold text-gray-600">ชั้น</th>
                  <th class="px-4 py-3 text-center font-semibold text-gray-500">จำนวน</th>
                  <th class="px-4 py-3 text-center font-semibold text-blue-500">ผอม</th>
                  <th class="px-4 py-3 text-center font-semibold text-green-600">สมส่วน</th>
                  <th class="px-4 py-3 text-center font-semibold text-amber-500">น้ำหนักเกิน</th>
                  <th class="px-4 py-3 text-center font-semibold text-red-500">อ้วน</th>
                  <th class="px-4 py-3 text-center font-semibold text-teal-600">BMI เฉลี่ย</th>
                  <th class="px-4 py-3 text-left font-semibold text-gray-400">สัดส่วน</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                <tr v-for="g in bmiByGrade" :key="g.grade" class="hover:bg-gray-50 transition">
                  <td class="px-4 py-3 font-bold text-gray-800">{{ g.grade }}</td>
                  <td class="px-4 py-3 text-center text-gray-600 font-medium">{{ g.total }}</td>
                  <td class="px-4 py-3 text-center">
                    <span class="text-blue-500 font-semibold">{{ g['ผอม']||0 }}</span>
                    <span class="text-[10px] text-gray-300 ml-1">{{ g.total?((g['ผอม']||0)/g.total*100).toFixed(0):0 }}%</span>
                  </td>
                  <td class="px-4 py-3 text-center">
                    <span class="text-green-600 font-semibold">{{ g['สมส่วน']||0 }}</span>
                    <span class="text-[10px] text-gray-300 ml-1">{{ g.total?((g['สมส่วน']||0)/g.total*100).toFixed(0):0 }}%</span>
                  </td>
                  <td class="px-4 py-3 text-center">
                    <span class="text-amber-500 font-semibold">{{ g['น้ำหนักเกิน']||0 }}</span>
                    <span class="text-[10px] text-gray-300 ml-1">{{ g.total?((g['น้ำหนักเกิน']||0)/g.total*100).toFixed(0):0 }}%</span>
                  </td>
                  <td class="px-4 py-3 text-center">
                    <span class="text-red-500 font-semibold">{{ g['อ้วน']||0 }}</span>
                    <span class="text-[10px] text-gray-300 ml-1">{{ g.total?((g['อ้วน']||0)/g.total*100).toFixed(0):0 }}%</span>
                  </td>
                  <td class="px-4 py-3 text-center font-mono font-bold"
                    :class="g.total&&(g.bmiSum/g.total)<18.5?'text-blue-500':g.total&&(g.bmiSum/g.total)<23?'text-green-600':g.total&&(g.bmiSum/g.total)<27.5?'text-amber-500':'text-red-500'">
                    {{ g.total ? (g.bmiSum/g.total).toFixed(1) : '-' }}
                  </td>
                  <td class="px-4 py-3 min-w-[120px]">
                    <!-- Stacked bar -->
                    <div class="flex h-4 rounded-full overflow-hidden gap-px" v-if="g.total">
                      <div v-for="cat in BMI_CATS" :key="'stack-'+cat.key+g.grade"
                        :class="cat.color"
                        :style="{ width: `${(g[cat.key]||0)/g.total*100}%` }"
                        :title="`${cat.key}: ${g[cat.key]||0}`">
                      </div>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- BMI Reference + data source -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <div class="font-semibold text-gray-700 mb-3 text-sm">📋 เกณฑ์ BMI มาตรฐานไทย</div>
            <div class="grid grid-cols-2 gap-2">
              <div v-for="cat in BMI_CATS" :key="'ref-'+cat.key"
                :class="['rounded-xl p-3 border', cat.light, cat.border]">
                <div :class="['w-2.5 h-2.5 rounded-full mb-1.5', cat.color]"></div>
                <div :class="['text-sm font-bold', cat.text]">{{ cat.key }}</div>
                <div class="text-xs text-gray-400 mt-0.5">
                  <template v-if="cat.key==='ผอม'">BMI &lt; 18.5</template>
                  <template v-else-if="cat.key==='สมส่วน'">18.5 – 22.9</template>
                  <template v-else-if="cat.key==='น้ำหนักเกิน'">23.0 – 27.4</template>
                  <template v-else>BMI ≥ 27.5</template>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 rounded-2xl border border-gray-100 p-5 text-xs text-gray-500">
            <div class="font-semibold text-gray-600 mb-2 text-sm">ℹ️ แหล่งข้อมูล</div>
            <p class="mb-2">ข้อมูลนำมาจากระบบ DMC (Data Management Center) ของสำนักงานคณะกรรมการการศึกษาขั้นพื้นฐาน</p>
            <p class="mb-2">สูตรคำนวณ BMI = น้ำหนัก (กก.) ÷ ส่วนสูง² (ม.)</p>
            <p class="text-gray-400">แสดงเฉพาะข้อมูลรวม ไม่เปิดเผยข้อมูลส่วนบุคคล</p>
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

const loading      = ref(true)
const allImports   = ref([])
const selectedImport = ref(null)
const latestImport   = computed(() => selectedImport.value)
const snapshots    = ref([])
const fGrade       = ref('')

// ── BMI helpers ────────────────────────────────────────────────────────────────
function calcBMI(weight, height) {
  const w = parseFloat(weight), h = parseFloat(height)
  if (!w || !h || h < 50) return null
  return w / ((h / 100) ** 2)
}
function bmiCategory(bmi) {
  if (bmi === null || bmi === undefined) return null
  if (bmi < 18.5) return 'ผอม'
  if (bmi < 23)   return 'สมส่วน'
  if (bmi < 27.5) return 'น้ำหนักเกิน'
  return 'อ้วน'
}
function classifyGender(genderField, prefix) {
  const g = (genderField || '').trim()
  if (g.includes('ชาย'))  return 'ชาย'
  if (g.includes('หญิง')) return 'หญิง'
  const p = (prefix || '').trim()
  if (p === 'เด็กชาย' || p === 'นาย')                      return 'ชาย'
  if (p === 'เด็กหญิง' || p === 'นาง' || p === 'นางสาว') return 'หญิง'
  return ''
}
const BMI_CATS = [
  { key: 'ผอม',          color: 'bg-blue-400',  light: 'bg-blue-50',   text: 'text-blue-600',  border: 'border-blue-200'  },
  { key: 'สมส่วน',      color: 'bg-green-400', light: 'bg-green-50',  text: 'text-green-600', border: 'border-green-200' },
  { key: 'น้ำหนักเกิน', color: 'bg-amber-400', light: 'bg-amber-50',  text: 'text-amber-600', border: 'border-amber-200' },
  { key: 'อ้วน',        color: 'bg-red-400',   light: 'bg-red-50',    text: 'text-red-600',   border: 'border-red-200'   },
]
function numFromGrade(v) { return parseFloat(String(v).replace(/[^\d.]/g,'')) || 0 }

// ── Computed ───────────────────────────────────────────────────────────────────
const gradeOpts = computed(() => {
  const s = new Set(snapshots.value.map(s => s.grade_level).filter(Boolean))
  return [...s].sort((a,b) => numFromGrade(a)-numFromGrade(b))
})

const filtered = computed(() =>
  fGrade.value
    ? snapshots.value.filter(s => s.grade_level === fGrade.value)
    : snapshots.value
)

const bmiStats = computed(() =>
  filtered.value
    .map(s => ({ ...s, bmi: calcBMI(s.weight, s.height) }))
    .filter(s => s.bmi !== null)
)

const bmiCounts = computed(() => {
  const c = { 'ผอม': 0, 'สมส่วน': 0, 'น้ำหนักเกิน': 0, 'อ้วน': 0 }
  bmiStats.value.forEach(s => { const cat = bmiCategory(s.bmi); if (cat) c[cat]++ })
  return c
})

const bmiAvg = computed(() =>
  bmiStats.value.length ? bmiStats.value.reduce((a,s)=>a+s.bmi,0)/bmiStats.value.length : null
)
const avgWeight = computed(() => {
  const rows = filtered.value.filter(s => parseFloat(s.weight))
  return rows.length ? rows.reduce((a,s)=>a+parseFloat(s.weight),0)/rows.length : null
})
const avgHeight = computed(() => {
  const rows = filtered.value.filter(s => parseFloat(s.height))
  return rows.length ? rows.reduce((a,s)=>a+parseFloat(s.height),0)/rows.length : null
})

const bmiByGrade = computed(() => {
  const map = {}
  bmiStats.value.forEach(s => {
    const g = s.grade_level || 'ไม่ระบุ'
    if (!map[g]) map[g] = { grade:g, total:0, ผอม:0, สมส่วน:0, 'น้ำหนักเกิน':0, อ้วน:0, bmiSum:0 }
    const cat = bmiCategory(s.bmi)
    if (cat) { map[g][cat]++; map[g].total++; map[g].bmiSum += s.bmi }
  })
  return Object.values(map).sort((a,b) => numFromGrade(a.grade)-numFromGrade(b.grade))
})

const bmiGender = computed(() => ({
  male:   bmiStats.value.filter(s => classifyGender(s.gender, s.prefix) === 'ชาย'),
  female: bmiStats.value.filter(s => classifyGender(s.gender, s.prefix) === 'หญิง'),
}))

// ── Data Loading ───────────────────────────────────────────────────────────────
async function loadSnapshots(importId) {
  snapshots.value = []
  let all = [], from = 0
  while (true) {
    const { data, error } = await supabase
      .from('student_snapshots')
      .select('grade_level, gender, prefix, weight, height')
      .eq('import_id', importId)
      .range(from, from + 999)
    if (error) { console.error(error); break }
    if (!data?.length) break
    all = all.concat(data)
    if (data.length < 1000) break
    from += 1000
  }
  snapshots.value = all
}

async function selectImport(imp) {
  selectedImport.value = imp
  fGrade.value = ''
  loading.value = true
  await loadSnapshots(imp.id)
  loading.value = false
}

onMounted(async () => {
  loading.value = true
  const { data: imports } = await supabase
    .from('dmc_imports')
    .select('id, label, academic_year, semester, total_count, imported_at')
    .order('imported_at', { ascending: false })
  allImports.value = imports || []
  if (allImports.value.length) {
    selectedImport.value = allImports.value[0]
    await loadSnapshots(allImports.value[0].id)
  }
  loading.value = false
})
</script>
