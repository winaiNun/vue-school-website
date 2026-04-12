<template>
  <AdminLayout>
    <div class="space-y-4">

      <!-- Header -->
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 class="text-lg font-bold text-gray-900">จัดการครูและบุคลากร</h2>
          <p class="text-xs text-gray-400 mt-0.5">ทั้งหมด {{ teachers.length }} คน</p>
        </div>
        <button @click="openAdd" class="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-xl text-sm font-semibold transition-colors">
          <span class="text-base">+</span> เพิ่มครู
        </button>
      </div>

      <!-- Search & Filter -->
      <div class="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 flex flex-wrap gap-3">
        <input v-model="search" type="text" placeholder="🔍 ค้นหาชื่อ..." class="input-field flex-1 min-w-40" />
        <select v-model="filterGroup" class="input-field w-48">
          <option value="">กลุ่มสาระทั้งหมด</option>
          <option v-for="g in subjectGroups" :key="g" :value="g">{{ g }}</option>
        </select>
        <select v-model="filterPos" class="input-field w-44">
          <option value="">ตำแหน่งทั้งหมด</option>
          <option v-for="p in positions" :key="p" :value="p">{{ p }}</option>
        </select>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-16 text-gray-400">
        <div class="text-4xl mb-2">⏳</div><p>กำลังโหลด...</p>
      </div>

      <!-- Teacher Grid -->
      <div v-else-if="filtered.length" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <div v-for="t in filtered" :key="t.id"
          class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow">
          <!-- Photo -->
          <div class="relative h-40 bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
            <img v-if="t.profile_image_url" :src="t.profile_image_url" class="w-full h-full object-cover object-top" />
            <div v-else class="text-5xl opacity-30">👤</div>
            <!-- Badge วิทยฐานะ -->
            <div v-if="t.academic_standing" class="absolute top-2 right-2 bg-yellow-400 text-yellow-900 text-xs px-2 py-0.5 rounded-full font-medium">
              {{ t.academic_standing.replace('ครู','') }}
            </div>
          </div>
          <!-- Info -->
          <div class="p-4">
            <p class="font-semibold text-gray-900 truncate">{{ t.prefix }}{{ t.first_name }} {{ t.last_name }}</p>
            <p class="text-xs text-gray-500 mt-0.5">{{ t.position || 'ครู' }}</p>
            <div class="flex flex-wrap gap-1 mt-2">
              <span v-if="t.subject_group" class="bg-blue-50 text-blue-700 text-xs px-2 py-0.5 rounded-full">{{ t.subject_group }}</span>
            </div>
            <!-- Actions -->
            <div class="flex gap-2 mt-3">
              <button @click="openEdit(t)" class="flex-1 text-xs py-1.5 rounded-lg border border-gray-200 hover:bg-gray-50 text-gray-600 transition-colors">✏️ แก้ไข</button>
              <button @click="confirmDelete(t)" class="text-xs py-1.5 px-3 rounded-lg border border-red-100 hover:bg-red-50 text-red-500 transition-colors">🗑️</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty -->
      <div v-else class="text-center py-16 text-gray-400 bg-white rounded-2xl border border-gray-100">
        <div class="text-5xl mb-3">👨‍🏫</div>
        <p class="font-medium">{{ search || filterGroup || filterPos ? 'ไม่พบข้อมูลที่ค้นหา' : 'ยังไม่มีข้อมูลครู' }}</p>
        <p class="text-sm mt-1">{{ !search && !filterGroup ? 'กด "+ เพิ่มครู" เพื่อเริ่มต้น' : '' }}</p>
      </div>
    </div>

    <!-- ── Add/Edit Modal ── -->
    <Teleport to="body">
      <div v-if="showForm" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-3">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[92vh] overflow-y-auto">
          <div class="px-6 py-4 border-b flex items-center justify-between sticky top-0 bg-white z-10">
            <h3 class="font-bold text-gray-800">{{ editId ? '✏️ แก้ไขข้อมูลครู' : '➕ เพิ่มครูและบุคลากร' }}</h3>
            <button type="button" @click="closeForm" class="w-8 h-8 flex items-center justify-center rounded-full hover:bg-gray-100 text-gray-400 text-xl">×</button>
          </div>

          <form @submit.prevent="handleSave" class="p-6 space-y-5">
            <!-- Photo -->
            <div class="flex justify-center">
              <div class="text-center">
                <p class="text-xs font-medium text-gray-600 mb-2">รูปภาพ</p>
                <ImageUploadCrop
                  v-model="teacherForm.profile_image_url"
                  bucket="school"
                  :storage-path="'teachers/teacher-' + (editId || pendingNewId) + '.jpg'"
                  shape="square"
                  :aspect-ratio="3/4"
                  :output-width="300"
                  container-class="w-24 h-32 rounded-2xl"
                  icon="👤"
                  placeholder="อัปโหลดรูป"
                />
              </div>
            </div>

            <!-- ชื่อ -->
            <div class="grid grid-cols-3 gap-3">
              <div>
                <label class="label">คำนำหน้า</label>
                <select v-model="teacherForm.prefix" class="input-field">
                  <option>นาย</option><option>นาง</option><option>นางสาว</option>
                  <option>เด็กชาย</option><option>เด็กหญิง</option>
                </select>
              </div>
              <div>
                <label class="label">ชื่อ <span class="text-red-500">*</span></label>
                <input v-model="teacherForm.first_name" required class="input-field" placeholder="ชื่อจริง" />
              </div>
              <div>
                <label class="label">นามสกุล <span class="text-red-500">*</span></label>
                <input v-model="teacherForm.last_name" required class="input-field" placeholder="นามสกุล" />
              </div>
            </div>

            <!-- ตำแหน่ง & วิทยฐานะ -->
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="label">ตำแหน่ง</label>
                <select v-model="teacherForm.position" class="input-field">
                  <option>ผู้อำนวยการโรงเรียน</option>
                  <option>รองผู้อำนวยการ</option>
                  <option>ครู</option>
                  <option>ครูผู้ช่วย</option>
                  <option>พนักงานราชการ</option>
                  <option>ลูกจ้างประจำ</option>
                  <option>ลูกจ้างชั่วคราว</option>
                  <option>ธุรการโรงเรียน</option>
                </select>
              </div>
              <div>
                <label class="label">วิทยฐานะ</label>
                <select v-model="teacherForm.academic_standing" class="input-field">
                  <option value="">ไม่มี / ยังไม่มีวิทยฐานะ</option>
                  <optgroup label="── ครู ──">
                    <option>ครูชำนาญการ</option>
                    <option>ครูชำนาญการพิเศษ</option>
                    <option>ครูเชี่ยวชาญ</option>
                    <option>ครูเชี่ยวชาญพิเศษ</option>
                  </optgroup>
                  <optgroup label="── ผู้อำนวยการ ──">
                    <option>ผู้อำนวยการชำนาญการพิเศษ</option>
                    <option>ผู้อำนวยการเชี่ยวชาญ</option>
                  </optgroup>
                  <optgroup label="── รองผู้อำนวยการ ──">
                    <option>รองผู้อำนวยการชำนาญการพิเศษ</option>
                    <option>รองผู้อำนวยการเชี่ยวชาญ</option>
                  </optgroup>
                </select>
              </div>
            </div>

            <!-- กลุ่มสาระ & บทบาทในกลุ่ม -->
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="label">กลุ่มสาระการเรียนรู้</label>
                <select v-model="teacherForm.subject_group" class="input-field">
                  <option value="">-</option>
                  <option v-for="g in subjectGroups" :key="g" :value="g">{{ g }}</option>
                </select>
              </div>
              <div>
                <label class="label">บทบาทในกลุ่มสาระ</label>
                <select v-model="teacherForm.group_role" class="input-field">
                  <option value="">ครูทั่วไป</option>
                  <option value="หัวหน้ากลุ่มสาระ">หัวหน้ากลุ่มสาระ</option>
                  <option value="รองหัวหน้ากลุ่มสาระ">รองหัวหน้ากลุ่มสาระ</option>
                </select>
              </div>
            </div>

            <!-- วิชาที่สอน -->
            <div>
              <label class="label">วิชาที่สอน</label>
              <input v-model="teacherForm.subjects_taught" class="input-field" placeholder="เช่น คณิตศาสตร์พื้นฐาน, แคลคูลัส" />
            </div>

            <!-- งานบริหาร -->
            <div class="bg-indigo-50 rounded-xl p-4">
              <div class="flex items-center justify-between mb-3">
                <label class="text-sm font-semibold text-indigo-800">🏢 งานบริหาร (เพิ่มได้หลายกลุ่ม)</label>
                <button type="button" @click="addDeptRow"
                  class="text-xs bg-indigo-600 text-white px-3 py-1 rounded-lg hover:bg-indigo-700 transition-colors">
                  + เพิ่มกลุ่ม
                </button>
              </div>
              <div v-if="!deptAssignments.length" class="text-xs text-indigo-400 text-center py-2">
                ยังไม่ได้กำหนดงานบริหาร
              </div>
              <div v-for="(row, idx) in deptAssignments" :key="idx" class="flex items-center gap-2 mb-2">
                <select v-model="row.department_name" class="input-field flex-1 text-sm">
                  <option value="">-- เลือกกลุ่ม --</option>
                  <option v-for="d in adminDepartments" :key="d" :value="d">{{ d }}</option>
                </select>
                <select v-model="row.department_role" class="input-field w-48 text-sm">
                  <option value="ผู้อำนวยการโรงเรียน">ผู้อำนวยการโรงเรียน</option>
                  <option value="รองผู้อำนวยการโรงเรียน">รองผู้อำนวยการโรงเรียน</option>
                  <option value="หัวหน้ากลุ่ม">หัวหน้ากลุ่ม</option>
                  <option value="รองหัวหน้ากลุ่ม">รองหัวหน้ากลุ่ม</option>
                  <option value="เลขานุการ">เลขานุการ</option>
                  <option value="กรรมการ">กรรมการ</option>
                </select>
                <button type="button" @click="deptAssignments.splice(idx, 1)"
                  class="p-1.5 rounded-lg text-indigo-300 hover:text-red-500 hover:bg-red-50 transition-colors flex-shrink-0">✕</button>
              </div>
            </div>

            <!-- ข้อมูลส่วนตัว -->
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="label">เลขบัตรประชาชน</label>
                <input v-model="teacherForm.id_card" type="text" maxlength="13" class="input-field font-mono" placeholder="13 หลัก" />
              </div>
              <div>
                <label class="label">วันเกิด</label>
                <input v-model="teacherForm.birth_date" type="date" class="input-field" />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="label">เบอร์โทรศัพท์</label>
                <input v-model="teacherForm.phone" type="tel" class="input-field" placeholder="08X-XXX-XXXX" />
              </div>
              <div>
                <label class="label">อีเมล</label>
                <input v-model="teacherForm.email" type="email" class="input-field" placeholder="example@school.go.th" />
              </div>
            </div>

            <!-- เว็บไซต์/ผลงาน -->
            <div>
              <label class="label">🌐 เว็บไซต์หรือผลงาน (ถ้ามี)</label>
              <input v-model="teacherForm.website_url" type="url" class="input-field"
                placeholder="https://sites.google.com/..." />
              <p class="text-xs text-gray-400 mt-1">จะแสดงปุ่ม "เยี่ยมชมผลงาน" บนการ์ดในหน้าสาธารณะ</p>
            </div>

            <!-- วุฒิการศึกษา -->
            <div class="bg-amber-50 rounded-xl p-4">
              <label class="text-sm font-semibold text-amber-800 mb-3 block">🎓 วุฒิการศึกษา</label>
              <div class="grid grid-cols-3 gap-3">
                <div>
                  <label class="label">ระดับการศึกษา</label>
                  <select v-model="teacherForm.education_level" class="input-field">
                    <option value="">— ไม่ระบุ —</option>
                    <option>ต่ำกว่าปริญญาตรี</option>
                    <option>ปริญญาตรี</option>
                    <option>ปริญญาโท</option>
                    <option>ปริญญาเอก</option>
                  </select>
                </div>
                <div>
                  <label class="label">สาขาวิชา</label>
                  <input v-model="teacherForm.education_major" type="text" class="input-field" placeholder="เช่น คณิตศาสตร์" />
                </div>
                <div>
                  <label class="label">สถาบัน</label>
                  <input v-model="teacherForm.education_institution" type="text" class="input-field" placeholder="เช่น ม.ราชภัฏ..." />
                </div>
              </div>
            </div>

            <!-- เชื่อมบัญชี -->
            <div class="bg-blue-50 rounded-xl p-4">
              <label class="label text-blue-800">🔗 เชื่อมกับบัญชีผู้ใช้ในระบบ (ถ้ามี)</label>
              <select v-model="teacherForm.profile_id" class="input-field mt-1">
                <option value="">-- ไม่เชื่อม --</option>
                <option v-for="p in availableProfiles" :key="p.id" :value="p.id">
                  {{ p.full_name || p.email }}
                </option>
              </select>
              <p class="text-xs text-blue-600 mt-1">ถ้าเชื่อม จะอนุมัติ account และตั้งเป็น teacher อัตโนมัติ</p>
            </div>

            <div v-if="formError" class="bg-red-50 text-red-700 rounded-xl p-3 text-sm">{{ formError }}</div>

            <div class="flex justify-end gap-3 pt-1">
              <button type="button" @click="closeForm" class="px-5 py-2 rounded-xl border border-gray-200 text-gray-600 hover:bg-gray-50 text-sm font-medium">ยกเลิก</button>
              <button type="submit" :disabled="formLoading"
                class="px-5 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold disabled:opacity-60 flex items-center gap-2">
                <svg v-if="formLoading" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
                </svg>
                {{ formLoading ? 'กำลังบันทึก...' : '💾 บันทึก' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>

    <!-- ── Delete Confirm ── -->
    <Teleport to="body">
      <div v-if="deleteTarget" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
          <div class="text-5xl mb-3">🗑️</div>
          <h3 class="font-bold text-gray-800 text-lg">ลบข้อมูลครู?</h3>
          <p class="text-gray-500 text-sm mt-2">
            {{ deleteTarget.prefix }}{{ deleteTarget.first_name }} {{ deleteTarget.last_name }}
          </p>
          <p class="text-red-500 text-xs mt-1">การกระทำนี้ไม่สามารถยกเลิกได้</p>
          <div class="flex gap-3 mt-5">
            <button @click="deleteTarget = null" class="flex-1 py-2 rounded-xl border border-gray-200 text-gray-600 hover:bg-gray-50 text-sm font-medium">ยกเลิก</button>
            <button @click="deleteTeacher" :disabled="formLoading"
              class="flex-1 py-2 rounded-xl bg-red-600 hover:bg-red-700 text-white text-sm font-semibold disabled:opacity-60">
              {{ formLoading ? 'กำลังลบ...' : 'ลบเลย' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

  </AdminLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AdminLayout from '../../layouts/AdminLayout.vue'
import ImageUploadCrop from '../../components/admin/ImageUploadCrop.vue'
import { supabase } from '../../lib/supabase'
import { useSchoolConfig } from '../../composables/useSchoolConfig'

// ── Constants ────────────────────────────────────────────────
const subjectGroups = ['ภาษาไทย','คณิตศาสตร์','วิทยาศาสตร์และเทคโนโลยี','สังคมศึกษาฯ','ภาษาต่างประเทศ','สุขศึกษาและพลศึกษา','ศิลปะ','การงานอาชีพ','กิจกรรมพัฒนาผู้เรียน']
const positions = ['ผู้อำนวยการโรงเรียน','รองผู้อำนวยการ','ครู','ครูผู้ช่วย','พนักงานราชการ','ลูกจ้างประจำ','ลูกจ้างชั่วคราว','ธุรการโรงเรียน']
const DEFAULT_DEPTS = ['กลุ่มบริหารวิชาการ','กลุ่มบริหารงบประมาณ','กลุ่มบริหารงานบุคคล','กลุ่มบริหารทั่วไป']

const { config } = useSchoolConfig()
const adminDepartments = computed(() =>
  Array.isArray(config.value?.admin_departments) && config.value.admin_departments.length
    ? config.value.admin_departments
    : DEFAULT_DEPTS
)

// ── State ────────────────────────────────────────────────────
const teachers          = ref([])
const availableProfiles = ref([])
const loading           = ref(false)
const showForm          = ref(false)
const formLoading       = ref(false)
const formError         = ref('')
const editId            = ref(null)
const pendingNewId      = ref('')   // UUID ที่ generate ล่วงหน้าสำหรับครูใหม่
const deleteTarget      = ref(null)
const search            = ref('')
const filterGroup       = ref('')
const filterPos         = ref('')
const deptAssignments   = ref([])   // [{ department_name, department_role }]

const emptyForm = () => ({
  prefix: 'นาย', first_name: '', last_name: '', position: 'ครู',
  academic_standing: '', subject_group: '', group_role: '', subjects_taught: '',
  id_card: '', phone: '', email: '', birth_date: '',
  education_level: '', education_major: '', education_institution: '',
  website_url: '', profile_id: '', profile_image_url: ''
})
const teacherForm = ref(emptyForm())

// ── Computed ─────────────────────────────────────────────────
const filtered = computed(() => teachers.value.filter(t => {
  const name = `${t.prefix}${t.first_name} ${t.last_name}`.toLowerCase()
  if (search.value && !name.includes(search.value.toLowerCase())) return false
  if (filterGroup.value && t.subject_group !== filterGroup.value) return false
  if (filterPos.value && t.position !== filterPos.value) return false
  return true
}))

// ── Load ─────────────────────────────────────────────────────
async function loadTeachers() {
  loading.value = true
  try {
    const { data } = await supabase.from('teacher_profiles').select('*').order('first_name')
    teachers.value = data || []
  } finally {
    loading.value = false
  }
}

// ── Open Add/Edit ─────────────────────────────────────────────
function addDeptRow() {
  deptAssignments.value.push({ department_name: '', department_role: 'กรรมการ' })
}

function openAdd() {
  editId.value       = null
  pendingNewId.value = crypto.randomUUID()
  teacherForm.value  = emptyForm()
  deptAssignments.value = []
  formError.value    = ''
  showForm.value     = true
}

async function openEdit(t) {
  editId.value      = t.id
  pendingNewId.value = ''
  teacherForm.value = {
    prefix:             t.prefix || 'นาย',
    first_name:         t.first_name || '',
    last_name:          t.last_name || '',
    position:           t.position || 'ครู',
    academic_standing:  t.academic_standing || '',
    subject_group:      t.subject_group || '',
    subjects_taught:    t.subjects_taught || '',
    id_card:            t.id_card || '',
    phone:              t.phone || '',
    email:              t.email || '',
    birth_date:         t.birth_date || '',
    group_role:              t.group_role              || '',
    education_level:         t.education_level         || '',
    education_major:         t.education_major         || '',
    education_institution:   t.education_institution   || '',
    website_url:             t.website_url             || '',
    profile_id:              t.profile_id              || '',
    profile_image_url:       t.profile_image_url       || '',
  }
  // โหลด dept assignments
  const { data } = await supabase
    .from('teacher_department_assignments')
    .select('department_name, department_role')
    .eq('teacher_id', t.id)
  deptAssignments.value = data || []
  formError.value = ''
  showForm.value  = true
}

function closeForm() { showForm.value = false; editId.value = null; deptAssignments.value = [] }

// ── Save ─────────────────────────────────────────────────────
async function handleSave() {
  formLoading.value = true
  formError.value   = ''
  try {
    const { profile_id, ...payload } = teacherForm.value
    if (!payload.first_name || !payload.last_name) throw new Error('กรุณากรอกชื่อ-นามสกุล')

    let teacherId = editId.value
    if (editId.value) {
      if (profile_id) payload.profile_id = profile_id
      const { error } = await supabase.from('teacher_profiles').update(payload).eq('id', editId.value)
      if (error) throw error
      if (profile_id) {
        await supabase.from('profiles').update({ role: 'teacher', is_approved: true }).eq('id', profile_id)
      }
    } else {
      payload.id = pendingNewId.value
      teacherId  = pendingNewId.value
      if (profile_id) payload.profile_id = profile_id
      const { error } = await supabase.from('teacher_profiles').insert(payload)
      if (error) throw error
      if (profile_id) {
        await supabase.from('profiles').update({ role: 'teacher', is_approved: true }).eq('id', profile_id)
      }
    }

    // บันทึก dept assignments — ลบเก่าแล้ว insert ใหม่
    await supabase.from('teacher_department_assignments').delete().eq('teacher_id', teacherId)
    const validDepts = deptAssignments.value.filter(d => d.department_name?.trim())
    if (validDepts.length) {
      await supabase.from('teacher_department_assignments').insert(
        validDepts.map(d => ({ teacher_id: teacherId, department_name: d.department_name, department_role: d.department_role || 'กรรมการ' }))
      )
    }

    closeForm()
    await loadTeachers()
  } catch (e) {
    formError.value = e.message
  } finally {
    formLoading.value = false
  }
}

// ── Delete ────────────────────────────────────────────────────
function confirmDelete(t) { deleteTarget.value = t }

async function deleteTeacher() {
  if (!deleteTarget.value) return
  formLoading.value = true
  try {
    const { error } = await supabase.from('teacher_profiles').delete().eq('id', deleteTarget.value.id)
    if (error) throw error
    deleteTarget.value = null
    await loadTeachers()
  } catch (e) {
    alert('ลบไม่สำเร็จ: ' + e.message)
  } finally {
    formLoading.value = false
  }
}

// ── Mount ─────────────────────────────────────────────────────
onMounted(async () => {
  await loadTeachers()
  const { data } = await supabase.from('profiles')
    .select('id, email, full_name')
    .in('role', ['teacher','pending'])
    .eq('is_approved', false)
  availableProfiles.value = data || []
})
</script>
