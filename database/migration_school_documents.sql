-- ============================================================
-- Migration: ระบบสารบัญโรงเรียน (คำสั่ง + ประกาศ)
-- รันใน Supabase SQL Editor
-- ============================================================

-- 1. ตาราง school_documents
CREATE TABLE IF NOT EXISTS public.school_documents (
  id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  type          text        NOT NULL CHECK (type IN ('order', 'announcement')),
  doc_number    text        NOT NULL,
  title         text        NOT NULL,
  issued_date   date        NOT NULL,
  drive_url     text        NOT NULL,
  department    text        NOT NULL,
  dept_other    text,
  academic_year int         NOT NULL,
  note          text,
  created_by    uuid        REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

-- 2. RLS
ALTER TABLE public.school_documents ENABLE ROW LEVEL SECURITY;

-- ทุกคนอ่านได้ (สาธารณะ)
DROP POLICY IF EXISTS "school_docs: public read" ON public.school_documents;
CREATE POLICY "school_docs: public read"
  ON public.school_documents FOR SELECT
  TO anon, authenticated
  USING (true);

-- admin + staff เพิ่ม/แก้/ลบได้
DROP POLICY IF EXISTS "school_docs: admin write" ON public.school_documents;
CREATE POLICY "school_docs: admin write"
  ON public.school_documents FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
        AND role IN ('admin', 'staff')
        AND is_approved = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
        AND role IN ('admin', 'staff')
        AND is_approved = true
    )
  );

-- 3. เพิ่ม staff role (ถ้า profiles.role มี CHECK constraint)
-- ถ้า role เป็น text ธรรมดา ไม่ต้องรันส่วนนี้
-- ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
-- ALTER TABLE public.profiles ADD CONSTRAINT profiles_role_check
--   CHECK (role IN ('admin', 'teacher', 'staff'));
