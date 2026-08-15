-- 0062_oprp01_at_step2_confirmed.sql
--
-- QA confirmed on 15/08/26 that the OPRP for incoming meat sits at step 2, the
-- accept/reject decision, rather than at step 1.1 where the temperature is
-- measured. That resolves NCR-256908-012 on the merits: the control level never
-- dropped, so the R=6 score in QM-QA-04 ข้อ 3.1 stays consistent with the
-- decision rule in ข้อ 2.
--
-- It is recorded, not closed. The resolution lives in two drafts that are not
-- approved yet, and a finding does not close because the fix has been written
-- down.

UPDATE nc_capa SET
  correctiveAction = 'ย้ายแผนควบคุมของ OPRP 1 เดิม (รับวัตถุดิบของสด) ไปเป็นแผนควบคุมของ OPRP-01 ที่ขั้นตอนที่ 2 ตรวจสอบและตัดสินรับ / ปฏิเสธ โดยคงเกณฑ์อุณหภูมิแกนกลาง 0 – 7 °C (แช่เย็น) และ ≤ -18 °C (แช่แข็ง) ไว้เป็นเกณฑ์ยอมรับของขั้นตอนที่ 2
เหตุผล: ขั้นตอนที่ 1.1 เป็นการวัดและบันทึก ส่วนขั้นตอนที่ 2 เป็นการตัดสินรับหรือปฏิเสธ มาตรการควบคุมที่ทำให้อันตรายลดลงจริงคือการปฏิเสธล็อตที่ตกเกณฑ์ ซึ่งเกิดที่ขั้นตอนที่ 2
ผลคือระดับการควบคุมไม่ได้ลดลง คะแนน R=6 ในข้อ 3.1 จึงยังสอดคล้องกับเกณฑ์ในข้อ 2 (6 – 8 ต้องควบคุมด้วย OPRP หรือ CCP) โดยไม่ต้องทบทวนคะแนนใหม่
ร่างเอกสารที่รองรับ: QM-QA-09 Rev.01 ข้อ 8 รายการที่ 2 และ QM-QA-04 Rev.06 ข้อ 4 แผนควบคุม OPRP-01',
  notes = COALESCE(notes,'') || '

[15/08/26 — QA ยืนยันแนวทาง]
เลือกทางที่ย้ายจุดควบคุมไปขั้นตอนที่ 2 แทนการทบทวนคะแนนความเสี่ยงใหม่ · ร่าง QM-QA-04 Rev.06 เขียนแผนควบคุม OPRP-01 ตามแนวทางนี้แล้ว
· ยังไม่ปิดข้อบกพร่อง เพราะทางแก้อยู่ในเอกสารสองฉบับที่ยังเป็นฉบับร่าง — ต้องประกาศใช้ QM-QA-09 Rev.01 และ QM-QA-04 Rev.06 พร้อมกันก่อน จึงจะทวนสอบและปิดได้',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-012';

UPDATE nc_capa SET
  correctiveAction = 'ประกาศใช้ QM-QA-09 Rev.01 เป็นฉบับควบคุมเพียงฉบับเดียว โดยยึดเนื้อหาข้อ 2 ตามฉบับที่ประกาศจุดควบคุมเชิงปฏิบัติการ 8 จุด ตามที่ QA ตัดสินเมื่อ 15/08/26
Rev.01 แก้ข้อ 1, 4.1, 5 และ 6 ให้สอดคล้องกับข้อ 2 ในครั้งเดียว เพื่อไม่ให้เกิดเอกสารที่ขัดกันเองอีก และมีแถวประวัติการแก้ไขระบุว่าแก้อะไรและเพราะอะไร
ต้องเรียกคืนไฟล์ Rev.00 ที่ไม่ใช้ออกจากทุกจุดใช้งาน ทำเครื่องหมายยกเลิก และเก็บไว้ชุดเดียวเพื่อการอ้างอิงย้อนหลัง
ต้องประกาศ QM-QA-04 Rev.06 พร้อมกัน เพราะทั้งสองฉบับอ้างอิงกันโดยตรง',
  notes = COALESCE(notes,'') || '

[15/08/26] ร่าง QM-QA-09 Rev.01 และ QM-QA-04 Rev.06 จัดทำเสร็จแล้วทั้งคู่ · ยังไม่ปิดข้อบกพร่อง จนกว่าจะอนุมัติ ประกาศใช้ และเรียกคืนฉบับเดิมออกจากจุดใช้งานครบ — ตราบใดที่ยังมีสองไฟล์ที่อ้าง Rev.00 หมุนเวียนอยู่ ข้อบกพร่องยังคงอยู่',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-013';

-- The Rev.06 draft now carries a control plan for every declared OPRP, but six
-- of the eight still have no hazard analysis behind them. That is the part of
-- the finding that a draft cannot discharge: under Codex principles 1 and 2 the
-- control-point type is an output of the analysis, so declaring OPRP at a step
-- with no risk score is the sequence run backwards.
UPDATE nc_capa SET
  notes = COALESCE(notes,'') || '

[15/08/26 — ร่างแผนควบคุมครบ 8 จุดแล้ว แต่ข้อบกพร่องยังไม่ปิด]
QM-QA-04 Rev.06 ข้อ 4 มีแผนควบคุมครบทั้ง 8 OPRP และ CCP-01 แล้ว โดย OPRP-01, OPRP-06 และ CCP-01 ยกมาจากเอกสารที่อนุมัติ ส่วนอีก 6 จุดเป็นร่างข้อเสนอที่ทำเครื่องหมายไว้ชัดเจน ต้องให้คณะทำงานแก้ไขและยืนยัน
สิ่งที่ยังขาดและร่างเอกสารให้ไม่ได้: <b>6 จาก 8 OPRP ยังไม่มีการวิเคราะห์อันตรายและคะแนนความเสี่ยงรองรับ</b> — ขั้นตอน 4, 5–7, 8, 10, 15 และ 17 ปรากฏอยู่ในข้อ 3.2 ว่ายังไม่วิเคราะห์ แต่ถูกประกาศเป็น OPRP ในแผนภูมิแล้ว
ตามหลักการที่ 1 และ 2 ของ Codex ประเภทจุดควบคุมเป็นผลลัพธ์ของการวิเคราะห์อันตราย การประกาศก่อนแล้วหาเหตุผลมารองรับทีหลังเป็นลำดับย้อนกลับที่ผู้ตรวจประเมินจะตั้งคำถาม
ข้อเสนอ: วิเคราะห์ขั้นตอนที่ 8 (สารก่อภูมิแพ้ตอนชั่ง) และ 15 (ฉลากสารก่อภูมิแพ้) ก่อนขั้นตอนอื่น — ขั้นตอนที่ 15 มีโอกาสได้คะแนน 9 ขึ้นไป ซึ่งตารางข้อ 2 บังคับให้เป็น CCP ไม่ใช่ OPRP',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-004';
