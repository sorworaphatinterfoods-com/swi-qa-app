-- Migration 0003 — add rm_receiving and pest_control tables
-- ============================================================================
-- Context: two newer form modules store their data under client DB keys that
-- had no matching D1 table and were missing from the /api/sync keyMap, so their
-- records never reached D1:
--
--   rmReceiving  (FM-QA-31) — raw-material receiving: one truck header +
--                a nested materials[] array (lot / qty / 3 core-temp rounds)
--   pestControl  (FM-EN-02) — pest-control monitoring: one area header +
--                a nested points[] array (device points)
--
-- Both follow the same shape as inprocess_inspections (header columns + one
-- JSON column for the nested array). worker.js serialises the array via
-- normalize() (JSON.stringify) and re-hydrates it on read via deserializeRow()
-- using the `jsonCols` config.
--
-- Apply with:
--   wrangler d1 execute qa-factory-db --remote --file=migrations/0003_add_rm_receiving_and_pest_control.sql
-- (Already applied to qa-factory-db on 2026-06-03 via the Cloudflare D1 API.)
-- ============================================================================

-- RAW MATERIAL RECEIVING (FM-QA-31)
CREATE TABLE IF NOT EXISTS rm_receiving (
  id             TEXT PRIMARY KEY,
  docNo          TEXT DEFAULT 'FM-QA-31',
  date           TEXT,
  supplier       TEXT,
  truckPlate     TEXT,
  truckCondition TEXT,
  truckTemp      REAL,
  inspector      TEXT,
  note           TEXT,
  materials      TEXT,          -- JSON array of received materials
  overallResult  TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_rmrcv_date   ON rm_receiving(date);
CREATE INDEX IF NOT EXISTS idx_rmrcv_result ON rm_receiving(overallResult);
CREATE INDEX IF NOT EXISTS idx_rmrcv_sup    ON rm_receiving(supplier);

-- PEST CONTROL (FM-EN-02)
CREATE TABLE IF NOT EXISTS pest_control (
  id            TEXT PRIMARY KEY,
  docNo         TEXT DEFAULT 'FM-EN-02',
  date          TEXT,
  area          TEXT,
  inspector     TEXT,
  note          TEXT,
  points        TEXT,           -- JSON array of inspected device points
  overallResult TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_pest_date   ON pest_control(date);
CREATE INDEX IF NOT EXISTS idx_pest_result ON pest_control(overallResult);
CREATE INDEX IF NOT EXISTS idx_pest_area   ON pest_control(area);
