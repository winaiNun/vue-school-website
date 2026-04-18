<template>
  <AdminLayout>
    <div class="space-y-6">
      <!-- Tabs -->
      <div class="bg-white rounded-2xl p-1.5 shadow-sm border border-gray-100 flex gap-1 flex-wrap">
        <button v-for="tab in tabs" :key="tab.key" @click="activeTab = tab.key"
          :class="['flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all',
            activeTab === tab.key
              ? 'bg-blue-600 text-white shadow-sm'
              : 'text-gray-600 hover:bg-gray-100 hover:text-blue-600']"
        >
          <span>{{ tab.icon }}</span>
          <span class="hidden sm:inline">{{ tab.label }}</span>
        </button>
      </div>

      <!-- ─── Tab 1: ข้อมูลพื้นฐาน ─── -->
      <div v-if="activeTab === 'basic'" class="space-y-4">
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-5 flex items-center gap-2 text-base">🔑 รหัสสำคัญ</h3>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label class="label">รหัสโรงเรียน (DMC) <span class="text-red-500">*</span></label>
              <input v-model="form.school_code" type="text" maxlength="10" class="input-field font-mono" placeholder="เช่น 30022001" />
              <p class="text-xs text-gray-400 mt-1">ใช้ตรวจสอบไฟล์นำเข้าจาก DMC และส่งออกข้อมูล</p>
            </div>
            <div>
              <label class="label">รหัส SMIS</label>
              <input v-model="form.obec_smis_code" type="text" class="input-field font-mono" placeholder="เช่น 50010001" />
            </div>
            <div>
              <label class="label">รหัสเขตพื้นที่</label>
              <input v-model="form.area_code" type="text" maxlength="10" class="input-field font-mono" placeholder="เช่น 5001" />
            </div>
          </div>
        </div>

        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-5 flex items-center gap-2 text-base">📋 ข้อมูลทั่วไป</h3>
          <div class="space-y-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label class="label">ชื่อโรงเรียน (ภาษาไทย) <span class="text-red-500">*</span></label>
                <input v-model="form.name_th" type="text" class="input-field" placeholder="โรงเรียน..." />
              </div>
              <div>
                <label class="label">ชื่อโรงเรียน (ภาษาอังกฤษ)</label>
                <input v-model="form.name_en" type="text" class="input-field" placeholder="School Name..." />
              </div>
            </div>
            <div>
              <label class="label">คำขวัญโรงเรียน</label>
              <input v-model="form.motto" type="text" class="input-field" />
            </div>
            <div>
              <label class="label">วิสัยทัศน์ (Vision)</label>
              <textarea v-model="form.vision" rows="3" class="input-field" placeholder="วิสัยทัศน์..."></textarea>
            </div>
            <div>
              <label class="label">พันธกิจ (Mission)</label>
              <textarea v-model="form.mission" rows="3" class="input-field" placeholder="พันธกิจ..."></textarea>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label class="label">ประเภทสถานศึกษา</label>
                <select v-model="form.school_type" class="input-field">
                  <option>รัฐบาล</option><option>เอกชน</option><option>ท้องถิ่น</option><option>ตชด.</option>
                </select>
              </div>
              <div>
                <label class="label">ขนาดโรงเรียน</label>
                <select v-model="form.school_size" class="input-field">
                  <option>เล็ก</option><option>กลาง</option><option>ใหญ่</option><option>ใหญ่พิเศษ</option>
                </select>
              </div>
              <div>
                <label class="label">ปีที่ก่อตั้ง (พ.ศ.)</label>
                <input v-model="form.established_year" type="number" class="input-field" min="2400" max="2600" />
              </div>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label class="label">ระดับที่เปิดสอน</label>
                <select v-model="form.level_open" class="input-field">
                  <option value="">-- เลือก --</option>
                  <option>อนุบาล - ป.6</option><option>อนุบาล - ม.3</option>
                  <option>ป.1 - ป.6</option><option>ป.1 - ม.3 (ขยายโอกาส)</option>
                  <option>ม.1 - ม.3</option><option>ม.1 - ม.6</option><option>ม.4 - ม.6</option>
                </select>
              </div>
              <div>
                <label class="label">จำนวนห้องเรียน</label>
                <input v-model="form.total_rooms" type="number" class="input-field" min="0" />
              </div>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label class="label">สีประจำโรงเรียน</label>
                <input v-model="form.school_color" type="text" class="input-field" placeholder="เช่น เขียว-เหลือง" />
              </div>
              <div>
                <label class="label">ต้นไม้ประจำโรงเรียน</label>
                <input v-model="form.school_tree" type="text" class="input-field" placeholder="เช่น ราชพฤกษ์" />
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-5 flex items-center gap-2 text-base">🏛️ สังกัด</h3>
          <div class="space-y-4">
            <div>
              <label class="label">หน่วยงานต้นสังกัด</label>
              <select v-model="form.affiliation" class="input-field">
                <option>สำนักงานคณะกรรมการการศึกษาขั้นพื้นฐาน (สพฐ.)</option>
                <option>สำนักงานคณะกรรมการส่งเสริมการศึกษาเอกชน (สช.)</option>
                <option>องค์กรปกครองส่วนท้องถิ่น (อปท.)</option>
                <option>กองบัญชาการตำรวจตระเวนชายแดน (ตชด.)</option>
              </select>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label class="label">สำนักงานเขตพื้นที่การศึกษา</label>
                <input v-model="form.area_name" type="text" class="input-field" placeholder="เช่น สพป.เชียงใหม่ เขต 1" />
              </div>
              <div>
                <label class="label">จังหวัด</label>
                <input v-model="form.address_province" type="text" class="input-field" placeholder="จังหวัด..." />
              </div>
            </div>
          </div>
        </div>

        <!-- 📂 ชื่อหน้า วPA -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-1 flex items-center gap-2 text-base">📂 ชื่อหน้า วPA สาธารณะ</h3>
          <p class="text-xs text-gray-500 mb-4">ชื่อที่แสดงบนหัวหน้าเว็บไซต์ วPA ที่เปิดให้สาธารณะดูได้</p>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="label">ชื่อหน้า วPA</label>
              <input v-model="form.wpa_title" type="text" class="input-field"
                placeholder="เช่น ข้อตกลงและผลงาน (วPA)" />
            </div>
            <div class="flex items-end pb-1">
              <p class="text-xs text-gray-400">ตัวอย่าง: <span class="font-medium text-gray-600">{{ form.wpa_title || 'ข้อตกลงและผลงาน (วPA)' }}</span></p>
            </div>
          </div>
        </div>

        <!-- 🔐 รหัสลงทะเบียนสมาชิก -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-1 flex items-center gap-2 text-base">🔐 รหัสลงทะเบียนสมาชิก</h3>
          <p class="text-xs text-gray-500 mb-4">ป้องกัน bot และคนนอก — เฉพาะคนที่รู้รหัสนี้เท่านั้นที่สมัครสมาชิกได้</p>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 items-end">
            <div class="sm:col-span-2">
              <label class="label">รหัสลงทะเบียน</label>
              <input v-model="form.register_code" type="text" class="input-field font-mono"
                placeholder="เช่น SCHOOL2025 (เว้นว่าง = ปิดการใช้รหัส)" />
            </div>
            <div class="text-xs text-gray-500 leading-relaxed">
              <p v-if="form.register_code">🔒 <span class="text-green-600 font-medium">เปิดใช้งาน</span> — แจ้งรหัสนี้เฉพาะบุคลากร</p>
              <p v-else>🔓 <span class="text-yellow-600 font-medium">ปิดอยู่</span> — ใครก็สมัครได้</p>
            </div>
          </div>
        </div>
      </div>

      <!-- ─── Tab 2: ที่ตั้ง & ติดต่อ ─── -->
      <div v-if="activeTab === 'location'" class="space-y-4">
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-5 flex items-center gap-2 text-base">📍 ที่ตั้งโรงเรียน</h3>
          <div class="space-y-4">
            <div class="grid grid-cols-3 sm:grid-cols-6 gap-3">
              <div class="col-span-1">
                <label class="label">เลขที่</label>
                <input v-model="form.address_no" type="text" class="input-field" placeholder="123" />
              </div>
              <div class="col-span-1">
                <label class="label">หมู่</label>
                <input v-model="form.address_moo" type="text" class="input-field" placeholder="5" />
              </div>
              <div class="col-span-4">
                <label class="label">ถนน</label>
                <input v-model="form.address_road" type="text" class="input-field" placeholder="ถนน..." />
              </div>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <div>
                <label class="label">ตำบล/แขวง</label>
                <input v-model="form.address_subdistrict" type="text" class="input-field" />
              </div>
              <div>
                <label class="label">อำเภอ/เขต</label>
                <input v-model="form.address_district" type="text" class="input-field" />
              </div>
              <div>
                <label class="label">จังหวัด</label>
                <input v-model="form.address_province" type="text" class="input-field" />
              </div>
              <div>
                <label class="label">รหัสไปรษณีย์</label>
                <input v-model="form.zipcode" type="text" maxlength="5" class="input-field font-mono" />
              </div>
            </div>
            <div>
              <label class="label">ที่อยู่รวม (สำหรับแสดงผล)</label>
              <textarea v-model="form.address" rows="2" class="input-field" placeholder="หรือพิมพ์ที่อยู่เต็มที่นี่"></textarea>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="label">ละติจูด (Latitude)</label>
                <input v-model="form.lat" type="number" step="0.0000001" class="input-field font-mono" placeholder="18.7883" />
              </div>
              <div>
                <label class="label">ลองจิจูด (Longitude)</label>
                <input v-model="form.lng" type="number" step="0.0000001" class="input-field font-mono" placeholder="98.9853" />
              </div>
            </div>
            <p class="text-xs text-gray-400">
              💡 หาพิกัดจาก
              <a href="https://maps.google.com" target="_blank" class="text-blue-500 underline">Google Maps</a>
              → คลิกขวาบนแผนที่ → "พิกัดของตำแหน่งนี้"
            </p>
            <div v-if="form.lat && form.lng" class="rounded-xl overflow-hidden border border-gray-200 h-64">
              <iframe :src="`https://maps.google.com/maps?q=${form.lat},${form.lng}&z=15&output=embed`"
                width="100%" height="100%" frameborder="0" allowfullscreen class="w-full h-full"></iframe>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-5 flex items-center gap-2 text-base">📞 ข้อมูลติดต่อ</h3>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="label">โทรศัพท์</label>
              <input v-model="form.phone" type="tel" class="input-field" placeholder="053-000-000" />
            </div>
            <div>
              <label class="label">โทรสาร (Fax)</label>
              <input v-model="form.fax" type="tel" class="input-field" placeholder="053-000-001" />
            </div>
            <div>
              <label class="label">อีเมลโรงเรียน</label>
              <input v-model="form.email" type="email" class="input-field" />
            </div>
            <div>
              <label class="label">เว็บไซต์</label>
              <input v-model="form.website" type="url" class="input-field" placeholder="https://..." />
            </div>
          </div>
        </div>

        <!-- ─── โซเชียลมีเดีย ─── -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-2 flex items-center gap-2 text-base">📱 โซเชียลมีเดีย</h3>
          <p class="text-xs text-gray-400 mb-5">ติ๊กถูก "แสดง" เพื่อให้ไอคอนนั้นปรากฏใน Footer ของเว็บไซต์</p>

          <div class="space-y-4">
            <!-- Facebook -->
            <div class="flex items-start gap-3">
              <div class="flex-shrink-0 pt-6">
                <label class="flex items-center gap-2 cursor-pointer select-none">
                  <input type="checkbox" v-model="form.show_social_facebook" class="w-4 h-4 accent-blue-600 rounded" />
                  <span class="text-xs text-gray-600">แสดง</span>
                </label>
              </div>
              <div class="flex-1">
                <label class="label flex items-center gap-2">
                  <svg class="w-5 h-5 text-blue-600" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                  </svg>
                  Facebook Page
                </label>
                <input v-model="form.social_facebook" type="url" class="input-field" placeholder="https://facebook.com/..." />
              </div>
            </div>

            <!-- Line -->
            <div class="flex items-start gap-3">
              <div class="flex-shrink-0 pt-6">
                <label class="flex items-center gap-2 cursor-pointer select-none">
                  <input type="checkbox" v-model="form.show_social_line" class="w-4 h-4 accent-green-600 rounded" />
                  <span class="text-xs text-gray-600">แสดง</span>
                </label>
              </div>
              <div class="flex-1">
                <label class="label flex items-center gap-2">
                  <svg class="w-5 h-5 text-green-500" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M19.365 9.863c.349 0 .63.285.63.631 0 .345-.281.63-.63.63H17.61v1.125h1.755c.349 0 .63.283.63.63 0 .344-.281.629-.63.629h-2.386c-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.627-.63h2.386c.349 0 .63.285.63.63 0 .349-.281.63-.63.63H17.61v1.125h1.755zm-3.855 3.016c0 .27-.174.51-.432.596-.064.021-.133.031-.199.031-.211 0-.391-.09-.51-.25l-2.443-3.317v2.94c0 .344-.279.629-.631.629-.346 0-.626-.285-.626-.629V8.108c0-.27.173-.51.43-.595.06-.023.136-.033.194-.033.195 0 .375.104.495.254l2.462 3.33V8.108c0-.345.282-.63.63-.63.345 0 .63.285.63.63v4.771zm-5.741 0c0 .344-.282.629-.631.629-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.627-.63.349 0 .631.285.631.63v4.771zm-2.466.629H4.917c-.345 0-.63-.285-.63-.629V8.108c0-.345.285-.63.63-.63.348 0 .63.285.63.63v4.141h1.756c.348 0 .629.283.629.63 0 .344-.281.629-.629.629M24 10.314C24 4.943 18.615.572 12 .572S0 4.943 0 10.314c0 4.811 4.27 8.842 10.035 9.608.391.082.923.258 1.058.59.12.301.079.766.038 1.08l-.164 1.02c-.045.301-.24 1.186 1.049.645 1.291-.539 6.916-4.070 9.436-6.975C23.176 14.393 24 12.458 24 10.314"/>
                  </svg>
                  Line Official
                </label>
                <input v-model="form.social_line" type="text" class="input-field" placeholder="@lineid หรือ https://line.me/..." />
              </div>
            </div>

            <!-- YouTube -->
            <div class="flex items-start gap-3">
              <div class="flex-shrink-0 pt-6">
                <label class="flex items-center gap-2 cursor-pointer select-none">
                  <input type="checkbox" v-model="form.show_social_youtube" class="w-4 h-4 accent-red-600 rounded" />
                  <span class="text-xs text-gray-600">แสดง</span>
                </label>
              </div>
              <div class="flex-1">
                <label class="label flex items-center gap-2">
                  <svg class="w-5 h-5 text-red-500" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
                  </svg>
                  YouTube Channel
                </label>
                <input v-model="form.social_youtube" type="url" class="input-field" placeholder="https://youtube.com/@channel" />
              </div>
            </div>

            <!-- TikTok -->
            <div class="flex items-start gap-3">
              <div class="flex-shrink-0 pt-6">
                <label class="flex items-center gap-2 cursor-pointer select-none">
                  <input type="checkbox" v-model="form.show_social_tiktok" class="w-4 h-4 accent-gray-800 rounded" />
                  <span class="text-xs text-gray-600">แสดง</span>
                </label>
              </div>
              <div class="flex-1">
                <label class="label flex items-center gap-2">
                  <svg class="w-5 h-5 text-gray-900" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.08 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.19-3.44-3.37-3.65-5.71-.02-.5-.03-1-.01-1.49.18-1.9 1.12-3.72 2.58-4.96 1.66-1.44 3.98-2.13 6.15-1.72.02 1.48-.04 2.96-.04 4.44-.99-.32-2.15-.23-3.02.37-.63.41-1.11 1.04-1.36 1.75-.21.51-.15 1.07-.14 1.61.24 1.64 1.82 3.02 3.5 2.87 1.12-.01 2.19-.66 2.77-1.61.19-.33.4-.67.41-1.06.1-1.79.06-3.57.07-5.36.01-4.03-.01-8.05.02-12.07z"/>
                  </svg>
                  TikTok
                </label>
                <input v-model="form.social_tiktok" type="url" class="input-field" placeholder="https://tiktok.com/@username" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ─── Tab 3: ผู้บริหาร ─── -->
      <div v-if="activeTab === 'director'" class="space-y-4">
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-5 flex items-center gap-2 text-base">👤 ผู้อำนวยการโรงเรียน</h3>
          <div class="flex flex-col sm:flex-row gap-6 items-start">
            <!-- Upload รูปผู้อำนวยการ -->
            <div class="flex flex-col items-center gap-2 flex-shrink-0">
              <p class="text-xs font-medium text-gray-600 self-start">รูปผู้อำนวยการ</p>
              <ImageUploadCrop
                v-model="form.director_image_url"
                bucket="school"
                storage-path="directors/director.jpg"
                shape="square"
                :aspect-ratio="3/4"
                :output-width="300"
                container-class="w-32 h-40 rounded-2xl"
                icon="👤"
                placeholder="อัปโหลดรูปภาพ"
                hint="สัดส่วน 3:4"
              />
            </div>

            <div class="flex-1 space-y-4 w-full">
              <div class="grid grid-cols-3 gap-3">
                <div>
                  <label class="label">คำนำหน้า</label>
                  <select v-model="form.director_prefix" class="input-field">
                    <option>นาย</option><option>นาง</option><option>นางสาว</option>
                    <option>ดร.</option><option>ผอ.</option>
                  </select>
                </div>
                <div class="col-span-2">
                  <label class="label">ชื่อ-นามสกุล ผู้อำนวยการ</label>
                  <input v-model="form.director_name" type="text" class="input-field" placeholder="ชื่อ นามสกุล" />
                </div>
              </div>
              <div>
                <label class="label">เบอร์โทรศัพท์ผู้อำนวยการ</label>
                <input v-model="form.director_phone" type="tel" class="input-field" placeholder="08X-XXX-XXXX" />
              </div>
            </div>
          </div>
        </div>

        <!-- รองผู้อำนวยการ -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center justify-between mb-5">
            <h3 class="font-bold text-gray-900 flex items-center gap-2 text-base">👥 รองผู้อำนวยการ / ฝ่ายบริหาร</h3>
            <button @click="addDeputy" class="text-sm bg-blue-50 text-blue-600 border border-blue-200 px-3 py-1.5 rounded-lg hover:bg-blue-100 transition-colors">
              + เพิ่ม
            </button>
          </div>
          <div class="space-y-3">
            <div v-for="(d, i) in deputies" :key="i"
              class="p-4 bg-gray-50 rounded-xl space-y-3">
              <div class="flex items-center justify-between">
                <span class="text-xs font-medium text-gray-500">รองผู้อำนวยการ / ผู้บริหารคนที่ {{ i + 1 }}</span>
                <button @click="deputies.splice(i, 1)" class="text-red-400 hover:text-red-600 text-sm">🗑️ ลบ</button>
              </div>
              <div class="flex flex-col sm:flex-row gap-4 items-start">
                <!-- รูปรองผอ. -->
                <ImageUploadCrop
                  v-model="d.image_url"
                  bucket="school"
                  :storage-path="'deputies/deputy-' + i + '.jpg'"
                  shape="square"
                  :aspect-ratio="3/4"
                  :output-width="300"
                  container-class="w-20 h-24 rounded-xl"
                  icon="👤"
                  placeholder="รูปภาพ"
                />
                <div class="flex-1 space-y-2 w-full">
                  <div class="grid grid-cols-3 gap-2">
                    <select v-model="d.prefix" class="input-field text-sm py-1.5">
                      <option>นาย</option><option>นาง</option><option>นางสาว</option><option>ดร.</option>
                    </select>
                    <div class="col-span-2">
                      <input v-model="d.name" type="text" class="input-field text-sm py-1.5" placeholder="ชื่อ-นามสกุล" />
                    </div>
                  </div>
                  <input v-model="d.position" type="text" class="input-field text-sm py-1.5" placeholder="ตำแหน่ง เช่น รองผู้อำนวยการฝ่ายวิชาการ" />
                </div>
              </div>
            </div>
            <div v-if="!deputies.length" class="text-center py-6 text-gray-400 text-sm border-2 border-dashed border-gray-200 rounded-xl">
              ยังไม่มีข้อมูลรองผู้อำนวยการ
            </div>
          </div>
        </div>
      </div>

      <!-- ─── Tab 4: โลโก้ & แบนเนอร์ ─── -->
      <div v-if="activeTab === 'media'" class="space-y-4">
        <!-- Logo Upload -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-2 flex items-center gap-2 text-base">🖼️ โลโก้โรงเรียน</h3>
          <p class="text-xs text-gray-400 mb-5">แนะนำ: PNG พื้นหลังโปร่งใส (Transparent) ขนาด 400×400px</p>
          <div class="flex flex-col sm:flex-row items-start gap-8">
            <ImageUploadCrop
              v-model="form.logo_url"
              bucket="school"
              storage-path="logos/logo.png"
              shape="square"
              :aspect-ratio="1"
              :output-width="400"
              format="png"
              container-class="w-40 h-40 rounded-2xl"
              icon="🏫"
              placeholder="อัปโหลดโลโก้"
              hint="PNG โปร่งใส 400×400px"
            />
            <!-- Preview ในบริบทต่างๆ -->
            <div class="space-y-3">
              <p class="text-xs font-medium text-gray-600">ตัวอย่างการแสดงผล:</p>
              <div class="flex items-center gap-3 bg-blue-900 rounded-xl px-4 py-3">
                <div class="w-9 h-9 rounded-full bg-white overflow-hidden flex-shrink-0">
                  <img v-if="form.logo_url" :src="form.logo_url" class="w-full h-full object-contain p-0.5" />
                  <span v-else class="w-full h-full flex items-center justify-center text-sm">🏫</span>
                </div>
                <span class="text-white text-sm font-medium">{{ form.name_th || 'ชื่อโรงเรียน' }}</span>
              </div>
              <div class="flex items-center gap-3 bg-white border border-gray-200 rounded-xl px-4 py-3">
                <div class="w-12 h-12 rounded-full bg-gray-50 border border-gray-200 overflow-hidden flex-shrink-0">
                  <img v-if="form.logo_url" :src="form.logo_url" class="w-full h-full object-contain p-1" />
                  <span v-else class="w-full h-full flex items-center justify-center text-lg">🏫</span>
                </div>
                <div>
                  <p class="text-sm font-bold text-gray-900">{{ form.name_th || 'ชื่อโรงเรียน' }}</p>
                  <p class="text-xs text-gray-400">{{ form.name_en || 'School Name' }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Banners -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center justify-between mb-4">
            <div>
              <h3 class="font-bold text-gray-900 flex items-center gap-2 text-base">🎠 แบนเนอร์หน้าแรก</h3>
              <p class="text-xs text-gray-400 mt-1">สัดส่วน 16:6 (1280×480px) · รองรับภาพและวิดีโอ MP4 · สูงสุด 5 รายการ</p>
            </div>
            <button @click="addBanner" class="text-sm bg-blue-50 text-blue-600 border border-blue-200 px-3 py-1.5 rounded-lg hover:bg-blue-100 transition-colors">
              + เพิ่มแบนเนอร์
            </button>
          </div>

          <!-- โหมดแบนเนอร์ -->
          <div class="flex items-center gap-3 mb-5 p-3 bg-gray-50 rounded-xl border border-gray-100">
            <span class="text-sm text-gray-600 font-medium">โหมดแสดงผล:</span>
            <div class="flex gap-2">
              <button @click="form.banner_autoplay = true"
                :class="['px-3 py-1.5 text-xs rounded-lg border transition-colors flex items-center gap-1.5',
                  form.banner_autoplay !== false ? 'bg-blue-600 text-white border-blue-600' : 'text-gray-500 border-gray-200 hover:border-blue-300']">
                ▶️ สไลด์โชว์อัตโนมัติ
              </button>
              <button @click="form.banner_autoplay = false"
                :class="['px-3 py-1.5 text-xs rounded-lg border transition-colors flex items-center gap-1.5',
                  form.banner_autoplay === false ? 'bg-blue-600 text-white border-blue-600' : 'text-gray-500 border-gray-200 hover:border-blue-300']">
                🔒 ล็อกภาพแรก
              </button>
            </div>
            <span v-if="form.banner_autoplay !== false" class="text-xs text-gray-400">เปลี่ยนทุก 5 วินาที</span>
            <span v-else class="text-xs text-gray-400">แสดงภาพ/วิดีโอแรกอย่างเดียว</span>
          </div>
          <div class="space-y-5">
            <div v-for="(b, i) in banners" :key="i" class="border border-gray-100 rounded-2xl p-4 space-y-4 bg-gray-50/50">
              <div class="flex items-center justify-between">
                <span class="text-sm font-medium text-gray-700">🖼️ แบนเนอร์ที่ {{ i + 1 }}</span>
                <button @click="banners.splice(i, 1)" class="text-red-400 hover:text-red-600 text-sm flex items-center gap-1">
                  🗑️ ลบ
                </button>
              </div>

              <!-- Type Toggle -->
              <div class="flex gap-2 mb-1">
                <button @click="b.type = 'image'"
                  :class="['px-3 py-1 text-xs rounded-lg border transition-colors', b.type !== 'video' ? 'bg-blue-600 text-white border-blue-600' : 'text-gray-500 border-gray-200 hover:border-blue-300']">
                  🖼️ ภาพ
                </button>
                <button @click="b.type = 'video'"
                  :class="['px-3 py-1 text-xs rounded-lg border transition-colors', b.type === 'video' ? 'bg-blue-600 text-white border-blue-600' : 'text-gray-500 border-gray-200 hover:border-blue-300']">
                  🎬 วิดีโอ MP4
                </button>
              </div>

              <div class="flex flex-col sm:flex-row gap-4 items-start">
                <!-- Banner Upload: Image -->
                <div v-if="b.type !== 'video'" class="w-full sm:w-64 flex-shrink-0">
                  <ImageUploadCrop
                    v-model="b.url"
                    bucket="school"
                    :storage-path="'banners/banner-' + i + '.jpg'"
                    :aspect-ratio="16/6"
                    :output-width="1280"
                    container-class="w-full rounded-xl aspect-[16/6]"
                    icon="🖼️"
                    placeholder="คลิกเพื่ออัปโหลดภาพแบนเนอร์"
                    hint="16:6 · 1280×480px · แนะนำภาพแนวนอนกว้าง"
                  />
                  <button v-if="b.url" @click="deleteStorageFile(b.url, i)"
                    class="mt-1.5 w-full text-xs text-red-400 hover:text-red-600 flex items-center justify-center gap-1 py-1 rounded-lg hover:bg-red-50 transition-colors">
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                    </svg>
                    ลบไฟล์ออกจาก Storage
                  </button>
                </div>

                <!-- Banner Upload: Video -->
                <div v-else class="w-full sm:w-64 flex-shrink-0">
                  <input :ref="el => videoRefs[i] = el" type="file" accept="video/mp4,video/webm" class="hidden"
                    @change="handleVideoUpload($event, i)" />
                  <div @click="videoRefs[i]?.click()"
                    class="relative w-full aspect-[16/6] rounded-xl overflow-hidden border-2 border-dashed border-gray-300 hover:border-blue-400 cursor-pointer group bg-gray-50 flex items-center justify-center">
                    <video v-if="b.url && !videoUploading[i]"
                      :src="b.url" loop muted autoplay playsinline
                      class="absolute inset-0 w-full h-full object-cover pointer-events-none" />
                    <!-- Overlay -->
                    <div v-if="b.url && !videoUploading[i]"
                      class="absolute inset-0 bg-black/0 group-hover:bg-black/50 transition-colors flex items-center justify-center">
                      <span class="text-white text-xs font-medium opacity-0 group-hover:opacity-100">🎬 เปลี่ยนวิดีโอ</span>
                    </div>
                    <!-- Uploading -->
                    <div v-if="videoUploading[i]" class="absolute inset-0 bg-black/60 flex flex-col items-center justify-center gap-2">
                      <svg class="w-6 h-6 text-white animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                      </svg>
                      <span class="text-white text-xs">กำลังอัปโหลด...</span>
                    </div>
                    <!-- Empty -->
                    <div v-if="!b.url && !videoUploading[i]" class="flex flex-col items-center gap-1 text-gray-400">
                      <span class="text-3xl">🎬</span>
                      <span class="text-xs font-medium">คลิกเพื่ออัปโหลดวิดีโอ</span>
                      <span class="text-[10px]">MP4 · ไม่เกิน 50MB · แนะนำ 10-15 วินาที</span>
                    </div>
                  </div>
                  <button v-if="b.url" @click="deleteStorageFile(b.url, i)"
                    class="mt-1.5 w-full text-xs text-red-400 hover:text-red-600 flex items-center justify-center gap-1 py-1 rounded-lg hover:bg-red-50 transition-colors">
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                    </svg>
                    ลบไฟล์ออกจาก Storage
                  </button>
                </div>

                <div class="flex-1 space-y-3 w-full">
                  <div>
                    <label class="label">หัวข้อ (Caption)</label>
                    <input v-model="b.caption" type="text" class="input-field" placeholder="ชื่อโรงเรียน หรือหัวข้อ..." />
                  </div>
                  <div>
                    <label class="label">คำบรรยาย (Sub Caption)</label>
                    <input v-model="b.subcaption" type="text" class="input-field" placeholder="คำขวัญ หรือรายละเอียด..." />
                  </div>
                  <div class="border-t border-gray-100 pt-3">
                    <label class="label flex items-center gap-1">🔗 ลิงก์ (ถ้าต้องการให้คลิกได้)</label>
                    <input v-model="b.link" type="url" class="input-field" placeholder="https://..." />
                  </div>
                  <div v-if="b.link">
                    <label class="label">ชื่อปุ่ม</label>
                    <input v-model="b.link_label" type="text" class="input-field" placeholder="ดูเพิ่มเติม" />
                  </div>
                </div>
              </div>
            </div>

            <div v-if="!banners.length" class="text-center py-12 text-gray-400 border-2 border-dashed border-gray-200 rounded-2xl">
              <div class="text-5xl mb-3">🎠</div>
              <p class="text-sm font-medium">ยังไม่มีแบนเนอร์</p>
              <p class="text-xs mt-1">กด "+ เพิ่มแบนเนอร์" เพื่อเริ่มต้น</p>
            </div>
          </div>
        </div>
      </div>

      <!-- ─── Tab 5: Preview ─── -->
      <!-- ── Tab: ธีมสี ───────────────────────────────────── -->
      <div v-if="activeTab === 'theme'" class="space-y-6">
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-5 flex items-center gap-2">🎨 เลือกธีมสีเว็บไซต์</h3>

          <!-- Color Themes -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
            <button v-for="t in themes" :key="t.key"
              @click="form.theme = t.key; form.nav_color = t.navColor"
              :class="['relative rounded-2xl overflow-hidden border-2 transition-all duration-200 text-left',
                form.theme === t.key && form.nav_color === t.navColor ? 'border-blue-500 shadow-lg scale-105' : 'border-gray-200 hover:border-gray-300']"
            >
              <div class="h-16" :style="navColorToStyle(t.navColor)"></div>
              <div class="p-2.5 bg-white">
                <p class="font-semibold text-sm text-gray-900">{{ t.label }}</p>
                <p class="text-xs text-gray-400">{{ t.desc }}</p>
              </div>
              <div v-if="form.theme === t.key && form.nav_color === t.navColor"
                class="absolute top-2 right-2 w-5 h-5 bg-blue-500 rounded-full flex items-center justify-center text-white text-xs font-bold shadow">✓</div>
            </button>

            <!-- Custom color card -->
            <label :class="['relative rounded-2xl overflow-hidden border-2 transition-all duration-200 text-left cursor-pointer',
                form.theme === 'custom' ? 'border-blue-500 shadow-lg scale-105' : 'border-dashed border-gray-300 hover:border-gray-400']">
              <div class="h-16 flex items-center justify-center text-2xl relative overflow-hidden"
                   :style="form.theme === 'custom' ? navColorToStyle(form.nav_color) : { background: 'linear-gradient(135deg,#e2e8f0,#cbd5e1)' }">
                <span v-if="form.theme !== 'custom'" class="text-gray-400">🎨</span>
                <span v-else class="text-white text-xs font-bold">{{ form.nav_color?.toUpperCase() }}</span>
                <input type="color" :value="form.nav_color || '#1e3a8a'"
                       @input="form.theme = 'custom'; form.nav_color = $event.target.value"
                       class="absolute inset-0 opacity-0 w-full h-full cursor-pointer" />
              </div>
              <div class="p-2.5 bg-white">
                <p class="font-semibold text-sm text-gray-900">กำหนดเอง</p>
                <p class="text-xs text-gray-400">เลือกสีจากวงล้อ</p>
              </div>
              <div v-if="form.theme === 'custom'"
                class="absolute top-2 right-2 w-5 h-5 bg-blue-500 rounded-full flex items-center justify-center text-white text-xs font-bold shadow">✓</div>
            </label>
          </div>

          <!-- Preview live -->
          <div class="rounded-2xl overflow-hidden border border-gray-200 mb-8">
            <p class="text-xs text-gray-500 px-4 py-2 bg-gray-50 border-b">ตัวอย่าง Navbar (บันทึกแล้วจะเห็นผลทั้งเว็บ)</p>
            <div class="h-14 flex items-center px-5 gap-3 text-white text-sm font-bold"
                 :style="themePreviewStyle">
              <div class="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center text-xs">ร</div>
              <span>{{ form.name_th || 'โรงเรียนของคุณ' }}</span>
              <div class="ml-auto flex gap-4 text-xs font-normal opacity-80">
                <span>หน้าแรก</span><span>บุคลากร</span><span>ข่าว</span>
              </div>
            </div>
          </div>

          <!-- Mourning Mode -->
          <div class="border border-gray-200 rounded-2xl p-5">
            <h4 class="font-bold text-gray-900 mb-1 flex items-center gap-2">⬛ โหมดไว้ทุกข์</h4>
            <p class="text-xs text-gray-500 mb-4">เว็บทั้งหมดจะเป็นขาวดำโดยอัตโนมัติ (รวมรูปภาพ) จนถึงวันที่ที่กำหนด</p>
            <div class="flex flex-col sm:flex-row gap-3 items-start sm:items-end">
              <div class="flex-1">
                <label class="label">ไว้ทุกข์ถึงวันที่</label>
                <input v-model="form.mourning_until" type="date" class="input-field"
                  :min="todayStr" />
              </div>
              <button v-if="form.mourning_until" @click="form.mourning_until = null"
                class="text-sm text-red-500 hover:text-red-700 border border-red-200 px-4 py-2.5 rounded-lg hover:bg-red-50 transition-colors whitespace-nowrap">
                ❌ ยกเลิกโหมดไว้ทุกข์
              </button>
            </div>
            <div v-if="form.mourning_until" class="mt-3 bg-gray-100 rounded-xl px-4 py-3 text-sm text-gray-700 flex items-center gap-2">
              <span class="text-lg">⬛</span>
              โหมดไว้ทุกข์เปิดใช้งาน ถึง <strong>{{ new Date(form.mourning_until).toLocaleDateString('th-TH', {year:'numeric',month:'long',day:'numeric'}) }}</strong>
            </div>
          </div>
        </div>
      </div>

      <div v-if="activeTab === 'preview'" class="space-y-4">
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-6 flex items-center gap-2">👁️ ตัวอย่างการแสดงผล</h3>
          <div class="space-y-4 text-sm">
            <div class="border border-blue-100 rounded-2xl p-5 bg-blue-50">
              <div class="flex items-center gap-4 mb-4">
                <div class="w-16 h-16 rounded-full bg-white border-2 border-blue-200 overflow-hidden flex-shrink-0 flex items-center justify-center">
                  <img v-if="form.logo_url" :src="form.logo_url" class="w-full h-full object-contain p-1" />
                  <span v-else class="text-2xl">🏫</span>
                </div>
                <div>
                  <h2 class="font-bold text-gray-900 text-lg">{{ form.name_th || 'ชื่อโรงเรียน' }}</h2>
                  <p class="text-gray-500 text-xs">{{ form.name_en }}</p>
                  <p class="text-blue-600 text-xs italic mt-1">"{{ form.motto }}"</p>
                </div>
              </div>
              <div class="grid grid-cols-2 gap-3 text-xs">
                <div class="bg-white rounded-xl p-3">
                  <p class="text-gray-400 mb-1">รหัสโรงเรียน</p>
                  <p class="font-mono font-bold">{{ form.school_code || '-' }}</p>
                </div>
                <div class="bg-white rounded-xl p-3">
                  <p class="text-gray-400 mb-1">สังกัดเขต</p>
                  <p class="font-medium">{{ form.area_name || '-' }}</p>
                </div>
                <div class="bg-white rounded-xl p-3">
                  <p class="text-gray-400 mb-1">ผู้อำนวยการ</p>
                  <p class="font-medium">{{ form.director_prefix }} {{ form.director_name || '-' }}</p>
                </div>
                <div class="bg-white rounded-xl p-3">
                  <p class="text-gray-400 mb-1">ขนาดโรงเรียน</p>
                  <p class="font-medium">{{ form.school_size || '-' }}</p>
                </div>
                <div class="bg-white rounded-xl p-3 col-span-2">
                  <p class="text-gray-400 mb-1">ที่อยู่</p>
                  <p>{{ fullAddress }}</p>
                </div>
              </div>

              <!-- Social preview -->
              <div v-if="activeSocials.length" class="mt-4 pt-4 border-t border-blue-100">
                <p class="text-xs text-gray-500 mb-2">โซเชียลที่แสดงใน Footer:</p>
                <div class="flex gap-3 flex-wrap">
                  <a v-for="s in activeSocials" :key="s.key"
                    :href="s.url" target="_blank"
                    :class="['w-9 h-9 rounded-full flex items-center justify-center text-white text-sm transition-opacity hover:opacity-80', s.bg]"
                    :title="s.label"
                  >
                    <span v-html="s.icon"></span>
                  </a>
                </div>
              </div>
            </div>

            <div class="border border-green-100 rounded-2xl p-5 bg-green-50">
              <p class="font-semibold text-green-900 mb-3 text-sm">📤 ตัวอย่างข้อมูลที่จะส่งออก</p>
              <div class="bg-white rounded-xl p-3 font-mono text-xs text-gray-700 overflow-x-auto">
                <pre>{{ exportPreview }}</pre>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ─── Tab: Section หน้าแรก ─── -->
      <div v-if="activeTab === 'sections'" class="space-y-4">
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-1 flex items-center gap-2 text-base">🏠 Section หน้าแรก</h3>
          <p class="text-sm text-gray-400 mb-5">กำหนดชื่อ คำอธิบาย สไตล์เส้น ลำดับ และการแสดงผลของแต่ละ Section</p>

          <div class="space-y-3">
            <div v-for="(sec, idx) in form.homepage_sections" :key="sec.id"
                 class="border rounded-xl overflow-hidden transition-all"
                 :class="sec.visible ? 'border-gray-200' : 'border-gray-200 opacity-55'">

              <!-- ── Header row (คลิกเพื่อขยาย) ── -->
              <div class="flex items-center gap-2 p-3 bg-gray-50/80 cursor-pointer select-none"
                   @click="expandedSec = expandedSec === sec.id ? null : sec.id">
                <!-- ↑↓ Order buttons -->
                <div class="flex flex-col gap-0.5 shrink-0" @click.stop>
                  <button @click="moveSec(idx, -1)" :disabled="idx === 0"
                          class="w-6 h-5 flex items-center justify-center rounded text-xs text-gray-500 hover:bg-gray-200 disabled:opacity-30 disabled:cursor-not-allowed">▲</button>
                  <button @click="moveSec(idx, 1)" :disabled="idx === form.homepage_sections.length - 1"
                          class="w-6 h-5 flex items-center justify-center rounded text-xs text-gray-500 hover:bg-gray-200 disabled:opacity-30 disabled:cursor-not-allowed">▼</button>
                </div>
                <!-- Visible toggle -->
                <button @click.stop="sec.visible = !sec.visible"
                        class="shrink-0 w-8 h-8 flex items-center justify-center rounded-lg text-base transition-all"
                        :class="sec.visible ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-400'"
                        :title="sec.visible ? 'คลิกเพื่อซ่อน' : 'คลิกเพื่อแสดง'">
                  {{ sec.visible ? '👁️' : '🙈' }}
                </button>
                <!-- Section id badge -->
                <span class="shrink-0 text-xs px-2 py-0.5 rounded-full bg-gray-100 text-gray-400">{{ SECTION_LABELS[sec.id] }}</span>
                <!-- Icon + Title -->
                <span class="text-base shrink-0">{{ sec.icon }}</span>
                <span class="font-medium text-gray-700 flex-1 truncate text-sm">{{ sec.title }}</span>
                <!-- Variant badge -->
                <span class="shrink-0 hidden sm:inline text-xs px-2 py-0.5 rounded-full font-medium"
                      :style="{ background: sec.stemColor + '22', color: sec.stemColor }">
                  {{ VARIANTS.find(v => v.key === sec.variant)?.label || sec.variant }}
                </span>
                <!-- Color dot -->
                <span class="shrink-0 w-4 h-4 rounded-full border-2 border-white shadow"
                      :style="{ background: sec.stemColor }"></span>
                <!-- Expand icon -->
                <span class="shrink-0 text-gray-400 text-xs">{{ expandedSec === sec.id ? '▲' : '▼' }}</span>
              </div>

              <!-- ── Edit form ── -->
              <div v-show="expandedSec === sec.id" class="p-5 space-y-4 border-t border-gray-100 bg-white">
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <div class="sm:col-span-2">
                    <label class="label">ชื่อ Section</label>
                    <input v-model="sec.title" type="text" class="input-field" placeholder="ข่าวประชาสัมพันธ์" />
                  </div>
                  <div>
                    <label class="label">ไอคอน (emoji)</label>
                    <input v-model="sec.icon" type="text" class="input-field text-center text-xl" maxlength="4" placeholder="📰" />
                  </div>
                </div>
                <div>
                  <label class="label">คำอธิบาย</label>
                  <input v-model="sec.subtitle" type="text" class="input-field" placeholder="คำอธิบายสั้นๆ" />
                </div>

                <!-- Variant selector -->
                <div>
                  <label class="label">สไตล์เส้นและกรอบ</label>
                  <div class="grid grid-cols-5 gap-2">
                    <button v-for="v in VARIANTS" :key="v.key" @click="sec.variant = v.key"
                            class="p-2.5 rounded-xl border-2 text-center transition-all"
                            :class="sec.variant === v.key
                              ? 'border-blue-500 bg-blue-50 shadow-sm'
                              : 'border-gray-200 hover:border-gray-300 bg-white'">
                      <div class="text-2xl mb-1">{{ v.icon }}</div>
                      <div class="text-xs font-medium"
                           :class="sec.variant === v.key ? 'text-blue-600' : 'text-gray-400'">{{ v.label }}</div>
                    </button>
                  </div>
                </div>

                <!-- Color presets + Color wheel -->
                <div>
                  <label class="label">สีธีม</label>
                  <div class="flex flex-wrap gap-2 items-center">

                    <!-- Preset swatches -->
                    <button v-for="c in COLOR_PRESETS" :key="c.stem"
                            @click="applyPresetColor(sec, c)"
                            class="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg border-2 text-xs font-medium transition-all"
                            :class="sec.stemColor === c.stem ? 'border-gray-500 shadow-sm' : 'border-transparent hover:border-gray-200'"
                            :style="{ background: c.stem + '1a' }">
                      <span class="w-3.5 h-3.5 rounded-full flex-shrink-0" :style="{ background: c.stem }"></span>
                      <span class="text-gray-600">{{ c.label }}</span>
                    </button>

                    <!-- Divider -->
                    <div class="w-px h-7 bg-gray-200 mx-0.5 flex-shrink-0"></div>

                    <!-- Color wheel picker (วงล้อเลือกสีเอง) -->
                    <label class="relative flex items-center gap-1.5 px-3 py-1.5 rounded-lg border-2 cursor-pointer text-xs font-medium transition-all hover:border-gray-300 select-none"
                           :class="isCustomColor(sec) ? 'border-gray-500 shadow-sm' : 'border-dashed border-gray-300'"
                           :style="{ background: isCustomColor(sec) ? sec.stemColor + '1a' : '' }"
                           title="เลือกสีกำหนดเองจากวงล้อสี">
                      <!-- แสดงสีปัจจุบันถ้าเป็น custom -->
                      <span v-if="isCustomColor(sec)"
                            class="w-3.5 h-3.5 rounded-full flex-shrink-0 border border-white shadow-sm"
                            :style="{ background: sec.stemColor }"></span>
                      <!-- ไอคอนวงล้อ -->
                      <span v-else class="text-base leading-none">🎨</span>
                      <span class="text-gray-600">{{ isCustomColor(sec) ? sec.stemColor.toUpperCase() : 'กำหนดเอง' }}</span>
                      <!-- Native color input — ซ่อนแต่คลิกได้เต็มพื้นที่ -->
                      <input type="color"
                             :value="sec.stemColor"
                             @input="applyCustomColor(sec, $event.target.value)"
                             class="absolute inset-0 opacity-0 w-full h-full cursor-pointer"
                             title="เลือกสีจากวงล้อ"/>
                    </label>

                  </div>
                  <!-- แสดงสีที่เลือกอยู่ตอนนี้ -->
                  <div class="mt-2 flex items-center gap-2 text-xs text-gray-500">
                    <span class="w-4 h-4 rounded-full border border-gray-200 shadow-inner flex-shrink-0"
                          :style="{ background: sec.stemColor }"></span>
                    <span>ธีม: <b>{{ sec.stemColor }}</b></span>
                    <span class="w-4 h-4 rounded-full border border-gray-200 flex-shrink-0"
                          :style="{ background: sec.leafColor }"></span>
                    <span>สีอ่อน: <b>{{ sec.leafColor }}</b></span>
                  </div>
                </div>

                <!-- Background style selector -->
                <div>
                  <label class="label">พื้นหลัง Section</label>
                  <div class="grid grid-cols-4 sm:grid-cols-7 gap-2">
                    <button v-for="bg in BG_STYLES" :key="bg.key" @click="sec.bgStyle = bg.key"
                            class="group p-2 rounded-xl border-2 text-center transition-all"
                            :class="sec.bgStyle === bg.key
                              ? 'border-blue-500 shadow-sm'
                              : 'border-gray-200 hover:border-gray-300'">
                      <div class="w-full h-8 rounded-lg mb-1.5 overflow-hidden border border-gray-100"
                           :style="getPreviewBgStyle(bg.key, sec.stemColor, sec.darkColor)">
                        <div v-if="bg.key === 'plaid'" class="w-full h-full"
                             style="background-image:repeating-linear-gradient(45deg,rgba(100,116,139,.18) 0,rgba(100,116,139,.18) 1px,transparent 1px,transparent 7px),repeating-linear-gradient(-45deg,rgba(100,116,139,.18) 0,rgba(100,116,139,.18) 1px,transparent 1px,transparent 7px),repeating-linear-gradient(0deg,rgba(100,116,139,.12) 0,rgba(100,116,139,.12) 1px,transparent 1px,transparent 7px),repeating-linear-gradient(90deg,rgba(100,116,139,.12) 0,rgba(100,116,139,.12) 1px,transparent 1px,transparent 7px);background-color:#f9fafb"></div>
                        <div v-else-if="bg.key === 'image'" class="w-full h-full flex items-center justify-center text-gray-400 text-lg">🖼️</div>
                      </div>
                      <div class="text-xs font-medium leading-tight"
                           :class="sec.bgStyle === bg.key ? 'text-blue-600' : 'text-gray-500'">
                        {{ bg.label }}
                      </div>
                    </button>
                  </div>

                  <!-- Dark color picker (shows when bgStyle === 'dark') -->
                  <div v-if="sec.bgStyle === 'dark'" class="mt-3">
                    <label class="label text-xs">สีพื้นหลังเข้ม</label>
                    <div class="flex flex-wrap gap-2 mb-2">
                      <button v-for="dc in DARK_PRESETS" :key="dc.color"
                              @click="sec.darkColor = dc.color"
                              class="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg border-2 text-xs font-medium transition-all"
                              :class="sec.darkColor === dc.color ? 'border-white/60 shadow-sm' : 'border-transparent hover:border-white/30'"
                              :style="{ background: dc.color, color: '#fff' }">
                        {{ dc.label }}
                      </button>
                      <!-- custom color wheel -->
                      <label class="relative flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg border-2 cursor-pointer text-xs font-medium transition-all hover:border-gray-300"
                             :class="isDarkCustomColor(sec) ? 'border-gray-500 shadow-sm' : 'border-dashed border-gray-300'"
                             :style="isDarkCustomColor(sec) ? { background: sec.darkColor, color: '#fff' } : {}">
                        <span v-if="isDarkCustomColor(sec)" class="w-3.5 h-3.5 rounded-full border border-white/50 shrink-0" :style="{ background: sec.darkColor }"></span>
                        <span v-else class="text-base leading-none">🎨</span>
                        <span>{{ isDarkCustomColor(sec) ? sec.darkColor.toUpperCase() : 'กำหนดเอง' }}</span>
                        <input type="color" :value="sec.darkColor || '#1e3a5f'"
                               @input="sec.darkColor = $event.target.value"
                               class="absolute inset-0 opacity-0 w-full h-full cursor-pointer" />
                      </label>
                    </div>
                    <!-- live preview -->
                    <div class="w-full h-10 rounded-xl overflow-hidden border border-gray-200"
                         :style="getSectionBgStyle('dark', sec.stemColor, '', 'light', sec.darkColor)">
                    </div>
                  </div>

                  <!-- Image upload panel (shows when bgStyle === 'image') -->
                  <div v-if="sec.bgStyle === 'image'" class="mt-3 space-y-3">

                    <!-- Warning -->
                    <div class="bg-amber-50 border border-amber-200 rounded-xl p-3 text-xs text-amber-700 flex items-start gap-2">
                      <span class="text-base shrink-0">⚠️</span>
                      <div class="space-y-1">
                        <p><strong>คำแนะนำการใช้ภาพพื้นหลัง:</strong></p>
                        <ul class="list-disc list-inside space-y-0.5 text-amber-600">
                          <li>ภาพแสดงแบบ <strong>cover (เต็มพื้นที่)</strong> ตรึงตาม scroll ของเพจ — ไม่ใช้ parallax เพราะใช้ไม่ได้ใน iOS</li>
                          <li>แนะนำภาพแนวนอน <strong>อัตราส่วน 3:1 หรือ 16:9</strong> ขนาดไม่เกิน <strong>500 KB</strong></li>
                          <li>การมีภาพพื้นหลัง <strong>หลายบล็อกพร้อมกัน</strong> อาจทำให้เว็บโหลดช้าลงและใช้พื้นที่จัดเก็บมากขึ้น</li>
                          <li>เมื่อเปลี่ยน/ลบภาพ ระบบจะ<strong>ลบไฟล์เก่าจาก Supabase Storage อัตโนมัติ</strong></li>
                        </ul>
                      </div>
                    </div>

                    <!-- Upload + current preview -->
                    <div class="flex items-start gap-3">
                      <div class="shrink-0">
                        <ImageUploadCrop
                          v-model="sec.bgImage"
                          bucket="school"
                          :storage-path="`section-bg/${sec.id}/bg.jpg`"
                          :aspect-ratio="3"
                          :output-width="1200"
                          :quality="0.82"
                          placeholder="อัปโหลด"
                          hint="3:1 | ≤500KB"
                          container-class="w-28 h-10 rounded-xl"
                          icon="🖼️"
                        />
                      </div>
                      <div v-if="sec.bgImage" class="flex-1 relative min-w-0">
                        <img :src="sec.bgImage" class="w-full h-14 object-cover rounded-xl border border-gray-200" />
                        <button @click="deleteBgImage(sec)" title="ลบภาพพื้นหลัง"
                                class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full text-sm flex items-center justify-center hover:bg-red-600 shadow-md transition-colors">×</button>
                      </div>
                      <div v-else class="flex-1 flex items-center justify-center h-14 border-2 border-dashed border-gray-200 rounded-xl text-xs text-gray-400">
                        ยังไม่มีภาพ
                      </div>
                    </div>

                    <!-- Overlay selector -->
                    <div>
                      <label class="label text-xs">แสงซ้อนทับ (ช่วยให้อ่านข้อความได้ชัดขึ้น)</label>
                      <div class="flex gap-2 flex-wrap">
                        <button @click="sec.bgOverlay = 'none'"
                                class="px-3 py-1.5 rounded-lg text-xs border-2 transition-all"
                                :class="sec.bgOverlay === 'none' ? 'border-blue-500 bg-blue-50 text-blue-600' : 'border-gray-200 text-gray-500 hover:border-gray-300'">
                          ⬜ ไม่มี
                        </button>
                        <button @click="sec.bgOverlay = 'light'"
                                class="px-3 py-1.5 rounded-lg text-xs border-2 transition-all"
                                :class="sec.bgOverlay === 'light' ? 'border-blue-500 bg-blue-50 text-blue-600' : 'border-gray-200 text-gray-500 hover:border-gray-300'">
                          ☀️ ขาว 32% (แนะนำ)
                        </button>
                        <button @click="sec.bgOverlay = 'dark'"
                                class="px-3 py-1.5 rounded-lg text-xs border-2 transition-all"
                                :class="sec.bgOverlay === 'dark' ? 'border-blue-500 bg-blue-50 text-blue-600' : 'border-gray-200 text-gray-500 hover:border-gray-300'">
                          🌙 ดำ 42%
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-blue-50 rounded-xl p-4 text-sm text-blue-700 border border-blue-100 flex items-start gap-3">
          <span class="text-lg shrink-0">💡</span>
          <span>การเปลี่ยนแปลงจะมีผลทันทีหลังกด <strong>บันทึกทั้งหมด</strong> — ลำดับและการตั้งค่าที่กำหนดที่นี่จะแสดงบนหน้าแรกของเว็บไซต์</span>
        </div>
      </div>

      <!-- ─── Tab: Widget หน้าแรก ─── -->
      <div v-if="activeTab === 'widgets'" class="space-y-4">
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-1 flex items-center gap-2 text-base">🧩 Widget หน้าแรก</h3>
          <p class="text-xs text-gray-500 mb-6">กำหนดชื่อและการแสดงผล Widget ข้อมูลนักเรียนและปฏิทินในหน้าแรก</p>

          <!-- Order reference -->
          <div class="bg-amber-50 border border-amber-200 rounded-xl p-4 mb-2">
            <p class="text-xs font-semibold text-amber-700 mb-2">📌 ลำดับ Section ปัจจุบัน (อ้างอิง)</p>
            <div class="flex flex-wrap gap-2">
              <template v-for="sec in (form.homepage_sections || []).filter(s => s.visible !== false).sort((a,b)=>a.order-b.order)" :key="sec.id">
                <span class="inline-flex items-center gap-1 bg-white border border-amber-200 rounded-lg px-2 py-1 text-xs text-amber-800">
                  <span class="font-bold">{{ sec.order }}</span>
                  <span class="text-amber-400">·</span>
                  <span>{{ sec.icon }}</span>
                  <span>{{ sec.title }}</span>
                </span>
              </template>
            </div>
            <p class="text-xs text-amber-600 mt-2">กำหนดลำดับ Widget ให้ไม่ซ้ำกับ Section — ทศนิยมได้ เช่น 2.5 จะแทรกระหว่างลำดับ 2 กับ 3</p>
          </div>

          <div class="space-y-5">
            <!-- Student Stats Widget -->
            <div class="border border-gray-200 rounded-2xl overflow-hidden">
              <div class="flex items-center justify-between px-5 py-4 bg-blue-50 border-b border-blue-100">
                <div class="flex items-center gap-3">
                  <span class="text-2xl">🎓</span>
                  <div>
                    <p class="font-semibold text-gray-800 text-sm">Widget ข้อมูลนักเรียน</p>
                    <p class="text-xs text-gray-500">แสดงสถิตินักเรียนในหน้าแรก</p>
                  </div>
                </div>
                <button @click="form.homepage_widgets.student_stats.enabled = !form.homepage_widgets.student_stats.enabled"
                  :class="['relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none',
                    form.homepage_widgets.student_stats.enabled ? 'bg-blue-600' : 'bg-gray-300']">
                  <span :class="['inline-block w-4 h-4 rounded-full bg-white shadow-sm transition-transform',
                    form.homepage_widgets.student_stats.enabled ? 'translate-x-6' : 'translate-x-1']"></span>
                </button>
              </div>
              <div class="p-4" :class="form.homepage_widgets.student_stats.enabled ? '' : 'opacity-50 pointer-events-none'">
                <div class="grid grid-cols-1 sm:grid-cols-5 gap-4">

                  <!-- Controls -->
                  <div class="sm:col-span-3 space-y-3">
                    <div class="grid grid-cols-3 gap-2">
                      <div class="col-span-2">
                        <label class="label">ชื่อหัวข้อ</label>
                        <input v-model="form.homepage_widgets.student_stats.title" type="text" class="input-field"
                          placeholder="ข้อมูลนักเรียน" />
                      </div>
                      <div>
                        <label class="label">ลำดับ</label>
                        <input v-model.number="form.homepage_widgets.student_stats.order" type="number"
                          step="0.5" min="0.5" max="20" class="input-field text-center font-mono" />
                      </div>
                    </div>
                    <div>
                      <label class="label">คำอธิบาย <span class="text-gray-400 font-normal text-xs">(เว้นว่าง = แสดงวันที่ข้อมูล)</span></label>
                      <input v-model="form.homepage_widgets.student_stats.subtitle" type="text" class="input-field"
                        placeholder="สถิตินักเรียนปีการศึกษาล่าสุด" />
                    </div>
                    <!-- Variant -->
                    <div>
                      <label class="label">สไตล์เส้น</label>
                      <div class="grid grid-cols-5 gap-1.5">
                        <button v-for="v in VARIANTS" :key="v.key"
                          @click="form.homepage_widgets.student_stats.variant = v.key"
                          :title="v.label"
                          class="py-1.5 rounded-lg border-2 text-center transition-all"
                          :class="form.homepage_widgets.student_stats.variant === v.key
                            ? 'border-blue-500 bg-blue-50' : 'border-gray-200 hover:border-gray-300 bg-white'">
                          <div class="text-lg leading-none">{{ v.icon }}</div>
                          <div class="text-[10px] mt-0.5"
                            :class="form.homepage_widgets.student_stats.variant === v.key ? 'text-blue-600 font-semibold' : 'text-gray-400'">{{ v.label }}</div>
                        </button>
                      </div>
                    </div>
                    <!-- Colors -->
                    <div>
                      <label class="label">สีธีม</label>
                      <div class="flex flex-wrap gap-1.5 items-center">
                        <button v-for="c in COLOR_PRESETS" :key="c.stem"
                          @click="applyPresetColor(form.homepage_widgets.student_stats, c)"
                          :title="c.label"
                          class="w-6 h-6 rounded-full border-2 transition-all hover:scale-110 flex-shrink-0"
                          :class="form.homepage_widgets.student_stats.stemColor === c.stem
                            ? 'border-gray-700 scale-110 shadow-md' : 'border-white hover:border-gray-300 shadow-sm'"
                          :style="{ background: c.stem }">
                        </button>
                        <div class="w-px h-5 bg-gray-200 mx-0.5 flex-shrink-0"></div>
                        <label :title="'กำหนดเอง'" class="relative w-6 h-6 rounded-full border-2 cursor-pointer flex-shrink-0 flex items-center justify-center transition-all hover:scale-110"
                          :class="isCustomColor(form.homepage_widgets.student_stats) ? 'border-gray-700 scale-110 shadow-md' : 'border-dashed border-gray-400'"
                          :style="isCustomColor(form.homepage_widgets.student_stats) ? { background: form.homepage_widgets.student_stats.stemColor } : {}">
                          <span v-if="!isCustomColor(form.homepage_widgets.student_stats)" class="text-xs text-gray-400">+</span>
                          <input type="color" :value="form.homepage_widgets.student_stats.stemColor"
                            @input="applyCustomColor(form.homepage_widgets.student_stats, $event.target.value)"
                            class="absolute inset-0 opacity-0 w-full h-full cursor-pointer rounded-full" />
                        </label>
                      </div>
                    </div>
                  </div>

                  <!-- Preview -->
                  <div class="sm:col-span-2 bg-gray-50 rounded-xl p-3 border border-gray-100 flex flex-col justify-center min-h-[120px]">
                    <p class="text-[10px] text-gray-400 mb-2 font-medium text-center uppercase tracking-wide">ตัวอย่าง</p>
                    <VineDivider
                      :variant="form.homepage_widgets.student_stats.variant"
                      :stem-color="form.homepage_widgets.student_stats.stemColor"
                      :leaf-color="form.homepage_widgets.student_stats.leafColor"
                      class="mb-1.5">
                      <span class="text-sm">🎓</span>
                      <span class="w-px h-4 mx-0.5" :style="{ background: form.homepage_widgets.student_stats.stemColor + '99' }"></span>
                      <span class="text-xs font-extrabold tracking-wide text-gray-800">{{ form.homepage_widgets.student_stats.title || 'ข้อมูลนักเรียน' }}</span>
                    </VineDivider>
                    <p class="text-gray-400 text-[10px] text-center">{{ form.homepage_widgets.student_stats.subtitle || 'สถิตินักเรียนปีการศึกษาล่าสุด' }}</p>
                  </div>

                </div>
              </div>
            </div>

            <!-- Calendar Widget -->
            <div class="border border-gray-200 rounded-2xl overflow-hidden">
              <div class="flex items-center justify-between px-5 py-4 bg-indigo-50 border-b border-indigo-100">
                <div class="flex items-center gap-3">
                  <span class="text-2xl">📅</span>
                  <div>
                    <p class="font-semibold text-gray-800 text-sm">Widget ปฏิทินวิชาการ</p>
                    <p class="text-xs text-gray-500">แสดงปฏิทินกิจกรรมในหน้าแรก</p>
                  </div>
                </div>
                <button @click="form.homepage_widgets.calendar.enabled = !form.homepage_widgets.calendar.enabled"
                  :class="['relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none',
                    form.homepage_widgets.calendar.enabled ? 'bg-indigo-600' : 'bg-gray-300']">
                  <span :class="['inline-block w-4 h-4 rounded-full bg-white shadow-sm transition-transform',
                    form.homepage_widgets.calendar.enabled ? 'translate-x-6' : 'translate-x-1']"></span>
                </button>
              </div>
              <div class="p-4" :class="form.homepage_widgets.calendar.enabled ? '' : 'opacity-50 pointer-events-none'">
                <div class="grid grid-cols-1 sm:grid-cols-5 gap-4">

                  <!-- Controls -->
                  <div class="sm:col-span-3 space-y-3">
                    <div class="grid grid-cols-3 gap-2">
                      <div class="col-span-2">
                        <label class="label">ชื่อหัวข้อ</label>
                        <input v-model="form.homepage_widgets.calendar.title" type="text" class="input-field"
                          placeholder="ปฏิทินวิชาการ" />
                      </div>
                      <div>
                        <label class="label">ลำดับ</label>
                        <input v-model.number="form.homepage_widgets.calendar.order" type="number"
                          step="0.5" min="0.5" max="20" class="input-field text-center font-mono" />
                      </div>
                    </div>
                    <div>
                      <label class="label">คำอธิบาย</label>
                      <input v-model="form.homepage_widgets.calendar.subtitle" type="text" class="input-field"
                        placeholder="กิจกรรมและกำหนดการสำคัญของโรงเรียน" />
                    </div>
                    <!-- Variant -->
                    <div>
                      <label class="label">สไตล์เส้น</label>
                      <div class="grid grid-cols-5 gap-1.5">
                        <button v-for="v in VARIANTS" :key="v.key"
                          @click="form.homepage_widgets.calendar.variant = v.key"
                          :title="v.label"
                          class="py-1.5 rounded-lg border-2 text-center transition-all"
                          :class="form.homepage_widgets.calendar.variant === v.key
                            ? 'border-indigo-500 bg-indigo-50' : 'border-gray-200 hover:border-gray-300 bg-white'">
                          <div class="text-lg leading-none">{{ v.icon }}</div>
                          <div class="text-[10px] mt-0.5"
                            :class="form.homepage_widgets.calendar.variant === v.key ? 'text-indigo-600 font-semibold' : 'text-gray-400'">{{ v.label }}</div>
                        </button>
                      </div>
                    </div>
                    <!-- Colors -->
                    <div>
                      <label class="label">สีธีม</label>
                      <div class="flex flex-wrap gap-1.5 items-center">
                        <button v-for="c in COLOR_PRESETS" :key="c.stem"
                          @click="applyPresetColor(form.homepage_widgets.calendar, c)"
                          :title="c.label"
                          class="w-6 h-6 rounded-full border-2 transition-all hover:scale-110 flex-shrink-0"
                          :class="form.homepage_widgets.calendar.stemColor === c.stem
                            ? 'border-gray-700 scale-110 shadow-md' : 'border-white hover:border-gray-300 shadow-sm'"
                          :style="{ background: c.stem }">
                        </button>
                        <div class="w-px h-5 bg-gray-200 mx-0.5 flex-shrink-0"></div>
                        <label :title="'กำหนดเอง'" class="relative w-6 h-6 rounded-full border-2 cursor-pointer flex-shrink-0 flex items-center justify-center transition-all hover:scale-110"
                          :class="isCustomColor(form.homepage_widgets.calendar) ? 'border-gray-700 scale-110 shadow-md' : 'border-dashed border-gray-400'"
                          :style="isCustomColor(form.homepage_widgets.calendar) ? { background: form.homepage_widgets.calendar.stemColor } : {}">
                          <span v-if="!isCustomColor(form.homepage_widgets.calendar)" class="text-xs text-gray-400">+</span>
                          <input type="color" :value="form.homepage_widgets.calendar.stemColor"
                            @input="applyCustomColor(form.homepage_widgets.calendar, $event.target.value)"
                            class="absolute inset-0 opacity-0 w-full h-full cursor-pointer rounded-full" />
                        </label>
                      </div>
                    </div>
                  </div>

                  <!-- Preview -->
                  <div class="sm:col-span-2 bg-gray-50 rounded-xl p-3 border border-gray-100 flex flex-col justify-center min-h-[120px]">
                    <p class="text-[10px] text-gray-400 mb-2 font-medium text-center uppercase tracking-wide">ตัวอย่าง</p>
                    <VineDivider
                      :variant="form.homepage_widgets.calendar.variant"
                      :stem-color="form.homepage_widgets.calendar.stemColor"
                      :leaf-color="form.homepage_widgets.calendar.leafColor"
                      class="mb-1.5">
                      <span class="text-sm">📅</span>
                      <span class="w-px h-4 mx-0.5" :style="{ background: form.homepage_widgets.calendar.stemColor + '99' }"></span>
                      <span class="text-xs font-extrabold tracking-wide text-gray-800">{{ form.homepage_widgets.calendar.title || 'ปฏิทินวิชาการ' }}</span>
                    </VineDivider>
                    <p class="text-gray-400 text-[10px] text-center">{{ form.homepage_widgets.calendar.subtitle || 'กิจกรรมและกำหนดการสำคัญของโรงเรียน' }}</p>
                  </div>

                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ─── Tab: Footer ─── -->
      <!-- ═══ NAVBAR TAB ═══ -->
      <div v-if="activeTab === 'navbar'" class="space-y-4">

        <!-- แถบบนสุด (Top Bar) -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center justify-between mb-1">
            <h3 class="font-bold text-gray-900 flex items-center gap-2 text-base">🔝 แถบข้อความบนสุด</h3>
            <label class="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" v-model="form.topbar_enabled" class="sr-only peer" />
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:bg-blue-500 transition-colors after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:after:translate-x-5"></div>
              <span class="ml-2 text-sm font-medium" :class="form.topbar_enabled ? 'text-blue-600' : 'text-gray-400'">
                {{ form.topbar_enabled ? 'แสดง' : 'ซ่อน' }}
              </span>
            </label>
          </div>
          <p class="text-xs text-gray-400 mb-5">แถบสีเข้มบนสุดของทุกหน้า — แสดงข้อความสังกัดหรือข้อความที่ต้องการ</p>

          <div :class="{ 'opacity-40 pointer-events-none': !form.topbar_enabled }">
            <label class="label">ข้อความที่แสดง</label>
            <input v-model="form.topbar_text" type="text" class="input-field"
              :placeholder="form.affiliation || 'สำนักงานคณะกรรมการการศึกษาขั้นพื้นฐาน'" />
            <p class="text-xs text-gray-400 mt-1">ถ้าไม่กรอกจะใช้ชื่อสังกัดจากข้อมูลพื้นฐาน</p>

            <!-- Preview -->
            <div class="mt-4 rounded-xl overflow-hidden border border-gray-200">
              <div class="bg-blue-900 text-white text-xs py-1.5 px-4 flex justify-between items-center">
                <span>{{ form.topbar_text || form.affiliation || 'สำนักงานคณะกรรมการการศึกษาขั้นพื้นฐาน' }}</span>
                <div class="flex gap-4 opacity-70">
                  <span>Facebook</span>
                  <span>เข้าสู่ระบบ</span>
                </div>
              </div>
              <div class="bg-gray-50 text-center text-xs text-gray-400 py-2">ตัวอย่าง</div>
            </div>
          </div>
        </div>

      </div>

      <!-- ═══ PERSONNEL TAB ═══ -->
      <div v-if="activeTab === 'personnel'" class="space-y-4">
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 flex items-center gap-2 text-base mb-1">👥 กลุ่มบริหารงาน</h3>
          <p class="text-xs text-gray-400 mb-5">กำหนดชื่อกลุ่มบริหารของโรงเรียน — แสดงในหน้าบุคลากรสาธารณะ</p>
          <div class="space-y-2 mb-4">
            <div v-for="(dept, idx) in form.admin_departments" :key="idx" class="flex items-center gap-2">
              <span class="text-gray-400 text-sm w-5 text-right flex-shrink-0">{{ idx + 1 }}.</span>
              <input v-model="form.admin_departments[idx]" type="text" class="input-field flex-1"
                :placeholder="`ชื่อกลุ่มที่ ${idx + 1}`" />
              <button @click="form.admin_departments.splice(idx, 1)"
                class="p-2 rounded-lg text-gray-300 hover:text-red-500 hover:bg-red-50 transition-colors flex-shrink-0">✕</button>
            </div>
          </div>
          <button @click="form.admin_departments.push('')"
            class="flex items-center gap-2 text-sm text-blue-600 hover:text-blue-700 font-medium">
            <span class="text-lg leading-none">+</span> เพิ่มกลุ่ม
          </button>
        </div>
      </div>

      <!-- ═══ FOOTER TAB ═══ -->
      <div v-if="activeTab === 'footer'" class="space-y-4">

        <!-- ป้ายประกาศด่วน -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center justify-between mb-1">
            <h3 class="font-bold text-gray-900 flex items-center gap-2 text-base">📢 ป้ายประกาศด่วน</h3>
            <!-- Master toggle -->
            <label class="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" v-model="form.announcement_enabled" class="sr-only peer" />
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:bg-blue-500 transition-colors after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:after:translate-x-5"></div>
              <span class="ml-2 text-sm font-medium" :class="form.announcement_enabled ? 'text-blue-600' : 'text-gray-400'">
                {{ form.announcement_enabled ? 'เปิดใช้งาน' : 'ปิดอยู่' }}
              </span>
            </label>
          </div>
          <p class="text-xs text-gray-400 mb-5">แถบข้อความแสดงใต้ navbar ทุกหน้า — ใช้แจ้งข่าวสำคัญหรือกำหนดการเร่งด่วน</p>

          <div class="space-y-4" :class="{ 'opacity-40 pointer-events-none': !form.announcement_enabled }">
            <!-- ข้อความ -->
            <div>
              <label class="label">ข้อความประกาศ</label>
              <input v-model="form.announcement_text" type="text" class="input-field"
                placeholder="เช่น ปิดภาคเรียนที่ 1 วันที่ 1–30 ตุลาคม 2568 โรงเรียนจะเปิดทำการ 1 พฤศจิกายน 2568" />
            </div>

            <!-- ประเภท + ลิงก์ -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label class="label">ประเภท / สี</label>
                <div class="flex gap-2 flex-wrap">
                  <button v-for="t in ANNOUNCEMENT_TYPES" :key="t.key"
                    @click="form.announcement_type = t.key"
                    :class="['flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold border-2 transition-all',
                      form.announcement_type === t.key ? t.activeCls : 'border-gray-200 text-gray-500 hover:border-gray-300']">
                    <span>{{ t.icon }}</span>{{ t.label }}
                  </button>
                </div>
              </div>
              <div>
                <label class="label">ลิงก์ (ไม่บังคับ)</label>
                <input v-model="form.announcement_link" type="url" class="input-field text-xs font-mono"
                  placeholder="https://..." />
                <p class="text-xs text-gray-400 mt-1">ถ้ามีลิงก์จะแสดงปุ่ม "อ่านเพิ่มเติม"</p>
              </div>
            </div>

            <!-- ความเร็ว -->
            <div>
              <label class="label">ความเร็วในการวิ่ง</label>
              <div class="flex gap-2 flex-wrap">
                <button v-for="sp in SPEED_PRESETS" :key="sp.value"
                  @click="form.announcement_speed = sp.value"
                  :class="['px-4 py-2 rounded-xl text-xs font-semibold border-2 transition-all',
                    form.announcement_speed === sp.value
                      ? 'border-blue-500 bg-blue-600 text-white'
                      : 'border-gray-200 text-gray-600 hover:border-gray-300']">
                  {{ sp.label }}
                </button>
              </div>
              <p class="text-xs text-gray-400 mt-2">ปัจจุบัน: {{ form.announcement_speed }} วินาทีต่อรอบ</p>
            </div>

            <!-- Preview -->
            <div>
              <label class="label">ตัวอย่าง</label>
              <div :class="['rounded-xl py-2 px-4 flex items-center gap-3 text-sm font-medium', previewBg]">
                <span>{{ previewIcon }}</span>
                <span :class="previewText" class="flex-1 truncate">
                  {{ form.announcement_text || 'ข้อความประกาศของคุณจะแสดงที่นี่...' }}
                </span>
                <span v-if="form.announcement_link" :class="['text-xs font-bold underline', previewText]">อ่านเพิ่มเติม →</span>
                <span :class="['opacity-60 text-xs', previewText]">✕</span>
              </div>
            </div>
          </div>
        </div>

        <!-- ลิงก์ด่วน -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-900 mb-1 flex items-center gap-2 text-base">🔗 ลิงก์ด่วน</h3>
          <p class="text-xs text-gray-400 mb-5">เลือกลิงก์ที่ต้องการแสดงใน Footer — ลำดับคงที่ตามระบบ</p>
          <div class="space-y-2">
            <div v-for="(link, idx) in form.footer_quick_links" :key="link.to"
              class="flex items-center gap-3 p-3 rounded-xl border border-gray-100 hover:bg-gray-50">
              <label class="relative inline-flex items-center cursor-pointer">
                <input type="checkbox" v-model="link.visible" class="sr-only peer" />
                <div class="w-10 h-5 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:bg-blue-500 transition-colors after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:after:translate-x-5"></div>
              </label>
              <span class="text-sm font-medium text-gray-800 flex-1">{{ link.label }}</span>
              <span class="text-xs text-gray-400 font-mono bg-gray-100 px-2 py-0.5 rounded">{{ link.to }}</span>
            </div>
          </div>
        </div>

        <!-- หน่วยงานที่เกี่ยวข้อง -->
        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center justify-between mb-1">
            <h3 class="font-bold text-gray-900 flex items-center gap-2 text-base">🏛️ หน่วยงานที่เกี่ยวข้อง</h3>
            <button @click="addAgency"
              class="flex items-center gap-1.5 text-xs font-semibold text-blue-600 hover:text-blue-700 bg-blue-50 hover:bg-blue-100 px-3 py-1.5 rounded-lg transition-colors">
              + เพิ่มหน่วยงาน
            </button>
          </div>
          <p class="text-xs text-gray-400 mb-5">รายการลิงก์ภายนอกที่แสดงใน Footer — ลากเพื่อเรียงลำดับ หรือกด × เพื่อลบ</p>

          <div class="space-y-2">
            <div v-for="(ag, idx) in form.footer_agencies" :key="idx"
              class="flex items-center gap-2 p-3 rounded-xl border border-gray-100 bg-gray-50/50 group">
              <!-- drag handle -->
              <div class="flex flex-col gap-0.5 text-gray-300 group-hover:text-gray-400 cursor-grab select-none flex-shrink-0">
                <span class="block w-4 h-0.5 bg-current rounded"></span>
                <span class="block w-4 h-0.5 bg-current rounded"></span>
                <span class="block w-4 h-0.5 bg-current rounded"></span>
              </div>
              <!-- inputs -->
              <input v-model="ag.label" type="text" placeholder="ชื่อหน่วยงาน เช่น สพฐ."
                class="input-field text-sm flex-1 min-w-0" />
              <input v-model="ag.url" type="url" placeholder="https://..."
                class="input-field text-sm flex-1 min-w-0 font-mono text-xs" />
              <!-- move buttons -->
              <div class="flex flex-col gap-0.5">
                <button @click="moveAgency(idx, -1)" :disabled="idx === 0"
                  class="w-6 h-5 flex items-center justify-center text-gray-400 hover:text-gray-600 disabled:opacity-20 disabled:cursor-not-allowed text-xs">▲</button>
                <button @click="moveAgency(idx, 1)" :disabled="idx === form.footer_agencies.length - 1"
                  class="w-6 h-5 flex items-center justify-center text-gray-400 hover:text-gray-600 disabled:opacity-20 disabled:cursor-not-allowed text-xs">▼</button>
              </div>
              <!-- delete -->
              <button @click="removeAgency(idx)"
                class="w-7 h-7 flex items-center justify-center rounded-lg text-gray-300 hover:text-red-500 hover:bg-red-50 transition-colors flex-shrink-0">
                ×
              </button>
            </div>
            <div v-if="!form.footer_agencies?.length"
              class="text-center py-8 text-gray-300 text-sm border-2 border-dashed border-gray-100 rounded-xl">
              ยังไม่มีหน่วยงาน — กด "เพิ่มหน่วยงาน" เพื่อเริ่ม
            </div>
          </div>
        </div>
      </div>

      <!-- Save Button -->
      <div class="flex justify-end gap-3 pb-6">
        <button @click="loadConfig" class="btn-secondary">↩️ ยกเลิก</button>
        <button @click="handleSave" :disabled="saving"
          class="btn-primary flex items-center gap-2 min-w-32 justify-center">
          <svg v-if="saving" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
          </svg>
          {{ saving ? 'กำลังบันทึก...' : '💾 บันทึกทั้งหมด' }}
        </button>
      </div>

      <!-- Toast กลางจอ -->
      <Teleport to="body">
        <Transition name="toast">
          <div v-if="saveMsg.text"
            class="fixed inset-0 flex items-center justify-center z-[9999] pointer-events-none">
            <div :class="['pointer-events-auto flex items-center gap-3 px-6 py-4 rounded-2xl shadow-2xl text-sm font-medium max-w-sm w-full mx-4',
              saveMsg.type === 'success'
                ? 'bg-white border border-green-200 text-green-700'
                : 'bg-white border border-red-200 text-red-700']">
              <span class="text-xl">{{ saveMsg.type === 'success' ? '✅' : '❌' }}</span>
              <span>{{ saveMsg.text }}</span>
            </div>
          </div>
        </Transition>
      </Teleport>
    </div>
  </AdminLayout>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import AdminLayout from '../../layouts/AdminLayout.vue'
