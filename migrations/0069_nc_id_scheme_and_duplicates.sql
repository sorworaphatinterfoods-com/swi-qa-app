-- 0069_nc_id_scheme_and_duplicates.sql
--
-- QA spotted that NC0028 and NC0029 carry the wrong number shape. They do, and
-- pulling that thread found six non-conforming ids and three duplicate pairs.
--
-- FM-QA-20 numbers NCRs as NCR-<พ.ศ.><เดือน>-<ลำดับในเดือน>. The app's nextId()
-- builds ids by taking the trailing digits of the highest existing id and
-- padding to four, which can only ever produce NC0030-style numbers. So every
-- NCR the app raised automatically came out with a number the paper system does
-- not recognise — and someone re-keyed the same findings by hand under the
-- correct number. The register ended up holding both.
--
--   source IPI0003 → NC0026 (04/06, ปิด)  และ  NC-256906-001 (12/06, ปิด)
--   source PST0003 → NC0027 (16/06, ปิด)  และ  NCR-256906-002 (16/06, ปิด)
--   source RCV0040 → NC0028 (19/06, เปิด) และ  ์NCR-256906-003 (19/06, ปิด)
--
-- The third pair matters. NC0028 has been showing as a Major sitting Open since
-- June, and it is not — its twin was closed the same day. The Open row is the
-- machine's copy of a finding that was dealt with under the other number.
--
-- Two ids are corrected here because there is no judgement in either: one has a
-- stray Thai character in front of it, and one is a genuine single record with
-- no duplicate. The three pairs are annotated, not merged — deciding which copy
-- of a nonconformity record survives is QA's, and nothing is deleted.
--
-- Checked before renaming: no ncRef or ncId anywhere in the database points at
-- any NC00xx id.

-- ── 1. กำหนดเสร็จของข้อบกพร่องเดิม ตามที่ QA กำหนด ──────────────────────────
UPDATE nc_capa SET
  dueDate = '2026-06-30',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE status != 'Closed' AND date != '2026-08-15' AND (dueDate IS NULL OR dueDate = '');

-- ── 2. แบ่งสองระยะตามที่ QA ตัดสิน ──────────────────────────────────────────
UPDATE nc_capa SET
  correctiveAction = 'แบ่งการดำเนินการเป็นสองระยะ ตามที่ QA ตัดสินเมื่อ 15/08/26

ระยะที่ 1 — ภายใน 09/09/2569 (ก่อนการตรวจติดตาม)
วิเคราะห์อันตรายขั้นตอนที่ 8 (การชั่งส่วนผสมที่มีสารก่อภูมิแพ้) และขั้นตอนที่ 15 (การติดฉลากและสติกเกอร์ล็อต) ให้เสร็จสมบูรณ์ พร้อมให้คะแนน P/S/R และบันทึกเหตุผล
· ใช้ใบงาน docs/HA-worksheet-step8-15 เป็นเอกสารประกอบการประชุม
· ต้องปิด NCR-256908-016 บัญชีสารก่อภูมิแพ้ก่อน เพราะเป็นข้อมูลตั้งต้น

ระยะที่ 2 — หลังการตรวจติดตาม (ยังไม่กำหนดวัน รอ QA ระบุ)
วิเคราะห์อันตรายขั้นตอนที่เหลือให้ครบตามแผนภูมิ 19 ขั้นตอน ได้แก่ ขั้นตอนที่ 1.2, 1.3, 2, 4, 5–7, 9, 10, 14, 16, 17, 18 และ 19

เหตุผลของการแบ่งระยะ: การวิเคราะห์อันตรายเป็นงานของคณะทำงานทั้งคณะ ไม่ใช่งานที่ QA ทำคนเดียวได้ การกำหนดให้เสร็จครบ 14 ขั้นตอนภายใน 24 วันมีโอกาสไม่ทันสูง และข้อบกพร่องที่เลยกำหนดในวันตรวจจะถูกอ่านว่าระบบ CAPA ไม่ทำงาน ซึ่งหนักกว่าข้อบกพร่องที่ยังอยู่ในกำหนด
การแสดงระยะที่ 1 เสร็จตามกำหนด พร้อมแผนระยะที่ 2 ที่มีวันชัดเจน เป็นหลักฐานว่าระบบเดินอยู่',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-005';

UPDATE nc_capa SET
  correctiveAction = 'แบ่งการดำเนินการเป็นสองระยะ ตามที่ QA ตัดสินเมื่อ 15/08/26

ระยะที่ 1 — ภายใน 09/09/2569 (ก่อนการตรวจติดตาม)
เมื่อผลการวิเคราะห์ขั้นตอนที่ 8 และ 15 ออกแล้ว ให้ยืนยันหรือแก้ไขแผนควบคุมของ OPRP-04 และ OPRP-07 ที่ร่างไว้ใน QM-QA-04 Rev.06 ข้อ 4 ให้เป็นฉบับที่ใช้จริง พร้อมกำหนดความถี่และผู้รับผิดชอบที่ยังเว้นว่างอยู่

ระยะที่ 2 — หลังการตรวจติดตาม (ยังไม่กำหนดวัน รอ QA ระบุ)
เขียนแผนควบคุมของ OPRP ที่เหลือให้ครบ ตามจำนวนที่รอดจากการให้คะแนนความเสี่ยงในระยะที่ 2 ของ NCR-256908-005

