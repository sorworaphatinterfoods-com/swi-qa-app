-- SWI Foods — Smart QA Department System
-- D1 Database Schema Migration v2.0 — built from QA_Master_DATA.xlsx
-- Run: wrangler d1 execute qa-factory-db --file=schema.sql --remote
-- ============================================================

-- USERS
CREATE TABLE IF NOT EXISTS users (
  username      TEXT PRIMARY KEY,
  password_hash TEXT NOT NULL,
  name          TEXT NOT NULL,
  role          TEXT NOT NULL,
  dept          TEXT,
  email         TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP
);

-- =================== MASTER DATA TABLES ===================

-- SUPPLIERS (33 records)
CREATE TABLE IF NOT EXISTS suppliers (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  type            TEXT,             -- RM | DM | PM | CM
  risk            TEXT,             -- LOW | MEDIUM | HIGH
  coa             TEXT,             -- Yes | No
  halal           TEXT,             -- Yes | No
  gmp             TEXT,             -- Certified | Pending | -
  status          TEXT,             -- Approved | Conditional | Pending | Rejected
  materialCode    TEXT,
  lastAuditDate   TEXT,
  contact         TEXT,
  email           TEXT,
  address         TEXT,
  notes           TEXT,
  created         TEXT DEFAULT CURRENT_TIMESTAMP,
  modified        TEXT
);
CREATE INDEX IF NOT EXISTS idx_supp_status ON suppliers(status);
CREATE INDEX IF NOT EXISTS idx_supp_type   ON suppliers(type);

-- MATERIALS (109 records — combined RM/DM/PM/CM)
CREATE TABLE IF NOT EXISTS materials (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  category    TEXT,
  subCategory TEXT,
  unit        TEXT,
  minTemp     REAL,
  maxTemp     REAL,
  shelfLife   INTEGER,
  risk        TEXT,
  supplier    TEXT,
  status      TEXT DEFAULT 'Active',
  created     TEXT DEFAULT CURRENT_TIMESTAMP,
  modified    TEXT
);
CREATE INDEX IF NOT EXISTS idx_mat_supplier ON materials(supplier);
CREATE INDEX IF NOT EXISTS idx_mat_category ON materials(category);

-- INGREDIENTS (38 records — subset of DM with extra fields)
CREATE TABLE IF NOT EXISTS ingredients (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  category    TEXT,
  unit        TEXT,
  storageTemp TEXT,
  risk        TEXT
);

-- PACKAGING (60 records)
CREATE TABLE IF NOT EXISTS packaging (
  id    TEXT PRIMARY KEY,
  name  TEXT NOT NULL,
  unit  TEXT,
  risk  TEXT
);

-- CHEMICALS (6 records)
CREATE TABLE IF NOT EXISTS chemicals (
  id    TEXT PRIMARY KEY,
  name  TEXT NOT NULL,
  unit  TEXT,
  risk  TEXT
);

-- FINISHED GOODS (32 records)
CREATE TABLE IF NOT EXISTS finished_goods (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  type        TEXT,
  storageTemp TEXT,
  shelfLife   INTEGER,
  minWeight   REAL,
  maxWeight   REAL,
  minPack     REAL,
  maxPack     REAL,
  status      TEXT DEFAULT 'Active',
  created     TEXT DEFAULT CURRENT_TIMESTAMP
);

-- PROCESSES (25 records)
CREATE TABLE IF NOT EXISTS processes (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  step          INTEGER,
  description   TEXT,
  area          TEXT,
  isCCP         INTEGER DEFAULT 0,
  criticalLimit TEXT,
  monitoring    TEXT
);

-- PARAMETERS (32 records)
CREATE TABLE IF NOT EXISTS parameters (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT,
  category    TEXT,
  spec        TEXT,
  unit        TEXT
);

-- EQUIPMENT (32 records)
CREATE TABLE IF NOT EXISTS equipment (
  id     TEXT PRIMARY KEY,
  name   TEXT NOT NULL,
  type   TEXT,
  usage  TEXT,
  calibrationDue TEXT,
  status TEXT DEFAULT 'Active'
);

-- CCP MASTER (7 records)
CREATE TABLE IF NOT EXISTS ccps (
  id            TEXT PRIMARY KEY,
  processId     TEXT,
  name          TEXT NOT NULL,
  criticalLimit TEXT,
  monitoring    TEXT,
  correction    TEXT
);

-- PROCESS-PARAMETER MAP (21 records)
CREATE TABLE IF NOT EXISTS process_parameter_map (
  id           TEXT PRIMARY KEY,
  processId    TEXT,
  processName  TEXT,
  parameterId  TEXT
);
CREATE INDEX IF NOT EXISTS idx_ppm_proc ON process_parameter_map(processId);

-- MACHINES (7 records)
CREATE TABLE IF NOT EXISTS machines (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  type            TEXT,
  processId       TEXT,
  maintenanceDate TEXT,
  status          TEXT DEFAULT 'Active'
);

-- =================== TRANSACTIONAL TABLES ===================

