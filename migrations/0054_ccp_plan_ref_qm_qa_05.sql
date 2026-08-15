-- 0054_ccp_plan_ref_qm_qa_05.sql
-- The CCP register cites a plan that has been withdrawn.
--
-- 0041 loaded the monitoring plan as QM-MR-03 Rev.01 (01-10-25), which was the
-- current document at the time. The document-control Baseline Worksheet dated
-- 06/08/26 rules otherwise, in terms that leave nothing to interpret:
--
--   QM-MR-03 CCPs Monitoring Plan  →  ยกเลิก (OBSOLETE)
--   "ถูกแทนที่ด้วย QM-QA-05 Rev.02 — ค่า Non-Fe เดิม 2.0 mm ไม่ตรง Test Piece จริง"
--
-- and, on the code-collision sheet:
--
--   QM-MR-03 was used for four different documents (HACCP System / CCPs
--   Monitoring / Validation / Verification Plan) → "ยกเลิกรหัสชุด QM-MR ทั้งหมด
--   แล้วใช้ QM-QA-02 ถึง QM-QA-06 ตามทะเบียนเพียงชุดเดียว"
--
-- The Non-Fe note is the same conflict this system already resolved from the
-- line's own records months ago: the register carries Ø1.5 mm, the withdrawn
-- plan printed 2.0 mm, and the withdrawn plan was wrong. Pointing the CCPs at
-- QM-QA-05 Rev.02 removes the last place that contradiction still lived.
--
-- The records list is corrected at the same time. There is no FM-QC series —
-- FM-QC-28 and FM-QC-21 are FM-QA-28 (Metal Detector Monitoring Record, Rev.03,
-- marked CCP in the master list) and FM-QA-21 (Corrective Action Request).

UPDATE ccps SET
  planRef = 'QM-QA-05 Rev.02 แผนเฝ้าระวังจุดวิกฤต (CCPs Monitoring Plan)',
  records = 'FM-QA-28 บันทึกการตรวจสอบเครื่องตรวจจับโลหะ (Rev.03)
FM-QA-20 บันทึกรายงานสิ่งที่ไม่เป็นไปตามข้อกำหนด (NCR)
FM-QA-21 บันทึกขอให้ดำเนินการแก้ไขและป้องกันการเกิดซ้ำ (CAR)
QM-QA-06 การรับรองความใช้ได้และการทวนสอบ CCP
วิธีปฏิบัติงาน: WI-QA-09 การควบคุมเครื่องตรวจจับโลหะ',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE planRef LIKE 'QM-MR-03%';

-- The HACCP team appointment carries the old code too. The master list has it
-- as QM-QA-02; the Baseline marks the Google Doc "เก็บเป็นฉบับหลัก" with the
-- note that the code is not yet printed on the document itself.
UPDATE haccp_documents SET
  docNo = 'QM-QA-02',
  notes = TRIM(COALESCE(notes,'') || CASE WHEN COALESCE(notes,'')='' THEN '' ELSE ' | ' END ||
    'เดิมบันทึกเป็น QM-MR-01 · ชุดรหัส QM-MR ถูกประกาศยกเลิกทั้งชุดตาม Baseline Worksheet 06/08/26 ให้ใช้ QM-QA-02 ถึง QM-QA-06 แทน · หมายเหตุใน Baseline ระบุว่ายังไม่มีรหัสพิมพ์อยู่บนหน้าเอกสารจริง ต้องเติมก่อนการตรวจ'),
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE docNo = 'QM-MR-01';
