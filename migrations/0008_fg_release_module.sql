-- Migration 0008: Finished Goods Release (FG Release) module.
-- Final QA inspection, product HOLD, release authorization + traceability
-- before finished goods leave for warehouse / dispatch. Extends the existing
-- system; reuses finished_goods / ccps / haccp_records / nc_capa / capa etc.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0008_fg_release_module.sql --remote

-- FG LOT MASTER — each finished-goods lot + its lifecycle status.
CREATE TABLE IF NOT EXISTS fg_lots (
  id                 TEXT PRIMARY KEY,
  fgLot              TEXT,
  product            TEXT,          -- finished_goods.id (ref)
  productCode        TEXT,
  productionLot      TEXT,
  productionDate     TEXT,
  expiryDate         TEXT,
  line               TEXT,
  shift              TEXT,
  quantity           TEXT,
  unit               TEXT,
  packagingFormat    TEXT,
  storageCondition   TEXT,
  status             TEXT DEFAULT 'PENDING_INSPECTION', -- PENDING_INSPECTION|UNDER_INSPECTION|HOLD|APPROVED|REJECTED|RELEASED|VOID
  traceabilityStatus TEXT DEFAULT 'INCOMPLETE',         -- INCOMPLETE|COMPLETE
  notes              TEXT,
  createdBy          TEXT,
  approvedBy         TEXT,
  approvedAt         TEXT,
  created            TEXT DEFAULT CURRENT_TIMESTAMP,
  modified           TEXT
);
CREATE INDEX IF NOT EXISTS idx_fglot_status ON fg_lots(status);
CREATE INDEX IF NOT EXISTS idx_fglot_lot    ON fg_lots(fgLot);
CREATE INDEX IF NOT EXISTS idx_fglot_date   ON fg_lots(productionDate);

-- FG RELEASE INSPECTION — the final QA inspection record (condition / temperature /
-- weight / packaging / label / lab / release-readiness). Sample arrays stored as JSON.
CREATE TABLE IF NOT EXISTS fg_release_inspections (
  id               TEXT PRIMARY KEY,
  inspectDate      TEXT,
  inspectTime      TEXT,
  product          TEXT,
  productCode      TEXT,
  fgLot            TEXT,
  productionLot    TEXT,
  productionDate   TEXT,
  expiryDate       TEXT,
  line             TEXT,
  shift            TEXT,
  quantity         TEXT,
  unit             TEXT,
  inspector        TEXT,
  -- product condition
  appearance       TEXT,
  color            TEXT,
  odor             TEXT,
  texture          TEXT,
  frozenCondition  TEXT,
  foreignMatter    TEXT,
  integrity        TEXT,
  -- temperature (spec loaded from active revision; default <= -18 C)
  tempSpec         TEXT,
  surfaceTemp      TEXT,
  tempSamples      TEXT,          -- JSON [{temp}]
  tempResult       TEXT,
  -- weight
  weightTarget     TEXT,
  weightLSL        TEXT,
  weightUSL        TEXT,
  weightSamples    TEXT,          -- JSON [{weight}]
  weightPerStick   TEXT,
  sticks           TEXT,
  netWeight        TEXT,
  grossWeight      TEXT,
  weightResult     TEXT,
  -- packaging
  pkgIntegrity     TEXT,
  vacuumCondition  TEXT,
  sealCondition    TEXT,
  leakage          TEXT,
  damage           TEXT,
  pkgContamination TEXT,
  pkgMaterial      TEXT,
  pkgRevision      TEXT,
  packagingResult  TEXT,
  -- label
  lblProductName   TEXT,
  lblBrand         TEXT,
  lblFda           TEXT,
  lblLot           TEXT,
  lblMfg           TEXT,
  lblExp           TEXT,
  lblNetWeight     TEXT,
  lblStorage       TEXT,
  lblAllergen      TEXT,
  lblCooking       TEXT,
  lblBarcode       TEXT,
  lblRevision      TEXT,
  labelResult      TEXT,
  -- lab / micro
  labStatus        TEXT DEFAULT 'NOT_REQUIRED', -- NOT_REQUIRED|PENDING|PASS|FAIL
  -- release readiness gate (PASS|PENDING|BLOCKED each)
  chkInprocess     TEXT,
  chkInprocessHold TEXT,
  chkCcp           TEXT,
  chkMetalDetector TEXT,
  chkCcpDeviation  TEXT,
  chkProductHold   TEXT,
  chkLab           TEXT,
  chkPackaging     TEXT,
  chkLabel         TEXT,
  chkTraceability  TEXT,
  -- outcome
  overallResult    TEXT,          -- PASS|HOLD|FAIL
  releaseStatus    TEXT,          -- PENDING|READY|BLOCKED
  ncRef            TEXT,
  holdRef          TEXT,
  evidenceNote     TEXT,
  notes            TEXT,
  createdBy        TEXT,
  approvedBy       TEXT,
  approvedAt       TEXT,
  created          TEXT DEFAULT CURRENT_TIMESTAMP,
  modified         TEXT
);
CREATE INDEX IF NOT EXISTS idx_fgr_date   ON fg_release_inspections(inspectDate);
CREATE INDEX IF NOT EXISTS idx_fgr_lot    ON fg_release_inspections(fgLot);
CREATE INDEX IF NOT EXISTS idx_fgr_result ON fg_release_inspections(overallResult);

-- FG HOLD — quarantine + disposition workflow for finished goods.
CREATE TABLE IF NOT EXISTS fg_hold_records (
  id              TEXT PRIMARY KEY,
  holdDate        TEXT,
  fgLot           TEXT,
  product         TEXT,
  quantity        TEXT,
  reason          TEXT,
  holdLocation    TEXT,
  holdBy          TEXT,
  fgrRef          TEXT,
  ncRef           TEXT,
  investigation   TEXT,
  evidence        TEXT,
  disposition     TEXT DEFAULT 'PENDING', -- PENDING|RELEASE|ACCEPT_BY_CONCESSION|REWORK|REPACK|RELABEL|RETURN|REJECT|DESTROY
  dispositionBy   TEXT,
  dispositionDate TEXT,
  status          TEXT DEFAULT 'OPEN',    -- OPEN|CLOSED
  notes           TEXT,
  created         TEXT DEFAULT CURRENT_TIMESTAMP,
  modified        TEXT
);
CREATE INDEX IF NOT EXISTS idx_fgh_status ON fg_hold_records(status);
CREATE INDEX IF NOT EXISTS idx_fgh_lot    ON fg_hold_records(fgLot);

-- FG RELEASE DECISION — authorized QA release authorization (immutable audit).
CREATE TABLE IF NOT EXISTS fg_release_decisions (
  id                 TEXT PRIMARY KEY,
  decisionDate       TEXT,
  fgLot              TEXT,
  product            TEXT,
  fgrRef             TEXT,
  decision           TEXT,        -- APPROVED|HOLD|REJECTED|CONDITIONAL_RELEASE
  decidedBy          TEXT,
  decidedRole        TEXT,        -- QA Supervisor|QA Manager|Authorized QA Approver
  conditionalReason  TEXT,
  riskAssessment     TEXT,
  authorization      TEXT,
  evidence           TEXT,
  eSignature         TEXT,        -- e-signature placeholder
  destination        TEXT,        -- warehouse|customer|dispatch
  notes              TEXT,
  created            TEXT DEFAULT CURRENT_TIMESTAMP,
  modified           TEXT
);
CREATE INDEX IF NOT EXISTS idx_fgd_lot      ON fg_release_decisions(fgLot);
CREATE INDEX IF NOT EXISTS idx_fgd_decision ON fg_release_decisions(decision);
