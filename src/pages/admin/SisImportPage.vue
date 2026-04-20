<template>
  <AdminLayout>
    <div class="max-w-4xl mx-auto">
      <!-- Header -->
      <div class="flex items-center gap-3 mb-6">
        <router-link to="/admin/sis" class="p-2 rounded-xl text-gray-400 hover:text-gray-600 hover:bg-gray-100">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
        </router-link>
        <div>
          <h2 class="text-xl font-bold text-gray-900">นำเข้าข้อมูลนักเรียน</h2>
          <p class="text-sm text-gray-500 mt-0.5">นำเข้าจากไฟล์ Excel DMC</p>
        </div>
      </div>

      <!-- Steps Bar -->
      <div class="flex items-center gap-2 mb-8">
        <template v-for="(s, i) in steps" :key="i">
          <div class="flex items-center gap-2">
            <div :class="['w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold transition-all',
              step > i+1 ? 'bg-green-500 text-white' :
              step === i+1 ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-400']">
              <span v-if="step > i+1">✓</span>
              <span v-else>{{ i+1 }}</span>
            </div>
            <span :class="['text-sm hidden sm:block', step === i+1 ? 'font-semibold text-blue-600' : 'text-gray-400']">{{ s }}</span>
          </div>
          <div v-if="i < steps.length-1" class="flex-1 h-px bg-gray-200 mx-1"></div>
        </template>
      </div>

      <!-- STEP 1: Upload -->
      <div v-if="step === 1" class="bg-white rounded-2xl shadow-sm p-8">
        <h3 class="font-bold text-gray-900 text-lg mb-2">อัปโหลดไฟล์ Excel จาก DMC</h3>
        <p class="text-sm text-gray-500 mb-6">รองรับไฟล์ .xlsx และ .csv จาก DMC (Data Management Center)</p>

        <label class="block cursor-pointer">
          <div :class="['border-2 border-dashed rounded-2xl p-12 text-center transition-all',
            isDragging ? 'border-blue-400 bg-blue-50' : 'border-gray-200 hover:border-blue-300 hover:bg-blue-50/30']"
            @dragover.prevent="isDragging=true" @dragleave="isDragging=false"
            @drop.prevent="onDrop">
            <div class="text-5xl mb-3">📊</div>
            <p class="font-semibold text-gray-700 mb-1">ลากไฟล์มาวางที่นี่ หรือคลิกเพื่อเลือก</p>
            <p class="text-xs text-gray-400">.xlsx, .csv — ไฟล์ DMC ปกติ (row แรกเป็นวันที่, row สองเป็น header)</p>
          </div>
          <input type="file" accept=".xlsx,.csv" class="hidden" @change="onFileSelect" />
        </label>

        <div v-if="parseError" class="mt-4 p-4 bg-red-50 rounded-xl text-sm text-red-700 flex items-start gap-2">
          <span>❌</span><span>{{ parseError }}</span>
        </div>
        <div v-if="schoolCodeError" class="mt-4 p-4 bg-red-50 rounded-xl text-sm text-red-700 flex items-start gap-2">
          <span>🏫</span><span>{{ schoolCodeError }}</span>
        </div>

        <div v-if="parsing" class="mt-6 flex items-center gap-3 text-blue-600">
          <div class="w-5 h-5 border-2 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
          <span class="text-sm">กำลังอ่านไฟล์...</span>
        </div>
      </div>

      <!-- STEP 2: Preview & Validate -->
      <div v-if="step === 2" class="space-y-4">
        <!-- Summary bar -->
        <div class="bg-white rounded-2xl shadow-sm p-5 flex flex-wrap gap-6">
          <div>
            <p class="text-xs text-gray-500">ไฟล์</p>
            <p class="font-semibold text-gray-800 text-sm">{{ fileName }}</p>
          </div>
          <div>
            <p class="text-xs text-gray-500">รายการทั้งหมด</p>
            <p class="font-bold text-2xl text-blue-600">{{ rows.length }}</p>
          </div>
          <div>
            <p class="text-xs text-gray-500">แถวปัญหา</p>
            <p class="font-bold text-2xl" :class="errorRows.length ? 'text-red-500' : 'text-green-500'">{{ errorRows.length }}</p>
          </div>
          <div>
            <p class="text-xs text-gray-500">ตรวจสอบแล้ว</p>
            <p class="font-bold text-2xl text-green-600">{{ rows.length - errorRows.length }}</p>
          </div>
          <div class="ml-auto flex items-center">
            <button @click="step=3" :disabled="!!errorRows.length"
              class="btn-primary px-6 disabled:opacity-40">
              ถัดไป →
            </button>
          </div>
        </div>

        <!-- Error rows -->
        <div v-if="errorRows.length" class="bg-red-50 border border-red-100 rounded-2xl p-4">
          <p class="text-sm font-semibold text-red-700 mb-2">⚠️ พบแถวที่มีปัญหา {{ errorRows.length }} แถว</p>
          <div class="space-y-1 max-h-40 overflow-y-auto">
            <div v-for="e in errorRows" :key="e.row" class="text-xs text-red-600 bg-white rounded-lg px-3 py-1.5">
              แถว {{ e.row }}: {{ e.reason }}
            </div>
          </div>
        </div>

        <!-- Preview table -->
        <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
          <div class="px-4 py-3 border-b border-gray-100 flex items-center justify-between">
            <p class="text-sm font-semibold text-gray-700">ตัวอย่างข้อมูล ({{ Math.min(20, rows.length) }} แถวแรก)</p>
            <p class="text-xs text-gray-400">แสดง 20 แถวแรก</p>
          </div>
          <div class="overflow-x-auto">
            <table class="w-full text-xs">
              <thead class="bg-gray-50 text-gray-500 uppercase tracking-wide">
                <tr>
                  <th class="py-2 px-3 text-left">#</th>
                  <th class="py-2 px-3 text-left">เลขประจำตัว</th>
                  <th class="py-2 px-3 text-left">เลขบัตรปชช.</th>
                  <th class="py-2 px-3 text-left">ชื่อ-สกุล</th>
                  <th class="py-2 px-3 text-center">เพศ</th>
                  <th class="py-2 px-3 text-center">ชั้น</th>
                  <th class="py-2 px-3 text-center">ห้อง</th>
                  <th class="py-2 px-3 text-center">วันเกิด</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, i) in rows.slice(0,20)" :key="i"
                  class="border-b border-gray-50 hover:bg-blue-50/20">
                  <td class="py-1.5 px-3 text-gray-400">{{ i+1 }}</td>
                  <td class="py-1.5 px-3 font-mono font-semibold text-blue-700">{{ r.student_code }}</td>
                  <td class="py-1.5 px-3 font-mono text-gray-500 text-xs">{{ r.national_id }}</td>
                  <td class="py-1.5 px-3 text-gray-900">{{ r.prefix }}{{ r.first_name }} {{ r.last_name }}</td>
                  <td class="py-1.5 px-3 text-center">{{ r.gender === 'ชาย' ? '👦' : '👧' }}</td>
                  <td class="py-1.5 px-3 text-center font-medium">{{ r.grade_level }}</td>
                  <td class="py-1.5 px-3 text-center">{{ r.room }}</td>
                  <td class="py-1.5 px-3 text-center text-gray-500">{{ r.birth_date }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- STEP 3: Confirm metadata -->
      <div v-if="step === 3" class="bg-white rounded-2xl shadow-sm p-8">
        <h3 class="font-bold text-gray-900 text-lg mb-6">ยืนยันข้อมูลการนำเข้า</h3>
        <div class="space-y-5">
          <!-- ปีการศึกษา -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">ปีการศึกษา <span class="text-red-500">*</span></label>
            <input v-model.number="meta.academic_year" type="number" min="2560" max="2580"
              class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" />
          </div>

          <!-- ช่วงข้อมูล -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">ช่วงการเก็บข้อมูล <span class="text-red-500">*</span></label>
            <div class="grid grid-cols-3 gap-3">
              <button v-for="cp in checkpoints" :key="cp.value"
                @click="meta.checkpoint = cp.value"
                :class="['p-4 rounded-xl border-2 text-center transition-all',
                  meta.checkpoint === cp.value
                    ? 'border-blue-500 bg-blue-50'
                    : 'border-gray-200 hover:border-blue-200']">
                <p class="font-bold text-gray-900">ช่วงที่ {{ cp.value }}</p>
                <p class="text-sm text-blue-600 font-medium mt-1">{{ cp.label }}</p>
                <p class="text-xs text-gray-400 mt-0.5">{{ cp.desc }}</p>
              </button>
            </div>
          </div>

          <!-- หมายเหตุ -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">หมายเหตุ (ไม่บังคับ)</label>
            <textarea v-model="meta.notes" rows="2" placeholder="เช่น นำเข้าข้อมูลครั้งแรก ปีการศึกษา 2568"
              class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"></textarea>
          </div>

          <!-- Summary -->
          <div class="bg-blue-50 rounded-xl p-4 text-sm text-blue-800">
            <p class="font-semibold mb-1">📋 สรุปก่อนบันทึก</p>
            <p>ไฟล์: <span class="font-medium">{{ fileName }}</span></p>
            <p>จำนวน: <span class="font-bold text-blue-700">{{ rows.length }} คน</span></p>
            <p>ปีการศึกษา: <span class="font-medium">{{ meta.academic_year }}</span> ช่วงที่ {{ meta.checkpoint }}
              ({{ checkpoints.find(c=>c.value===meta.checkpoint)?.label }})</p>
          </div>
        </div>

        <div class="flex gap-3 mt-6">
          <button @click="step=2" class="px-5 py-2.5 border border-gray-200 rounded-xl text-sm text-gray-600 hover:bg-gray-50">← ย้อนกลับ</button>
          <button @click="doImport" :disabled="!meta.academic_year || !meta.checkpoint"
            class="flex-1 btn-primary py-2.5 disabled:opacity-40">
            🚀 บันทึกข้อมูล {{ rows.length }} คน
          </button>
        </div>
      </div>

      <!-- STEP 4: Processing -->
      <div v-if="step === 4" class="bg-white rounded-2xl shadow-sm p-12 text-center">
        <div class="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-6"></div>
        <h3 class="font-bold text-gray-900 text-lg mb-2">กำลังบันทึกข้อมูล...</h3>
        <p class="text-sm text-gray-500">กำลัง upsert นักเรียน {{ rows.length }} คน กรุณารอสักครู่</p>
      </div>

      <!-- STEP 5: Done -->
      <div v-if="step === 5" class="bg-white rounded-2xl shadow-sm p-10 text-center">
        <div class="w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mx-auto mb-5 text-3xl">✅</div>
        <h3 class="font-bold text-gray-900 text-xl mb-2">นำเข้าสำเร็จ!</h3>
        <p class="text-sm text-gray-500 mb-6">ปีการศึกษา {{ meta.academic_year }} ช่วงที่ {{ meta.checkpoint }}</p>
        <div class="grid grid-cols-3 gap-4 max-w-md mx-auto mb-8">
          <div class="bg-blue-50 rounded-xl p-4">
            <p class="text-2xl font-bold text-blue-600">{{ result.new_count }}</p>
            <p class="text-xs text-gray-500 mt-1">นักเรียนใหม่</p>
          </div>
          <div class="bg-green-50 rounded-xl p-4">
            <p class="text-2xl font-bold text-green-600">{{ result.updated_count }}</p>
            <p class="text-xs text-gray-500 mt-1">อัปเดตข้อมูล</p>
          </div>
          <div class="bg-orange-50 rounded-xl p-4">
            <p class="text-2xl font-bold text-orange-500">{{ result.left_count }}</p>
            <p class="text-xs text-gray-500 mt-1">ออกจากระบบ</p>
          </div>
        </div>
        <div class="flex justify-center gap-3">
          <router-link to="/admin/sis" class="btn-primary px-6 py-2.5">📊 ดูข้อมูลนักเรียน</router-link>
          <button @click="reset" class="px-6 py-2.5 border border-gray-200 rounded-xl text-sm text-gray-600 hover:bg-gray-50">นำเข้าอีกครั้ง</button>
        </div>
      </div>

    </div>
  </AdminLayout>
