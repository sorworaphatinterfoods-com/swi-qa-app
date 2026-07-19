-- Migration 0020: Supplier Document Register — structured document control per
-- supplier (extends the flat gmpExpiry/halalExpiry fields with a proper per-document
-- register: type, required/critical, expiry, status, QA approval).
-- Critical document expired/missing → supplier cannot be fully APPROVED.
--
-- NOTE: table is named supplier_doc_register (NOT supplier_documents) on purpose —
-- an unrelated supplier_documents table already exists on D1 from an external tool
-- with an incompatible schema (no `supplier` column), which made the original index
-- creation fail. This clean, app-owned table sidesteps that collision without
-- touching/dropping the orphan. Not yet wired to the UI (Gap 2 pending).
-- Safe: CREATE IF NOT EXISTS only.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0020_supplier_documents.sql --remote

CREATE TABLE IF NOT EXISTS supplier_doc_register (
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
CREATE INDEX IF NOT EXISTS idx_supdocreg_supplier ON supplier_doc_register(supplier, status);
CREATE INDEX IF NOT EXISTS idx_supdocreg_expiry   ON supplier_doc_register(expiryDate);
