-- Migration 0023: align ghp_personnel_hygiene with the official paper form
-- "บันทึกการตรวจสอบอุปกรณ์ป้องกันส่วนบุคคลและสุขลักษณะก่อนเข้าพื้นที่ผลิตอาหาร" (12 items).
-- Existing columns (hairCover/footwear/uniformClean/nailsShort/noJewelry/
-- noPersonalItems/handWash/woundCover/noIllness/result…) are reused as-is; this only
-- ADDs the header, the split PPE items, and the signature columns the form needs.
-- Safe: ADD COLUMN is additive (existing rows get NULL). result now also carries
-- 'IMPROVE' (ต้องปรับปรุง) — TEXT already, no change needed.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0023_hygiene_ppe_form.sql --remote

-- header
ALTER TABLE ghp_personnel_hygiene ADD COLUMN time        TEXT;  -- เวลา
ALTER TABLE ghp_personnel_hygiene ADD COLUMN department  TEXT;  -- หน่วยงาน
ALTER TABLE ghp_personnel_hygiene ADD COLUMN prodLine    TEXT;  -- ไลน์ผลิต
ALTER TABLE ghp_personnel_hygiene ADD COLUMN inspectee   TEXT;  -- ผู้ถูกตรวจ

-- PPE items split out to match the form (2 หน้ากาก, 3 ผ้ากันเปื้อน, 4 ถุงมือ, 9 น้ำหอม, 10 ขนมขบเคี้ยว)
ALTER TABLE ghp_personnel_hygiene ADD COLUMN mask      TEXT;
ALTER TABLE ghp_personnel_hygiene ADD COLUMN apron     TEXT;
ALTER TABLE ghp_personnel_hygiene ADD COLUMN gloves    TEXT;
ALTER TABLE ghp_personnel_hygiene ADD COLUMN noPerfume TEXT;
ALTER TABLE ghp_personnel_hygiene ADD COLUMN noSnacks  TEXT;

-- signatures
ALTER TABLE ghp_personnel_hygiene ADD COLUMN supervisor     TEXT;  -- หัวหน้างาน
ALTER TABLE ghp_personnel_hygiene ADD COLUMN acknowledgedBy TEXT;  -- ผู้รับทราบ
