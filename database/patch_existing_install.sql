-- ============================================================
-- PATCH สำหรับโปรเจคที่ติดตั้งจาก full_setup.sql เวอร์ชันเก่า
-- รันใน Supabase SQL Editor ครั้งเดียว
-- ไม่ต้องรัน full_setup.sql ซ้ำ
-- ============================================================


-- ============================================================
-- 1. แก้ profiles (เพิ่ม column ที่ขาด)
-- ============================================================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS prefix            TEXT DEFAULT 'นาย',
  ADD COLUMN IF NOT EXISTS subject_group     TEXT,
  ADD COLUMN IF NOT EXISTS position          TEXT DEFAULT 'ครู',
  ADD COLUMN IF NOT EXISTS academic_standing TEXT DEFAULT 'ครูผู้ช่วย';


-- ============================================================
-- 2. แก้ teacher_profiles
-- ============================================================
-- เพิ่ม sort_order สำหรับกำหนดตำแหน่งแสดงผล
ALTER TABLE public.teacher_profiles
  ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 100;
-- ลบ FK constraint ออกจาก id เพื่อให้เพิ่มครูได้โดยไม่ต้องสร้างบัญชี
ALTER TABLE public.teacher_profiles DROP CONSTRAINT IF EXISTS teacher_profiles_id_fkey;
-- เพิ่ม user_id สำหรับเชื่อมกับ auth account (nullable)
ALTER TABLE public.teacher_profiles
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
-- เพิ่ม profile_id สำหรับ backward compat
ALTER TABLE public.teacher_profiles
  ADD COLUMN IF NOT EXISTS profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_user_id ON public.teacher_profiles(user_id);


-- ============================================================
-- 3. แก้ import_sessions (เพิ่ม column ที่ขาด)
-- ============================================================
ALTER TABLE public.import_sessions
  ADD COLUMN IF NOT EXISTS filename      TEXT,
  ADD COLUMN IF NOT EXISTS new_count     INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS updated_count INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS left_count    INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS sort_order    INTEGER DEFAULT 0;


-- ============================================================
-- 4. แก้ students (เพิ่ม column + ชื่อที่ถูกต้อง)
-- ============================================================
ALTER TABLE public.students
  ADD COLUMN IF NOT EXISTS national_id        VARCHAR(13),
  ADD COLUMN IF NOT EXISTS guardian_name      VARCHAR(200) DEFAULT '',
  ADD COLUMN IF NOT EXISTS guardian_relation  VARCHAR(50)  DEFAULT '',
  ADD COLUMN IF NOT EXISTS guardian_occupation VARCHAR(100) DEFAULT '',
  ADD COLUMN IF NOT EXISTS disadvantaged      VARCHAR(200) DEFAULT '',
  ADD COLUMN IF NOT EXISTS status             VARCHAR(50)  DEFAULT 'กำลังศึกษา',
  ADD COLUMN IF NOT EXISTS last_import_id     UUID;

-- เพิ่ม UNIQUE บน student_code (ถ้ายังไม่มี)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'students_student_code_key' AND conrelid = 'public.students'::regclass
  ) THEN
    ALTER TABLE public.students ADD CONSTRAINT students_student_code_key UNIQUE (student_code);
  END IF;
END $$;

-- เพิ่ม FK last_import_id → import_sessions
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'students_last_import_id_fkey') THEN
    ALTER TABLE public.students
      ADD CONSTRAINT students_last_import_id_fkey
      FOREIGN KEY (last_import_id) REFERENCES public.import_sessions(id) ON DELETE SET NULL;
  END IF;
END $$;


-- ============================================================
-- 5. แก้ student_snapshots (เพิ่ม column + ชื่อที่ถูกต้อง)
-- ============================================================
ALTER TABLE public.student_snapshots
  ADD COLUMN IF NOT EXISTS national_id      VARCHAR(13),
  ADD COLUMN IF NOT EXISTS guardian_name    VARCHAR(200) DEFAULT '',
  ADD COLUMN IF NOT EXISTS guardian_phone   VARCHAR(20)  DEFAULT '',
  ADD COLUMN IF NOT EXISTS guardian_relation VARCHAR(50) DEFAULT '',
  ADD COLUMN IF NOT EXISTS disadvantaged    VARCHAR(200) DEFAULT '',
  ADD COLUMN IF NOT EXISTS status           VARCHAR(50)  DEFAULT 'กำลังศึกษา';
