-- 0059_factory_layouts_exist.sql
--
-- Correction to NCR-256908-006. QA confirms on 15/08/26 that the three factory
-- layout drawings exist — product flow, personnel flow, and High Care / Low
-- Care zoning. The finding was raised from QM-QA-09 Rev.00 ข้อ 5, which lists
-- all three as "ยังไม่จัดทำ".
--
-- So the drawings were never the gap. QM-QA-09 was wrong about them, and that
-- turns the finding around rather than closing it: an effective, approved
-- document asserts as fact that three documents do not exist when they do. That
-- is the same class of defect as NCR-256908-003 and has to be corrected in
-- QM-QA-09 Rev.01 alongside the rest.
--
-- What is still genuinely open is narrower and stated as such: whether the
-- three are controlled documents — numbered, revised, approved, in the register
-- and available where they are used — or files on one PC. The record does not
-- assume either. The Codex step-5 walkthrough half of the finding is untouched;
-- nothing said today bears on it.

UPDATE nc_capa SET
  description = 'ยังไม่มีบันทึกการทวนสอบแผนภูมิกระบวนการผลิตกับสายการผลิตจริง · หลักการ Codex ขั้นตอนที่ 5 และ QM-QA-09 Rev.00 ข้อ 4 กำหนดให้คณะทำงาน HACCP เดินทวนสอบแผนภูมิกับหน้างานในช่วงที่มีการผลิตจริง อย่างน้อยปีละ 1 ครั้ง โดยผู้ทวนสอบอย่างน้อย 2 คนจากคนละหน่วยงานลงชื่อกำกับ — ไม่พบบันทึกดังกล่าวในระบบ · QM-QA-09 ข้อ 4.1 ระบุรายการที่ต้องยืนยันเป็นลำดับแรกไว้ 4 ข้อ ซึ่งทั้งหมดยังค้าง: (1) ลำดับขั้นตอน 15–16 บรรจุถุงพิมพ์ก่อนหรือหลังแช่เยือกแข็ง เพราะแผนภูมิอีกฉบับระบุกลับกัน (2) อุณหภูมิและระยะเวลา Blast Freezer จนแกนกลาง ≤ -18 °C (3) อุณหภูมิเนื้อสัตว์ ณ ขั้นตอนเสียบไม้ ซึ่งกำหนด ≤ 7 °C ขณะที่ผลิตภัณฑ์ออกจากห้องหมักที่ 0 ถึง -3 °C (4) จุดติดตั้งเครื่องตรวจจับโลหะและระยะห่างจากจุดบรรจุ

[แก้ไขข้อกล่าวหาเมื่อ 15/08/26] ส่วนที่ระบุว่า "ยังไม่มีเอกสารผังโรงงาน" ถูกยกเลิก — QA ยืนยันว่าผังทั้งสามฉบับ (ผังการไหลของผลิตภัณฑ์ ผังการไหลของบุคลากร และผังการแบ่งโซน High Care / Low Care) จัดทำแล้ว ข้อกล่าวหาเดิมมาจาก QM-QA-09 Rev.00 ข้อ 5 ซึ่งระบุว่าทั้งสามฉบับ "ยังไม่จัดทำ"

สิ่งที่ยังเหลือจากประเด็นผังโรงงาน เปลี่ยนเป็นสองข้อ:
(ก) QM-QA-09 Rev.00 ข้อ 5 ระบุข้อเท็จจริงผิดในเอกสารที่บังคับใช้อยู่ ต้องแก้ในฉบับ Rev.01 พร้อมกับการแก้ข้ออื่น
(ข) ต้องยืนยันว่าผังทั้งสามฉบับเป็นเอกสารควบคุมหรือยัง — มีรหัสเอกสาร ครั้งที่แก้ไข วันบังคับใช้ ลายเซ็นอนุมัติ อยู่ในบัญชีแม่บท และเข้าถึงได้ ณ จุดใช้งาน ตาม ISO 22000 ข้อ 7.5.3 หรือเป็นไฟล์ที่เก็บไว้ในเครื่องเท่านั้น (ผังจุดวางกับดักสัตว์พาหะมีรหัส SD-QA-02 อยู่แล้ว อีกสามฉบับยังไม่ทราบรหัส)',
  notes = 'ข้อนี้เป็นงานหน้างานล้วน ทำได้เร็วกว่าข้ออื่นและปิดช่องคำถามที่ผู้ตรวจถามก่อนเสมอ · การเดินทวนสอบครั้งเดียวปิดรายการ 4 ข้อของ ข้อ 4.1 ได้ทั้งหมด และให้ข้อมูลที่ NCR-256908-004 ต้องใช้ (เวลา Blast Freezer จริง)

[15/08/26] QA แจ้งว่าผังโรงงานทั้งสามฉบับมีอยู่แล้ว เก็บไว้ในเครื่องคอมพิวเตอร์ · ข้อกล่าวหาส่วนผังโรงงานถูกถอนออกจากใบนี้แล้ว ไม่ใช่ปิด แต่เป็นการแก้ข้อเท็จจริง — ข้อกล่าวหาเดิมผิดตั้งแต่ต้น เพราะอ้างตาม QM-QA-09 ข้อ 5 โดยไม่ได้ตรวจสอบกับ QA ก่อน
· ระดับความรุนแรงคงไว้ที่ Major เพราะส่วนที่หนักที่สุดของใบนี้คือการไม่มีบันทึกการทวนสอบแผนภูมิกับหน้างาน ซึ่งไม่เกี่ยวกับผังโรงงานและยังค้างอยู่ทั้งหมด
· ข้อ (ข) ไม่ใช่การตั้งข้อสงสัย แต่เป็นสิ่งที่ต้องตอบได้หน้างาน: ผู้ตรวจประเมินจะขอดูผังการแบ่งโซนที่จุดใช้งาน ไม่ใช่ขอให้เปิดจากเครื่องในสำนักงาน หากยังไม่มีรหัสเอกสาร ควรออกรหัสในชุด SD-QA ต่อจาก SD-QA-02 และนำเข้าบัญชีแม่บทพร้อมกับงานตาม NCR-256908-011',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-006';

-- QM-QA-09's own §5 error joins the list of things its Rev.01 has to fix, next
-- to the OPRP count and the receiving limit. Recorded on the finding that
-- collects document conflicts so the revision is drafted once, not twice.
UPDATE nc_capa SET
  notes = COALESCE(notes,'') || '

[15/08/26 — เพิ่มรายการที่ QM-QA-09 Rev.01 ต้องแก้]
QM-QA-09 Rev.00 ข้อ 5 ระบุว่าผังการไหลของผลิตภัณฑ์ ผังการไหลของบุคลากร และผังการแบ่งโซนพื้นที่ "ยังไม่จัดทำ" ทั้งสามฉบับ แต่ QA ยืนยันเมื่อ 15/08/26 ว่าจัดทำแล้ว · เมื่อออก Rev.01 ให้แก้สถานะทั้งสามแถวพร้อมเติมรหัสเอกสารของแต่ละฉบับ และทบทวนคำเตือนท้ายข้อ 5 ที่ว่าผู้ตรวจอาจตั้งคำถามต่อผลการวิเคราะห์ทั้งฉบับ ซึ่งไม่ใช้แล้วเมื่อผังมีครบ — ดู NCR-256908-006',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-003';
