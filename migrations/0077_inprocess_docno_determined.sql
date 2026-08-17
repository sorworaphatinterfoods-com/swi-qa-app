-- 0077_inprocess_docno_determined.sql
--
-- QA answered the question 0076 left open, on 17/08/26:
--
--   "ตรวจระหว่างกระบวนการผลิต แบบฟอร์มจะค่อนข้างหลากหลาย
--    ให้ยึดตัวเลขตามที่ผมลงบันทึกเท่านั้น ให้ Header ปรับตามที่ผมพิมพ์"
--
-- So the five different form numbers are not an inconsistency to be cleaned
-- up. In-process checks are written on whichever form matches what is being
-- inspected, and the number written on the record is the authority — over the
-- register's title, and over any default the software might prefer.
--
-- 0076 recorded the counts and flagged FM-QA-28 and FM-QA-32 as looking like
-- they did not belong. That reading is withdrawn here. It was the same mistake
-- as before: inferring from a form's registered title what the check must have
-- been, instead of asking. Nothing about the records changes; what changes is
-- that the software stops asserting a number of its own.

UPDATE haccp_documents SET
  notes = TRIM(COALESCE(notes,'') || ' | [17/08/26] QA ยืนยันว่าการตรวจระหว่างผลิตใช้แบบฟอร์มหลายเลข '
    || 'ตามลักษณะสิ่งที่ตรวจ และให้ยึดเลขตามที่ระบุไว้บนใบบันทึกแต่ละใบ — ข้อสังเกตเรื่องเลขไม่ตรงในบันทึกก่อนหน้าถือว่าตกไป '
    || 'ระบบไม่กำหนดเลขแบบฟอร์มให้เองอีกต่อไป หัวกระดาษและใบสรุปรายวันขึ้นเลขตามที่ผู้บันทึกพิมพ์'),
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE docNo = 'FM-QA-05';

-- ── ถอนข้อสังเกตของ migration 0076 ────────────────────────────────────────
UPDATE nc_capa SET
  notes = COALESCE(notes,'') || '

[17/08/26 — ถอนข้อสังเกตเรื่องเลขแบบฟอร์มตรวจระหว่างผลิต]
QA ตอบคำถามที่ค้างไว้เมื่อ 17/08/26 ว่า <b>"ตรวจระหว่างกระบวนการผลิต แบบฟอร์มจะค่อนข้างหลากหลาย ให้ยึดตัวเลขตามที่ผมลงบันทึกเท่านั้น ให้ Header ปรับตามที่ผมพิมพ์"</b>
· เลขแบบฟอร์ม 5 เลขบนทะเบียนตรวจระหว่างผลิต <b>จึงไม่ใช่ความไม่สอดคล้อง</b> แต่เป็นการเลือกแบบฟอร์มให้ตรงกับสิ่งที่ตรวจในแต่ละใบ
· <b>เลขที่เขียนไว้บนใบบันทึกคือเลขที่ถูกต้อง</b> เหนือกว่าชื่อรายการในทะเบียน และเหนือกว่าค่าตั้งต้นใด ๆ ของระบบ
· ข้อสังเกตในบันทึกก่อนหน้าที่ว่า FM-QA-28 และ FM-QA-32 "ดูไม่ตรงเรื่อง" <b>ถอนออก</b> — เป็นการเดาจากชื่อแบบฟอร์มว่าใบนั้นตรวจอะไร ซึ่งเป็นความผิดพลาดแบบเดียวกับที่เคยเกิดมาแล้ว
· ไม่มีบันทึกใบใดถูกแก้ ทั้งใน 0076 และ 0077 — สิ่งที่เปลี่ยนคือระบบเลิกกำหนดเลขแบบฟอร์มให้เอง

<b>สิ่งที่ปรับในระบบตามคำสั่งนี้</b>
· หัวกระดาษใบรายแบตช์ ขึ้นเลขตามที่บันทึกไว้บนใบนั้น ถ้าไม่ได้ระบุจะขึ้นว่า "ไม่ได้ระบุ" ไม่เติมเลขให้เอง
· หัวกระดาษใบสรุปรายวัน ขึ้นเลขทุกเลขที่ใช้ในวันนั้น ถ้าวันนั้นใช้แบบฟอร์มเดียว ท้ายกระดาษจะขึ้นเลขนั้นด้วย ถ้าใช้หลายเลข ท้ายกระดาษเว้นไว้เพื่อไม่ให้อ้างเลขใดเลขหนึ่งแทนทั้งใบ
· ช่องเลขที่เอกสารในหน้ากรอก มีรายการเลือกจากเลขที่เคยใช้จริง และตั้งต้นด้วยเลขที่ QA ใช้ล่าสุด แก้เป็นเลขอื่นได้ตลอด
· ชื่อหน้าจอและเมนู ตัดเลข FM-QA-05 ที่เคยติดไว้ตายตัวออก เพราะทะเบียนนี้ไม่ได้ผูกกับแบบฟอร์มเดียว',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-011';
