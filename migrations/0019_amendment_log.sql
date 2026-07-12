-- Migration 0019: Amendment / Audit Trail (charter rule: approved records must
-- never be edited silently). Every edit is logged with who/when/old→new; edits
-- to records in an approved/closed state additionally require a reason, and
-- controlled (approved/closed) records cannot be hard-deleted.
-- Safe: CREATE IF NOT EXISTS only.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0019_amendment_log.sql --remote

CREATE TABLE IF NOT EXISTS amendment_logs (
  id           TEXT PRIMARY KEY,
  recordTable  TEXT,          -- client collection key (เช่น fgReleaseInspections)
  recordId     TEXT,          -- id ของ record ที่ถูกแก้
  action       TEXT,          -- EDIT | DELETE
  editedBy     TEXT,
  editedAt     TEXT,
  reason       TEXT,          -- บังคับเมื่อ record อยู่ในสถานะอนุมัติ/ปิดแล้ว
  recordStatus TEXT,          -- สถานะของ record ณ ตอนแก้
  changes      TEXT,          -- JSON [{field, old, new}]
  created      TEXT DEFAULT CURRENT_TIMESTAMP,
  modified     TEXT
);
CREATE INDEX IF NOT EXISTS idx_amd_rec  ON amendment_logs(recordTable, recordId);
CREATE INDEX IF NOT EXISTS idx_amd_time ON amendment_logs(editedAt);
