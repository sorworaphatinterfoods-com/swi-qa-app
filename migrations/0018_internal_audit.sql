-- Migration 0018: Internal Audit Management (ISO 22000 §9.2 — internal audit
-- programme). Audit events + findings. Major/Minor NC findings raise a real NC
-- (linked to the central NCR system) and cannot close without verification.
-- Safe: CREATE IF NOT EXISTS only.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0018_internal_audit.sql --remote

CREATE TABLE IF NOT EXISTS internal_audits (
  id           TEXT PRIMARY KEY,
  auditDate    TEXT,
  auditType    TEXT,          -- Internal | External | Certification Body | Customer
  standard     TEXT,          -- GHPs / HACCP / ISO 22000 / FSSC 22000 / อย. / Customer
  area         TEXT,          -- แผนก/พื้นที่ที่ตรวจ
  scope        TEXT,
  auditor      TEXT,
  auditee      TEXT,
  summary      TEXT,
  status       TEXT DEFAULT 'Planned', -- Planned | In Progress | Completed | Closed
  closedBy     TEXT,
  notes        TEXT,
  created      TEXT DEFAULT CURRENT_TIMESTAMP,
  modified     TEXT
);
CREATE INDEX IF NOT EXISTS idx_ia_date   ON internal_audits(auditDate);
CREATE INDEX IF NOT EXISTS idx_ia_status ON internal_audits(status);

CREATE TABLE IF NOT EXISTS audit_findings (
  id            TEXT PRIMARY KEY,
  auditRef      TEXT,          -- internal_audits.id
  findingDate   TEXT,
  area          TEXT,
  clauseRef     TEXT,          -- ข้อกำหนดที่อ้างอิง เช่น ISO 22000 8.5.4 / GHP ข้อ...
  category      TEXT,          -- Major | Minor | Observation | OFI
  description   TEXT,
  evidence      TEXT,
  owner         TEXT,          -- ผู้รับผิดชอบแก้ไข
  correctiveDue TEXT,
  ncRef         TEXT,          -- auto NC เมื่อ Major/Minor
  status        TEXT DEFAULT 'Open', -- Open | Action Submitted | Verified | Closed
  verifiedBy    TEXT,          -- ผู้ทวนสอบก่อนปิด (บังคับ)
  closedDate    TEXT,
  notes         TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP,
  modified      TEXT
);
CREATE INDEX IF NOT EXISTS idx_af_audit  ON audit_findings(auditRef);
CREATE INDEX IF NOT EXISTS idx_af_status ON audit_findings(status);
