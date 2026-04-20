<template>
  <AdminLayout>
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h2 class="text-xl font-bold text-gray-900">ระบบข้อมูลนักเรียน (SIS)</h2>
        <p class="text-sm text-gray-500 mt-0.5">
          <span v-if="lastSession">นำเข้าล่าสุด: {{ lastSession.checkpoint_label }} ปี {{ lastSession.academic_year }} — {{ lastSession.total_rows }} คน</span>
          <span v-else>ยังไม่มีข้อมูล</span>
        </p>
      </div>
        <div class="flex gap-2">
        <button @click="exportExcel"
          class="flex items-center gap-2 px-4 py-2 rounded-xl border border-gray-200 text-sm text-gray-600 hover:bg-gray-50 transition-all">
          📊 Export Excel
        </button>
        <router-link to="/admin/sis/import" class="btn-primary flex items-center gap-2">
          <span>📥</span> นำเข้าข้อมูล
        </router-link>
      </div>
    </div>

    <!-- Stats Cards — reactive ตาม filteredStudents -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-4" v-if="students.length">
      <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 mb-1">นักเรียน{{ hasFilter ? ' (ที่กรอง)' : 'ทั้งหมด' }}</p>
        <p class="text-3xl font-bold text-blue-600">{{ liveStats.total.toLocaleString() }}</p>
      </div>
      <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 mb-1">ชาย</p>
        <p class="text-3xl font-bold text-sky-500">{{ liveStats.male.toLocaleString() }}</p>
      </div>
      <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 mb-1">หญิง</p>
        <p class="text-3xl font-bold text-pink-500">{{ liveStats.female.toLocaleString() }}</p>
      </div>
      <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 mb-1">ด้อยโอกาส</p>
        <p class="text-3xl font-bold text-orange-500">{{ liveStats.disadvantaged.toLocaleString() }}</p>
      </div>
    </div>

    <!-- By Level chart — reactive -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6" v-if="students.length">
      <div class="bg-white rounded-2xl shadow-sm p-5 border border-gray-100">
        <h3 class="font-bold text-gray-800 mb-3 text-sm">📊 จำนวนตามระดับชั้น</h3>
        <div class="space-y-2">
          <div v-for="[lvl, cnt] in liveByLevel" :key="lvl"
            class="flex items-center gap-2 cursor-pointer hover:bg-blue-50/50 rounded-lg px-1 -mx-1 transition"
            @click="filterLevel = filterLevel===lvl ? '' : lvl; filterRoom=''; currentPage=1">
            <span :class="['text-xs font-medium w-12', filterLevel===lvl ? 'text-blue-600 font-bold' : 'text-gray-600']">{{ lvl }}</span>
            <div class="flex-1 bg-gray-100 rounded-full h-2">
              <div class="bg-blue-500 h-2 rounded-full transition-all"
                :style="`width:${liveStats.total ? Math.round(cnt/liveStats.total*100) : 0}%`"></div>
            </div>
            <span class="text-xs font-bold text-gray-700 w-10 text-right">{{ cnt }}</span>
          </div>
        </div>
        <p class="text-xs text-gray-400 mt-3">คลิกที่ชั้นเพื่อกรอง</p>
      </div>
      <div class="bg-white rounded-2xl shadow-sm p-5 border border-gray-100">
        <h3 class="font-bold text-gray-800 mb-3 text-sm">🌏 สัญชาติ</h3>
        <div class="space-y-2">
          <div v-for="[nat, cnt] in liveByNation" :key="nat" class="flex items-center justify-between">
            <span class="text-xs text-gray-600">{{ nat }}</span>
            <span class="text-xs font-bold text-gray-800">{{ cnt }}
              <span class="text-gray-400 font-normal">({{ liveStats.total ? Math.round(cnt/liveStats.total*100) : 0 }}%)</span>
            </span>
          </div>
        </div>
      </div>
      <div class="bg-white rounded-2xl shadow-sm p-5 border border-gray-100">
        <h3 class="font-bold text-gray-800 mb-3 text-sm">🕌 ศาสนา</h3>
        <div class="space-y-2">
          <div v-for="[rel, cnt] in liveByReligion" :key="rel" class="flex items-center justify-between">
            <span class="text-xs text-gray-600">{{ rel }}</span>
            <span class="text-xs font-bold text-gray-800">{{ cnt }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabs: รายชื่อ / ประวัติ import -->
    <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
      <div class="flex border-b border-gray-100">
        <button v-for="t in tabs" :key="t.key" @click="activeTab=t.key"
          :class="['px-5 py-3.5 text-sm font-medium transition-colors',
            activeTab===t.key ? 'border-b-2 border-blue-600 text-blue-600' : 'text-gray-500 hover:text-gray-700']">
          {{ t.label }}
        </button>
      </div>

      <!-- Tab: รายชื่อนักเรียน -->
      <div v-if="activeTab==='list'">
        <!-- Filters + Sort -->
        <div class="p-4 border-b border-gray-50 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
          <input v-model="search" @input="currentPage=1" type="text" placeholder="🔍 ชื่อ/รหัส"
            class="col-span-2 sm:col-span-1 border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" />
          <select v-model="filterLevel" @change="filterRoom='';currentPage=1"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option value="">— ทุกชั้น —</option>
            <option v-for="l in levels" :key="l" :value="l">{{ l }}</option>
          </select>
          <select v-model="filterRoom" @change="currentPage=1"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option value="">— ทุกห้อง —</option>
            <option v-for="r in roomsForLevel" :key="r" :value="r">ห้อง {{ r }}</option>
          </select>
          <select v-model="filterGender" @change="currentPage=1"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option value="">— ทุกเพศ —</option>
            <option value="ช">ชาย</option>
            <option value="ญ">หญิง</option>
          </select>
          <select v-model="filterStatus" @change="currentPage=1"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option value="">— ทุกสถานะ —</option>
            <option value="ปกติ">ปกติ</option>
            <option value="ลาออก">ลาออก</option>
            <option value="ย้ายออก">ย้ายออก</option>
            <option value="จำหน่าย">จำหน่าย</option>
          </select>
          <!-- Sort -->
          <select v-model="sortKey" @change="currentPage=1"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option value="grade_level">เรียงตามชั้น</option>
            <option value="room">เรียงตามห้อง</option>
            <option value="first_name">เรียงตามชื่อ</option>
            <option value="student_code">เรียงตามรหัส</option>
          </select>
          <!-- Per page -->
          <select v-model.number="perPage" @change="currentPage=1"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option :value="25">25 คน/หน้า</option>
            <option :value="50">50 คน/หน้า</option>
            <option :value="100">100 คน/หน้า</option>
          </select>
        </div>

        <div v-if="loadingStudents" class="p-10 text-center text-gray-400">
          <div class="text-3xl animate-spin mb-2">⏳</div>กำลังโหลด...
        </div>
        <div v-else-if="!filteredStudents.length" class="p-10 text-center text-gray-400">
          <div class="text-4xl mb-2">🎓</div>ไม่พบนักเรียน
        </div>
        <div v-else>
          <!-- Info bar -->
          <div class="px-4 py-2.5 border-b border-gray-50 flex items-center justify-between text-xs text-gray-400">
            <span>พบ <strong class="text-gray-700">{{ filteredStudents.length }}</strong> คน
              (หน้า {{ currentPage }}/{{ totalPages }})</span>
            <button v-if="search||filterLevel||filterRoom||filterGender||filterStatus"
              @click="search='';filterLevel='';filterRoom='';filterGender='';filterStatus='';currentPage=1"
              class="text-red-400 hover:text-red-600 underline">ล้างตัวกรอง</button>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 text-gray-500 text-xs uppercase">
                <tr>
                  <th class="py-2.5 px-3 text-left w-8 text-gray-400">#</th>
                  <th class="py-2.5 px-3 text-left cursor-pointer hover:text-blue-600 select-none" @click="setSort('student_code')">
                    เลขประจำตัว {{ sortKey==='student_code' ? (sortAsc?'↑':'↓') : '↕' }}
                  </th>
                  <th class="py-2.5 px-3 text-left hidden lg:table-cell text-gray-400 text-xs">เลขบัตรปชช.</th>
                  <th class="py-2.5 px-3 text-left cursor-pointer hover:text-blue-600 select-none" @click="setSort('first_name')">
                    ชื่อ-สกุล {{ sortKey==='first_name' ? (sortAsc?'↑':'↓') : '' }}
                  </th>
                  <th class="py-2.5 px-3 text-center">เพศ</th>
                  <th class="py-2.5 px-3 text-center cursor-pointer hover:text-blue-600 select-none" @click="setSort('grade_level')">
                    ชั้น {{ sortKey==='grade_level' ? (sortAsc?'↑':'↓') : '' }}
                  </th>
                  <th class="py-2.5 px-3 text-center cursor-pointer hover:text-blue-600 select-none" @click="setSort('room')">
                    ห้อง {{ sortKey==='room' ? (sortAsc?'↑':'↓') : '' }}
                  </th>
                  <th class="py-2.5 px-3 text-center hidden md:table-cell">สถานะ</th>
                  <th class="py-2.5 px-3 text-center hidden lg:table-cell">BMI</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(s, idx) in pagedStudents" :key="s.id"
                  class="border-b border-gray-50 hover:bg-blue-50/20 transition-colors">
                  <td class="py-2 px-3 text-gray-400 text-xs">{{ (currentPage-1)*perPage + idx + 1 }}</td>
                  <td class="py-2 px-3 font-mono text-sm font-bold text-blue-700">{{ s.student_code }}</td>
                  <td class="py-2 px-3 font-mono text-xs text-gray-400 hidden lg:table-cell">{{ s.national_id }}</td>
                  <td class="py-2 px-3 font-medium text-gray-900">{{ s.prefix }}{{ s.first_name }} {{ s.last_name }}</td>
                  <td class="py-2 px-3 text-center">{{ s.gender === 'ช' ? '👦' : '👧' }}</td>
                  <td class="py-2 px-3 text-center font-medium text-blue-700">{{ s.grade_level }}</td>
                  <td class="py-2 px-3 text-center text-gray-600">{{ s.room }}</td>
                  <td class="py-2 px-3 text-center hidden md:table-cell">
                    <button @click="openStatusModal(s)"
                      :class="['text-xs px-2 py-0.5 rounded-full font-medium cursor-pointer hover:opacity-75 transition-opacity',
                        s.status==='ปกติ'   ? 'bg-green-100 text-green-700' :
                        s.status==='ลาออก'  ? 'bg-red-100 text-red-600' :
                        s.status==='ย้ายออก'? 'bg-orange-100 text-orange-600' :
                        'bg-gray-100 text-gray-600']">
                      {{ s.status || 'ปกติ' }} ✏️
                    </button>
                  </td>
                  <td class="py-2 px-3 text-center text-xs text-gray-500 hidden lg:table-cell">
                    {{ calcBMI(s.weight, s.height) }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Pagination -->
          <div class="px-4 py-3 border-t border-gray-100 flex items-center justify-between">
            <button @click="currentPage--" :disabled="currentPage<=1"
              class="px-3 py-1.5 rounded-lg border border-gray-200 text-sm disabled:opacity-30 hover:bg-gray-50">← ก่อนหน้า</button>
            <div class="flex items-center gap-1">
              <button v-for="p in pageNumbers" :key="p" @click="currentPage=p"
                :class="['w-8 h-8 rounded-lg text-sm font-medium transition-all',
                  currentPage===p ? 'bg-blue-600 text-white' : 'text-gray-500 hover:bg-gray-100']">
                {{ p }}
              </button>
            </div>
            <button @click="currentPage++" :disabled="currentPage>=totalPages"
              class="px-3 py-1.5 rounded-lg border border-gray-200 text-sm disabled:opacity-30 hover:bg-gray-50">ถัดไป →</button>
          </div>
        </div>
      </div>

      <!-- Tab: ประวัติ Import + Session Management -->
      <div v-if="activeTab==='history'">
        <div v-if="!sessions.length" class="p-10 text-center text-gray-400">
          <div class="text-4xl mb-2">📋</div>ยังไม่มีประวัติการนำเข้า
          <div class="mt-4">
            <router-link to="/admin/sis/import" class="btn-primary px-5 py-2 text-sm">📥 นำเข้าข้อมูลใหม่</router-link>
          </div>
        </div>
        <div v-else>
          <div class="px-4 py-3 border-b border-gray-100 flex items-center justify-between bg-gray-50/60">
            <p class="text-xs text-gray-500">{{ sessions.length }} รอบ — ลากหรือใช้ปุ่ม ↑↓ เพื่อเรียงลำดับ</p>
            <router-link to="/admin/sis/import" class="text-xs text-blue-600 hover:underline">📥 นำเข้าใหม่</router-link>
          </div>
          <div class="divide-y divide-gray-50">
            <div v-for="(s, idx) in sessions" :key="s.id"
              class="flex items-center gap-3 px-4 py-3 hover:bg-gray-50/60 transition group">

              <!-- Sort arrows -->
              <div class="flex flex-col gap-0.5 shrink-0">
                <button @click="moveSession(idx, -1)" :disabled="idx===0"
                  class="w-6 h-5 flex items-center justify-center text-gray-300 hover:text-blue-500 disabled:opacity-20 transition text-xs rounded hover:bg-blue-50">▲</button>
                <button @click="moveSession(idx, +1)" :disabled="idx===sessions.length-1"
                  class="w-6 h-5 flex items-center justify-center text-gray-300 hover:text-blue-500 disabled:opacity-20 transition text-xs rounded hover:bg-blue-50">▼</button>
              </div>

              <!-- Year + checkpoint badge -->
              <div class="w-16 shrink-0">
                <span class="font-bold text-blue-700 text-sm">{{ s.academic_year }}</span>
              </div>
              <div class="shrink-0">
                <span class="text-xs bg-purple-100 text-purple-700 px-2 py-0.5 rounded-full font-medium">
                  ช่วง {{ s.checkpoint }}
                </span>
              </div>

              <!-- Label — editable inline -->
              <div class="flex-1 min-w-0">
                <template v-if="editingSession?.id === s.id">
                  <input v-model="editingLabel" @keyup.enter="saveSessionLabel"
                    @keyup.esc="editingSession=null"
                    class="w-full border border-blue-300 rounded-lg px-2 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                    :ref="el => el && el.focus()" />
                </template>
                <template v-else>
                  <span class="text-sm text-gray-800 truncate block">{{ s.checkpoint_label || `ช่วง ${s.checkpoint}/${s.academic_year}` }}</span>
                  <span class="text-xs text-gray-400">{{ new Date(s.imported_at).toLocaleDateString('th-TH') }} · {{ s.total_rows?.toLocaleString() }} คน</span>
                </template>
              </div>

              <!-- Count chips -->
              <div class="hidden md:flex items-center gap-2 shrink-0">
                <span class="text-xs font-bold text-gray-700">{{ s.total_rows?.toLocaleString() }}</span>
              </div>

              <!-- Edit / Save / Cancel / Delete buttons -->
              <div class="flex items-center gap-1 shrink-0">
                <template v-if="editingSession?.id === s.id">
                  <button @click="saveSessionLabel" :disabled="savingSessionLabel"
                    class="px-3 py-1 text-xs bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 transition">
                    {{ savingSessionLabel ? '...' : 'บันทึก' }}
                  </button>
                  <button @click="editingSession=null"
                    class="px-2 py-1 text-xs border border-gray-200 rounded-lg hover:bg-gray-50 transition">ยกเลิก</button>
                </template>
                <template v-else>
                  <button @click="startEditSession(s)"
                    class="opacity-0 group-hover:opacity-100 p-1.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition">✏️</button>
                  <button @click="confirmDeleteSession(s)"
                    class="opacity-0 group-hover:opacity-100 p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition">🗑️</button>
                </template>
              </div>
            </div>
          </div>
          <div v-if="sessionActionError" class="px-4 py-2 text-xs text-red-600 bg-red-50 border-t border-red-100">
            ⚠️ {{ sessionActionError }}
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Session Confirm Modal -->
    <div v-if="deleteSessionTarget" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4"
      @click.self="deleteSessionTarget=null">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
        <div class="text-4xl mb-3">🗑️</div>
        <h3 class="font-bold text-gray-800 mb-2">ลบรอบการนำเข้า?</h3>
        <p class="text-sm font-medium text-gray-700 mb-1">{{ deleteSessionTarget.checkpoint_label }}</p>
        <p class="text-xs text-gray-400 mb-5">
          ปีการศึกษา {{ deleteSessionTarget.academic_year }} ช่วงที่ {{ deleteSessionTarget.checkpoint }} ·
          {{ deleteSessionTarget.total_rows?.toLocaleString() }} รายการ
        </p>
        <div class="bg-red-50 border border-red-200 rounded-lg p-3 mb-5 text-xs text-red-700 text-left">
          ⚠️ ข้อมูล Snapshot <strong>{{ deleteSessionTarget.total_rows?.toLocaleString() }}</strong> รายการของรอบนี้จะถูกลบถาวร
        </div>
        <div v-if="deleteSessionError" class="bg-red-50 border border-red-200 rounded-lg p-2 mb-4 text-xs text-red-600">
          {{ deleteSessionError }}
        </div>
        <div class="flex gap-3 justify-center">
          <button @click="deleteSessionTarget=null" class="px-5 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50">ยกเลิก</button>
          <button @click="deleteSession" :disabled="deletingSession"
            class="px-5 py-2 text-sm bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:bg-gray-300 flex items-center gap-2">
            <span v-if="deletingSession" class="animate-spin">⏳</span>
            {{ deletingSession ? 'กำลังลบ...' : 'ลบถาวร' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Status Modal -->
    <div v-if="statusModal.show"
      class="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4"
      @click.self="statusModal.show=false">
      <div class="bg-white rounded-2xl shadow-xl w-full max-w-sm p-6">
        <h3 class="font-bold text-gray-900 mb-1">เปลี่ยนสถานะนักเรียน</h3>
        <p class="text-sm text-gray-500 mb-5">
          {{ statusModal.student?.prefix }}{{ statusModal.student?.first_name }} {{ statusModal.student?.last_name }}
          <span class="font-mono text-xs text-gray-400 ml-1">({{ statusModal.student?.student_code }})</span>
        </p>
        <div class="grid grid-cols-2 gap-3 mb-5">
          <button v-for="st in statusOptions" :key="st.value"
            @click="statusModal.selected = st.value"
            :class="['p-3 rounded-xl border-2 text-sm font-medium transition-all text-center',
              statusModal.selected === st.value
                ? `${st.activeBorder} ${st.activeBg} ${st.activeText}`
                : 'border-gray-200 text-gray-600 hover:border-gray-300']">
            {{ st.icon }} {{ st.value }}
          </button>
        </div>
        <div class="flex gap-3">
          <button @click="statusModal.show=false"
            class="flex-1 px-4 py-2.5 border border-gray-200 rounded-xl text-sm text-gray-600 hover:bg-gray-50">
            ยกเลิก
          </button>
          <button @click="saveStatus" :disabled="savingStatus"
            class="flex-1 btn-primary py-2.5 disabled:opacity-50">
            {{ savingStatus ? 'กำลังบันทึก...' : 'บันทึก' }}
          </button>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import * as XLSX from 'xlsx'
import AdminLayout from '../../layouts/AdminLayout.vue'
import { supabase } from '../../lib/supabase'

const students       = ref([])
const sessions       = ref([])
const stats          = ref(null)
const lastSession    = ref(null)
const loadingStudents = ref(true)
const activeTab      = ref('list')
const displayLimit   = ref(200)
const tabs = [
  { key: 'list',    label: '👨‍🎓 รายชื่อนักเรียน' },
  { key: 'history', label: '📋 ประวัติการนำเข้า' },
]

const search        = ref('')
const filterLevel   = ref('')
const filterRoom    = ref('')
const filterGender  = ref('')
const filterStatus  = ref('')
// เรียงลำดับชั้นเรียน: อนุบาล → ป. → ม.
function levelOrder(lvl) {
  if (!lvl) return 9999
  const n = parseInt(lvl.replace(/\D/g,'')) || 0
  if (lvl.startsWith('อ'))  return n           // อ.1=1, อ.2=2, อ.3=3
  if (lvl.startsWith('ป'))  return 100 + n     // ป.1=101 ... ป.6=106
  if (lvl.startsWith('ม'))  return 200 + n     // ม.1=201 ... ม.6=206
  return 500 + n
}

const sortKey      = ref('student_code')
const sortAsc      = ref(true)
const currentPage  = ref(1)
const perPage      = ref(50)

const hasFilter = computed(() => !!(search.value || filterLevel.value || filterRoom.value || filterGender.value || filterStatus.value))

const levels = computed(() => [...new Set(students.value.map(s=>s.grade_level).filter(Boolean))].sort((a,b)=>a.localeCompare(b,'th')))
const roomsForLevel = computed(() => {
  const src = filterLevel.value ? students.value.filter(s=>s.grade_level===filterLevel.value) : students.value
  // numeric sort สำหรับห้อง
  return [...new Set(src.map(s=>s.room).filter(v=>v!=null))].sort((a,b)=>Number(a)-Number(b))
})

// สถิติ reactive จาก filteredStudents
const liveStats = computed(() => {
  const list = filteredStudents.value
  const byLevel    = {}, byNation = {}, byReligion = {}
  let male = 0, female = 0, disadv = 0
  for (const s of list) {
    if (s.gender === 'ช') male++; else female++
    const dv = (s.disadvantaged || '').trim()
    if (dv) disadv++
    const lv = s.grade_level || 'ไม่ระบุ'
    byLevel[lv]   = (byLevel[lv]   || 0) + 1
    const nat = s.nationality || 'ไม่ระบุ'
    byNation[nat] = (byNation[nat] || 0) + 1
    const rel = s.religion || 'ไม่ระบุ'
    byReligion[rel] = (byReligion[rel] || 0) + 1
  }
  return { total: list.length, male, female, disadvantaged: disadv, byLevel, byNation, byReligion }
})
const liveByLevel   = computed(() => Object.entries(liveStats.value.byLevel).sort((a,b)=>a[0].localeCompare(b[0],'th')))
const liveByNation  = computed(() => Object.entries(liveStats.value.byNation).sort((a,b)=>b[1]-a[1]))
const liveByReligion= computed(() => Object.entries(liveStats.value.byReligion).sort((a,b)=>b[1]-a[1]))

function setSort(key) {
  if (sortKey.value === key) sortAsc.value = !sortAsc.value
  else { sortKey.value = key; sortAsc.value = true }
  currentPage.value = 1
}

const filteredStudents = computed(() => {
  const q = search.value.trim().toLowerCase()
  let list = students.value.filter(s => {
    if (filterLevel.value  && s.grade_level !== filterLevel.value)        return false
    if (filterRoom.value   && Number(s.room) !== Number(filterRoom.value)) return false
    if (filterGender.value && s.gender !== filterGender.value)             return false
    if (filterStatus.value && s.status !== filterStatus.value)             return false
    if (q && !`${s.first_name} ${s.last_name} ${s.student_code}`.toLowerCase().includes(q)) return false
    return true
  })
  return [...list].sort((a, b) => {
    const va = a[sortKey.value] ?? '', vb = b[sortKey.value] ?? ''
    let cmp = 0
    if (sortKey.value === 'room')        cmp = Number(va) - Number(vb)
    else if (sortKey.value === 'grade_level') cmp = levelOrder(va) - levelOrder(vb)
    else cmp = String(va).localeCompare(String(vb), 'th', { numeric: true })
    return sortAsc.value ? cmp : -cmp
  })
})

const totalPages    = computed(() => Math.max(1, Math.ceil(filteredStudents.value.length / perPage.value)))
const pagedStudents = computed(() => filteredStudents.value.slice((currentPage.value-1)*perPage.value, currentPage.value*perPage.value))
const pageNumbers   = computed(() => {
  const t = totalPages.value, c = currentPage.value
  if (t <= 7) return Array.from({length:t},(_,i)=>i+1)
  return [...new Set([1,t,c,c-1,c+1].filter(p=>p>=1&&p<=t))].sort((a,b)=>a-b)
})
watch(filteredStudents, () => { if (currentPage.value > totalPages.value) currentPage.value = 1 })

function calcBMI(w, h) {
  if (!w || !h) return '—'
  const bmi = w / ((h/100) ** 2)
  return bmi.toFixed(1)
}

// ===== Status modal =====
const statusOptions = [
  { value: 'ปกติ',   icon: '✅', activeBorder: 'border-green-500',  activeBg: 'bg-green-50',  activeText: 'text-green-700' },
  { value: 'ลาออก',  icon: '🚪', activeBorder: 'border-red-500',    activeBg: 'bg-red-50',    activeText: 'text-red-700'   },
  { value: 'ย้ายออก',icon: '📦', activeBorder: 'border-orange-500', activeBg: 'bg-orange-50', activeText: 'text-orange-700'},
  { value: 'จำหน่าย',icon: '📋', activeBorder: 'border-gray-500',   activeBg: 'bg-gray-50',   activeText: 'text-gray-700'  },
]
const statusModal  = ref({ show: false, student: null, selected: '' })
const savingStatus = ref(false)

function openStatusModal(student) {
  statusModal.value = { show: true, student, selected: student.status || 'ปกติ' }
}

async function saveStatus() {
  const { student, selected } = statusModal.value
  if (!student || !selected) return
  savingStatus.value = true
  const { error } = await supabase.from('students').update({ status: selected }).eq('id', student.id)
  if (!error) {
    const s = students.value.find(x => x.id === student.id)
    if (s) s.status = selected
    statusModal.value.show = false
  } else {
    alert('บันทึกไม่สำเร็จ: ' + error.message)
  }
  savingStatus.value = false
}

// ===== Export Excel =====
function exportExcel() {
  const rows = filteredStudents.value.map((s, i) => ({
    '#':           i + 1,
    'เลขประจำตัว': s.student_code,
    'เลขบัตร ปชช.':s.national_id || '',
    'คำนำหน้า':    s.prefix || '',
    'ชื่อ':        s.first_name || '',
    'นามสกุล':     s.last_name || '',
    'เพศ':         s.gender === 'ช' ? 'ชาย' : 'หญิง',
    'ชั้น':        s.grade_level || '',
    'ห้อง':        s.room || '',
    'สถานะ':       s.status || 'ปกติ',
    'วันเกิด':     s.birth_date || '',
    'น้ำหนัก':     s.weight || '',
    'ส่วนสูง':     s.height || '',
    'ศาสนา':       s.religion || '',
    'สัญชาติ':     s.nationality || '',
    'ผู้ปกครอง':   s.guardian_name || '',
    'ความสัมพันธ์':s.guardian_relation || '',
    'ด้อยโอกาส':   s.disadvantaged || '',
  }))
  const ws = XLSX.utils.json_to_sheet(rows)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'นักเรียน')
  const label = filterLevel.value ? `_${filterLevel.value}` : ''
  XLSX.writeFile(wb, `students${label}_${new Date().toISOString().slice(0,10)}.xlsx`)
}

