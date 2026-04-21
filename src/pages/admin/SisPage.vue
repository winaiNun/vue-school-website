<template>
  <AdminLayout>
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h2 class="text-xl font-bold text-gray-900">📊 สถิติ DMC</h2>
        <p class="text-sm text-gray-500 mt-0.5">
          เปรียบเทียบจำนวนนักเรียนแต่ละปี · ไม่กระทบทะเบียนนักเรียนปัจจุบัน
        </p>
      </div>
      <router-link to="/admin/sis/import"
        class="btn-primary flex items-center gap-2 px-4 py-2">
        <span>📥</span> นำเข้าสถิติใหม่
      </router-link>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="py-20 text-center text-gray-400 animate-pulse">กำลังโหลด...</div>

    <!-- Empty state -->
    <div v-else-if="!sessions.length" class="bg-white rounded-2xl shadow-sm p-16 text-center">
      <div class="text-5xl mb-4">📊</div>
      <h3 class="font-bold text-gray-700 mb-2">ยังไม่มีข้อมูลสถิติ DMC</h3>
      <p class="text-sm text-gray-400 mb-6">อัปโหลดไฟล์ DMC แต่ละปี/ภาคเรียน เพื่อเปรียบเทียบแนวโน้ม</p>
      <router-link to="/admin/sis/import" class="btn-primary px-6 py-2.5">📥 นำเข้าสถิติแรก</router-link>
    </div>

    <template v-else>

      <!-- Summary cards (latest session) -->
      <div class="grid grid-cols-3 gap-4 mb-6">
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
          <p class="text-xs text-gray-400 mb-1">รวมทั้งหมด (ล่าสุด)</p>
          <p class="text-3xl font-black text-blue-600">{{ latestStats?.total?.toLocaleString() ?? '-' }}</p>
        </div>
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
          <p class="text-xs text-gray-400 mb-1">👦 ชาย</p>
          <p class="text-3xl font-black text-sky-500">{{ latestStats?.male?.toLocaleString() ?? '-' }}</p>
        </div>
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
          <p class="text-xs text-gray-400 mb-1">👧 หญิง</p>
          <p class="text-3xl font-black text-pink-500">{{ latestStats?.female?.toLocaleString() ?? '-' }}</p>
        </div>
      </div>

      <!-- Tabs -->
      <div class="flex gap-1 bg-gray-100 p-1 rounded-xl w-fit mb-5">
        <button v-for="t in tabs" :key="t.key" @click="activeTab=t.key"
          :class="['px-5 py-2 rounded-lg text-sm font-medium transition',
            activeTab===t.key ? 'bg-white shadow text-blue-700' : 'text-gray-500 hover:text-gray-700']">
          {{ t.icon }} {{ t.label }}
        </button>
      </div>

      <!-- ═══ Tab 1: กราฟเปรียบเทียบ ═══ -->
      <template v-if="activeTab==='chart'">

        <!-- Vertical Bar + Trend Line Chart -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 mb-5">
          <div class="flex items-center justify-between mb-4">
            <h3 class="font-semibold text-gray-700 text-sm">จำนวนนักเรียนรวมแต่ละปี</h3>
            <div class="flex items-center gap-4 text-xs text-gray-500">
              <span class="flex items-center gap-1.5">
                <span class="w-8 h-3 rounded inline-block bg-gradient-to-r from-blue-400 to-blue-600"></span>รวม
              </span>
              <span class="flex items-center gap-1.5">
                <svg width="24" height="8"><line x1="0" y1="4" x2="24" y2="4" stroke="#f97316" stroke-width="2.5" stroke-linecap="round"/><circle cx="12" cy="4" r="3" fill="white" stroke="#f97316" stroke-width="2"/></svg>
                แนวโน้ม
              </span>
            </div>
          </div>

          <div class="w-full overflow-x-auto" @mouseleave="hoveredChartBar=null">
            <svg :viewBox="`0 0 ${C.W} ${C.H}`" class="w-full" style="min-width:320px;overflow:visible">
              <defs>
                <linearGradient id="sisBarGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stop-color="#60a5fa"/>
                  <stop offset="100%" stop-color="#2563eb"/>
                </linearGradient>
                <linearGradient id="sisBarHov" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stop-color="#93c5fd"/>
                  <stop offset="100%" stop-color="#3b82f6"/>
                </linearGradient>
              </defs>

              <!-- Y-axis grid + labels -->
              <g v-for="tick in chartYTicks" :key="tick.v">
                <line :x1="C.PL" :y1="tick.y" :x2="C.W-C.PR" :y2="tick.y"
                  :stroke="tick.v===0?'#cbd5e1':'#f1f5f9'" :stroke-width="tick.v===0?1.5:1"/>
                <text :x="C.PL-6" :y="tick.y+4" text-anchor="end" font-size="10" fill="#94a3b8">
                  {{ tick.label }}
                </text>
              </g>

              <!-- Bars -->
              <g v-for="bar in chartBars" :key="bar.s.id"
                 @mouseenter="hoveredChartBar=bar"
                 @mouseleave="hoveredChartBar=null"
                 style="cursor:pointer">
                <rect :x="bar.x" :y="bar.y" :width="bar.w" :height="bar.h" rx="5"
                  :fill="hoveredChartBar?.s.id===bar.s.id ? 'url(#sisBarHov)' : 'url(#sisBarGrad)'"
                  :opacity="hoveredChartBar && hoveredChartBar.s.id!==bar.s.id ? 0.55 : 1"
                  class="transition-all duration-150"/>
                <!-- Value on top of bar (if bar tall enough) -->
                <text v-if="bar.h > 20" :x="bar.cx" :y="bar.y-5"
                  text-anchor="middle" font-size="10" font-weight="700" fill="#3b82f6">
                  {{ bar.val >= 1000 ? `${(bar.val/1000).toFixed(1)}k` : bar.val }}
                </text>
                <!-- X label: year -->
                <text :x="bar.cx" :y="C.H-C.PB+16" text-anchor="middle" font-size="10" fill="#475569" font-weight="600">
                  {{ bar.s.academic_year }}
                </text>
                <!-- X label: checkpoint -->
                <text :x="bar.cx" :y="C.H-C.PB+28" text-anchor="middle" font-size="9" fill="#94a3b8">
                  ช่วง {{ bar.s.checkpoint }}
                </text>
              </g>

              <!-- Trend line -->
              <path v-if="trendPath" :d="trendPath"
                fill="none" stroke="#f97316" stroke-width="2.5"
                stroke-linecap="round" stroke-linejoin="round"/>

              <!-- Trend dots -->
              <g v-for="bar in chartBars" :key="'dot-'+bar.s.id">
                <circle :cx="bar.cx" :cy="bar.ty" r="5" fill="white" stroke="#f97316" stroke-width="2.5"/>
              </g>

              <!-- Tooltip -->
              <g v-if="hoveredChartBar"
                :transform="`translate(${Math.min(Math.max(hoveredChartBar.cx, C.PL+48), C.W-C.PR-48)},${Math.max(hoveredChartBar.y-14, C.PT+8)})`">
                <rect x="-48" y="-58" width="96" height="52" rx="8" fill="#1e293b" opacity="0.95"/>
                <text x="0" y="-40" text-anchor="middle" font-size="9" fill="#94a3b8">
                  {{ hoveredChartBar.s.checkpoint_label || `ช่วง ${hoveredChartBar.s.checkpoint}` }}
                </text>
                <text x="0" y="-24" text-anchor="middle" font-size="9" fill="#94a3b8">
                  ปีการศึกษา {{ hoveredChartBar.s.academic_year }}
                </text>
                <text x="0" y="-8" text-anchor="middle" font-size="16" font-weight="700" fill="white">
                  {{ hoveredChartBar.val.toLocaleString() }} คน
                </text>
                <polygon points="-5,0 5,0 0,7" fill="#1e293b" opacity="0.95"/>
              </g>

              <!-- Axes -->
              <line :x1="C.PL" :y1="C.PT" :x2="C.PL" :y2="C.H-C.PB" stroke="#e2e8f0" stroke-width="1.5"/>
              <line :x1="C.PL" :y1="C.H-C.PB" :x2="C.W-C.PR" :y2="C.H-C.PB" stroke="#e2e8f0" stroke-width="1.5"/>
            </svg>
          </div>
        </div>

        <!-- ตารางสรุปแต่ละรอบ (เรียงเก่า→ใหม่ = ซ้าย→ขวาเหมือนกราฟ) -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-gray-50 text-gray-500 text-xs uppercase">
              <tr>
                <th class="py-2.5 px-4 text-left">รอบข้อมูล</th>
                <th class="py-2.5 px-4 text-center">ปี</th>
                <th class="py-2.5 px-4 text-center">รวม</th>
                <th class="py-2.5 px-4 text-center">👦 ชาย</th>
                <th class="py-2.5 px-4 text-center">👧 หญิง</th>
                <th class="py-2.5 px-4 text-center hidden sm:table-cell">เปลี่ยน</th>
                <th class="py-2.5 px-4 text-left hidden md:table-cell">วันที่นำเข้า</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(s, i) in chartSessions" :key="'t'+s.id" class="border-b border-gray-50 hover:bg-gray-50/50">
                <td class="py-2.5 px-4">
                  <span class="text-xs bg-purple-100 text-purple-700 px-2 py-0.5 rounded-full font-medium">
                    ช่วง {{ s.checkpoint }}
                  </span>
                  <span class="ml-2 text-gray-700 text-xs">{{ s.checkpoint_label }}</span>
                </td>
                <td class="py-2.5 px-4 text-center font-bold text-blue-700">{{ s.academic_year }}</td>
                <td class="py-2.5 px-4 text-center font-bold">{{ sj(s).total?.toLocaleString() ?? '-' }}</td>
                <td class="py-2.5 px-4 text-center text-sky-600">{{ sj(s).male?.toLocaleString() ?? '-' }}</td>
                <td class="py-2.5 px-4 text-center text-pink-500">{{ sj(s).female?.toLocaleString() ?? '-' }}</td>
                <td class="py-2.5 px-4 text-center hidden sm:table-cell">
                  <template v-if="i > 0 && sj(chartSessions[i-1]).total">
                    <span :class="['text-xs font-medium px-2 py-0.5 rounded-full',
                      sj(s).total > sj(chartSessions[i-1]).total ? 'bg-green-100 text-green-700' :
                      sj(s).total < sj(chartSessions[i-1]).total ? 'bg-red-100 text-red-600' :
                      'bg-gray-100 text-gray-500']">
                      {{ sj(s).total > sj(chartSessions[i-1]).total ? '+' : '' }}{{ (sj(s).total||0) - (sj(chartSessions[i-1]).total||0) }}
                    </span>
                  </template>
                  <span v-else class="text-xs text-gray-300">–</span>
                </td>
                <td class="py-2.5 px-4 text-gray-400 text-xs hidden md:table-cell">
                  {{ new Date(s.imported_at).toLocaleDateString('th-TH') }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <!-- ═══ Tab 2: จัดการรอบข้อมูล ═══ -->
      <template v-if="activeTab==='sessions'">
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="px-4 py-3 border-b border-gray-100 flex items-center justify-between bg-gray-50/60">
            <p class="text-xs text-gray-500">{{ sessions.length }} รอบ — ใช้ปุ่ม ↑↓ เรียงลำดับ</p>
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

              <div class="w-16 shrink-0">
                <span class="font-bold text-blue-700 text-sm">{{ s.academic_year }}</span>
              </div>
              <div class="shrink-0">
                <span class="text-xs bg-purple-100 text-purple-700 px-2 py-0.5 rounded-full font-medium">ช่วง {{ s.checkpoint }}</span>
              </div>

              <!-- Label — editable inline -->
              <div class="flex-1 min-w-0">
                <template v-if="editingSession?.id === s.id">
                  <input v-model="editingLabel" @keyup.enter="saveSessionLabel" @keyup.esc="editingSession=null"
                    class="w-full border border-blue-300 rounded-lg px-2 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                    :ref="el => el && el.focus()" />
                </template>
                <template v-else>
                  <span class="text-sm text-gray-800 truncate block">{{ s.checkpoint_label || `ช่วง ${s.checkpoint}/${s.academic_year}` }}</span>
                  <span class="text-xs text-gray-400">{{ new Date(s.imported_at).toLocaleDateString('th-TH') }} · {{ sj(s).total?.toLocaleString() ?? s.total_rows?.toLocaleString() }} คน</span>
                </template>
              </div>

              <!-- Actions -->
              <div class="flex items-center gap-1 shrink-0">
                <template v-if="editingSession?.id === s.id">
                  <button @click="saveSessionLabel" :disabled="savingSessionLabel"
                    class="px-3 py-1 text-xs bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300">
                    {{ savingSessionLabel ? '...' : 'บันทึก' }}
                  </button>
                  <button @click="editingSession=null" class="px-2 py-1 text-xs border border-gray-200 rounded-lg hover:bg-gray-50">ยกเลิก</button>
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
      </template>

    </template>

    <!-- Delete Session Confirm Modal -->
    <div v-if="deleteSessionTarget" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4"
      @click.self="deleteSessionTarget=null">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
        <div class="text-4xl mb-3">🗑️</div>
        <h3 class="font-bold text-gray-800 mb-2">ลบรอบสถิติ?</h3>
        <p class="text-sm font-medium text-gray-700 mb-1">{{ deleteSessionTarget.checkpoint_label }}</p>
        <p class="text-xs text-gray-400 mb-5">
          ปีการศึกษา {{ deleteSessionTarget.academic_year }} ช่วงที่ {{ deleteSessionTarget.checkpoint }}
        </p>
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

  </AdminLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AdminLayout from '../../layouts/AdminLayout.vue'
import { supabase } from '../../lib/supabase'

const sessions  = ref([])
const loading   = ref(true)
const activeTab = ref('chart')

const tabs = [
  { key: 'chart',    icon: '📊', label: 'กราฟเปรียบเทียบ' },
  { key: 'sessions', icon: '📋', label: 'จัดการรอบข้อมูล' },
]

// Helper: ดึง stats_json จาก session
function sj(s) { return s.stats_json || {} }

const latestStats = computed(() => sj(sessions.value[0]))

// ── Chart: เรียงเก่า→ใหม่ (ซ้าย→ขวา) ────────────────────────────────────────
const chartSessions = computed(() =>
  [...sessions.value].sort((a, b) => {
    if (a.academic_year !== b.academic_year) return a.academic_year - b.academic_year
    return (a.checkpoint || 0) - (b.checkpoint || 0)
  })
)

const C = { W: 720, H: 260, PL: 52, PR: 20, PT: 20, PB: 50 }

const chartMax = computed(() =>
  Math.max(...chartSessions.value.map(s => sj(s).total || 0), 1)
)

function tyAt(val) {
  return C.PT + (C.H - C.PT - C.PB) * (1 - val / chartMax.value)
}

const chartYTicks = computed(() => {
  const max = chartMax.value
  let step = Math.pow(10, Math.floor(Math.log10(max / 4)))
  if (max / step > 8) step *= 2
  const ticks = []
  for (let v = 0; v <= max * 1.08; v += step) {
    ticks.push({ v, y: tyAt(v), label: v >= 1000 ? `${(v/1000).toFixed(v%1000===0?0:1)}k` : v })
  }
  return ticks
})

const chartBars = computed(() => {
  const n = chartSessions.value.length
  if (!n) return []
  const slotW = (C.W - C.PL - C.PR) / n
  const barW  = Math.min(slotW * 0.52, 54)
  return chartSessions.value.map((s, i) => {
    const cx  = C.PL + slotW * i + slotW / 2
    const val = sj(s).total || 0
    const ty  = tyAt(val)
    return {
      s, cx, x: cx - barW / 2, y: ty,
      w: barW, h: C.H - C.PB - ty,
      val, ty,
    }
  })
})

const trendPath = computed(() => {
  if (chartBars.value.length < 2) return ''
  return chartBars.value.map((b, i) => `${i===0?'M':'L'}${b.cx},${b.ty}`).join(' ')
})

const hoveredChartBar = ref(null)

// ══ Session Management ══════════════════════════════════════════════════════
const editingSession     = ref(null)
const editingLabel       = ref('')
const savingSessionLabel = ref(false)
const deleteSessionTarget= ref(null)
const deletingSession    = ref(false)
const deleteSessionError = ref('')
const sessionActionError = ref('')

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
    // ลบ snapshots ก่อน (ถ้ามี) แล้วลบ session
    await supabase.from('student_snapshots').delete().eq('import_session_id', id)
    const { error } = await supabase.from('import_sessions').delete().eq('id', id)
    if (error) throw error
    sessions.value = sessions.value.filter(s => s.id !== id)
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
  const a = sessions.value[idx], b = sessions.value[swapIdx]
  const oa = a.sort_order ?? idx, ob = b.sort_order ?? swapIdx
  const na = oa === ob ? (dir > 0 ? oa + 1 : oa - 1) : ob
  const nb = oa === ob ? (dir > 0 ? oa - 1 : oa + 1) : oa
  try {
    await Promise.all([
      supabase.from('import_sessions').update({ sort_order: na }).eq('id', a.id),
      supabase.from('import_sessions').update({ sort_order: nb }).eq('id', b.id),
    ])
    sessions.value[idx].sort_order     = na
    sessions.value[swapIdx].sort_order = nb
    ;[sessions.value[idx], sessions.value[swapIdx]] = [sessions.value[swapIdx], sessions.value[idx]]
  } catch (e) {
    sessionActionError.value = e.message || 'เรียงลำดับไม่ได้'
  }
}

// ══ Load ══════════════════════════════════════════════════════════════════════
onMounted(async () => {
  const { data } = await supabase
    .from('import_sessions')
    .select('id, academic_year, checkpoint, checkpoint_label, total_rows, stats_json, sort_order, imported_at')
    .order('sort_order', { ascending: true, nullsFirst: false })
    .order('imported_at', { ascending: false })
  sessions.value = data || []
  loading.value  = false
})
</script>
