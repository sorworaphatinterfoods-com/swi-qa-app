-- Migration 0020: Supplier Documents — structured document control per supplier
-- (extends the existing flat gmpExpiry/halalExpiry fields with a proper
-- per-document register: type, required/critical, expiry, status, QA approval).
-- Critical document expired/missing → supplier cannot be fully APPROVED.
-- Reuses the existing suppliers/supplier_scars/supplier_evaluations tables — does
-- NOT duplicate them. Safe: CREATE IF NOT EXISTS only.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0020_supplier_documents.sql --remote

CREATE TABLE IF NOT EXISTS supplier_documents (
  id           TEXT PRIMARY KEY,
  supplier     TEXT,          -- suppliers.id
  docType      TEXT,          -- GMP / HACCP / ISO / Halal / COA / ร.4 / SDS / ...
  required     TEXT,          -- yes | no
  critical     TEXT,          -- yes | no (critical → block approval when expired/missing)
  fileUrl      TEXT,          -- R2 / link
  issueDate    TEXT,
  expiryDate   TEXT,
  reviewDate   TEXT,
  status       TEXT DEFAULT 'MISSING', -- MISSING | SUBMITTED | UNDER_REVIEW | APPROVED | EXPIRED | REJECTED
  approvedBy   TEXT,
  approvedAt   TEXT,
  remarks      TEXT,
  created      TEXT DEFAULT CURRENT_TIMESTAMP,
  modified     TEXT
);
CREATE INDEX IF NOT EXISTS idx_supdoc_supplier ON supplier_documents(supplier, status);
CREATE INDEX IF NOT EXISTS idx_supdoc_expiry   ON supplier_documents(expiryDate);
