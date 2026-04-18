<template>
  <AdminLayout>
    <div class="space-y-6">

      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-xl font-bold text-gray-900 flex items-center gap-2">🔑 API Keys</h2>
          <p class="text-sm text-gray-500 mt-0.5">สร้างและจัดการเส้นทาง API สำหรับดึงข้อมูลภายนอก</p>
        </div>
        <button @click="openCreate"
          class="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-xl text-sm font-medium shadow-sm transition-colors">
          <span class="text-lg leading-none">+</span> สร้าง API Key
        </button>
      </div>

      <!-- Key List -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div v-if="loading" class="p-10 text-center text-gray-400">
          <div class="text-3xl animate-spin inline-block mb-2">⏳</div>
          <p class="text-sm">กำลังโหลด...</p>
        </div>
        <div v-else-if="!keys.length" class="p-12 text-center text-gray-400">
          <div class="text-5xl mb-3">🔑</div>
          <p class="font-medium">ยังไม่มี API Key</p>
          <p class="text-xs mt-1">กดปุ่ม "สร้าง API Key" เพื่อเริ่มต้น</p>
        </div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-100 text-xs text-gray-500 uppercase tracking-wide">
            <tr>
              <th class="py-3 px-4 text-left">ชื่อ / Resource</th>
              <th class="py-3 px-4 text-left hidden md:table-cell">Field ที่เลือก</th>
              <th class="py-3 px-4 text-center">เรียกใช้</th>
              <th class="py-3 px-4 text-center hidden sm:table-cell">ใช้ล่าสุด</th>
              <th class="py-3 px-4 text-center">สถานะ</th>
              <th class="py-3 px-4 text-center">จัดการ</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="k in keys" :key="k.id" class="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
              <td class="py-3 px-4">
                <p class="font-semibold text-gray-900">{{ k.name }}</p>
                <div class="flex items-center gap-1.5 mt-0.5">
                  <span :class="['text-[10px] px-2 py-0.5 rounded-full font-medium', resourceBadge(k.resource)]">
                    {{ RESOURCES.find(r => r.key === k.resource)?.label || k.resource }}
                  </span>
                  <span v-if="k.expires_at" class="text-[10px] text-gray-400">
                    หมดอายุ {{ formatDate(k.expires_at) }}
                  </span>
                </div>
              </td>
              <td class="py-3 px-4 hidden md:table-cell">
                <div class="flex flex-wrap gap-1">
                  <span v-for="f in k.fields.slice(0,5)" :key="f"
                    class="text-[10px] bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded">{{ f }}</span>
                  <span v-if="k.fields.length > 5" class="text-[10px] text-gray-400">+{{ k.fields.length - 5 }}</span>
                </div>
              </td>
              <td class="py-3 px-4 text-center">
                <span class="text-sm font-semibold text-gray-700">{{ k.request_count ?? 0 }}</span>
              </td>
              <td class="py-3 px-4 text-center hidden sm:table-cell text-xs text-gray-400">
                {{ k.last_used_at ? formatDate(k.last_used_at) : '—' }}
              </td>
              <td class="py-3 px-4 text-center">
                <button @click="toggleActive(k)"
                  :class="['px-2.5 py-1 rounded-full text-xs font-semibold transition-colors',
                    k.is_active ? 'bg-green-100 text-green-700 hover:bg-red-50 hover:text-red-600'
                                : 'bg-gray-100 text-gray-500 hover:bg-green-50 hover:text-green-600']">
                  {{ k.is_active ? '✅ เปิด' : '⛔ ปิด' }}
                </button>
              </td>
              <td class="py-3 px-4 text-center">
                <div class="flex items-center justify-center gap-1">
                  <button @click="showUrl(k)" title="ดู URL"
                    class="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors">🔗</button>
                  <button @click="confirmDelete(k)" title="ลบ"
                    class="p-1.5 rounded-lg text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors">🗑️</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

    </div>

    <!-- ===== CREATE MODAL ===== -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="showCreate" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
          @click.self="showCreate = false">
          <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] flex flex-col">

            <!-- Header -->
            <div class="px-6 py-4 border-b flex items-center justify-between">
              <h3 class="font-bold text-gray-900">🔑 สร้าง API Key ใหม่</h3>
              <button @click="showCreate = false" class="w-8 h-8 flex items-center justify-center rounded-full hover:bg-gray-100 text-gray-400">✕</button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto px-6 py-5 space-y-5">

              <!-- ชื่อ -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อ API Key <span class="text-red-500">*</span></label>
                <input v-model="form.name" type="text" placeholder="เช่น Google Sheets ทะเบียนครู"
                  class="w-full border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" />
              </div>

              <!-- Resource -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">ข้อมูลที่ต้องการ</label>
                <div class="flex gap-3">
                  <button v-for="r in RESOURCES" :key="r.key"
                    @click="form.resource = r.key; form.fields = []"
                    :class="['flex-1 flex items-center gap-2 px-4 py-3 rounded-xl border-2 text-sm font-medium transition-all',
                      form.resource === r.key ? 'border-blue-500 bg-blue-50 text-blue-700' : 'border-gray-200 text-gray-600 hover:border-gray-300']">
                    <span class="text-xl">{{ r.icon }}</span>
                    <div class="text-left">
                      <p class="font-semibold">{{ r.label }}</p>
                      <p class="text-xs opacity-60">{{ r.desc }}</p>
                    </div>
                  </button>
                </div>
              </div>

              <!-- Field Selector -->
              <div v-if="form.resource">
                <div class="flex items-center justify-between mb-2">
                  <label class="block text-sm font-medium text-gray-700">เลือก Field ที่ต้องการ</label>
                  <div class="flex gap-2 text-xs">
                    <button @click="selectSafe" class="text-blue-600 hover:underline">เลือกปลอดภัย</button>
                    <span class="text-gray-300">|</span>
                    <button @click="form.fields = currentFields.map(f => f.key)" class="text-gray-500 hover:underline">เลือกทั้งหมด</button>
                    <span class="text-gray-300">|</span>
                    <button @click="form.fields = []" class="text-gray-500 hover:underline">ล้าง</button>
                  </div>
                </div>

                <!-- Fields by category -->
                <div v-for="cat in fieldCategories" :key="cat" class="mb-4">
                  <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">{{ cat }}</p>
                  <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
                    <label v-for="f in currentFields.filter(x => x.category === cat)" :key="f.key"
                      :class="['flex items-center gap-2 px-3 py-2 rounded-xl border-2 cursor-pointer transition-all text-sm select-none',
                        form.fields.includes(f.key)
                          ? (f.safe ? 'border-blue-400 bg-blue-50' : 'border-orange-400 bg-orange-50')
                          : 'border-gray-100 hover:border-gray-300 bg-gray-50']">
                      <input type="checkbox" :value="f.key" v-model="form.fields" class="accent-blue-600" />
                      <span class="flex-1">
                        <span class="font-medium text-gray-800">{{ f.label }}</span>
                        <span v-if="!f.safe" class="ml-1 text-[10px] text-orange-500">⚠️ sensitive</span>
                      </span>
                    </label>
                  </div>
                </div>

                <p v-if="form.fields.length" class="text-xs text-gray-500 mt-1">
                  เลือก {{ form.fields.length }} field · {{ form.fields.join(', ') }}
                </p>
              </div>

              <!-- Expiry (optional) -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">วันหมดอายุ <span class="text-gray-400 text-xs">(ไม่บังคับ)</span></label>
                <input v-model="form.expires_at" type="date" :min="todayStr"
                  class="w-full border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" />
              </div>

              <p v-if="createError" class="text-sm text-red-600 bg-red-50 px-3 py-2 rounded-xl">{{ createError }}</p>
            </div>

            <!-- Footer -->
            <div class="px-6 py-4 border-t flex justify-end gap-3">
              <button @click="showCreate = false" class="px-4 py-2 border border-gray-200 rounded-xl text-sm text-gray-600 hover:bg-gray-50">ยกเลิก</button>
              <button @click="createKey" :disabled="creating || !form.name || !form.resource || !form.fields.length"
                class="px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-semibold disabled:opacity-50 flex items-center gap-2">
                <svg v-if="creating" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                </svg>
                {{ creating ? 'กำลังสร้าง...' : '✅ สร้าง API Key' }}
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- ===== RESULT MODAL (แสดง key + URL) ===== -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="result" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
          <div class="bg-white rounded-2xl shadow-2xl w-full max-w-xl">
            <div class="px-6 py-4 border-b">
              <h3 class="font-bold text-green-700 flex items-center gap-2">✅ สร้าง API Key สำเร็จ!</h3>
            </div>
            <div class="px-6 py-5 space-y-4">

              <!-- Warning -->
              <div class="bg-amber-50 border border-amber-200 rounded-xl p-3 flex gap-2 text-xs text-amber-700">
                <span class="text-lg shrink-0">⚠️</span>
                <p><strong>คัดลอก API Key ไว้ก่อน</strong> — ระบบจะแสดงครั้งเดียวเท่านั้น ไม่สามารถดูซ้ำได้</p>
              </div>

              <!-- API Key -->
              <div>
                <label class="text-xs font-semibold text-gray-500 mb-1 block">API KEY</label>
                <div class="flex gap-2">
                  <code class="flex-1 bg-gray-900 text-green-400 px-3 py-2.5 rounded-xl text-sm font-mono break-all">{{ result.key }}</code>
                  <button @click="copy(result.key)"
                    class="px-3 py-2 border border-gray-200 rounded-xl text-sm hover:bg-gray-50 shrink-0 transition-colors">
                    {{ copied === 'key' ? '✅' : '📋' }}
                  </button>
                </div>
              </div>

              <!-- URL -->
              <div>
                <label class="text-xs font-semibold text-gray-500 mb-1 block">ENDPOINT URL</label>
                <div class="flex gap-2">
                  <code class="flex-1 bg-gray-50 border border-gray-200 text-gray-700 px-3 py-2.5 rounded-xl text-xs break-all">{{ result.url }}</code>
                  <button @click="copy(result.url)"
                    class="px-3 py-2 border border-gray-200 rounded-xl text-sm hover:bg-gray-50 shrink-0 transition-colors">
                    {{ copied === 'url' ? '✅' : '📋' }}
                  </button>
                </div>
              </div>

              <!-- Fields info -->
              <div class="text-xs text-gray-500 bg-gray-50 rounded-xl p-3">
                <p><strong>Resource:</strong> {{ result.resource }}</p>
                <p class="mt-1"><strong>Fields:</strong> {{ result.fields.join(', ') }}</p>
                <p class="mt-2 text-gray-400">เรียก URL นี้แบบ GET · response เป็น JSON</p>
              </div>
            </div>
            <div class="px-6 py-4 border-t">
              <button @click="result = null; fetchKeys()"
                class="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-semibold transition-colors">
                เข้าใจแล้ว ปิด
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- ===== URL VIEWER MODAL ===== -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="urlView" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
          @click.self="urlView = null">
          <div class="bg-white rounded-2xl shadow-xl w-full max-w-xl p-6 space-y-4">
            <h3 class="font-bold text-gray-900">🔗 {{ urlView.name }}</h3>

            <!-- คำเตือนหลัก: key ถูกซ่อน ใช้ URL นี้ไม่ได้ -->
            <div class="bg-red-50 border border-red-200 rounded-xl p-4 flex gap-3">
              <span class="text-2xl shrink-0">🔒</span>
              <div>
                <p class="text-sm font-semibold text-red-700">API Key ถูกซ่อนแล้ว — ดึงคืนไม่ได้</p>
                <p class="text-xs text-red-500 mt-1">
                  ระบบไม่เก็บ key จริงไว้เพื่อความปลอดภัย<br/>
                  หากทำ URL หาย ต้อง<strong>ลบ key นี้แล้วสร้างใหม่</strong>
                </p>
              </div>
            </div>

            <!-- Endpoint base (ไม่มี key) -->
            <div>
              <label class="text-xs font-semibold text-gray-500 mb-1 block">BASE ENDPOINT</label>
              <div class="flex gap-2">
                <code class="flex-1 bg-gray-50 border border-gray-200 text-gray-500 px-3 py-2.5 rounded-xl text-xs break-all">
                  {{ RPC_URL }}?p_api_key=<span class="text-red-400 font-bold">YOUR_KEY</span>&amp;apikey=...
                </code>
              </div>
              <p class="text-[11px] text-gray-400 mt-1">⚠️ URL นี้คัดลอกไปใช้งานไม่ได้ — ต้องมี API Key จริง</p>
            </div>

            <!-- Info -->
            <div class="text-xs text-gray-600 bg-gray-50 rounded-xl p-3 space-y-1">
              <p><strong>Resource:</strong> {{ RESOURCES.find(r => r.key === urlView.resource)?.label || urlView.resource }}</p>
              <p><strong>Fields:</strong> {{ urlView.fields.join(', ') }}</p>
            </div>

            <div class="flex gap-3">
              <button @click="deleteFromUrl()"
                class="flex-1 py-2 bg-red-50 border border-red-200 text-red-600 rounded-xl text-sm hover:bg-red-100 transition-colors">
                🗑️ ลบแล้วสร้างใหม่
              </button>
              <button @click="urlView = null"
                class="flex-1 py-2 border border-gray-200 rounded-xl text-sm text-gray-600 hover:bg-gray-50">
                ปิด
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
            <h3 class="font-bold text-red-700">🗑️ ลบ API Key</h3>
            <p class="text-sm text-gray-600">ยืนยันลบ <strong>{{ deleteTarget.name }}</strong>?<br>
              <span class="text-xs text-red-500">ลิงก์ที่ใช้ key นี้จะใช้งานไม่ได้ทันที</span></p>
            <div class="flex gap-3">
              <button @click="deleteKey" :disabled="deleting"
                class="flex-1 bg-red-600 hover:bg-red-700 text-white py-2 rounded-xl text-sm font-medium disabled:opacity-50">
                {{ deleting ? 'กำลังลบ...' : 'ยืนยันลบ' }}
              </button>
              <button @click="deleteTarget = null"
                class="flex-1 border border-gray-200 text-gray-600 py-2 rounded-xl text-sm hover:bg-gray-50">ยกเลิก</button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

  </AdminLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'