</template>

<script setup>
import { ref } from 'vue'
import * as XLSX from 'xlsx'
import AdminLayout from '../../layouts/AdminLayout.vue'
import { supabase } from '../../lib/supabase'

const step      = ref(1)
const parsing   = ref(false)
const parseError = ref('')
const isDragging = ref(false)
const fileName  = ref('')
const rows      = ref([])
const errorRows = ref([])
const result    = ref({ new_count: 0, updated_count: 0, left_count: 0 })

const steps = ['อัปโหลด', 'ตรวจสอบ', 'ยืนยัน', 'บันทึก', 'เสร็จสิ้น']
const checkpoints = [
  { value: 1, label: '10 มิ.ย.', desc: 'ต้นปีการศึกษา' },
  { value: 2, label: '10 พ.ย.', desc: 'กลางปีการศึกษา' },
  { value: 3, label: '30 เม.ย.', desc: 'ปลายปีการศึกษา' },
]

const currentYear = new Date().getFullYear() + 543
const meta = ref({ academic_year: currentYear, checkpoint: null, notes: '' })
const detectedSchoolCode = ref('')  // รหัสโรงเรียนจากไฟล์
const schoolCodeError    = ref('')  // ถ้าไม่ตรง

// DMC column map — ใช้ index เพราะมี column ซ้ำชื่อ
// col C(2) = เลขบัตรประชาชน (national_id)
// col F(5) = เลขประจำตัวนักเรียน (student_code) ← key หลัก
const COL_IDX = {
  0:  'school_code',       // รหัสโรงเรียน (validate เท่านั้น)
  2:  'national_id',       // เลขบัตรประชาชน 13 หลัก
  3:  'grade_level',       // ชั้น เช่น ม.1 / ป.3 / อ.2
  4:  'room',              // ห้อง
  5:  'student_code',      // เลขประจำตัวนักเรียน ← primary key
  6:  'gender',            // เพศ (ช/ญ)
  7:  'prefix',            // คำนำหน้า
  8:  'first_name',        // ชื่อ
  9:  'last_name',         // นามสกุล
  10: 'birth_date',        // วันเกิด
  12: 'weight',            // น้ำหนัก
  13: 'height',            // ส่วนสูง
  15: 'religion',          // ศาสนา
  16: 'ethnicity',         // เชื้อชาติ
  17: 'nationality',       // สัญชาติ
  24: '_guardian_first',   // ชื่อผู้ปกครอง
  25: '_guardian_last',    // นามสกุลผู้ปกครอง
  27: 'guardian_relation', // ความเกี่ยวข้อง
  34: 'disadvantaged',     // ความด้อยโอกาส
}

