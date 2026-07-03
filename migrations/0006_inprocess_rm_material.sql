-- Migration 0006: In-Process inspection (FM-QA-34) — add RM material columns.
-- Used at the size-reduction step where the item is still raw material
-- (RM0001/RM0002/RM0005), not yet a finished good.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0006_inprocess_rm_material.sql --remote
--
-- SQLite has no ADD COLUMN IF NOT EXISTS; these error harmlessly if the column
-- already exists — safe to ignore on re-run.
ALTER TABLE inprocess_inspections ADD COLUMN rmMaterial TEXT;
ALTER TABLE inprocess_inspections ADD COLUMN rmMaterialName TEXT;

-- Note: migration 0005 added ipqc_checks.rmMaterial when the RM dropdown was
-- first placed on the IPQC form. It was moved to the In-Process wizard instead;
-- the ipqc_checks.rmMaterial column is left in place (unused, harmless).