import ImageUploadCrop from '../../components/admin/ImageUploadCrop.vue'
import VineDivider from '../../components/public/VineDivider.vue'
import { useSchoolConfig } from '../../composables/useSchoolConfig'
import { supabase, SUPABASE_URL } from '../../lib/supabase'
import { getSectionBgStyle } from '../../utils/sectionBg.js'

const { config, updateConfig } = useSchoolConfig()

const activeTab = ref('basic')
const saving = ref(false)
const saveMsg = ref({ text: '', type: '' })
const form = ref({})
const banners = ref([])
const deputies = ref([])
const expandedSec = ref(null)

const SECTION_LABELS = { news: 'ข่าว', systems: 'ระบบงาน', activity: 'กิจกรรม', media: 'คลังสื่อ' }

const VARIANTS = [
  { key: 'circuit', icon: '⊙', label: 'Circuit' },
  { key: 'wave',    icon: '〜', label: 'Wave'    },
  { key: 'diamond', icon: '◆', label: 'Diamond' },
  { key: 'minimal', icon: '⋯', label: 'Minimal' },
  { key: 'chevron', icon: '›',  label: 'Chevron' },
]

const COLOR_PRESETS = [
  { label: 'น้ำเงิน',  stem: '#3b82f6', leaf: '#93c5fd' },
  { label: 'ฟ้า',      stem: '#0ea5e9', leaf: '#7dd3fc' },
  { label: 'คราม',     stem: '#6366f1', leaf: '#a5b4fc' },
  { label: 'กรมท่า',   stem: '#1d4ed8', leaf: '#93c5fd' },
  { label: 'ม่วง',     stem: '#a855f7', leaf: '#d8b4fe' },
  { label: 'ม่วงเข้ม', stem: '#7c3aed', leaf: '#c4b5fd' },
  { label: 'ชมพู',     stem: '#ec4899', leaf: '#f9a8d4' },
  { label: 'กุหลาบ',   stem: '#f43f5e', leaf: '#fda4af' },
  { label: 'แดง',      stem: '#ef4444', leaf: '#fca5a5' },
  { label: 'ส้มแดง',   stem: '#f97316', leaf: '#fdba74' },
  { label: 'ส้ม',      stem: '#fb923c', leaf: '#fed7aa' },
  { label: 'เหลือง',   stem: '#f59e0b', leaf: '#fde68a' },
  { label: 'ทอง',      stem: '#d97706', leaf: '#fcd34d' },
  { label: 'เขียวมะนาว',stem:'#84cc16', leaf: '#d9f99d' },
  { label: 'เขียว',    stem: '#22c55e', leaf: '#86efac' },
  { label: 'เขียวเข้ม',stem: '#16a34a', leaf: '#86efac' },
  { label: 'มรกต',     stem: '#10b981', leaf: '#6ee7b7' },
  { label: 'ฟ้าเขียว', stem: '#14b8a6', leaf: '#5eead4' },
  { label: 'เทา',      stem: '#64748b', leaf: '#cbd5e1' },
  { label: 'น้ำตาล',   stem: '#92400e', leaf: '#fcd34d' },
]

