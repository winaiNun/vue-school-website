-- ============================================================
-- Migration: RPC get_public_bmi_stats สำหรับหน้าสาธารณะ
-- รันใน Supabase SQL Editor
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_public_bmi_stats()
RETURNS TABLE (
  grade_level text,
  weight      text,
  height      text
)
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT
    COALESCE(s.grade_level, ss.grade_level)::text AS grade_level,
    ss.weight::text,
    ss.height::text
  FROM student_snapshots ss
  INNER JOIN (
    SELECT id
    FROM import_sessions
    ORDER BY imported_at DESC
    LIMIT 1
  ) latest ON ss.import_session_id = latest.id
  INNER JOIN students s ON s.student_code = ss.student_code
  WHERE s.is_active = true
    AND ss.weight IS NOT NULL AND ss.weight::text <> ''
    AND ss.height IS NOT NULL AND ss.height::text <> '';
$$;

GRANT EXECUTE ON FUNCTION public.get_public_bmi_stats() TO anon, authenticated;
