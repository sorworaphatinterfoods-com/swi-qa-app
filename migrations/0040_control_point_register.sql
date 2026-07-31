-- 0040_control_point_register.sql
-- Load the approved process flow diagram's control scheme for the RTC and
-- Par-cooked streams, and give the register the columns it needs to hold it.
--
-- The register contradicted the approved document in four ways:
--   1. CCP004 (อุณหภูมิหลังการทำให้สุก ≥75°C) was attached to PC0008 การผสมและ
--      การหมัก. Marinating is not a kill step; the document puts that limit at
--      the heating step. Corrected to PC0010.
--   2. The Par-cooked kill step (Core Temp ≥ 60°C) was absent entirely, so the
--      whole par-cooked stream had no CCP controlling lethality.
--   3. Metal detection existed twice -- CCP001-003 on PC0012 (right process,
--      but with "Detect and Reject" and no test-piece size) and CCP021-023 on
--      PC0010 การให้ความร้อน (wrong process). The document has one metal
--      detector CCP per stream carrying all three test pieces.
--   4. OPRP and CP had no representation at all. The document numbers CP-01..04
--      and OPRP-01..04 alongside the CCPs as one control scheme per stream, so
--      the register needs to carry all three types or it does not match.
--
-- Numbering: the document restarts at CCP-01 in every stream, so its labels are
-- not unique across the plan. The primary key stays unique (CCP01xx = RTC,
-- CCP02xx = Par-cooked) and docRef carries the number as printed, so records
-- reference something stable while printed output matches the approved copy.
--
-- monitoring and correction are left empty. The diagram states limits, not
-- monitoring procedures or corrective actions -- those are HACCP principles 4
-- and 5 and have to come from QA. Filling them from the limits would fabricate
-- procedures that no approved document backs.
--
-- Safe to apply: nothing references ccps.id. haccp_records stores a free-text
-- ccpName, and ccp_deviations and hazard_analysis are both empty.
--
-- RTE is deliberately not loaded -- QA is reviewing that stream separately.
-- Only CCP004's wrong process link is corrected here.

ALTER TABLE finished_goods ADD COLUMN productStream  TEXT;  -- RTC | PARCOOKED | RTE
ALTER TABLE ccps           ADD COLUMN stream         TEXT;  -- which stream's plan
ALTER TABLE ccps           ADD COLUMN docRef         TEXT;  -- number as printed on the diagram
ALTER TABLE ccps           ADD COLUMN controlType    TEXT;  -- CCP | OPRP | CP
ALTER TABLE ccps           ADD COLUMN stepNo         TEXT;  -- step number on the diagram
ALTER TABLE ccps           ADD COLUMN status         TEXT;  -- Active | Superseded

-- ── สาย 1: RTC (ดิบพร้อมปรุง / Ready to Cook) ────────────────────────────
INSERT OR REPLACE INTO ccps (id, stream, docRef, controlType, stepNo, processId, name, criticalLimit, status) VALUES
 ('CCP0101','RTC','CP-01',  'CP',  '6', 'PC0008','ควบคุมสารก่อภูมิแพ้ — ล้างทำความสะอาดเครื่องจักรก่อนเปลี่ยนผลิตภัณฑ์','ล้างทำความสะอาดเครื่องจักรก่อนเปลี่ยนผลิตภัณฑ์ทุกครั้ง','Active'),
 ('CCP0102','RTC','OPRP-01','OPRP','6', 'PC0008','ควบคุมสารก่อภูมิแพ้ — แยกไลน์ผลิต / แยกวันผลิต','แยกไลน์ผลิตหรือแยกวันผลิต สำหรับสูตรที่มีและไม่มีสารก่อภูมิแพ้ (ถั่วเหลือง, แป้งสาลี, นม, งา)','Active'),
 ('CCP0103','RTC','CP-02',  'CP',  '7', 'PC0009','ขึ้นรูป / เสียบไม้ / จัดวางลงถาด','อุณหภูมิเนื้อสัตว์ ≤ 7 °C','Active'),
 ('CCP0104','RTC','OPRP-02','OPRP','8', 'PC0014','แช่เยือกแข็งฉับพลัน (Blast Freezer)','-35 °C ถึง -40 °C จนกว่า Core Temp ≤ -18 °C','Active'),
 ('CCP0105','RTC','OPRP-03','OPRP','9', 'PC0013','บรรจุภัณฑ์ (Vacuum / ถุง / กล่อง)','อุณหภูมิห้อง 10 - 15 °C','Active'),
 ('CCP0106','RTC','CCP-01', 'CCP', '10','PC0012','ตรวจสอบสิ่งเจือปน (Metal Detector)','Test Piece: Fe ø1.0 mm · Non-Fe ø1.5 mm · SUS ø2.0 mm — ตรวจพบต้องคัดแยกออก (Detect & Reject)','Active'),
 ('CCP0107','RTC','OPRP-04','OPRP','11','PC0013','บรรจุลงลัง / ติดฉลาก (Lot No.)','อุณหภูมิห้อง 10 - 15 °C','Active'),
 ('CCP0108','RTC','CP-03',  'CP',  '12','PC0015','จัดเก็บสินค้าสำเร็จรูป','ห้องเย็น ≤ -18 °C','Active'),
 ('CCP0109','RTC','CP-04',  'CP',  '13','PC0016','กระจายสินค้า (รถห้องเย็น)','≤ -18 °C ตลอดเส้นทาง','Active');