-- หมายเหตุ: academic_year ถูกเพิ่มไปแล้วก่อนหน้านี้


-- ============================================================
-- 6. แก้ news (เพิ่ม column ที่ขาด)
-- ============================================================
ALTER TABLE public.news
  ADD COLUMN IF NOT EXISTS content_type VARCHAR(10)              DEFAULT 'text',
  ADD COLUMN IF NOT EXISTS excerpt      TEXT                     DEFAULT '',
  ADD COLUMN IF NOT EXISTS show_cover   BOOLEAN                  DEFAULT true,
  ADD COLUMN IF NOT EXISTS links        JSONB                    DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS extra_images JSONB                    DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS external_url TEXT                     DEFAULT '',
  ADD COLUMN IF NOT EXISTS is_pinned    BOOLEAN                  DEFAULT false,
  ADD COLUMN IF NOT EXISTS views        INTEGER                  DEFAULT 0,
  ADD COLUMN IF NOT EXISTS updated_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW();


-- ============================================================
-- 7. แก้ activities (เพิ่ม column ที่ขาด)
-- ============================================================
ALTER TABLE public.activities
  ADD COLUMN IF NOT EXISTS link_url    TEXT,
  ADD COLUMN IF NOT EXISTS cover_emoji TEXT    DEFAULT '📁',
  ADD COLUMN IF NOT EXISTS views       INTEGER DEFAULT 0;


-- ============================================================
-- 8. สร้างตารางใหม่ที่ขาด
-- ============================================================

-- teacher_department_assignments
CREATE TABLE IF NOT EXISTS public.teacher_department_assignments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id      UUID NOT NULL REFERENCES public.teacher_profiles(id) ON DELETE CASCADE,
  department_name TEXT NOT NULL,
  department_role TEXT DEFAULT 'กรรมการ',
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE public.teacher_department_assignments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "dept_assignments: public read"       ON public.teacher_department_assignments;
DROP POLICY IF EXISTS "dept_assignments: admin all"         ON public.teacher_department_assignments;
DROP POLICY IF EXISTS "dept_assignments: teacher manage own" ON public.teacher_department_assignments;
CREATE POLICY "dept_assignments: public read"
  ON public.teacher_department_assignments FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "dept_assignments: admin all"
  ON public.teacher_department_assignments FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');
CREATE POLICY "dept_assignments: teacher manage own"
  ON public.teacher_department_assignments FOR ALL TO authenticated
  USING (teacher_id = auth.uid()) WITH CHECK (teacher_id = auth.uid());

-- news_categories
CREATE TABLE IF NOT EXISTS public.news_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);
ALTER TABLE public.news_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "news_categories: public read" ON public.news_categories;
DROP POLICY IF EXISTS "news_categories: admin all"   ON public.news_categories;
CREATE POLICY "news_categories: public read"
  ON public.news_categories FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "news_categories: admin all"
  ON public.news_categories FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- org_pages
