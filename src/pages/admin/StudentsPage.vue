<template>
  <AdminLayout>
    <div class="p-6">

      <!-- Header -->
      <div class="mb-6 flex items-start justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-800">จัดการนักเรียน</h1>
          <p class="text-gray-500 text-sm mt-1">นำเข้าข้อมูล DMC · ติดตามสถิติ · ดูประวัติเปรียบเทียบ</p>
        </div>
        <div v-if="latestImport" class="text-right text-xs text-gray-400 hidden md:block">
          นำเข้าล่าสุด<br/>
          <span class="font-semibold text-gray-600">{{ latestImport.label }}</span><br/>
          {{ formatDate(latestImport.imported_at) }}
        </div>
      </div>

      <!-- Tabs -->
      <div class="flex gap-1 bg-gray-100 p-1 rounded-xl w-fit mb-6">
        <button v-for="t in TABS" :key="t.key" @click="switchTab(t.key)"
          :class="['px-5 py-2 rounded-lg text-sm font-medium transition',
            activeTab === t.key ? 'bg-white shadow text-blue-700' : 'text-gray-500 hover:text-gray-700']">
          {{ t.icon }} {{ t.label }}
        </button>
      </div>

      <!-- ═══════════════════════════════════════ -->
      <!-- TAB 1: ข้อมูลปัจจุบัน                  -->
      <!-- ═══════════════════════════════════════ -->
      <template v-if="activeTab === 'current'">

        <!-- Summary Cards -->
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-5">
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 text-center">
            <div class="text-2xl font-bold text-blue-700">{{ activeCount.toLocaleString() }}</div>
            <div class="text-xs text-gray-500 mt-1">กำลังศึกษา</div>
          </div>
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 text-center">
            <div class="text-2xl font-bold text-green-600">{{ maleCount.toLocaleString() }}</div>
            <div class="text-xs text-gray-500 mt-1">ชาย</div>
          </div>
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 text-center">
            <div class="text-2xl font-bold text-pink-500">{{ femaleCount.toLocaleString() }}</div>
            <div class="text-xs text-gray-500 mt-1">หญิง</div>
          </div>
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 text-center">
            <div class="text-2xl font-bold text-gray-400">{{ inactiveCount.toLocaleString() }}</div>
            <div class="text-xs text-gray-500 mt-1">ออกจากระบบ</div>
          </div>
        </div>

        <!-- BMI Compact Dashboard (reactive ตาม fGrade/fRoom) -->
        <div v-if="bmiStats.length > 0" class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-5">
          <div class="flex items-center justify-between mb-3">
            <div class="flex items-center gap-2">
              <span class="text-sm font-semibold text-gray-700">🏥 สุขภาพ BMI</span>
              <span class="text-xs text-gray-400 bg-gray-50 px-2 py-0.5 rounded-full">
                {{ bmiStats.length.toLocaleString() }} คน · เฉลี่ย <strong>{{ bmiAvg?.toFixed(1) }}</strong>
              </span>
            </div>
            <button @click="switchTab('health')" class="text-xs text-blue-500 hover:text-blue-700 transition">รายละเอียด →</button>
          </div>

          <!-- Stacked bar -->
          <div class="flex h-7 rounded-xl overflow-hidden gap-px mb-3">
            <div v-for="cat in BMI_CATS" :key="cat.key"
              :class="[cat.color, 'transition-all duration-700 flex items-center justify-center overflow-hidden']"
              :style="{ width: `${Math.max(0,(bmiCounts[cat.key]||0)/bmiStats.length*100)}%` }"
              :title="`${cat.key}: ${bmiCounts[cat.key]||0} คน (${((bmiCounts[cat.key]||0)/bmiStats.length*100).toFixed(1)}%)`">
              <span v-if="(bmiCounts[cat.key]||0)/bmiStats.length > 0.08" class="text-white text-xs font-bold drop-shadow">
                {{ ((bmiCounts[cat.key]||0)/bmiStats.length*100).toFixed(0) }}%
              </span>
            </div>
          </div>

          <!-- Legend cards -->
          <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
            <div v-for="cat in BMI_CATS" :key="'leg-'+cat.key"
              :class="['flex items-center justify-between rounded-lg px-3 py-2 border', cat.light, cat.border]">
              <div class="flex items-center gap-1.5">
                <div :class="['w-2 h-2 rounded-full flex-shrink-0', cat.color]"></div>
                <span class="text-xs text-gray-700 font-medium">{{ cat.key }}</span>
              </div>
              <div class="text-right">
                <span :class="['text-sm font-bold', cat.text]">{{ (bmiCounts[cat.key]||0).toLocaleString() }}</span>
                <span class="text-[10px] text-gray-400 ml-1">{{ bmiStats.length ? ((bmiCounts[cat.key]||0)/bmiStats.length*100).toFixed(0) : 0 }}%</span>
              </div>
            </div>
          </div>

          <!-- ไม่มีข้อมูล notice -->
          <div v-if="noWeightCount > 0" class="mt-2 text-[11px] text-amber-600 text-center">
            ⚠️ {{ noWeightCount.toLocaleString() }} คน ไม่มีข้อมูลน้ำหนัก/ส่วนสูง
          </div>
        </div>
        <div v-else-if="loadingBMI" class="bg-gray-50 rounded-xl p-3 mb-5 text-center text-xs text-gray-400 animate-pulse">
          กำลังโหลดข้อมูล BMI...
        </div>

        <!-- Filter bar -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-4">
          <div class="flex flex-wrap items-end gap-3">
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium text-gray-600">ชั้น</label>
              <select v-model="fGrade" @change="fRoom=''; curPage=1"
                class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 min-w-[130px]">
                <option value="">ทุกชั้น</option>
                <option v-for="g in gradeOpts" :key="g" :value="g">{{ g }}</option>
              </select>
            </div>
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium text-gray-600">ห้อง</label>
              <select v-model="fRoom" :disabled="!fGrade" @change="curPage=1"
                class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 min-w-[110px] disabled:bg-gray-50 disabled:text-gray-400">
                <option value="">ทุกห้อง</option>
                <option v-for="r in roomOpts" :key="r" :value="r">ห้อง {{ r }}</option>
              </select>
            </div>
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium text-gray-600">สถานะ</label>
              <select v-model="fActive" @change="curPage=1"
                class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
                <option value="true">กำลังศึกษา</option>
                <option value="false">ออกแล้ว</option>
                <option value="">ทั้งหมด</option>
              </select>
            </div>
            <div class="flex flex-col gap-1 flex-1 min-w-[160px]">
              <label class="text-xs font-medium text-gray-600">ค้นหา</label>
              <input v-model="fSearch" @input="curPage=1" type="text" placeholder="ชื่อ / รหัส..."
                class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
            </div>
            <div class="flex items-end gap-2 ml-auto">
              <select v-model="pageSize" @change="curPage=1"
                class="border border-gray-300 rounded-lg px-2 py-2 text-sm">
                <option :value="20">20</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
                <option :value="9999">ทั้งหมด</option>
              </select>
              <button @click="exportCurrentExcel" :disabled="filteredStudents.length===0"
                class="bg-green-600 hover:bg-green-700 disabled:bg-gray-300 text-white text-sm px-4 py-2 rounded-lg flex items-center gap-2 transition">
                📥 Export
              </button>
              <button @click="openAdd"
                class="bg-blue-600 hover:bg-blue-700 text-white text-sm px-4 py-2 rounded-lg flex items-center gap-2 transition">
                ➕ เพิ่มนักเรียน
              </button>
            </div>
          </div>
        </div>

        <!-- Table -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="flex items-center justify-between px-4 py-2 bg-gray-50 border-b text-xs text-gray-500">
            <span>ทั้งหมด <strong class="text-gray-800">{{ filteredStudents.length.toLocaleString() }}</strong> คน</span>
            <span v-if="totalPages > 1">หน้า {{ curPage }} / {{ totalPages }}</span>
          </div>
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-blue-50 border-b border-blue-100">
                <tr>
                  <th class="px-3 py-3 text-center text-xs font-semibold text-blue-700 w-10">#</th>
                  <th class="px-3 py-3 text-left   text-xs font-semibold text-blue-700">รหัส</th>
                  <th class="px-3 py-3 text-left   text-xs font-semibold text-blue-700">เลขบัตรประชาชน</th>
                  <th class="px-3 py-3 text-left   text-xs font-semibold text-blue-700">ชื่อ-นามสกุล</th>
                  <th class="px-3 py-3 text-center text-xs font-semibold text-blue-700">เพศ</th>
                  <th class="px-3 py-3 text-center text-xs font-semibold text-blue-700">ชั้น</th>
                  <th class="px-3 py-3 text-center text-xs font-semibold text-blue-700">ห้อง</th>
                  <th class="px-3 py-3 text-center text-xs font-semibold text-blue-700">สถานะ</th>
                  <th class="px-3 py-3 text-center text-xs font-semibold text-blue-700 w-20">จัดการ</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                <tr v-if="loadingStudents">
                  <td colspan="9" class="text-center py-12 text-gray-400 animate-pulse">กำลังโหลด...</td>
                </tr>
                <template v-else>
                  <tr v-for="(s, i) in pagedStudents" :key="s.student_code || i"
                    class="hover:bg-blue-50/40 transition cursor-pointer"
                    @click="openEdit(s)">
                    <td class="px-3 py-2.5 text-center text-gray-400 text-xs">{{ (curPage-1)*pageSize+i+1 }}</td>
                    <td class="px-3 py-2.5 font-mono text-gray-600 text-xs">{{ s.student_code }}</td>
                    <td class="px-3 py-2.5 font-mono text-gray-500 text-xs">{{ s.national_id || '-' }}</td>
                    <td class="px-3 py-2.5">
                      <span class="text-gray-500 text-xs mr-1">{{ s.prefix }}</span>
                      <span class="font-medium text-gray-800">{{ s.first_name }} {{ s.last_name }}</span>
                    </td>
                    <td class="px-3 py-2.5 text-center text-xs text-gray-600">{{ getGender(s) || '-' }}</td>
                    <td class="px-3 py-2.5 text-center text-gray-700">{{ s.grade_level }}</td>
                    <td class="px-3 py-2.5 text-center text-gray-700">{{ s.room }}</td>
                    <td class="px-3 py-2.5 text-center">
                      <span :class="s.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
                        class="px-2 py-0.5 rounded-full text-xs font-medium">
                        {{ s.is_active ? 'กำลังศึกษา' : 'ออกแล้ว' }}
                      </span>
                    </td>
                    <td class="px-3 py-2.5 text-center" @click.stop>
                      <button @click="openEdit(s)"
                        class="text-blue-500 hover:text-blue-700 text-xs px-2 py-1 rounded hover:bg-blue-50 transition">✏️</button>
                      <button @click="confirmDelete(s)"
                        class="text-red-400 hover:text-red-600 text-xs px-2 py-1 rounded hover:bg-red-50 transition ml-1">🗑️</button>
                    </td>
                  </tr>
                  <tr v-if="!loadingStudents && pagedStudents.length===0">
                    <td colspan="9" class="text-center py-12 text-gray-400">ไม่พบข้อมูล</td>
                  </tr>
                </template>
              </tbody>
            </table>
          </div>
          <!-- Pagination -->
          <div v-if="totalPages > 1" class="flex items-center justify-between px-4 py-3 border-t bg-gray-50">
            <span class="text-xs text-gray-500">แสดง {{ pageStart }}–{{ pageEnd }} จาก {{ filteredStudents.length.toLocaleString() }} คน</span>
            <div class="flex gap-1">
              <button @click="curPage=1"         :disabled="curPage===1"         class="px-2 py-1 text-xs border rounded hover:bg-gray-100 disabled:opacity-40">«</button>
              <button @click="curPage--"          :disabled="curPage===1"         class="px-3 py-1 text-xs border rounded hover:bg-gray-100 disabled:opacity-40">‹</button>
              <button v-for="p in pageButtons" :key="p" @click="curPage=p"
                :class="['px-3 py-1 text-xs border rounded transition', p===curPage ? 'bg-blue-600 text-white border-blue-600':'hover:bg-gray-100']">{{ p }}</button>
              <button @click="curPage++"          :disabled="curPage===totalPages" class="px-3 py-1 text-xs border rounded hover:bg-gray-100 disabled:opacity-40">›</button>
              <button @click="curPage=totalPages" :disabled="curPage===totalPages" class="px-2 py-1 text-xs border rounded hover:bg-gray-100 disabled:opacity-40">»</button>
            </div>
          </div>
        </div>
      </template>

      <!-- ═══════════════════════════════════════ -->
      <!-- TAB 2: นำเข้า DMC                      -->
      <!-- ═══════════════════════════════════════ -->
      <template v-if="activeTab === 'import'">
        <div class="max-w-3xl">

          <!-- Step indicator -->
          <div class="flex items-center mb-8">
            <template v-for="(label, i) in IMPORT_STEPS" :key="label">
              <div class="flex items-center gap-2">
                <div :class="['w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold shrink-0 transition',
                  importStep > i+1 ? 'bg-blue-600 text-white' :
                  importStep === i+1 ? 'bg-blue-600 text-white ring-4 ring-blue-200' :
                  'bg-gray-200 text-gray-500']">
                  {{ importStep > i+1 ? '✓' : i+1 }}
                </div>
                <span :class="['text-xs font-medium hidden sm:block', importStep===i+1 ? 'text-blue-700':'text-gray-400']">{{ label }}</span>
              </div>
              <div v-if="i < IMPORT_STEPS.length-1" class="flex-1 h-px bg-gray-200 mx-2 min-w-[12px]"></div>
            </template>
          </div>

          <!-- Step 1: อัปโหลด -->
          <div v-if="importStep===1" class="bg-white rounded-xl shadow-sm border border-gray-100 p-8">
            <h2 class="font-semibold text-gray-800 mb-1">อัปโหลดไฟล์ Excel DMC</h2>
            <p class="text-sm text-gray-500 mb-6">รองรับไฟล์ .xlsx / .xls ที่ export จากระบบ DMC</p>
            <label class="block border-2 border-dashed border-blue-300 rounded-xl p-12 text-center cursor-pointer hover:bg-blue-50 transition">
              <input type="file" accept=".xlsx,.xls,.csv" class="hidden" @change="handleFileUpload" />
              <div class="text-5xl mb-3">📂</div>
              <div class="text-sm font-semibold text-blue-600">คลิกเพื่อเลือกไฟล์</div>
              <div class="text-xs text-gray-400 mt-1">หรือลากไฟล์มาวางที่นี่</div>
              <div class="text-xs text-gray-300 mt-3">.xlsx .xls .csv</div>
            </label>
            <p v-if="fileError" class="text-red-500 text-sm mt-3">⚠️ {{ fileError }}</p>
          </div>

          <!-- Step 2: Column mapping + metadata -->
          <div v-if="importStep===2" class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 class="font-semibold text-gray-800 mb-1">ตรวจสอบ Column และข้อมูลการนำเข้า</h2>
            <p class="text-sm text-gray-500 mb-5">ตรวจสอบการจับคู่คอลัมน์ และกรอกข้อมูลรอบการนำเข้า</p>

            <div class="bg-gray-50 rounded-xl p-4 mb-5 grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1 col-span-2">
                <label class="text-xs font-medium text-gray-600">ชื่อรอบการนำเข้า <span class="text-red-400">*</span></label>
                <input v-model="importMeta.label" type="text" placeholder="เช่น ภาคเรียนที่ 1/2567"
                  class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
              </div>
              <div class="flex flex-col gap-1">
                <label class="text-xs font-medium text-gray-600">ปีการศึกษา (พ.ศ.) <span class="text-red-400">*</span></label>
                <input v-model.number="importMeta.academic_year" type="number" placeholder="2567"
                  class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
              </div>
              <div class="flex flex-col gap-1">
                <label class="text-xs font-medium text-gray-600">ภาคเรียน <span class="text-red-400">*</span></label>
                <select v-model.number="importMeta.semester"
                  class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
                  <option :value="1">ภาคเรียนที่ 1</option>
                  <option :value="2">ภาคเรียนที่ 2</option>
                </select>
              </div>
              <div class="flex flex-col gap-1 col-span-2">
                <label class="text-xs font-medium text-gray-600">หมายเหตุ</label>
                <input v-model="importMeta.note" type="text" placeholder="หมายเหตุเพิ่มเติม (ถ้ามี)"
                  class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
              </div>
            </div>

            <div class="mb-5">
              <div class="flex items-center justify-between mb-2">
                <span class="text-xs font-medium text-gray-600">การจับคู่คอลัมน์</span>
                <span :class="['text-xs font-medium', mappedRequired===REQUIRED_COLS.length ? 'text-green-600':'text-orange-500']">
                  {{ mappedRequired }}/{{ REQUIRED_COLS.length }} คอลัมน์จำเป็น
                </span>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 max-h-72 overflow-y-auto pr-1">
                <div v-for="col in DB_COLS" :key="col.key" class="flex items-center gap-2 bg-gray-50 rounded-lg p-2.5">
                  <span class="text-xs text-gray-500 w-28 shrink-0">
                    {{ col.label }}<span v-if="col.required" class="text-red-400 ml-0.5">*</span>
                  </span>
                  <select v-model="colMapping[col.key]"
                    :class="['flex-1 border rounded px-2 py-1 text-xs focus:outline-none',
                      col.required && !colMapping[col.key] ? 'border-red-300 bg-red-50':'border-gray-300 bg-white']">
                    <option value="">-- ไม่ใช้ --</option>
                    <option v-for="h in excelHeaders" :key="h" :value="h">{{ h }}</option>
                  </select>
                  <span v-if="colMapping[col.key]" class="text-green-500 shrink-0">✓</span>
                  <span v-else-if="col.required" class="text-red-400 shrink-0 text-xs">!</span>
                </div>
              </div>
            </div>

            <div class="flex gap-3 justify-end">
              <button @click="importStep=1" class="px-4 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50">← ย้อนกลับ</button>
              <button @click="goToPreview" :disabled="!canProceed"
                class="px-6 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed">
                ดูตัวอย่าง →
              </button>
            </div>
          </div>

          <!-- Step 3: Preview -->
          <div v-if="importStep===3" class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 class="font-semibold text-gray-800 mb-1">ตัวอย่างข้อมูลที่จะนำเข้า</h2>
            <p class="text-sm text-gray-500 mb-5">ตรวจสอบก่อนยืนยัน</p>

            <div class="grid grid-cols-3 gap-3 mb-5">
              <div class="bg-blue-50 rounded-xl p-4 text-center">
                <div class="text-2xl font-bold text-blue-700">{{ parsedRows.length.toLocaleString() }}</div>
                <div class="text-xs text-gray-500 mt-1">รายการทั้งหมด</div>
              </div>
              <div class="bg-green-50 rounded-xl p-4 text-center">
                <div class="text-2xl font-bold text-green-600">{{ previewGender.male.toLocaleString() }}</div>
                <div class="text-xs text-gray-500 mt-1">ชาย</div>
              </div>
              <div class="bg-pink-50 rounded-xl p-4 text-center">
                <div class="text-2xl font-bold text-pink-500">{{ previewGender.female.toLocaleString() }}</div>
                <div class="text-xs text-gray-500 mt-1">หญิง</div>
              </div>
            </div>

            <div class="mb-5">
              <div class="text-xs font-medium text-gray-600 mb-2">จำนวนแยกตามชั้น</div>
              <div class="space-y-1.5">
                <div v-for="g in previewByGrade" :key="g.grade" class="flex items-center gap-3">
                  <span class="text-xs text-gray-600 w-12 text-right shrink-0">{{ g.grade }}</span>
                  <div class="flex-1 bg-gray-100 rounded-full h-5 overflow-hidden">
                    <div class="bg-blue-400 h-full rounded-full transition-all"
                      :style="{width:`${(g.count/parsedRows.length*100).toFixed(1)}%`}"></div>
                  </div>
                  <span class="text-xs font-medium text-gray-700 w-14 shrink-0">{{ g.count }} คน</span>
                </div>
              </div>
            </div>

            <div class="mb-5">
              <div class="text-xs font-medium text-gray-600 mb-2">ตัวอย่าง 5 แถวแรก</div>
              <div class="overflow-x-auto rounded-lg border border-gray-200">
                <table class="w-full text-xs">
                  <thead class="bg-gray-50 border-b">
                    <tr>
                      <th class="px-3 py-2 text-left text-gray-600">รหัส</th>
                      <th class="px-3 py-2 text-left text-gray-600">ชื่อ-นามสกุล</th>
                      <th class="px-3 py-2 text-center text-gray-600">ชั้น</th>
                      <th class="px-3 py-2 text-center text-gray-600">ห้อง</th>
                      <th class="px-3 py-2 text-center text-gray-600">เพศ</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-100">
                    <tr v-for="(r,i) in parsedRows.slice(0,5)" :key="i" class="hover:bg-gray-50">
                      <td class="px-3 py-2 font-mono">{{ r.student_code }}</td>
                      <td class="px-3 py-2">{{ r.prefix }}{{ r.first_name }} {{ r.last_name }}</td>
                      <td class="px-3 py-2 text-center">{{ r.grade_level }}</td>
                      <td class="px-3 py-2 text-center">{{ r.room }}</td>
                      <td class="px-3 py-2 text-center">{{ r.gender }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <div class="bg-amber-50 border border-amber-200 rounded-lg p-3 mb-5 text-xs text-amber-700">
              ⚠️ การนำเข้าจะ <strong>อัปเดตข้อมูลนักเรียนปัจจุบัน</strong> และนักเรียนที่ไม่อยู่ในไฟล์จะถูกทำเครื่องหมาย <strong>"ออกแล้ว"</strong> โดยอัตโนมัติ
            </div>

            <div class="flex gap-3 justify-end">
              <button @click="importStep=2" class="px-4 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50">← ย้อนกลับ</button>
              <button @click="executeImport"
                class="px-6 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 flex items-center gap-2">
                ✅ ยืนยันนำเข้า {{ parsedRows.length.toLocaleString() }} รายการ
              </button>
            </div>
          </div>

          <!-- Step 4: Processing / Done -->
          <div v-if="importStep===4" class="bg-white rounded-xl shadow-sm border border-gray-100 p-10 text-center">
            <template v-if="importDone">
              <div class="text-6xl mb-4">🎉</div>
              <h2 class="font-bold text-gray-800 text-lg mb-2">นำเข้าสำเร็จ!</h2>
              <p class="text-gray-500 text-sm mb-1">นำเข้าข้อมูล <strong class="text-blue-700">{{ parsedRows.length.toLocaleString() }}</strong> รายการเรียบร้อย</p>
              <p class="text-gray-400 text-xs mb-8">{{ importMeta.label }} · ปีการศึกษา {{ importMeta.academic_year }} ภาคเรียนที่ {{ importMeta.semester }}</p>
              <div class="flex justify-center gap-3">
                <button @click="resetImport" class="px-5 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50">นำเข้าอีกครั้ง</button>
                <button @click="switchTab('current')" class="px-5 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700">ดูข้อมูลปัจจุบัน →</button>
              </div>
            </template>
            <template v-else>
              <div class="animate-spin rounded-full h-14 w-14 border-b-4 border-blue-600 mx-auto mb-5"></div>
              <h2 class="font-semibold text-gray-700 mb-3">กำลังนำเข้าข้อมูล...</h2>
              <div class="w-full max-w-xs mx-auto bg-gray-200 rounded-full h-2.5 mb-2">
                <div class="bg-blue-600 h-2.5 rounded-full transition-all duration-300"
                  :style="{width:`${importProgress}%`}"></div>
              </div>
              <p class="text-sm text-gray-500 mt-1">{{ importProgress }}% · {{ importStatus }}</p>
            </template>
          </div>

        </div>
      </template>

      <!-- ═══════════════════════════════════════ -->
      <!-- TAB 3: ประวัติ / เปรียบเทียบ           -->
      <!-- ═══════════════════════════════════════ -->
      <template v-if="activeTab === 'history'">
        <div v-if="loadingHistory" class="text-center py-16 text-gray-400 animate-pulse">กำลังโหลด...</div>
        <div v-else-if="imports.length===0" class="text-center py-20">
          <div class="text-5xl mb-4">📭</div>
          <p class="text-gray-400">ยังไม่มีประวัติการนำเข้าข้อมูล</p>
          <button @click="switchTab('import')" class="mt-4 px-5 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700">
            เริ่มนำเข้า DMC
          </button>
        </div>
        <template v-else>

          <!-- Trend bar chart -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5 mb-5">
            <div class="font-semibold text-gray-700 mb-4 text-sm">แนวโน้มจำนวนนักเรียน</div>
            <div class="flex items-end gap-3 overflow-x-auto pb-2" style="min-height:130px">
              <div v-for="imp in chronologicalImports" :key="imp.id"
                class="flex flex-col items-center gap-1 flex-1 min-w-[60px]">
                <span class="text-xs font-bold text-blue-700">{{ imp.total_count.toLocaleString() }}</span>
                <div class="w-full bg-blue-400 rounded-t"
                  :style="{height:`${Math.max(8, Math.round(imp.total_count / maxCount * 100))}px`}"></div>
                <span class="text-xs text-gray-500 text-center leading-tight">
                  {{ imp.label.replace('ภาคเรียนที่','เทอม').replace('ภาคเรียน','เทอม') }}
                </span>
              </div>
            </div>
          </div>

          <!-- Comparison table -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div class="px-5 py-4 border-b border-gray-100 font-semibold text-gray-700 text-sm">รายการนำเข้าทั้งหมด</div>
            <div class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead class="bg-gray-50 border-b text-xs text-gray-600">
                  <tr>
                    <th class="px-4 py-3 text-left">รอบการนำเข้า</th>
                    <th class="px-4 py-3 text-center">ปีการศึกษา</th>
                    <th class="px-4 py-3 text-center">ภาค</th>
                    <th class="px-4 py-3 text-center">รวม</th>
                    <th class="px-4 py-3 text-center">ชาย</th>
                    <th class="px-4 py-3 text-center">หญิง</th>
                    <th class="px-4 py-3 text-center">เปลี่ยนแปลง</th>
                    <th class="px-4 py-3 text-center">วันที่นำเข้า</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                  <tr v-for="(imp, idx) in imports" :key="imp.id" class="hover:bg-gray-50 transition">
                    <td class="px-4 py-3 font-medium text-gray-800">{{ imp.label }}</td>
                    <td class="px-4 py-3 text-center text-gray-600">{{ imp.academic_year }}</td>
                    <td class="px-4 py-3 text-center text-gray-600">{{ imp.semester }}</td>
                    <td class="px-4 py-3 text-center font-bold text-blue-700">{{ imp.total_count.toLocaleString() }}</td>
                    <td class="px-4 py-3 text-center text-green-600">{{ imp.male_count ?? '-' }}</td>
                    <td class="px-4 py-3 text-center text-pink-500">{{ imp.female_count ?? '-' }}</td>
                    <td class="px-4 py-3 text-center">
                      <template v-if="idx < imports.length-1">
                        <span :class="['text-xs font-medium px-2 py-0.5 rounded-full',
                          imp.total_count > imports[idx+1].total_count ? 'bg-green-100 text-green-700' :
                          imp.total_count < imports[idx+1].total_count ? 'bg-red-100 text-red-600' :
                          'bg-gray-100 text-gray-500']">
                          {{ imp.total_count > imports[idx+1].total_count ? '+' : '' }}{{ imp.total_count - imports[idx+1].total_count }}
                        </span>
                      </template>
                      <span v-else class="text-xs text-gray-300">–</span>
                    </td>
                    <td class="px-4 py-3 text-center text-xs text-gray-400">{{ formatDate(imp.imported_at) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>
      </template>

      <!-- ═══════════════════════════════════════ -->
      <!-- TAB 4: สุขภาพ BMI                       -->
      <!-- ═══════════════════════════════════════ -->
      <template v-if="activeTab === 'health'">
        <div v-if="loadingBMI" class="text-center py-16 text-gray-400 animate-pulse">กำลังโหลด...</div>
        <div v-else-if="bmiData.length === 0" class="text-center py-20">
          <div class="text-5xl mb-4">⚖️</div>
          <p class="text-gray-500 font-medium">ยังไม่มีข้อมูลน้ำหนัก/ส่วนสูง</p>
          <p class="text-gray-400 text-sm mt-1">กรุณานำเข้าไฟล์ DMC ที่มีคอลัมน์น้ำหนักและส่วนสูง</p>
          <button @click="switchTab('import')" class="mt-4 px-5 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700">นำเข้า DMC →</button>
        </div>
        <template v-else>

          <!-- ตัวกรอง (ใช้ร่วมกับ tab ข้อมูลปัจจุบัน) -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-5">
            <div class="flex flex-wrap items-end gap-3">
              <div class="flex flex-col gap-1">
                <label class="text-xs font-medium text-gray-600">ชั้น</label>
                <select v-model="fGrade" @change="fRoom=''"
                  class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 min-w-[130px]">
                  <option value="">ทุกชั้น</option>
                  <option v-for="g in gradeOpts" :key="g" :value="g">{{ g }}</option>
                </select>
              </div>
              <div class="flex flex-col gap-1">
                <label class="text-xs font-medium text-gray-600">ห้อง</label>
                <select v-model="fRoom" :disabled="!fGrade"
                  class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 min-w-[110px] disabled:bg-gray-50 disabled:text-gray-400">
                  <option value="">ทุกห้อง</option>
                  <option v-for="r in roomOpts" :key="r" :value="r">ห้อง {{ r }}</option>
                </select>
              </div>
              <div class="ml-auto text-right text-xs text-gray-400">
                นักเรียนปัจจุบัน · น้ำหนัก/ส่วนสูงล่าสุดที่บันทึก
              </div>
            </div>
          </div>

          <!-- แจ้งเตือนไม่มีน้ำหนัก/ส่วนสูง -->
          <div v-if="noWeightCount > 0" class="bg-amber-50 border border-amber-200 rounded-xl px-4 py-3 mb-5 text-xs text-amber-700">
            ⚠️ มีนักเรียน <strong>{{ noWeightCount.toLocaleString() }}</strong> คน ที่ไม่มีข้อมูลน้ำหนัก/ส่วนสูง — ไม่นับในการคำนวณ BMI
          </div>

          <!-- Summary Cards -->
          <div class="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-3 mb-5">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 text-center sm:col-span-1">
              <div class="text-xl font-bold text-gray-700">{{ bmiStats.length.toLocaleString() }}</div>
              <div class="text-xs text-gray-400 mt-0.5">มีข้อมูล BMI</div>
            </div>
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 text-center">
              <div class="text-xl font-bold text-blue-700">{{ bmiAvg !== null ? bmiAvg.toFixed(1) : '-' }}</div>
              <div class="text-xs text-gray-400 mt-0.5">BMI เฉลี่ย</div>
            </div>
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 text-center">
              <div class="text-xl font-bold text-indigo-600">{{ avgWeight !== null ? avgWeight.toFixed(1) : '-' }}</div>
              <div class="text-xs text-gray-400 mt-0.5">น้ำหนักเฉลี่ย กก.</div>
            </div>
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 text-center">
              <div class="text-xl font-bold text-teal-600">{{ avgHeight !== null ? avgHeight.toFixed(1) : '-' }}</div>
              <div class="text-xs text-gray-400 mt-0.5">ส่วนสูงเฉลี่ย ซม.</div>
            </div>
            <div v-for="cat in BMI_CATS" :key="cat.key"
              :class="['rounded-xl shadow-sm border p-4 text-center', cat.light, cat.border]">
              <div :class="['text-xl font-bold', cat.text]">{{ (bmiCounts[cat.key]||0).toLocaleString() }}</div>
              <div class="text-xs text-gray-500 mt-0.5">{{ cat.key }}</div>
              <div :class="['text-[10px] mt-0.5', cat.text]">
                {{ bmiStats.length ? ((bmiCounts[cat.key]||0)/bmiStats.length*100).toFixed(1) : 0 }}%
              </div>
            </div>
          </div>

          <!-- Main Content: Distribution + By Grade -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-5 mb-5">

            <!-- Distribution Bar -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
              <div class="font-semibold text-gray-700 mb-5 text-sm flex items-center gap-2">
                📊 การกระจายตัว BMI
              </div>
              <div class="space-y-4">
                <div v-for="cat in BMI_CATS" :key="cat.key">
                  <div class="flex items-center justify-between mb-1.5">
                    <div class="flex items-center gap-2">
                      <div :class="['w-2.5 h-2.5 rounded-full flex-shrink-0', cat.color]"></div>
                      <span class="text-sm font-medium text-gray-700">{{ cat.key }}</span>
                    </div>
                    <div class="flex items-center gap-2">
                      <span class="text-sm font-bold text-gray-800">{{ (bmiCounts[cat.key]||0).toLocaleString() }}</span>
                      <span :class="['text-xs px-2 py-0.5 rounded-full font-medium', cat.light, cat.text]">
                        {{ bmiStats.length ? ((bmiCounts[cat.key]||0)/bmiStats.length*100).toFixed(1) : 0 }}%
                      </span>
                    </div>
                  </div>
                  <div class="w-full bg-gray-100 rounded-full h-5 overflow-hidden">
                    <div :class="[cat.color, 'h-full rounded-full transition-all duration-700 flex items-center justify-end pr-2']"
                      :style="{ width: bmiStats.length ? `${Math.max(2,(bmiCounts[cat.key]||0)/bmiStats.length*100)}%` : '0%' }">
                    </div>
                  </div>
                </div>
              </div>

              <!-- เพศ BMI summary -->
              <div class="mt-6 pt-4 border-t border-gray-100 grid grid-cols-2 gap-3">
                <div class="text-center">
                  <div class="text-xs text-gray-500 mb-1">ชาย ({{ bmiGender.male.length }} คน)</div>
                  <div class="text-lg font-bold text-blue-600">
                    {{ bmiGender.male.length ? (bmiGender.male.reduce((a,s)=>a+s.bmi,0)/bmiGender.male.length).toFixed(1) : '-' }}
                  </div>
                  <div class="text-xs text-gray-400">BMI เฉลี่ย</div>
                </div>
                <div class="text-center">
                  <div class="text-xs text-gray-500 mb-1">หญิง ({{ bmiGender.female.length }} คน)</div>
                  <div class="text-lg font-bold text-pink-500">
                    {{ bmiGender.female.length ? (bmiGender.female.reduce((a,s)=>a+s.bmi,0)/bmiGender.female.length).toFixed(1) : '-' }}
                  </div>
                  <div class="text-xs text-gray-400">BMI เฉลี่ย</div>
                </div>
              </div>
            </div>

            <!-- By Grade Table -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
              <div class="font-semibold text-gray-700 mb-4 text-sm flex items-center gap-2">
                🏫 จำแนกตามชั้นเรียน
              </div>
              <div v-if="bmiByGrade.length === 0" class="text-center py-10 text-gray-300 text-sm">ไม่มีข้อมูล</div>
              <div v-else class="overflow-x-auto">
                <table class="w-full text-xs">
                  <thead>
                    <tr class="bg-gray-50 border-b border-gray-100">
                      <th class="px-3 py-2.5 text-left font-semibold text-gray-600">ชั้น</th>
                      <th class="px-2 py-2.5 text-center font-semibold text-gray-500">จำนวน</th>
                      <th class="px-2 py-2.5 text-center font-semibold text-blue-500">ผอม</th>
                      <th class="px-2 py-2.5 text-center font-semibold text-green-600">สมส่วน</th>
                      <th class="px-2 py-2.5 text-center font-semibold text-amber-500">เกิน</th>
                      <th class="px-2 py-2.5 text-center font-semibold text-red-500">อ้วน</th>
                      <th class="px-2 py-2.5 text-center font-semibold text-gray-500">BMI เฉลี่ย</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-50">
                    <tr v-for="g in bmiByGrade" :key="g.grade" class="hover:bg-gray-50 transition">
                      <td class="px-3 py-2.5 font-semibold text-gray-800">{{ g.grade }}</td>
                      <td class="px-2 py-2.5 text-center text-gray-600 font-medium">{{ g.total }}</td>
                      <td class="px-2 py-2.5 text-center text-blue-500">{{ g['ผอม'] || 0 }}</td>
                      <td class="px-2 py-2.5 text-center text-green-600">{{ g['สมส่วน'] || 0 }}</td>
                      <td class="px-2 py-2.5 text-center text-amber-500">{{ g['น้ำหนักเกิน'] || 0 }}</td>
                      <td class="px-2 py-2.5 text-center text-red-500">{{ g['อ้วน'] || 0 }}</td>
                      <td class="px-2 py-2.5 text-center font-mono font-semibold text-gray-700">
                        {{ g.total ? (g.bmiSum/g.total).toFixed(1) : '-' }}
                      </td>
                    </tr>
                  </tbody>
                  <!-- Footer -->
                  <tfoot class="border-t-2 border-gray-200 bg-gray-50">
                    <tr>
                      <td class="px-3 py-2.5 font-bold text-gray-700">รวม</td>
                      <td class="px-2 py-2.5 text-center font-bold text-gray-700">{{ bmiStats.length }}</td>
                      <td class="px-2 py-2.5 text-center font-bold text-blue-500">{{ bmiCounts['ผอม'] || 0 }}</td>
                      <td class="px-2 py-2.5 text-center font-bold text-green-600">{{ bmiCounts['สมส่วน'] || 0 }}</td>
                      <td class="px-2 py-2.5 text-center font-bold text-amber-500">{{ bmiCounts['น้ำหนักเกิน'] || 0 }}</td>
                      <td class="px-2 py-2.5 text-center font-bold text-red-500">{{ bmiCounts['อ้วน'] || 0 }}</td>
                      <td class="px-2 py-2.5 text-center font-mono font-bold text-gray-700">{{ bmiAvg !== null ? bmiAvg.toFixed(1) : '-' }}</td>
                    </tr>
                  </tfoot>
                </table>
              </div>

              <!-- Mini bar by grade -->
              <div v-if="bmiByGrade.length > 0" class="mt-4 pt-4 border-t border-gray-100">
                <div class="text-xs font-medium text-gray-500 mb-3">BMI เฉลี่ยแต่ละชั้น</div>
                <div class="space-y-1.5">
                  <div v-for="g in bmiByGrade" :key="'bar-'+g.grade" class="flex items-center gap-2">
                    <span class="text-xs text-gray-500 w-10 text-right shrink-0">{{ g.grade }}</span>
                    <div class="flex-1 bg-gray-100 rounded-full h-4 overflow-hidden">
                      <div class="h-full rounded-full transition-all duration-500"
                        :class="g.total&&(g.bmiSum/g.total)<18.5?'bg-blue-400':g.total&&(g.bmiSum/g.total)<23?'bg-green-400':g.total&&(g.bmiSum/g.total)<27.5?'bg-amber-400':'bg-red-400'"
                        :style="{ width: g.total ? `${Math.min(100, (g.bmiSum/g.total)/40*100)}%` : '0%' }">
                      </div>
                    </div>
                    <span class="text-xs font-mono font-medium text-gray-600 w-8 shrink-0">{{ g.total ? (g.bmiSum/g.total).toFixed(1) : '-' }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- BMI Reference -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <div class="font-semibold text-gray-700 mb-3 text-sm">📋 เกณฑ์การประเมิน BMI (มาตรฐานไทย)</div>
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
              <div v-for="cat in BMI_CATS" :key="'ref-'+cat.key"
                :class="['rounded-xl p-3 border', cat.light, cat.border]">
                <div :class="['w-3 h-3 rounded-full mb-2', cat.color]"></div>
                <div :class="['text-sm font-bold', cat.text]">{{ cat.key }}</div>
                <div class="text-xs text-gray-500 mt-0.5">
                  <template v-if="cat.key==='ผอม'">BMI &lt; 18.5</template>
                  <template v-else-if="cat.key==='สมส่วน'">18.5 – 22.9</template>
                  <template v-else-if="cat.key==='น้ำหนักเกิน'">23.0 – 27.4</template>
                  <template v-else>BMI ≥ 27.5</template>
                </div>
              </div>
            </div>
          </div>

        </template>
      </template>

    </div>
  </AdminLayout>

  <!-- ═══════════════════════════════════════════════ -->
  <!-- Modal: เพิ่ม / แก้ไขนักเรียน                   -->
  <!-- ═══════════════════════════════════════════════ -->
  <Teleport to="body">
    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4"
      @click.self="showModal=false">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">

        <!-- Modal Header -->
        <div class="sticky top-0 bg-white border-b border-gray-100 px-6 py-4 flex items-center justify-between rounded-t-2xl">
          <h2 class="font-bold text-gray-800 text-base">
            {{ isAdding ? '➕ เพิ่มนักเรียนใหม่' : '✏️ แก้ไขข้อมูลนักเรียน' }}
          </h2>
          <button @click="showModal=false" class="text-gray-400 hover:text-gray-600 text-xl leading-none">✕</button>
        </div>

        <!-- Modal Body -->
        <div class="px-6 py-5 grid grid-cols-2 gap-4">

          <!-- รหัสนักเรียน -->
          <div class="flex flex-col gap-1 col-span-2">
            <label class="text-xs font-medium text-gray-600">รหัสนักเรียน <span class="text-red-400">*</span></label>
            <input v-model="editForm.student_code" type="text" placeholder="รหัสนักเรียน"
              :readonly="!isAdding"
              :class="['border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400',
                !isAdding ? 'bg-gray-50 text-gray-500 cursor-not-allowed border-gray-200' : 'border-gray-300']"/>
            <p v-if="!isAdding" class="text-xs text-gray-400">รหัสนักเรียนไม่สามารถเปลี่ยนได้</p>
          </div>

          <!-- คำนำหน้า -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">คำนำหน้า</label>
            <select v-model="editForm.prefix"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
              <option value="">-- เลือก --</option>
              <option>เด็กชาย</option>
              <option>เด็กหญิง</option>
              <option>นาย</option>
              <option>นางสาว</option>
              <option>นาง</option>
            </select>
          </div>

          <!-- เพศ -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">เพศ</label>
            <select v-model="editForm.gender"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
              <option value="">-- เลือก --</option>
              <option>ชาย</option>
              <option>หญิง</option>
            </select>
          </div>

          <!-- ชื่อ -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">ชื่อ <span class="text-red-400">*</span></label>
            <input v-model="editForm.first_name" type="text" placeholder="ชื่อ"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- นามสกุล -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">นามสกุล <span class="text-red-400">*</span></label>
            <input v-model="editForm.last_name" type="text" placeholder="นามสกุล"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- วันเกิด -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">วันเกิด</label>
            <input v-model="editForm.birth_date" type="date"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- เลขบัตรประชาชน -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">เลขบัตรประชาชน</label>
            <input v-model="editForm.national_id" type="text" placeholder="เลข 13 หลัก" maxlength="13"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 font-mono"/>
          </div>

          <!-- ระดับชั้น -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">ระดับชั้น <span class="text-red-400">*</span></label>
            <select v-model="editForm.grade_level"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
              <option value="">-- เลือก --</option>
              <option v-for="g in ['ม.1','ม.2','ม.3','ม.4','ม.5','ม.6']" :key="g" :value="g">{{ g }}</option>
            </select>
          </div>

          <!-- ห้อง -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">ห้อง <span class="text-red-400">*</span></label>
            <input v-model="editForm.room" type="text" placeholder="เช่น 1, 2, 3"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- สัญชาติ -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">สัญชาติ</label>
            <input v-model="editForm.nationality" type="text" placeholder="เช่น ไทย"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- เชื้อชาติ -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">เชื้อชาติ</label>
            <input v-model="editForm.ethnicity" type="text" placeholder="เช่น ไทย"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- ศาสนา -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">ศาสนา</label>
            <input v-model="editForm.religion" type="text" placeholder="เช่น พุทธ"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- น้ำหนัก / ส่วนสูง -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">น้ำหนัก (กก.)</label>
            <input v-model="editForm.weight" type="number" step="0.1" placeholder="0.0"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">ส่วนสูง (ซม.)</label>
            <input v-model="editForm.height" type="number" step="0.1" placeholder="0.0"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- ผู้ปกครอง -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">ชื่อผู้ปกครอง</label>
            <input v-model="editForm.guardian_name" type="text" placeholder="ชื่อผู้ปกครอง"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">ความสัมพันธ์</label>
            <input v-model="editForm.guardian_relation" type="text" placeholder="เช่น บิดา, มารดา"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- ด้อยโอกาส -->
          <div class="flex flex-col gap-1 col-span-2">
            <label class="text-xs font-medium text-gray-600">ประเภทด้อยโอกาส</label>
            <input v-model="editForm.disadvantaged" type="text" placeholder="เช่น ยากจน, พิการ (ถ้ามี)"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"/>
          </div>

          <!-- สถานะ -->
          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium text-gray-600">สถานะนักเรียน</label>
            <select v-model="editForm.is_active"
              class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
              <option :value="true">กำลังศึกษา</option>
              <option :value="false">ออกแล้ว</option>
            </select>
          </div>

        </div>

        <!-- Error -->
        <div v-if="saveError" class="mx-6 mb-3 bg-red-50 border border-red-200 rounded-lg p-3 text-xs text-red-600">
          ⚠️ {{ saveError }}
        </div>

        <!-- Modal Footer -->
        <div class="sticky bottom-0 bg-white border-t border-gray-100 px-6 py-4 flex justify-end gap-3 rounded-b-2xl">
          <button @click="showModal=false" class="px-5 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50">ยกเลิก</button>
          <button @click="saveStudent" :disabled="saving"
            class="px-6 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center gap-2">
            <span v-if="saving" class="animate-spin">⏳</span>
            {{ isAdding ? 'เพิ่มนักเรียน' : 'บันทึก' }}
          </button>
        </div>

      </div>
    </div>

    <!-- Delete Confirm Modal -->
    <div v-if="deleteTarget" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4"
      @click.self="deleteTarget=null">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
        <div class="text-4xl mb-3">🗑️</div>
        <h3 class="font-bold text-gray-800 mb-2">ลบนักเรียน?</h3>
        <p class="text-sm text-gray-500 mb-1">
          <strong>{{ deleteTarget.prefix }}{{ deleteTarget.first_name }} {{ deleteTarget.last_name }}</strong>
        </p>
        <p class="text-xs text-gray-400 mb-5">รหัส {{ deleteTarget.student_code }}</p>
        <div class="bg-amber-50 border border-amber-200 rounded-lg p-3 mb-5 text-xs text-amber-700 text-left">
          ⚠️ ข้อมูลในตาราง students จะถูกลบถาวร แต่ประวัติใน Snapshots ยังคงอยู่
        </div>
        <div class="flex gap-3 justify-center">
          <button @click="deleteTarget=null" class="px-5 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50">ยกเลิก</button>
          <button @click="deleteStudent" :disabled="saving"
            class="px-5 py-2 text-sm bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:bg-gray-300">
            {{ saving ? 'กำลังลบ...' : 'ลบ' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import AdminLayout from '../../layouts/AdminLayout.vue'
import { supabase } from '../../lib/supabase'
import { useAuth } from '../../composables/useAuth'
import * as XLSX from 'xlsx'

const { user } = useAuth()

// ── Constants ──────────────────────────────────────────────────────────────────
const TABS = [
  { key: 'current', icon: '📋', label: 'ข้อมูลปัจจุบัน' },
  { key: 'import',  icon: '📥', label: 'นำเข้า DMC' },
  { key: 'history', icon: '📊', label: 'ประวัติ / เปรียบเทียบ' },
  { key: 'health',  icon: '🏥', label: 'สุขภาพ BMI' },
]
const IMPORT_STEPS = ['อัปโหลดไฟล์', 'ตรวจสอบ Column', 'ตัวอย่าง', 'นำเข้า']
const DB_COLS = [
  { key: 'student_code',     label: 'รหัสนักเรียน',    required: true  },
  { key: 'prefix',           label: 'คำนำหน้า',         required: true  },
  { key: 'first_name',       label: 'ชื่อ',              required: true  },
  { key: 'last_name',        label: 'นามสกุล',           required: true  },
  { key: 'grade_level',      label: 'ระดับชั้น',         required: true  },
  { key: 'room',             label: 'ห้อง',              required: true  },
  { key: 'gender',           label: 'เพศ',               required: false },
  { key: 'birth_date',       label: 'วันเกิด',           required: false },
  { key: 'nationality',      label: 'สัญชาติ',           required: false },
  { key: 'religion',         label: 'ศาสนา',             required: false },
  { key: 'ethnicity',        label: 'เชื้อชาติ',         required: false },
  { key: 'weight',           label: 'น้ำหนัก',           required: false },
  { key: 'height',           label: 'ส่วนสูง',           required: false },
  { key: 'disadvantaged',    label: 'ด้อยโอกาส',         required: false },
  { key: 'guardian_name',    label: 'ชื่อผู้ปกครอง',     required: false },
  { key: 'guardian_relation',label: 'ความสัมพันธ์',      required: false },
  { key: 'national_id',      label: 'เลขบัตรประชาชน',   required: false },
  { key: 'status',           label: 'สถานะ',             required: false },
]
const REQUIRED_COLS = DB_COLS.filter(c => c.required)

// Auto-detect Thai DMC column headers
const COL_DETECT = {
  'รหัสนักเรียน': 'student_code', 'เลขประจำตัว': 'student_code',
  'เลขประจำตัวนักเรียน': 'student_code', 'รหัส': 'student_code',
  'คำนำหน้า': 'prefix', 'คำนำหน้าชื่อ': 'prefix',
  'ชื่อ': 'first_name', 'ชื่อนักเรียน': 'first_name', 'ชื่อจริง': 'first_name',
  'นามสกุล': 'last_name',
  'เพศ': 'gender',
  'วันเกิด': 'birth_date', 'วันเดือนปีเกิด': 'birth_date', 'วันที่เกิด': 'birth_date',
  'ระดับชั้น': 'grade_level', 'ชั้น': 'grade_level', 'ชั้นเรียน': 'grade_level', 'ชั้นปี': 'grade_level',
  'ห้อง': 'room', 'ห้องเรียน': 'room',
  'สัญชาติ': 'nationality',
  'ศาสนา': 'religion',
  'เชื้อชาติ': 'ethnicity',
  'น้ำหนัก': 'weight', 'น้ำหนัก(กก.)': 'weight',
  'ส่วนสูง': 'height', 'ส่วนสูง(ซม.)': 'height',
  'ด้อยโอกาส': 'disadvantaged', 'ประเภทด้อยโอกาส': 'disadvantaged',
  'ชื่อผู้ปกครอง': 'guardian_name', 'ผู้ปกครอง': 'guardian_name',
  'ความสัมพันธ์': 'guardian_relation', 'ความสัมพันธ์ผู้ปกครอง': 'guardian_relation',
  'เลขบัตรประชาชน': 'national_id', 'เลขประจำตัวประชาชน': 'national_id',
  'สถานะ': 'status', 'สถานะนักเรียน': 'status',
}

// ── Helpers ────────────────────────────────────────────────────────────────────
function numFromGrade(v) { return parseFloat(String(v).replace(/[^\d.]/g,'')) || 0 }
function formatDate(dt) {
  if (!dt) return '-'
  return new Date(dt).toLocaleDateString('th-TH', { day:'numeric', month:'short', year:'numeric' })
}

// ── BMI Helpers ────────────────────────────────────────────────────────────────
function calcBMI(weight, height) {
  const w = parseFloat(weight), h = parseFloat(height)
  if (!w || !h || h < 50) return null
  return w / ((h / 100) ** 2)
}
function bmiCategory(bmi) {
  if (bmi === null || bmi === undefined) return null
  if (bmi < 18.5) return 'ผอม'
  if (bmi < 23)   return 'สมส่วน'
  if (bmi < 27.5) return 'น้ำหนักเกิน'
  return 'อ้วน'
}
const BMI_CATS = [
  { key: 'ผอม',          color: 'bg-blue-400',  light: 'bg-blue-50',   text: 'text-blue-600',  border: 'border-blue-200'  },
  { key: 'สมส่วน',      color: 'bg-green-400', light: 'bg-green-50',  text: 'text-green-600', border: 'border-green-200' },
  { key: 'น้ำหนักเกิน', color: 'bg-amber-400', light: 'bg-amber-50',  text: 'text-amber-600', border: 'border-amber-200' },
  { key: 'อ้วน',        color: 'bg-red-400',   light: 'bg-red-50',    text: 'text-red-600',   border: 'border-red-200'   },
]

// จำแนกเพศ: ใช้ gender field ก่อน → fallback prefix
function classifyGender(genderField, prefix) {
  const g = (genderField || '').trim()
  if (g.includes('ชาย'))   return 'ชาย'
  if (g.includes('หญิง'))  return 'หญิง'
  const p = (prefix || '').trim()
  if (p === 'เด็กชาย' || p === 'นาย')                      return 'ชาย'
  if (p === 'เด็กหญิง' || p === 'นาง' || p === 'นางสาว') return 'หญิง'
  return ''
}
function getGender(s) { return classifyGender(s.gender, s.prefix) }

// ── Tab state ──────────────────────────────────────────────────────────────────
const activeTab = ref('current')
function switchTab(tab) {
  activeTab.value = tab
  if (tab === 'current' && allStudents.value.length === 0) loadCurrentStudents()
  if (tab === 'history') loadImports()
  if (tab === 'health'  && bmiData.value.length === 0)    loadBMIData()
}

// ══ TAB 1: ข้อมูลปัจจุบัน ══════════════════════════════════════════════════════
const loadingStudents = ref(false)
const allStudents     = ref([])
const fGrade   = ref('')
const fRoom    = ref('')
const fActive  = ref('true')
const fSearch  = ref('')
const pageSize = ref(20)
const curPage  = ref(1)

async function loadCurrentStudents() {
  loadingStudents.value = true
  try {
    let all = [], from = 0
    while (true) {
      const { data, error } = await supabase
        .from('students')
        .select('student_code, prefix, first_name, last_name, gender, national_id, grade_level, room, is_active')
        .range(from, from + 999)
      if (error) throw error
      if (!data?.length) break
      all = all.concat(data)
      if (data.length < 1000) break
      from += 1000
    }
    allStudents.value = all
  } catch (e) { console.error(e) }
  finally { loadingStudents.value = false }
}

// Summary cards: กรองตาม grade+room (ไม่รวม status filter) — อัปเดตตามการกรอง
const summaryBase = computed(() =>
  allStudents.value.filter(s => {
    if (!s.is_active) return false
    if (fGrade.value && s.grade_level !== fGrade.value) return false
    if (fRoom.value  && String(s.room) !== String(fRoom.value)) return false
    return true
  })
)
const activeCount   = computed(() => summaryBase.value.length)
const inactiveCount = computed(() => allStudents.value.filter(s => {
  if (s.is_active) return false
  if (fGrade.value && s.grade_level !== fGrade.value) return false
  if (fRoom.value  && String(s.room) !== String(fRoom.value)) return false
  return true
}).length)
const maleCount   = computed(() => summaryBase.value.filter(s => getGender(s) === 'ชาย').length)
const femaleCount = computed(() => summaryBase.value.filter(s => getGender(s) === 'หญิง').length)

const activeStudents = computed(() => allStudents.value.filter(s => s.is_active))

const gradeOpts = computed(() => {
  const s = new Set(activeStudents.value.map(s => s.grade_level))
  return [...s].sort((a,b) => numFromGrade(a) - numFromGrade(b))
})
const roomOpts = computed(() => {
  if (!fGrade.value) return []
  const s = new Set(activeStudents.value.filter(s => s.grade_level === fGrade.value).map(s => s.room))
  return [...s].sort((a,b) => Number(a) - Number(b))
})
const filteredStudents = computed(() => {
  const q = fSearch.value.trim().toLowerCase()
  return allStudents.value.filter(s => {
    if (fActive.value==='true'  && !s.is_active) return false
    if (fActive.value==='false' &&  s.is_active) return false
    if (fGrade.value && s.grade_level !== fGrade.value) return false
    if (fRoom.value  && String(s.room) !== String(fRoom.value)) return false
    if (q && !`${s.student_code} ${s.first_name} ${s.last_name}`.toLowerCase().includes(q)) return false
    return true
  })
})
const totalPages    = computed(() => pageSize.value >= 9999 ? 1 : Math.max(1, Math.ceil(filteredStudents.value.length / pageSize.value)))
const pageStart     = computed(() => Math.min((curPage.value-1)*pageSize.value+1, filteredStudents.value.length))
const pageEnd       = computed(() => Math.min(curPage.value*pageSize.value, filteredStudents.value.length))
const pagedStudents = computed(() => {
  if (pageSize.value >= 9999) return filteredStudents.value
  return filteredStudents.value.slice((curPage.value-1)*pageSize.value, curPage.value*pageSize.value)
})
const pageButtons = computed(() => {
  const total = totalPages.value, cur = curPage.value
  let s = Math.max(1,cur-2), e = Math.min(total,cur+2)
  if (e-s < 4) { if (s===1) e=Math.min(total,5); else s=Math.max(1,e-4) }
  return Array.from({length:e-s+1},(_,i)=>s+i)
})
watch(filteredStudents, () => { if (curPage.value > totalPages.value) curPage.value = 1 })

function exportCurrentExcel() {
  const ws = XLSX.utils.json_to_sheet(filteredStudents.value.map((s,i) => ({
    'ลำดับ':i+1,'รหัส':s.student_code,'คำนำหน้า':s.prefix,
    'ชื่อ':s.first_name,'นามสกุล':s.last_name,'เพศ':s.gender,
    'ชั้น':s.grade_level,'ห้อง':s.room,
    'สถานะ':s.is_active?'กำลังศึกษา':'ออกแล้ว',
  })))
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'นักเรียน')
  XLSX.writeFile(wb, 'รายชื่อนักเรียน.xlsx')
}

// ══ TAB 2: นำเข้า DMC ══════════════════════════════════════════════════════════
const importStep     = ref(1)
const fileError      = ref('')
const excelHeaders   = ref([])
const rawRows        = ref([])
const parsedRows     = ref([])
const colMapping     = ref({})
const importMeta     = ref({ label:'', academic_year: new Date().getFullYear()+543, semester:1, note:'' })
const importProgress = ref(0)
const importStatus   = ref('')
const importDone     = ref(false)

function handleFileUpload(e) {
  fileError.value = ''
  const file = e.target.files[0]
  if (!file) return
  const reader = new FileReader()
  reader.onload = ev => {
    try {
      const wb  = XLSX.read(ev.target.result, { type:'array' })
      const ws  = wb.Sheets[wb.SheetNames[0]]
      const raw = XLSX.utils.sheet_to_json(ws, { header:1, defval:'' })
      let hRow  = 0
      while (hRow < raw.length && (!raw[hRow] || raw[hRow].every(c=>!c))) hRow++
      const headers = (raw[hRow]||[]).map(h=>String(h).trim()).filter(h=>h)
      const rows    = raw.slice(hRow+1).filter(r=>r.some(c=>c!==''))
      excelHeaders.value = headers
      rawRows.value      = rows
      // Auto-detect
      const mapping = {}
      DB_COLS.forEach(col => { mapping[col.key]='' })
      headers.forEach(h => {
        const k = COL_DETECT[h.trim()]
        if (k && !mapping[k]) mapping[k] = h
      })
      colMapping.value = mapping
      // Auto-fill semester
      if (!importMeta.value.label) {
        const sem = (new Date().getMonth()+1 >= 5 && new Date().getMonth()+1 <= 10) ? 1 : 2
        importMeta.value.semester = sem
        importMeta.value.label = `ภาคเรียนที่ ${sem}/${importMeta.value.academic_year}`
      }
      importStep.value = 2
    } catch (err) { fileError.value='ไม่สามารถอ่านไฟล์ได้ กรุณาตรวจสอบรูปแบบไฟล์'; console.error(err) }
  }
  reader.readAsArrayBuffer(file)
}

const mappedRequired = computed(() => REQUIRED_COLS.filter(c=>colMapping.value[c.key]).length)
const canProceed     = computed(() =>
  importMeta.value.label && importMeta.value.academic_year &&
  REQUIRED_COLS.every(c => colMapping.value[c.key])
)

function goToPreview() {
  const headers = excelHeaders.value
  const mapping = colMapping.value
  parsedRows.value = rawRows.value.map(row => {
    const obj = {}
    DB_COLS.forEach(col => {
      const idx = mapping[col.key] ? headers.indexOf(mapping[col.key]) : -1
      obj[col.key] = idx >= 0 ? String(row[idx]??'').trim() : ''
    })
    return obj
  }).filter(r => r.student_code)
  importStep.value = 3
}

const previewGender  = computed(() => ({
  male:   parsedRows.value.filter(r => classifyGender(r.gender, r.prefix) === 'ชาย').length,
  female: parsedRows.value.filter(r => classifyGender(r.gender, r.prefix) === 'หญิง').length,
}))
const previewByGrade = computed(() => {
  const map = {}
  parsedRows.value.forEach(r => { const g=r.grade_level||'ไม่ระบุ'; map[g]=(map[g]||0)+1 })
  return Object.entries(map).map(([grade,count])=>({grade,count}))
    .sort((a,b)=>numFromGrade(a.grade)-numFromGrade(b.grade))
})

async function executeImport() {
  importStep.value = 4; importDone.value = false
  importProgress.value = 0; importStatus.value = 'กำลังสร้างรอบการนำเข้า...'
  try {
    const BATCH = 400, rows = parsedRows.value, year = importMeta.value.academic_year

    // 1. Create dmc_imports
    const { data:imp, error:impErr } = await supabase.from('dmc_imports')
      .insert({ label:importMeta.value.label, academic_year:year, semester:importMeta.value.semester,
        total_count:rows.length, note:importMeta.value.note||null, created_by:user.value?.id||null })
      .select().single()
    if (impErr) throw impErr
    importProgress.value = 5

    // 2. Insert student_snapshots
    let done = 0
    importStatus.value = 'กำลังบันทึก Snapshots...'
    for (let i = 0; i < rows.length; i += BATCH) {
      const batch = rows.slice(i, i+BATCH).map(r => ({
        import_id:imp.id, academic_year:year,
        student_code:r.student_code||null, prefix:r.prefix||null,
        first_name:r.first_name||null, last_name:r.last_name||null,
        gender:r.gender||null, birth_date:r.birth_date||null,
        grade_level:r.grade_level||null,
        room: r.room ? (parseInt(r.room)||null) : null,
        nationality:r.nationality||null, religion:r.religion||null, ethnicity:r.ethnicity||null,
        weight:r.weight?(parseFloat(r.weight)||null):null,
        height:r.height?(parseFloat(r.height)||null):null,
        disadvantaged:r.disadvantaged||null,
        guardian_name:r.guardian_name||null, guardian_relation:r.guardian_relation||null,
        national_id:r.national_id||null, status:r.status||'กำลังศึกษา',
      }))
      const { error } = await supabase.from('student_snapshots').insert(batch)
      if (error) throw error
      done += batch.length
      importProgress.value = Math.round(5 + (done/rows.length)*45)
      importStatus.value = `Snapshots: ${done.toLocaleString()}/${rows.length.toLocaleString()}`
    }

    // 3. Upsert students
    done = 0
    importStatus.value = 'กำลังอัปเดตข้อมูลนักเรียนปัจจุบัน...'
    for (let i = 0; i < rows.length; i += BATCH) {
      const batch = rows.slice(i, i+BATCH).map(r => ({
        student_code: r.student_code || null,
        prefix:       r.prefix       || null,
        first_name:   r.first_name   || null,
        last_name:    r.last_name    || null,
        gender:       r.gender       || null,
        national_id:  r.national_id  || null,
        grade_level:  r.grade_level  || null,
        room:         r.room         || null,
        is_active:    true,
        last_import_id: imp.id,
      }))
      const { error } = await supabase.from('students').upsert(batch, { onConflict:'student_code' })
      if (error) throw error
      done += batch.length
      importProgress.value = Math.round(50 + (done/rows.length)*35)
      importStatus.value = `Students: ${done.toLocaleString()}/${rows.length.toLocaleString()}`
    }

    // 4. Mark inactive
    importStatus.value = 'กำลังทำเครื่องหมายนักเรียนที่ออก...'; importProgress.value = 85
    const { data:currentActive } = await supabase.from('students').select('student_code').eq('is_active',true)
    const newCodes = new Set(rows.map(r=>r.student_code))
    const toOff = (currentActive||[]).map(s=>s.student_code).filter(c=>!newCodes.has(c))
    for (let i = 0; i < toOff.length; i += 200)
      await supabase.from('students').update({is_active:false}).in('student_code', toOff.slice(i,i+200))

    importProgress.value = 100; importStatus.value = 'เสร็จสิ้น!'
    importDone.value = true
    await loadCurrentStudents()
    await loadImports()
  } catch (err) {
    console.error('Import error:', err)
    importStatus.value = `❌ เกิดข้อผิดพลาด: ${err.message}`
  }
}

function resetImport() {
  importStep.value=1; fileError.value=''; excelHeaders.value=[]
  rawRows.value=[]; parsedRows.value=[]; colMapping.value={}
  importProgress.value=0; importStatus.value=''; importDone.value=false
}

// ══ TAB 3: History ══════════════════════════════════════════════════════════════
const loadingHistory = ref(false)
const imports        = ref([])
const latestImport   = ref(null)

async function loadImports() {
  loadingHistory.value = true
  try {
    const { data, error } = await supabase.from('dmc_imports').select('*').order('imported_at',{ascending:false})
    if (error) throw error
    const result = data || []
    for (const imp of result) {
      const { data:s } = await supabase.from('student_snapshots').select('gender, prefix').eq('import_id',imp.id)
      imp.male_count   = (s||[]).filter(x => classifyGender(x.gender, x.prefix) === 'ชาย').length
      imp.female_count = (s||[]).filter(x => classifyGender(x.gender, x.prefix) === 'หญิง').length
    }
    imports.value      = result
    latestImport.value = result[0] || null
  } catch (e) { console.error(e) }
  finally { loadingHistory.value = false }
}

const chronologicalImports = computed(() =>
  [...imports.value].sort((a,b)=>new Date(a.imported_at)-new Date(b.imported_at))
)
const maxCount = computed(() => Math.max(...imports.value.map(i=>i.total_count), 1))

// ══ TAB 4: Health / BMI ═════════════════════════════════════════════════════════
const loadingBMI = ref(false)
const bmiData    = ref([])   // นักเรียนปัจจุบัน + น้ำหนัก/ส่วนสูงล่าสุดที่มีข้อมูล

async function loadBMIData() {
  loadingBMI.value = true
  try {
    // ── Step 1: ดึง active students (grade, room, gender, prefix) ─────────────
    const activeMap = {}
    let from = 0
    while (true) {
      const { data, error } = await supabase
        .from('students')
        .select('student_code, grade_level, room, gender, prefix')
        .eq('is_active', true)
        .range(from, from + 999)
      if (error) throw error
      if (!data?.length) break
      data.forEach(s => { activeMap[s.student_code] = s })
      if (data.length < 1000) break
      from += 1000
    }
    const codes = Object.keys(activeMap)
    if (!codes.length) { bmiData.value = []; return }

    // ── Step 2: ดึง snapshots ที่มี weight+height ของนักเรียนเหล่านั้น ──────────
    // batch ทีละ 500 เพราะ .in() มี limit
    const snapMap = {}   // student_code → snapshot ล่าสุดที่มี weight/height
    for (let i = 0; i < codes.length; i += 500) {
      const batch = codes.slice(i, i + 500)
      const { data } = await supabase
        .from('student_snapshots')
        .select('student_code, weight, height, academic_year, semester')
        .in('student_code', batch)
      ;(data || []).forEach(snap => {
        const w = parseFloat(snap.weight), h = parseFloat(snap.height)
        if (!w || !h || h < 50) return   // ข้ามข้อมูลที่ไม่สมเหตุสมผล
        const cur = snapMap[snap.student_code]
        if (!cur ||
            snap.academic_year > cur.academic_year ||
            (snap.academic_year === cur.academic_year && snap.semester > cur.semester)) {
          snapMap[snap.student_code] = snap   // เก็บล่าสุด
        }
      })
    }

    // ── Step 3: รวม active student + snapshot ล่าสุด ──────────────────────────
    bmiData.value = codes
      .filter(code => snapMap[code])
      .map(code => ({
        ...activeMap[code],
        weight: snapMap[code].weight,
        height: snapMap[code].height,
      }))
  } catch (e) { console.error(e) }
  finally { loadingBMI.value = false }
}

// กรองตาม grade/room เหมือน tab 1
const bmiFiltered = computed(() =>
  bmiData.value.filter(s => {
    if (fGrade.value && s.grade_level !== fGrade.value) return false
    if (fRoom.value  && String(s.room) !== String(fRoom.value)) return false
    return true
  })
)
// คำนวณ BMI แต่ละคน (กรองเฉพาะที่มีค่า)
const bmiStats = computed(() =>
  bmiFiltered.value
    .map(s => ({ ...s, bmi: calcBMI(s.weight, s.height) }))
    .filter(s => s.bmi !== null)
)
const noWeightCount = computed(() =>
  bmiFiltered.value.filter(s => calcBMI(s.weight, s.height) === null).length
)
// นับตามหมวด
const bmiCounts = computed(() => {
  const c = { 'ผอม': 0, 'สมส่วน': 0, 'น้ำหนักเกิน': 0, 'อ้วน': 0 }
  bmiStats.value.forEach(s => { const cat = bmiCategory(s.bmi); if (cat) c[cat]++ })
  return c
})
// ค่าเฉลี่ย
const bmiAvg    = computed(() => bmiStats.value.length ? bmiStats.value.reduce((a,s)=>a+s.bmi,0)/bmiStats.value.length : null)
const avgWeight = computed(() => {
  const rows = bmiFiltered.value.filter(s => parseFloat(s.weight))
  return rows.length ? rows.reduce((a,s)=>a+parseFloat(s.weight),0)/rows.length : null
})
const avgHeight = computed(() => {
  const rows = bmiFiltered.value.filter(s => parseFloat(s.height))
  return rows.length ? rows.reduce((a,s)=>a+parseFloat(s.height),0)/rows.length : null
})
// จำแนกตามชั้น
const bmiByGrade = computed(() => {
  const map = {}
  bmiStats.value.forEach(s => {
    const g = s.grade_level || 'ไม่ระบุ'
    if (!map[g]) map[g] = { grade:g, total:0, ผอม:0, สมส่วน:0, 'น้ำหนักเกิน':0, อ้วน:0, bmiSum:0 }
    const cat = bmiCategory(s.bmi)
    if (cat) { map[g][cat]++; map[g].total++; map[g].bmiSum += s.bmi }
  })
  return Object.values(map).sort((a,b) => numFromGrade(a.grade)-numFromGrade(b.grade))
})
// กลุ่มเพศ
const bmiGender = computed(() => ({
  male:   bmiStats.value.filter(s => classifyGender(s.gender, s.prefix) === 'ชาย'),
  female: bmiStats.value.filter(s => classifyGender(s.gender, s.prefix) === 'หญิง'),
}))

// ══ CRUD: เพิ่ม / แก้ไข / ลบ นักเรียน ═════════════════════════════════════════
const showModal   = ref(false)
const isAdding    = ref(false)
const saving      = ref(false)
const saveError   = ref('')
const deleteTarget = ref(null)

const EMPTY_FORM = {
  student_code: '', prefix: '', first_name: '', last_name: '',
  gender: '', birth_date: '', grade_level: '', room: '',
  national_id: '', nationality: '', ethnicity: '', religion: '',
  weight: '', height: '', guardian_name: '', guardian_relation: '',
  disadvantaged: '', is_active: true,
}
const editForm = ref({ ...EMPTY_FORM })

async function openEdit(s) {
  saveError.value = ''
  isAdding.value  = false
  // ดึงข้อมูลเพิ่มเติมจาก student_snapshots (latest)
  const { data: snap } = await supabase
    .from('student_snapshots')
    .select('*')
    .eq('student_code', s.student_code)
    .order('academic_year', { ascending: false })
    .limit(1)
    .maybeSingle()

  editForm.value = {
    student_code:      s.student_code || '',
    prefix:            s.prefix       || '',
    first_name:        s.first_name   || '',
    last_name:         s.last_name    || '',
    gender:            classifyGender(s.gender || snap?.gender, s.prefix || snap?.prefix),
    birth_date:        snap?.birth_date || '',
    grade_level:       s.grade_level  || '',
    room:              String(s.room  || ''),
    national_id:       s.national_id || snap?.national_id || '',
    nationality:       snap?.nationality         || '',
    ethnicity:         snap?.ethnicity           || '',
    religion:          snap?.religion            || '',
    weight:            snap?.weight              || '',
    height:            snap?.height              || '',
    guardian_name:     snap?.guardian_name       || '',
    guardian_relation: snap?.guardian_relation   || '',
    disadvantaged:     snap?.disadvantaged       || '',
    is_active:         s.is_active ?? true,
  }
  showModal.value = true
}

function openAdd() {
  saveError.value = ''
  isAdding.value  = true
  editForm.value  = { ...EMPTY_FORM }
  showModal.value = true
}

async function saveStudent() {
  saveError.value = ''
  if (!editForm.value.student_code || !editForm.value.first_name || !editForm.value.last_name) {
    saveError.value = 'กรุณากรอกรหัสนักเรียน ชื่อ และนามสกุล'
    return
  }
  saving.value = true
  try {
    const row = {
      student_code: editForm.value.student_code,
      prefix:       editForm.value.prefix       || null,
      first_name:   editForm.value.first_name   || null,
      last_name:    editForm.value.last_name     || null,
      gender:       editForm.value.gender        || null,
      national_id:  editForm.value.national_id   || null,
      grade_level:  editForm.value.grade_level   || null,
      room:         editForm.value.room          || null,
      is_active:    editForm.value.is_active,
    }

    if (isAdding.value) {
      const { error } = await supabase.from('students').insert(row)
      if (error) throw error
    } else {
      const { error } = await supabase.from('students')
        .update(row).eq('student_code', editForm.value.student_code)
      if (error) throw error
    }

    // อัปเดต local state
    if (isAdding.value) {
      allStudents.value.unshift({ ...row, gender: editForm.value.gender })
    } else {
      const idx = allStudents.value.findIndex(s => s.student_code === editForm.value.student_code)
      if (idx >= 0) allStudents.value[idx] = { ...allStudents.value[idx], ...row }
    }

    showModal.value = false
  } catch (e) {
    console.error(e)
    saveError.value = e.message || 'เกิดข้อผิดพลาด'
  } finally {
    saving.value = false
  }
}

function confirmDelete(s) {
  deleteTarget.value = s
}

async function deleteStudent() {
  if (!deleteTarget.value) return
  saving.value = true
  try {
    const { error } = await supabase.from('students')
      .delete().eq('student_code', deleteTarget.value.student_code)
    if (error) throw error
    allStudents.value = allStudents.value.filter(s => s.student_code !== deleteTarget.value.student_code)
    deleteTarget.value = null
  } catch (e) {
    console.error(e)
    alert('เกิดข้อผิดพลาด: ' + e.message)
  } finally {
    saving.value = false
  }
}

// ── Init ────────────────────────────────────────────────────────────────────────
onMounted(async () => {
  await Promise.all([loadCurrentStudents(), loadImports()])
  await loadBMIData()   // โหลดหลัง loadImports เพราะต้องการ latestImport.id
})
</script>
