-- Migration 0004: Add missing tables — lot_genealogy, incoming_inspections,
-- ipqc_checks, inprocess_hold_records, inprocess_deviation_logs
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0004_add_lot_genealogy_incoming_ipqc.sql --remote

CREATE TABLE IF NOT EXISTS lot_genealogy (
  id              TEXT PRIMARY KEY,
  fgProduct       TEXT,
  fgLot           TEXT,
  productionDate  TEXT,
  machine         TEXT,
  operator        TEXT,
  rmLots          TEXT,            -- JSON array [{code,name,lot,supplier,qty}]
  ingredientLots  TEXT,            -- JSON array [{code,name,lot,supplier}]
  packagingLots   TEXT,            -- JSON array [{code,name,lot,supplier}]
  distribution    TEXT,            -- JSON array [{customer,invoiceNo,qty,date}]
  notes           TEXT,
  status          TEXT DEFAULT 'Active',
  created         TEXT DEFAULT CURRENT_TIMESTAMP,
  modified        TEXT
);
CREATE INDEX IF NOT EXISTS idx_lg_fgLot     ON lot_genealogy(fgLot);
CREATE INDEX IF NOT EXISTS idx_lg_fgProduct ON lot_genealogy(fgProduct);

CREATE TABLE IF NOT EXISTS incoming_inspections (
  id               TEXT PRIMARY KEY,
  receivedDate     TEXT,
  inspector        TEXT,
  supplierName     TEXT,
  truckPlate       TEXT,
  arrivalTime      TEXT,
  truckTemp        TEXT,
  truckTempPass    TEXT,
  vc_clean         TEXT,
  vc_noOdor        TEXT,
  vc_noRust        TEXT,
  vc_noNonFood     TEXT,
  vc_arranged      TEXT,
  items            TEXT,           -- JSON array [{rmName,lotSupplier,internalLot,qty,mfg,exp,t1,t2,t3,coa,result}]
  qc_pr0016        TEXT,
  qc_pr0017        TEXT,
  qc_pr0018        TEXT,
  qc_pr0020        TEXT,
  docDeliveryNote  TEXT,
  docCoa           TEXT,
  docVet           TEXT,
  approvedSupplier TEXT,
  inspectionResult TEXT,
  carNo            TEXT,
  notes            TEXT,
  status           TEXT DEFAULT 'Active',
  created          TEXT DEFAULT CURRENT_TIMESTAMP,
  modified         TEXT
);
CREATE INDEX IF NOT EXISTS idx_iqc_date     ON incoming_inspections(receivedDate);
CREATE INDEX IF NOT EXISTS idx_iqc_supplier ON incoming_inspections(supplierName);
CREATE INDEX IF NOT EXISTS idx_iqc_result   ON incoming_inspections(inspectionResult);

CREATE TABLE IF NOT EXISTS ipqc_checks (
  id            TEXT PRIMARY KEY,
  checkDate     TEXT,
  checkTime     TEXT,
  shift         TEXT,
  process       TEXT,
  lot           TEXT,
  product       TEXT,
  inspector     TEXT,
  weightSpec    TEXT,
  weightSamples TEXT,             -- JSON array [{sticks,weightPerStick,totalWeight,note}]
  weightResult  TEXT,
  tempSpec      TEXT,
  tempSamples   TEXT,             -- JSON array [{sampleId,temp,note}]
  tempResult    TEXT,
  visualColor   TEXT,
  visualOdor    TEXT,
  visualTexture TEXT,
  foreignMatter TEXT,
  visualResult  TEXT,
  labelCorrect  TEXT,
  sealIntact    TEXT,
  labelResult   TEXT,
  overallResult TEXT,
  ncRef         TEXT,
  holdRef       TEXT,
  evidenceNote  TEXT,
  notes         TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP,
  modified      TEXT
);
CREATE INDEX IF NOT EXISTS idx_ipqc_date   ON ipqc_checks(checkDate);
CREATE INDEX IF NOT EXISTS idx_ipqc_lot    ON ipqc_checks(lot);
CREATE INDEX IF NOT EXISTS idx_ipqc_result ON ipqc_checks(overallResult);

CREATE TABLE IF NOT EXISTS inprocess_hold_records (
  id              TEXT PRIMARY KEY,
  holdDate        TEXT,
  lotNo           TEXT,
  product         TEXT,
  process         TEXT,
  quantity        TEXT,
  reason          TEXT,
  holdLocation    TEXT,
  ipqcRef         TEXT,
  ncRef           TEXT,
  issuedBy        TEXT,
  approvedBy      TEXT,
  disposition     TEXT DEFAULT 'Pending',
  dispositionDate TEXT,
  dispositionBy   TEXT,
  status          TEXT DEFAULT 'Open',
  notes           TEXT,
  created         TEXT DEFAULT CURRENT_TIMESTAMP,
  modified        TEXT
);
CREATE INDEX IF NOT EXISTS idx_hold_status ON inprocess_hold_records(status);
CREATE INDEX IF NOT EXISTS idx_hold_date   ON inprocess_hold_records(holdDate);

CREATE TABLE IF NOT EXISTS inprocess_deviation_logs (
  id                TEXT PRIMARY KEY,
  deviationDate     TEXT,
  lotNo             TEXT,
  product           TEXT,
  process           TEXT,
  deviationType     TEXT,
  description       TEXT,
  detectedBy        TEXT,
  ipqcRef           TEXT,
  holdRef           TEXT,
  dispositionAction TEXT,
  capaRef           TEXT,
  rootCause         TEXT,
  status            TEXT DEFAULT 'Open',
  closedDate        TEXT,
  notes             TEXT,
  created           TEXT DEFAULT CURRENT_TIMESTAMP,
  modified          TEXT
);
CREATE INDEX IF NOT EXISTS idx_dev_status ON inprocess_deviation_logs(status);
CREATE INDEX IF NOT EXISTS idx_dev_date   ON inprocess_deviation_logs(deviationDate);
