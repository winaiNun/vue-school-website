<template>
  <AdminLayout>
    <div class="space-y-5">

      <!-- ===== HEADER ===== -->
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 class="text-xl font-bold text-gray-900 flex items-center gap-2">
            📅 ปฏิทินวิชาการ
          </h2>
          <p class="text-sm text-gray-500 mt-0.5">จัดการกิจกรรมและวันสำคัญประจำปีการศึกษา</p>
        </div>
        <div class="flex items-center gap-2">
          <!-- Academic Year Selector -->
          <select v-model="currentYear"
            class="border border-gray-200 rounded-xl px-3 py-2 text-sm font-medium text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white shadow-sm">
            <option v-for="y in academicYears" :key="y" :value="y">ปีการศึกษา {{ y }}</option>
          </select>
          <!-- Print Dropdown -->
          <div class="relative">
            <button @click="showPrintMenu = !showPrintMenu"
              class="flex items-center gap-1.5 border border-gray-200 bg-white text-gray-700 hover:bg-gray-50 rounded-xl px-3 py-2 text-sm font-medium shadow-sm transition-colors">
              <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
              </svg>
              พิมพ์
              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
              </svg>
            </button>
            <div v-if="showPrintMenu"
              class="absolute right-0 top-full mt-1.5 bg-white rounded-2xl shadow-xl border border-gray-100 z-50 overflow-hidden w-56">
              <div class="px-3 py-2 bg-gray-50 border-b border-gray-100">
                <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">เลือกรูปแบบพิมพ์</p>
              </div>
              <button @click="doPrint('monthly')"
                class="flex items-start gap-3 w-full px-4 py-3 text-left hover:bg-blue-50 transition-colors">
                <span class="text-lg leading-none mt-0.5">📅</span>
                <div>
                  <div class="text-sm font-semibold text-gray-800">รายเดือน</div>
                  <div class="text-xs text-gray-400">A4 Landscape · 12 หน้า</div>
                </div>
              </button>
              <button @click="doPrint('yearly')"
                class="flex items-start gap-3 w-full px-4 py-3 text-left hover:bg-blue-50 transition-colors border-t border-gray-50">
                <span class="text-lg leading-none mt-0.5">📆</span>
                <div>
                  <div class="text-sm font-semibold text-gray-800">ภาพรวมทั้งปี</div>
                  <div class="text-xs text-gray-400">A4 Landscape · 1 หน้า</div>
                </div>
              </button>
              <button @click="doPrint('list')"
                class="flex items-start gap-3 w-full px-4 py-3 text-left hover:bg-blue-50 transition-colors border-t border-gray-50">
                <span class="text-lg leading-none mt-0.5">📋</span>
                <div>
                  <div class="text-sm font-semibold text-gray-800">รายการกิจกรรม</div>
                  <div class="text-xs text-gray-400">A4 Portrait · ตารางรายการ</div>
                </div>
              </button>
            </div>
          </div>
          <!-- Import Holiday -->
          <div class="relative">
            <input ref="xlsxInput" type="file" accept=".xlsx,.xls" class="hidden" @change="onXlsxFile" />
            <div class="flex items-center gap-2">
              <button @click="downloadTemplate"
                class="flex items-center gap-1.5 border border-gray-200 bg-white text-gray-700 hover:bg-gray-50 rounded-xl px-3 py-2 text-sm font-medium shadow-sm transition-colors">
                📥 Template วันหยุด
              </button>
              <button @click="xlsxInput.click()"
                class="flex items-center gap-1.5 border border-green-200 bg-green-50 text-green-700 hover:bg-green-100 rounded-xl px-3 py-2 text-sm font-medium shadow-sm transition-colors">
                📤 นำเข้าวันหยุด
              </button>
            </div>
          </div>
          <button @click="openCreateModal(null)"
            class="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-xl text-sm font-medium shadow-sm transition-colors">
            <span class="text-lg leading-none">+</span> เพิ่มกิจกรรม
          </button>
        </div>
      </div>

      <!-- ===== MONTH NAVIGATION ===== -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4">
        <!-- Month Nav Bar -->
        <div class="flex items-center justify-between mb-4">
          <button @click="prevMonth"
            class="p-2 rounded-xl hover:bg-gray-100 text-gray-600 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
            </svg>
          </button>
          <h3 class="text-base font-bold text-gray-900">
            {{ thaiMonths[currentMonth] }} {{ currentYear }}
          </h3>
          <button @click="nextMonth"
            class="p-2 rounded-xl hover:bg-gray-100 text-gray-600 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
            </svg>
          </button>
        </div>

        <!-- Month Tab Strip -->
        <div class="flex gap-1 overflow-x-auto pb-1 scrollbar-hide">
          <button v-for="(m, idx) in thaiMonths" :key="idx" @click="currentMonth = idx"
            :class="['flex-shrink-0 px-3 py-1.5 rounded-lg text-xs font-medium transition-all whitespace-nowrap',
              currentMonth === idx
                ? 'bg-blue-600 text-white shadow-sm'
                : 'text-gray-500 hover:bg-gray-100 hover:text-gray-700']">
            {{ m }}
          </button>
        </div>
      </div>

      <!-- ===== MAIN CONTENT: Calendar + Event List ===== -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">

        <!-- LEFT: Calendar Grid -->
        <div class="lg:col-span-2 bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <!-- Loading -->
          <div v-if="loading" class="p-10 text-center text-gray-400">
            <div class="text-3xl mb-2 animate-spin inline-block">⏳</div>
            <p class="text-sm">กำลังโหลด...</p>
          </div>

          <template v-else>
            <!-- Day Headers -->
            <div class="grid grid-cols-7 bg-gray-50 border-b border-gray-100">
              <div v-for="d in dayHeaders" :key="d"
                class="py-2.5 text-center text-xs font-semibold text-gray-500 uppercase">
                {{ d }}
              </div>
            </div>

            <!-- Calendar Cells -->
            <div class="grid grid-cols-7">
              <div v-for="(day, idx) in calendarCells" :key="idx"
                @click="day && openCreateModal(day)"
                :class="[
                  'min-h-[90px] p-1.5 border-b border-r border-gray-100 relative',
                  day ? 'cursor-pointer hover:bg-blue-50/50 transition-colors' : 'bg-gray-50/50',
                  idx % 7 === 6 ? 'border-r-0' : '',
                  isToday(day) ? 'ring-2 ring-inset ring-blue-400' : ''
                ]">
                <!-- Day Number -->
                <div v-if="day" class="flex justify-end mb-1">
                  <span :class="[
                    'text-xs font-semibold w-6 h-6 flex items-center justify-center rounded-full',
                    isToday(day) ? 'bg-blue-600 text-white' : 'text-gray-700'
                  ]">{{ day }}</span>
                </div>

                <!-- Event Badges -->
                <div v-if="day" class="space-y-0.5">
                  <div v-for="(ev, ei) in eventsOnDay(day).slice(0, 3)" :key="ev.id"
                    @click.stop="openEditModal(ev)"
                    :class="['text-[10px] px-1 py-0.5 rounded truncate cursor-pointer font-medium border transition-opacity hover:opacity-80',
                      eventTypeMap[ev.event_type]?.color || 'bg-gray-100 text-gray-600 border-gray-200']">
                    <span :class="['inline-block w-1.5 h-1.5 rounded-full mr-0.5 align-middle', eventTypeMap[ev.event_type]?.dot || 'bg-gray-400']"></span>
                    {{ ev.title }}
                  </div>
                  <div v-if="eventsOnDay(day).length > 3"
                    class="text-[10px] text-gray-400 font-medium pl-1">
                    +{{ eventsOnDay(day).length - 3 }} อื่นๆ
                  </div>
                </div>
              </div>
            </div>
          </template>
        </div>

        <!-- RIGHT: Event List -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden flex flex-col">
          <!-- Header -->
          <div class="px-4 py-3 border-b border-gray-100">
            <div class="flex items-center justify-between mb-2">
              <h4 class="font-semibold text-gray-900 text-sm">กิจกรรมเดือน{{ thaiMonths[currentMonth] }}</h4>
              <span class="text-xs text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full">
                {{ eventsThisMonth.length }} รายการ
              </span>
            </div>
            <!-- Type breakdown badges -->
            <div v-if="eventsThisMonth.length" class="flex flex-wrap gap-1.5">
              <span v-for="et in eventTypes" :key="et.value"
                v-show="eventsThisMonthByType[et.value]"
                :class="['inline-flex items-center gap-1 text-[10px] px-2 py-0.5 rounded-full font-medium border', et.color]">
                <span :class="['w-1.5 h-1.5 rounded-full', et.dot]"></span>
                {{ et.label }} {{ eventsThisMonthByType[et.value] }}
              </span>
            </div>
          </div>

          <div class="flex-1 overflow-y-auto max-h-[520px]">
            <div v-if="loading" class="p-6 text-center text-gray-400 text-sm">กำลังโหลด...</div>
            <div v-else-if="!eventsThisMonth.length" class="p-8 text-center text-gray-400">
              <div class="text-3xl mb-2">📭</div>
              <p class="text-sm">ไม่มีกิจกรรมในเดือนนี้</p>
            </div>

            <!-- Grouped by type -->
            <div v-else>
              <template v-for="et in eventTypes" :key="et.value">
                <template v-if="eventsThisMonthByType[et.value]">
                  <!-- Group header -->
                  <div :class="['px-4 py-1.5 flex items-center gap-1.5 sticky top-0 z-10 border-b border-gray-50', et.color.replace('border-','').split(' ').filter(c=>c.startsWith('bg-')).join(' ') || 'bg-gray-50']"
                    style="background:inherit">
                    <span :class="['w-2 h-2 rounded-full flex-shrink-0', et.dot]"></span>
                    <span class="text-[11px] font-bold tracking-wide text-gray-600">{{ et.label }}</span>
                    <span class="ml-auto text-[10px] text-gray-400">{{ eventsThisMonthByType[et.value] }} รายการ</span>
                  </div>
                  <!-- Events in group -->
                  <div v-for="ev in eventsThisMonthGrouped[et.value]" :key="ev.id"
                    class="px-4 py-3 hover:bg-gray-50 transition-colors group border-b border-gray-50 last:border-b-0">
                    <div class="flex items-start justify-between gap-2">
                      <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1">
                          <span :class="['text-[10px] px-2 py-0.5 rounded-full font-medium border',
                            eventTypeMap[ev.event_type]?.color || 'bg-gray-100 text-gray-600 border-gray-200']">
                            {{ eventTypeMap[ev.event_type]?.label || ev.event_type }}
                          </span>
                      <span v-if="!ev.is_public" class="text-[10px] text-gray-400">🔒</span>
                    </div>
                    <p class="text-sm font-medium text-gray-800 truncate">{{ ev.title }}</p>
                    <p class="text-xs text-gray-400 mt-0.5">
                      {{ formatDateThai(ev.start_date) }}
                      <span v-if="ev.end_date && ev.end_date !== ev.start_date">
                        – {{ formatDateThai(ev.end_date) }}
                      </span>
                    </p>
                  </div>
                  <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button @click="openEditModal(ev)"
                      class="p-1.5 rounded-lg hover:bg-blue-100 text-blue-600 transition-colors">
                      <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                      </svg>
                    </button>
                    <button @click="confirmDeleteEvent(ev)"
                      class="p-1.5 rounded-lg hover:bg-red-100 text-red-500 transition-colors">
                      <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
            </template><!-- /v-if eventsThisMonthByType -->
          </template><!-- /v-for eventTypes -->
            </div><!-- /v-else -->
          </div><!-- /overflow container -->
        </div><!-- /right panel -->
      </div>

      <!-- ===== LEGEND ===== -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4">
        <p class="text-xs font-semibold text-gray-500 mb-2.5 uppercase tracking-wide">ประเภทกิจกรรม</p>
        <div class="flex flex-wrap gap-2">
          <span v-for="et in eventTypes" :key="et.value"
            :class="['flex items-center gap-1.5 text-xs px-2.5 py-1 rounded-full border font-medium', et.color]">
            <span :class="['w-2 h-2 rounded-full', et.dot]"></span>
            {{ et.label }}
          </span>
        </div>
      </div>

    </div>

    <!-- ===== CREATE/EDIT MODAL ===== -->
    <Teleport to="body">
      <Transition name="modal">
        <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <!-- Backdrop -->
          <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="closeModal"></div>

          <!-- Panel -->
          <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
            <!-- Modal Header -->
            <div class="sticky top-0 bg-white rounded-t-2xl border-b border-gray-100 px-6 py-4 flex items-center justify-between z-10">
              <h3 class="font-bold text-gray-900">
                {{ editTarget ? 'แก้ไขกิจกรรม' : 'เพิ่มกิจกรรมใหม่' }}
              </h3>
              <button @click="closeModal" class="p-1.5 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>

            <!-- Modal Body -->
            <div class="px-6 py-5 space-y-4">

              <!-- ชื่อกิจกรรม -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                  ชื่อกิจกรรม <span class="text-red-500">*</span>
                </label>
                <input v-model="form.title" type="text" placeholder="ระบุชื่อกิจกรรม..."
                  class="w-full border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                  :class="{'border-red-300 ring-1 ring-red-300': formErrors.title}" />
                <p v-if="formErrors.title" class="text-xs text-red-500 mt-1">{{ formErrors.title }}</p>
              </div>

              <!-- ประเภท -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">ประเภทกิจกรรม</label>
                <div class="grid grid-cols-2 gap-2">
                  <button v-for="et in eventTypes" :key="et.value"
                    @click="form.event_type = et.value"
                    :class="['flex items-center gap-2 px-3 py-2 rounded-xl border text-xs font-medium transition-all',
                      form.event_type === et.value
                        ? [et.color, 'border-current shadow-sm']
                        : 'border-gray-200 text-gray-600 hover:border-gray-300 hover:bg-gray-50']">
                    <span :class="['w-2.5 h-2.5 rounded-full flex-shrink-0', et.dot]"></span>
                    {{ et.label }}
                  </button>
                </div>
              </div>

              <!-- วันที่ -->
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">
                    วันที่เริ่ม <span class="text-red-500">*</span>
                  </label>
                  <input v-model="form.start_date" type="date"
                    class="w-full border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
                    :class="{'border-red-300 ring-1 ring-red-300': formErrors.start_date}" />
                  <p v-if="formErrors.start_date" class="text-xs text-red-500 mt-1">{{ formErrors.start_date }}</p>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">วันที่สิ้นสุด <span class="text-gray-400 text-xs">(ถ้ามี)</span></label>
                  <input v-model="form.end_date" type="date"
                    class="w-full border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition" />
                </div>
              </div>

              <!-- รายละเอียด -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">รายละเอียด</label>
                <textarea v-model="form.description" rows="3" placeholder="รายละเอียดเพิ่มเติม..."
                  class="w-full border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition resize-none"></textarea>
              </div>

              <!-- ปีการศึกษา + แสดงสาธารณะ -->
              <div class="flex items-center gap-4">
                <div class="flex-1">
                  <label class="block text-sm font-medium text-gray-700 mb-1">ปีการศึกษา</label>
                  <select v-model="form.academic_year"
                    class="w-full border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition">
                    <option v-for="y in academicYears" :key="y" :value="y">{{ y }}</option>
                  </select>
                </div>
                <div class="flex-shrink-0">
                  <label class="block text-sm font-medium text-gray-700 mb-1">แสดงสาธารณะ</label>
                  <button @click="form.is_public = !form.is_public"
                    :class="['relative inline-flex h-7 w-12 items-center rounded-full transition-colors focus:outline-none',
                      form.is_public ? 'bg-blue-600' : 'bg-gray-300']">
                    <span :class="['inline-block w-5 h-5 rounded-full bg-white shadow-sm transition-transform',
                      form.is_public ? 'translate-x-6' : 'translate-x-1']"></span>
                  </button>
                </div>
              </div>

              <!-- Delete Confirm Inline -->
              <div v-if="confirmDelete" class="bg-red-50 border border-red-200 rounded-xl p-4">
                <p class="text-sm font-medium text-red-700 mb-3">ยืนยันการลบกิจกรรมนี้?</p>
                <p class="text-xs text-red-500 mb-3">การลบไม่สามารถกู้คืนได้</p>
                <div class="flex gap-2">
                  <button @click="deleteEvent" :disabled="saving"
                    class="flex-1 bg-red-600 hover:bg-red-700 text-white text-sm py-2 rounded-xl font-medium transition-colors disabled:opacity-60">
                    {{ saving ? 'กำลังลบ...' : 'ยืนยันลบ' }}
                  </button>
                  <button @click="confirmDelete = false"
                    class="flex-1 bg-white border border-gray-200 text-gray-600 text-sm py-2 rounded-xl font-medium transition-colors hover:bg-gray-50">
                    ยกเลิก
                  </button>
                </div>
              </div>

              <!-- Error message -->
              <p v-if="saveError" class="text-sm text-red-600 bg-red-50 px-3 py-2 rounded-xl">{{ saveError }}</p>
            </div>

            <!-- Modal Footer -->
            <div class="sticky bottom-0 bg-white rounded-b-2xl border-t border-gray-100 px-6 py-4 flex items-center gap-2">
              <button @click="saveEvent" :disabled="saving"
                class="flex-1 bg-blue-600 hover:bg-blue-700 text-white py-2.5 rounded-xl font-medium text-sm transition-colors disabled:opacity-60 flex items-center justify-center gap-2">
                <svg v-if="saving" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                </svg>
                {{ saving ? 'กำลังบันทึก...' : (editTarget ? 'บันทึกการแก้ไข' : 'เพิ่มกิจกรรม') }}
              </button>
              <button v-if="editTarget && !confirmDelete" @click="confirmDelete = true"
                class="px-4 py-2.5 rounded-xl border border-red-200 text-red-600 hover:bg-red-50 text-sm font-medium transition-colors">
                ลบ
              </button>
              <button @click="closeModal"
                class="px-4 py-2.5 rounded-xl border border-gray-200 text-gray-600 hover:bg-gray-50 text-sm font-medium transition-colors">
                ยกเลิก
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- ===== IMPORT PREVIEW MODAL ===== -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="showImportModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" @click.self="showImportModal = false">
          <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[85vh] flex flex-col">
            <div class="px-6 py-4 border-b flex items-center justify-between">
              <div>
                <h3 class="font-bold text-gray-900">📤 ตรวจสอบข้อมูลก่อนนำเข้า</h3>
                <p class="text-xs text-gray-400 mt-0.5">พบ {{ importRows.length }} รายการ · จะ<span class="text-red-500 font-medium">แทนที่</span>วันหยุดเดิมทั้งหมดของปีนี้</p>
              </div>
              <button @click="showImportModal = false" class="w-8 h-8 flex items-center justify-center rounded-full hover:bg-gray-100 text-gray-400">✕</button>
            </div>

            <!-- Error rows -->
            <div v-if="importErrors.length" class="mx-6 mt-4 bg-red-50 border border-red-200 rounded-xl p-3">
              <p class="text-xs font-semibold text-red-700 mb-1">⚠️ พบข้อผิดพลาด {{ importErrors.length }} แถว (จะถูกข้ามไป)</p>
              <ul class="text-xs text-red-600 space-y-0.5">
                <li v-for="e in importErrors.slice(0,5)" :key="e">{{ e }}</li>
                <li v-if="importErrors.length > 5" class="text-red-400">...และอีก {{ importErrors.length - 5 }} รายการ</li>
              </ul>
            </div>

            <!-- Preview Table -->
            <div class="flex-1 overflow-y-auto px-6 py-4">
              <table class="w-full text-xs">
                <thead>
                  <tr class="border-b border-gray-100 text-gray-500 text-left">
                    <th class="pb-2 pr-3">วันที่เริ่ม</th>
                    <th class="pb-2 pr-3">วันที่สิ้นสุด</th>
                    <th class="pb-2 pr-3 flex-1">ชื่อ</th>
                    <th class="pb-2 pr-3">ประเภท</th>
                    <th class="pb-2">ปีการศึกษา</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, i) in importRows" :key="i" class="border-b border-gray-50 hover:bg-gray-50">
                    <td class="py-1.5 pr-3 font-mono">{{ row.start_date }}</td>
                    <td class="py-1.5 pr-3 font-mono text-gray-400">{{ row.end_date || '-' }}</td>
                    <td class="py-1.5 pr-3 text-gray-800">{{ row.title }}</td>
                    <td class="py-1.5 pr-3">
                      <span :class="['px-1.5 py-0.5 rounded-full text-xs', eventTypeMap[row.event_type]?.color || 'bg-gray-100 text-gray-600']">
                        {{ eventTypeMap[row.event_type]?.label || row.event_type }}
                      </span>
                    </td>
                    <td class="py-1.5 text-gray-500">{{ row.academic_year }}</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="px-6 py-4 border-t flex justify-end gap-3">
              <button @click="showImportModal = false" class="px-4 py-2 border border-gray-200 rounded-xl text-sm text-gray-600 hover:bg-gray-50">ยกเลิก</button>
              <button @click="confirmImport" :disabled="importing || !importRows.length"
                class="px-5 py-2 bg-green-600 hover:bg-green-700 text-white rounded-xl text-sm font-semibold disabled:opacity-50 flex items-center gap-2">
                <svg v-if="importing" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
                </svg>
                {{ importing ? 'กำลังนำเข้า...' : `✅ นำเข้า ${importRows.length} รายการ` }}
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

  </AdminLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import * as XLSX from 'xlsx'