// คำนวณ leafColor (สีอ่อน) จาก stemColor อัตโนมัติ (ผสมกับสีขาว 55%)
function lightenColor(hex, amount = 0.55) {
  const r = parseInt(hex.slice(1, 3), 16)
  const g = parseInt(hex.slice(3, 5), 16)
  const b = parseInt(hex.slice(5, 7), 16)
  const mix = c => Math.round(c + (255 - c) * amount)
  return '#' + [mix(r), mix(g), mix(b)].map(v => v.toString(16).padStart(2, '0')).join('')
}

// เลือก preset color
function applyPresetColor(sec, preset) {
  sec.stemColor = preset.stem
  sec.leafColor = preset.leaf
}

// เลือกสีจาก color picker — คำนวณ leafColor อัตโนมัติ
function applyCustomColor(sec, hex) {
  sec.stemColor = hex
  sec.leafColor = lightenColor(hex)
}

// ตรวจว่าสีปัจจุบันเป็นสีกำหนดเองหรือไม่ (ไม่อยู่ใน preset)
function isCustomColor(sec) {
  return !COLOR_PRESETS.some(c => c.stem === sec.stemColor)
}

const DARK_PRESETS = [
  { label: 'กรมท่า',    color: '#1e3a5f' },
  { label: 'น้ำเงิน',   color: '#1e3269' },
  { label: 'ม่วงเข้ม',  color: '#312e81' },
  { label: 'เขียวเข้ม', color: '#14532d' },
  { label: 'แดงเข้ม',   color: '#7f1d1d' },
  { label: 'เทาเข้ม',   color: '#1e293b' },
  { label: 'ดำ',        color: '#0f172a' },
]