async function fetchAll() {
  loadingStudents.value = true
  const [{ data: sts }, { data: sess }, { data: statsData }] = await Promise.all([
    supabase.rpc('get_all_students'),
    supabase.rpc('get_sis_sessions'),
    supabase.rpc('get_checkpoint_stats'),
  ])
  // get_all_students returns jsonb (array) to bypass PostgREST 1000-row limit
  students.value  = Array.isArray(sts) ? sts : (sts || [])
  sessions.value  = sess  || []
  stats.value     = statsData || null
  lastSession.value = (sess || [])[0] || null
  loadingStudents.value = false
}

// ══ Session Management ════════════════════════════════════════════════════════
const editingSession      = ref(null)   // session object กำลัง edit label
const editingLabel        = ref('')
const savingSessionLabel  = ref(false)
const deleteSessionTarget = ref(null)
const deletingSession     = ref(false)
const deleteSessionError  = ref('')
const sessionActionError  = ref('')

function startEditSession(s) {
  editingSession.value = s
  editingLabel.value   = s.checkpoint_label || ''
}

async function saveSessionLabel() {
  if (!editingSession.value || !editingLabel.value.trim()) return
  savingSessionLabel.value = true; sessionActionError.value = ''
  try {
    const { error } = await supabase
      .from('import_sessions')
      .update({ checkpoint_label: editingLabel.value.trim() })
      .eq('id', editingSession.value.id)
    if (error) throw error
    // อัปเดต local state
    const t = sessions.value.find(s => s.id === editingSession.value.id)
    if (t) t.checkpoint_label = editingLabel.value.trim()
    editingSession.value = null
  } catch (e) {
    sessionActionError.value = e.message || 'บันทึกไม่ได้'
  } finally {
    savingSessionLabel.value = false
  }
}