import { supabase } from '../../lib/supabase'
import { useSchoolConfig } from '../../composables/useSchoolConfig'
import { printMonthly, printYearOverview, printEventList } from '../../utils/calendarPrint'
import AdminLayout from '../../layouts/AdminLayout.vue'

// ─── Constants ───────────────────────────────────────────────────────────────
const thaiMonths = [
  'มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน',
  'กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม'
]
const dayHeaders = ['จ','อ','พ','พฤ','ศ','ส','อา']
const academicYears = [2566, 2567, 2568, 2569, 2570]

const eventTypes = [
  { value: 'holiday',  label: 'วันหยุดราชการ',    color: 'bg-red-100 text-red-700 border-red-200',      dot: 'bg-red-500'    },
  { value: 'exam',     label: 'สอบ',               color: 'bg-purple-100 text-purple-700 border-purple-200', dot: 'bg-purple-500' },
  { value: 'activity', label: 'กิจกรรมโรงเรียน',  color: 'bg-green-100 text-green-700 border-green-200',  dot: 'bg-green-500'  },
  { value: 'term',     label: 'เปิด-ปิดภาคเรียน',  color: 'bg-blue-100 text-blue-700 border-blue-200',    dot: 'bg-blue-500'   },
  { value: 'meeting',  label: 'ประชุม',             color: 'bg-amber-100 text-amber-700 border-amber-200',  dot: 'bg-amber-500'  },
  { value: 'other',    label: 'อื่นๆ',              color: 'bg-gray-100 text-gray-600 border-gray-200',    dot: 'bg-gray-400'   },
]

