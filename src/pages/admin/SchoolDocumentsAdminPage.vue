<template>
  <AdminLayout>
    <div class="space-y-5">

      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 class="text-xl font-bold text-gray-900">📋 คำสั่งและประกาศโรงเรียน</h2>
          <p class="text-xs text-gray-400 mt-0.5">จัดการคำสั่งโรงเรียน และประกาศโรงเรียน</p>
        </div>
        <button @click="openForm()"
          class="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-xl text-sm font-medium shadow-sm transition-colors self-start sm:self-auto">
          <span class="text-lg leading-none">+</span> เพิ่มเอกสาร
        </button>
      </div>

      <!-- Search + Filter Bar -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4">
        <div class="flex flex-wrap gap-3">
          <!-- Search -->
          <div class="relative flex-1 min-w-[200px]">
            <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">🔍</span>
            <input v-model="search" type="text" placeholder="ค้นหา เลขที่ / เรื่อง / กลุ่มงาน..."
              class="w-full pl-8 pr-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
          </div>
          <!-- Type -->
          <select v-model="filterType"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 min-w-[150px]">
            <option value="">ทุกประเภท</option>
            <option value="order">📋 คำสั่งโรงเรียน</option>
            <option value="announcement">📢 ประกาศโรงเรียน</option>
          </select>
          <!-- Department -->
          <select v-model="filterDept"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 min-w-[180px]">
            <option value="">ทุกกลุ่มงาน</option>
            <option v-for="d in DEPARTMENTS" :key="d" :value="d">{{ d }}</option>
          </select>
          <!-- Year -->
          <select v-model="filterYear"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 min-w-[130px]">
            <option value="">ทุกปีการศึกษา</option>
            <option v-for="y in yearOptions" :key="y" :value="y">{{ y }}</option>
          </select>
          <!-- Clear -->
          <button v-if="search || filterType || filterDept || filterYear"
            @click="clearFilters"
            class="px-3 py-2 text-sm text-gray-500 hover:text-red-500 border border-gray-200 rounded-xl hover:border-red-200 transition-colors">
            ✕ ล้าง
          </button>
        </div>
        <p class="text-xs text-gray-400 mt-2">
          แสดง {{ filtered.length.toLocaleString() }} / {{ docs.length.toLocaleString() }} รายการ
        </p>
      </div>

      <!-- DataTable -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div v-if="loading" class="py-16 text-center text-gray-400">
          <div class="w-8 h-8 border-4 border-blue-400 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
          <p class="text-sm">กำลังโหลด...</p>
        </div>
        <div v-else-if="!filtered.length" class="py-16 text-center text-gray-400">
          <div class="text-4xl mb-2">📄</div>
          <p class="text-sm">{{ docs.length ? 'ไม่พบเอกสารที่ตรงกับการค้นหา' : 'ยังไม่มีเอกสาร' }}</p>
        </div>
        <template v-else>
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 border-b border-gray-100">
                <tr>
                  <th @click="setSort('type')" class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none whitespace-nowrap">
                    ประเภท {{ sortIcon('type') }}
                  </th>
                  <th @click="setSort('doc_number')" class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none whitespace-nowrap">
                    เลขที่ {{ sortIcon('doc_number') }}
                  </th>
                  <th @click="setSort('title')" class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none">
                    เรื่อง {{ sortIcon('title') }}
                  </th>
                  <th @click="setSort('issued_date')" class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none whitespace-nowrap hidden sm:table-cell">
                    วันที่ {{ sortIcon('issued_date') }}
                  </th>
                  <th @click="setSort('department')" class="py-3 px-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer hover:text-blue-600 select-none hidden md:table-cell">
                    กลุ่มงาน {{ sortIcon('department') }}
                  </th>
                  <th class="py-3 px-4 text-center text-xs font-semibold text-gray-500 uppercase tracking-wide whitespace-nowrap">
                    จัดการ
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                <tr v-for="doc in paginated" :key="doc.id"
                  class="hover:bg-gray-50/60 transition-colors">
                  <td class="py-3 px-4 whitespace-nowrap">
                    <span :class="['inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-semibold',
                      doc.type === 'order' ? 'bg-blue-100 text-blue-700' : 'bg-amber-100 text-amber-700']">
                      {{ doc.type === 'order' ? '📋 คำสั่ง' : '📢 ประกาศ' }}
                    </span>
                  </td>
                  <td class="py-3 px-4 font-mono font-semibold text-gray-700 whitespace-nowrap">
                    {{ doc.doc_number }}
                  </td>
                  <td class="py-3 px-4 text-gray-800 max-w-xs">
                    <p class="truncate">{{ doc.title }}</p>
                    <p class="text-xs text-gray-400 mt-0.5 sm:hidden">{{ formatDate(doc.issued_date) }}</p>
                  </td>
                  <td class="py-3 px-4 text-gray-500 whitespace-nowrap hidden sm:table-cell">
                    {{ formatDate(doc.issued_date) }}
                  </td>
                  <td class="py-3 px-4 hidden md:table-cell">
                    <span class="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded-lg">
                      {{ doc.department === 'อื่นๆ' ? (doc.dept_other || 'อื่นๆ') : doc.department }}
                    </span>
                  </td>
                  <td class="py-3 px-4">
                    <div class="flex items-center justify-center gap-1">
                      <a :href="doc.drive_url" target="_blank" rel="noopener"
                        class="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors" title="เปิดเอกสาร">
                        🔗
                      </a>
                      <button @click="openForm(doc)"
                        class="p-1.5 rounded-lg text-gray-400 hover:text-amber-600 hover:bg-amber-50 transition-colors" title="แก้ไข">
                        ✏️
                      </button>
                      <button @click="confirmDelete(doc)"
                        class="p-1.5 rounded-lg text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors" title="ลบ">
                        🗑️
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Pagination -->
          <div v-if="totalPages > 1" class="flex items-center justify-between px-5 py-3 border-t border-gray-100">
            <p class="text-xs text-gray-400">
              หน้า {{ page }} / {{ totalPages }} · {{ filtered.length }} รายการ
            </p>
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
        </template>
      </div>

    </div>

    <!-- ===== FORM MODAL ===== -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="showForm" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
          @click.self="showForm = false">
          <div class="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] flex flex-col">

            <div class="px-6 py-4 border-b flex items-center justify-between">
              <h3 class="font-bold text-gray-900">
                {{ editTarget ? '✏️ แก้ไขเอกสาร' : '➕ เพิ่มเอกสารใหม่' }}
              </h3>
              <button @click="showForm = false"
                class="w-8 h-8 flex items-center justify-center rounded-full hover:bg-gray-100 text-gray-400">✕</button>
            </div>

            <div class="flex-1 overflow-y-auto px-6 py-5 space-y-4">

              <!-- ประเภท -->
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-2">ประเภทเอกสาร <span class="text-red-500">*</span></label>
                <div class="grid grid-cols-2 gap-2">
                  <button v-for="t in DOC_TYPES" :key="t.value" @click="form.type = t.value"
                    :class="['flex items-center gap-2 px-4 py-3 rounded-xl border-2 text-sm font-medium transition-all',
                      form.type === t.value ? 'border-blue-500 bg-blue-50 text-blue-700' : 'border-gray-200 text-gray-600 hover:border-gray-300']">
                    <span class="text-xl">{{ t.icon }}</span>
                    <span>{{ t.label }}</span>
                  </button>
                </div>
              </div>

              <!-- เลขที่ + ปีการศึกษา -->
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-xs font-semibold text-gray-600 mb-1">เลขที่ <span class="text-red-500">*</span></label>
                  <input v-model="form.doc_number" type="text" placeholder="เช่น 25/2568"
                    class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
                </div>
                <div>
                  <label class="block text-xs font-semibold text-gray-600 mb-1">ปีการศึกษา <span class="text-red-500">*</span></label>
                  <input v-model.number="form.academic_year" type="number" min="2560" max="2580"
                    class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
                </div>
              </div>

              <!-- เรื่อง -->
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">เรื่อง <span class="text-red-500">*</span></label>
                <input v-model="form.title" type="text" placeholder="ชื่อเรื่องเอกสาร"
                  class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
              </div>

              <!-- วันที่ -->
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">วันที่ออก <span class="text-red-500">*</span></label>
                <input v-model="form.issued_date" type="date"
                  class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
              </div>

              <!-- กลุ่มงาน -->
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">กลุ่มงาน <span class="text-red-500">*</span></label>
                <select v-model="form.department"
                  class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
                  <option value="">-- เลือกกลุ่มงาน --</option>
                  <option v-for="d in DEPARTMENTS" :key="d" :value="d">{{ d }}</option>
                </select>
                <input v-if="form.department === 'อื่นๆ'"
                  v-model="form.dept_other" type="text" placeholder="ระบุกลุ่มงาน..."
                  class="mt-2 w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
              </div>

              <!-- ลิงค์ Drive -->
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">ลิงค์ Google Drive <span class="text-red-500">*</span></label>
                <input v-model="form.drive_url" type="url" placeholder="https://drive.google.com/..."
                  class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
              </div>

              <!-- หมายเหตุ -->
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">หมายเหตุ <span class="text-gray-400 font-normal">(ไม่บังคับ)</span></label>
                <textarea v-model="form.note" rows="2" placeholder="บันทึกเพิ่มเติม..."
                  class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 resize-none"></textarea>
              </div>

              <p v-if="formError" class="text-sm text-red-600 bg-red-50 px-3 py-2 rounded-xl">{{ formError }}</p>
            </div>

            <div class="px-6 py-4 border-t flex justify-end gap-3">
              <button @click="showForm = false"
                class="px-4 py-2 border border-gray-200 rounded-xl text-sm text-gray-600 hover:bg-gray-50">ยกเลิก</button>
              <button @click="saveDoc" :disabled="saving"
                class="px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-semibold disabled:opacity-50 flex items-center gap-2">
                <svg v-if="saving" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                </svg>
                {{ saving ? 'กำลังบันทึก...' : editTarget ? '💾 บันทึกการแก้ไข' : '✅ เพิ่มเอกสาร' }}
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- ===== DELETE CONFIRM ===== -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="deleteTarget" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
          @click.self="deleteTarget = null">
          <div class="bg-white rounded-2xl shadow-xl w-full max-w-sm p-6 space-y-4">
            <h3 class="font-bold text-red-700">🗑️ ยืนยันการลบ</h3>
            <div class="bg-gray-50 rounded-xl p-3 text-sm">
              <p class="font-semibold text-gray-800">{{ deleteTarget?.title }}</p>
              <p class="text-gray-500 text-xs mt-0.5">{{ deleteTarget?.doc_number }} · {{ formatDate(deleteTarget?.issued_date) }}</p>
            </div>
            <p class="text-sm text-gray-600">ลบเอกสารนี้แล้วจะไม่สามารถกู้คืนได้</p>
            <div class="flex gap-3">
              <button @click="deleteDoc" :disabled="deleting"
                class="flex-1 bg-red-600 hover:bg-red-700 text-white py-2.5 rounded-xl text-sm font-medium disabled:opacity-50">
                {{ deleting ? 'กำลังลบ...' : 'ยืนยันลบ' }}
              </button>
              <button @click="deleteTarget = null"
                class="flex-1 border border-gray-200 text-gray-600 py-2.5 rounded-xl text-sm hover:bg-gray-50">ยกเลิก</button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

  </AdminLayout>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import AdminLayout from '../../layouts/AdminLayout.vue'
