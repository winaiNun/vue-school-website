<template>
  <AdminLayout>
    <div class="space-y-5">

      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 class="text-lg font-bold text-gray-900">จัดการระบบงาน</h2>
          <p class="text-xs text-gray-400 mt-0.5">ไอคอนที่แสดงในกริดหน้าแรก และเมนูระบบงานบน Navbar</p>
        </div>
        <button @click="openAdd" class="btn-primary flex items-center gap-2 self-start sm:self-auto">
          + เพิ่มระบบงาน
        </button>
      </div>

      <!-- Table -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div v-if="loading" class="text-center py-12">
          <div class="w-8 h-8 border-2 border-gray-200 border-t-blue-500 rounded-full animate-spin mx-auto"></div>
        </div>
        <div v-else-if="!items.length" class="text-center py-12 text-gray-300">
          <p class="text-4xl mb-2">🔗</p>
          <p class="text-sm">ยังไม่มีระบบงาน</p>
        </div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50 text-xs text-gray-500 uppercase tracking-wide">
            <tr>
              <th class="text-left px-5 py-3">ระบบงาน</th>
              <th class="text-left px-4 py-3 hidden md:table-cell">URL</th>
              <th class="text-center px-4 py-3 hidden sm:table-cell">หน้าแรก</th>
              <th class="text-center px-4 py-3">Navbar</th>
              <th class="text-center px-4 py-3">เรียง</th>
              <th class="text-right px-5 py-3">จัดการ</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="(item, idx) in items" :key="item.id" class="hover:bg-gray-50/60 transition-colors">
              <!-- Icon + Label -->
              <td class="px-5 py-3">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-xl flex items-center justify-center text-xl flex-shrink-0 shadow-sm"
                    :style="{ background: item.icon_bg || '#3b82f6' }">
                    {{ item.icon || '🔗' }}
                  </div>
                  <div>
                    <p class="font-semibold text-gray-800">{{ item.label }}</p>
                    <p v-if="item.description" class="text-xs text-gray-400">{{ item.description }}</p>
                  </div>
                </div>
              </td>
              <!-- URL -->
              <td class="px-4 py-3 hidden md:table-cell">
                <span class="text-xs font-mono text-gray-400 truncate block max-w-[180px]">{{ item.url }}</span>
              </td>
              <!-- show_in_grid -->
              <td class="px-4 py-3 text-center hidden sm:table-cell">
                <button @click="toggleGrid(item)"
                  :class="['text-xs px-2.5 py-1 rounded-full font-semibold transition-colors',
                    item.show_in_grid ? 'bg-blue-100 text-blue-700 hover:bg-blue-200' : 'bg-gray-100 text-gray-400 hover:bg-gray-200']">
                  {{ item.show_in_grid ? '✅ แสดง' : '— ซ่อน' }}
                </button>
              </td>
              <!-- is_active (navbar) -->
              <td class="px-4 py-3 text-center">
                <button @click="toggleActive(item)"
                  :class="['text-xs px-2.5 py-1 rounded-full font-semibold transition-colors',
                    item.is_active ? 'bg-green-100 text-green-700 hover:bg-green-200' : 'bg-gray-100 text-gray-400 hover:bg-gray-200']">
                  {{ item.is_active ? '✅ แสดง' : '— ซ่อน' }}
                </button>
              </td>
              <!-- Sort -->
              <td class="px-4 py-3 text-center">
                <div class="flex items-center justify-center gap-0.5">
                  <button @click="moveUp(idx)" :disabled="idx === 0"
                    class="w-6 h-6 flex items-center justify-center text-gray-300 hover:text-gray-600 disabled:opacity-20 text-xs">▲</button>
                  <button @click="moveDown(idx)" :disabled="idx === items.length - 1"
                    class="w-6 h-6 flex items-center justify-center text-gray-300 hover:text-gray-600 disabled:opacity-20 text-xs">▼</button>
                </div>
              </td>
              <!-- Actions -->
              <td class="px-5 py-3 text-right">
                <div class="flex items-center justify-end gap-2">
                  <button @click="openEdit(item)" class="text-xs text-gray-500 hover:text-gray-700 px-2 py-1 rounded hover:bg-gray-100 transition-colors">แก้ไข</button>
                  <button @click="confirmTarget = item" class="text-xs text-red-400 hover:text-red-600 px-2 py-1 rounded hover:bg-red-50 transition-colors">ลบ</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ── Add/Edit Modal ── -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="showModal" class="fixed inset-0 bg-black/40 z-50 flex items-start justify-center p-4 overflow-y-auto"
          @click.self="showModal = false">
          <div class="bg-white rounded-3xl shadow-2xl w-full max-w-xl my-6">
            <div class="flex items-center justify-between px-6 pt-6 pb-4 border-b border-gray-100">
              <h3 class="font-bold text-gray-900 text-base">{{ editId ? 'แก้ไขระบบงาน' : 'เพิ่มระบบงาน' }}</h3>
              <button @click="showModal = false" class="text-gray-300 hover:text-gray-500">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>

            <div class="px-6 py-5 space-y-5">

              <!-- Preview + Icon Config -->
              <div class="flex items-center gap-5">
                <!-- Preview icon -->
                <div class="flex-shrink-0 text-center">
                  <div class="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl shadow-lg mx-auto"
                    :style="{ background: form.icon_bg }">
                    {{ form.icon || '🔗' }}
                  </div>
                  <p class="text-xs text-gray-400 mt-1.5">ตัวอย่าง</p>
                </div>

                <div class="flex-1 space-y-3">
                  <!-- Emoji picker -->
                  <div>
                    <label class="label">ไอคอน (Emoji)</label>
                    <!-- กริดตัวเลือกสำเร็จรูป -->
                    <div class="flex flex-wrap gap-1.5 mb-2">
                      <button v-for="e in EMOJI_OPTIONS" :key="e" @click="form.icon = e"
                        :class="['w-8 h-8 rounded-lg text-base flex items-center justify-center border-2 transition-all',
                          form.icon === e ? 'border-blue-500 bg-blue-50 scale-110' : 'border-gray-200 hover:border-gray-300']">
                        {{ e }}
                      </button>
                    </div>
                    <!-- พิมพ์/วาง Emoji เองได้ -->
                    <div class="flex items-center gap-2 mt-1">
                      <span class="text-xs text-gray-400 whitespace-nowrap">หรือพิมพ์เอง:</span>
                      <input
                        v-model="form.icon"
                        type="text"
                        maxlength="8"
                        placeholder="วาง emoji ที่นี่ 🏅"
                        class="flex-1 border border-gray-200 rounded-lg px-3 py-1.5 text-lg text-center focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent"
                        @input="e => { form.icon = [...(e.target.value||'')].slice(0,2).join('') }"
                      />
                      <button v-if="form.icon" @click="form.icon='🔗'"
                        class="text-xs text-gray-400 hover:text-red-400 transition px-1.5 py-1 rounded hover:bg-red-50"
                        title="รีเซ็ต">✕</button>
                    </div>
                    <p class="text-[10px] text-gray-400 mt-1 ml-1">
                      คัดลอก emoji จาก
                      <a href="https://emojipedia.org" target="_blank" class="text-blue-400 hover:underline">emojipedia.org</a>
                      หรือ Windows: <kbd class="text-[9px] bg-gray-100 px-1 py-0.5 rounded border">Win+.</kbd>
                      Mac: <kbd class="text-[9px] bg-gray-100 px-1 py-0.5 rounded border">⌘+⌃+Space</kbd>
                    </p>
                  </div>

                  <!-- Color picker -->
                  <div>
                    <label class="label">สีพื้นหลังไอคอน</label>
                    <div class="flex flex-wrap gap-1.5 items-center">
                      <button v-for="c in COLOR_PRESETS" :key="c" @click="form.icon_bg = c"
                        :class="['w-7 h-7 rounded-lg transition-all border-2',
                          form.icon_bg === c ? 'border-gray-700 scale-110' : 'border-transparent hover:scale-105']"
                        :style="{ background: c }">
                      </button>
                      <!-- Custom color -->
                      <label class="w-7 h-7 rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center cursor-pointer hover:border-gray-400 overflow-hidden" title="เลือกสีเอง">
                        <input type="color" v-model="form.icon_bg" class="opacity-0 absolute w-0 h-0" />
                        <span class="text-xs text-gray-400">+</span>
                      </label>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Label + Desc -->
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="label">ชื่อระบบงาน <span class="text-red-500">*</span></label>
                  <input v-model="form.label" type="text" class="input-field" placeholder="เช่น งานทะเบียน" />
                </div>
                <div>
                  <label class="label">คำอธิบาย</label>
                  <input v-model="form.description" type="text" class="input-field" placeholder="เช่น ข้อมูลนักเรียน" />
                </div>
              </div>

              <!-- Route Picker -->
              <div>
                <label class="label">เลือกลิงก์</label>
                <!-- Known internal routes -->
                <div class="border border-gray-200 rounded-xl overflow-hidden mb-2">
                  <div class="bg-gray-50 px-3 py-1.5 text-xs font-semibold text-gray-500 border-b border-gray-200">
                    📌 หน้าภายในระบบ — คลิกเพื่อเลือก
                  </div>
                  <div class="grid grid-cols-2 sm:grid-cols-3 gap-0.5 p-2 max-h-40 overflow-y-auto">
                    <button v-for="r in KNOWN_ROUTES" :key="r.path"
                      @click="pickRoute(r)"
                      :class="['flex items-center gap-2 px-2.5 py-1.5 rounded-lg text-xs text-left transition-colors',
                        form.url === r.path ? 'bg-blue-100 text-blue-700 font-semibold' : 'text-gray-600 hover:bg-gray-100']">
                      <span>{{ r.icon }}</span>
                      <span class="truncate">{{ r.label }}</span>
                    </button>
                  </div>
                </div>
                <!-- Manual URL input -->
                <input v-model="form.url" type="text" class="input-field font-mono text-xs"
                  placeholder="หรือพิมพ์ URL เอง เช่น https://... หรือ /path" />
              </div>

              <!-- Toggles -->
              <div class="grid grid-cols-2 gap-3">
                <div class="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
                  <div>
                    <p class="text-xs font-semibold text-gray-700">กริดหน้าแรก</p>
                    <p class="text-[10px] text-gray-400">แสดงไอคอนในหน้าหลัก</p>
                  </div>
                  <label class="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" v-model="form.show_in_grid" class="sr-only peer" />
                    <div class="w-9 h-5 bg-gray-200 rounded-full peer peer-checked:bg-blue-500 transition-colors after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:after:translate-x-4"></div>
                  </label>
                </div>
                <div class="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
                  <div>
                    <p class="text-xs font-semibold text-gray-700">เมนู Navbar</p>
                    <p class="text-[10px] text-gray-400">แสดงใน dropdown บน</p>
                  </div>
                  <label class="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" v-model="form.is_active" class="sr-only peer" />
                    <div class="w-9 h-5 bg-gray-200 rounded-full peer peer-checked:bg-green-500 transition-colors after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:after:translate-x-4"></div>
                  </label>
                </div>
              </div>

              <!-- External toggle -->
              <div class="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
                <div>
                  <p class="text-xs font-semibold text-gray-700">เปิดแท็บใหม่</p>
                  <p class="text-[10px] text-gray-400">สำหรับลิงก์ภายนอก (https://...)</p>
                </div>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input type="checkbox" v-model="form.is_external" class="sr-only peer" />
                  <div class="w-9 h-5 bg-gray-200 rounded-full peer peer-checked:bg-orange-500 transition-colors after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:after:translate-x-4"></div>
                </label>
              </div>

              <p v-if="formError" class="text-xs text-red-500">{{ formError }}</p>
            </div>

            <div class="flex gap-3 px-6 pb-6">
              <button @click="showModal = false" class="btn-secondary flex-1">ยกเลิก</button>
              <button @click="saveItem" :disabled="saving"
                class="btn-primary flex-1 flex items-center justify-center gap-2">
                <svg v-if="saving" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
                </svg>
                {{ saving ? 'กำลังบันทึก...' : editId ? 'บันทึก' : 'เพิ่มระบบงาน' }}
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- Confirm Delete -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="confirmTarget" class="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4"
          @click.self="confirmTarget = null">
          <div class="bg-white rounded-3xl shadow-2xl w-full max-w-sm p-6 text-center">
            <p class="text-3xl mb-3">🗑️</p>
            <h3 class="font-bold text-gray-900 mb-1">ยืนยันการลบ</h3>
            <p class="text-sm text-gray-500 mb-5">ลบ "<span class="font-semibold text-gray-700">{{ confirmTarget.label }}</span>" ใช่ไหม?</p>
            <div class="flex gap-3">
              <button @click="confirmTarget = null" class="flex-1 btn-secondary">ยกเลิก</button>
              <button @click="confirmDelete" class="flex-1 py-2.5 bg-red-600 hover:bg-red-700 text-white rounded-xl text-sm font-semibold transition-colors">ลบ</button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- Toast -->
    <Teleport to="body">
      <Transition name="toast">
        <div v-if="toast" class="fixed top-6 left-1/2 -translate-x-1/2 z-[9999] bg-gray-900 text-white px-6 py-3 rounded-2xl shadow-2xl text-sm font-medium">
          {{ toast }}
        </div>
      </Transition>
    </Teleport>
  </AdminLayout>
</template>

<script setup>
import { ref } from 'vue'
import AdminLayout from '../../layouts/AdminLayout.vue'
import { supabase } from '../../lib/supabase'

// ── Constants ─────────────────────────────────────────────────
const EMOJI_OPTIONS = [
  '🔗','📋','📊','📜','📂','💰','🏫','📅','👥','🎓','⚙️','📱',
  '🖥️','📝','🔐','📣','🏆','🔬','🎨','📸','🗂️','🧾','📞','🌐',
]

const COLOR_PRESETS = [
  '#3b82f6','#10b981','#f59e0b','#ef4444','#8b5cf6',
  '#f97316','#ec4899','#06b6d4','#84cc16','#6366f1',
  '#14b8a6','#a855f7','#0ea5e9','#d97706','#dc2626',
]

const KNOWN_ROUTES = [
  { path: '/',              label: 'หน้าแรก',              icon: '🏠' },
  { path: '/news',          label: 'ข่าวประชาสัมพันธ์',    icon: '📰' },
  { path: '/activities',    label: 'ภาพกิจกรรม',           icon: '🖼️' },
  { path: '/media',         label: 'คลังสื่อ',              icon: '📚' },
  { path: '/calendar',      label: 'ปฏิทินวิชาการ',        icon: '📅' },
  { path: '/documents',     label: 'เอกสาร/ดาวน์โหลด',    icon: '📂' },
  { path: '/personnel',     label: 'บุคลากร',              icon: '👨‍🏫' },
  { path: '/students-info', label: 'ข้อมูลนักเรียน',      icon: '🎓' },
  { path: '/wpa-public',    label: 'วPA ครู',              icon: '📄' },
  { path: '/login',         label: 'เข้าสู่ระบบ',          icon: '🔐' },
  { path: '/dashboard',     label: 'หน้าหลักครู',          icon: '👤' },
  { path: '/wpa',           label: 'วPA ของฉัน',           icon: '📝' },
]

// ── State ─────────────────────────────────────────────────────
const items         = ref([])
const loading       = ref(true)
const showModal     = ref(false)
const saving        = ref(false)
const editId        = ref(null)
const confirmTarget = ref(null)
const toast         = ref('')
const formError     = ref('')
let toastTimer      = null

const BLANK = { label: '', description: '', url: '', icon: '🔗', icon_bg: '#3b82f6', show_in_grid: true, is_active: true, is_external: false }
const form = ref({ ...BLANK })

// ── Helpers ───────────────────────────────────────────────────
function showToast(msg) {
  toast.value = msg
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => { toast.value = '' }, 2500)
}