function isDarkCustomColor(sec) {
  return !DARK_PRESETS.some(d => d.color === (sec.darkColor || '#1e3a5f'))
}

const BG_STYLES = [
  { key: 'white',  label: 'ขาว'   },
  { key: 'gray',   label: 'เทา'   },
  { key: 'plaid',  label: 'สก็อต' },
  { key: 'corner', label: 'ขอบมุม'},
  { key: 'edge',   label: '4 ทิศ' },
  { key: 'dark',   label: 'เข้ม'  },
  { key: 'image',  label: 'ภาพ'   },
]

function getPreviewBgStyle(bgKey, stemColor, darkColor = '#1e3a5f') {
  if (bgKey === 'image') return { background: 'linear-gradient(135deg,#e2e8f0,#cbd5e1)' }
  return getSectionBgStyle(bgKey, stemColor, '', 'light', darkColor)
}

async function deleteBgImage(sec) {
  if (!sec.bgImage) return
  try {
    const match = sec.bgImage.match(/\/object\/public\/([^/]+)\/(.+?)(\?.*)?$/)
    if (match) {
      const bucket = match[1]
      const path = decodeURIComponent(match[2])
      await supabase.storage.from(bucket).remove([path])
    }
  } catch (e) {
    console.warn('delete bg image:', e)
  }
  sec.bgImage = ''
  sec.bgOverlay = 'light'
}