CREATE TABLE IF NOT EXISTS public.org_pages (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title        TEXT    NOT NULL,
  slug         TEXT    NOT NULL UNIQUE,
  icon         TEXT    DEFAULT '',
  content      TEXT    DEFAULT '',
  content_type TEXT    DEFAULT 'text',
  show_title   BOOLEAN DEFAULT true,
  is_published BOOLEAN DEFAULT true,
  sort_order   INTEGER DEFAULT 0,
  created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE public.org_pages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "org_pages: public read" ON public.org_pages;
DROP POLICY IF EXISTS "org_pages: admin all"   ON public.org_pages;
CREATE POLICY "org_pages: public read"
  ON public.org_pages FOR SELECT TO anon, authenticated USING (is_published = true);
CREATE POLICY "org_pages: admin all"
  ON public.org_pages FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- nav_systems
CREATE TABLE IF NOT EXISTS public.nav_systems (
  id           UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  label        TEXT    NOT NULL,
  description  TEXT    DEFAULT '',
  url          TEXT    NOT NULL DEFAULT '',
  icon         TEXT    DEFAULT '',
  icon_bg      TEXT    DEFAULT '',
  show_in_grid BOOLEAN DEFAULT true,
  is_active    BOOLEAN DEFAULT true,
  is_external  BOOLEAN DEFAULT false,
  sort_order   INTEGER DEFAULT 0
);
ALTER TABLE public.nav_systems ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "nav_systems: public read" ON public.nav_systems;
DROP POLICY IF EXISTS "nav_systems: admin all"   ON public.nav_systems;
CREATE POLICY "nav_systems: public read"
  ON public.nav_systems FOR SELECT TO anon, authenticated USING (is_active = true);
CREATE POLICY "nav_systems: admin all"
  ON public.nav_systems FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- media_categories
CREATE TABLE IF NOT EXISTS public.media_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);
ALTER TABLE public.media_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "media_categories: public read" ON public.media_categories;
DROP POLICY IF EXISTS "media_categories: admin all"   ON public.media_categories;
CREATE POLICY "media_categories: public read"
  ON public.media_categories FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "media_categories: admin all"
  ON public.media_categories FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- subject_areas
CREATE TABLE IF NOT EXISTS public.subject_areas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);
ALTER TABLE public.subject_areas ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "subject_areas: public read" ON public.subject_areas;
DROP POLICY IF EXISTS "subject_areas: admin all"   ON public.subject_areas;
CREATE POLICY "subject_areas: public read"
  ON public.subject_areas FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "subject_areas: admin all"
  ON public.subject_areas FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- grade_levels
CREATE TABLE IF NOT EXISTS public.grade_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);
ALTER TABLE public.grade_levels ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grade_levels: public read" ON public.grade_levels;
DROP POLICY IF EXISTS "grade_levels: admin all"   ON public.grade_levels;
CREATE POLICY "grade_levels: public read"
  ON public.grade_levels FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "grade_levels: admin all"
  ON public.grade_levels FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- media
