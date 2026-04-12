<template>
  <PublicLayout>
    <!-- Hero -->
    <div class="bg-gradient-to-r from-blue-800 to-blue-600 text-white py-10 px-4">
      <div class="max-w-6xl mx-auto flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 class="text-2xl md:text-3xl font-bold">👨‍🏫 คณะครูและบุคลากร</h1>
          <p class="text-blue-200 mt-1 text-sm">{{ config?.name_th || 'โรงเรียน' }}</p>
        </div>
        <RouterLink to="/personnel/stats"
          class="flex items-center gap-2 bg-white/15 hover:bg-white/25 border border-white/30 text-white text-sm font-medium px-4 py-2 rounded-xl transition-colors">
          📊 สารสนเทศบุคลากร
        </RouterLink>
      </div>
    </div>

    <div class="max-w-6xl mx-auto px-4 py-8">

      <!-- Loading -->
      <div v-if="loading" class="flex flex-col items-center py-20 text-gray-400">
        <svg class="w-10 h-10 animate-spin text-blue-400 mb-3" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
        </svg>
        <p>กำลังโหลดข้อมูล...</p>
      </div>

      <!-- Error -->
      <div v-else-if="fetchError" class="text-center py-16 text-red-400">
        <div class="text-4xl mb-2">⚠️</div>
        <p class="font-medium">โหลดข้อมูลไม่สำเร็จ</p>
        <p class="text-xs mt-1 text-gray-400">{{ fetchError }}</p>
      </div>

      <div v-else>
        <!-- Empty -->
        <div v-if="!allTeachers.length" class="text-center py-20 text-gray-400">
          <div class="text-5xl mb-3">👨‍🏫</div>
          <p class="font-medium">ยังไม่มีข้อมูลบุคลากร</p>
        </div>

        <!-- ── Tab Bar ── -->
        <div v-else class="mb-8">
          <div class="flex flex-wrap gap-2 border-b border-gray-200 pb-0">
            <button v-for="tab in tabs" :key="tab.key" @click="activeTab = tab.key"
              :class="['px-4 py-2.5 text-sm font-medium rounded-t-xl transition-all border-b-2 -mb-px',
                activeTab === tab.key
                  ? 'border-blue-600 text-blue-700 bg-blue-50'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:bg-gray-50']">
              {{ tab.icon }} {{ tab.label }}
              <span class="ml-1.5 text-xs px-1.5 py-0.5 rounded-full"
                :class="activeTab === tab.key ? 'bg-blue-100 text-blue-600' : 'bg-gray-100 text-gray-400'">
                {{ tab.count }}
              </span>
            </button>
          </div>
        </div>

        <!-- ───── ผู้บริหาร ───── -->
        <section v-if="activeTab === 'executives' && executives" class="mb-10">
          <div class="flex items-center gap-3 mb-4">
            <div class="w-8 h-8 flex items-center justify-center bg-blue-100 rounded-full text-lg">🏫</div>
            <h2 class="text-lg font-bold text-gray-800">ผู้บริหารโรงเรียน</h2>
            <div class="flex-1 h-px bg-gray-200"></div>
          </div>
          <div v-if="director" class="flex justify-center mb-5">
            <PersonCard :teacher="director" :width="180" :height="216" />
          </div>
          <div v-if="viceDirectors.length" class="flex flex-wrap justify-center gap-4">
            <PersonCard v-for="t in viceDirectors" :key="t.id" :teacher="t" :width="160" :height="192" />
          </div>
        </section>

        <!-- ───── กลุ่มบริหาร ───── -->
        <template v-if="activeTab === 'departments' && adminDeptGroups.length">
          <section v-for="dept in adminDeptGroups" :key="dept.name" class="mb-10">
            <div class="flex items-center gap-3 mb-4">
              <div class="w-8 h-8 flex items-center justify-center bg-indigo-100 rounded-full text-lg">🏢</div>
              <h2 class="text-lg font-bold text-gray-800">{{ dept.name }}</h2>
              <div class="flex-1 h-px bg-gray-200"></div>
            </div>
            <!-- แถวที่ 1: ผอ. คนเดียวกลาง -->
            <div v-if="dept.director" class="flex justify-center mb-4">
              <PersonCard :teacher="dept.director" :width="168" :height="200" role-label="ผู้อำนวยการโรงเรียน" role-color="text-blue-600" />
            </div>
            <!-- แถวที่ 2: รอง ผอ. + หัวหน้ากลุ่ม -->
            <div v-if="dept.row2.length" class="flex flex-wrap justify-center gap-4 mb-4">
              <PersonCard v-for="t in dept.row2" :key="t.id + '_' + dept.name" :teacher="t" :width="160" :height="192"
                :role-label="deptRoleLabel(t, dept.name)" role-color="text-indigo-600" />
            </div>
            <!-- แถวต่อไป: สมาชิก -->
            <div v-if="dept.members.length" class="flex flex-wrap justify-center gap-3">
              <PersonCard v-for="t in dept.members" :key="t.id + '_m_' + dept.name" :teacher="t" :width="152" :height="180"
                :role-label="deptRoleLabel(t, dept.name)" role-color="text-gray-500" />
            </div>
          </section>
        </template>

        <!-- ───── กลุ่มสาระ ───── -->
        <template v-if="activeTab === 'subjects'">
          <!-- Search + filter -->
          <div class="flex flex-col sm:flex-row gap-3 mb-6">
            <div class="relative flex-1">
              <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
              <input v-model="subjectSearch" type="text" placeholder="ค้นหาชื่อครู..."
                class="w-full pl-9 pr-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white" />
            </div>
            <div class="flex flex-wrap gap-2">
              <button @click="subjectFilter = ''"
                :class="['px-3 py-2 rounded-xl text-xs font-medium border transition-all',
                  subjectFilter === '' ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-600 border-gray-200 hover:border-blue-300']">
                ทั้งหมด
              </button>
              <button v-for="g in availableSubjectGroups" :key="g" @click="subjectFilter = g"
                :class="['px-3 py-2 rounded-xl text-xs font-medium border transition-all',
                  subjectFilter === g ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-600 border-gray-200 hover:border-blue-300']">
                {{ groupIcon(g) }} {{ g }}
              </button>
            </div>
          </div>
          <!-- ไม่พบ -->
          <div v-if="filteredSubjectGroups.length === 0 && subjectSearch" class="text-center py-16 text-gray-400">
            <div class="text-4xl mb-2">🔍</div>
            <p>ไม่พบครูชื่อ "{{ subjectSearch }}"</p>
          </div>
        </template>
        <section v-if="activeTab === 'subjects'" v-for="group in filteredSubjectGroups" :key="group.name" class="mb-10">
          <div class="flex items-center gap-3 mb-4">
            <div class="w-8 h-8 flex items-center justify-center bg-blue-100 rounded-full text-lg">{{ groupIcon(group.name) }}</div>
            <h2 class="text-lg font-bold text-gray-800">{{ group.name }}</h2>
            <div class="flex-1 h-px bg-gray-200"></div>
          </div>
          <div v-if="group.head" class="flex justify-center mb-4">
            <PersonCard :teacher="group.head" :width="168" :height="200" role-label="⭐ หัวหน้ากลุ่มสาระ" role-color="text-indigo-600" />
          </div>
          <div v-if="group.members.length" class="flex flex-wrap justify-center gap-3">
            <PersonCard v-for="t in group.members" :key="t.id" :teacher="t" :width="152" :height="180"
              :role-label="t.group_role === 'รองหัวหน้ากลุ่มสาระ' ? '★ รองหัวหน้ากลุ่มสาระ' : ''"
              role-color="text-indigo-500" />
          </div>
        </section>

        <!-- ───── บุคลากรสนับสนุน ───── -->
        <section v-if="activeTab === 'support' && otherStaff.length" class="mb-10">
          <div class="flex items-center gap-3 mb-4">
            <div class="w-8 h-8 flex items-center justify-center bg-blue-100 rounded-full text-lg">👷</div>
            <h2 class="text-lg font-bold text-gray-800">บุคลากรสนับสนุน</h2>
            <div class="flex-1 h-px bg-gray-200"></div>
          </div>
          <div class="flex flex-wrap justify-center gap-3">
            <PersonCard v-for="t in otherStaff" :key="t.id" :teacher="t" :width="152" :height="180" bg-class="from-gray-50 to-gray-100" />
          </div>
        </section>
      </div>
    </div>
  </PublicLayout>