const DEFAULT_SECTIONS = [
  { id: 'news',     order: 1, visible: true, title: 'ข่าวประชาสัมพันธ์',  subtitle: 'ข่าวสารและประกาศจากโรงเรียน',                      icon: '📰', variant: 'circuit', stemColor: '#3b82f6', leafColor: '#93c5fd', bgStyle: 'white',  bgImage: '', bgOverlay: 'light', darkColor: '#1e3a5f' },
  { id: 'systems',  order: 2, visible: true, title: 'ระบบงานโรงเรียน',    subtitle: 'เข้าถึงระบบงานต่างๆ ของโรงเรียน',                  icon: '🏫', variant: 'chevron', stemColor: '#fbbf24', leafColor: '#fde68a', bgStyle: 'dark',   bgImage: '', bgOverlay: 'light', darkColor: '#1e3a5f' },
  { id: 'activity', order: 3, visible: true, title: 'ภาพกิจกรรม',          subtitle: 'บรรยากาศกิจกรรมและความทรงจำของโรงเรียน',           icon: '🖼️', variant: 'diamond', stemColor: '#f97316', leafColor: '#fdba74', bgStyle: 'gray',   bgImage: '', bgOverlay: 'light', darkColor: '#1e3a5f' },
  { id: 'media',    order: 4, visible: true, title: 'คลังสื่อการเรียนรู้', subtitle: 'วิดีโอ สื่อนำเสนอ เอกสาร และแหล่งเรียนรู้ออนไลน์', icon: '📚', variant: 'wave',    stemColor: '#6366f1', leafColor: '#a5b4fc', bgStyle: 'white',  bgImage: '', bgOverlay: 'light', darkColor: '#1e3a5f' },
]

