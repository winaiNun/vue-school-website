<template>
  <PublicLayout>

    <!-- Hero -->
    <div class="bg-gradient-to-r from-blue-800 via-blue-700 to-indigo-700 text-white py-10 px-4">
      <div class="max-w-5xl mx-auto text-center">
        <div class="text-4xl mb-2">📋</div>
        <h1 class="text-2xl md:text-3xl font-bold">คำสั่งและประกาศโรงเรียน</h1>
        <p class="text-blue-200 mt-1 text-sm">{{ config?.name_th || 'โรงเรียน' }}</p>
      </div>
    </div>

    <div class="max-w-5xl mx-auto px-4 py-8">

      <!-- Search + Filter -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-6">
        <div class="flex flex-wrap gap-3">
          <div class="relative flex-1 min-w-[200px]">
            <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">🔍</span>
            <input v-model="search" type="text" placeholder="ค้นหา เลขที่ / เรื่อง / กลุ่มงาน..."
              class="w-full pl-8 pr-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
          </div>
          <select v-model="filterType"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
            <option value="">ทุกประเภท</option>
            <option value="order">📋 คำสั่งโรงเรียน</option>
            <option value="announcement">📢 ประกาศโรงเรียน</option>
          </select>
          <select v-model="filterDept"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
            <option value="">ทุกกลุ่มงาน</option>
            <option v-for="d in deptOptions" :key="d" :value="d">{{ d }}</option>
          </select>
          <select v-model="filterYear"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
            <option value="">ทุกปีการศึกษา</option>
            <option v-for="y in yearOptions" :key="y" :value="y">{{ y }}</option>
          </select>
          <button v-if="search || filterType || filterDept || filterYear"
            @click="clearFilters"
            class="px-3 py-2 text-sm text-gray-500 hover:text-red-500 border border-gray-200 rounded-xl hover:border-red-200 transition-colors">
            ✕ ล้าง
          </button>
        </div>
        <p class="text-xs text-gray-400 mt-2">
          แสดง <span class="font-semibold text-gray-600">{{ filtered.length.toLocaleString() }}</span> รายการ
          <span v-if="filtered.length !== docs.length"> จากทั้งหมด {{ docs.length.toLocaleString() }} รายการ</span>
        </p>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="py-20 text-center text-gray-400">
        <div class="w-10 h-10 border-4 border-blue-400 border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
        <p class="text-sm">กำลังโหลด...</p>
      </div>

      <!-- Empty -->
      <div v-else-if="!filtered.length" class="py-20 text-center text-gray-400">
        <div class="text-5xl mb-3">📄</div>
        <p class="font-medium">{{ docs.length ? 'ไม่พบเอกสารที่ตรงกับการค้นหา' : 'ยังไม่มีเอกสาร' }}</p>
      </div>

      <!-- DataTable -->
      <template v-else>
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 border-b border-gray-100">
                <tr>
                  <th @click="setSort('type')"
                    class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none whitespace-nowrap">
                    ประเภท {{ sortIcon('type') }}
                  </th>
                  <th @click="setSort('doc_number')"
                    class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none whitespace-nowrap">
                    เลขที่ {{ sortIcon('doc_number') }}
                  </th>
                  <th @click="setSort('title')"
                    class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none w-full">
                    เรื่อง {{ sortIcon('title') }}
                  </th>
                  <th @click="setSort('issued_date')"
                    class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none whitespace-nowrap hidden sm:table-cell">
                    วันที่ {{ sortIcon('issued_date') }}
                  </th>
                  <th @click="setSort('department')"
                    class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none whitespace-nowrap hidden md:table-cell">
                    กลุ่มงาน {{ sortIcon('department') }}
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                <tr v-for="doc in paginated" :key="doc.id"
                  class="hover:bg-blue-50/30 transition-colors">
                  <td class="py-3 px-4 whitespace-nowrap">
                    <span :class="['inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-semibold',
                      doc.type === 'order' ? 'bg-blue-100 text-blue-700' : 'bg-amber-100 text-amber-700']">
                      {{ doc.type === 'order' ? '📋 คำสั่ง' : '📢 ประกาศ' }}
                    </span>
                  </td>
                  <td class="py-3 px-4 font-mono font-semibold text-gray-700 whitespace-nowrap">
                    {{ doc.doc_number }}
                  </td>
                  <td class="py-3 px-4">
                    <a :href="doc.drive_url" target="_blank" rel="noopener"
                      class="font-medium leading-snug text-blue-700 hover:text-blue-900 hover:underline inline-flex items-start gap-1 group">
                      <span>{{ doc.title }}</span>
                      <svg class="w-3.5 h-3.5 mt-0.5 flex-shrink-0 text-blue-500 group-hover:text-blue-700 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                      </svg>
                    </a>
                    <!-- วันที่ แสดงเฉพาะมือถือ (sm+ มีคอลัมน์แยก) -->
                    <div class="flex flex-wrap items-center gap-1.5 mt-1 sm:hidden">
                      <span class="text-xs text-gray-400">{{ formatDate(doc.issued_date) }}</span>
                    </div>
                    <!-- กลุ่มงาน แสดงบนมือถือและ tablet (md+ มีคอลัมน์แยก) -->
                    <div class="mt-1 md:hidden">
                      <span class="text-xs bg-gray-100 text-gray-500 px-1.5 py-0.5 rounded whitespace-nowrap inline-block">
                        {{ doc.department === 'อื่นๆ' ? (doc.dept_other || 'อื่นๆ') : doc.department }}
                      </span>
                    </div>
                    <p v-if="doc.note" class="text-xs text-gray-400 mt-0.5 truncate max-w-xs">{{ doc.note }}</p>
                  </td>
                  <td class="py-3 px-4 text-gray-500 text-sm whitespace-nowrap hidden sm:table-cell">
                    {{ formatDate(doc.issued_date) }}
                  </td>
                  <td class="py-3 px-4 whitespace-nowrap hidden md:table-cell">
                    <span class="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded-lg">
                      {{ doc.department === 'อื่นๆ' ? (doc.dept_other || 'อื่นๆ') : doc.department }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Pagination -->
          <div v-if="totalPages > 1" class="flex items-center justify-between px-5 py-3 border-t border-gray-100">
            <p class="text-xs text-gray-400">หน้า {{ page }} / {{ totalPages }}</p>
            <div class="flex gap-1">
              <button @click="page = 1" :disabled="page === 1"
                class="px-2 py-1 text-xs rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50">«</button>
              <button @click="page--" :disabled="page === 1"
                class="px-3 py-1 text-xs rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50">‹</button>
              <template v-for="p in pageRange" :key="p">
                <button @click="page = p"
                  :class="['px-3 py-1 text-xs rounded-lg border transition-colors',
                    p === page ? 'bg-blue-600 text-white border-blue-600' : 'border-gray-200 hover:bg-gray-50']">
                  {{ p }}
                </button>
              </template>
              <button @click="page++" :disabled="page === totalPages"
                class="px-3 py-1 text-xs rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50">›</button>
              <button @click="page = totalPages" :disabled="page === totalPages"
                class="px-2 py-1 text-xs rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50">»</button>
            </div>
          </div>
        </div>
      </template>

    </div>
  </PublicLayout>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import PublicLayout from '../../layouts/PublicLayout.vue'
