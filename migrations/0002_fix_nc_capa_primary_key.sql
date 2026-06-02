-- Migration 0002 — rebuild nc_capa so `id` is the PRIMARY KEY
-- ============================================================================
-- Context: the live nc_capa table in qa-factory-db had drifted from schema.sql.
-- It was created with an auto-increment surrogate key and lowercased columns:
--
--   CREATE TABLE "nc_capa" (
--     "_row_id" INTEGER PRIMARY KEY AUTOINCREMENT,
--     ... "rootcause" ... "correctiveaction" ... "duedate" ...
--     "id" TEXT,            -- <-- plain column, NOT unique
--     "created" TEXT
--   )
--
-- Because `id` had no PRIMARY KEY / UNIQUE constraint, every /api/sync upsert
--   INSERT ... ON CONFLICT(id) DO UPDATE ...
-- failed with: "ON CONFLICT clause does not match any PRIMARY KEY or UNIQUE
-- constraint (SQLITE_ERROR)". All nc_capa rows from the client silently never
-- reached D1.
--
-- This migration rebuilds nc_capa to match schema.sql (id TEXT PRIMARY KEY,
-- camelCase columns), preserving existing rows. Column names are mapped
-- case-insensitively by SQLite, so the lowercase source columns copy cleanly.
--
-- Apply with:
--   wrangler d1 execute qa-factory-db --remote --file=migrations/0002_fix_nc_capa_primary_key.sql
-- (Already applied to qa-factory-db on 2026-06-02 via the Cloudflare D1 API;
--  24 existing rows preserved.)
-- ============================================================================

CREATE TABLE IF NOT EXISTS nc_capa_new (
  id                  TEXT PRIMARY KEY,
  date                TEXT,
  type                TEXT,
  description         TEXT,
  severity            TEXT,
  source              TEXT,
  rootCause           TEXT,
  correctiveAction    TEXT,
  preventiveAction    TEXT,
  owner               TEXT,
  dueDate             TEXT,
  verifiedBy          TEXT,
  effectivenessCheck  TEXT,
  status              TEXT,
  created             TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Copy existing rows (source columns are lowercase; SQLite matches them
-- case-insensitively to the camelCase target columns).
INSERT INTO nc_capa_new
  (id, date, type, description, severity, source, rootCause, correctiveAction,
   preventiveAction, owner, dueDate, verifiedBy, effectivenessCheck, status, created)
SELECT
   id, date, type, description, severity, source, rootcause, correctiveaction,
   preventiveaction, owner, duedate, verifiedby, effectivenesscheck, status, created
FROM nc_capa;

DROP TABLE nc_capa;
ALTER TABLE nc_capa_new RENAME TO nc_capa;

CREATE INDEX IF NOT EXISTS idx_nccapa_status   ON nc_capa(status);
CREATE INDEX IF NOT EXISTS idx_nccapa_severity ON nc_capa(severity);
