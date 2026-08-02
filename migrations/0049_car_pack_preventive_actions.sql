-- 0049_car_pack_preventive_actions.sql
-- Load the submitted CAR response pack into the 19 findings of the 14/05/69
-- internal audit.
--
-- The pack answers all nineteen with root cause, actions, assignee, target date
-- and attached evidence. The system already held its corrective-action column;
-- what it never had was the PREVENTIVE half — the measure that stops the finding
-- returning — which is why every one of them sat at Pending Verification with
-- two blank fields.
--
-- The pack keeps corrective and preventive in ONE column ("แนวทางการแก้ไขปัญหา
-- และป้องกันไม่ให้เกิดซ้ำ"). Splitting them is an editorial call, made the same
-- way each time: the immediate fix to this instance stays corrective (hold the
-- lot, re-pass it, wipe the floor), and the change to the system that outlives
-- it becomes preventive (revise the procedure, add it to the PM plan, put it on
-- a checklist, train against it). Wording is transcribed from the document, not
-- composed here. Document numbers named in the pack are carried across so the
-- paper file and this record point at each other.
--
-- effectivenessCheck stays EMPTY on all nineteen. Whether the attached evidence
-- actually proves the fix worked is the QA's verification, not a transcription
-- job, and writing it here would be exactly the "closed with nothing behind it"
-- that the central system's CSV import already did once.

-- ── Preventive actions, transcribed per finding ─────────────────────────────
UPDATE nc_capa SET preventiveAction = 'เพิ่มเกณฑ์ประเมินซัพพลายเออร์กลุ่มเนื้อสัตว์ ต้องมีระบบสอบย้อนกลับที่ตอบสนองเวลาตามที่ลูกค้ากำหนด · Update QP-PU-02 หัวข้อ 4.1 เพิ่มข้อ 4 ย่อย กำหนดเงื่อนไขการส่งมอบเอกสารจาก ASL', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-001';

UPDATE nc_capa SET preventiveAction = 'จัดทำ HR Checklist (แบบฟอร์มตรวจสอบเอกสารพนักงาน) ให้ตรวจครบก่อนเก็บเข้าแฟ้มประวัติพนักงานทุกราย', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-002';

UPDATE nc_capa SET preventiveAction = 'จัดทำป้าย OPL (One Point Lesson) 2 ภาษา ไทย-พม่า ติดหน้าเครื่อง Metal Detector แสดงขั้นตอนการทวนสอบรายชั่วโมงและมาตรการตอบโต้เมื่อเครื่องชำรุด 4 ขั้น (STOP LINE → NOTIFY → HOLD PRODUCT → OUT OF ORDER) ให้พนักงานมีอำนาจหยุดไลน์ได้เอง · ประสานฝ่ายจัดซื้อวางระบบเรียกช่าง Service ให้กลับมาทำงานได้ตามปกติอย่างรวดเร็ว', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-003';

UPDATE nc_capa SET preventiveAction = 'ปรับปรุงแบบฟอร์มบันทึกการสอบย้อนกลับ FM-QA-23 ให้มีตารางกระทบยอด (Mass Balance) ทั้งแบบเดินหน้าและถอยหลังในฉบับเดียว · แก้ QP-QA-16 ข้อ 7.4 และข้อ 8 กำหนดให้ทวนสอบระบบสอบกลับ/ซ้อมเรียกคืน 3 ครั้ง/ปี เกณฑ์ผ่านคือ Mass Balance 100% ภายใน 4 ชั่วโมง', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-004';

UPDATE nc_capa SET preventiveAction = 'อัปเดต WI/QP-QA-16 ข้อ 7.3 ให้การซ้อมเรียกคืนต้องมีการจำลองส่งอีเมล (Dummy Email) แจ้งลูกค้าภายนอกทุกครั้ง · ตรวจสอบและอัปเดตข้อกำหนดของลูกค้าทุกรายเข้าระบบก่อนวางแผนซ้อมประจำปี', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-005';

UPDATE nc_capa SET preventiveAction = 'ติดป้าย OPL ลำดับขั้นตอนการทำงานภายในจุดงานชั่งเครื่องปรุง (ฉบับภาษาพม่า) เพื่อให้พนักงานที่ถูกย้ายมาทำแทนเข้าใจขั้นตอนได้ทันที · หัวหน้าทำ OJT หน้างานในจุดดังกล่าวซ้ำ พร้อมอธิบายขั้นตอนตามใบ OPL', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-006';

UPDATE nc_capa SET preventiveAction = 'เพิ่มฝ้า เพดาน (และมุ้ง/กำแพง/แอร์) เป็นจุดทำความสะอาดและตรวจสอบในแบบฟอร์ม FM-PD-07 แก้ไขครั้งที่ 2 ความถี่ 1 ครั้ง/สัปดาห์ พร้อมกำหนดผู้ตรวจสอบและผู้ทวนสอบทุกวัน', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-007';

UPDATE nc_capa SET preventiveAction = 'กำหนดมาตรการชั่วคราวให้พนักงานรีดน้ำทุก 2 ชั่วโมง ไม่ให้มีน้ำขังข้ามวัน · เปิดใบแจ้งซ่อม (FM-MN-01) เพื่อซ่อมแซมถาวร กำหนดหยุดซ่อมพื้นที่ 25–30/06/26 · เพิ่มการระบุความเสี่ยงของโครงสร้างที่ชำรุดเข้าในโปรแกรมตรวจประเมินภายใน (Internal GMP Audit) เพื่อให้ออกใบแจ้งซ่อมเชิงป้องกัน', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-008';

UPDATE nc_capa SET preventiveAction = 'Update SD-QA-02 แผนผังจุดวางอุปกรณ์ดักจับสัตว์พาหะให้ตรงหน้างาน · แก้ QP-QA-01 แก้ไขครั้งที่ 2 กำหนดให้ทบทวนแผนผัง Layout ทุกครั้งที่รับรายงานผู้ให้บริการประจำสัปดาห์ และต้องออกใบร้องขอดำเนินการงานเอกสาร (DAR) ทุกครั้งที่มีการโยกย้ายสถานี · QA เดินทวนสอบเทียบผังกับหน้างานจริงทุกเดือน', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-009';

UPDATE nc_capa SET preventiveAction = 'บรรจุรายการตรวจสอบสภาพม่านพลาสติกเข้าไว้ในแผนบำรุงรักษาเชิงป้องกัน (PM) ของฝ่ายซ่อมบำรุง เป็นรายการที่ 44 ของแผนประจำปี 2569', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-010';

UPDATE nc_capa SET preventiveAction = 'อัปเดตแบบฟอร์ม FM-PD-15 แก้ไขครั้งที่ 2 (บังคับใช้ 15/05/2026) เพิ่มช่อง Sticker Lot. ให้ทวนสอบสติ๊กเกอร์ ต้น–กลาง–ท้าย ของการผลิต ไม่ใช่เฉพาะก่อนเริ่มใช้งาน', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-011';

UPDATE nc_capa SET preventiveAction = 'ทบทวนระเบียบ QP-QA-03 การควบคุมสารเคมี แก้ไขครั้งที่ 1 หัวข้อ 4.3 เพิ่มข้อกำหนดการชี้บ่งภาชนะบรรจุรอง (Secondary Container Labeling) และห้ามใช้ภาชนะบรรจุรองที่ไม่มีป้ายชี้บ่งในพื้นที่ผลิตโดยเด็ดขาด', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-012';

UPDATE nc_capa SET preventiveAction = 'สุ่มตรวจสุขลักษณะพนักงานก่อนเข้าไลน์ผลิตทุกจุดการทำงานทุกวัน โดยบันทึกข้อมูลผ่าน Web Application (qa-personal-hygiene) ซึ่งออกรายงานและเก็บหลักฐานอัตโนมัติ แทนการบันทึกบนกระดาษที่ถูกข้าม', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-013';

UPDATE nc_capa SET preventiveAction = 'ประกาศนโยบายการตรวจสุขภาพก่อนเริ่มงาน ที่ บค.002/2569 ลงนามโดยกรรมการผู้จัดการ บังคับใช้ 8 มิ.ย. 2569 — ผู้สมัครทุกตำแหน่งต้องผ่านการตรวจสุขภาพ (ตรวจร่างกาย เอกซเรย์ปอด ตรวจหาเชื้อก่อโรคทางอาหาร) ก่อนเริ่มปฏิบัติงาน · จัดทำ checklist onboarding ให้ตรวจครบก่อนรับเข้าทำงาน', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-014';

UPDATE nc_capa SET preventiveAction = 'แก้ QP-QA-01 แก้ไขครั้งที่ 2 เพิ่มข้อ 6.4 การบันทึกข้อมูล การตรวจสอบ และการทบทวนแบบบันทึก และข้อ 6.5 การฝึกอบรมและสร้างความตระหนัก พร้อมระบุเอกสารที่เกี่ยวข้อง (FM-QA-01 บันทึกการตรวจสอบสัตว์พาหะ · FM-QA-02 Trend Analysis · SD-QA-02 Layout) · อบรมพนักงานให้ตระหนักถึงความสำคัญของการควบคุมสัตว์พาหะและการลงบันทึก', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-015';

UPDATE nc_capa SET preventiveAction = 'ออกระเบียบปฏิบัติใหม่ QP-QA-17 การศึกษาอายุผลิตภัณฑ์ (บังคับใช้ 02/06/26) · รวบรวมรายงานวิจัย Shelf Life Study ทั้งหมดเข้าแฟ้มทะเบียนเอกสาร · กำหนดให้ทดลองศึกษาซ้ำทุก 3 ปี หรือเมื่อเปลี่ยนสูตร/กระบวนการบรรจุอย่างมีนัยสำคัญ', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-016';

UPDATE nc_capa SET preventiveAction = 'จัดทำ checklist ตรวจประจำเดือน FM-HR-15 (ป้ายทางออกฉุกเฉิน · ไฟฉุกเฉิน · เส้นทางหนีไฟ · ถังดับเพลิง) กำหนดผู้รับผิดชอบตรวจและผู้ทวนสอบชัดเจน และให้ทบทวนทุกครั้งหลังปรับปรุงพื้นที่ · ซ้อมอพยพหนีไฟ 18/06/2026 โดยให้ทีมดับเพลิงอาชีพประเมินความถูกต้องของจุดติดตั้งป้าย', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-017';

UPDATE nc_capa SET preventiveAction = 'จัดทำแผนตรวจวัดสภาพแวดล้อมในการทำงานประจำปี แต่งตั้งผู้รับผิดชอบติดตาม จัดทำทะเบียนวันครบกำหนด และจัดสรรงบประมาณล่วงหน้า · ประสานหน่วยงานตรวจวัดที่ได้รับการรับรอง (สสปท.) · ทบทวนผลตรวจและปรับปรุงพื้นที่เสี่ยงทุกรอบ', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-018';

UPDATE nc_capa SET preventiveAction = 'Update QP-QA-02 แก้ไขครั้งที่ 1 หัวข้อ 4.1 เพิ่มข้อ 3 และข้อ 4 ย่อย กำหนดให้อุปกรณ์แก้ว/พลาสติกแข็งชนิดใหม่ต้องขึ้นทะเบียน (Master List of Brittle Plastic & Glass) ก่อนนำเข้าใช้ในพื้นที่ผลิตเสมอ และกำหนดรอบตรวจสอบตาม Glass & Brittle Plastic Checklist · เรียกอบรมพนักงานและผู้เกี่ยวข้องให้รับทราบข้อกำหนดที่แก้ไข', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-019';

-- ── Evidence references ─────────────────────────────────────────────────────
-- Only records that exist in this system with an ID. The pack's other exhibits
-- are scanned documents (QP-QA-16, FM-QA-23, ประกาศ บค.002/2569 …) and belong in
-- the document control system; they are named in the preventive actions above so
-- the paper file can be found from here.
--
-- The two training records are attached to the findings they actually cover. In
-- the submitted pack they are swapped — the pest finding carries the glass
-- training record and the glass finding carries the pest one. Both sessions were
-- genuinely held on 4 มิ.ย. 69 with the same seven attendees, so this is a filing
-- slip rather than a missing record, but it is the kind an auditor reads as
-- evidence assembled after the fact.
UPDATE nc_capa SET evidenceRefs = '["TR-20260628-001"]',                    modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-001';
UPDATE nc_capa SET evidenceRefs = '["RCL0001","TR-20260628-001"]',          modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-004';
UPDATE nc_capa SET evidenceRefs = '["RCL0001"]',                            modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-005';
UPDATE nc_capa SET evidenceRefs = '["TR0002"]',                             modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-015';
UPDATE nc_capa SET evidenceRefs = '["SLS0001"]',                            modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-016';
UPDATE nc_capa SET evidenceRefs = '["TR0003"]',                             modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'NCR-256905-019';

-- SLS0001 is deliberately attached even though it dates from 20/10/2025, before
-- the finding — the corrective action was to GATHER the existing studies, so a
-- pre-existing one is the right kind of record. It is also the only one there
-- is: a single product (FG-ม006), still Ongoing. It supports the finding, it
-- does not answer it, and the note says so rather than letting the attachment
-- imply otherwise.
UPDATE nc_capa SET rootCause = rootCause || '
[บันทึกเพิ่ม 02/08/69] หลักฐานที่แนบคือระเบียบใหม่ QP-QA-17 และผลศึกษา SLS0001 เพียงรายการเดียว (FG-ม006 · REALTIME · FROZEN · สถานะ Ongoing) ซึ่งยังไม่ครอบคลุมสินค้าตัวอื่น — ระเบียบตอบว่าจะทำอย่างไรต่อไป แต่ยังไม่ตอบว่าอายุสินค้าที่ระบุบนฉลากปัจจุบันอ้างอิงผลทดลองใด'
WHERE id = 'NCR-256905-016';