const tabs = [
  { key: 'basic',    icon: '📋', label: 'ข้อมูลพื้นฐาน' },
  { key: 'location', icon: '📍', label: 'ที่ตั้ง & ติดต่อ' },
  { key: 'director', icon: '👤', label: 'ผู้บริหาร' },
  { key: 'media',    icon: '🖼️', label: 'โลโก้ & แบนเนอร์' },
  { key: 'theme',    icon: '🎨', label: 'ธีมสี' },
  { key: 'preview',  icon: '👁️', label: 'ตัวอย่าง' },
  { key: 'sections', icon: '🏠', label: 'Section หน้าแรก' },
  { key: 'widgets',  icon: '🧩', label: 'Widget หน้าแรก' },
  { key: 'navbar',    icon: '🔝', label: 'Navbar' },
  { key: 'personnel', icon: '👥', label: 'บุคลากร' },
  { key: 'footer',    icon: '🔗', label: 'Footer' },
]

const SPEED_PRESETS = [
  { label: '🐢 ช้า',       value: 30 },
  { label: '🚶 ปานกลาง',  value: 18 },
  { label: '🏃 เร็ว',      value: 10 },
  { label: '⚡ เร็วมาก',  value: 6  },
]

const ANNOUNCEMENT_TYPES = [
  { key: 'info',    label: 'ข้อมูล',   icon: '📢', activeCls: 'border-blue-500 bg-blue-600 text-white'   },
  { key: 'warning', label: 'เตือน',    icon: '⚠️', activeCls: 'border-amber-400 bg-amber-400 text-amber-900' },
  { key: 'success', label: 'สำเร็จ',  icon: '✅', activeCls: 'border-green-500 bg-green-600 text-white'  },
  { key: 'danger',  label: 'ด่วน',    icon: '🚨', activeCls: 'border-red-500 bg-red-600 text-white'      },
]