</template>

<script setup>
import { ref, computed, onMounted, defineComponent, h } from 'vue'
import PublicLayout from '../../layouts/PublicLayout.vue'
import { supabase } from '../../lib/supabase'
import { useSchoolConfig } from '../../composables/useSchoolConfig'

const { config } = useSchoolConfig()

// ── PersonCard component (inline) ────────────────────────────
const PersonCard = defineComponent({
  props: {
    teacher: Object,
    width: { type: Number, default: 152 },
    height: { type: Number, default: 180 },
    roleLabel: { type: String, default: '' },
    roleColor: { type: String, default: 'text-indigo-600' },
    bgClass: { type: String, default: 'from-blue-50 to-indigo-100' },
  },
  setup(props) {
    return () => {
      const t = props.teacher
      const hasPhoto = !!t?.profile_image_url
      return h('div', {
        class: 'bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow',
        style: `width:${props.width}px`,
      }, [
        h('div', {
          class: `relative bg-gradient-to-br ${props.bgClass} flex flex-col items-center justify-center overflow-hidden`,
          style: `height:${props.height}px`,
        }, [
          ...(hasPhoto
            ? [h('img', { src: t.profile_image_url, class: 'w-full h-full object-cover object-top', loading: 'lazy' })]
            : [
                h('svg', { viewBox: '0 0 80 100', class: 'w-16 opacity-25', fill: 'currentColor' }, [
                  h('ellipse', { cx: 40, cy: 28, rx: 20, ry: 24, fill: '#6b7280' }),
                  h('path', { d: 'M5,100 Q5,60 40,60 Q75,60 75,100 Z', fill: '#6b7280' }),
                ]),
                h('p', { class: 'text-gray-400 text-center mt-1', style: 'font-size:10px;line-height:1.3;max-width:90%' }, 'ยังไม่มีภาพถ่าย'),
              ]
          ),
          // Overlay ลิงค์ผลงาน
          t?.website_url
            ? h('a', {
                href: t.website_url, target: '_blank', rel: 'noopener noreferrer',
                class: 'absolute bottom-0 left-0 right-0 bg-blue-600/90 hover:bg-blue-700 text-white text-center py-1.5 transition-colors',
                style: 'font-size:10px;font-weight:600;letter-spacing:0.02em',
                onClick: (e) => e.stopPropagation(),
              }, '🌐 เยี่ยมชมผลงาน')
            : null,
        ]),
        h('div', { class: 'px-2 py-2.5 text-center' }, [
          h('p', { class: 'font-semibold text-gray-900', style: 'font-size:12px;line-height:1.35;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden' },
            `${t?.prefix || ''}${t?.first_name || ''} ${t?.last_name || ''}`),
          h('p', { class: 'text-blue-600 font-medium mt-0.5', style: 'font-size:11px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis' },
            t?.academic_standing || t?.position || 'ครู'),
          props.roleLabel
            ? h('p', { class: `font-semibold mt-0.5 ${props.roleColor}`, style: 'font-size:11px' }, props.roleLabel)
            : null,
        ]),
      ])
    }
  },
})