CREATE TABLE IF NOT EXISTS public.media (
  id             UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  title          TEXT    NOT NULL,
  description    TEXT    DEFAULT '',
  thumbnail_url  TEXT    DEFAULT '',
  show_thumbnail BOOLEAN DEFAULT true,
  category       TEXT    DEFAULT '',
  subject_area   TEXT    DEFAULT '',
  grade_level    TEXT    DEFAULT '',
  media_type     TEXT    DEFAULT 'embed',
  content        TEXT    DEFAULT '',
  external_url   TEXT    DEFAULT '',
  author_name    TEXT    DEFAULT '',
  is_published   BOOLEAN DEFAULT true,
  is_featured    BOOLEAN DEFAULT false,
  created_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE public.media ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "media: public read" ON public.media;
DROP POLICY IF EXISTS "media: admin all"   ON public.media;
CREATE POLICY "media: public read"
  ON public.media FOR SELECT TO anon, authenticated USING (is_published = true);
CREATE POLICY "media: admin all"
  ON public.media FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- documents
CREATE TABLE IF NOT EXISTS public.documents (
  id             UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  title          TEXT    NOT NULL,
  description    TEXT    DEFAULT '',
  category       TEXT    DEFAULT '',
  file_type      TEXT    DEFAULT '',
  file_url       TEXT    DEFAULT '',
  is_public      BOOLEAN DEFAULT true,
  download_count INTEGER DEFAULT 0,
  sort_order     INTEGER DEFAULT 0,
  created_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "documents: public read" ON public.documents;
DROP POLICY IF EXISTS "documents: admin all"   ON public.documents;
CREATE POLICY "documents: public read"
  ON public.documents FOR SELECT TO anon, authenticated USING (is_public = true);
CREATE POLICY "documents: admin all"
  ON public.documents FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- wpa_records
CREATE TABLE IF NOT EXISTS public.wpa_records (
  id            UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID    NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  year          INTEGER NOT NULL,
  agreement_url TEXT    DEFAULT '',
  portfolio_url TEXT    DEFAULT '',
  note          TEXT    DEFAULT '',
  is_public     BOOLEAN DEFAULT false,
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE public.wpa_records ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "wpa_records: public read"  ON public.wpa_records;
DROP POLICY IF EXISTS "wpa_records: teacher own"  ON public.wpa_records;
DROP POLICY IF EXISTS "wpa_records: admin all"    ON public.wpa_records;
CREATE POLICY "wpa_records: public read"
  ON public.wpa_records FOR SELECT TO anon, authenticated USING (is_public = true);
CREATE POLICY "wpa_records: teacher own"
  ON public.wpa_records FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "wpa_records: admin all"
  ON public.wpa_records FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- academic_calendar
CREATE TABLE IF NOT EXISTS public.academic_calendar (
  id            UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  title         TEXT    NOT NULL,
  description   TEXT    DEFAULT '',
  start_date    DATE    NOT NULL,
  end_date      DATE,
  event_type    TEXT    DEFAULT 'general',
  academic_year INTEGER,
  is_public     BOOLEAN DEFAULT true,
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE public.academic_calendar ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "calendar: public read" ON public.academic_calendar;
DROP POLICY IF EXISTS "calendar: admin all"   ON public.academic_calendar;
CREATE POLICY "calendar: public read"
  ON public.academic_calendar FOR SELECT TO anon, authenticated USING (is_public = true);
CREATE POLICY "calendar: admin all"
  ON public.academic_calendar FOR ALL TO authenticated
  USING (public.get_my_role() = 'admin') WITH CHECK (public.get_my_role() = 'admin');

-- dmc_imports (view ของ import_sessions สำหรับ StudentHealthPage)
CREATE OR REPLACE VIEW public.dmc_imports AS
SELECT
  id,
  checkpoint_label AS label,
  academic_year::integer,
  checkpoint       AS semester,
  total_rows       AS total_count,
  imported_at
FROM public.import_sessions;


-- ============================================================
-- 9. แก้ RLS policies ที่ผิดเพราะ teacher_profiles.id ไม่ใช่ auth UUID อีกต่อไป
-- ============================================================
DROP POLICY IF EXISTS "teacher_profiles: select" ON public.teacher_profiles;
DROP POLICY IF EXISTS "teacher_profiles: insert" ON public.teacher_profiles;
DROP POLICY IF EXISTS "teacher_profiles: update" ON public.teacher_profiles;
CREATE POLICY "teacher_profiles: select"
  ON public.teacher_profiles FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.get_my_role() = 'admin');
CREATE POLICY "teacher_profiles: insert"
  ON public.teacher_profiles FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR public.get_my_role() = 'admin');
CREATE POLICY "teacher_profiles: update"
  ON public.teacher_profiles FOR UPDATE TO authenticated
  USING (user_id = auth.uid() OR public.get_my_role() = 'admin');

DROP POLICY IF EXISTS "dept_assignments: teacher manage own" ON public.teacher_department_assignments;
CREATE POLICY "dept_assignments: teacher manage own"
  ON public.teacher_department_assignments FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.teacher_profiles
    WHERE id = teacher_id AND user_id = auth.uid()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.teacher_profiles
    WHERE id = teacher_id AND user_id = auth.uid()
  ));


-- ============================================================
-- 10. RPC Functions ที่ขาด
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_sis_sessions()
RETURNS TABLE (
  id               UUID,
  academic_year    SMALLINT,
  checkpoint       SMALLINT,
  checkpoint_label TEXT,
  total_rows       INTEGER,
  imported_at      TIMESTAMPTZ
)
LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public
AS $$
  SELECT id, academic_year, checkpoint, checkpoint_label, total_rows, imported_at
  FROM import_sessions
  ORDER BY imported_at DESC;
$$;
GRANT EXECUTE ON FUNCTION public.get_sis_sessions() TO anon, authenticated;

DROP FUNCTION IF EXISTS public.get_checkpoint_stats(UUID);
CREATE OR REPLACE FUNCTION public.get_checkpoint_stats(p_session_id UUID)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = public
AS $$
DECLARE
  v_by_level        jsonb;
  v_by_room         jsonb;
  v_by_level_gender jsonb;