import AdminLayout from '../../layouts/AdminLayout.vue'

// ─── Config ──────────────────────────────────────────────────────────────────
// ใช้ Postgres RPC — ไม่ต้อง deploy Edge Function
const SUPABASE_URL  = import.meta.env.VITE_SUPABASE_URL  || ''
const SUPABASE_ANON = import.meta.env.VITE_SUPABASE_ANON_KEY || ''
const RPC_URL = `${SUPABASE_URL}/rest/v1/rpc/get_api_data`

const RESOURCES = [
  { key: 'teachers', label: 'ครูและบุคลากร', icon: '👨‍🏫', desc: 'teacher_profiles' },
  { key: 'students', label: 'นักเรียน',        icon: '🎓', desc: 'students' },
]

const FIELDS = {
  teachers: [
    { key: 'prefix',                 label: 'คำนำหน้า',           category: 'ข้อมูลส่วนตัว',  safe: true  },
    { key: 'first_name',             label: 'ชื่อ',               category: 'ข้อมูลส่วนตัว',  safe: true  },
    { key: 'last_name',              label: 'นามสกุล',             category: 'ข้อมูลส่วนตัว',  safe: true  },
    { key: 'email',                  label: 'อีเมล (บัญชีผู้ใช้)', category: 'ข้อมูลส่วนตัว',  safe: false },
    { key: 'profile_image_url',      label: 'รูปโปรไฟล์ (URL)',   category: 'ข้อมูลส่วนตัว',  safe: true  },
    { key: 'website_url',            label: 'เว็บไซต์/ผลงาน',     category: 'ข้อมูลส่วนตัว',  safe: true  },
    { key: 'phone',                  label: 'เบอร์โทรศัพท์',      category: 'ข้อมูลส่วนตัว',  safe: false },
    { key: 'position',               label: 'ตำแหน่ง',            category: 'ข้อมูลราชการ',   safe: true  },
    { key: 'academic_standing',      label: 'วิทยฐานะ',            category: 'ข้อมูลราชการ',   safe: true  },
    { key: 'subject_group',          label: 'กลุ่มสาระ',           category: 'ข้อมูลราชการ',   safe: true  },
    { key: 'subjects_taught',        label: 'วิชาที่สอน',          category: 'ข้อมูลราชการ',   safe: true  },
    { key: 'employee_id',            label: 'รหัสพนักงาน',         category: 'ข้อมูลราชการ',   safe: true  },
    { key: 'education_level',        label: 'วุฒิการศึกษา',        category: 'การศึกษา',        safe: true  },
    { key: 'education_major',        label: 'สาขาวิชา',            category: 'การศึกษา',        safe: true  },
    { key: 'education_institution',  label: 'สถาบัน',              category: 'การศึกษา',        safe: true  },
    { key: 'id_card',                label: 'เลขบัตรประชาชน',      category: 'ข้อมูลส่วนตัว',  safe: false },
  ],
  students: [
    { key: 'student_code',  label: 'รหัสนักเรียน',       category: 'ข้อมูลนักเรียน', safe: true  },
    { key: 'prefix',        label: 'คำนำหน้า',           category: 'ข้อมูลส่วนตัว',  safe: true  },
    { key: 'first_name',    label: 'ชื่อ',               category: 'ข้อมูลส่วนตัว',  safe: true  },
    { key: 'last_name',     label: 'นามสกุล',             category: 'ข้อมูลส่วนตัว',  safe: true  },
    { key: 'grade_level',   label: 'ระดับชั้น',           category: 'ข้อมูลนักเรียน', safe: true  },
    { key: 'room',          label: 'ห้อง',               category: 'ข้อมูลนักเรียน', safe: true  },
    { key: 'status',        label: 'สถานะ',              category: 'ข้อมูลนักเรียน', safe: true  },
    { key: 'national_id',   label: 'เลขบัตรประชาชน',     category: 'ข้อมูลส่วนตัว',  safe: false },
  ],
}