const eventTypeMap = Object.fromEntries(eventTypes.map(et => [et.value, et]))

// ─── School Config ────────────────────────────────────────────────────────────
const { fetchConfig, schoolName, logoUrl } = useSchoolConfig()

// ─── State ────────────────────────────────────────────────────────────────────
const events        = ref([])
const loading       = ref(false)
const saving        = ref(false)
const saveError     = ref('')
const showPrintMenu = ref(false)

const now = new Date()
const currentYear  = ref(now.getFullYear() + 543)
const currentMonth = ref(now.getMonth()) // 0-11

const showModal     = ref(false)
const editTarget    = ref(null)
const confirmDelete = ref(false)
const formErrors    = ref({})

const defaultForm = () => ({
  title: '',
  description: '',
  start_date: '',
  end_date: '',
  event_type: 'activity',
  academic_year: currentYear.value,
  is_public: true,
})
const form = ref(defaultForm())

// ─── Calendar Computed ────────────────────────────────────────────────────────
const daysInMonth = computed(() => {
  const ce = currentYear.value - 543
  return new Date(ce, currentMonth.value + 1, 0).getDate()
})

const firstDayOfMonth = computed(() => {
  const ce = currentYear.value - 543
  let day = new Date(ce, currentMonth.value, 1).getDay()
  return day === 0 ? 6 : day - 1 // Monday = 0
})