BEGIN
  SELECT jsonb_object_agg(grade_level, cnt)
  INTO v_by_level
  FROM (
    SELECT grade_level, COUNT(*) AS cnt
    FROM student_snapshots
    WHERE import_session_id = p_session_id
      AND grade_level IS NOT NULL AND grade_level <> ''
    GROUP BY grade_level
  ) t;

  -- room NULL → key "<grade>/0" เพื่อไม่ให้หายจาก byRoom
  SELECT jsonb_object_agg(room_key, stats)
  INTO v_by_room
  FROM (
    SELECT
      grade_level || '/' || COALESCE(room::text, '0') AS room_key,
      jsonb_build_object(
        'total',  COUNT(*),
        'male',   COUNT(*) FILTER (WHERE gender IN ('ชาย', 'ช', 'male')),
        'female', COUNT(*) FILTER (WHERE gender IN ('หญิง', 'ญ', 'female'))
      ) AS stats
    FROM student_snapshots
    WHERE import_session_id = p_session_id
      AND grade_level IS NOT NULL AND grade_level <> ''
    GROUP BY grade_level, room
  ) t;

  -- สรุปเพศต่อชั้น (fallback กรณี room ว่าง)
  SELECT jsonb_object_agg(grade_level, stats)
  INTO v_by_level_gender
  FROM (
    SELECT grade_level,
      jsonb_build_object(
        'total',  COUNT(*),
        'male',   COUNT(*) FILTER (WHERE gender IN ('ชาย', 'ช', 'male')),
        'female', COUNT(*) FILTER (WHERE gender IN ('หญิง', 'ญ', 'female'))
      ) AS stats
    FROM student_snapshots
    WHERE import_session_id = p_session_id
      AND grade_level IS NOT NULL AND grade_level <> ''
    GROUP BY grade_level
  ) t;

  RETURN jsonb_build_object(
    'byLevel',        COALESCE(v_by_level,        '{}'::jsonb),
    'byRoom',         COALESCE(v_by_room,         '{}'::jsonb),
    'byLevelGender',  COALESCE(v_by_level_gender, '{}'::jsonb)
  );
END;
$$;
GRANT EXECUTE ON FUNCTION public.get_checkpoint_stats(UUID) TO anon, authenticated;

DROP FUNCTION IF EXISTS public.get_all_wpa_admin();
CREATE OR REPLACE FUNCTION public.get_all_wpa_admin()
RETURNS TABLE (
  id                UUID,
  user_id           UUID,
  year              INTEGER,
  agreement_url     TEXT,
  portfolio_url     TEXT,
  note              TEXT,
  is_public         BOOLEAN,
  full_name         TEXT,
  teacher_position  TEXT,
  subject_group     TEXT,
  profile_image_url TEXT
)
LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public
AS $$
  SELECT
    w.id,
    w.user_id,
    w.year,
    w.agreement_url,
    w.portfolio_url,
    w.note,
    w.is_public,
    COALESCE(tp.prefix || tp.first_name || ' ' || tp.last_name, p.full_name, p.email)::text AS full_name,
    COALESCE(tp.position, p.position, '')::text       AS teacher_position,
    COALESCE(tp.subject_group, p.subject_group, '')::text AS subject_group,
    COALESCE(tp.profile_image_url, p.profile_image_url, '')::text AS profile_image_url
  FROM wpa_records w
  LEFT JOIN profiles p          ON p.id = w.user_id
  LEFT JOIN teacher_profiles tp ON tp.user_id = w.user_id
  ORDER BY w.year DESC, full_name;
$$;
GRANT EXECUTE ON FUNCTION public.get_all_wpa_admin() TO authenticated;


