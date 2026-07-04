-- Migration 0007: backfill CREATE TABLE for two tables that were created
-- ad-hoc on D1 (via console/wrangler) but never had a committed migration —
-- surfaced by scripts/check-registry.mjs. Schemas below match the live
-- qa-factory-db definitions, so this is a no-op there (IF NOT EXISTS) and
-- makes the repo the source of truth for a clean rebuild.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0007_backfill_capa_product_labels.sql --remote

CREATE TABLE IF NOT EXISTS capa (
  id                  TEXT PRIMARY KEY,
  date                TEXT,
  ncId                TEXT,
  source              TEXT,
  capaType            TEXT,
  rootCause           TEXT,
  correctiveAction    TEXT,
  preventiveAction    TEXT,
  owner               TEXT,
  dueDate             TEXT,
  completedDate       TEXT,
  verifiedBy          TEXT,
  effectivenessCheck  TEXT,
  status              TEXT,
  created             TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_capa_status ON capa(status);
CREATE INDEX IF NOT EXISTS idx_capa_ncId   ON capa(ncId);

CREATE TABLE IF NOT EXISTS product_labels (
  id               TEXT PRIMARY KEY,
  brand            TEXT,
  nameTh           TEXT,
  nameEn           TEXT,
  foodType         TEXT,
  ingredients      TEXT,
  color            TEXT,
  odor             TEXT,
  flavorEnhancers  TEXT,
  additives        TEXT,
  preservativeUsed TEXT,
  allergens        TEXT,
  netWeight        TEXT,
  storage          TEXT,
  preparation      TEXT,
  manufacturer     TEXT,
  packagingNote    TEXT,
  fdaNumber        TEXT,
  status           TEXT,
  created          TEXT DEFAULT CURRENT_TIMESTAMP,
  labelPhoto       TEXT,
  barcodePhoto     TEXT
);
CREATE INDEX IF NOT EXISTS idx_labels_fda ON product_labels(fdaNumber);