const calendarCells = computed(() => {
  const cells = []
  for (let i = 0; i < firstDayOfMonth.value; i++) cells.push(null)
  for (let d = 1; d <= daysInMonth.value; d++) cells.push(d)
  while (cells.length % 7 !== 0) cells.push(null)
  return cells
})

const eventsThisMonth = computed(() => {
  const ce = currentYear.value - 543
  const monthStr = `${ce}-${String(currentMonth.value + 1).padStart(2, '0')}`
  return events.value.filter(e => {
    const start = e.start_date || ''
    const end   = e.end_date   || e.start_date || ''
    const monthEnd   = `${monthStr}-${String(daysInMonth.value).padStart(2,'0')}`
    const monthStart = `${monthStr}-01`
    return start <= monthEnd && end >= monthStart
  })
})

// นับจำนวนแต่ละประเภท  { holiday: 5, activity: 3, ... }
const eventsThisMonthByType = computed(() => {
  const map = {}
  for (const ev of eventsThisMonth.value) {
    map[ev.event_type] = (map[ev.event_type] || 0) + 1
  }
  return map
})

// จัดกลุ่ม { holiday: [...], activity: [...], ... } เรียงตาม start_date
const eventsThisMonthGrouped = computed(() => {
  const map = {}
  for (const ev of eventsThisMonth.value) {
    if (!map[ev.event_type]) map[ev.event_type] = []
    map[ev.event_type].push(ev)
  }
  // เรียงตาม start_date ภายในแต่ละกลุ่ม
  for (const key of Object.keys(map)) {
    map[key].sort((a, b) => a.start_date.localeCompare(b.start_date))
  }
  return map
})

