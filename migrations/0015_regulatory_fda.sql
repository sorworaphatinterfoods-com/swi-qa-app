-- Migration 0015: Regulatory / FDA (อย.) Compliance Suite.
-- Product Regulatory Master + Additive Compliance (INS/ML/ADI) + Label Compliance
-- checklist + FDA Submission/License tracking + Regulatory Change Control.
-- Safe migration: CREATE TABLE IF NOT EXISTS only — no drop/rename, existing data intact.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0015_regulatory_fda.sql --remote

-- 1) Product Regulatory Master — the legal registration record per product
CREATE TABLE IF NOT EXISTS reg_products (
  id                 TEXT PRIMARY KEY,
  product            TEXT,          -- finished_goods.id (master link)
  nameTh             TEXT,
  nameEn             TEXT,
  brand              TEXT,
  foodCategory       TEXT,          -- ประเภทอาหารตามบัญชี อย.
  fdaNumber          TEXT,          -- เลขสารบบอาหาร 13 หลัก
  registrationType   TEXT,          -- จดทะเบียน / แจ้งรายละเอียด / ขอใช้ฉลาก
  licenseStatus      TEXT DEFAULT 'Pending',  -- Registered | Pending | Expired | Suspended
  approvedDate       TEXT,
  expiryDate         TEXT,          -- วันหมดอายุใบอนุญาต (แจ้งเตือนต่ออายุ)
  dldEstablishmentNo TEXT,          -- เลขทะเบียน กรมปศุสัตว์ (โรงงานเนื้อสัตว์)
  exportEligible     TEXT,          -- yes | no
  exportCountries    TEXT,
  halalCert          TEXT,          -- yes | no
  halalExpiry        TEXT,
  specSheetRef       TEXT,
  notes              TEXT,
  created            TEXT DEFAULT CURRENT_TIMESTAMP,
  modified           TEXT
);
CREATE INDEX IF NOT EXISTS idx_regprod_status ON reg_products(licenseStatus);
CREATE INDEX IF NOT EXISTS idx_regprod_expiry ON reg_products(expiryDate);

-- 2) Additive Compliance — INS number, used level vs Maximum Level (ML), ADI
CREATE TABLE IF NOT EXISTS reg_additives (
  id            TEXT PRIMARY KEY,
  product       TEXT,          -- reg_products.id
  additiveName  TEXT,
  insNumber     TEXT,          -- เลข INS
  functionClass TEXT,          -- หน้าที่ (วัตถุกันเสีย/อิมัลซิไฟเออร์/...)
  limitBasis    TEXT,          -- ML (มีเกณฑ์สูงสุด) | GMP (ปริมาณที่เหมาะสม)
  maxLevel      TEXT,          -- ปริมาณสูงสุดที่อนุญาต mg/kg
  usedLevel     TEXT,          -- ปริมาณที่ใช้จริง mg/kg
  unit          TEXT DEFAULT 'mg/kg',
  adi           TEXT,          -- ค่าความปลอดภัย ADI
  result        TEXT,          -- PASS | OVER_LIMIT | NOT_PERMITTED
  ncRef         TEXT,          -- auto NC เมื่อไม่ผ่าน
  assessor      TEXT,
  notes         TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP,
  modified      TEXT
);
CREATE INDEX IF NOT EXISTS idx_regadd_result ON reg_additives(result);

-- 3) Label Compliance — checklist against ประกาศฉลากอาหาร required elements
CREATE TABLE IF NOT EXISTS reg_label_compliance (
  id             TEXT PRIMARY KEY,
  product        TEXT,          -- reg_products.id
  labelVersion   TEXT,
  checkDate      TEXT,
  inspector      TEXT,
  elName         TEXT,          -- ชื่ออาหาร
  elFdaNo        TEXT,          -- เลขสารบบอาหาร
  elIngredients  TEXT,          -- ส่วนประกอบเรียงลำดับ %
  elAllergen     TEXT,          -- ข้อมูลสำหรับผู้แพ้อาหาร
  elAdditive     TEXT,          -- วัตถุเจือปนอาหาร (INS)
  elNetWeight    TEXT,          -- น้ำหนัก/ปริมาตรสุทธิ
  elMfgExp       TEXT,          -- วันผลิต/หมดอายุ
  elStorage      TEXT,          -- คำแนะนำการเก็บรักษา
  elManufacturer TEXT,          -- ชื่อ-ที่อยู่ผู้ผลิต
  elNutrition    TEXT,          -- ฉลากโภชนาการ/GDA
  elBarcode      TEXT,          -- บาร์โค้ด
  elWarning      TEXT,          -- คำเตือน (เช่น ต้องปรุงสุกก่อนบริโภค)
  result         TEXT,          -- PASS | FAIL
  correctiveAction TEXT,
  ncRef          TEXT,
  notes          TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_reglbl_result ON reg_label_compliance(result);

-- 4) FDA Submission & License — application / renewal workflow + expiry
CREATE TABLE IF NOT EXISTS reg_submissions (
  id             TEXT PRIMARY KEY,
  product        TEXT,          -- reg_products.id (optional; some are facility-level)
  submissionType TEXT,          -- จดทะเบียนใหม่/แจ้งรายละเอียด/ต่ออายุ/แก้ไข/อ.2
  refNo          TEXT,          -- เลขที่คำขอ / e-submission
  authority      TEXT,          -- อย. (FDA) / กรมปศุสัตว์ (DLD) / อื่นๆ
  status         TEXT DEFAULT 'Preparing', -- Preparing|Submitted|Under Review|Info Requested|Approved|Rejected
  submitDate     TEXT,
  approvedDate   TEXT,
  resultNumber   TEXT,          -- เลขที่ได้รับ (เช่น เลขสารบบ)
  licenseExpiry  TEXT,          -- วันหมดอายุใบอนุญาต (แจ้งเตือนต่ออายุ)
  owner          TEXT,
  docsAttached   TEXT,
  notes          TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_regsub_status ON reg_submissions(status);
CREATE INDEX IF NOT EXISTS idx_regsub_expiry ON reg_submissions(licenseExpiry);

-- 5) Regulatory Change Control — impact assessment (must we notify อย.?)
CREATE TABLE IF NOT EXISTS reg_changes (
  id                 TEXT PRIMARY KEY,
  product            TEXT,       -- reg_products.id
  changeType         TEXT,       -- สูตร/ฉลาก/บรรจุ/วัตถุเจือปน/กระบวนการ/ชื่อ/สถานที่
  description        TEXT,
  requestedBy        TEXT,
  requestDate        TEXT,
  affectsLabel       TEXT,       -- yes | no
  affectsRegistration TEXT,      -- yes | no
  notifyRequired     TEXT,       -- ต้องแจ้ง อย./ต้องยื่นแก้ทะเบียน/ไม่ต้องแจ้ง/กำลังประเมิน
  linkedSubmissionRef TEXT,      -- reg_submissions.id
  assessedBy         TEXT,
  status             TEXT DEFAULT 'Open', -- Open|Under Assessment|Approved|Implemented|Rejected
  approvedBy         TEXT,
  effectiveDate      TEXT,
  notes              TEXT,
  created            TEXT DEFAULT CURRENT_TIMESTAMP,
  modified           TEXT
);
CREATE INDEX IF NOT EXISTS idx_regchg_status ON reg_changes(status);