import { useSchoolConfig } from '../../composables/useSchoolConfig'
import { supabase } from '../../lib/supabase'

const { config } = useSchoolConfig()

const docs    = ref([])
const loading = ref(true)

const search     = ref('')
const filterType = ref('')
const filterDept = ref('')
const filterYear = ref('')
const sortField  = ref('issued_date')
const sortDir    = ref('desc')
const page       = ref(1)

const PER_PAGE = 20

// ── Computed ───────────────────────────────────────────────────────────────────
const deptOptions = computed(() => [...new Set(docs.value.map(d => d.department))].sort())
const yearOptions = computed(() => [...new Set(docs.value.map(d => d.academic_year))].sort((a, b) => b - a))

const filtered = computed(() => {
  let list = [...docs.value]
  const q = search.value.trim().toLowerCase()
  if (q) {
    list = list.filter(d =>
      d.doc_number.toLowerCase().includes(q) ||
      d.title.toLowerCase().includes(q) ||
      d.department.toLowerCase().includes(q) ||
      (d.dept_other || '').toLowerCase().includes(q)
    )
  }
  if (filterType.value) list = list.filter(d => d.type === filterType.value)
  if (filterDept.value) list = list.filter(d => d.department === filterDept.value)
  if (filterYear.value) list = list.filter(d => d.academic_year === filterYear.value)

  list.sort((a, b) => {
    const av = a[sortField.value] ?? ''
    const bv = b[sortField.value] ?? ''
    const cmp = av < bv ? -1 : av > bv ? 1 : 0
    return sortDir.value === 'asc' ? cmp : -cmp
  })
  return list
})

const totalPages = computed(() => Math.max(1, Math.ceil(filtered.value.length / PER_PAGE)))
const paginated  = computed(() => filtered.value.slice((page.value - 1) * PER_PAGE, page.value * PER_PAGE))
const pageRange  = computed(() => {
  const total = totalPages.value, cur = page.value
  let start = Math.max(1, cur - 2)
  let end   = Math.min(total, start + 4)
  if (end - start < 4) start = Math.max(1, end - 4)
  return Array.from({ length: end - start + 1 }, (_, i) => start + i)
})

watch([search, filterType, filterDept, filterYear], () => { page.value = 1 })

// ── Helpers ────────────────────────────────────────────────────────────────────
function formatDate(d) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('th-TH', { year: 'numeric', month: 'short', day: 'numeric' })
}

function setSort(field) {
  if (sortField.value === field) sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'
  else { sortField.value = field; sortDir.value = 'asc' }
}

function sortIcon(field) {
  if (sortField.value !== field) return '↕'
  return sortDir.value === 'asc' ? '↑' : '↓'
}

function clearFilters() {
  search.value = ''; filterType.value = ''; filterDept.value = ''; filterYear.value = ''
}

// ── Data ───────────────────────────────────────────────────────────────────────
onMounted(async () => {
  const { data } = await supabase
    .from('school_documents')
    .select('id, type, doc_number, title, issued_date, department, dept_other, academic_year, note, drive_url')
    .order('issued_date', { ascending: false })
  docs.value = data || []
  loading.value = false
})
</script>