function pickRoute(r) {
  form.value.url = r.path
  form.value.is_external = false
  if (!form.value.label) form.value.label = r.label
  if (!form.value.icon || form.value.icon === '🔗') form.value.icon = r.icon
}

// ── CRUD ──────────────────────────────────────────────────────
async function fetchItems() {
  loading.value = true
  const { data } = await supabase.from('nav_systems').select('*').order('sort_order')
  items.value = data || []
  loading.value = false
}

function openAdd() {
  editId.value = null
  form.value = { ...BLANK }
  formError.value = ''
  showModal.value = true
}

function openEdit(item) {
  editId.value = item.id
  form.value = {
    label:        item.label,
    description: item.description || '',
    url:          item.url,
    icon:         item.icon || '🔗',
    icon_bg:      item.icon_bg || '#3b82f6',
    show_in_grid: item.show_in_grid ?? true,
    is_active:    item.is_active ?? true,
    is_external:  item.is_external ?? false,
  }
  formError.value = ''
  showModal.value = true
}

async function saveItem() {
  formError.value = ''
  if (!form.value.label.trim()) { formError.value = 'กรุณาใส่ชื่อระบบงาน'; return }
  if (!form.value.url.trim())   { formError.value = 'กรุณาเลือกหรือใส่ลิงก์'; return }

  saving.value = true
  const payload = {
    label:        form.value.label.trim(),
    description: form.value.description?.trim() || null,
    url:          form.value.url.trim(),
    icon:         form.value.icon,
    icon_bg:      form.value.icon_bg,
    show_in_grid: form.value.show_in_grid,
    is_active:    form.value.is_active,
    is_external:  form.value.is_external,
  }

  if (editId.value) {
    await supabase.from('nav_systems').update(payload).eq('id', editId.value)
    showToast('✅ บันทึกแล้ว')
  } else {
    await supabase.from('nav_systems').insert({ ...payload, sort_order: items.value.length })
    showToast('✅ เพิ่มระบบงานแล้ว')
  }

  saving.value = false
  showModal.value = false
  fetchItems()
}