function confirmDeleteSession(s) {
  deleteSessionTarget.value = s
  deleteSessionError.value  = ''
}

async function deleteSession() {
  if (!deleteSessionTarget.value) return
  deletingSession.value = true; deleteSessionError.value = ''
  try {
    const id = deleteSessionTarget.value.id
    // 1. ลบ snapshots ก่อน (FK constraint)
    const { error: snapErr } = await supabase
      .from('student_snapshots').delete().eq('import_session_id', id)
    if (snapErr) throw snapErr
    // 2. ลบ import_session
    const { error: sessErr } = await supabase
      .from('import_sessions').delete().eq('id', id)
    if (sessErr) throw sessErr
    // 3. อัปเดต local
    sessions.value = sessions.value.filter(s => s.id !== id)
    lastSession.value = sessions.value[0] || null
    deleteSessionTarget.value = null
  } catch (e) {
    deleteSessionError.value = e.message || 'เกิดข้อผิดพลาด'
  } finally {
    deletingSession.value = false
  }
}

async function moveSession(idx, dir) {
  const swapIdx = idx + dir
  if (swapIdx < 0 || swapIdx >= sessions.value.length) return
  sessionActionError.value = ''

  // สลับ sort_order ของสองตัว
  const a = sessions.value[idx]
  const b = sessions.value[swapIdx]
  const orderA = a.sort_order ?? idx
  const orderB = b.sort_order ?? swapIdx

  // ถ้า sort_order เท่ากัน ให้ใช้ index แทน
  const newOrderA = orderB === orderA ? (dir > 0 ? orderA + 1 : orderA - 1) : orderB
  const newOrderB = orderB === orderA ? (dir > 0 ? orderA - 1 : orderA + 1) : orderA

  try {
    await Promise.all([
      supabase.from('import_sessions').update({ sort_order: newOrderA }).eq('id', a.id),
      supabase.from('import_sessions').update({ sort_order: newOrderB }).eq('id', b.id),
    ])
    // อัปเดต local
    sessions.value[idx].sort_order     = newOrderA
    sessions.value[swapIdx].sort_order = newOrderB
    // สลับตำแหน่งใน array
    ;[sessions.value[idx], sessions.value[swapIdx]] = [sessions.value[swapIdx], sessions.value[idx]]
  } catch (e) {
    sessionActionError.value = e.message || 'เรียงลำดับไม่ได้'
  }
}

onMounted(fetchAll)
</script>
