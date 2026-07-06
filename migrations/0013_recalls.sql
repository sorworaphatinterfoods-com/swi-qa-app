-- Migration 0013: Traceability & Recall.
-- Mock / actual recall exercises with quantity reconciliation, built on top of
-- the existing lot_genealogy relationships (RM/ingredient/packaging -> FG ->
-- customer). lot_genealogy is untouched; this adds the recall log only.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0013_recalls.sql --remote

CREATE TABLE IF NOT EXISTS recalls (
  id                 TEXT PRIMARY KEY,
  recallDate         TEXT,
  recallType         TEXT,          -- MOCK | ACTUAL
  recallClass        TEXT,          -- I | II | III
  product            TEXT,          -- finished_goods.id (ref)
  fgLot              TEXT,          -- FG lot triggering the recall
  triggerLot         TEXT,          -- optional upstream RM/ingredient lot that triggered it
  reason             TEXT,
  initiatedBy        TEXT,
  teamLeader         TEXT,
  scope              TEXT,          -- customers / regions affected
  -- quantity reconciliation
  totalProduced      TEXT,
  totalShipped       TEXT,
  quantityRecovered  TEXT,
  quantityOnHold     TEXT,
  quantityRemaining  TEXT,
  reconciliationPct  TEXT,
  -- timing & effectiveness
  startTime          TEXT,
  traceCompleteTime  TEXT,
  timeToTraceMin     TEXT,
  targetTimeMin      TEXT,
  effectiveness      TEXT,          -- PASS | FAIL | PENDING
  status             TEXT DEFAULT 'Open', -- Open | Completed
  closedBy           TEXT,
  closedAt           TEXT,
  notes              TEXT,
  created            TEXT DEFAULT CURRENT_TIMESTAMP,
  modified           TEXT
);
CREATE INDEX IF NOT EXISTS idx_recall_date ON recalls(recallDate);
CREATE INDEX IF NOT EXISTS idx_recall_type ON recalls(recallType);
CREATE INDEX IF NOT EXISTS idx_recall_lot  ON recalls(fgLot);