function onDrop(e) {
  isDragging.value = false
  const file = e.dataTransfer.files[0]
  if (file) processFile(file)
}
function onFileSelect(e) {
  const file = e.target.files[0]
  if (file) processFile(file)
}

function autoDetectFromFilename(name) {
  // รูปแบบ: 2568-3-student.xlsx
  const m = name.match(/(\d{4})-(\d)/)
  if (m) {
    const yr = parseInt(m[1])
    const cp = parseInt(m[2])
    if (yr >= 2560 && yr <= 2580 && cp >= 1 && cp <= 3) {
      meta.value.academic_year = yr
      meta.value.checkpoint = cp
    }
  }
}

// แปลงวันเกิด DD/MM/YYYY (พ.ศ.) → YYYY-MM-DD (ค.ศ.)
function parseBirthDate(raw) {
  if (!raw) return null
  const s = String(raw).trim()
  // Excel date serial number
  if (/^\d{5}$/.test(s)) {
    const d = XLSX.SSF.parse_date_code(parseInt(s))
    if (d) return `${d.y}-${String(d.m).padStart(2,'0')}-${String(d.d).padStart(2,'0')}`
  }
  // DD/MM/YYYY
  const m = s.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$/)
  if (m) {
    let y = parseInt(m[3])
    if (y > 2400) y -= 543 // แปลง พ.ศ. → ค.ศ.
    return `${y}-${m[2].padStart(2,'0')}-${m[1].padStart(2,'0')}`
  }
  return null
}

