-- Migration 0025: close GHP/HACCP documentation gaps found in the pre-audit checklist.
-- Adds four synced tables (registry-wired): maintenance (GHP การบำรุงรักษา),
-- chemical control (GHP การควบคุมสารเคมี), product descriptions (Codex/HACCP),
-- and the HACCP document register (Team appointment / ToR / Flow / Plan / Verification).
-- Safe: CREATE IF NOT EXISTS only.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0025_ghp_gaps.sql --remote

-- GHP §การบำรุงรักษา — work orders + preventive maintenance (combined; maintType splits them)
CREATE TABLE IF NOT EXISTS ghp_maintenance (
  id              TEXT PRIMARY KEY,
  reportedDate    TEXT,
  maintType       TEXT,          -- PREVENTIVE | BREAKDOWN | CORRECTIVE | IMPROVEMENT
  asset           TEXT,          -- machines.id (ref)
  area            TEXT,
  problem         TEXT,
  priority        TEXT,          -- LOW | MEDIUM | HIGH | URGENT
  reportedBy      TEXT,
  assignedTo      TEXT,
  actionTaken     TEXT,
  partsUsed       TEXT,
  downtimeHrs     TEXT,
  foodSafetyImpact TEXT,         -- yes | no
  cleanedAfter    TEXT,          -- yes | no | na  (verified clean before restart)
  status          TEXT DEFAULT 'Open', -- Open | In Progress | Done | Closed
  completedDate   TEXT,
  nextPmDue       TEXT,          -- for PREVENTIVE
  verifiedBy      TEXT,
  ncRef           TEXT,
  notes           TEXT,
  created         TEXT DEFAULT CURRENT_TIMESTAMP,
  modified        TEXT
);
CREATE INDEX IF NOT EXISTS idx_maint_asset ON ghp_maintenance(asset, status);
CREATE INDEX IF NOT EXISTS idx_maint_pm    ON ghp_maintenance(nextPmDue);

-- GHP §การควบคุมสารเคมี — chemical storage/labelling/SDS/usage checklist
CREATE TABLE IF NOT EXISTS ghp_chemical_control (
  id              TEXT PRIMARY KEY,
  date            TEXT,
  area            TEXT,
  chemical        TEXT,          -- chemicals.id (ref) or free text
  inspector       TEXT,
  labelClear      TEXT,          -- pass | fail | na  (per item)
  sdsAvailable    TEXT,
  segregated      TEXT,
  containerOk     TEXT,
  foodContactSep  TEXT,
  authorizedOnly  TEXT,
  expiryOk        TEXT,
  spillKitReady   TEXT,
  usageLogged     TEXT,
  result          TEXT DEFAULT 'PASS', -- PASS | FAIL
  correctiveAction TEXT,
  ncRef           TEXT,
  notes           TEXT,
  created         TEXT DEFAULT CURRENT_TIMESTAMP,
  modified        TEXT
);
CREATE INDEX IF NOT EXISTS idx_chemctl_area ON ghp_chemical_control(area, result);

-- Codex/HACCP Product Description — product identity, composition, intended use
CREATE TABLE IF NOT EXISTS product_descriptions (
  id                   TEXT PRIMARY KEY,
  issueDate            TEXT,
  product              TEXT,     -- finished_goods.id (ref)
  nameTh               TEXT,
  nameEn               TEXT,
  category             TEXT,
  composition          TEXT,     -- ingredients + additives
  allergens            TEXT,
  packaging            TEXT,
  netWeight            TEXT,
  storageCondition     TEXT,
  shelfLife            TEXT,
  distributionMethod   TEXT,
  intendedUse          TEXT,
  preparationBeforeUse TEXT,
  targetConsumer       TEXT,     -- incl. vulnerable groups
  labellingInstruction TEXT,
  microChemStandard    TEXT,
  revision             TEXT,
  approvedBy           TEXT,
  approvedDate         TEXT,
  status               TEXT DEFAULT 'Active', -- Draft | Active | Superseded
  notes                TEXT,
  created              TEXT DEFAULT CURRENT_TIMESTAMP,
  modified             TEXT
);
CREATE INDEX IF NOT EXISTS idx_proddesc_product ON product_descriptions(product, status);

-- HACCP Document Register — links the HACCP plan documents (kept in DCC) to the QA app
CREATE TABLE IF NOT EXISTS haccp_documents (
  id              TEXT PRIMARY KEY,
  docType         TEXT,          -- TEAM | TOR | PRODUCT_DESC | FLOW | HAZARD | PLAN | VERIFICATION | VALIDATION | OTHER
  title           TEXT,
  docNo           TEXT,
  revision        TEXT,
  relatedProduct  TEXT,          -- finished_goods.id or scope
  effectiveDate   TEXT,
  reviewDate      TEXT,
  owner           TEXT,
  approvedBy      TEXT,
  fileUrl         TEXT,          -- link to DCC / file
  status          TEXT DEFAULT 'Active', -- Draft | Approved | Active | Obsolete
  notes           TEXT,
  created         TEXT DEFAULT CURRENT_TIMESTAMP,
  modified        TEXT
);
CREATE INDEX IF NOT EXISTS idx_haccpdoc_type ON haccp_documents(docType, status);
