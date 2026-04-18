-- ============================================================
-- FULL SETUP SQL — ระบบเว็บไซต์โรงเรียน (Vue + Supabase)
-- สำหรับการติดตั้งใหม่ทั้งหมด (Fresh Install)
-- รันใน Supabase SQL Editor ครั้งเดียว
-- ============================================================
-- ขั้นตอนก่อนรัน:
--   1. สร้าง Supabase project ใหม่
--   2. คัดลอก SQL ทั้งหมดนี้วางใน SQL Editor แล้วกด Run
--   3. ไปที่ Authentication → สมัครบัญชีผู้ใช้แรก
--   4. รันส่วน PART 6 ด้านล่างสุด (แก้ email ให้ตรง) แล้วกด Run
-- ============================================================


-- ============================================================
-- PART 1: profiles table (สร้างก่อน ยังไม่ใส่ policy)
-- ============================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email             VARCHAR(255) UNIQUE NOT NULL,
  full_name         VARCHAR(200) DEFAULT '',
  role              VARCHAR(20)  DEFAULT 'pending'
                    CHECK (role IN ('admin', 'teacher', 'staff', 'pending')),
  is_approved       BOOLEAN      DEFAULT false,
  avatar_url        TEXT         DEFAULT '',
  profile_image_url TEXT         DEFAULT '',
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;


-- ============================================================
-- PART 2: Helper Functions (อ้างอิง profiles ได้แล้ว)
-- ============================================================

-- ดึง role โดยไม่ recursive (ใช้ใน RLS ทุกที่)
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text LANGUAGE sql SECURITY DEFINER SET search_path = public STABLE
AS $$ SELECT role FROM public.profiles WHERE id = auth.uid(); $$;

-- Auto-create profile เมื่อสมัครสมาชิก
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================================
-- PART 3: profiles RLS policies (get_my_role พร้อมแล้ว)
-- ============================================================

DROP POLICY IF EXISTS "profiles: select"           ON public.profiles;
DROP POLICY IF EXISTS "profiles: update"           ON public.profiles;
DROP POLICY IF EXISTS "profiles: read own"         ON public.profiles;
DROP POLICY IF EXISTS "profiles: admin read all"   ON public.profiles;
DROP POLICY IF EXISTS "profiles: update own"       ON public.profiles;
DROP POLICY IF EXISTS "profiles: admin update all" ON public.profiles;
DROP POLICY IF EXISTS "profiles: read"             ON public.profiles;
CREATE POLICY "profiles: read"
  ON public.profiles FOR SELECT TO authenticated
  USING (id = auth.uid() OR public.get_my_role() = 'admin');
CREATE POLICY "profiles: update"
  ON public.profiles FOR UPDATE TO authenticated
  USING (id = auth.uid() OR public.get_my_role() = 'admin')
  WITH CHECK (id = auth.uid() OR public.get_my_role() = 'admin');


-- ============================================================
-- PART 4: Tables
-- ============================================================