async function processFile(file) {
  parsing.value = true
  parseError.value = ''
  schoolCodeError.value = ''
  detectedSchoolCode.value = ''
  fileName.value = file.name
  autoDetectFromFilename(file.name)

  try {
    const buf = await file.arrayBuffer()
    const wb  = XLSX.read(buf, { type: 'array', cellDates: false, raw: false })
    const ws  = wb.Sheets[wb.SheetNames[0]]

    // อ่านเป็น array of arrays เพื่อใช้ index แทนชื่อ column (หลีกเลี่ยงปัญหา column ซ้ำ)
    // DMC: row[0] = metadata วันที่, row[1] = header, row[2+] = data
    const raw = XLSX.utils.sheet_to_json(ws, { header: 1, defval: '', raw: false })

    // ดึง school_code จากแถวข้อมูลแรก (row index 2)
    if (raw.length > 2) {
      detectedSchoolCode.value = String(raw[2][0] || '').trim()
    }

    // ตรวจสอบรหัสโรงเรียน (DMC) กับ school_config.school_code
    const { data: cfg } = await supabase.from('school_config').select('school_code').limit(1).single()
    const configCode = cfg?.school_code?.trim()
    if (configCode && detectedSchoolCode.value && configCode !== detectedSchoolCode.value) {
      schoolCodeError.value = `รหัสโรงเรียน DMC ในไฟล์ (${detectedSchoolCode.value}) ไม่ตรงกับรหัสที่ตั้งค่าไว้ (${configCode}) — กรุณาตรวจสอบว่าเลือกไฟล์ถูกโรงเรียน`
      parsing.value = false
      return
    }

    const parsed = []
    const errs   = []

    // วนจาก row index 2 (skip metadata + header)
    for (let idx = 2; idx < raw.length; idx++) {
      const row = raw[idx]
      // ข้ามแถวว่าง
      if (!row || row.every(v => v === '' || v == null)) continue

      const obj = {}
      for (const [colIdx, fieldName] of Object.entries(COL_IDX)) {
        const val = String(row[parseInt(colIdx)] ?? '').trim()
        obj[fieldName] = val
      }
      // รวมชื่อผู้ปกครอง
      obj.guardian_name = [obj._guardian_first, obj._guardian_last].filter(Boolean).join(' ')
      delete obj._guardian_first; delete obj._guardian_last
      delete obj.school_code  // ไม่เก็บในตาราง students

      // Normalize gender: DMC ใช้ 'ช'/'ญ' → แปลงเป็น 'ชาย'/'หญิง' เสมอ
      if (obj.gender === 'ช' || obj.gender === 'male') obj.gender = 'ชาย'
      else if (obj.gender === 'ญ' || obj.gender === 'female') obj.gender = 'หญิง'

      // แปลงวันเกิด
      obj.birth_date = parseBirthDate(obj.birth_date)

      // แปลง room เป็น int
      obj.room = parseInt(obj.room) || null

      // validate
      if (!obj.student_code) {
        errs.push({ row: idx, reason: `ไม่มีเลขประจำตัวนักเรียน (row ${idx})` })
        continue
      }
      if (!obj.first_name) {
        errs.push({ row: idx, reason: `ไม่มีชื่อ (row ${idx}, รหัส ${obj.student_code})` })
        continue
      }
      parsed.push(obj)
    }

    rows.value      = parsed
    errorRows.value = errs
    step.value      = 2
  } catch (e) {
    parseError.value = 'ไม่สามารถอ่านไฟล์ได้: ' + e.message
  } finally {
    parsing.value = false
  }
}

async function doImport() {
  if (!meta.value.academic_year || !meta.value.checkpoint) return
  step.value = 4

  const label = meta.value.notes
    ? `${fileName.value} — ${meta.value.notes}`
    : fileName.value

  // ส่งทั้งหมดในครั้งเดียว — ไม่ batch เพื่อป้องกัน "สถานะออก" ผิด
  const { data, error } = await supabase.rpc('process_student_import', {
    p_year:        meta.value.academic_year,
    p_checkpoint:  meta.value.checkpoint,
    p_label:       label,
    p_school_code: detectedSchoolCode.value || '',
    p_students:    rows.value,
  })

  if (error) {
    alert('เกิดข้อผิดพลาด: ' + error.message)
    step.value = 3
    return
  }

  result.value = {
    new_count:     data.inserted ?? 0,
    updated_count: data.updated  ?? 0,
    left_count:    0,
  }
  step.value = 5
}

function reset() {
  step.value      = 1
  rows.value      = []
  errorRows.value = []
  fileName.value  = ''
  parseError.value = ''
  meta.value      = { academic_year: currentYear, checkpoint: null, notes: '' }
}
</script>