// ─── Helpers ──────────────────────────────────────────────────────────────────
function dateStr(year, month, day) {
  const ce = year - 543
  return `${ce}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`
}

function eventsOnDay(day) {
  if (!day) return []
  const ds = dateStr(currentYear.value, currentMonth.value, day)
  return events.value.filter(e => {
    const start = e.start_date
    const end   = e.end_date || e.start_date
    return ds >= start && ds <= end
  })
}

function isToday(day) {
  if (!day) return false
  const today = new Date()
  return today.getFullYear() === (currentYear.value - 543) &&
    today.getMonth() === currentMonth.value &&
    today.getDate() === day
}

function formatDateThai(dateStr) {
  if (!dateStr) return ''
  const [y, m, d] = dateStr.split('-')
  const thaiYear = parseInt(y) + 543
  return `${parseInt(d)} ${thaiMonths[parseInt(m) - 1]} ${thaiYear}`
}

// ─── Navigation ───────────────────────────────────────────────────────────────
function prevMonth() {
  if (currentMonth.value === 0) {
    currentMonth.value = 11
    currentYear.value--
  } else {
    currentMonth.value--
  }
}

function nextMonth() {
  if (currentMonth.value === 11) {
    currentMonth.value = 0
    currentYear.value++
  } else {
    currentMonth.value++
  }
}

