-- 0057_ccp1_monitoring_from_qm_qa_04_rev05.sql
--
-- CCP 1 keeps monitoring and corrective-action text that predates QM-QA-04
-- Rev.05. 0055 moved the row to the right step and 0054 pointed it at the right
-- plan, but the four columns an auditor actually reads at the CCP were never
-- updated. Transcribed here from QM-QA-04 Rev.05 ข้อ 4, which is the approved
-- control plan.
--
-- What was wrong, in order of how much it matters:
--
--   HOLD scope. The row said "Hold สินค้าที่ผลิตในชั่วโมงก่อนหน้า". The approved
--   plan says hold from the last round that tested good — the Risk Window. The
--   difference is the whole point of the hourly test: when a detector fails you
--   do not know when it started failing, so an hour is a guess. If the failure
--   began forty minutes into the previous hour the guess is lucky; if it began
--   at the last product change it is not. This is also the first question an
--   auditor asks at a metal detector, and the one that decides whether the CCP
--   is judged to be under control.
--
--   Frequency. The row listed two of the five occasions the plan requires —
--   ก่อนเริ่มผลิต and ทุก 1 ชม. Missing: เปลี่ยนผลิตภัณฑ์, หลังซ่อมบำรุง, ท้ายกะ.
--
--   Stop Line authority. Rev.04 added it and WI-QA-09 ข้อ 7 carries it: the
--   operator at the station, QC, the production supervisor and QA can all halt
--   the line without waiting for approval. Authority that is not written down
--   is not authority anyone uses at 02:00.
--
--   Machine failure. The plan is explicit that a detector too broken to test is
--   a CCP failure and that running past it is forbidden outright. The row said
--   nothing, and silence at a CCP reads as permission.
--
--   Product effect. The test piece goes against real product. A test piece run
--   through an empty aperture passes on machines that would miss the same metal
--   inside a skewer.
--
--   Document numbers. QP-QC-06 and FM-QC-28 do not exist — there is no QP-QC or
--   FM-QC series. They are QP-QA-06 and FM-QA-28.

UPDATE ccps SET
  monWhat = 'ประสิทธิภาพการตรวจจับและการดีดออก (Reject) ของเครื่อง
1) ผลิตภัณฑ์ทุกไม้ / ทุกแพ็ค ต้องผ่านเครื่องตรวจจับโลหะ 100%
2) ระบบ Reject ของเครื่องทำงานได้จริง — ตรวจจับได้อย่างเดียวไม่ถือว่าผ่าน',

  monHow = 'วางชุด Test Piece แนบไปกับผลิตภัณฑ์จริง (Product Effect) แล้วปล่อยผ่านเครื่อง ครบทั้ง 3 ชนิด (Fe / Non-Fe / SUS 304)
เครื่องต้องตรวจจับและคัดแยกออกได้ทั้ง 3 ชนิด จึงถือว่าผ่าน
หมายเหตุ: การทดสอบโดยปล่อย Test Piece ผ่านช่องเปล่าโดยไม่มีผลิตภัณฑ์ ไม่ถือเป็นการทดสอบที่ใช้ได้ เพราะไม่ได้จำลองผลของเนื้อผลิตภัณฑ์ต่อสัญญาณ',

  monFreq = 'ก่อนเริ่มผลิต · ทุก 1 ชั่วโมงระหว่างผลิต · เมื่อเปลี่ยนผลิตภัณฑ์ · หลังซ่อมบำรุง · ท้ายกะ',

  monWho = 'QC Line Inspector (ผู้เฝ้าระวัง) — ทวนสอบบันทึกโดยหัวหน้าแผนก QA',

  correction = '1. STOP LINE — หยุดสายการผลิตทันที พนักงานประจำจุด, QC, หัวหน้างานฝ่ายผลิต และ QA มีอำนาจสั่งหยุดได้เองโดยไม่ต้องรออนุมัติ (WI-QA-09 ข้อ 7)
2. NOTIFY — แจ้ง QA และฝ่ายวิศวกรรม
3. HOLD — กักกันผลิตภัณฑ์ย้อนหลังตั้งแต่รอบที่ทดสอบผ่านครั้งล่าสุด (Risk Window) ไม่ใช่เฉพาะชั่วโมงก่อนหน้า เพราะเมื่อเครื่องตกเกณฑ์จะไม่ทราบว่าเริ่มผิดปกติตั้งแต่เมื่อใด · กำหนดขอบเขต Risk Window ให้ชัดเจนและออก NCR (FM-QA-20)
4. ซ่อมเครื่อง แล้วทดสอบซ้ำครบทั้ง 3 ชนิดจนผ่าน จึงเดินเครื่องต่อได้
5. RE-PASS — นำผลิตภัณฑ์ที่ HOLD ไว้ผ่านเครื่องใหม่ 100%
6. QA ตัดสินสถานะผลิตภัณฑ์ตาม QP-QA-06 และเปิด CAPA