async function toggleActive(item) {
  await supabase.from('nav_systems').update({ is_active: !item.is_active }).eq('id', item.id)
  item.is_active = !item.is_active
}

async function toggleGrid(item) {
  await supabase.from('nav_systems').update({ show_in_grid: !item.show_in_grid }).eq('id', item.id)
  item.show_in_grid = !item.show_in_grid
}

async function confirmDelete() {
  await supabase.from('nav_systems').delete().eq('id', confirmTarget.value.id)
  items.value = items.value.filter(i => i.id !== confirmTarget.value.id)
  confirmTarget.value = null
  showToast('🗑️ ลบแล้ว')
}

async function moveUp(idx) {
  if (idx === 0) return
  const a = items.value[idx], b = items.value[idx - 1]
  await Promise.all([
    supabase.from('nav_systems').update({ sort_order: b.sort_order }).eq('id', a.id),
    supabase.from('nav_systems').update({ sort_order: a.sort_order }).eq('id', b.id),
  ])
  fetchItems()
}

async function moveDown(idx) {
  if (idx === items.value.length - 1) return
  const a = items.value[idx], b = items.value[idx + 1]
  await Promise.all([
    supabase.from('nav_systems').update({ sort_order: b.sort_order }).eq('id', a.id),
    supabase.from('nav_systems').update({ sort_order: a.sort_order }).eq('id', b.id),
  ])
  fetchItems()
}

fetchItems()
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translate(-50%, -12px); }
</style>
