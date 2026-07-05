-- Migration 0011: Supplier Approval & Evaluation.
-- Turn the suppliers master from a name list into a controlled approval lifecycle
-- (rule 13). SAFE MIGRATION for suppliers: ADD COLUMN only (no rename / no PK
-- change) so existing 34 supplier rows are preserved. Plus 3 new transactional
-- tables for periodic evaluation, SCAR, and audit.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0011_supplier_approval.sql --remote

ALTER TABLE suppliers ADD COLUMN approvedScope      TEXT;
ALTER TABLE suppliers ADD COLUMN approvedMaterials  TEXT;
ALTER TABLE suppliers ADD COLUMN gmpExpiry          TEXT;
ALTER TABLE suppliers ADD COLUMN halalExpiry        TEXT;
ALTER TABLE suppliers ADD COLUMN coaExpiry          TEXT;
ALTER TABLE suppliers ADD COLUMN requiredDocs       TEXT;
ALTER TABLE suppliers ADD COLUMN qaReviewed         TEXT;
ALTER TABLE suppliers ADD COLUMN qaReviewer         TEXT;
ALTER TABLE suppliers ADD COLUMN approvedBy         TEXT;
ALTER TABLE suppliers ADD COLUMN approvedDate       TEXT;
ALTER TABLE suppliers ADD COLUMN reapprovalDate     TEXT;
ALTER TABLE suppliers ADD COLUMN nextEvaluationDate TEXT;
ALTER TABLE suppliers ADD COLUMN performanceGrade   TEXT;

-- Periodic supplier evaluation / scoring / reapproval decision.
CREATE TABLE IF NOT EXISTS supplier_evaluations (
  id            TEXT PRIMARY KEY,
  evalDate      TEXT,
  supplier      TEXT,          -- suppliers.id (ref)
  period        TEXT,
  qualityScore  TEXT,
  deliveryScore TEXT,
  docScore      TEXT,
  responseScore TEXT,
  totalScore    TEXT,
  grade         TEXT,          -- A|B|C|D
  decision      TEXT,          -- APPROVED|CONDITIONAL|SUSPENDED|DISQUALIFIED
  evaluator     TEXT,
  qaApproved    TEXT DEFAULT 'no',
  nextDue       TEXT,
  notes         TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP,
  modified      TEXT
);
CREATE INDEX IF NOT EXISTS idx_seval_supplier ON supplier_evaluations(supplier);
CREATE INDEX IF NOT EXISTS idx_seval_date     ON supplier_evaluations(evalDate);

-- Supplier Corrective Action Request (SCAR) / supplier NC.
CREATE TABLE IF NOT EXISTS supplier_scars (
  id               TEXT PRIMARY KEY,
  scarDate         TEXT,
  supplier         TEXT,
  issue            TEXT,
  ncRef            TEXT,
  severity         TEXT,
  requiredAction   TEXT,
  dueDate          TEXT,
  supplierResponse TEXT,
  rootCause        TEXT,
  correctiveAction TEXT,
  effectiveness    TEXT,        -- PENDING|EFFECTIVE|NOT_EFFECTIVE
  verifiedBy       TEXT,
  status           TEXT DEFAULT 'Open', -- Open|Closed
  closedBy         TEXT,
  closedAt         TEXT,
  notes            TEXT,
  created          TEXT DEFAULT CURRENT_TIMESTAMP,
  modified         TEXT
);
CREATE INDEX IF NOT EXISTS idx_scar_supplier ON supplier_scars(supplier);
CREATE INDEX IF NOT EXISTS idx_scar_status   ON supplier_scars(status);

-- Supplier audit records.
CREATE TABLE IF NOT EXISTS supplier_audits (
  id             TEXT PRIMARY KEY,
  auditDate      TEXT,
  supplier       TEXT,
  auditType      TEXT,          -- ONSITE|DESKTOP|SECOND_PARTY
  scope          TEXT,
  score          TEXT,
  result         TEXT,          -- PASS|CONDITIONAL|FAIL
  majorFindings  TEXT,
  minorFindings  TEXT,
  findings       TEXT,
  auditor        TEXT,
  capaRef        TEXT,
  nextAuditDate  TEXT,
  status         TEXT DEFAULT 'Open',
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_saudit_supplier ON supplier_audits(supplier);
CREATE INDEX IF NOT EXISTS idx_saudit_date     ON supplier_audits(auditDate);