-- ============================================================
-- 10. Indexes ใหม่
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_org_pages_slug           ON public.org_pages(slug);
CREATE INDEX IF NOT EXISTS idx_org_pages_published      ON public.org_pages(is_published, sort_order);
CREATE INDEX IF NOT EXISTS idx_nav_systems_active       ON public.nav_systems(is_active, sort_order);
CREATE INDEX IF NOT EXISTS idx_wpa_user                 ON public.wpa_records(user_id, year);
CREATE INDEX IF NOT EXISTS idx_calendar_year            ON public.academic_calendar(academic_year, start_date);
CREATE INDEX IF NOT EXISTS idx_media_published          ON public.media(is_published, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_dept_teacher             ON public.teacher_department_assignments(teacher_id);
CREATE INDEX IF NOT EXISTS idx_news_pinned              ON public.news(is_pinned);


-- ============================================================
-- 11. อัปเดต get_sis_sessions → เพิ่ม sort_order + เรียงลำดับ
-- ============================================================
DROP FUNCTION IF EXISTS public.get_sis_sessions();
CREATE OR REPLACE FUNCTION public.get_sis_sessions()
RETURNS TABLE (
  id               UUID,
  academic_year    SMALLINT,
  checkpoint       SMALLINT,
  checkpoint_label TEXT,
  total_rows       INTEGER,
  sort_order       INTEGER,
  imported_at      TIMESTAMPTZ
)
LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public
AS $$
  SELECT id, academic_year, checkpoint, checkpoint_label, total_rows, sort_order, imported_at
  FROM import_sessions
  ORDER BY sort_order ASC NULLS LAST, imported_at DESC;
$$;
GRANT EXECUTE ON FUNCTION public.get_sis_sessions() TO anon, authenticated;


-- ============================================================
-- 12. ระบบ 2: เพิ่ม stats_json ใน import_sessions
-- ============================================================
ALTER TABLE public.import_sessions
  ADD COLUMN IF NOT EXISTS stats_json JSONB DEFAULT '{}'::jsonb;


-- ============================================================
-- 13. get_current_student_stats — อ่านสถิติจาก students table
--     คืน jsonb โครงสร้างเดียวกับ get_checkpoint_stats
--     ใช้โดย public pages (anon) แสดงนักเรียนปัจจุบัน
-- ============================================================
DROP FUNCTION IF EXISTS public.get_current_student_stats();
CREATE OR REPLACE FUNCTION public.get_current_student_stats()
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = public
AS $$
DECLARE
  v_total           bigint := 0;
  v_male            bigint := 0;
  v_female          bigint := 0;
  v_by_level        jsonb;
  v_by_room         jsonb;
  v_by_level_gender jsonb;
BEGIN
  SELECT COUNT(*),
    COUNT(*) FILTER (WHERE gender IN ('ชาย','ช','male')),
    COUNT(*) FILTER (WHERE gender IN ('หญิง','ญ','female'))
  INTO v_total, v_male, v_female
  FROM students WHERE is_active = true;

  SELECT jsonb_object_agg(grade_level, cnt) INTO v_by_level
  FROM (
    SELECT grade_level, COUNT(*) AS cnt
    FROM students WHERE is_active = true AND grade_level IS NOT NULL AND grade_level <> ''
    GROUP BY grade_level
  ) t;

  SELECT jsonb_object_agg(room_key, stats) INTO v_by_room
  FROM (
    SELECT grade_level || '/' || COALESCE(room::text, '0') AS room_key,
      jsonb_build_object(
        'total',  COUNT(*),
        'male',   COUNT(*) FILTER (WHERE gender IN ('ชาย','ช','male')),
        'female', COUNT(*) FILTER (WHERE gender IN ('หญิง','ญ','female'))
      ) AS stats
    FROM students
    WHERE is_active = true AND grade_level IS NOT NULL AND grade_level <> ''
    GROUP BY grade_level, room
  ) t;

  SELECT jsonb_object_agg(grade_level, stats) INTO v_by_level_gender
  FROM (
    SELECT grade_level, jsonb_build_object(
      'total',  COUNT(*),
      'male',   COUNT(*) FILTER (WHERE gender IN ('ชาย','ช','male')),
      'female', COUNT(*) FILTER (WHERE gender IN ('หญิง','ญ','female'))
    ) AS stats
    FROM students
    WHERE is_active = true AND grade_level IS NOT NULL AND grade_level <> ''
    GROUP BY grade_level
  ) t;

  RETURN jsonb_build_object(
    'total',         COALESCE(v_total, 0),
    'male',          COALESCE(v_male, 0),
    'female',        COALESCE(v_female, 0),
    'byLevel',       COALESCE(v_by_level, '{}'::jsonb),
    'byRoom',        COALESCE(v_by_room, '{}'::jsonb),
    'byLevelGender', COALESCE(v_by_level_gender, '{}'::jsonb)
  );
END;
$$;
GRANT EXECUTE ON FUNCTION public.get_current_student_stats() TO anon, authenticated;
