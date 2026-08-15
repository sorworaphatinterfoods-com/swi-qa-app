-- 0056_receiving_limit_and_parcooked_scope.sql
--
-- Two determinations by QA on 15/08/26, in answer to the two questions
-- migration 0055 left open.
--
--   1. เกณฑ์รับวัตถุดิบแช่เย็น = ≤ 7 °C
--   2. กลุ่ม Par-cooked และ RTE ยังไม่ผลิตเชิงพาณิชย์
--
-- Neither is invented here and neither is inferred. Both are recorded as
-- decisions, with what follows from each.

-- ── 1. the chilled receiving limit ──────────────────────────────────────────
-- The two effective documents disagreed: QM-QA-04 Rev.05 ข้อ 3.1 and ข้อ 4 print
-- ≤ 4 °C, QM-QA-09 Rev.00 ขั้นตอน 1.1 prints 0 – 7 °C. 0055 held the stricter
-- value on CCP0110 pending this decision. QA has ruled for 7 °C.
--
-- Worth recording that the floor was never running 4 °C. RM_CORE_SPEC in the
-- receiving form has been '0 - 7' throughout, so FM-QA-31 has been judging core
-- temperature against exactly the value now confirmed. The outlier was
-- QM-QA-04, not the system and not the line.
--
-- The register carries the range as QM-QA-09 prints it — 0 – 7 °C, not ≤ 7 °C —
-- because that is what the receiving form already enforces and what the
-- approved chart says. A delivery below 0 °C fails as out of range rather than
-- passing, which is the stricter reading of the same decision.
UPDATE ccps SET
  criticalLimit = 'อุณหภูมิแกนกลาง: แช่เย็น 0 – 7 °C · แช่แข็ง ≤ -18 °C',
  notes = 'จุดควบคุมนี้มีแผนควบคุมครบถ้วนใน QM-QA-04 Rev.05 แต่ไม่เคยมีแถวในทะเบียนนี้ — เพิ่มเข้ามาโดยคัดลอกจากเอกสารที่อนุมัติทั้งหมด ไม่มีการเรียบเรียงใหม่ · เกณฑ์อุณหภูมิแกนกลางเนื้อแช่เย็น: QA ตัดสินเมื่อ 15/08/26 ให้ใช้ ≤ 7 °C ตาม QM-QA-09 Rev.00 ขั้นตอน 1.1 (พิมพ์เป็นช่วง 0 – 7 °C) · ทะเบียนถือค่าเป็นช่วง 0 – 7 °C ตามที่แผนภูมิพิมพ์ไว้และตรงกับค่าที่ใบตรวจรับ FM-QA-31 ในระบบใช้ตัดสินอยู่แล้ว (RM_CORE_SPEC) หน้างานจึงไม่ต้องเปลี่ยนวิธีปฏิบัติ · ค่าที่ต้องแก้คือในเอกสาร: QM-QA-04 Rev.05 ข้อ 3.1 และ ข้อ 4 ยังพิมพ์ ≤ 4 °C ต้องออก Rev.06 แก้เป็น 0 – 7 °C ให้ตรงกัน — ดู NCR-256908-003 · ระวังอย่าสับสนกับอุณหภูมิในตู้รถ ซึ่งเป็นการตรวจคนละรายการ เกณฑ์ 0 – 4 °C และไม่มีการเปลี่ยนแปลง · QM-QA-09 ยังกำหนดเอกสาร ร.น. และ ร.3 ครบตรงล็อตเป็นพารามิเตอร์ควบคุมของขั้นตอนนี้ด้วย',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'CCP0110';

UPDATE nc_capa SET
  notes = 'พบจากการเทียบเอกสารที่อนุมัติกับทะเบียนจุดควบคุมในระบบ ไม่ใช่จากการตรวจหน้างาน · ทะเบียนในระบบถูกปรับให้ตรงกับ QM-QA-09 Rev.00 แล้วตาม migration 0055

