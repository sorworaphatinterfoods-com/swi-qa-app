-- 0046_duangcharoen_trial_failure.sql
-- Record the evidence behind removing ดวงเจริญ (SP0035), and correct an
-- evaluation that could not have survived an auditor's first question.
--
-- SEV0014 was written from the incident summary alone and came out 92.3 / grade A
-- against a decision of DISQUALIFIED. A grade-A supplier being cut is not a
-- finding an auditor lets pass; it reads either as a scoring system nobody uses
-- or as a decision taken outside the system. It was flagged as unsupported at
-- the time rather than dressed up.
--
-- The supporting document has now been produced: หนังสือแจ้งซัพพลายเออร์
-- QA-2569/04-003 dated 17 เม.ย. 2569, issued to บริษัท ดวงเจริญ อินเตอร์เทรด จำกัด
-- covering deliveries on 16 and 17 เม.ย. 2569, requiring root cause and CAPA back
-- by 22/04/69 before approval as a main supplier would be considered.
--
-- That changes the picture in two ways. First, the events: two rejected lots,
-- missing ร.น. on both delivery days, a labelling non-conformance and an unfit
-- delivery vehicle — none of which were in the data SEV0014 was scored from.
-- Second, and more decisive than any score, this was a NEW-SUPPLIER TRIAL. The
-- letter set a condition and a deadline; the condition was not met. A trial that
-- is not completed does not end in approval. The score is now consistent with
-- that outcome instead of contradicting it, but the outcome does not rest on the
-- score.
--
-- Dates here are the dates on the document. Recording a real letter under its
-- own issue date is transcription; the created/modified stamps still say today,
-- so the record shows plainly that it was entered on 02/08/69. Nothing is
-- back-dated.

-- ── 1. Legal entity name ────────────────────────────────────────────────────
-- The register held the name used on the floor. The letter is addressed to the
-- registered company, which is the name that has to appear in an approved-
-- supplier list. tax_id is still unknown and stays NULL rather than guessed.
UPDATE suppliers SET
  name  = 'บริษัท ดวงเจริญ อินเตอร์เทรด จำกัด',
  notes = 'ไม่ผ่านการประเมินซัพพลายเออร์รายใหม่ (new-supplier trial) — ไม่เคยขึ้นเป็นผู้ขายที่อนุมัติ · อ้างอิงหนังสือแจ้ง QA-2569/04-003 ลว. 17 เม.ย. 2569 กำหนดให้ส่ง Root Cause + CAPA ภายใน 22/04/69 ก่อนพิจารณาอนุมัติเป็นซัพพลายเออร์รายหลัก · ไม่ได้รับการตอบกลับตามกำหนด จึงยุติการประเมิน · คงบันทึกไว้เพื่อให้ประวัติเหตุการณ์ (เม.ย.–พ.ค.69) มีที่อ้างอิง และเพื่อแสดงว่าการไม่รับเข้าเป็นผู้ขายเกิดจากการประเมินจริง',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'SP0035';

-- ── 2. Re-score SEV0014 on the documented events ────────────────────────────
-- Same deduction scale as SEV0013, so the two are comparable: food safety −12,
-- quality −8, documentation −8, late delivery −4 per event.
--
--   Quality 100 − 16 = 84   (มันหมูไม่ตรงสเปก 24/04 · วัตถุดิบนิ่มจากน้ำในรถขนส่ง)
--   Food safety 100 − 48 = 52
--       มันหมู 40 กก. สี/กลิ่นไม่ผ่านเกณฑ์ความสด — Reject 16-17/04
--       สะโพกหมู 6 กก. สิ่งแปลกปลอมในถุงสินค้า — Reject 16-17/04
--       สะโพกปนเปื้อนสิ่งสกปรก / บางถุงกลิ่นเหม็น สีเขียวคล้ำ 24/04
--       น้ำจากระบบปรับอากาศในรถกระเด็นใส่วัตถุดิบ (การปนเปื้อนจากพาหนะ)
--   Delivery 100 − 12 = 88  (ส่งช้า 04/05 −4 · รถขนส่งไม่พร้อมใช้งาน −8)
--   Documentation 100 − 32 = 68
--       ไม่ส่งเอกสาร ร.น. วันที่ 16/04 และ 17/04 (2 ครั้ง)
--       ฉลากระบุเพียง Pack Date ไม่มี MFG Date
--       ไม่ส่ง CAPA ตามกำหนด 22/04/69
--
-- Total uses the app's own weighting (Q .25 · FS .30 · Delivery .15 · Doc .10,
-- re-normalised over the four criteria scored):
--   (84×.25 + 52×.30 + 88×.15 + 68×.10) / .80 = 70.75 → 71, grade C.
-- Audit and Responsiveness stay NULL — no on-site audit was done, and scoring
-- responsiveness at 0 for a supplier who simply never replied would be putting a
-- number on an absence.
UPDATE supplier_evaluations SET
  qualityScore    = '84',
  foodSafetyScore = '52',
  deliveryScore   = '88',
  docScore        = '68',
  totalScore      = '71',
  grade           = 'C',
  decision        = 'DISQUALIFIED',
  notes           = 'ประเมินซัพพลายเออร์รายใหม่ (new-supplier trial) — ไม่ผ่าน จึงไม่รับเข้าเป็นผู้ขาย | หลักฐานหลัก: หนังสือแจ้งซัพพลายเออร์ QA-2569/04-003 ลว. 17 เม.ย. 2569 (การจัดส่ง 16 และ 17 เม.ย. 2569) | เหตุการณ์: ปฏิเสธรับสินค้า 2 รายการ (มันหมู 40 กก. สี/กลิ่นไม่ผ่านเกณฑ์ความสด · สะโพกหมู 6 กก. พบสิ่งแปลกปลอมในถุง) · ไม่ส่งเอกสาร ร.น. ทั้ง 2 วันจัดส่ง · ฉลากมีเพียง Pack Date ไม่มี MFG Date · ระบบปรับอากาศรถขนส่งชำรุด น้ำกระเด็นใส่วัตถุดิบทำให้วัตถุดิบนิ่ม · สะโพกปนเปื้อนสิ่งสกปรกและมันหมูไม่ตรงสเปก 24/04/69 · ส่งช้าเกือบเลยเวลารับของ 04/05/69 | เกณฑ์หักคะแนนเดียวกับ SEV0013: ความปลอดภัยอาหาร -12 · คุณภาพ -8 · เอกสาร -8 · ส่งช้า -4 ต่อครั้ง | เหตุผลของการไม่รับเข้าเป็นผู้ขาย ไม่ได้อยู่ที่คะแนนอย่างเดียว: หนังสือแจ้งกำหนดให้ส่ง Root Cause + CAPA ภายใน 22/04/69 เป็นเงื่อนไขก่อนพิจารณาอนุมัติเป็นซัพพลายเออร์รายหลัก ไม่ได้รับการตอบกลับตามกำหนด การประเมินรายใหม่จึงไม่ผ่านและยุติ | อ้างอิง SCAR0008 | ยังไม่ได้บันทึกวันที่ตัดสินใจจริง (disqualified_at) — QA เป็นผู้ระบุ',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'SEV0014';