import { supabase } from '../../lib/supabase'
import { useAuth } from '../../composables/useAuth'

const { user } = useAuth()

// ── Constants ──────────────────────────────────────────────────────────────────
const DEPARTMENTS = [
  'กลุ่มบริหารงานบุคคล',
  'กลุ่มบริหารวิชาการ',
  'กลุ่มบริหารทั่วไป',
  'กลุ่มบริหารงบประมาณ',
  'กิจการนักเรียน',
  'อื่นๆ',
]

const DOC_TYPES = [
  { value: 'order',        icon: '📋', label: 'คำสั่งโรงเรียน' },
  { value: 'announcement', icon: '📢', label: 'ประกาศโรงเรียน' },
]

const PER_PAGE = 20
const currentThaiYear = new Date().getFullYear() + 543

// ── State ──────────────────────────────────────────────────────────────────────
const docs       = ref([])
const loading    = ref(false)
const showForm   = ref(false)
const editTarget = ref(null)
const saving     = ref(false)
const formError  = ref('')
const deleteTarget = ref(null)
const deleting   = ref(false)

// Filters + Sort + Pagination
const search     = ref('')
const filterType = ref('')
const filterDept = ref('')
const filterYear = ref('')
const sortField  = ref('issued_date')
const sortDir    = ref('desc')
const page       = ref(1)

