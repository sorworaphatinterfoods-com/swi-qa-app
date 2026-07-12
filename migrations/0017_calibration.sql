-- Migration 0017: Calibration Management (ISO 22000 §8.7 — control of monitoring
-- and measuring). Calibration records + extend equipment master with schedule
-- fields. FAIL = instrument out of service + NC + impact assessment of
-- measurements taken since the last good calibration.
-- Safe: CREATE IF NOT EXISTS + ADD COLUMN only.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0017_calibration.sql --remote

CREATE TABLE IF NOT EXISTS calibration_records (
  id                 TEXT PRIMARY KEY,
  equipmentId        TEXT,          -- equipment.id (FK, master link)
  calDate            TEXT,
  calType            TEXT,          -- Internal (verify) | External (accredited lab)
  provider           TEXT,          -- ผู้สอบเทียบ / แลป
  certificateNo      TEXT,
  standardRef        TEXT,          -- traceable to national/int'l standard
  rangeCalibrated    TEXT,
  acceptanceCriteria TEXT,          -- เกณฑ์ยอมรับ (MPE)
  asFound            TEXT,          -- ค่าก่อนปรับ
  asLeft             TEXT,          -- ค่าหลังปรับ
  result             TEXT,          -- PASS | FAIL | LIMITED
  impactAssessment   TEXT,          -- บังคับเมื่อ FAIL: ประเมินผลวัดย้อนหลัง
  nextDueDate        TEXT,
  calibratedBy       TEXT,
  verifiedBy         TEXT,
  certPhoto          TEXT,          -- ใบรับรอง (R2)
  ncRef              TEXT,          -- auto NC เมื่อ FAIL
  notes              TEXT,
  created            TEXT DEFAULT CURRENT_TIMESTAMP,
  modified           TEXT
);
CREATE INDEX IF NOT EXISTS idx_cal_equip ON calibration_records(equipmentId);
CREATE INDEX IF NOT EXISTS idx_cal_due   ON calibration_records(nextDueDate);

-- Extend equipment master (safe ADD COLUMN; existing rows keep NULL)
ALTER TABLE equipment ADD COLUMN serialNo TEXT;
ALTER TABLE equipment ADD COLUMN location TEXT;
ALTER TABLE equipment ADD COLUMN calRequired TEXT;          -- yes | no
ALTER TABLE equipment ADD COLUMN calFrequencyMonths TEXT;   -- รอบสอบเทียบ (เดือน)
ALTER TABLE equipment ADD COLUMN lastCalDate TEXT;
ALTER TABLE equipment ADD COLUMN created TEXT;
ALTER TABLE equipment ADD COLUMN modified TEXT;