กรณีเครื่องชำรุดจนทดสอบไม่ได้ ถือเป็น CCP Failure — ห้ามผลิตต่อโดยข้ามเครื่องตรวจจับโลหะโดยเด็ดขาด',

  verification = 'Validation ค่าวิกฤตและขนาด Test Piece ปีละ 1 ครั้ง หรือเมื่อเปลี่ยนผลิตภัณฑ์ (QM-QA-06)
สอบเทียบเครื่องโดยหน่วยงานภายนอก ปีละ 1 ครั้ง
QA ทบทวนบันทึก FM-QA-28 ทุกวัน
ซ้อมรับมือเหตุเครื่องชำรุด ปีละ 1 ครั้ง',

  notes = 'ตำแหน่งเดิมในระบบคือขั้นตอนที่ 10 หลังแช่เยือกแข็งและหลังบรรจุ · แก้เป็นขั้นตอนที่ 13 ก่อนบรรจุ (ตรวจสินค้าเปลือย) ตาม QM-QA-09 Rev.00 ซึ่งระบุการแก้ตำแหน่งนี้ไว้ในประวัติการแก้ไขเอกสาร และยืนยันจากหน้างานแล้ว · บรรจุภัณฑ์ที่ป้อนเข้าขั้นตอนที่ 14–15 อยู่หลังจุดควบคุมวิกฤต ไม่มีมาตรการดักจับสิ่งแปลกปลอมหลังจุดนี้อีก ต้องควบคุมด้วย PRP อย่างเข้มงวด · QM-QA-04 Rev.05 ข้อ 4 อ้างรหัสกระบวนการ PC0010 แต่ PC0010 ในทะเบียนคือ "การให้ความร้อนวัตถุดิบ (สุก)" การตรวจจับโลหะคือ PC0012 — ดู NCR-256908-003

[15/08/26 — ปรับการเฝ้าระวังและการแก้ไขให้ตรง QM-QA-04 Rev.05 ข้อ 4]
ข้อความเดิมในทะเบียนเป็นฉบับก่อน Rev.05 และผิดสาระ 6 จุด:
(1) ขอบเขตการ HOLD — เดิมระบุ "Hold สินค้าที่ผลิตในชั่วโมงก่อนหน้า" ที่ถูกต้องคือกักกันย้อนหลังถึงรอบที่ทดสอบผ่านครั้งล่าสุด (Risk Window) เพราะเมื่อเครื่องตกเกณฑ์จะไม่ทราบว่าเริ่มผิดปกติเมื่อใด การกำหนดเป็น 1 ชั่วโมงคือการเดา
(2) ความถี่ — เดิมมี 2 โอกาส จาก 5 โอกาสที่แผนกำหนด ขาด เปลี่ยนผลิตภัณฑ์ / หลังซ่อมบำรุง / ท้ายกะ
(3) ไม่ได้ระบุอำนาจ Stop Line ซึ่ง Rev.04 เพิ่มไว้แล้ว
(4) ไม่ได้ระบุข้อห้ามเดินเครื่องข้ามเครื่องตรวจจับโลหะกรณีเครื่องชำรุดจนทดสอบไม่ได้
(5) ไม่ได้ระบุ Product Effect ในวิธีทดสอบ
(6) อ้างรหัสเอกสารที่ไม่มีจริง QP-QC-06 และ FM-QC-28 — ที่ถูกคือ QP-QA-06 และ FM-QA-28',

  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'CCP0106';

-- The same six occasions are the reason NCR-256908-008 exists: FM-QA-28 Rev.03
-- has ten rows and none of them is หลังซ่อมบำรุง. The register now requires a
-- test the controlled form has nowhere to record, which is worth stating on the
-- finding rather than leaving for someone to discover on the line.
UPDATE nc_capa SET
  notes = 'หน้าพิมพ์ FM-QA-28 ในระบบสร้างตามแบบฟอร์มควบคุม Rev.03 ตรงทุกช่อง ข้อบกพร่องจึงอยู่ที่ตัวแบบฟอร์ม ไม่ใช่ที่ระบบ · แก้โดยออก FM-QA-28 Rev.04 เพิ่มสองแถว แล้วปรับหน้าพิมพ์ตามในภายหลัง · ค่าวิกฤตและเกณฑ์บนแบบฟอร์มตรงกับ QM-QA-04 Rev.05 ทุกค่า (Fe Ø1.0 / Non-Fe Ø1.5 / SUS 304 Ø2.0 mm, Detect และ Reject)

[15/08/26] ทะเบียนจุดควบคุม CCP0106 ถูกปรับให้ระบุความถี่ครบทั้ง 5 โอกาสตามแผนแล้ว ช่องว่างจึงชัดขึ้น: ระบบกำหนดให้ทดสอบหลังซ่อมบำรุง แต่แบบฟอร์มที่ควบคุมอยู่ไม่มีแถวให้บันทึก ผู้ปฏิบัติจะต้องเขียนแทรกในช่องหมายเหตุ ซึ่งเป็นสิ่งที่ผู้ตรวจประเมินจะหยิบขึ้นมา · ควรออก Rev.04 ก่อนการตรวจ',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-008';
