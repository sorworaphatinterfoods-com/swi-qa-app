-- 0072_chemicals_dedupe.sql
--
-- The chemicals master held 18 rows for 6 chemicals. Each one existed three
-- times under three id formats, and QA confirmed on 16/08/26 that the CM000n
-- set is the register in use:
--
--   CM - 001 · CM001 · CM0001   CL - NEXGEN PH-1000
--   CM - 002 · CM002 · CM0002   SN - คลอรีนน้ำ 10%
--   CM - 003 · CM003 · CM0003   CL - ENRICH D028
--   CM - 004 · CM004 · CM0004   SN - NEXGEN ALCO 70B
--   CM - 006 · CM006 · CM0006   SN - NEXGEN SAN 800
--   CM - 007 · CM007 · CM0007   CL - NEXGEN MP-1000
--
-- The twelve older rows are deleted. They are master data, not records — no
-- audit trail is lost, and the full list is above if any needs restoring.
--
-- References are repointed first. Two cleaning-and-sanitation records
-- (GCL0001, GCL0002) point at CM002; deleting before repointing would leave
-- them naming a chemical that no longer exists.

-- ── 1. ย้ายการอ้างอิงไปยังรหัสที่ใช้จริงก่อน ────────────────────────────────
UPDATE ghp_cleaning_sanitation SET
  chemicalUsed = CASE TRIM(chemicalUsed)
    WHEN 'CM - 001' THEN 'CM0001' WHEN 'CM001' THEN 'CM0001'
    WHEN 'CM - 002' THEN 'CM0002' WHEN 'CM002' THEN 'CM0002'
    WHEN 'CM - 003' THEN 'CM0003' WHEN 'CM003' THEN 'CM0003'
    WHEN 'CM - 004' THEN 'CM0004' WHEN 'CM004' THEN 'CM0004'
    WHEN 'CM - 006' THEN 'CM0006' WHEN 'CM006' THEN 'CM0006'
    WHEN 'CM - 007' THEN 'CM0007' WHEN 'CM007' THEN 'CM0007'
    ELSE chemicalUsed END,
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE TRIM(chemicalUsed) IN ('CM - 001','CM001','CM - 002','CM002','CM - 003','CM003',
                             'CM - 004','CM004','CM - 006','CM006','CM - 007','CM007');

UPDATE ghp_chemical_control SET
  chemical = CASE TRIM(chemical)
    WHEN 'CM - 001' THEN 'CM0001' WHEN 'CM001' THEN 'CM0001'
    WHEN 'CM - 002' THEN 'CM0002' WHEN 'CM002' THEN 'CM0002'
    WHEN 'CM - 003' THEN 'CM0003' WHEN 'CM003' THEN 'CM0003'
    WHEN 'CM - 004' THEN 'CM0004' WHEN 'CM004' THEN 'CM0004'
    WHEN 'CM - 006' THEN 'CM0006' WHEN 'CM006' THEN 'CM0006'
    WHEN 'CM - 007' THEN 'CM0007' WHEN 'CM007' THEN 'CM0007'
    ELSE chemical END,
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE TRIM(chemical) IN ('CM - 001','CM001','CM - 002','CM002','CM - 003','CM003',
                         'CM - 004','CM004','CM - 006','CM006','CM - 007','CM007');

-- ── 2. ลบรายการซ้ำ 12 แถว ──────────────────────────────────────────────────
DELETE FROM chemicals WHERE id IN (
  'CM - 001','CM - 002','CM - 003','CM - 004','CM - 006','CM - 007',
  'CM001','CM002','CM003','CM004','CM006','CM007');

-- ── 3. Q-San M — คำตอบของรหัสที่ชนกัน ──────────────────────────────────────
-- The retired rows carried the older trade name: CM006 was "SN - QAC (Q-San M)"
-- and the current CM0006 is "SN - NEXGEN SAN 800". Same code, same slot, renamed
-- product. So Q-San M is CM0006, and SD-QA-12 citing it as CM-002 is simply
-- wrong — CM0002 is and always was the chlorine.
UPDATE nc_capa SET
  correctiveAction = 'แก้รหัสสารเคมีใน SD-QA-12 ให้ตรงกับทะเบียนสารเคมีที่ใช้จริง

<b>คำตอบของรหัสที่ชนกัน</b> — ทะเบียนสารเคมีในระบบเก็บชื่อเดิมของ CM0006 ไว้ว่า "SN - QAC (Q-San M)" ส่วนชื่อปัจจุบันคือ "SN - NEXGEN SAN 800"
· <b>Q-San M คือ CM0006 ไม่ใช่ CM-002</b> — เป็นสินค้าตัวเดียวกันที่เปลี่ยนชื่อทางการค้า
· CM0002 เป็นคลอรีนน้ำ 10% มาตลอด ตรงกันทั้ง SD-QA-07 Rev.03 FM-QA-16 Stock Card และทะเบียนในระบบ