// ─── State ───────────────────────────────────────────────────────────────────
const keys       = ref([])
const loading    = ref(false)
const showCreate = ref(false)
const creating   = ref(false)
const createError= ref('')
const result     = ref(null)
const urlView    = ref(null)
const deleteTarget = ref(null)
const deleting   = ref(false)
const copied     = ref('')

const form = ref({ name: '', resource: 'teachers', fields: [], expires_at: '' })

const todayStr = new Date().toISOString().split('T')[0]

// ─── Computed ─────────────────────────────────────────────────────────────────
const currentFields  = computed(() => FIELDS[form.value.resource] || [])
const fieldCategories = computed(() => [...new Set(currentFields.value.map(f => f.category))])

// ─── Helpers ─────────────────────────────────────────────────────────────────
function resourceBadge(r) {
  return r === 'teachers' ? 'bg-blue-100 text-blue-700' : 'bg-green-100 text-green-700'
}

function formatDate(d) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('th-TH', { year: 'numeric', month: 'short', day: 'numeric' })
}

function selectSafe() {
  form.value.fields = currentFields.value.filter(f => f.safe).map(f => f.key)
}

function buildUrl(apiKey) {
  // GET endpoint — ส่ง apikey ใน query string ด้วยเพื่อให้เรียกจาก browser/Sheets ได้เลย
  return `${RPC_URL}?p_api_key=${apiKey}&apikey=${SUPABASE_ANON}`
}

