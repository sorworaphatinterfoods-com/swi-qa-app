-- 0041_ccp_monitoring_plan.sql
-- Load the approved CCPs Monitoring Plan (QM-MR-03 Rev.01 / 01-10-25) into the
-- control point register: HACCP principles 4 (monitoring) and 5 (corrective
-- action), plus verification and the records each CCP generates.
--
-- These were the fields left empty in 0040 because the flow diagram states
-- limits only. They are the fields an auditor asks about first -- a CCP with a
-- limit but no stated who/how/how-often is a finding on its own.
--
-- Monitoring is stored as four columns rather than one blob because the source
-- document is four columns, and because "who monitors this" and "how often" are
-- asked separately in an audit and need to be answerable separately.
--
-- criticalLimit is deliberately NOT written by this migration. The monitoring
-- plan's test-piece sizes disagree with both the process flow diagram and the
-- validation record on Non-Fe (2.0 mm here, 1.5 mm in the other two). Picking
-- one would settle a conflict between controlled documents silently, and the
-- looser figure would weaken the daily check below what validation proved. The
-- register keeps the validated 1.5 mm and the conflict is raised to QA to
-- resolve on the documents themselves.

ALTER TABLE ccps ADD COLUMN hazard       TEXT;  -- อันตรายที่ควบคุม
ALTER TABLE ccps ADD COLUMN monWhat      TEXT;  -- Monitoring: What
ALTER TABLE ccps ADD COLUMN monHow       TEXT;  -- Monitoring: How
ALTER TABLE ccps ADD COLUMN monFreq      TEXT;  -- Monitoring: Frequency
ALTER TABLE ccps ADD COLUMN monWho       TEXT;  -- Monitoring: Who
ALTER TABLE ccps ADD COLUMN verification TEXT;  -- การทวนสอบ
ALTER TABLE ccps ADD COLUMN records      TEXT;  -- แบบบันทึกที่เกี่ยวข้อง
ALTER TABLE ccps ADD COLUMN planRef      TEXT;  -- เอกสารต้นทาง + revision

-- CCP 1 "Metal Detection" in QM-MR-03 is one plan covering the detector, which
-- appears as CCP-01 in the RTC stream and CCP-02 in the Par-cooked stream.
UPDATE ccps SET
  hazard  = 'เศษโลหะในผลิตภัณฑ์',
  monWhat = '1) สินค้าทุกถุงต้องผ่านเครื่องตรวจจับโลหะ' || char(10) ||
            '2) ตรวจสอบระบบ Reject ของเครื่อง Metal Detector',
  monHow  = '1) ตรวจสอบด้วยสายตาว่าเครื่อง Metal Detector และระบบ Reject ทำงานปกติ' || char(10) ||
            '2) นำชุด Test Pieces (Fe / Non-Fe / SUS304) มาปล่อยผ่านเครื่อง Metal Detector',
  monFreq = 'ก่อนเริ่มผลิต และระหว่างการผลิตทุก ๆ 1 ชม.',
  monWho  = 'เจ้าหน้าที่ QA/QC (ผู้รับผิดชอบ: QA/QC, PD)',
  correction = 'กรณีเครื่องตรวจจับโลหะไม่ Reject ชุดทดสอบ — Hold สินค้าที่ผลิตในชั่วโมงก่อนหน้า ' ||
               'ตรวจสอบ/ปรับแก้ไข Metal Detector ให้ปกติ แล้วนำสินค้ามาผ่านเครื่องตรวจจับโลหะอีกครั้ง ' ||
               'หากพบว่าสินค้าถูก reject ให้ Hold สินค้าเพื่อดำเนินการตาม QP-QC-06 ' ||
               'หาสาเหตุและแก้ไขป้องกันการเกิดซ้ำ',
  verification = 'ทวนสอบบันทึกการตรวจสอบเครื่องตรวจจับโลหะทุกวัน โดยหัวหน้าแผนก QA (FM-QC-28)' || char(10) ||
                 'Validation ปีละ 1 ครั้ง' || char(10) ||
                 'สอบเทียบเครื่องตรวจจับโลหะจากภายนอก ปีละ 1 ครั้ง',
  records = 'FM-QC-28 บันทึกการตรวจสอบเครื่องตรวจจับโลหะ' || char(10) ||
            'FM-QC-21 Corrective Action Records (CARs)' || char(10) ||
            'QM-MR-03 HACCP Validation',
  planRef = 'QM-MR-03 Rev.01 (01-10-25)',
  modified = datetime('now')
 WHERE id IN ('CCP0106', 'CCP0207');