// ── Constants ─────────────────────────────────────────────────
const SUBJECT_GROUP_ORDER = [
  'ภาษาไทย','คณิตศาสตร์','วิทยาศาสตร์และเทคโนโลยี','สังคมศึกษาฯ',
  'ภาษาต่างประเทศ','สุขศึกษาและพลศึกษา','ศิลปะ','การงานอาชีพ','กิจกรรมพัฒนาผู้เรียน',
]
const STANDING_ORDER = {
  'ผู้อำนวยการเชี่ยวชาญ': 0, 'ผู้อำนวยการชำนาญการพิเศษ': 1,
  'รองผู้อำนวยการเชี่ยวชาญ': 2, 'รองผู้อำนวยการชำนาญการพิเศษ': 3,
  'ครูเชี่ยวชาญพิเศษ': 4, 'ครูเชี่ยวชาญ': 5,
  'ครูชำนาญการพิเศษ': 6, 'ครูชำนาญการ': 7, '': 8,
}
const STANDING_LABEL = { 'ครูเชี่ยวชาญพิเศษ': 'คศ.4', 'ครูเชี่ยวชาญ': 'คศ.3', 'ครูชำนาญการพิเศษ': 'คศ.2', 'ครูชำนาญการ': 'คศ.1' }
const GROUP_ROLE_ORDER = { 'หัวหน้ากลุ่มสาระ': 0, 'รองหัวหน้ากลุ่มสาระ': 1, '': 2 }
const EXEC_POSITIONS    = ['ผู้อำนวยการโรงเรียน', 'รองผู้อำนวยการ']
const SUPPORT_POSITIONS = ['พนักงานราชการ', 'ลูกจ้างประจำ', 'ลูกจ้างชั่วคราว', 'ธุรการโรงเรียน']
const GROUP_ICONS = {
  'ภาษาไทย': '📚', 'คณิตศาสตร์': '🔢', 'วิทยาศาสตร์และเทคโนโลยี': '🔬',
  'สังคมศึกษาฯ': '🌍', 'ภาษาต่างประเทศ': '🌐', 'สุขศึกษาและพลศึกษา': '⚽',
  'ศิลปะ': '🎨', 'การงานอาชีพ': '🔧', 'กิจกรรมพัฒนาผู้เรียน': '🌱',
}