const form = ref(defaultForm())

function defaultForm() {
  return {
    type: 'order',
    doc_number: '',
    title: '',
    issued_date: '',
    department: '',
    dept_other: '',
    academic_year: currentThaiYear,
    drive_url: '',
    note: '',
  }
}

// ── Computed ───────────────────────────────────────────────────────────────────
const yearOptions = computed(() => {
  const years = [...new Set(docs.value.map(d => d.academic_year))].sort((a, b) => b - a)
  if (!years.length) years.push(currentThaiYear)
  return years
})

const filtered = computed(() => {
  let list = [...docs.value]
  const q = search.value.trim().toLowerCase()
  if (q) {
    list = list.filter(d =>
      d.doc_number.toLowerCase().includes(q) ||
      d.title.toLowerCase().includes(q) ||
      d.department.toLowerCase().includes(q) ||
      (d.dept_other || '').toLowerCase().includes(q) ||
      (d.note || '').toLowerCase().includes(q)
    )
  }
  if (filterType.value) list = list.filter(d => d.type === filterType.value)
  if (filterDept.value) list = list.filter(d => d.department === filterDept.value)
  if (filterYear.value) list = list.filter(d => d.academic_year === filterYear.value)

  // sort
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
  const total = totalPages.value
  const cur   = page.value
  let start = Math.max(1, cur - 2)
  let end   = Math.min(total, start + 4)
  if (end - start < 4) start = Math.max(1, end - 4)
  return Array.from({ length: end - start + 1 }, (_, i) => start + i)
})