-- ── 3. The letter itself becomes a SCAR ─────────────────────────────────────
-- QA-2569/04-003 is a corrective action request in everything but name: it lists
-- non-conformities, demands root cause and CAPA, and sets a due date. Filing it
-- as a SCAR is what makes the missed deadline visible — an unanswered letter in
-- a drawer proves nothing, an open SCAR past its due date proves the supplier
-- was given the chance and did not take it.
--
-- Status stays Open. The app refuses to close a SCAR unless effectiveness is
-- EFFECTIVE, which is right: no response was received, so there is nothing to
-- verify. Open-and-overdue is the accurate state, not an untidy one.
INSERT OR IGNORE INTO supplier_scars
  (id, scarDate, supplier, issue, severity, requiredAction, dueDate,
   effectiveness, status, notes, created, modified)
VALUES (
  'SCAR0008', '2026-04-17', 'SP0035',
  'หนังสือแจ้งซัพพลายเออร์ QA-2569/04-003 — ข้อบกพร่องช่วงประเมินซัพพลายเออร์รายใหม่ จากการจัดส่งวันที่ 16 และ 17 เม.ย. 2569 รวม 4 ประเด็น: (1) ปฏิเสธรับสินค้า — มันหมู 40 กก. สีและกลิ่นไม่ผ่านเกณฑ์ความสด / สะโพกหมู 6 กก. ตรวจพบสิ่งแปลกปลอมปนเปื้อนในถุงสินค้า (2) ขาดส่งเอกสาร ร.น. ทั้ง 2 วันจัดส่ง (3) ฉลากสินค้าระบุเพียง Pack Date ไม่มี MFG Date จึงไม่เพียงพอต่อการตรวจสอบความสดใหม่ (4) ระบบปรับอากาศในรถจัดส่งชำรุด มีน้ำกระเด็นใส่วัตถุดิบ ทำให้วัตถุดิบนิ่ม',
  'Major',
  'ส่ง Root Cause และมาตรการแก้ไข/ป้องกัน (CAPA) กลับมาให้ฝ่ายประกันคุณภาพพิจารณา เป็นเงื่อนไขก่อนการพิจารณาอนุมัติเป็นซัพพลายเออร์รายหลัก',
  '2026-04-22',
  'PENDING', 'Open',
  'ออกโดย QA&QC Supervisor · ผู้รับ: บริษัท ดวงเจริญ อินเตอร์เทรด จำกัด · ไม่ได้รับการตอบกลับภายในกำหนด 22/04/69 การประเมินซัพพลายเออร์รายใหม่จึงไม่ผ่าน (ดู SEV0014) · คง SCAR ไว้สถานะ Open เพราะไม่มีการตอบกลับให้ทวนสอบประสิทธิผล ปิดไม่ได้ตามเกณฑ์ · หมายเหตุบนตัวหนังสือแจ้ง: บรรทัด "ประจำวันที่ 16-17 เมษายน 2026" ใช้ ค.ศ. ปนกับ พ.ศ. 2569 ในบรรทัดอื่น เป็นวันเดียวกันแต่ควรแก้ให้เป็นปีเดียวกันในแบบฟอร์มครั้งต่อไป',
  strftime('%Y-%m-%dT%H:%M:%fZ','now'), strftime('%Y-%m-%dT%H:%M:%fZ','now')
);