-- ─── 4.1 school_config ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.school_config (
  id                    SERIAL PRIMARY KEY,
  school_code           VARCHAR(20)   DEFAULT '',
  obec_smis_code        VARCHAR(20)   DEFAULT '',
  area_code             VARCHAR(10)   DEFAULT '',
  province_code         VARCHAR(5)    DEFAULT '',
  name_th               VARCHAR(300)  DEFAULT 'โรงเรียนของฉัน',
  name_en               VARCHAR(300)  DEFAULT 'My School',
  motto                 VARCHAR(300)  DEFAULT '',
  vision                TEXT          DEFAULT '',
  mission               TEXT          DEFAULT '',
  school_color          VARCHAR(100)  DEFAULT '',
  school_tree           VARCHAR(100)  DEFAULT '',
  school_type           VARCHAR(50)   DEFAULT 'รัฐบาล',
  level_open            VARCHAR(100)  DEFAULT '',
  total_rooms           INTEGER       DEFAULT 0,
  established_year      INTEGER       DEFAULT 2500,
  school_size           VARCHAR(50)   DEFAULT 'กลาง',
  address               TEXT          DEFAULT '',
  address_no            VARCHAR(20)   DEFAULT '',
  address_moo           VARCHAR(10)   DEFAULT '',
  address_road          VARCHAR(100)  DEFAULT '',
  address_subdistrict   VARCHAR(100)  DEFAULT '',
  address_district      VARCHAR(100)  DEFAULT '',
  address_province      VARCHAR(100)  DEFAULT '',
  zipcode               VARCHAR(10)   DEFAULT '',
  lat                   DECIMAL(10,7) DEFAULT NULL,
  lng                   DECIMAL(10,7) DEFAULT NULL,
  director_prefix       VARCHAR(20)   DEFAULT 'นาย',
  director_name         VARCHAR(100)  DEFAULT '',
  director_phone        VARCHAR(20)   DEFAULT '',
  director_image_url    TEXT          DEFAULT '',
  deputy_directors      JSONB         DEFAULT '[]',
  phone                 VARCHAR(20)   DEFAULT '',
  fax                   VARCHAR(20)   DEFAULT '',
  email                 VARCHAR(100)  DEFAULT '',
  website               VARCHAR(200)  DEFAULT '',
  affiliation           VARCHAR(200)  DEFAULT 'สำนักงานคณะกรรมการการศึกษาขั้นพื้นฐาน',
  area_name             VARCHAR(200)  DEFAULT '',
  social_facebook       VARCHAR(300)  DEFAULT '',
  social_line           VARCHAR(300)  DEFAULT '',
  social_youtube        VARCHAR(300)  DEFAULT '',
  social_tiktok         TEXT          DEFAULT '',
  show_social_facebook  BOOLEAN       DEFAULT true,
  show_social_line      BOOLEAN       DEFAULT true,
  show_social_youtube   BOOLEAN       DEFAULT true,
  show_social_tiktok    BOOLEAN       DEFAULT true,
  logo_url              TEXT          DEFAULT '',
  banner_images         JSONB         DEFAULT '[]',
  show_public_bmi       BOOLEAN       DEFAULT false,
  register_code         TEXT          DEFAULT '1234',
  -- การแสดงผลหน้าแรก
  homepage_sections     JSONB         DEFAULT '[]',
  homepage_widgets      JSONB         DEFAULT '{}',
  -- topbar แถบประกาศบนสุด
  topbar_enabled        BOOLEAN       DEFAULT true,
  topbar_text           TEXT          DEFAULT '',
  -- announcement banner เลื่อน
  announcement_enabled  BOOLEAN       DEFAULT false,
  announcement_text     TEXT          DEFAULT '',
  announcement_type     TEXT          DEFAULT 'info',
  announcement_link     TEXT          DEFAULT '',
  announcement_speed    INTEGER       DEFAULT 18,
  -- กลุ่มบริหาร
  admin_departments     JSONB         DEFAULT '[]',
  -- ธีม / สีเมนู
  theme                 TEXT          DEFAULT 'default',
  nav_color             TEXT          DEFAULT '#1e3a8a',
  -- ชื่อหน้า วPA
  wpa_title             TEXT          DEFAULT 'ข้อตกลงและผลงาน (วPA)',
  -- footer
  footer_quick_links    JSONB         DEFAULT '[]',
  footer_agencies       JSONB         DEFAULT '[]',
  updated_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO public.school_config (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.school_config ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "school_config: public read"  ON public.school_config;
DROP POLICY IF EXISTS "school_config: admin update" ON public.school_config;
DROP POLICY IF EXISTS "school_config: select"       ON public.school_config;
DROP POLICY IF EXISTS "school_config: update"       ON public.school_config;
CREATE POLICY "school_config: public read"
  ON public.school_config FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "school_config: admin update"
  ON public.school_config FOR UPDATE TO authenticated
  USING (public.get_my_role() = 'admin')
  WITH CHECK (public.get_my_role() = 'admin');


-- ─── 4.2 teacher_profiles ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.teacher_profiles (
  id                    UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  employee_id           VARCHAR(20)  DEFAULT '',
  id_card               VARCHAR(13)  DEFAULT '',
  prefix                VARCHAR(20)  DEFAULT '',
  first_name            VARCHAR(100) DEFAULT '',
  last_name             VARCHAR(100) DEFAULT '',
  email                 VARCHAR(255) DEFAULT '',
  phone                 VARCHAR(20)  DEFAULT '',
  position              VARCHAR(100) DEFAULT '',
  academic_standing     VARCHAR(100) DEFAULT '',
  subject_group         VARCHAR(100) DEFAULT '',
  subjects_taught       TEXT         DEFAULT '',
  group_role            VARCHAR(100) DEFAULT '',
  education_level       VARCHAR(50)  DEFAULT '',
  education_major       VARCHAR(100) DEFAULT '',
  education_institution VARCHAR(100) DEFAULT '',
  birth_date            DATE,
  start_date            DATE,
  website_url           TEXT         DEFAULT '',
  profile_image_url     TEXT         DEFAULT '',
  created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.teacher_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "teacher_profiles: select"      ON public.teacher_profiles;
DROP POLICY IF EXISTS "teacher_profiles: insert"      ON public.teacher_profiles;
DROP POLICY IF EXISTS "teacher_profiles: update"      ON public.teacher_profiles;
DROP POLICY IF EXISTS "teacher_profiles: public read" ON public.teacher_profiles;
CREATE POLICY "teacher_profiles: select"
  ON public.teacher_profiles FOR SELECT TO authenticated
  USING (id = auth.uid() OR public.get_my_role() = 'admin');
CREATE POLICY "teacher_profiles: insert"
  ON public.teacher_profiles FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid() OR public.get_my_role() = 'admin');
CREATE POLICY "teacher_profiles: update"
  ON public.teacher_profiles FOR UPDATE TO authenticated
  USING (id = auth.uid() OR public.get_my_role() = 'admin');
CREATE POLICY "teacher_profiles: public read"
  ON public.teacher_profiles FOR SELECT TO anon USING (true);


-- ─── 4.3 students ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.students (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id_card       VARCHAR(13) UNIQUE,
  student_code          VARCHAR(20),
  prefix                VARCHAR(20)  DEFAULT '',
  first_name            VARCHAR(100) NOT NULL DEFAULT '',
  last_name             VARCHAR(100) NOT NULL DEFAULT '',
  gender                VARCHAR(10)  DEFAULT '',
  grade_level           VARCHAR(10)  DEFAULT '',
  room                  SMALLINT,
  birth_date            DATE,
  age                   INTEGER,
  weight                DECIMAL(5,2),
  height                DECIMAL(5,2),
  blood_type            VARCHAR(5)   DEFAULT '',
  religion              VARCHAR(50)  DEFAULT '',
  ethnicity             VARCHAR(50)  DEFAULT '',
  nationality           VARCHAR(50)  DEFAULT 'ไทย',
  address_no            VARCHAR(20)  DEFAULT '',
  address_moo           VARCHAR(10)  DEFAULT '',
  address_road          VARCHAR(100) DEFAULT '',
  address_subdistrict   VARCHAR(100) DEFAULT '',
  address_district      VARCHAR(100) DEFAULT '',
  address_province      VARCHAR(100) DEFAULT '',
  guardian_prefix       VARCHAR(20)  DEFAULT '',
  guardian_first_name   VARCHAR(100) DEFAULT '',
  guardian_last_name    VARCHAR(100) DEFAULT '',
  guardian_occupation   VARCHAR(100) DEFAULT '',
  guardian_phone        VARCHAR(20)  DEFAULT '',
  guardian_relationship VARCHAR(50)  DEFAULT '',
  father_first_name     VARCHAR(100) DEFAULT '',
  father_last_name      VARCHAR(100) DEFAULT '',
  father_occupation     VARCHAR(100) DEFAULT '',
  mother_first_name     VARCHAR(100) DEFAULT '',
  mother_last_name      VARCHAR(100) DEFAULT '',
  mother_occupation     VARCHAR(100) DEFAULT '',
  disadvantaged_status  VARCHAR(200) DEFAULT '',
  profile_image_url     TEXT         DEFAULT '',
  is_active             BOOLEAN      DEFAULT true,
  academic_year         VARCHAR(10)  DEFAULT '',
  created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "students: select" ON public.students;
DROP POLICY IF EXISTS "students: insert" ON public.students;
DROP POLICY IF EXISTS "students: update" ON public.students;
DROP POLICY IF EXISTS "students: delete" ON public.students;
CREATE POLICY "students: select"
  ON public.students FOR SELECT TO authenticated USING (true);
CREATE POLICY "students: insert"
  ON public.students FOR INSERT TO authenticated
  WITH CHECK (public.get_my_role() IN ('admin', 'teacher'));
CREATE POLICY "students: update"
  ON public.students FOR UPDATE TO authenticated
  USING (public.get_my_role() IN ('admin', 'teacher'));
CREATE POLICY "students: delete"
  ON public.students FOR DELETE TO authenticated
  USING (public.get_my_role() = 'admin');


-- ─── 4.4 import_sessions ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.import_sessions (
  id               UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  academic_year    INTEGER      NOT NULL,
  checkpoint       SMALLINT     NOT NULL,
  checkpoint_label VARCHAR(100) DEFAULT '',
  total_rows       INTEGER      DEFAULT 0,
  imported_by      UUID         REFERENCES public.profiles(id) ON DELETE SET NULL,
  imported_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.import_sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "import_sessions: admin read"  ON public.import_sessions;
DROP POLICY IF EXISTS "import_sessions: admin write" ON public.import_sessions;
CREATE POLICY "import_sessions: admin read"
  ON public.import_sessions FOR SELECT TO authenticated
  USING (public.get_my_role() IN ('admin', 'teacher'));
CREATE POLICY "import_sessions: admin write"
  ON public.import_sessions FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin')
  WITH CHECK (public.get_my_role() = 'admin');


-- ─── 4.5 student_snapshots ───────────────────────────────────
CREATE TABLE IF NOT EXISTS public.student_snapshots (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  import_session_id     UUID         NOT NULL REFERENCES public.import_sessions(id) ON DELETE CASCADE,
  student_code          VARCHAR(20),
  student_id_card       VARCHAR(13),
  prefix                VARCHAR(20)  DEFAULT '',
  first_name            VARCHAR(100) DEFAULT '',
  last_name             VARCHAR(100) DEFAULT '',
  gender                VARCHAR(10)  DEFAULT '',
  grade_level           VARCHAR(10)  DEFAULT '',
  room                  SMALLINT,
  birth_date            DATE,
  age                   INTEGER,
  weight                DECIMAL(5,2),
  height                DECIMAL(5,2),
  blood_type            VARCHAR(5)   DEFAULT '',
  religion              VARCHAR(50)  DEFAULT '',
  ethnicity             VARCHAR(50)  DEFAULT '',
  nationality           VARCHAR(50)  DEFAULT 'ไทย',
  address_no            VARCHAR(20)  DEFAULT '',
  address_moo           VARCHAR(10)  DEFAULT '',
  address_subdistrict   VARCHAR(100) DEFAULT '',
  address_district      VARCHAR(100) DEFAULT '',
  address_province      VARCHAR(100) DEFAULT '',
  guardian_prefix       VARCHAR(20)  DEFAULT '',
  guardian_first_name   VARCHAR(100) DEFAULT '',
  guardian_last_name    VARCHAR(100) DEFAULT '',
  guardian_occupation   VARCHAR(100) DEFAULT '',
  guardian_phone        VARCHAR(20)  DEFAULT '',
  guardian_relationship VARCHAR(50)  DEFAULT '',
  father_first_name     VARCHAR(100) DEFAULT '',
  father_last_name      VARCHAR(100) DEFAULT '',
  mother_first_name     VARCHAR(100) DEFAULT '',
  mother_last_name      VARCHAR(100) DEFAULT '',
  disadvantaged_status  VARCHAR(200) DEFAULT '',
  created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.student_snapshots ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "student_snapshots: admin read"  ON public.student_snapshots;
DROP POLICY IF EXISTS "student_snapshots: admin write" ON public.student_snapshots;
CREATE POLICY "student_snapshots: admin read"
  ON public.student_snapshots FOR SELECT TO authenticated
  USING (public.get_my_role() IN ('admin', 'teacher'));
CREATE POLICY "student_snapshots: admin write"
  ON public.student_snapshots FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin')
  WITH CHECK (public.get_my_role() = 'admin');


-- ─── 4.6 news ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.news (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           VARCHAR(500) NOT NULL,
  content         TEXT         DEFAULT '',
  cover_image_url TEXT         DEFAULT '',
  category        VARCHAR(50)  DEFAULT 'news'
                  CHECK (category IN ('news', 'announcement', 'award', 'academic')),
  is_published    BOOLEAN      DEFAULT true,
  view_count      INTEGER      DEFAULT 0,
  created_by      UUID         REFERENCES public.profiles(id),
  published_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.news ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "news: public read" ON public.news;
DROP POLICY IF EXISTS "news: admin all"   ON public.news;
CREATE POLICY "news: public read"
  ON public.news FOR SELECT TO anon, authenticated USING (is_published = true);
CREATE POLICY "news: admin all"
  ON public.news FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin')
  WITH CHECK (public.get_my_role() = 'admin');


-- ─── 4.7 activities ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.activities (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           VARCHAR(500) NOT NULL,
  description     TEXT         DEFAULT '',
  cover_image_url TEXT         DEFAULT '',
  images          JSONB        DEFAULT '[]',
  activity_date   DATE         DEFAULT CURRENT_DATE,
  is_published    BOOLEAN      DEFAULT true,
  created_by      UUID         REFERENCES public.profiles(id),
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "activities: public read" ON public.activities;
DROP POLICY IF EXISTS "activities: admin all"   ON public.activities;
CREATE POLICY "activities: public read"
  ON public.activities FOR SELECT TO anon, authenticated USING (is_published = true);
CREATE POLICY "activities: admin all"
  ON public.activities FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin')
  WITH CHECK (public.get_my_role() = 'admin');


-- ─── 4.8 api_keys ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.api_keys (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT        NOT NULL,
  api_key       TEXT        UNIQUE NOT NULL,
  resource      TEXT        NOT NULL,
  fields        TEXT[]      NOT NULL DEFAULT '{}',
  filter_json   JSONB       DEFAULT '{}',
  is_active     BOOLEAN     DEFAULT true,
  expires_at    TIMESTAMPTZ,
  last_used_at  TIMESTAMPTZ,
  request_count INTEGER     DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.api_keys ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "api_keys admin only" ON public.api_keys;
CREATE POLICY "api_keys admin only"
  ON public.api_keys FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin' AND is_approved = true
    )
  );


-- ─── 4.9 school_documents (คำสั่ง/ประกาศโรงเรียน) ────────────
CREATE TABLE IF NOT EXISTS public.school_documents (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  type          TEXT        NOT NULL CHECK (type IN ('order', 'announcement')),
  doc_number    TEXT        NOT NULL,
  title         TEXT        NOT NULL,
  issued_date   DATE        NOT NULL,
  drive_url     TEXT        NOT NULL,
  department    TEXT        NOT NULL,
  dept_other    TEXT,
  academic_year INT         NOT NULL,
  note          TEXT,
  created_by    UUID        REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.school_documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "school_docs: public read" ON public.school_documents;
DROP POLICY IF EXISTS "school_docs: admin write" ON public.school_documents;
CREATE POLICY "school_docs: public read"
  ON public.school_documents FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "school_docs: admin write"
  ON public.school_documents FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role IN ('admin', 'staff') AND is_approved = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role IN ('admin', 'staff') AND is_approved = true
    )
  );


-- ============================================================
-- PART 5: Indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_profiles_role        ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_is_approved ON public.profiles(is_approved);
CREATE INDEX IF NOT EXISTS idx_students_grade       ON public.students(grade_level, room);
CREATE INDEX IF NOT EXISTS idx_students_id_card     ON public.students(student_id_card);
CREATE INDEX IF NOT EXISTS idx_students_name        ON public.students(first_name, last_name);
CREATE INDEX IF NOT EXISTS idx_students_is_active   ON public.students(is_active);
CREATE INDEX IF NOT EXISTS idx_students_code        ON public.students(student_code);
CREATE INDEX IF NOT EXISTS idx_snapshots_session    ON public.student_snapshots(import_session_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_code       ON public.student_snapshots(student_code);
CREATE INDEX IF NOT EXISTS idx_news_published       ON public.news(is_published, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_activities_published ON public.activities(is_published, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_school_docs_type     ON public.school_documents(type);
CREATE INDEX IF NOT EXISTS idx_school_docs_date     ON public.school_documents(issued_date DESC);
CREATE INDEX IF NOT EXISTS idx_school_docs_year     ON public.school_documents(academic_year);


-- ============================================================
-- PART 6: RPC Functions
-- ============================================================

-- ─── 6.0 check_register_code (ใช้ตอนสมัครสมาชิก) ────────────
CREATE OR REPLACE FUNCTION public.check_register_code(input_code text)
RETURNS boolean
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.school_config
    WHERE id = 1 AND register_code = input_code
  );
$$;
GRANT EXECUTE ON FUNCTION public.check_register_code(text) TO anon, authenticated;

-- ─── 6.1 get_storage_usage ───────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_storage_usage()
RETURNS TABLE (total_size bigint, file_count bigint)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT
    COALESCE(SUM((metadata->>'size')::bigint), 0) AS total_size,
    COUNT(*) AS file_count
  FROM storage.objects
  WHERE bucket_id NOT IN ('supabase-internal');
$$;
GRANT EXECUTE ON FUNCTION public.get_storage_usage() TO authenticated;

-- ─── 6.2 get_public_bmi_stats ────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_public_bmi_stats()
RETURNS TABLE (grade_level text, weight text, height text)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT
    COALESCE(s.grade_level, ss.grade_level)::text AS grade_level,
    ss.weight::text,
    ss.height::text
  FROM student_snapshots ss
  INNER JOIN (
    SELECT id FROM import_sessions ORDER BY imported_at DESC LIMIT 1
  ) latest ON ss.import_session_id = latest.id
  INNER JOIN students s ON s.student_code = ss.student_code
  WHERE s.is_active = true
    AND ss.weight IS NOT NULL AND ss.weight::text <> ''
    AND ss.height IS NOT NULL AND ss.height::text <> '';
$$;
GRANT EXECUTE ON FUNCTION public.get_public_bmi_stats() TO anon, authenticated;

-- ─── 6.3 teacher_data_view + get_api_data ────────────────────
CREATE OR REPLACE VIEW public.teacher_data_view AS
SELECT
  tp.id, tp.employee_id, tp.id_card, tp.prefix, tp.first_name, tp.last_name,
  tp.email, tp.phone, tp.position, tp.academic_standing, tp.subject_group,
  tp.subjects_taught, tp.group_role, tp.education_level, tp.education_major,
  tp.education_institution, tp.website_url, tp.profile_image_url,
  tp.birth_date, tp.created_at, tp.updated_at
FROM public.teacher_profiles tp;

CREATE OR REPLACE FUNCTION public.get_api_data(p_api_key text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_rec    api_keys%ROWTYPE;
  v_fields text;
  v_result jsonb;
BEGIN
  SELECT * INTO v_rec
  FROM api_keys
  WHERE api_key = p_api_key AND is_active = true
    AND (expires_at IS NULL OR expires_at > now());

  IF NOT FOUND THEN
    RETURN jsonb_build_object('error', 'Invalid or expired API key');
  END IF;

  v_fields := array_to_string(v_rec.fields, ', ');

  IF v_rec.resource = 'teachers' THEN
    EXECUTE format(
      'SELECT jsonb_agg(row_to_json(t))
       FROM (SELECT %s FROM teacher_data_view ORDER BY subject_group, first_name) t',
      v_fields
    ) INTO v_result;
  ELSIF v_rec.resource = 'students' THEN
    EXECUTE format(
      'SELECT jsonb_agg(row_to_json(t))
       FROM (SELECT %s FROM students ORDER BY grade_level, room, first_name) t',
      v_fields
    ) INTO v_result;
  ELSE
    RETURN jsonb_build_object('error', 'Unknown resource: ' || v_rec.resource);
  END IF;

  RETURN jsonb_build_object(
    'success',  true,
    'resource', v_rec.resource,
    'fields',   to_jsonb(v_rec.fields),
    'count',    jsonb_array_length(COALESCE(v_result, '[]'::jsonb)),
    'data',     COALESCE(v_result, '[]'::jsonb)
  );
END;
$$;
GRANT EXECUTE ON FUNCTION public.get_api_data(text) TO anon, authenticated;


-- ============================================================
-- PART 7: Storage Buckets
-- ============================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('avatars',    'avatars',    true, 204800,   ARRAY['image/jpeg','image/png','image/webp']),
  ('school',     'school',     true, 2097152,  ARRAY['image/jpeg','image/png','image/webp']),
  ('news',       'news',       true, 5242880,  ARRAY['image/jpeg','image/png','image/webp']),
  ('activities', 'activities', true, 5242880,  ARRAY['image/jpeg','image/png','image/webp']),
  ('teachers',   'teachers',   true, 5242880,  ARRAY['image/jpeg','image/png','image/webp']),
  ('documents',  'documents',  true, 20971520, NULL)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "storage: public read" ON storage.objects;
DROP POLICY IF EXISTS "storage: auth upload" ON storage.objects;
DROP POLICY IF EXISTS "storage: auth update" ON storage.objects;
DROP POLICY IF EXISTS "storage: auth delete" ON storage.objects;
CREATE POLICY "storage: public read" ON storage.objects FOR SELECT  TO public        USING (true);
CREATE POLICY "storage: auth upload" ON storage.objects FOR INSERT  TO authenticated WITH CHECK (true);
CREATE POLICY "storage: auth update" ON storage.objects FOR UPDATE  TO authenticated USING (true);
CREATE POLICY "storage: auth delete" ON storage.objects FOR DELETE  TO authenticated USING (true);


-- ============================================================
-- PART 8: สร้าง Admin (รันแยกหลังจากสมัครบัญชีแล้ว)
-- ============================================================
-- 1. ไปที่ Authentication → Users → สมัครบัญชีผ่านหน้าเว็บก่อน
-- 2. แก้ email ด้านล่างให้ตรงกับที่สมัคร
-- 3. Highlight เฉพาะ 2 บรรทัด UPDATE แล้วกด Run

/*
UPDATE public.profiles
SET role = 'admin', is_approved = true, full_name = 'ผู้ดูแลระบบ'
WHERE email = 'your-email@example.com';

-- ตรวจสอบ
SELECT id, email, role, is_approved FROM public.profiles
WHERE email = 'your-email@example.com';
*/
