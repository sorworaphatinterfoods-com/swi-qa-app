-- Migration 0024: Hazard Analysis / Risk Assessment (HACCP Codex Principle 1).
-- Per process step: identify B/C/P/Allergen hazards, score risk (likelihood ×
-- severity), decide significance, define a control measure, and run the Codex
-- decision tree (Q1–Q4) to classify PRP / OPRP / CCP with a critical limit.
-- Links to the processes master and (for a CCP) the ccps master.
-- Safe: CREATE IF NOT EXISTS only.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0024_hazard_analysis.sql --remote

CREATE TABLE IF NOT EXISTS hazard_analysis (
  id              TEXT PRIMARY KEY,
  analysisDate    TEXT,
  process         TEXT,          -- processes.id (ref)
  processStep     TEXT,          -- ขั้นตอน
  hazardType      TEXT,          -- BIO | CHE | PHY | ALL
  hazard          TEXT,          -- อันตรายที่ระบุ
  source          TEXT,          -- แหล่งที่มา/สาเหตุ
  likelihood      TEXT,          -- 1..5
  severity        TEXT,          -- 1..5
  riskScore       TEXT,          -- likelihood × severity (auto)
  riskLevel       TEXT,          -- LOW | MEDIUM | HIGH | CRITICAL (auto)
  significant     TEXT,          -- yes | no
  controlMeasure  TEXT,
  q1              TEXT,          -- Codex decision tree Q1..Q4
  q2              TEXT,
  q3              TEXT,
  q4              TEXT,
  controlType     TEXT,          -- PRP | OPRP | CCP
  criticalLimit   TEXT,          -- when CCP
  monitoring      TEXT,
  ccpRef          TEXT,          -- ccps.id (ref, when CCP)
  justification   TEXT,
  assessor        TEXT,
  approvedBy      TEXT,
  status          TEXT DEFAULT 'Active', -- Active | Review | Retired
  notes           TEXT,
  created         TEXT DEFAULT CURRENT_TIMESTAMP,
  modified        TEXT
);
CREATE INDEX IF NOT EXISTS idx_ha_process ON hazard_analysis(process, status);
CREATE INDEX IF NOT EXISTS idx_ha_type    ON hazard_analysis(hazardType, controlType);
