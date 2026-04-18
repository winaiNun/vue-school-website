-- ============================================================
-- Migration: เพิ่ม show_public_bmi ใน school_config
-- รันใน Supabase SQL Editor
-- ============================================================

ALTER TABLE public.school_config
  ADD COLUMN IF NOT EXISTS show_public_bmi BOOLEAN DEFAULT false;