const PREVIEW_BG   = { info: 'bg-blue-600', warning: 'bg-amber-400', success: 'bg-green-600', danger: 'bg-red-600' }
const PREVIEW_TEXT = { info: 'text-white',  warning: 'text-amber-900', success: 'text-white', danger: 'text-white' }
const PREVIEW_ICON = { info: '📢', warning: '⚠️', success: '✅', danger: '🚨' }

const previewBg   = computed(() => PREVIEW_BG[form.value.announcement_type]   || 'bg-blue-600')
const previewText = computed(() => PREVIEW_TEXT[form.value.announcement_type] || 'text-white')
const previewIcon = computed(() => PREVIEW_ICON[form.value.announcement_type] || '📢')

const DEFAULT_QUICK_LINKS = [
  { label: 'หน้าแรก',            to: '/',          visible: true },
  { label: 'ข่าวประชาสัมพันธ์', to: '/news',       visible: true },
  { label: 'ภาพกิจกรรม',        to: '/activities', visible: true },
  { label: 'คลังสื่อ',           to: '/media',      visible: true },
  { label: 'ปฏิทินวิชาการ',     to: '/calendar',   visible: true },
  { label: 'ข้อมูลนักเรียน',    to: '/students-info', visible: true },
  { label: 'เอกสาร/ดาวน์โหลด', to: '/documents',  visible: true },
  { label: 'เข้าสู่ระบบ',       to: '/login',      visible: true },
  { label: 'ลงทะเบียน',         to: '/register',   visible: false },
]

const DEFAULT_AGENCIES = [
  { label: 'สพฐ. (OBEC)',  url: 'https://www.obec.go.th' },
  { label: 'ระบบ DMC',    url: 'https://portal.bopp-obec.info/obec65' },
  { label: 'OBECIT',      url: 'https://www.obecit.obec.go.th' },
  { label: 'คุรุสภา',     url: 'https://www.ksp.or.th' },
  { label: 'e-Budget',    url: 'https://ebudget.obec.go.th' },
]

const themes = [
  { key: 'blue',    label: 'น้ำเงินราชการ',  desc: 'Classic · รัฐ/ราชการ',   navColor: '#1e3a8a' },
  { key: 'green',   label: 'เขียวมรกต',      desc: 'Nature · วิชาการ',       navColor: '#064e3b' },
  { key: 'red',     label: 'แดงทับทิม',      desc: 'Bold · ประเพณีไทย',     navColor: '#881337' },
  { key: 'pastel',  label: 'ม่วงพาสเทล',     desc: 'Soft · หรูหรา',         navColor: '#4c1d95' },
  { key: 'teal',    label: 'เขียวทะเล',      desc: 'Fresh · ทันสมัย',        navColor: '#134e4a' },
  { key: 'amber',   label: 'ทองเหลือง',      desc: 'Warm · อบอุ่น',         navColor: '#78350f' },
  { key: 'slate',   label: 'เทาเข้ม',        desc: 'Neutral · เรียบหรู',     navColor: '#0f172a' },
  { key: 'maroon',  label: 'แดงเลือดหมู',    desc: 'Strong · ทรงพลัง',      navColor: '#4a0404' },
]