-- RAW MATERIAL INSPECTIONS
CREATE TABLE IF NOT EXISTS rm_inspections (
  id            TEXT PRIMARY KEY,
  date          TEXT,
  supplier      TEXT,
  material      TEXT,
  lotNo         TEXT,
  quantity      REAL,
  unit          TEXT,
  temp          REAL,
  visual        TEXT,
  coaReceived   INTEGER,
  samplingPlan  TEXT,
  result        TEXT,
  remarks       TEXT,
  inspector     TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_rmi_date   ON rm_inspections(date);
CREATE INDEX IF NOT EXISTS idx_rmi_result ON rm_inspections(result);

-- RAW MATERIAL RECEIVING (FM-QA-31) — header + nested materials[] (JSON)
CREATE TABLE IF NOT EXISTS rm_receiving (
  id             TEXT PRIMARY KEY,
  docNo          TEXT DEFAULT 'FM-QA-31',
  date           TEXT,
  supplier       TEXT,
  truckPlate     TEXT,
  truckCondition TEXT,
  truckTemp      REAL,
  inspector      TEXT,
  note           TEXT,
  materials      TEXT,          -- JSON array of received materials (lot/qty/temp rounds)
  overallResult  TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_rmrcv_date   ON rm_receiving(date);
CREATE INDEX IF NOT EXISTS idx_rmrcv_result ON rm_receiving(overallResult);
CREATE INDEX IF NOT EXISTS idx_rmrcv_sup    ON rm_receiving(supplier);

-- PEST CONTROL (FM-EN-02) — header + nested points[] (JSON)
CREATE TABLE IF NOT EXISTS pest_control (
  id            TEXT PRIMARY KEY,
  docNo         TEXT DEFAULT 'FM-EN-02',
  date          TEXT,
  area          TEXT,
  inspector     TEXT,
  note          TEXT,
  points        TEXT,           -- JSON array of inspected device points
  overallResult TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_pest_date   ON pest_control(date);
CREATE INDEX IF NOT EXISTS idx_pest_result ON pest_control(overallResult);
CREATE INDEX IF NOT EXISTS idx_pest_area   ON pest_control(area);

-- FG INSPECTIONS
CREATE TABLE IF NOT EXISTS fg_inspections (
  id              TEXT PRIMARY KEY,
  date            TEXT,
  product         TEXT,
  batch           TEXT,
  quantity        REAL,
  weightTarget    REAL,
  weightActual    REAL,
  weightCheck     TEXT,
  visual          TEXT,
  metalDetector   TEXT,
  coreTemp        REAL,
  sensoryColor    TEXT,
  sensoryTaste    TEXT,
  sensoryTexture  TEXT,
  result          TEXT,
  remarks         TEXT,
  inspector       TEXT,
  created         TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_fgi_date ON fg_inspections(date);

-- PACKAGING INSPECTIONS
CREATE TABLE IF NOT EXISTS pkg_inspections (
  id          TEXT PRIMARY KEY,
  date        TEXT,
  material    TEXT,
  lotNo       TEXT,
  quantity    REAL,
  visual      TEXT,
  dimension   TEXT,
  foodGrade   INTEGER,
  result      TEXT,
  remarks     TEXT,
  inspector   TEXT,
  created     TEXT DEFAULT CURRENT_TIMESTAMP
);

-- IN-PROCESS INSPECTIONS (FM-QA-32)
-- Nested structure: processes[] -> parameters[] -> rounds[] stored as JSON in `processes`
CREATE TABLE IF NOT EXISTS inprocess_inspections (
  id            TEXT PRIMARY KEY,
  docNo         TEXT DEFAULT 'FM-QA-32',
  date          TEXT,
  product       TEXT,            -- FG id
  productName   TEXT,
  batch         TEXT,
  line          TEXT,
  shift         TEXT,
  inspector     TEXT,
  note          TEXT,
  processes     TEXT,            -- JSON: [{processId,processName,isCCP,parameters:[{parameterId,parameterName,spec,unit,rounds:[{time,value}]}]}]
  overallResult TEXT,            -- PASS | FAIL | PENDING
  created       TEXT DEFAULT CURRENT_TIMESTAMP,
  modified      TEXT
);
CREATE INDEX IF NOT EXISTS idx_ipi_date   ON inprocess_inspections(date);
CREATE INDEX IF NOT EXISTS idx_ipi_result ON inprocess_inspections(overallResult);
CREATE INDEX IF NOT EXISTS idx_ipi_batch  ON inprocess_inspections(batch);

-- TRANSPORT INSPECTIONS (FM-TS-01) — Vehicle Inspection & Transportation Record
CREATE TABLE IF NOT EXISTS transport_inspections (
  id            TEXT PRIMARY KEY,
  date          TEXT,
  plateNo       TEXT,
  transportType TEXT,             -- own | subcontract
  driver        TEXT,
  chkClean      INTEGER,          -- 5-point visual checklist (4.6.4)
  chkPest       INTEGER,
  chkHazard     INTEGER,
  chkRust       INTEGER,
  chkStack      INTEGER,
  tempCold      REAL,             -- °C, must be ≤4 for fresh meat (4.6.3)
  tempMethod    TEXT,             -- gun | logger | na
  docRoNo       INTEGER,          -- ใบ ร.น. (animal carcass movement)
  docRo3        INTEGER,          -- ใบ ร.3 (carcass trade license)
  product       TEXT,
  lotNo         TEXT,
  quantity      REAL,
  destination   TEXT,
  invoiceNo     TEXT,
  result        TEXT,             -- PASS | FAIL
  remarks       TEXT,
  inspector     TEXT,
  verifier      TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_ts_date   ON transport_inspections(date);
CREATE INDEX IF NOT EXISTS idx_ts_result ON transport_inspections(result);
CREATE INDEX IF NOT EXISTS idx_ts_plate  ON transport_inspections(plateNo);

-- RM RECEIVING (FM-QA-31 v2) — header + materials[] (JSON with temp rounds)
CREATE TABLE IF NOT EXISTS rm_receiving (
  id             TEXT PRIMARY KEY,
  docNo          TEXT DEFAULT 'FM-QA-31',
  date           TEXT,
  supplier       TEXT,
  truckPlate     TEXT,
  truckCondition TEXT,
  truckTemp      REAL,            -- PR0001, spec 0-4°C
  inspector      TEXT,
  note           TEXT,
  materials      TEXT,            -- JSON: [{material,lot,qty,unit,mfgDate,expDate,coa,tempRounds:[],result,remarks}]
  overallResult  TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_rcv_date     ON rm_receiving(date);
CREATE INDEX IF NOT EXISTS idx_rcv_supplier ON rm_receiving(supplier);
CREATE INDEX IF NOT EXISTS idx_rcv_result   ON rm_receiving(overallResult);

-- PEST CONTROL (FM-EN-02) — header + points[] (JSON)
CREATE TABLE IF NOT EXISTS pest_control (
  id            TEXT PRIMARY KEY,
  docNo         TEXT DEFAULT 'FM-EN-02',
  date          TEXT,
  area          TEXT,
  inspector     TEXT,
  note          TEXT,
  points        TEXT,             -- JSON: [{code,type,location,found,count,condition,action}]
  overallResult TEXT,             -- OK | ACTION | PENDING
  created       TEXT DEFAULT CURRENT_TIMESTAMP,
  modified      TEXT
);
CREATE INDEX IF NOT EXISTS idx_pst_date   ON pest_control(date);
CREATE INDEX IF NOT EXISTS idx_pst_result ON pest_control(overallResult);

-- HACCP / CCP RECORDS
CREATE TABLE IF NOT EXISTS haccp_records (
  id                 TEXT PRIMARY KEY,
  timestamp          TEXT,
  ccpName            TEXT,
  criticalLimit      TEXT,
  measuredValue      TEXT,
  status             TEXT,           -- IN_LIMIT | OUT_OF_LIMIT
  correctiveAction   TEXT,
  productDisposition TEXT,
  operator           TEXT,
  verifier           TEXT,
  created            TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_haccp_status ON haccp_records(status);

-- NC / CAPA
CREATE TABLE IF NOT EXISTS nc_capa (
  id                  TEXT PRIMARY KEY,
  date                TEXT,
  type                TEXT,
  description         TEXT,
  severity            TEXT,
  source              TEXT,
  rootCause           TEXT,
  correctiveAction    TEXT,
  preventiveAction    TEXT,
  owner               TEXT,
  dueDate             TEXT,
  verifiedBy          TEXT,
  effectivenessCheck  TEXT,
  status              TEXT,
  created             TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_nccapa_status   ON nc_capa(status);
CREATE INDEX IF NOT EXISTS idx_nccapa_severity ON nc_capa(severity);

-- ENVIRONMENTAL
CREATE TABLE IF NOT EXISTS environmental (
  id         TEXT PRIMARY KEY,
  date       TEXT,
  area       TEXT,
  parameter  TEXT,
  value      REAL,
  "limit"    TEXT,
  result     TEXT,
  action     TEXT,
  operator   TEXT,
  created    TEXT DEFAULT CURRENT_TIMESTAMP
);

-- TRAINING
CREATE TABLE IF NOT EXISTS training (
  id             TEXT PRIMARY KEY,
  date           TEXT,
  title          TEXT,
  category       TEXT,
  trainer        TEXT,
  attendees      INTEGER,
  duration       REAL,
  assessment     TEXT,
  avgScore       REAL,
  effectiveness  TEXT,
  status         TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP
);

-- TRACEABILITY
CREATE TABLE IF NOT EXISTS traceability (
  id              TEXT PRIMARY KEY,
  date            TEXT,
  direction       TEXT,
  product         TEXT,
  batch           TEXT,
  productionDate  TEXT,
  rmLots          TEXT,
  quantity        REAL,
  customer        TEXT,
  shipDate        TEXT,
  reason          TEXT,
  completionTime  INTEGER,
  created         TEXT DEFAULT CURRENT_TIMESTAMP
);

-- CUSTOMER COMPLAINTS
CREATE TABLE IF NOT EXISTS complaints (
  id            TEXT PRIMARY KEY,
  date          TEXT,
  customer      TEXT,
  channel       TEXT,
  product       TEXT,
  batch         TEXT,
  subject       TEXT,
  description   TEXT,
  severity      TEXT,
  investigation TEXT,
  response      TEXT,
  compensation  TEXT,
  status        TEXT,
  assignee      TEXT,
  created       TEXT DEFAULT CURRENT_TIMESTAMP
);

-- CONTACT FORM
CREATE TABLE IF NOT EXISTS contact_submissions (
  id        TEXT PRIMARY KEY,
  name      TEXT,
  email     TEXT,
  phone     TEXT,
  subject   TEXT,
  message   TEXT,
  created   TEXT DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- SEED DATA — Default users (set password via /api/auth/login)
-- ============================================================

INSERT OR IGNORE INTO users (username, password_hash, name, role, dept) VALUES
  ('admin',     'CHANGEME-SET-VIA-API', 'Administrator',   'ผู้ดูแลระบบ',   'IT'),
  ('qa',        'CHANGEME-SET-VIA-API', 'หัวหน้า QA',      'QA Manager',   'QA'),
  ('inspector', 'CHANGEME-SET-VIA-API', 'เจ้าหน้าที่ QA',   'QA Inspector', 'QA');


-- suppliers: 33 records
INSERT OR IGNORE INTO suppliers (id, name, type, risk, coa, halal, gmp, status, materialCode, lastAuditDate) VALUES
  ('SP0001', 'บริษัท เบทาโกรเกษตรอุตสาหกรรม จำกัด (หมู)', 'RM', 'HIGH', 'Yes', 'Yes', 'Certified', 'Approved', 'RM0001, RM0002', '2025-11-15'),
  ('SP0002', 'บริษัท เบทาโกรเกษตรอุตสาหกรรม จำกัด (ไก่)', 'RM', 'HIGH', 'Yes', 'Yes', 'Certified', 'Approved', 'RM0004', '2025-11-15'),
  ('SP0003', 'บริษัท เอส แอล พิทักษ์ จำกัด', 'RM', 'HIGH', 'Yes', 'Yes', 'Certified', 'Approved', 'RM0001', '2025-10-10'),
  ('SP0004', 'บริษัท ฟู้ด จ๊อบ จำกัด', 'RM', 'HIGH', 'Yes', 'Yes', 'Certified', 'Approved', 'RM0004', '2025-10-05'),
  ('SP0005', 'ห้างหุ้นส่วนจำกัด หมูสามตัว', 'DM', 'HIGH', 'Yes', 'Yes', 'Certified', 'Approved', 'RM0006', '2025-07-12'),
  ('SP0006', 'ร้าน ปายปายค้าข้าว', 'DM', 'LOW', 'No', 'No', '-', 'Conditional', NULL, NULL),
  ('SP0007', 'บริษัท ซีพีแอ็กซ์ตร้า จำกัด (มหาชน)', 'DM', 'LOW', 'Yes', 'No', 'Certified', 'Approved', 'PD0006', '2025-09-20'),
  ('SP0008', 'บริษัท หยั่นหว่อ หยุ่น คอร์ปอเรชั่น จำกัด', 'DM', 'LOW', 'Yes', 'Yes', 'Pending', 'Approved', 'PD0001', '2025-08-15'),
  ('SP0009', 'บริษัท ยิ่งเจริญ มงคลฟู้ดส์ จำกัด', 'DM', 'LOW', 'Yes', 'Yes', 'Certified', 'Approved', 'PD0002', '2025-09-01'),
  ('SP0010', 'บริษัท เดลี่ ฟู้ดส์ จำกัด', 'DM', 'LOW', 'Yes', 'Yes', 'Certified', 'Approved', 'PD0019', '2025-10-01'),
  ('SP0011', 'บริษัท เอ็น.อาร์.น้ำตาลมะพร้าว จำกัด', 'DM', 'LOW', 'Yes', 'Yes', 'Certified', 'Approved', 'PD0018', '2025-11-02'),
  ('SP0012', 'โรงงานน้ำตาลโชควาสนา', 'DM', 'LOW', 'Yes', 'Yes', 'Certified', 'Approved', 'PD0017', '2025-06-20'),
  ('SP0013', 'บริษัท จิมสกรุ๊ป จำกัด', 'DM', 'LOW', 'Yes', 'Yes', 'Certified', 'Approved', 'PD0007', '2025-06-18'),
  ('SP0014', 'บริษัท ไอ พลัส ซัพพลายส์ จำกัด', 'DM', 'LOW', 'Yes', 'No', 'Certified', 'Approved', 'PD0008', '2025-08-01'),
  ('SP0015', 'หจก.สหบุญญชาติ ฟลาวเซ็นเตอร์', 'DM', 'LOW', 'Yes', 'No', 'Certified', 'Approved', 'PD0009', '2025-07-25'),
  ('SP0016', 'ร้าน จูนีย์ (หอม-กระเทียม)', 'DM', 'LOW', 'Yes', 'No', 'Certified', 'Approved', 'PD0011', '2025-07-26'),
  ('SP0017', 'บริษัท เอส เอ โอ การเกษตร จำกัด', 'DM', 'LOW', 'No', 'No', '-', 'Approved', 'PD0012', '2025-05-10'),
  ('SP0018', 'บริษัท กุยลิ้มซึ้ง จำกัด', 'DM', 'LOW', 'Yes', 'Yes', 'Certified', 'Approved', 'PD0030', '2025-09-12'),
  ('SP0019', 'บริษัท ตะวันพืชผล จำกัด', 'DM', 'LOW', 'Yes', 'No', 'Certified', 'Approved', 'PD0032', '2025-07-01'),
  ('SP0020', 'บริษัท อาหารเบทเทอร์ จำกัด', 'DM', 'LOW', 'Yes', 'Yes', 'Certified', 'Approved', 'PD0008', '2025-06-05'),
  ('SP0021', 'หจก.เชียงใหม่เบเกอร์มาร์ท', 'DM', 'LOW', 'Yes', 'Yes', 'Certified', 'Approved', 'PD0020', '2025-08-10'),
  ('SP0022', 'บริษัท อุทัยพลาสติก อุตสาหกรรม จำกัด', 'PM', 'LOW', 'Yes', 'Yes', 'Certified', 'Approved', 'PG0001', '2025-06-15'),
  ('SP0023', 'บริษัท เจเนอรัล เรคคอร์ด อินเตอร์ จำกัด', 'PM', 'LOW', 'Yes', 'No', 'Certified', 'Approved', 'PK0001', '2025-08-22'),
  ('SP0024', 'บริษัท บางกอก อินสทรูเมนท์ แอนด์เซอร์วิส จำกัด', 'PM', 'LOW', 'Yes', 'No', 'Certified', 'Approved', 'PK0010', '2025-07-30'),
  ('SP0025', 'บริษัท ศรีไม้ไผ่ทอง(2019) อุตสาหกรรม จำกัด', 'PM', 'LOW', 'No', 'No', '-', 'Approved', 'PK0019', '2025-05-20'),
  ('SP0026', 'บริษัท ฟิวเจอร์ บิสซิเนส โซลูชั่น จำกัด', 'PM', 'LOW', 'Yes', 'No', 'Certified', 'Approved', 'PK0040', '2025-08-05'),
  ('SP0027', 'ห้างหุ้นส่วนจำกัด วี-ริน เคมีคอล', 'CM', 'MEDIUM', 'Yes', 'No', 'Certified', 'Approved', 'CM0002', '2025-07-15'),
  ('SP0028', 'บริษัท เอ็นริช อินเตอร์เคมิคัล จำกัด', 'CM', 'MEDIUM', 'Yes', 'No', 'Certified', 'Approved', 'CM0003', '2025-07-18'),
  ('SP0029', 'บริษัท ฟลุสสิค เคม จำกัด', 'CM', 'MEDIUM', 'Yes', 'No', 'Certified', 'Approved', 'CM0006', '2025-07-22'),
  ('SP0030', 'บริษัท เบทเทอร์ ฟาร์มา จำกัด', 'CM', 'MEDIUM', 'Yes', 'No', 'Certified', 'Approved', 'CM0007', '2025-07-28'),
  ('SP0031', 'บริษัท ออฟฟิศเมท (ไทย) จำกัด', 'CM', 'MEDIUM', 'Yes', 'No', 'Certified', 'Approved', 'CM0001', NULL),
  ('SP0032', 'บริษัท ท้อป เมาท์เทน จำกัด', 'PM', 'LOW', 'No', 'No', '-', 'Approved', 'PG0012', NULL),
  ('SP0033', 'บริษัท ดวงเจริญ อินเตอร์เทรด จำกัด', 'RM', 'HIGH', 'No', 'No', '-', 'Conditional', 'RM0001', NULL);

-- materials: 109 records
INSERT OR IGNORE INTO materials (id, name, category, subCategory, unit, minTemp, maxTemp, shelfLife, risk, supplier, status) VALUES
  ('RM0001', 'สะโพกหมู', 'RM', 'Pork', 'กิโลกรัม', 0, 7, 6, 'High', 'SP0001', 'Active'),
  ('RM0002', 'มันสันแข็ง', 'RM', 'Pork', 'กิโลกรัม', 0, 7, 6, 'High', 'SP001', 'Active'),
  ('RM0004', 'เศษบีบีติดหนัง', 'RM', 'Chicken', 'กิโลกรัม', 0, 7, 5, 'High', 'SP005', 'Active'),
  ('RM0005', 'อกไก่', 'RM', 'Chicken', 'กิโลกรัม', 0, 7, 5, 'High', 'SP005', 'Active'),
  ('RM0006', 'ข้าวสารเหนียว', 'DM', 'Rice', 'กิโลกรัม', NULL, NULL, NULL, 'Medium', 'SP005', 'Active'),
  ('PD0001', 'ซอสหอยนางรมหมู', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0002', 'ซอสหอยนางรมไก่', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0003', 'ซอสปรุงรสฝาเขียว', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0004', 'ซีอิ้วขาว  สูตร 1', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0005', 'ซีอิ้วดำฉลากส้ม', 'DM', 'Ingredient', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0006', 'ซีอิ้วขาวเห็ดหอม', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0007', 'ผงปรุงรส', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0008', 'ผงชูรส', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0009', 'แป้งท้าว', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0010', 'เกลือ', 'DM', 'Ingredient', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0011', 'กระเทียม', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0012', 'พริกไทยดำ', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0013', 'พริกไทยขาว', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0014', 'เมล็ดผักชี', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0015', 'ผงขมิ้น', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0016', 'ผงกระเทียม', 'DM', 'Seasoning', 'กรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0017', 'น้ำตาลมะพร้าวหมู', 'DM', 'Ingredient', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0018', 'น้ำตาลมะพร้าวไก่', 'DM', 'Ingredient', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0019', 'นมจืด', 'DM', 'Ingredient', 'กระป๋อง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0020', 'สีส้มแดง', 'DM', 'Additive', 'กรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0021', 'สีเหลืองไข่', 'DM', 'Additive', 'กรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0022', 'โซดา', 'DM', 'Additive', 'ขวด', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0023', 'ฟอสเฟต', 'DM', 'Additive', 'กรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0024', 'แป้งมัน', 'DM', 'Ingredient', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0025', 'วุ้นเส้น', 'DM', 'Ingredient', 'กรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0026', 'ข้าวเจ้า', 'DM', 'Ingredient', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0027', 'ซอสบาร์บีคิว', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0028', 'ซอสพริก', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0029', 'เบคกิ้งโซดา', 'DM', 'Additive', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0030', 'ผงสามเกลอ', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0031', 'พริกขี้หนูป่น', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0032', 'ผงพริกหม่าล่า', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0033', 'ผงกะหรี่', 'DM', 'Seasoning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0034', 'น้ำมันงา', 'DM', 'Seasoning', 'ลิตร', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0035', 'น้ำปลา', 'DM', 'Seasoning', 'ลิตร', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0036', 'ซอสโชยุ', 'DM', 'Seasoning', 'กรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0037', 'ซอสเทอริยากิ', 'DM', 'Seasoning', 'กรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PD0038', 'งาขาว', 'DM', 'Seasoning', 'กรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0001', 'ถุงหูหิ้ว9*18', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0002', 'ถุงหูหิ้ว12*20', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0003', 'ถุงหูหิ้ว12*18', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0004', 'ถุงใส6*9', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0005', 'ถุงขยะดำ 24*28*20mm', 'PM', 'Plastic Bag', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0006', 'ถุงขยะสีชา', 'PM', 'Plastic Bag', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0009', 'รองเท้าบูทยางสีขาว เบอร์ 11', 'PM', 'Boots', 'คู่', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0010', 'รองเท้าบูทสีขาว เบอร์12', 'PM', 'Boots', 'คู่', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0011', 'เอี๋ยมน้ำเงิน', 'PM', 'Aprons', 'ผืน', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0012', 'ถุงมือยางสีน้ำเงิน/S', 'PM', 'Gloves', 'กล่อง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0013', 'ถุงมือยางสีน้ำเงิน/M', 'PM', 'Gloves', 'กล่อง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0014', 'ถุงมือยางสีน้ำเงิน/L', 'PM', 'Gloves', 'กล่อง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0015', 'ถุงHD A11"x17" หนา 0.12 มม./คู่', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0016', 'ถุง HD  A14"x25" หนา 0.12 มม./คู่ (สีขาว)', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PG0018', 'ถุง HD  A14"x25" หนา 0.12 มม./คู่ (สีฟ้า)', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0001', 'กล่องลูกฟูก5ชั้น ขนาด287*385*305', 'PM', 'Packaging', 'ใบ', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0002', 'กล่องลูกฟูก5ชั้น ขนาด23*40*21.2', 'PM', 'Packaging', 'ใบ', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0003', 'กล่องโฟม 25', 'PM', 'Packaging', 'ใบ', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0004', 'กล่องโฟม 3 กก', 'PM', 'Packaging', 'ใบ', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0005', 'ถุงHD A19*12(แผ่นแพ็ค)', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0006', 'ถุงHD/A10*16หนา0.08มม.คู่ไม่พิมพ์โลโก้', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0007', 'ถุงHD A10*16หนา พิมพ์โลโก้', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0008', 'ถุงNYLON+LL 220mm*300mm ซีล 3ด้าน', 'PM', 'Packaging', 'ใบ', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0009', 'ถุงHD 11*17 พิมพ์โลโก้หมูนมสด size s', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0010', 'เทปใส', 'PM', 'Tape', 'ม้วน', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0011', 'แผ่นรองชั้น HD A7*10หนา0.08มม', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0012', 'แผ่นแพ็คHD A18*23หนา0.08มม', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0013', 'แผ่นHD Aสีเหลือง18*23หนา0.08มม', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0014', 'แผ่นHD Aสีเขียว18*23หนา0.08มม', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0015', 'แผ่นHD Aชมพู18*23หนา0.08มม', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0016', 'แผ่นHD Aสีส้ม18*23หนา0.08มม', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0017', 'แผ่นห่อHD A8*10หนา0.08มม', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0018', 'แผ่นห่อDH A4*6หนา0.08มม', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0019', 'ไม้กลม3*5', 'PM', 'Skewer', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0020', 'ไม้กลม3*6', 'PM', 'Skewer', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0021', 'ไม้กลม3*7', 'PM', 'Skewer', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0022', 'ไม้ชายธงเบอร์6', 'PM', 'Skewer', 'ถุง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0023', 'สติ๊กเกอร์ติดข้างกล่อง MK', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0024', 'สติ๊กเกอร์ติดแพ็คเก็จจิ้ง MK', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0025', 'สติ๊กเกอร์ (ข้าว)', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0026', 'ถุงHD A10*16  พิมพ์ไก่พริกไทยดำ', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0027', 'ถุงHD A10*16  พิมพ์ไก่แดง', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0028', 'ถุงHD A10*16  พิมพ์ไก่นมสด', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0029', 'ไม้กลม2.5*6', 'PM', 'Skewer', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0030', 'ถุงNYLON+LL 300*400mm.*80cm ซีล 3 ด้าน', 'PM', 'Packaging', 'ใบ', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0031', 'สติ๊กเกอร์ติดข้างกล่อง หมูนมสด-GHS', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0032', 'สติ๊กเกอร์ติดแพคเกจจิ้ง หมูนมสด-GHS', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0033', 'สติ๊กเกอร์ติดข้างกล่อง BBQ', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0034', 'สติ๊กเกอร์ติดแพคเกจจิ้ง BBQ', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0036', 'ถุงNYLON+LL 220*240mm.*80mi ซีล 3 ด้าน', 'PM', 'Packaging', 'ใบ', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0037', 'ถุงNYLON+LL 205*305mm.*80mi ซีล 3 ด้าน', 'PM', 'Packaging', 'ใบ', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0038', 'กล่องลูกฟูก5ชั้น ขนาด230*400*170', 'PM', 'Packaging', 'ใบ', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0040', 'สติ๊กเกอร์ข้างกล่อง หมูปิ้งหมักสูตรโบราณ aro', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0041', 'สติ๊กเกอร์ข้างกล่อง หมูสะเต๊ะพร้อมปรุงเสียบไม้ aro', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0042', 'สติ๊กเกอร์ข้างกล่อง หมูปิ้งนมสดสูตรเข้มข้น aro', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0043', 'สติ๊กเกอร์แพคเกจจิ้ง หมูปิ้งหมักสูตรโบราณ aro', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0044', 'สติ๊กเกอร์แพคเกจจิ้ง หมูสะเต๊ะพร้อมปรุงเสียบไม้ aro', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0045', 'สติ๊กเกอร์แพคเกจจิ้ง หมูปิ้งนมสดสูตรเข้มข้น aro', 'PM', 'Sticker', 'ดวง', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0046', 'ถุงHD A10*16  พิมพ์หมูแดดเดียว', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('PK0053', 'ถุงHD 11*17 (ไม่พิมพ์โลโก้)', 'PM', 'Packaging', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('CM0001', 'CL - NEXGEN PH-1000', 'CM', 'Cleaning', 'ลิตร', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('CM0002', 'SN - คลอรีนน้ำ 10%', 'CM', 'Sanitizing', 'กิโลกรััม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('CM0003', 'CL - ENRICH D028', 'CM', 'Cleaning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('CM0004', 'SN - NEXGEN ALCO 70B', 'CM', 'Sanitizing', 'ลิตร', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('CM0006', 'SN - NEXGEN SAN 800', 'CM', 'Sanitizing', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active'),
  ('CM0007', 'CL - NEXGEN MP-1000', 'CM', 'Cleaning', 'กิโลกรัม', NULL, NULL, NULL, NULL, NULL, 'Active');

-- ingredients: 38 records
INSERT OR IGNORE INTO ingredients (id, name, category, unit, storageTemp, risk) VALUES
  ('PD0001', 'ซอสหอยนางรมหมู', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0002', 'ซอสหอยนางรมไก่', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0003', 'ซอสปรุงรสฝาเขียว', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0004', 'ซีอิ้วขาว  สูตร 1', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Low'),
  ('PD0005', 'ซีอิ้วดำฉลากส้ม', 'Ingredient', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0006', 'ซีอิ้วขาวเห็ดหอม', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Low'),
  ('PD0007', 'ผงปรุงรส', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Low'),
  ('PD0008', 'ผงชูรส', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0009', 'แป้งท้าว', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0010', 'เกลือ', 'Ingredient', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0011', 'กระเทียม', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0012', 'พริกไทยดำ', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0013', 'พริกไทยขาว', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0014', 'เมล็ดผักชี', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0015', 'ผงขมิ้น', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0016', 'ผงกระเทียม', 'Seasoning', 'กรัม', '25-30 C', 'Medium'),
  ('PD0017', 'น้ำตาลมะพร้าวหมู', 'Ingredient', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0018', 'น้ำตาลมะพร้าวไก่', 'Ingredient', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0019', 'นมจืด', 'Ingredient', 'กระป๋อง', '25-30 C', 'Medium'),
  ('PD0020', 'สีส้มแดง', 'Additive', 'กรัม', '25-30 C', 'Low'),
  ('PD0021', 'สีเหลืองไข่', 'Additive', 'กรัม', '25-30 C', 'Low'),
  ('PD0022', 'โซดา', 'Additive', 'ขวด', '25-30 C', 'Low'),
  ('PD0023', 'ฟอสเฟต', 'Additive', 'กรัม', '25-30 C', 'Low'),
  ('PD0024', 'แป้งมัน', 'Ingredient', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0025', 'วุ้นเส้น', 'Ingredient', 'กรัม', '25-30 C', 'Medium'),
  ('PD0026', 'ข้าวเจ้า', 'Ingredient', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0027', 'ซอสบาร์บีคิว', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0028', 'ซอสพริก', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0029', 'เบคกิ้งโซดา', 'Additive', 'กิโลกรัม', '25-30 C', 'Low'),
  ('PD0030', 'ผงสามเกลอ', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0031', 'พริกขี้หนูป่น', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0032', 'ผงพริกหม่าล่า', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0033', 'ผงกะหรี่', 'Seasoning', 'กิโลกรัม', '25-30 C', 'Medium'),
  ('PD0034', 'น้ำมันงา', 'Seasoning', 'ลิตร', '25-30 C', 'Medium'),
  ('PD0035', 'น้ำปลา', 'Seasoning', 'ลิตร', '25-30 C', 'Medium'),
  ('PD0036', 'ซอสโชยุ', 'Seasoning', 'กรัม', '25-30 C', 'Medium'),
  ('PD0037', 'ซอสเทอริยากิ', 'Seasoning', 'กรัม', '25-30 C', 'Medium'),
  ('PD0038', 'งาขาว', 'Seasoning', 'กรัม', '25-30 C', 'Medium');

-- packaging: 60 records
INSERT OR IGNORE INTO packaging (id, name, unit, risk) VALUES
  ('PK0001', 'กล่องลูกฟูก5ชั้น ขนาด287*385*305', 'ใบ', 'Medium'),
  ('PK0002', 'กล่องลูกฟูก5ชั้น ขนาด23*40*21.2', 'ใบ', 'Medium'),
  ('PK0003', 'กล่องโฟม 25', 'ใบ', 'Medium'),
  ('PK0004', 'กล่องโฟม 3 กก', 'ใบ', 'Medium'),
  ('PK0005', 'ถุงHD A19*12(แผ่นแพ็ค)', 'กิโลกรัม', 'Low'),
  ('PK0006', 'ถุงHD/A10*16หนา0.08มม.คู่ไม่พิมพ์โลโก้', 'กิโลกรัม', 'Low'),
  ('PK0007', 'ถุงHD A10*16หนา พิมพ์โลโก้', 'กิโลกรัม', 'Low'),
  ('PK0008', 'ถุงNYLON+LL 220mm*300mm ซีล 3ด้าน', 'ใบ', 'Low'),
  ('PK0009', 'ถุงHD 11*17 พิมพ์โลโก้หมูนมสด size s', 'กิโลกรัม', 'Low'),
  ('PK0010', 'เทปใส', 'ม้วน', 'Low'),
  ('PK0011', 'แผ่นรองชั้น HD A7*10หนา0.08มม', 'กิโลกรัม', 'Low'),
  ('PK0012', 'แผ่นแพ็คHD A18*23หนา0.08มม', 'กิโลกรัม', 'Low'),
  ('PK0013', 'แผ่นHD Aสีเหลือง18*23หนา0.08มม', 'กิโลกรัม', 'Low'),
  ('PK0014', 'แผ่นHD Aสีเขียว18*23หนา0.08มม', 'กิโลกรัม', 'Low'),
  ('PK0015', 'แผ่นHD Aชมพู18*23หนา0.08มม', 'กิโลกรัม', 'Low'),
  ('PK0016', 'แผ่นHD Aสีส้ม18*23หนา0.08มม', 'กิโลกรัม', 'Low'),
  ('PK0017', 'แผ่นห่อHD A8*10หนา0.08มม', 'กิโลกรัม', 'Low'),
  ('PK0018', 'แผ่นห่อDH A4*6หนา0.08มม', 'กิโลกรัม', 'Low'),
  ('PK0019', 'ไม้กลม3*5', 'กิโลกรัม', 'Low'),
  ('PK0020', 'ไม้กลม3*6', 'กิโลกรัม', 'Low'),
  ('PK0021', 'ไม้กลม3*7', 'กิโลกรัม', 'Low'),
  ('PK0022', 'ไม้ชายธงเบอร์6', 'ถุง', 'Low'),
  ('PK0023', 'สติ๊กเกอร์ติดข้างกล่อง MK', 'ดวง', 'Low'),
  ('PK0024', 'สติ๊กเกอร์ติดแพ็คเก็จจิ้ง MK', 'ดวง', 'Low'),
  ('PK0025', 'สติ๊กเกอร์ (ข้าว)', 'ดวง', 'Low'),
  ('PK0026', 'ถุงHD A10*16  พิมพ์ไก่พริกไทยดำ', 'กิโลกรัม', 'Low'),
  ('PK0027', 'ถุงHD A10*16  พิมพ์ไก่แดง', 'กิโลกรัม', 'Low'),
  ('PK0028', 'ถุงHD A10*16  พิมพ์ไก่นมสด', 'กิโลกรัม', 'Low'),
  ('PK0029', 'ไม้กลม2.5*6', 'กิโลกรัม', 'Low'),
  ('PK0030', 'ถุงNYLON+LL 300*400mm.*80cm ซีล 3 ด้าน', 'ใบ', 'Low'),
  ('PK0031', 'สติ๊กเกอร์ติดข้างกล่อง หมูนมสด-GHS', 'ดวง', 'Low'),
  ('PK0032', 'สติ๊กเกอร์ติดแพคเกจจิ้ง หมูนมสด-GHS', 'ดวง', 'Low'),
  ('PK0033', 'สติ๊กเกอร์ติดข้างกล่อง BBQ', 'ดวง', 'Low'),
  ('PK0034', 'สติ๊กเกอร์ติดแพคเกจจิ้ง BBQ', 'ดวง', 'Low'),
  ('PK0036', 'ถุงNYLON+LL 220*240mm.*80mi ซีล 3 ด้าน', 'ใบ', 'Low'),
  ('PK0037', 'ถุงNYLON+LL 205*305mm.*80mi ซีล 3 ด้าน', 'ใบ', 'Low'),
  ('PK0038', 'กล่องลูกฟูก5ชั้น ขนาด230*400*170', 'ใบ', 'Low'),
  ('PK0040', 'สติ๊กเกอร์ข้างกล่อง หมูปิ้งหมักสูตรโบราณ aro', 'ดวง', 'Low'),
  ('PK0041', 'สติ๊กเกอร์ข้างกล่อง หมูสะเต๊ะพร้อมปรุงเสียบไม้ aro', 'ดวง', 'Low'),
  ('PK0042', 'สติ๊กเกอร์ข้างกล่อง หมูปิ้งนมสดสูตรเข้มข้น aro', 'ดวง', 'Low'),
  ('PK0043', 'สติ๊กเกอร์แพคเกจจิ้ง หมูปิ้งหมักสูตรโบราณ aro', 'ดวง', 'Low'),
  ('PK0044', 'สติ๊กเกอร์แพคเกจจิ้ง หมูสะเต๊ะพร้อมปรุงเสียบไม้ aro', 'ดวง', 'Low'),
  ('PK0045', 'สติ๊กเกอร์แพคเกจจิ้ง หมูปิ้งนมสดสูตรเข้มข้น aro', 'ดวง', 'Low'),
  ('PK0046', 'ถุงHD A10*16  พิมพ์หมูแดดเดียว', 'กิโลกรัม', 'Low'),
  ('PK0053', 'ถุงHD 11*17 (ไม่พิมพ์โลโก้)', 'กิโลกรัม', 'Low'),
  ('PG0001', 'ถุงหูหิ้ว9*18', 'กิโลกรัม', 'Low'),
  ('PG0002', 'ถุงหูหิ้ว12*20', 'กิโลกรัม', 'Low'),
  ('PG0003', 'ถุงหูหิ้ว12*18', 'กิโลกรัม', 'Low'),
  ('PG0004', 'ถุงใส6*9', 'กิโลกรัม', 'Low'),
  ('PG0005', 'ถุงขยะดำ 24*28*20mm', 'กิโลกรัม', 'Low'),
  ('PG0006', 'ถุงขยะสีชา', 'กิโลกรัม', 'Low'),
  ('PG0009', 'รองเท้าบูทยางสีขาว เบอร์ 11', 'คู่', 'Low'),
  ('PG0010', 'รองเท้าบูทสีขาว เบอร์12', 'คู่', 'Low'),
  ('PG0011', 'เอี๋ยมน้ำเงิน', 'ผืน', 'Low'),
  ('PG0012', 'ถุงมือยางสีน้ำเงิน/S', 'กล่อง', 'Low'),
  ('PG0013', 'ถุงมือยางสีน้ำเงิน/M', 'กล่อง', 'Low'),
  ('PG0014', 'ถุงมือยางสีน้ำเงิน/L', 'กล่อง', 'Low'),
  ('PG0015', 'ถุงHD A11"x17" หนา 0.12 มม./คู่', 'กิโลกรัม', 'Low'),
  ('PG0016', 'ถุง HD  A14"x25" หนา 0.12 มม./คู่ (สีขาว)', 'กิโลกรัม', 'Low'),
  ('PG0018', 'ถุง HD  A14"x25" หนา 0.12 มม./คู่ (สีฟ้า)', 'กิโลกรัม', 'Low');

-- chemicals: 6 records
INSERT OR IGNORE INTO chemicals (id, name, unit, risk) VALUES
  ('CM - 001', 'CL - Liquid Soap', 'Gallon', 'Medium'),
  ('CM - 002', 'SN - คลอรีนน้ำ 10%', 'Kg', 'Medium'),
  ('CM - 003', 'CL - Enrich D028', 'Kg', 'Medium'),
  ('CM - 004', 'SN - ALCOHOL 75%', 'L', 'Medium'),
  ('CM - 006', 'SN - QAC (Q-San M)', 'Kg', 'Medium'),
  ('CM - 007', 'CL - NEXGEN MP-1000', 'Kg', 'Medium');

-- finished_goods: 32 records
INSERT OR IGNORE INTO finished_goods (id, name, type, storageTemp, shelfLife, minWeight, maxWeight, minPack, maxPack, status) VALUES
  ('FG - ม002', 'หมูปิ้งนมสดเสียบไม้ - Size L', 'Pork Marinated', -18, 365, 50, 52, 2500, 2600, 'Active'),
  ('FG - ม003', 'หมูปิ้งนมสดเสียบไม้ - Size S', 'Pork Marinated', -18, 365, 25, 26, 2500, 2600, 'Active'),
  ('FG - ม004', 'หมูปิ้งนมสดเสียบไม้ - พาย', 'Pork Marinated', -18, 365, 50, 52, 2500, 2600, 'Active'),
  ('FG - ม005', 'หมูปิ้งนมสดเสียบไม้ Size L พร้อมทาน', 'Pork Marinated', -18, 365, 45, 46, 2500, 2600, 'Active'),
  ('FG - ม006', 'หมูปิ้งนมสดแช่แข็ง 25 ก x 40 ไม้ x 20 แพ็ก / ลัง (MK)', 'Pork Marinated', -18, 365, 25, 26, 950, 1050, 'Active'),
  ('FG - ม007', 'หมูปิ้งนมสดแช่แข็ง 45 ก x 40 ไม้ x 10 แพ็ก / ลัง (GHS)', 'Pork Marinated', -18, 365, 45, 46, 1800, 1850, 'Active'),
  ('FG - ม008', 'GHS หมูปิ้งนมสดฉลากขาว 45ก.x40ไม้x10 แพ็ก', 'Pork Marinated', -18, 365, 45, 46, 1800, 1850, 'Active'),
  ('FG - ม010', 'หมูแดดเดียว', 'Pork Marinated', -18, 365, 35, 37, NULL, NULL, 'Active'),
  ('FG - ม011', 'หมูปิ้งโบราณ Size L', 'Pork Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ม013', 'หมูปิ้งโบราณ Size S', 'Pork Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ม014', 'หมูปิ้งโบราณแช่แข็ง 16 ก x 40 ไม้ x 24 แพ็ก / ลัง (MK)', 'Pork Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ม024', 'หมูหมักบาร์บีคิวเสียบไม้แช่แข็ง 50 ก x 30 ไม้', 'Pork Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ม025', 'หมูปิ้งโบราณแช่แข็ง 16 ก x 50 ไม้ ( สูตร 2 )', 'Pork Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ม026', 'หมูสะเต๊ะแช่แข็ง 13 ก x 50 ไม้', 'Pork Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ม027', 'หมูหม่าล่าแช่แข็ง 16 ก x 50 ไม้', 'Pork Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ม028', 'Repack หมูสะเต๊ะแช่แข็ง 30 ก x 50 ไม้', 'Pork Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ม029', 'Repack หมูหม่าล่าแช่แข็ง 24 ก x 50 ไม้', 'Pork Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ล001', 'ลูกชิ้นหมู', 'Meat Ball', -18, 365, NULL, NULL, 2000, 2200, 'Active'),
  ('FG - ล003', 'ลูกชิ้นเอ็นหมู', 'Meat Ball', -18, 365, NULL, NULL, 2000, 2200, 'Active'),
  ('FG - ส001', 'ไส้กรอกวุ้นเส้น', 'Esan Sausage', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ส002', 'ไส้กรอกดั้งเดิม', 'Esan Sausage', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ส003', 'ไส้กรอกเปรี้ยว', 'Esan Sausage', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ก001', 'ไก่แดงโบราณ', 'Chicken Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ก001 MPS', 'ไก่พริกไทยดำเสียบไม้ แพ็กละ10ไม้', 'Chicken Marinated', -18, 365, NULL, NULL, NULL, NULL, 'Active'),
  ('FG - ก002', 'ไก่พริกไทยดำ', 'Chicken Marinated', -18, 365, 50, 52, 2500, 2600, 'Active'),
  ('FG - ก003', 'ไก่ปิ้งนมสด', 'Chicken Marinated', -18, 365, 50, 52, 2500, 2600, 'Active'),
  ('FG - ก004', 'ไก่เทอริยากิ 55 ก x 50 ไม้', 'Chicken Marinated', -18, 365, 50, 52, 2500, 2600, 'Active'),
  ('FG - ก005', 'ไก่หม่าล่า 55 ก x 50 ไม้', 'Chicken Marinated', -18, 365, 50, 52, 2500, 2600, 'Active'),
  ('FG - ก006', 'ไก่บาร์บีคิว 55 ก x 40 ไม้', 'Chicken Marinated', -18, 365, 50, 52, 2500, 2600, 'Active'),
  ('FG - ข001', 'ข้าวเหนียว', 'Rice', 'Ambient', 270, 5000, 5000, 5000, 5000, 'Active'),
  ('FG - ม002 Tops', 'Tops หมูปิ้งนมสดพร้อมทาน', 'Pork Marinated', -18, 365, 410, 450, 410, 450, 'Active'),
  ('FG - ก001 Tops', 'Tops ไก่แดงโบราณพร้อมทาน', 'Chicken Marinated', -18, 365, 410, 450, 410, 450, 'Active');

-- processes: 25 records
INSERT OR IGNORE INTO processes (id, name, step, description, area, isCCP) VALUES
  ('PC0001', 'การรับเข้าวัตถุดิบ', 1, 'จุดตรวจสอบและรับเนื้อหมู เครื่องปรุง หรือบรรจุภัณฑ์', 'จุดรับวัตถุดิบ RM, DM, PM, CM', 0),
  ('PC0002', 'การจัดเก็บวัตถุดิบ', 2, 'การเก็บรักษาวัตถุดิบก่อนเบิกไปใช้ (เช่น ห้องเย็น)', 'ห้องแช่เย็น จัดเก็บ RM', 0),
  ('PC0003', 'การตัดและตกแต่ง', 3, 'การหั่นเนื้อหมู เลาะพังผืด หรือตัดแต่งขนาด', 'จุุดตัดแต่ง ห้องผลิต', 0),
  ('PC0004', 'การชั่งน้ำหนักส่วนผสมตามสูตร', 4, 'การชั่งตวงส่วนผสมให้ได้สัดส่วนตามสูตร (Recipe)', 'ห้องชั่งสาร', 0),
  ('PC0005', 'การลดขนาดวัตถุดิบ ครั้งที่ 1', 5, 'การลดขนาดวัตถุดิบให้มีชิ้นเล็กลงตามขนาดของตัวเครื่องและใบมีด', 'ห้องผลิิต', 0),
  ('PC0006', 'การลดขนาดวัตถุดิบ ครั้งที่ 2', 6, 'การลดขนาดวัตถุดิบให้มีชิ้นเล็กลงตามขนาดของตัวเครื่องและใบมีด', 'ห้องผลิิต', 0),
  ('PC0007', 'การลดขนาดวัตถุดิบ ครั้งที่ 3', 7, 'การลดขนาดวัตถุดิบให้มีชิ้นเล็กลงตามขนาดของตัวเครื่องและใบมีด', 'ห้องผลิิต', 0),
  ('PC0008', 'การผสมและการหมัก', 8, 'การคลุกเคล้าเนื้อหมูกับเครื่องปรุงและหมักทิ้งไว้', 'ห้องผลิต', 1),
  ('PC0009', 'การเสียบไม้และขึ้นรูป', 9, 'การนำเนื้อหมูมาเสียบไม้และจัดทรงให้ได้มาตรฐาน', 'ห้องผลิต', 0),
  ('PC0010', 'การให้ความร้อนวัตถุดิบ (สุก)', 10, 'กระบวนการให้ความร้อน (หากเป็นสินค้าแบบปรุงสุก)', 'ห้องผลิต (ไลน์สุก)', 1),
  ('PC0011', 'การลดอุณหภูมิ', 11, 'การพักสินค้าให้เย็นลงก่อนนำไปแพ็คหรือแช่แข็ง', 'ห้องผลิต', 0),
  ('PC0012', 'การตรวจจับโลหะ', 12, 'จุดตรวจสอบหาสิ่งเจือปนที่เป็นโลหะ (จุด CCP ที่สำคัญ)', 'ห้องผลิต', 1),
  ('PC0013', 'การบรรจุ/ซีล/ติดฉลาก', 13, 'การนำสินค้าลงถุง ซีลปิดปากถุง และติดฉลาก', 'ห้องบรรจุ แพ็กสินค้า', 0),
  ('PC0014', 'การแช่แข็ง', 14, 'การนำสินค้าเข้าอุโมงค์ลมเย็น (Air Blast) เพื่อแช่แข็ง', 'ห้องแช่เยือกแข็ง แบบรวดเร็ว', 0),
  ('PC0015', 'การจัดเก็บสินค้าแช่แข็ง', 15, 'การเก็บสินค้าสำเร็จรูปในห้องจัดเก็บอุณหภูมิ ≤-18°C', 'ห้องแช่เยือกแข็็ง จัดเก็บ FG', 0),
  ('PC0016', 'การจ่ายสินค้า/การจัดส่ง', 16, 'การโหลดสินค้าขึ้นรถเพื่อกระจายไปยังลูกค้า', 'จุดโหลดสินค้า', 0),
  ('PC0017', 'การทดลองเดินเครื่อง/ทดลองผลิต', 17, 'การทดสอบระบบหรือผลิตสินค้านำร่องก่อนผลิตจริง ประจำวัน', 'ห้องผลิต', 0),
  ('PC0018', 'การทดสอบชิมผลิตภัณฑ์', 18, 'การนำผลิตภัณฑ์มาทดสอบชิม', NULL, 0),
  ('PC0019', 'การตรวจสอบเชื้อจุลินทรีย์ก่อโรค', 19, NULL, NULL, 0),
  ('PC0020', 'การตรวจวัดคุณภาพน้ำ', 20, NULL, NULL, 0),
  ('PC0021', 'การตรวจวััดความเข้มข้นสารละลาย', 21, NULL, NULL, 0),
  ('PC0022', 'การล้างควบคุมสารก่อภูมิแพ้ (Allergen)', 22, NULL, NULL, 0),
  ('PC0023', 'การตรวจสภาพแวดล้อมและความปลอดภัย (OH&S)', 23, NULL, NULL, 0),
  ('PC0024', 'การตรวจประเมินด้านแรงงาน (ESG)', 24, NULL, NULL, 0),
  ('PC0025', 'การศึกษาอายุผลิตภัณฑ์ (Shelf-life Study)', 25, NULL, NULL, 0);

-- parameters: 32 records
INSERT OR IGNORE INTO parameters (id, name, description, category, spec, unit) VALUES
  ('PR0001', 'อุณหภูมิรถขนส่ง (เฉพาะกลุ่ม RM)', 'อุณหภูมิของรถขนส่งวัตถุดิบ ณ จุดที่ตรวจ', 'Temperature', '0 - 4', '°C'),
  ('PR0002', 'ค่า pH รับเข้าเนื้อสัตว์', 'ค่า pH รัับเข้าของวัตถุดิบ', 'Quality', '5.5 - 5.8', '-'),
  ('PR0003', 'อุณหภูมิแกนกลางวัตถุดิบ FG (สุุก)', 'อุณหภูมิจุดกึ่งกลางของชิ้นสินค้า', 'Temperature', '≥ 75', '°C'),
  ('PR0004', 'อุณหภูมิแกนกลางวัตถุดิบ RM', 'อุณหภูมิจุดกึ่งกลางของชิ้นสินค้า', 'Temperature', '0 - 7', '°C'),
  ('PR0005', 'อุณหภูมิห้องผลิต', 'อุณหภูมิของพื้นที่ปฏิบัติงาน (เช่น ห้องผลิต, ห้องบรรจุ)', 'Temperature', '≤ 12', '°C'),
  ('PR0006', 'อุณหภูมิห้องแช่เย็น', 'อุณหภูมิของตู้จัดเก็บหรือห้องแช่เย็น', 'Temperature', '(-4) - 4', '°C'),
  ('PR0007', 'อุณหภูมิห้องแช่แข็ง', 'อุณหภูมิของตู้จัดเก็บหรือห้องแช่่เยือกแข็ง', 'Temperature', '≤ -18', '°C'),
  ('PR0008', 'ตรวจจับโลหะ (เหล็ก)', 'เครื่องตรวจจับโลหะประเภท Ferrous (โลหะที่มีสารแม่เหล็ก/เหล็ก)', 'Food Safety', 'ø 1.0', 'มิลลิเมตร'),
  ('PR0009', 'ตรวจจับโลหะ (อลูมิเนียม ทองแดง ทองเหลือง)', 'เครื่องตรวจจับโลหะประเภท Non-Ferrous (เช่น อลูมิเนียม, ทองแดง, ทองเหลือง)', 'Food Safety', 'ø 1.5', 'มิลลิเมตร'),
  ('PR0010', 'ตรวจจับโลหะ (สแตนเลส)', 'เครื่องตรวจจับโลหะประเภท Stainless Steel (สแตนเลส)', 'Food Safety', 'ø 2.0', 'มิลลิเมตร'),
  ('PR0011', 'ขนาดของวัตถุดิบ (ใบมีดใหญ่)', 'ขนาดของวัตถุดิบหลังผ่านเครื่องสไลด์', 'Quality', 'ø 24.5 - 25.0', 'มิลลิเมตร'),
  ('PR0012', 'ขนาดของวัตถุดิบ (ใบมีดเล็ก)', 'ขนาดของวัตถุดิบหลังผ่านเครื่องสไลด์', 'Quality', 'ø 2.2 - 2.5', 'มิลลิเมตร'),
  ('PR0013', 'น้ำหนัก/ไม้', 'ความคลาดเคลื่อนของน้ำหนัก (เช่น น้ำหนักรายชิ้น)', 'Weight', 'within tolerance', 'กรัม / กิโลกรัม'),
  ('PR0014', 'น้ำหนักสุทธิ / รวม', 'น้ำหนักรวมของสินค้าในบรรจุภัณฑ์', 'Weight', 'within tolerance', 'กรัม / กิโลกรัม'),
  ('PR0015', 'จำนวนไม้', 'จำนวนไม้ของสินค้าในบรรจุภัณฑ์', 'Visual', 'อ้างอิง Spec. ผลิตภัณฑ์', '-'),
  ('PR0016', 'ลักษณะปรากฏ', 'รูปลักษณ์ หรือสิ่งที่ปรากฎภายนอกโดยรวม', 'Quality', 'ปกติ', '-'),
  ('PR0017', 'สิ่งแปลกปลอม (เส้นผม พลาสติก แมลง)', 'สิ่งเจือปนที่ไม่อนุญาตให้มี (เช่น เส้นผม, พลาสติก, แมลง)', 'Quality', 'ไม่พบสิ่งแปลกปลอม', '-'),
  ('PR0018', 'Physical check (สี , กลิ่น , เนื้อสัมผัส)', 'สี กลิ่น เนื้อสัมผัสของผลิตภัณฑ์ต้องตรงตามมาตรฐานที่กำหนด', 'Quality', 'ตรงตามมาตรฐาน', '-'),
  ('PR0019', 'ความสมบูรณ์ของรอยซีล', 'ไม่มีความเสียหาย ไม่รั่วซึม รอยซีลสมบูรณ์', 'Visual', 'ไม่เสียหาย / ไม่รั่วซึม', '-'),
  ('PR0020', 'ฉลาก และสติ๊กเกอร์', 'ถูกต้อง ครบถ้วน อ่านได้ชัดเจน', 'Visual', 'ข้อมูลถูกต้อง / ชัดเจน', '-'),
  ('PR0021', 'เอกสาร', 'ถูกต้อง ครบถ้วน ณ วันส่งมอบ', 'Process', 'ข้อมูลถูกต้อง ครบถ้วน', '-'),
  ('PR0022', 'เวลาในการทำให้อาหารสุก', 'ระยะเวลาในการให้ความร้อน', 'Process', 'อ้างอิง QP', '-'),
  ('PR0023', 'ค่า pH ตรวจวัดคุณภาพน้ำ', NULL, 'Food Safety', '6.5 - 8.5', NULL),
  ('PR0024', 'ค่าคลอรีนอิสระ', NULL, 'Food Safety', '0.2 - 0.5', 'ppm.'),
  ('PR0025', 'ตรวจวัด Coliform', NULL, NULL, NULL, 'ppm.'),
  ('PR0026', 'ความเข้มข้นสารละลาย QAC', NULL, NULL, 200, 'ppm.'),
  ('PR0027', 'ความเข้มข้นสารละลาย คลอรีน', NULL, NULL, 200, 'ppm.'),
  ('PR0028', 'ระดับแสงสว่าง (Light)', NULL, NULL, '≥ 300 (หรือตาม จป.)', 'LUX'),
  ('PR0029', 'ระดับเสียง (Sound)', NULL, NULL, '≤ 85', 'db'),
  ('PR0030', 'ป้ายทางออกฉุกเฉิน', NULL, NULL, 'สว่าง / ใช้งานได้', NULL),
  ('PR0031', 'เชื้อจุลินทรีย์ (TPC / Salmonella)', NULL, NULL, 'ผ่านเกณฑ์ Thai FDA', NULL),
  ('PR0032', 'Allergen Swab Test (Protein)', NULL, NULL, 'ไม่พบโปรตีนตกค้าง', NULL);

-- equipment: 32 records
INSERT OR IGNORE INTO equipment (id, name, type, usage) VALUES
  ('MDB001', 'เครื่องชั่งดิจิตอล พิกัด 6 กิโลกรัม (ห้องเครื่องเสียบ)', 'Measuring', 'ชั่งน้ำหนักผลิตภัณฑ์  (น้ำหนัก / ไม้ , น้ำหนักรวม)'),
  ('MDB002', 'เครื่องชั่งดิจิตอล พิกัด 6 กิโลกรัม (ห้องเสียบมือ)', 'Measuring', 'ชั่งน้ำหนักผลิตภัณฑ์  (น้ำหนัก / ไม้ , น้ำหนักรวม)'),
  ('MDB003', 'เครื่องชั่งดิจิตอล พิกัด 15 กิโลกรัม (ห้องชั่งสาร)', 'Measuring', 'ชั่งน้ำหนักส่วนผสม กลุ่ม DM'),
  ('MDB004', 'เครื่องชั่งดิจิตอล พิกัด 15 กิโลกรัม (ห้องเครื่องเสียบ)', 'Measuring', 'ชั่งน้ำหนักผลิตภัณฑ์  (น้ำหนัก / ไม้ , น้ำหนักรวม)'),
  ('MDB006', 'เครื่องชั่งดิจิตอล พิกัด 100 กิโลกรัม (จุดเตรียมวัตถุดิบ)', 'Measuring', 'ชั่งน้ำหนักวัตถุดิบ (ก่อนลดขนาด และแบ่งบรรจุถุง)'),
  ('MDB007', 'เครื่องชั่งดิจิตอล พิกัด 15 กิโลกรัม (แผนกคุณภาพ)', 'Measuring', 'สุ่มชั่งตลอดกระบวนการผลิต - QA/QC'),
  ('MDB008', 'เครื่องชั่งดิจิตอล พิกัด 15 กิโลกรัม (ห้องเสียบมือ)', 'Measuring', 'ชั่งน้ำหนักผลิตภัณฑ์  (น้ำหนัก / ไม้ , น้ำหนักรวม)'),
  ('MDB009', 'เครื่องชั่งดิจิตอล พิกัด 150 กิโลกรัม (ห้องหมัก - ผสม)', 'Measuring', 'ชั่งน้ำหนักวัตถุดิบ (ก่อนลดขนาด และแบ่งบรรจุถุง)'),
  ('MDB010', 'เครื่องชั่งดิจิตอล พิกัด 150 กิโลกรัม (จุดรับวัตถุดิบ RM)', 'Measuring', 'ชั่งน้ำหนักวัตถุดิบ กลุ่ม RM'),
  ('MTC001', 'ห้องแช่เย็นควบคุมอุณหภูมิ (ห้อง RM)', 'Measuring', 'ห้องจัดเก็บวัตถุดิบกลุ่ม RM'),
  ('MTC002', 'ห้องปฏิบัติงานควบคุมอุณหภูมิ (ห้องชั่งสาร)', 'Measuring', 'ห้องปฏิบัติงาน'),
  ('MTC003', 'ห้องแช่เย็นควบคุมอุณหภูมิ (ห้องพักหมูหมัก)', 'Measuring', 'ห้องจัดเก็บหมูหมักบรรจุถุง'),
  ('MTC004', 'ห้องปฏิบัติงานควบคุมอุณหภูมิ (ห้องผลิต)', 'Measuring', 'ห้องปฏิบัติงาน'),
  ('MTF001', 'ห้องแช่เยือกแข็งควบคุมอุณหภูมิ', 'Measuring', 'ห้อง FG 1'),
  ('MTF002', 'ห้องแช่เยือกแข็งควบคุมอุณหภูมิ', 'Measuring', 'ห้อง FG 1.1'),
  ('MTF003', 'ห้องแช่เยือกแข็งควบคุมอุณหภูมิ', 'Measuring', 'ห้อง FG 2'),
  ('MTF004', 'ห้องแช่เยือกแข็งควบคุมอุณหภูมิ', 'Measuring', 'ห้อง FG 3'),
  ('MTF005', 'ห้องแช่เยือกแข็งควบคุมอุณหภูมิ', 'Measuring', 'ห้อง Waste'),
  ('MDT001', 'HANNA - IC', 'Measuring', 'วัดอุณหภูมิแกนกลางวัตถุดิบ (จุดรับวัตถุดิบ กลุ่ม RM)'),
  ('MDT002', 'HANNA - IP', 'Measuring', 'วัดอุณหภูมิวัตถุดิบ / หมูหมักบน Hopper และอื่นๆในห้องผลิต'),
  ('MDT003', 'Data Logger', 'Measuring', 'เก็บข้อมูลผลิตภัณฑ์'),
  ('MIT001', 'Infared Thermometer - QA', 'Measuring', 'วัดอุณหภูมิรถขนส่งในกลุ่มวัตถุดิบ RM'),
  ('MIT002', 'Infared Thermometer - PD', 'Measuring', 'วัดอุณหภูมิพื้นผิวผลิตภัณฑ์'),
  ('MRF001', 'Refractometer (Brix)', 'Measuring', 'วัดค่าความหวานของน้ำซอสหมัก และผลิตภัณฑ์'),
  ('MRF002', 'Refractometer (Salt)', 'Measuring', 'วัดค่าความเค็มของน้ำซอสหมัก และผลิตภัณฑ์'),
  ('MPH001', 'pH Meter 001', 'Measuring', 'วัดค่าคุณภาพของน้ำใช้ภายในโรงงาน'),
  ('MPH002', 'pH Meter 002', 'Measuring', 'วัดค่าคุณภาพของน้ำใช้ภายในโรงงาน (เครื่องสำรอง)'),
  ('TMD001', 'Metal Detector - S', 'Testing', 'ทดสอบสิ่งแปลกปลอมที่ปะปนกับผลิตภัณฑ์ เครื่อง S'),
  ('TMD002', 'Metal Detector - L', 'Testing', 'ทดสอบสิ่งแปลกปลอมที่ปะปนกับผลิตภัณฑ์ เครื่อง L'),
  ('VSC001', 'Visual Check', 'Visual', 'ตรวจสอบด้วยสายตา'),
  ('MTS001', 'Test Strips ความเข้มข้นคลอรีนอิสระ 0 - 400 ppm.', 'Measuring', 'วัดความเข้มข้นคลอรีนอิสระ (ppm.)'),
  ('MTS002', 'Test Strips ความเข้้มข้นสารละลาย QAC 0 - 400 ppm.', 'Measuring', 'วัดความเข้มข้นสารละลาย QAC (ppm.)');

-- ccps: 7 records
INSERT OR IGNORE INTO ccps (id, processId, name, criticalLimit) VALUES
  ('CCP001', 'PC0012', 'ตรวจจับสิ่งแปลกปลอม Fe', 'ø 1.0 mm.'),
  ('CCP002', 'PC0012', 'ตรวจจับสิ่งแปลกปลอม Non Fe', 'ø 1.5 mm.'),
  ('CCP003', 'PC0012', 'ตรวจจับสิ่งแปลกปลอม SUS', 'ø 2.0 mm.'),
  ('CCP021', 'PC0010', 'ตรวจจับสิ่งแปลกปลอม Fe', 'ø 1.0 mm.'),
  ('CCP022', 'PC0010', 'ตรวจจับสิ่งแปลกปลอม Non Fe', 'ø 1.5 mm.'),
  ('CCP023', 'PC0010', 'ตรวจจับสิ่งแปลกปลอม SUS', 'ø 2.0 mm.'),
  ('CCP004', 'PC0008', 'อุณหภูมิหลังการทำให้สุก', '≥ 75 °C');

-- process_parameter_map: 21 records
INSERT OR IGNORE INTO process_parameter_map (id, processId, processName, parameterId) VALUES
  ('MAP0001', 'PC0001', 'การรับเข้าวัตถุดิบ', 'PR0019'),
  ('MAP0002', 'PC0001', 'การรับเข้าวัตถุดิบ', 'PR0001'),
  ('MAP0003', 'PC0001', 'การรับเข้าวัตถุดิบ', 'PR0004'),
  ('MAP0004', 'PC0001', 'การรับเข้าวัตถุดิบ', 'PR0002'),
  ('MAP0005', 'PC0001', 'การรับเข้าวัตถุดิบ', 'PR0016'),
  ('MAP0006', 'PC0001', 'การรับเข้าวัตถุดิบ', 'PR0015'),
  ('MAP0007', 'PC0002', 'การจัดเก็บวัตถุดิบ', 'PR0006'),
  ('MAP0008', 'PC0004', 'การชั่งน้ำหนัก', 'PR0011'),
  ('MAP0009', 'PC0008', 'การผสมและการหมัก', 'PR0004'),
  ('MAP0010', 'PC0009', 'การเสียบไม้และขึ้นรูป', 'PR0011'),
  ('MAP0011', 'PC0009', 'การเสียบไม้และขึ้นรูป', 'PR0012'),
  ('MAP0012', 'PC0009', 'การเสียบไม้และขึ้นรูป', 'PR0013'),
  ('MAP0013', 'PC0010', 'การทำให้สุก/การปิ้งย่าง', 'PR0003'),
  ('MAP0014', 'PC0010', 'การทำให้สุก/การปิ้งย่าง', 'PR0020'),
  ('MAP0015', 'PC0012', 'การตรวจจับโลหะ', 'PR0008'),
  ('MAP0016', 'PC0012', 'การตรวจจับโลหะ', 'PR0009'),
  ('MAP0017', 'PC0012', 'การตรวจจับโลหะ', 'PR0010'),
  ('MAP0018', 'PC0013', 'การบรรจุ/ซีล/ติดฉลาก', 'PR0018'),
  ('MAP0019', 'PC0013', 'การบรรจุ/ซีล/ติดฉลาก', 'PR0017'),
  ('MAP0020', 'PC0013', 'การบรรจุ/ซีล/ติดฉลาก', 'PR0015'),
  ('MAP0021', 'PC0015', 'การจัดเก็บสินค้าแช่แข็ง', 'PR0007');

-- machines: 7 records
INSERT OR IGNORE INTO machines (id, name, type, processId) VALUES
  ('MC001', 'meat_cutter', 'processing_machine', 'P003'),
  ('MC002', 'marinade_mixer', 'processing_machine', 'P005'),
  ('MC003', 'skewer_machine', 'processing_machine', 'P006'),
  ('MC004', 'grill_machine', 'cooking_machine', 'P007'),
  ('MC005', 'metal_detector_unit', 'inspection_machine', 'P009'),
  ('MC006', 'vacuum_packer', 'packing_machine', 'P010'),
  ('MC007', 'blast_freezer', 'freezing_machine', 'P011');