// ─── Modal ────────────────────────────────────────────────────────────────────
function openCreateModal(day) {
  editTarget.value  = null
  confirmDelete.value = false
  formErrors.value  = {}
  saveError.value   = ''
  form.value = defaultForm()
  if (day) {
    form.value.start_date = dateStr(currentYear.value, currentMonth.value, day)
    form.value.end_date   = form.value.start_date
  }
  showModal.value = true
}

function openEditModal(ev) {
  editTarget.value  = ev
  confirmDelete.value = false
  formErrors.value  = {}
  saveError.value   = ''
  form.value = {
    title:         ev.title || '',
    description:   ev.description || '',
    start_date:    ev.start_date || '',
    end_date:      ev.end_date || '',
    event_type:    ev.event_type || 'activity',
    academic_year: ev.academic_year || currentYear.value,
    is_public:     ev.is_public !== false,
  }
  showModal.value = true
}

function closeModal() {
  showModal.value     = false
  editTarget.value    = null
  confirmDelete.value = false
  formErrors.value    = {}
  saveError.value     = ''
}

function confirmDeleteEvent(ev) {
  openEditModal(ev)
  confirmDelete.value = true
}

// ─── CRUD ─────────────────────────────────────────────────────────────────────
async function fetchEvents() {
  loading.value = true
  const { data, error } = await supabase
    .from('academic_calendar')
    .select('*')
    .eq('academic_year', currentYear.value)
    .order('start_date')
  if (error) console.error('fetchEvents error:', error)
  events.value = data || []
  loading.value = false
}

