-- ============================================================
-- PG Analytics — Supabase Migration v1.0
-- Run this entire script in the Supabase SQL Editor
-- Project: https://supabase.com → your project → SQL Editor
-- ============================================================

-- 1. Main analyses table
CREATE TABLE IF NOT EXISTS analyses (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  bl_name          TEXT        NOT NULL,
  filename         TEXT        NOT NULL,
  upload_date      TIMESTAMPTZ DEFAULT NOW(),
  period_start     DATE,
  period_end       DATE,
  brand            TEXT,
  metrics          JSONB       NOT NULL,
  forecast_data    JSONB,
  csv_storage_path TEXT,
  notes            TEXT
);

CREATE INDEX IF NOT EXISTS idx_analyses_bl_date
  ON analyses(bl_name, upload_date DESC);

-- 2. Row Level Security (open — no login required)
ALTER TABLE analyses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_all_anon" ON analyses;
CREATE POLICY "allow_all_anon" ON analyses
  FOR ALL USING (true) WITH CHECK (true);

-- 3. Storage bucket policies
-- NOTE: First create the 'csvs' bucket manually in the Supabase dashboard:
--   Storage → New Bucket → name: csvs → toggle Private ON → Create
-- Then run these policies:

DROP POLICY IF EXISTS "anon_upload_csvs" ON storage.objects;
CREATE POLICY "anon_upload_csvs" ON storage.objects
  FOR INSERT TO anon
  WITH CHECK (bucket_id = 'csvs');

DROP POLICY IF EXISTS "anon_select_csvs" ON storage.objects;
CREATE POLICY "anon_select_csvs" ON storage.objects
  FOR SELECT TO anon
  USING (bucket_id = 'csvs');