[15/08/26 — ตัดสินแล้ว 1 ข้อ จาก 5 ข้อ]
ข้อ (2) เกณฑ์อุณหภูมิรับวัตถุดิบแช่เย็น: QA ตัดสินให้ใช้ ≤ 7 °C ตาม QM-QA-09 Rev.00 · ทะเบียนจุดควบคุม (CCP0110) แก้ตามแล้ว และไม่กระทบหน้างาน เพราะใบตรวจรับ FM-QA-31 ในระบบใช้เกณฑ์แกนกลาง 0 – 7 °C มาตลอดอยู่แล้ว · สิ่งที่ต้องทำต่อคือแก้เอกสาร — QM-QA-04 Rev.05 ข้อ 3.1 และ ข้อ 4 ยังพิมพ์ ≤ 4 °C ต้องออก Rev.06 พร้อมกับการแก้ข้ออื่นในใบนี้

ยังค้าง 4 ข้อ: (1) จำนวน OPRP 2 หรือ 3 · (3) การนับลำดับขั้นตอนใน QM-QA-04 ข้อ 3.1 และ 3.2 ยังเป็นลำดับเดิม · (4) รหัสกระบวนการของ CCP 1 อ้าง PC0010 แทน PC0012 · (5) FM-QA-06 ถูกใช้กับสองแบบฟอร์ม',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-003';

-- ── 2. Par-cooked / RTE scope ───────────────────────────────────────────────
-- 0055 graded this Minor on an assumption and said so: Minor if neither stream
-- is in commercial production, Critical if either is. QA confirms neither is.
-- The grading stands as recorded rather than being quietly reaffirmed.
--
-- The correction the finding called for is done — the eleven rows are ร่าง and
-- the register no longer claims four CCPs — so the NC moves to await QA
-- verification. It is not closed here. Closure is a QA determination and the
-- forward gate below has to be accepted as part of it.
UPDATE nc_capa SET
  status = 'Pending Verification',
  correctiveAction = 'เปลี่ยนสถานะจุดควบคุมสายกึ่งสุกและปรุงสุกทั้ง 11 จุด จาก "ใช้งาน" เป็น "ร่าง" ตาม migration 0055 ทะเบียนจึงไม่แสดง CCP ที่ใช้งาน 4 จุดอีก เหลือ 1 จุดตรงกับแผนที่อนุมัติ · ไม่ลบแถวทิ้ง เพราะเป็นงานที่ต้องทำต่อเมื่อจะเริ่มผลิตจริง',
  preventiveAction = 'ก่อนเริ่มผลิตกลุ่มกึ่งสุกหรือปรุงสุกเชิงพาณิชย์ ต้องดำเนินการให้ครบก่อนทุกข้อ:
1. จัดทำการวิเคราะห์อันตรายแยกฉบับของกลุ่มผลิตภัณฑ์นั้น (QM-QA-04 ข้อ 1)
2. จัดทำแผนภูมิกระบวนการผลิตแยกฉบับ พร้อมกำหนด CCP ขั้นตอนการให้ความร้อน (QM-QA-09 ข้อ 1)
3. Validate ค่าวิกฤตด้านอุณหภูมิและเวลาด้วยหลักฐานทางวิชาการตาม QM-QA-06 — ค่า ≥ 60 °C และ ≥ 75 °C ที่อยู่ในระบบยังไม่มีหลักฐานรองรับ
4. เปลี่ยนสถานะจุดควบคุมจาก "ร่าง" เป็น "ใช้งาน" หลังเอกสารทั้งชุดได้รับอนุมัติแล้วเท่านั้น',
  notes = 'แถวทั้ง 11 ถูกเปลี่ยนสถานะเป็น "ร่าง" ใน migration 0055 แล้ว จึงไม่แสดงเป็นจุดควบคุมที่ประกาศใช้อีก และไม่ถูกลบทิ้งเพราะเป็นงานที่ต้องทำต่อ

[15/08/26 — ยืนยันข้อเท็จจริงแล้ว]
QA ยืนยันว่ากลุ่มกึ่งสุก (Par-cooked) และปรุงสุก (RTE) ยังไม่มีการผลิตเชิงพาณิชย์ · ระดับความรุนแรง Minor จึงยืนตามเดิม ไม่ต้องยกระดับเป็น Critical · ข้อบกพร่องจำกัดอยู่ที่การควบคุมข้อมูลหลักในทะเบียน ซึ่งแก้แล้ว · ส่งให้ QA ทวนสอบและตัดสินปิด โดยต้องรับเงื่อนไขในช่องมาตรการป้องกันไปด้วย เพราะเป็นเงื่อนไขที่มีผลในวันที่จะเริ่มผลิตจริง',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-007';