// ── State ─────────────────────────────────────────────────────
const allTeachers   = ref([])
const deptMap       = ref({})   // { teacher_id: [{department_name, department_role}] }
const loading       = ref(true)
const fetchError    = ref('')

// ── Tab state ─────────────────────────────────────────────────
const activeTab    = ref('executives')
const subjectSearch = ref('')
const subjectFilter = ref('')

const DEFAULT_DEPTS = ['กลุ่มบริหารวิชาการ','กลุ่มบริหารงบประมาณ','กลุ่มบริหารงานบุคคล','กลุ่มบริหารทั่วไป']
const adminDeptList = computed(() =>
  Array.isArray(config.value?.admin_departments) && config.value.admin_departments.length
    ? config.value.admin_departments : DEFAULT_DEPTS
)

// ── Fetch ─────────────────────────────────────────────────────
onMounted(async () => {
  try {
    const [{ data: teachers, error }, { data: depts }] = await Promise.all([
      supabase.from('teacher_profiles').select('*').order('first_name'),
      supabase.from('teacher_department_assignments').select('teacher_id, department_name, department_role'),
    ])
    if (error) throw error
    allTeachers.value = teachers || []
    // สร้าง map: teacher_id → assignments[]
    const m = {}
    for (const d of (depts || [])) {
      if (!m[d.teacher_id]) m[d.teacher_id] = []
      m[d.teacher_id].push(d)
    }
    deptMap.value = m
  } catch (e) {
    fetchError.value = e.message
  } finally {
    loading.value = false
  }
})

