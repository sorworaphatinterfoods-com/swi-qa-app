-- Migration 0009: CCP / Metal Detector Verification module.
-- Metal Detector is the plant's single CCP before packing. Test-piece + reject-
-- mechanism verification; any miss = CCP FAILURE -> affected-period HOLD +
-- CCP deviation + CAPA + QA review + block release. Reuses ccps / machines /
-- nc_capa / inprocess_hold_records; adds two new controlled-record tables.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0009_ccp_metal_detector.sql --remote

CREATE TABLE IF NOT EXISTS metal_detector_verifications (
  id             TEXT PRIMARY KEY,
  verifyDate     TEXT,
  verifyTime     TEXT,
  machine        TEXT,          -- machines.id (ref) e.g. metal_detector_unit
  line           TEXT,
  product        TEXT,          -- finished_goods.id (ref)
  productionLot  TEXT,
  checkType      TEXT,          -- START | HOURLY | END | AFTER_ADJUST
  sensitivity    TEXT,
  -- Critical limits: Fe Ø1.0 / Non-Fe Ø1.5 / SUS Ø2.0. For each test piece the
  -- detector must DETECT it and the REJECT mechanism must eject it.
  feSize         TEXT,
  feDetect       TEXT,          -- detect | no
  feReject       TEXT,          -- reject | no
  nonFeSize      TEXT,
  nonFeDetect    TEXT,
  nonFeReject    TEXT,
  susSize        TEXT,
  susDetect      TEXT,
  susReject      TEXT,
  rejectMechanism TEXT,         -- works | fails
  -- affected-period control (used on CCP failure)
  affectedFrom   TEXT,
  affectedTo     TEXT,
  affectedQty    TEXT,
  affectedNote   TEXT,
  overallResult  TEXT,          -- PASS | FAIL
  ccpDevRef      TEXT,
  holdRef        TEXT,
  evidenceNote   TEXT,
  inspector      TEXT,
  notes          TEXT,
  createdBy      TEXT,
  approvedBy     TEXT,
  approvedAt     TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_mdv_date   ON metal_detector_verifications(verifyDate);
CREATE INDEX IF NOT EXISTS idx_mdv_lot    ON metal_detector_verifications(productionLot);
CREATE INDEX IF NOT EXISTS idx_mdv_result ON metal_detector_verifications(overallResult);

CREATE TABLE IF NOT EXISTS ccp_deviations (
  id              TEXT PRIMARY KEY,
  deviationDate   TEXT,
  deviationTime   TEXT,
  ccpName         TEXT,         -- e.g. Metal Detector
  ccpRef          TEXT,         -- ccps.id (ref)
  machine         TEXT,
  line            TEXT,
  product         TEXT,
  productionLot   TEXT,
  deviationType   TEXT,         -- TEST_PIECE_FAIL | REJECT_FAIL | CL_EXCEEDED | MONITORING_MISSED
  criticalLimit   TEXT,
  measuredValue   TEXT,
  description     TEXT,
  affectedFrom    TEXT,
  affectedTo      TEXT,
  affectedQty     TEXT,
  immediateAction TEXT,
  productControl  TEXT,         -- HOLD | SEGREGATE | ...
  correction      TEXT,
  mdvRef          TEXT,
  holdRef         TEXT,
  capaRef         TEXT,
  qaReviewed      TEXT DEFAULT 'no',
  qaReviewer      TEXT,
  qaReviewDate    TEXT,
  disposition     TEXT,
  status          TEXT DEFAULT 'Open', -- Open | Closed
  closedBy        TEXT,
  closedAt        TEXT,
  notes           TEXT,
  created         TEXT DEFAULT CURRENT_TIMESTAMP,
  modified        TEXT
);
CREATE INDEX IF NOT EXISTS idx_ccpdev_status ON ccp_deviations(status);
CREATE INDEX IF NOT EXISTS idx_ccpdev_lot    ON ccp_deviations(productionLot);
CREATE INDEX IF NOT EXISTS idx_ccpdev_date   ON ccp_deviations(deviationDate);
