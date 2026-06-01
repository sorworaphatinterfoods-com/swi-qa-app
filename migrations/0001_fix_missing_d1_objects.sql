-- Migration 0001 — fix objects missing from the live qa-factory-db
-- ============================================================================
-- Context: the live D1 database (qa-factory-db) was missing two transactional
-- tables and two contact columns that schema.sql already defined. As a result
-- in-process & transport inspection records silently failed to sync to D1
-- (the error was swallowed in /api/sync), and the contact form INSERT always
-- failed because it referenced company/position columns that did not exist.
--
-- This migration is additive and safe to run repeatedly. Apply with:
--   wrangler d1 execute qa-factory-db --remote --file=migrations/0001_fix_missing_d1_objects.sql
-- (Already applied to qa-factory-db on 2026-06-01.)
-- ============================================================================

-- IN-PROCESS INSPECTIONS (FM-QA-32)
CREATE TABLE IF NOT EXISTS inprocess_inspections (
  id            TEXT PRIMARY KEY,
  docNo         TEXT DEFAULT 'FM-QA-32',
  date          TEXT,
  product       TEXT,
  productName   TEXT,
  batch         TEXT,
  line          TEXT,
  shift         TEXT,
  inspector     TEXT,
  note          TEXT,
  processes     TEXT,
  overallResult TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP,
  modified      TEXT
);
CREATE INDEX IF NOT EXISTS idx_ipi_date   ON inprocess_inspections(date);
CREATE INDEX IF NOT EXISTS idx_ipi_result ON inprocess_inspections(overallResult);
CREATE INDEX IF NOT EXISTS idx_ipi_batch  ON inprocess_inspections(batch);

-- TRANSPORT INSPECTIONS (FM-TS-01)
CREATE TABLE IF NOT EXISTS transport_inspections (
  id            TEXT PRIMARY KEY,
  date          TEXT,
  plateNo       TEXT,
  transportType TEXT,
  driver        TEXT,
  chkClean      INTEGER,
  chkPest       INTEGER,
  chkHazard     INTEGER,
  chkRust       INTEGER,
  chkStack      INTEGER,
  tempCold      REAL,
  tempMethod    TEXT,
  docRoNo       INTEGER,
  docRo3        INTEGER,
  product       TEXT,
  lotNo         TEXT,
  quantity      REAL,
  destination   TEXT,
  invoiceNo     TEXT,
  result        TEXT,
  remarks       TEXT,
  inspector     TEXT,
  verifier      TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_ts_date   ON transport_inspections(date);
CREATE INDEX IF NOT EXISTS idx_ts_result ON transport_inspections(result);
CREATE INDEX IF NOT EXISTS idx_ts_plate  ON transport_inspections(plateNo);

-- CONTACT SUBMISSIONS — columns referenced by /api/contact
-- D1/SQLite has no "ADD COLUMN IF NOT EXISTS"; if a column already exists the
-- statement errors harmlessly — ignore "duplicate column name".
ALTER TABLE contact_submissions ADD COLUMN company  TEXT;
ALTER TABLE contact_submissions ADD COLUMN position TEXT;