เหตุผลของการแบ่งระยะ: จำนวนแผนควบคุมที่ต้องเขียนยังไม่ทราบ เพราะขึ้นกับผลการให้คะแนน หากขั้นตอนใดได้คะแนนต่ำกว่า 6 เกณฑ์ในข้อ 2 ของ QM-QA-04 อนุญาตให้ควบคุมด้วย PRP ซึ่งจะลดจำนวนลง
· การประกาศจุดควบคุมน้อยจุดแต่เฝ้าระวังและมีบันทึกครบ ดีกว่าการประกาศ 8 จุดแล้วพิสูจน์ไม่ได้แม้แต่จุดเดียว',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-004';

-- ── 3. แก้รหัสสองรายการที่ไม่มีข้อต้องตัดสิน ────────────────────────────────
-- อักขระไทย ์ (U+0E4C) ติดอยู่หน้ารหัส มองด้วยตาแทบไม่เห็น แต่ทำให้เรียงลำดับและค้นหาไม่เจอ
UPDATE nc_capa SET
  id = 'NCR-256906-003',
  notes = TRIM(COALESCE(notes,'') || CASE WHEN COALESCE(notes,'')='' THEN '' ELSE ' | ' END ||
    '[15/08/26] แก้รหัสจากเดิมที่มีอักขระไทย ์ ติดอยู่ข้างหน้า ทำให้ค้นหาและเรียงลำดับไม่ตรง · เนื้อหาไม่เปลี่ยน'),
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id LIKE '%NCR-256906-003' AND id <> 'NCR-256906-003';

-- NC0029 ไม่มีคู่ซ้ำ เป็นรายการเดี่ยวที่ระบบรันรหัสผิดรูปแบบ · เดือน 07/2569 ยังไม่มีลำดับใด
UPDATE nc_capa SET
  id = 'NCR-256907-001',
  notes = TRIM(COALESCE(notes,'') || CASE WHEN COALESCE(notes,'')='' THEN '' ELSE ' | ' END ||
    '[15/08/26] แก้รหัสจากเดิม NC0029 ซึ่งเป็นรูปแบบที่ระบบรันเอง ไม่ตรงกับรูปแบบ NCR-<พ.ศ.><เดือน>-<ลำดับ> ตาม FM-QA-20 · เนื้อหาไม่เปลี่ยน · ตรวจแล้วว่าไม่มีบันทึกใดในระบบอ้างถึงรหัสเดิม'),
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NC0029';

-- ── 4. คู่ซ้ำ 3 คู่ — บันทึกไว้ ไม่ยุบให้ ──────────────────────────────────
UPDATE nc_capa SET
  notes = TRIM(COALESCE(notes,'') || CASE WHEN COALESCE(notes,'')='' THEN '' ELSE ' | ' END ||
    '[15/08/26 ตรวจพบบันทึกซ้ำ] รายการนี้บันทึกไว้สองครั้งจากเหตุการณ์เดียวกัน อ้างอิงต้นเรื่องเดียวกัน · สาเหตุ: ระบบสร้าง NC อัตโนมัติด้วยรหัสรูปแบบ NC00xx ซึ่งไม่ตรงกับรูปแบบตาม FM-QA-20 จึงมีการป้อนซ้ำด้วยมือภายใต้รหัสที่ถูกต้อง · ต้องเลือกเก็บฉบับเดียวและปิดอีกฉบับโดยอ้างถึงกัน ไม่ลบทิ้ง เพราะบันทึกข้อบกพร่องเป็นส่วนหนึ่งของร่องรอยการตรวจสอบ · การตัดสินว่าเก็บฉบับใดเป็นอำนาจของ QA'),
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id IN ('NC0026','NC-256906-001','NC0027','NCR-256906-002','NC0028','NCR-256906-003');

-- คู่ที่สามต่างกันตรงสถานะ ซึ่งเป็นเหตุให้ยอดข้อบกพร่องค้างคลาดเคลื่อน
UPDATE nc_capa SET
  notes = COALESCE(notes,'') || ' | ⚠️ คู่ของรายการนี้คือ NCR-256906-003 ซึ่งปิดไปแล้วตั้งแต่ 19/06 · รายการนี้จึงค้างสถานะเปิดอยู่ทั้งที่เหตุการณ์ได้รับการแก้ไขแล้ว ทำให้ยอดข้อบกพร่องค้างสูงกว่าความเป็นจริง และทำให้ดูเหมือนมี Major ค้างมาสองเดือนโดยไม่มีความคืบหน้า · แนะนำให้ปิดรายการนี้โดยอ้างถึง NCR-256906-003 เป็นเอกสารหลัก',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NC0028';

-- คู่แรกลงวันที่ต่างกัน ทั้งที่อ้างต้นเรื่องเดียวกัน
UPDATE nc_capa SET
  notes = COALESCE(notes,'') || ' | ⚠️ คู่นี้ลงวันที่ไม่ตรงกัน — NC0026 ระบุ 04/06/2569 ส่วน NC-256906-001 ระบุ 12/06/2569 ทั้งที่อ้างต้นเรื่อง IPI0003 เดียวกัน · ต้องตรวจกับบันทึกต้นเรื่องว่าวันใดถูก ก่อนเลือกฉบับที่จะเก็บ · นอกจากนี้ NC-256906-001 ยังขาดตัวอักษร R และเก็บวันที่ในรูปแบบ วว/ดด/ปป ต่างจากรายการอื่นที่ใช้รูปแบบ ปปปป-ดด-วว',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id IN ('NC0026','NC-256906-001');