<b>สิ่งที่ต้องแก้ใน SD-QA-12 ตารางข้อ 6</b>
· แถว Q-San M — เปลี่ยนรหัสจาก CM-002 เป็น <b>CM0006</b> และควรเปลี่ยนชื่อเป็น NEXGEN SAN 800 (Q-San M) เพื่อให้ตรงกับฉลากบนภาชนะ
· แถวคลอรีนน้ำ — เปลี่ยนรหัสจาก CM-XXX เป็น <b>CM0002</b>
· ปรับรูปแบบรหัสทั้งฉบับเป็น CM000n ให้ตรงกับ SD-QA-07 และทะเบียน

<b>ยังต้องยืนยันหน้างาน</b> — ภาชนะจริงติดรหัสรูปแบบใดไว้ ถ้าติดเป็น CM-002 หรือ CM002 ต้องเปลี่ยนป้ายให้เป็น CM0002 ด้วย มิฉะนั้นเอกสารกับของจริงยังไม่ตรงกัน',
  notes = COALESCE(notes,'') || '

[16/08/26 — ได้คำตอบจากทะเบียนสารเคมีในระบบ]
ทะเบียนมี 18 แถวสำหรับสารเคมี 6 ตัว เพราะมีรหัส 3 รูปแบบซ้อนกัน คือ CM - 00n · CM00n · CM000n
· แถวรุ่นเก่าเก็บชื่อเดิมไว้ ทำให้ตอบได้ว่า <b>Q-San M คือ CM0006 (ปัจจุบันชื่อ NEXGEN SAN 800)</b> ไม่ใช่ CM-002
· ลบแถวซ้ำ 12 แถวออกแล้วตาม migration 0072 เหลือชุด CM000n ตามที่ QA ยืนยัน
· <b>ข้อสังเกตเพิ่ม:</b> ชื่อเดิมของ CM0004 คือ "SN - ALCOHOL 75%" ส่วนชื่อปัจจุบันคือ "SN - NEXGEN ALCO 70B" — ความเข้มข้น 75% กับ 70% ต่างกัน ต้องยืนยันว่าเปลี่ยนสินค้าจริงหรือเป็นการแก้ชื่อให้ตรงฉลาก เพราะกระทบการคำนวณเจือจางถ้ามีการใช้แอลกอฮอล์ในตารางเตรียมสาร
· <b>ไม่มี CM0005 ในทะเบียน</b> — เลขข้ามจาก CM0004 ไป CM0006 ต้องยืนยันว่าเคยมีแล้วตัดจำหน่าย หรือเป็นเลขที่ยังไม่เคยใช้',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-019';

-- ── 4. ข้อสังเกตจากบันทึกการทำความสะอาดสองรายการ ───────────────────────────
UPDATE nc_capa SET
  notes = COALESCE(notes,'') || '

[16/08/26 — ข้อสังเกตจากบันทึกที่มีอยู่ 2 รายการ]
บันทึกการทำความสะอาดและฆ่าเชื้อในระบบมี 2 รายการ ลงวันที่ 07/07/2026 ทั้งคู่ ใช้คลอรีน (CM0002) ที่ความเข้มข้น 200 ppm
· GCL0001 จุดฆ่าเชื้อรองเท้าบูท · GCL0002 จุดรับ RM และทางเดินพื้นที่ผลิต
· SD-QA-12 ตารางข้อ 6 ระบุคลอรีนไว้สำหรับ "ฆ่าเชื้อพื้นผิวทั่วไป / พื้น / ท่อ" ที่ 200 ppm ซึ่งตรงกับ GCL0002
· แต่ <b>ตารางไม่มีแถวของคลอรีนสำหรับบ่อแช่เท้า</b> — มีแต่แถว QAC ที่ 800–1,000 ppm สำหรับการใช้งานนั้น
· ไม่ได้แปลว่า 200 ppm ผิด แต่แปลว่าการใช้งานคู่นี้ยังไม่มีแถวรองรับในคู่มือ · เมื่อแก้ SD-QA-12 ตามข้อข้างต้น ควรเพิ่มแถวคลอรีนสำหรับบ่อแช่เท้าพร้อมความเข้มข้นที่กำหนด หรือระบุว่าบ่อแช่เท้าให้ใช้ QAC เท่านั้น',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-019';
