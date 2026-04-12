<template>
  <PublicLayout>
    <!-- Hero -->
    <div class="bg-gradient-to-br from-blue-900 to-indigo-800 text-white py-12 px-4">
      <div class="max-w-6xl mx-auto">
        <h1 class="text-2xl md:text-3xl font-bold mb-1">📊 สารสนเทศบุคลากร</h1>
        <p class="text-blue-200 text-sm">{{ config?.name_th || 'โรงเรียน' }} · ข้อมูล ณ ปัจจุบัน</p>
      </div>
    </div>

    <div class="max-w-6xl mx-auto px-4 py-10">

      <!-- Loading -->
      <div v-if="loading" class="flex justify-center py-24 text-gray-400">
        <svg class="w-10 h-10 animate-spin text-blue-400" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
        </svg>
      </div>

      <template v-else>
        <!-- ── Summary Cards ── -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <div class="text-3xl font-bold text-blue-700">{{ total }}</div>
            <div class="text-sm text-gray-500 mt-1">บุคลากรทั้งหมด</div>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <div class="text-3xl font-bold text-indigo-600">{{ countExec }}</div>
            <div class="text-sm text-gray-500 mt-1">ผู้บริหาร</div>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <div class="text-3xl font-bold text-green-600">{{ countTeacher }}</div>
            <div class="text-sm text-gray-500 mt-1">ครู</div>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <div class="text-3xl font-bold text-amber-600">{{ countSupport }}</div>
            <div class="text-sm text-gray-500 mt-1">บุคลากรสนับสนุน</div>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

          <!-- ── ตำแหน่ง ── -->
          <StatCard title="แยกตามตำแหน่ง" icon="💼" :total="total" :rows="byPosition" color="blue" />

          <!-- ── วิทยฐานะ ── -->
          <StatCard title="แยกตามวิทยฐานะ" icon="🏅" :total="total" :rows="byStanding" color="indigo" />

          <!-- ── วุฒิการศึกษา ── -->
          <StatCard title="แยกตามวุฒิการศึกษา" icon="🎓" :total="total" :rows="byEducation" color="amber" />

          <!-- ── เพศ ── -->
          <StatCard title="แยกตามเพศ" icon="👥" :total="total" :rows="byGender" color="pink" />

          <!-- ── กลุ่มสาระ ── -->
          <div class="md:col-span-2">
            <StatCard title="แยกตามกลุ่มสาระการเรียนรู้" icon="📚" :total="total" :rows="bySubjectGroup" color="green" />
          </div>

        </div>
      </template>
    </div>
  </PublicLayout>
</template>

<script setup>
import { ref, computed, onMounted, defineComponent, h } from 'vue'
import PublicLayout from '../../layouts/PublicLayout.vue'
import { supabase } from '../../lib/supabase'
import { useSchoolConfig } from '../../composables/useSchoolConfig'

const { config } = useSchoolConfig()
const loading = ref(true)
const teachers = ref([])

// ── StatCard component (inline) ───────────────────────────────
const COLOR_MAP = {
  blue:   { bar: 'bg-blue-500',   text: 'text-blue-700',   head: 'bg-blue-50 border-blue-100' },
  indigo: { bar: 'bg-indigo-500', text: 'text-indigo-700', head: 'bg-indigo-50 border-indigo-100' },
  green:  { bar: 'bg-green-500',  text: 'text-green-700',  head: 'bg-green-50 border-green-100' },
  amber:  { bar: 'bg-amber-500',  text: 'text-amber-700',  head: 'bg-amber-50 border-amber-100' },
  pink:   { bar: 'bg-pink-500',   text: 'text-pink-700',   head: 'bg-pink-50 border-pink-100' },
}

const StatCard = defineComponent({
  props: {
    title: String, icon: String,
    total: { type: Number, default: 0 },
    rows: { type: Array, default: () => [] },
    color: { type: String, default: 'blue' },
  },
  setup(props) {
    return () => {
      const c = COLOR_MAP[props.color] || COLOR_MAP.blue
      return h('div', { class: 'bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden' }, [
        // Header
        h('div', { class: `px-5 py-3.5 border-b ${c.head} flex items-center gap-2` }, [
          h('span', { class: 'text-base' }, props.icon),
          h('h3', { class: `font-bold text-sm ${c.text}` }, props.title),
        ]),
        // Rows
        h('div', { class: 'p-4 space-y-3' },
          props.rows.length
            ? props.rows.map(row =>
                h('div', { key: row.label }, [
                  h('div', { class: 'flex justify-between text-sm mb-1' }, [
                    h('span', { class: 'text-gray-700' }, row.label),
                    h('span', { class: `font-bold ${c.text}` }, `${row.count} คน`),
                  ]),
                  h('div', { class: 'w-full bg-gray-100 rounded-full h-2' }, [
                    h('div', {
                      class: `${c.bar} h-2 rounded-full transition-all`,
                      style: `width:${props.total ? Math.round((row.count / props.total) * 100) : 0}%`,
                    }),
                  ]),
                ])
              )
            : [h('p', { class: 'text-gray-400 text-sm text-center py-4' }, 'ไม่มีข้อมูล')]
        ),
      ])
    }
  },
})