function maskKey(k) {
  return k.slice(0, 8) + '••••••••••••••••' + k.slice(-4)
}

async function copy(text, type = 'url') {
  await navigator.clipboard.writeText(text)
  copied.value = type === text ? 'key' : (text === urlView.value?.url ? 'url-view' : 'url')
  // แยก type จาก context
  if (result.value && text === result.value.key) copied.value = 'key'
  else if (result.value && text === result.value.url) copied.value = 'url'
  else copied.value = 'url-view'
  setTimeout(() => (copied.value = ''), 2000)
}

// ─── Data ────────────────────────────────────────────────────────────────────
async function fetchKeys() {
  loading.value = true
  const { data } = await supabase
    .from('api_keys')
    .select('id, name, resource, fields, is_active, expires_at, last_used_at, request_count, created_at')
    .order('created_at', { ascending: false })
  keys.value  = data || []
  loading.value = false
}

// ─── Actions ─────────────────────────────────────────────────────────────────
function openCreate() {
  form.value   = { name: '', resource: 'teachers', fields: [], expires_at: '' }
  createError.value = ''
  showCreate.value  = true
  selectSafe()
}

async function createKey() {
  if (!form.value.name.trim() || !form.value.fields.length) return
  creating.value   = true
  createError.value = ''

  // Generate random key: prefix + UUID
  const raw = `sk_${crypto.randomUUID().replace(/-/g, '')}`

  const payload = {
    name:        form.value.name.trim(),
    api_key:     raw,
    resource:    form.value.resource,
    fields:      form.value.fields,
    expires_at:  form.value.expires_at || null,
    is_active:   true,
    request_count: 0,
  }

  const { error } = await supabase.from('api_keys').insert(payload)
  creating.value = false

  if (error) {
    createError.value = error.message
    return
  }

  showCreate.value = false
  result.value = {
    key:      raw,
    url:      buildUrl(raw),
    resource: form.value.resource,
    fields:   [...form.value.fields],
  }
}

async function toggleActive(k) {
  const { error } = await supabase
    .from('api_keys')
    .update({ is_active: !k.is_active })
    .eq('id', k.id)
  if (!error) k.is_active = !k.is_active
}

function showUrl(k) {
  urlView.value = {
    name:     k.name,
    resource: k.resource,
    fields:   k.fields,
    _key:     k,   // เก็บ ref เผื่อกด "ลบแล้วสร้างใหม่"
  }
}

function deleteFromUrl() {
  const k = urlView.value._key
  urlView.value = null
  confirmDelete(k)
}

function confirmDelete(k) {
  deleteTarget.value = k
}

async function deleteKey() {
  if (!deleteTarget.value) return
  deleting.value = true
  const { error } = await supabase.from('api_keys').delete().eq('id', deleteTarget.value.id)
  deleting.value = false
  if (!error) {
    keys.value = keys.value.filter(k => k.id !== deleteTarget.value.id)
    deleteTarget.value = null
  }
}

onMounted(fetchKeys)
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to       { opacity: 0; }
</style>