-- ── สาย 2: Par-cooked (กึ่งสุก) ──────────────────────────────────────────
INSERT OR REPLACE INTO ccps (id, stream, docRef, controlType, stepNo, processId, name, criticalLimit, status) VALUES
 ('CCP0201','PARCOOKED','CP-01',  'CP',  '6', 'PC0008','ควบคุมสารก่อภูมิแพ้ — ล้างทำความสะอาดเครื่องจักรก่อนเปลี่ยนผลิตภัณฑ์','ล้างทำความสะอาดเครื่องจักรก่อนเปลี่ยนผลิตภัณฑ์ทุกครั้ง','Active'),
 ('CCP0202','PARCOOKED','OPRP-01','OPRP','6', 'PC0008','ควบคุมสารก่อภูมิแพ้ — แยกไลน์ผลิต / แยกวันผลิต','แยกไลน์ผลิตหรือแยกวันผลิต สำหรับสูตรที่มีและไม่มีสารก่อภูมิแพ้ (ถั่วเหลือง, แป้งสาลี, นม, งา)','Active'),
 ('CCP0203','PARCOOKED','CP-02',  'CP',  '7', 'PC0009','ขึ้นรูป / เสียบไม้ / จัดวางลงถาด','อุณหภูมิเนื้อสัตว์ ≤ 7 °C','Active'),
 ('CCP0204','PARCOOKED','CCP-01', 'CCP', '9', 'PC0010','ผ่านความร้อนระยะสั้น (Par-cooking) — นึ่ง / อบ / ทอด (Pre-fried)','อุณหภูมิแกนกลาง (Core Temp) ≥ 60 °C','Active'),
 ('CCP0205','PARCOOKED','OPRP-02','OPRP','8', 'PC0014','แช่เยือกแข็งฉับพลัน (Blast Freezer)','-35 °C ถึง -40 °C จนกว่า Core Temp ≤ -18 °C','Active'),
 ('CCP0206','PARCOOKED','OPRP-03','OPRP','10','PC0013','บรรจุภัณฑ์ (Vacuum / ถุง / กล่อง)','อุณหภูมิห้อง 10 - 15 °C','Active'),
 ('CCP0207','PARCOOKED','CCP-02', 'CCP', '11','PC0012','ตรวจสอบสิ่งเจือปน (Metal Detector)','Test Piece: Fe ø1.0 mm · Non-Fe ø1.5 mm · SUS ø2.0 mm — ตรวจพบต้องคัดแยกออก (Detect & Reject)','Active'),
 ('CCP0208','PARCOOKED','OPRP-04','OPRP','12','PC0013','บรรจุลงลัง / ติดฉลาก (Lot No.)','อุณหภูมิห้อง 10 - 15 °C','Active'),
 ('CCP0209','PARCOOKED','CP-03',  'CP',  '13','PC0015','จัดเก็บสินค้าสำเร็จรูป','ห้องเย็น ≤ -18 °C','Active'),
 ('CCP0210','PARCOOKED','CP-04',  'CP',  '14','PC0016','กระจายสินค้า (รถห้องเย็น)','≤ -18 °C ตลอดเส้นทาง','Active');

-- ── retire the rows the document supersedes ──────────────────────────────
-- CCP001-003 split metal detection into three CCPs; the document treats the
-- detector as one CCP carrying three test pieces. CCP021-023 duplicated it
-- against the wrong process.
UPDATE ccps SET status='Superseded', modified=datetime('now')
 WHERE id IN ('CCP001','CCP002','CCP003','CCP021','CCP022','CCP023');

-- CCP004 is the RTE kill step and stays for that stream's review, but its
-- process link was simply wrong -- corrected from marinating to heating.
UPDATE ccps SET processId='PC0010', stream='RTE', docRef='CCP-01', controlType='CCP',
                stepNo='8', status='Active', modified=datetime('now')
 WHERE id='CCP004';

-- Everything already in the table predates these columns; default them so the
-- register has no rows in an undefined state.
UPDATE ccps SET controlType='CCP' WHERE controlType IS NULL;
UPDATE ccps SET status='Active'   WHERE status IS NULL;