// ── Fetch ─────────────────────────────────────────────────────
onMounted(async () => {
  const { data } = await supabase
    .from('teacher_profiles')
    .select('position, academic_standing, education_level, prefix, subject_group')
  teachers.value = data || []
  loading.value = false
})

// ── Constants ─────────────────────────────────────────────────
const EXEC_POS    = ['ผู้อำนวยการโรงเรียน', 'รองผู้อำนวยการ']
const SUPPORT_POS = ['พนักงานราชการ', 'ลูกจ้างประจำ', 'ลูกจ้างชั่วคราว', 'ธุรการโรงเรียน']

// ── Summary ───────────────────────────────────────────────────
const total       = computed(() => teachers.value.length)
const countExec   = computed(() => teachers.value.filter(t => EXEC_POS.includes(t.position)).length)
const countTeacher = computed(() => teachers.value.filter(t => !EXEC_POS.includes(t.position) && !SUPPORT_POS.includes(t.position)).length)
const countSupport = computed(() => teachers.value.filter(t => SUPPORT_POS.includes(t.position)).length)

// ── Helper: นับและเรียง ────────────────────────────────────────
function countBy(field, order = []) {
  const map = {}
  for (const t of teachers.value) {
    const key = t[field] || 'ไม่ระบุ'
    map[key] = (map[key] || 0) + 1
  }
  const entries = Object.entries(map).map(([label, count]) => ({ label, count }))
  if (order.length) {
    const ordered = order.filter(k => map[k]).map(k => ({ label: k, count: map[k] }))
    const rest = entries.filter(e => !order.includes(e.label)).sort((a, b) => b.count - a.count)
    return [...ordered, ...rest]
  }
  return entries.sort((a, b) => b.count - a.count)
}

// ── Computed rows ─────────────────────────────────────────────
const byPosition = computed(() => countBy('position', [
  'ผู้อำนวยการโรงเรียน', 'รองผู้อำนวยการ', 'ครู', 'ครูผู้ช่วย',
  'พนักงานราชการ', 'ลูกจ้างประจำ', 'ลูกจ้างชั่วคราว', 'ธุรการโรงเรียน',
]))

const byStanding = computed(() => countBy('academic_standing', [
  'ผู้อำนวยการเชี่ยวชาญ', 'ผู้อำนวยการชำนาญการพิเศษ',
  'รองผู้อำนวยการเชี่ยวชาญ', 'รองผู้อำนวยการชำนาญการพิเศษ',
  'ครูเชี่ยวชาญพิเศษ', 'ครูเชี่ยวชาญ', 'ครูชำนาญการพิเศษ', 'ครูชำนาญการ', 'ไม่ระบุ',
]))

const byEducation = computed(() => countBy('education_level', [
  'ปริญญาเอก', 'ปริญญาโท', 'ปริญญาตรี', 'ต่ำกว่าปริญญาตรี', 'ไม่ระบุ',
]))

const byGender = computed(() => {
  const map = { 'ชาย': 0, 'หญิง': 0, 'ไม่ระบุ': 0 }
  for (const t of teachers.value) {
    if (t.prefix === 'นาย' || t.prefix === 'ว่าที่ร้อยตรี' || t.prefix === 'เด็กชาย') map['ชาย']++
    else if (t.prefix === 'นาง' || t.prefix === 'นางสาว' || t.prefix === 'ว่าที่ร้อยตรีหญิง' || t.prefix === 'เด็กหญิง') map['หญิง']++
    else map['ไม่ระบุ']++
  }
  return Object.entries(map).filter(([, v]) => v > 0).map(([label, count]) => ({ label, count }))
})

const bySubjectGroup = computed(() => {
  const SUBJECT_ORDER = [
    'ภาษาไทย', 'คณิตศาสตร์', 'วิทยาศาสตร์และเทคโนโลยี', 'สังคมศึกษาฯ',
    'ภาษาต่างประเทศ', 'สุขศึกษาและพลศึกษา', 'ศิลปะ', 'การงานอาชีพ', 'กิจกรรมพัฒนาผู้เรียน',
  ]
  return countBy('subject_group', SUBJECT_ORDER).filter(r => r.label !== 'ไม่ระบุ')
})
</script>