// ── Helpers ───────────────────────────────────────────────────
function standingLabel(t) {
  return STANDING_LABEL[t.academic_standing] || ''
}
// มีวิทยฐานะ → แสดงวิทยฐานะอย่างเดียว | ไม่มี → แสดงตำแหน่ง
function positionLine(t) {
  return t.academic_standing || t.position || 'ครู'
}
function groupIcon(name) {
  return GROUP_ICONS[name] || '📖'
}
function sortTeachers(list) {
  return [...list].sort((a, b) => {
    const rA = GROUP_ROLE_ORDER[a.group_role ?? ''] ?? 2
    const rB = GROUP_ROLE_ORDER[b.group_role ?? ''] ?? 2
    if (rA !== rB) return rA - rB
    const sA = STANDING_ORDER[a.academic_standing ?? ''] ?? 4
    const sB = STANDING_ORDER[b.academic_standing ?? ''] ?? 4
    if (sA !== sB) return sA - sB
    return (a.first_name ?? '').localeCompare(b.first_name ?? '', 'th')
  })
}

// ── Helpers เพิ่มเติม ─────────────────────────────────────────
function getDeptRole(t, deptName) {
  return (deptMap.value[t.id] || []).find(d => d.department_name === deptName)?.department_role || ''
}
function deptRoleLabel(t, deptName) {
  const role = getDeptRole(t, deptName)
  if (role === 'ผู้อำนวยการโรงเรียน')   return '🏫 ผู้อำนวยการโรงเรียน'
  if (role === 'รองผู้อำนวยการโรงเรียน') return '🏫 รองผู้อำนวยการโรงเรียน'
  if (role === 'หัวหน้ากลุ่ม')           return '⭐ หัวหน้ากลุ่ม'
  if (role === 'รองหัวหน้ากลุ่ม')        return '★ รองหัวหน้ากลุ่ม'
  if (role === 'เลขานุการ')              return '📝 เลขานุการ'
  return ''
}

const DEPT_ROLE_ORDER = { 'หัวหน้ากลุ่ม': 0, 'รองหัวหน้ากลุ่ม': 1, 'เลขานุการ': 2, 'กรรมการ': 3 }

function sortByStanding(list) {
  return [...list].sort((a, b) => {
    const sA = STANDING_ORDER[a.academic_standing ?? ''] ?? 4
    const sB = STANDING_ORDER[b.academic_standing ?? ''] ?? 4
    if (sA !== sB) return sA - sB
    return (a.first_name ?? '').localeCompare(b.first_name ?? '', 'th')
  })
}

// ── Computed ──────────────────────────────────────────────────
// ผู้อำนวยการ (คนเดียว)
const director = computed(() =>
  allTeachers.value.find(t => t.position === 'ผู้อำนวยการโรงเรียน') || null
)

// รอง ผอ. และผู้บริหารอื่น (ไม่รวม ผอ.)
const viceDirectors = computed(() =>
  allTeachers.value
    .filter(t => t.position === 'รองผู้อำนวยการ')
    .sort((a, b) => (a.first_name ?? '').localeCompare(b.first_name ?? '', 'th'))
)

// executives รวม (ใช้ตรวจสอบว่ามีหรือไม่)
const executives = computed(() => director.value || viceDirectors.value.length)

const subjectGroupsData = computed(() => {
  const teachers = allTeachers.value.filter(
    t => t.subject_group && !EXEC_POSITIONS.includes(t.position) && !SUPPORT_POSITIONS.includes(t.position)
  )
  const map = {}
  for (const t of teachers) {
    if (!map[t.subject_group]) map[t.subject_group] = []
    map[t.subject_group].push(t)
  }
  const result = []
  const buildGroup = (name, list) => {
    const sorted = sortTeachers(list)
    // แยก หัวหน้ากลุ่ม ออก (คนแรกที่เป็นหัวหน้า)
    const headIdx = sorted.findIndex(t => t.group_role === 'หัวหน้ากลุ่มสาระ')
    const head    = headIdx >= 0 ? sorted[headIdx] : null
    const members = sorted.filter((_, i) => i !== headIdx)
    return { name, head, members }
  }
  for (const g of SUBJECT_GROUP_ORDER) {
    if (map[g]) result.push(buildGroup(g, map[g]))
  }
  for (const g of Object.keys(map)) {
    if (!SUBJECT_GROUP_ORDER.includes(g)) result.push(buildGroup(g, map[g]))
  }
  return result
})