function validateForm() {
  const errors = {}
  if (!form.value.title?.trim()) errors.title = 'กรุณาระบุชื่อกิจกรรม'
  if (!form.value.start_date)   errors.start_date = 'กรุณาระบุวันที่เริ่ม'
  formErrors.value = errors
  return Object.keys(errors).length === 0
}

async function saveEvent() {
  if (!validateForm()) return
  saving.value  = true
  saveError.value = ''

  const payload = {
    title:         form.value.title.trim(),
    description:   form.value.description?.trim() || null,
    start_date:    form.value.start_date,
    end_date:      form.value.end_date || form.value.start_date,
    event_type:    form.value.event_type,
    academic_year: form.value.academic_year,
    is_public:     form.value.is_public,
  }

  try {
    if (editTarget.value) {
      const { error } = await supabase
        .from('academic_calendar')
        .update(payload)
        .eq('id', editTarget.value.id)
      if (error) throw error
    } else {
      const { error } = await supabase
        .from('academic_calendar')
        .insert(payload)
      if (error) throw error
    }
    await fetchEvents()
    closeModal()
  } catch (err) {
    saveError.value = err.message || 'เกิดข้อผิดพลาด กรุณาลองใหม่'
  } finally {
    saving.value = false
  }
}

async function deleteEvent() {
  if (!editTarget.value) return
  saving.value = true
  try {
    const { error } = await supabase
      .from('academic_calendar')
      .delete()
      .eq('id', editTarget.value.id)
    if (error) throw error
    await fetchEvents()
    closeModal()
  } catch (err) {
    saveError.value = err.message || 'ลบไม่สำเร็จ กรุณาลองใหม่'
  } finally {
    saving.value = false
  }
}

// ─── Excel Import ─────────────────────────────────────────────────────────────
const xlsxInput       = ref(null)
const showImportModal = ref(false)
const importRows      = ref([])
const importErrors    = ref([])
const importing       = ref(false)

const VALID_TYPES = ['holiday', 'activity', 'exam', 'term', 'meeting', 'other']

// วันหยุดราชการ 2569 (ตัวอย่าง / ปรับตามประกาศราชการ)
const HOLIDAYS_2569 = [
  { start_date: '2026-01-01', end_date: '2026-01-01', title: 'วันขึ้นปีใหม่', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-02-26', end_date: '2026-02-26', title: 'วันมาฆบูชา', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-04-06', end_date: '2026-04-06', title: 'วันจักรี', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-04-13', end_date: '2026-04-15', title: 'วันสงกรานต์', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-05-01', end_date: '2026-05-01', title: 'วันแรงงานแห่งชาติ', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-05-04', end_date: '2026-05-04', title: 'วันฉัตรมงคล', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-05-11', end_date: '2026-05-11', title: 'วันวิสาขบูชา', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-06-03', end_date: '2026-06-03', title: 'วันเฉลิมพระชนมพรรษาสมเด็จพระนางเจ้าฯ', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-07-08', end_date: '2026-07-08', title: 'วันอาสาฬหบูชา', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-07-09', end_date: '2026-07-09', title: 'วันเข้าพรรษา', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-07-28', end_date: '2026-07-28', title: 'วันเฉลิมพระชนมพรรษา ร.10', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-08-12', end_date: '2026-08-12', title: 'วันแม่แห่งชาติ', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-10-13', end_date: '2026-10-13', title: 'วันคล้ายวันสวรรคต ร.9', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-10-23', end_date: '2026-10-23', title: 'วันปิยมหาราช', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-12-05', end_date: '2026-12-05', title: 'วันพ่อแห่งชาติ', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-12-10', end_date: '2026-12-10', title: 'วันรัฐธรรมนูญ', event_type: 'holiday', academic_year: 2569 },
  { start_date: '2026-12-31', end_date: '2026-12-31', title: 'วันสิ้นปี', event_type: 'holiday', academic_year: 2569 },
]

function downloadTemplate() {
  // Use aoa_to_sheet so we can control cell types explicitly (force strings for dates)
  const headerRow = ['start_date (YYYY-MM-DD)', 'end_date (YYYY-MM-DD)', 'title', 'event_type', 'academic_year']
  const dataRows  = HOLIDAYS_2569.map(h => [h.start_date, h.end_date, h.title, h.event_type, h.academic_year])
  const ws = XLSX.utils.aoa_to_sheet([headerRow, ...dataRows])

  // Force date columns (col 0 & 1) to type string so Excel won't convert them
  for (let r = 1; r <= HOLIDAYS_2569.length; r++) {
    ;[0, 1].forEach(c => {
      const addr = XLSX.utils.encode_cell({ r, c })
      if (ws[addr]) ws[addr].t = 's'
    })
  }

  ws['!cols'] = [{ wch: 22 }, { wch: 22 }, { wch: 45 }, { wch: 12 }, { wch: 14 }]

  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'วันหยุดราชการ')
  XLSX.writeFile(wb, `template_holiday_${currentYear.value}.xlsx`)
}