// reset page on filter change
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
async function fetchDocs() {
  loading.value = true
  const { data } = await supabase
    .from('school_documents')
    .select('*')
    .order('issued_date', { ascending: false })
  docs.value = data || []
  loading.value = false
}

// ── CRUD ───────────────────────────────────────────────────────────────────────
function openForm(doc = null) {
  editTarget.value = doc
  formError.value  = ''
  form.value = doc
    ? { ...doc }
    : defaultForm()
  showForm.value = true
}

function validate() {
  if (!form.value.type)        return 'กรุณาเลือกประเภทเอกสาร'
  if (!form.value.doc_number?.trim()) return 'กรุณากรอกเลขที่'
  if (!form.value.title?.trim())      return 'กรุณากรอกเรื่อง'
  if (!form.value.issued_date)        return 'กรุณาเลือกวันที่'
  if (!form.value.department)         return 'กรุณาเลือกกลุ่มงาน'
  if (form.value.department === 'อื่นๆ' && !form.value.dept_other?.trim()) return 'กรุณาระบุกลุ่มงาน'
  if (!form.value.drive_url?.trim())  return 'กรุณากรอกลิงค์ Google Drive'
  return null
}

async function saveDoc() {
  formError.value = validate()
  if (formError.value) return
  saving.value = true
  const payload = {
    type:          form.value.type,
    doc_number:    form.value.doc_number.trim(),
    title:         form.value.title.trim(),
    issued_date:   form.value.issued_date,
    department:    form.value.department,
    dept_other:    form.value.department === 'อื่นๆ' ? (form.value.dept_other?.trim() || null) : null,
    academic_year: form.value.academic_year,
    drive_url:     form.value.drive_url.trim(),
    note:          form.value.note?.trim() || null,
    updated_at:    new Date().toISOString(),
  }
  let error
  if (editTarget.value) {
    ;({ error } = await supabase.from('school_documents').update(payload).eq('id', editTarget.value.id))
  } else {
    payload.created_by = user.value?.id || null
    ;({ error } = await supabase.from('school_documents').insert(payload))
  }
  saving.value = false
  if (error) { formError.value = error.message; return }
  showForm.value = false
  await fetchDocs()
}

function confirmDelete(doc) { deleteTarget.value = doc }

async function deleteDoc() {
  if (!deleteTarget.value) return
  deleting.value = true
  const { error } = await supabase.from('school_documents').delete().eq('id', deleteTarget.value.id)
  deleting.value = false
  if (!error) {
    docs.value = docs.value.filter(d => d.id !== deleteTarget.value.id)
    deleteTarget.value = null
  }
}

onMounted(fetchDocs)
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to       { opacity: 0; }
</style>