const otherStaff = computed(() =>
  sortTeachers(
    allTeachers.value.filter(
      t => SUPPORT_POSITIONS.includes(t.position) ||
           (!t.subject_group && !EXEC_POSITIONS.includes(t.position))
    )
  )
)

// กลุ่มสาระกรองตาม search + filter
const availableSubjectGroups = computed(() => subjectGroupsData.value.map(g => g.name))

const filteredSubjectGroups = computed(() => {
  const q = subjectSearch.value.toLowerCase().trim()
  return subjectGroupsData.value
    .filter(g => !subjectFilter.value || g.name === subjectFilter.value)
    .map(g => {
      if (!q) return g
      const filterMember = t => {
        const name = `${t.prefix || ''}${t.first_name || ''} ${t.last_name || ''}`.toLowerCase()
        return name.includes(q)
      }
      const head    = g.head    && filterMember(g.head)    ? g.head    : null
      const members = g.members.filter(filterMember)
      return { ...g, head, members }
    })
    .filter(g => g.head || g.members.length)
})

// Tab definitions
const tabs = computed(() => [
  { key: 'executives',  icon: '🏫', label: 'ผู้บริหาร',         count: (director.value ? 1 : 0) + viceDirectors.value.length },
  { key: 'departments', icon: '🏢', label: 'กลุ่มบริหาร',       count: adminDeptGroups.value.length },
  { key: 'subjects',    icon: '📚', label: 'กลุ่มสาระ',          count: subjectGroupsData.value.length },
  { key: 'support',     icon: '👷', label: 'บุคลากรสนับสนุน',    count: otherStaff.value.length },
].filter(t => t.count > 0)
)

// กลุ่มบริหาร — แต่ละกลุ่มมี director / row2 / members
const adminDeptGroups = computed(() => {
  return adminDeptList.value.map(deptName => {
    // หาครูที่อยู่ในกลุ่มนี้
    const members = allTeachers.value.filter(t =>
      (deptMap.value[t.id] || []).some(d => d.department_name === deptName)
    )
    if (!members.length) return null

    // แถวที่ 1: department_role === 'ผู้อำนวยการโรงเรียน'
    const directorInDept = members.find(t => getDeptRole(t, deptName) === 'ผู้อำนวยการโรงเรียน') || null

    // แถวที่ 2: รอง ผอ. (ตาม role) + หัวหน้ากลุ่ม — ไม่รวม ผอ.
    const row2 = members.filter(t => {
      if (getDeptRole(t, deptName) === 'ผู้อำนวยการโรงเรียน') return false
      const role = getDeptRole(t, deptName)
      return role === 'รองผู้อำนวยการโรงเรียน' || role === 'หัวหน้ากลุ่ม'
    }).sort((a, b) => {
      // รอง ผอ. ก่อน หัวหน้ากลุ่ม
      const order = { 'รองผู้อำนวยการโรงเรียน': 0, 'หัวหน้ากลุ่ม': 1 }
      return (order[getDeptRole(a, deptName)] ?? 2) - (order[getDeptRole(b, deptName)] ?? 2)
    })

    // สมาชิกที่เหลือ เรียงตามวิทยฐานะ
    const row2Ids = new Set([directorInDept?.id, ...row2.map(t => t.id)].filter(Boolean))
    const rest = sortByStanding(members.filter(t => !row2Ids.has(t.id)))

    return { name: deptName, director: directorInDept, row2, members: rest }
  }).filter(Boolean)
})
</script>