// คำนวณ gradient style จาก navColor hex
function navColorToStyle(hex) {
  const h = (hex || '#1e3a8a').replace('#', '')
  const r = parseInt(h.slice(0, 2), 16)
  const g = parseInt(h.slice(2, 4), 16)
  const b = parseInt(h.slice(4, 6), 16)
  const toHex = (v) => Math.min(255, Math.max(0, Math.round(v))).toString(16).padStart(2, '0')
  const darker  = `#${toHex(r * .70)}${toHex(g * .70)}${toHex(b * .78)}`
  const lighter = `#${toHex(r * 1.15)}${toHex(g * 1.12)}${toHex(b * 1.20)}`
  return { background: `linear-gradient(135deg, ${darker} 0%, ${hex} 60%, ${lighter} 100%)` }
}

const themePreviewStyle = computed(() => {
  const t = themes.find(t => t.key === form.value.theme)
  const color = form.value.nav_color || t?.navColor || '#1e3a8a'
  return navColorToStyle(color)
})

const todayStr = new Date().toISOString().split('T')[0]

const fullAddress = computed(() => {
  const f = form.value
  const parts = [
    f.address_no ? `${f.address_no}` : '',
    f.address_moo ? `หมู่ ${f.address_moo}` : '',
    f.address_road ? `ถ.${f.address_road}` : '',
    f.address_subdistrict ? `ต.${f.address_subdistrict}` : '',
    f.address_district ? `อ.${f.address_district}` : '',
    f.address_province ? `จ.${f.address_province}` : '',
    f.zipcode || '',
  ].filter(Boolean)
  return parts.join(' ') || form.value.address || '-'
})

const exportPreview = computed(() => JSON.stringify({
  school_code: form.value.school_code,
  name_th: form.value.name_th,
  area_code: form.value.area_code,
  area_name: form.value.area_name,
  province: form.value.address_province,
}, null, 2))

// Social media list สำหรับ preview
const activeSocials = computed(() => {
  const f = form.value
  const list = []
  if (f.show_social_facebook && f.social_facebook)
    list.push({ key: 'fb', label: 'Facebook', url: f.social_facebook, bg: 'bg-blue-600',
      icon: '<svg viewBox="0 0 24 24" fill="currentColor" class="w-4 h-4"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>' })
  if (f.show_social_line && f.social_line)
    list.push({ key: 'line', label: 'Line', url: f.social_line.startsWith('http') ? f.social_line : `https://line.me/ti/p/${f.social_line}`, bg: 'bg-green-500',
      icon: '<svg viewBox="0 0 24 24" fill="currentColor" class="w-4 h-4"><path d="M19.365 9.863c.349 0 .63.285.63.631 0 .345-.281.63-.63.63H17.61v1.125h1.755c.349 0 .63.283.63.63 0 .344-.281.629-.63.629h-2.386c-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.627-.63h2.386c.349 0 .63.285.63.63 0 .349-.281.63-.63.63H17.61v1.125h1.755zm-3.855 3.016c0 .27-.174.51-.432.596-.064.021-.133.031-.199.031-.211 0-.391-.09-.51-.25l-2.443-3.317v2.94c0 .344-.279.629-.631.629-.346 0-.626-.285-.626-.629V8.108c0-.27.173-.51.43-.595.06-.023.136-.033.194-.033.195 0 .375.104.495.254l2.462 3.33V8.108c0-.345.282-.63.63-.63.345 0 .63.285.63.63v4.771zm-5.741 0c0 .344-.282.629-.631.629-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.627-.63.349 0 .631.285.631.63v4.771zm-2.466.629H4.917c-.345 0-.63-.285-.63-.629V8.108c0-.345.285-.63.63-.63.348 0 .63.285.63.63v4.141h1.756c.348 0 .629.283.629.63 0 .344-.281.629-.629.629M24 10.314C24 4.943 18.615.572 12 .572S0 4.943 0 10.314c0 4.811 4.27 8.842 10.035 9.608.391.082.923.258 1.058.59.12.301.079.766.038 1.08l-.164 1.02c-.045.301-.24 1.186 1.049.645 1.291-.539 6.916-4.07 9.436-6.975C23.176 14.393 24 12.458 24 10.314"/></svg>' })
  if (f.show_social_youtube && f.social_youtube)
    list.push({ key: 'yt', label: 'YouTube', url: f.social_youtube, bg: 'bg-red-600',
      icon: '<svg viewBox="0 0 24 24" fill="currentColor" class="w-4 h-4"><path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/></svg>' })
  if (f.show_social_tiktok && f.social_tiktok)
    list.push({ key: 'tt', label: 'TikTok', url: f.social_tiktok, bg: 'bg-gray-900',
      icon: '<svg viewBox="0 0 24 24" fill="currentColor" class="w-4 h-4"><path d="M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.08 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.19-3.44-3.37-3.65-5.71-.02-.5-.03-1-.01-1.49.18-1.9 1.12-3.72 2.58-4.96 1.66-1.44 3.98-2.13 6.15-1.72.02 1.48-.04 2.96-.04 4.44-.99-.32-2.15-.23-3.02.37-.63.41-1.11 1.04-1.36 1.75-.21.51-.15 1.07-.14 1.61.24 1.64 1.82 3.02 3.5 2.87 1.12-.01 2.19-.66 2.77-1.61.19-.33.4-.67.41-1.06.1-1.79.06-3.57.07-5.36.01-4.03-.01-8.05.02-12.07z"/></svg>' })
  return list
})

const videoRefs = ref({})
const videoUploading = ref({})

async function getToken() {
  // ใช้ getSession() เสมอ — auto-refresh token ถ้าหมดอายุ
  const { data } = await supabase.auth.getSession()
  return data?.session?.access_token ?? null
}

async function deleteStorageFile(url, idx) {
  if (!url) return
  if (!confirm('ลบไฟล์นี้ออกจาก Storage ด้วยไหม?\n(ไม่สามารถกู้คืนได้)')) return
  try {
    const match = url.match(/\/object\/(?:public|sign)\/school\/(.+?)(\?|$)/)
    if (!match) throw new Error('ไม่สามารถระบุ path ของไฟล์ได้')
    const path = decodeURIComponent(match[1])
    const { error } = await supabase.storage.from('school').remove([path])
    if (error) throw error
    banners.value[idx].url = ''
    saveMsg.value = { text: '🗑️ ลบไฟล์ออกจาก Storage สำเร็จ', type: 'success' }
    setTimeout(() => saveMsg.value = { text: '', type: '' }, 3000)
  } catch (e) {
    saveMsg.value = { text: 'ลบไฟล์ไม่สำเร็จ: ' + e.message, type: 'error' }
    setTimeout(() => saveMsg.value = { text: '', type: '' }, 4000)
  }
}

async function handleVideoUpload(event, idx) {
  const file = event.target.files[0]
  if (!file) return
  if (file.size > 50 * 1024 * 1024) {
    saveMsg.value = { text: 'ไฟล์วิดีโอใหญ่เกิน 50MB กรุณาบีบอัดหรือตัดให้สั้นลงก่อน', type: 'error' }
    setTimeout(() => saveMsg.value = { text: '', type: '' }, 4000)
    return
  }
  videoUploading.value[idx] = true
  try {
    const token = await getToken()
    const ext = file.name.split('.').pop().toLowerCase() || 'mp4'
    const path = `banners/banner-${idx}.${ext}`
    const res = await fetch(`${SUPABASE_URL}/storage/v1/object/school/${path}`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': file.type || 'video/mp4',
        'x-upsert': 'true',
      },
      body: file,
    })
    if (!res.ok) throw new Error(await res.text())
    const { data: urlData } = supabase.storage.from('school').getPublicUrl(path)
    banners.value[idx].url = urlData.publicUrl + `?t=${Date.now()}`
    banners.value[idx].type = 'video'
    saveMsg.value = { text: '✅ อัปโหลดวิดีโอสำเร็จ', type: 'success' }
    setTimeout(() => saveMsg.value = { text: '', type: '' }, 3000)
  } catch (e) {
    saveMsg.value = { text: 'อัปโหลดวิดีโอไม่สำเร็จ: ' + e.message, type: 'error' }
    setTimeout(() => saveMsg.value = { text: '', type: '' }, 5000)
  } finally {
    videoUploading.value[idx] = false
    if (videoRefs.value[idx]) videoRefs.value[idx].value = ''
  }
}

function addBanner() { banners.value.push({ type: 'image', url: '', caption: '', subcaption: '' }) }
function addDeputy() { deputies.value.push({ prefix: 'นาย', name: '', position: '', image_url: '' }) }

const DEFAULT_WIDGETS = {
  student_stats: { enabled: true, order: 5, title: 'ข้อมูลนักเรียน', subtitle: 'สถิตินักเรียนปีการศึกษาล่าสุด', variant: 'circuit', stemColor: '#3b82f6', leafColor: '#93c5fd' },
  calendar:      { enabled: true, order: 6, title: 'ปฏิทินวิชาการ',  subtitle: 'กิจกรรมและกำหนดการสำคัญของโรงเรียน', variant: 'wave',    stemColor: '#6366f1', leafColor: '#a5b4fc' },
}

function loadConfig() {
  if (!config.value) return
  form.value = { ...config.value }
  // nav_color: ถ้าไม่มีในฐานข้อมูล → ดึงจาก theme preset เป็น fallback
  if (!form.value.nav_color) {
    const preset = themes.find(t => t.key === form.value.theme)
    form.value.nav_color = preset?.navColor || '#1e3a8a'
  }
  banners.value = Array.isArray(config.value.banner_images) ? config.value.banner_images.map(b => ({ ...b })) : []
  deputies.value = Array.isArray(config.value.deputy_directors) ? config.value.deputy_directors.map(d => ({ ...d })) : []
  form.value.homepage_sections = Array.isArray(config.value.homepage_sections) && config.value.homepage_sections.length
    ? config.value.homepage_sections.map(s => ({
        darkColor: '#1e3a5f', // fallback สำหรับ record เก่าที่ยังไม่มี darkColor
        ...s,
      }))
    : DEFAULT_SECTIONS.map(s => ({ ...s }))
  const w = config.value.homepage_widgets || {}
  form.value.homepage_widgets = {
    student_stats: { ...DEFAULT_WIDGETS.student_stats, ...(w.student_stats || {}) },
    calendar:      { ...DEFAULT_WIDGETS.calendar,      ...(w.calendar      || {}) },
  }

  // Top bar
  form.value.topbar_enabled = config.value.topbar_enabled ?? true
  form.value.topbar_text    = config.value.topbar_text    ?? ''

  // Personnel — admin departments
  form.value.admin_departments = Array.isArray(config.value.admin_departments) && config.value.admin_departments.length
    ? [...config.value.admin_departments]
    : ['กลุ่มบริหารวิชาการ', 'กลุ่มบริหารงบประมาณ', 'กลุ่มบริหารงานบุคคล', 'กลุ่มบริหารทั่วไป']

  // Announcement banner
  form.value.announcement_enabled = config.value.announcement_enabled ?? false
  form.value.announcement_text    = config.value.announcement_text    ?? ''
  form.value.announcement_type    = config.value.announcement_type    ?? 'info'
  form.value.announcement_link    = config.value.announcement_link    ?? ''
  form.value.announcement_speed   = config.value.announcement_speed   ?? 18

  // Footer
  const savedLinks = config.value.footer_quick_links
  form.value.footer_quick_links = Array.isArray(savedLinks) && savedLinks.length
    ? savedLinks
    : DEFAULT_QUICK_LINKS.map(l => ({ ...l }))

  const savedAgencies = config.value.footer_agencies
  form.value.footer_agencies = Array.isArray(savedAgencies)
    ? savedAgencies.map(a => ({ ...a }))
    : DEFAULT_AGENCIES.map(a => ({ ...a }))
}

function addAgency() {
  form.value.footer_agencies.push({ label: '', url: '' })
}
function removeAgency(idx) {
  form.value.footer_agencies.splice(idx, 1)
}
function moveAgency(idx, dir) {
  const arr = form.value.footer_agencies
  const ni = idx + dir
  if (ni < 0 || ni >= arr.length) return
  ;[arr[idx], arr[ni]] = [arr[ni], arr[idx]]
}

function moveSec(idx, dir) {
  const arr = form.value.homepage_sections
  const ni = idx + dir
  if (ni < 0 || ni >= arr.length) return
  ;[arr[idx], arr[ni]] = [arr[ni], arr[idx]]
  arr.forEach((s, i) => { s.order = i + 1 })
}

async function handleSave() {
  saving.value = true
  saveMsg.value = { text: '', type: '' }
  try {
    await updateConfig({
      ...form.value,
      banner_images: banners.value,
      deputy_directors: deputies.value,
    })
    saveMsg.value = { text: '✅ บันทึกการตั้งค่าสำเร็จ', type: 'success' }
    setTimeout(() => saveMsg.value = { text: '', type: '' }, 4000)
  } catch (e) {
    saveMsg.value = { text: '❌ บันทึกไม่สำเร็จ: ' + e.message, type: 'error' }
  } finally {
    saving.value = false
  }
}

watch(config, loadConfig, { immediate: true })
onMounted(() => { if (config.value) loadConfig() })
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
.toast-enter-active { transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1); }
.toast-leave-active { transition: all 0.25s ease-in; }
.toast-enter-from { opacity: 0; transform: scale(0.85); }
.toast-leave-to { opacity: 0; transform: scale(0.9); }
</style>
