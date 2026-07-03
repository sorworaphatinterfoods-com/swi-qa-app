-- Migration 0005: Split incoming inspection by material type
--   FM-QA-31 ของสด (RM)        -> incoming_inspections  (existing)
--   FM-QA-32 เครื่องปรุง (DM)   -> incoming_seasoning     (new)
--   FM-QA-33 บรรจุภัณฑ์ (PM)    -> incoming_packaging     (new)
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0005_split_incoming_seasoning_packaging.sql --remote

CREATE TABLE IF NOT EXISTS incoming_seasoning (
  id               TEXT PRIMARY KEY,
  receivedDate     TEXT,
  inspector        TEXT,
  supplierName     TEXT,
  truckPlate       TEXT,
  arrivalTime      TEXT,
  vc_clean         TEXT,
  vc_noOdor        TEXT,
  vc_noNonFood     TEXT,
  vc_arranged      TEXT,
  items            TEXT,           -- JSON array [{code,name,lotSupplier,internalLot,qty,mfg,exp,coa,result}]
  qc_pr0016        TEXT,
  qc_pr0017        TEXT,
  qc_pr0018        TEXT,
  qc_pr0019        TEXT,
  qc_pr0020        TEXT,
  docDeliveryNote  TEXT,
  docCoa           TEXT,
  approvedSupplier TEXT,
  inspectionResult TEXT,
  carNo            TEXT,
  notes            TEXT,
  status           TEXT DEFAULT 'Active',
  created          TEXT DEFAULT CURRENT_TIMESTAMP,
  modified         TEXT
);
CREATE INDEX IF NOT EXISTS idx_iqd_date     ON incoming_seasoning(receivedDate);
CREATE INDEX IF NOT EXISTS idx_iqd_supplier ON incoming_seasoning(supplierName);
CREATE INDEX IF NOT EXISTS idx_iqd_result   ON incoming_seasoning(inspectionResult);

CREATE TABLE IF NOT EXISTS incoming_packaging (
  id               TEXT PRIMARY KEY,
  receivedDate     TEXT,
  inspector        TEXT,
  supplierName     TEXT,
  truckPlate       TEXT,
  arrivalTime      TEXT,
  vc_clean         TEXT,
  vc_noNonFood     TEXT,
  vc_arranged      TEXT,
  items            TEXT,           -- JSON array [{code,name,lotSupplier,internalLot,qty,dimension,sampleSize,defects,result}]
  qc_pr0016        TEXT,
  qc_pr0017        TEXT,
  qc_pr0019        TEXT,
  qc_pr0020        TEXT,
  aqlLevel         TEXT,
  aqlResult        TEXT,
  docDeliveryNote  TEXT,
  docSpec          TEXT,
  approvedSupplier TEXT,
  inspectionResult TEXT,
  carNo            TEXT,
  notes            TEXT,
  status           TEXT DEFAULT 'Active',
  created          TEXT DEFAULT CURRENT_TIMESTAMP,
  modified         TEXT
);
CREATE INDEX IF NOT EXISTS idx_iqp_date     ON incoming_packaging(receivedDate);
CREATE INDEX IF NOT EXISTS idx_iqp_supplier ON incoming_packaging(supplierName);
CREATE INDEX IF NOT EXISTS idx_iqp_result   ON incoming_packaging(inspectionResult);

-- IPQC: add RM material column (used at size-reduction step where the item is
-- still raw material, not yet a finished good). SQLite has no ADD COLUMN IF NOT
-- EXISTS; this errors harmlessly if the column already exists — safe to ignore.
ALTER TABLE ipqc_checks ADD COLUMN rmMaterial TEXT;