// Convert whatever XLSX gives us (string / Date / serial number) → 'YYYY-MM-DD'
function toDateStr(val) {
  if (!val && val !== 0) return ''
  if (typeof val === 'string') return val.trim()
  if (val instanceof Date) {
    const y = val.getFullYear()
    const m = String(val.getMonth() + 1).padStart(2, '0')
    const d = String(val.getDate()).padStart(2, '0')
    return `${y}-${m}-${d}`
  }
  if (typeof val === 'number') {
    try {
      const info = XLSX.SSF.parse_date_code(val)
      if (info) return `${info.y}-${String(info.m).padStart(2,'0')}-${String(info.d).padStart(2,'0')}`
    } catch (_) { /* ignore */ }
  }
  return String(val).trim()
}

function onXlsxFile(e) {
  const file = e.target.files?.[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = (ev) => {
    try {
      // cellDates:true → ให้ XLSX แปลง serial เป็น JS Date ก่อน แล้วเราแปลงต่อ
      const wb   = XLSX.read(ev.target.result, { type: 'array', cellDates: true })
      const ws   = wb.Sheets[wb.SheetNames[0]]
      const raw  = XLSX.utils.sheet_to_json(ws, { defval: '' })

      const rows   = []
      const errors = []

      raw.forEach((row, i) => {
        const rowNum = i + 2 // Excel row (header = row 1)
        const start = toDateStr(row['start_date (YYYY-MM-DD)'] ?? row['start_date'] ?? '')
        const end   = toDateStr(row['end_date (YYYY-MM-DD)']   ?? row['end_date']   ?? '')
        const title = (row['title'] || '').toString().trim()
        const type  = (row['event_type'] || 'holiday').toString().trim()
        const year  = parseInt(row['academic_year'] || currentYear.value) || currentYear.value

        if (!start || !/^\d{4}-\d{2}-\d{2}$/.test(start)) {
          errors.push(`แถว ${rowNum}: start_date ไม่ถูกต้อง (${start || 'ว่าง'})`)
          return
        }
        if (!title) {
          errors.push(`แถว ${rowNum}: ไม่มีชื่อ (title)`)
          return
        }
        if (!VALID_TYPES.includes(type)) {
          errors.push(`แถว ${rowNum}: event_type "${type}" ไม่รู้จัก`)
          return
        }

        rows.push({
          start_date:    start,
          end_date:      end && /^\d{4}-\d{2}-\d{2}$/.test(end) ? end : start,
          title,
          event_type:    type,
          academic_year: year,
          is_public:     true,
        })
      })

      importRows.value   = rows
      importErrors.value = errors
      showImportModal.value = true
    } catch (err) {
      alert('อ่านไฟล์ไม่สำเร็จ: ' + err.message)
    } finally {
      // reset input so same file can be re-selected
      e.target.value = ''
    }
  }
  reader.readAsArrayBuffer(file)
}

async function confirmImport() {
  if (!importRows.value.length) return
  importing.value = true
  try {
    // Group rows by academic_year so we only delete years that appear in the file
    const years = [...new Set(importRows.value.map(r => r.academic_year))]

    for (const yr of years) {
      const { error: delErr } = await supabase
        .from('academic_calendar')
        .delete()
        .eq('event_type', 'holiday')
        .eq('academic_year', yr)
      if (delErr) throw delErr
    }

    const { error: insErr } = await supabase
      .from('academic_calendar')
      .insert(importRows.value)
    if (insErr) throw insErr

    await fetchEvents()
    showImportModal.value = false
    importRows.value      = []
    importErrors.value    = []
  } catch (err) {
    alert('นำเข้าไม่สำเร็จ: ' + err.message)
  } finally {
    importing.value = false
  }
}

// ─── Print ────────────────────────────────────────────────────────────────────
function doPrint(mode) {
  showPrintMenu.value = false
  const name = schoolName()
  const logo = logoUrl()
  if (mode === 'monthly') printMonthly(events.value, currentYear.value, name, logo)
  if (mode === 'yearly')  printYearOverview(events.value, currentYear.value, name, logo)
  if (mode === 'list')    printEventList(events.value, currentYear.value, name, logo)
}

// ─── Lifecycle ────────────────────────────────────────────────────────────────
onMounted(async () => {
  await fetchConfig()
  await fetchEvents()
})
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
.modal-enter-active .relative,
.modal-leave-active .relative {
  transition: transform 0.2s ease;
}
.modal-enter-from .relative {
  transform: scale(0.95) translateY(10px);
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>
