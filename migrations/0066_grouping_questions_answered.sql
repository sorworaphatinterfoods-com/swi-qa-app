-- 0066_grouping_questions_answered.sql
--
-- QA answered the last two grouping questions on 15/08/26:
--   -0008 ไก่ย่างสูตรโบราณ  — ไม่ผ่านความร้อนในโรงงาน
--   -0010 หมูแดดเดียวพร้อมปรุง — ไม่มีขั้นตอนตากแดดหรืออบแห้ง
--
-- Both stay in the RTC scope. Both flags are withdrawn as wrong, not closed as
-- resolved — there was never anything to resolve.
--
-- Worth recording why they were raised, because the pattern matters more than
-- the two rows. Both came from reading a product name and inferring a process:
-- "ย่าง" was read as grilling, "แดดเดียว" as sun-drying. Neither inference was
-- checked against anyone who knows the line before it was written into a
-- finding. Of the three name-derived questions raised on 15/08/26, two are now
-- withdrawn. That is a poor hit rate and the class of finding should carry a
-- lower confidence than the ones derived from documents and data in hand.

UPDATE reg_products SET
  notes = TRIM(COALESCE(notes,'') || CASE WHEN COALESCE(notes,'')='' THEN '' ELSE ' | ' END ||
    '[15/08/26 ยืนยันโดย QA] ไม่ผ่านความร้อนในโรงงาน — "ย่าง" ในชื่อผลิตภัณฑ์หมายถึงวิธีที่ผู้บริโภคนำไปปรุง ไม่ใช่กรรมวิธีการผลิต · ผลิตภัณฑ์อยู่ในกลุ่ม RTC ตามปกติ · ข้อสงสัยเดิมที่ตั้งไว้ว่าอาจเป็นผลิตภัณฑ์กึ่งสุก ถอนออกแล้ว'),
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE fdaNumber = '13-2-07462-6-0008';

UPDATE reg_products SET
  notes = TRIM(COALESCE(notes,'') || CASE WHEN COALESCE(notes,'')='' THEN '' ELSE ' | ' END ||
    '[15/08/26 ยืนยันโดย QA] ไม่มีขั้นตอนตากแดดหรืออบแห้ง — "แดดเดียว" เป็นชื่อเรียกลักษณะผลิตภัณฑ์ ไม่ใช่กรรมวิธีการผลิต · ผลิตภัณฑ์อยู่ในกลุ่ม RTC ตามปกติ · ข้อสงสัยเดิมเรื่อง aw และเชื้อรา ถอนออกแล้ว'),
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE fdaNumber = '13-2-07462-6-0010';

UPDATE nc_capa SET
  notes = COALESCE(notes,'') || '

[15/08/26 — ตอบครบทั้ง 3 คำถามแล้ว การจัดกลุ่มปิดสมบูรณ์]
(2) -0008 ไก่ย่างสูตรโบราณ ไม่ผ่านความร้อนในโรงงาน — "ย่าง" หมายถึงวิธีที่ผู้บริโภคนำไปปรุง · อยู่ในกลุ่ม B ตามปกติ
(3) -0010 หมูแดดเดียว ไม่มีขั้นตอนตากแดดหรืออบแห้ง — เป็นชื่อเรียกลักษณะผลิตภัณฑ์ · อยู่ในกลุ่ม A ตามปกติ
ข้อสงสัยทั้งสองถอนออกจากตารางจัดกลุ่มแล้ว ไม่ใช่การปิดข้อบกพร่อง แต่เป็นการแก้ข้อกล่าวหาที่ตั้งไว้ผิดตั้งแต่ต้น

<b>บทเรียนที่ควรบันทึกไว้:</b> ข้อสงสัยทั้งสองข้อเกิดจากการอ่านชื่อผลิตภัณฑ์แล้วอนุมานกรรมวิธีการผลิต โดยไม่ได้ตรวจสอบกับผู้ที่รู้หน้างานก่อนบันทึกเป็นข้อบกพร่อง
· จากข้อสงสัยที่มาจากการอ่านชื่อผลิตภัณฑ์ 3 ข้อที่ตั้งไว้เมื่อ 15/08/26 ถอนออกแล้ว 2 ข้อ เหลือเรื่องถั่วลิสงในผลิตภัณฑ์สะเต๊ะที่ยังไม่ได้ตอบ
· ข้อสงสัยประเภทนี้ควรถือเป็น "คำถามที่ต้องยืนยัน" ไม่ใช่ "ข้อบกพร่อง" จนกว่าจะตรวจสอบกับหน้างานแล้ว

<b>สถานะการจัดกลุ่ม ณ ตอนนี้:</b> ผลิตภัณฑ์ทั้ง 38 รายการมีกลุ่มที่ชัดเจนแล้วทุกรายการ
· กลุ่ม A เนื้อหมูหมักเสียบไม้ — ครอบคลุมโดย QM-QA-04
· กลุ่ม B เนื้อไก่หมักเสียบไม้ 11 รายการ — ต้องตัดสินว่าจะขยาย QM-QA-04 หรือเพิ่มผลิตภัณฑ์ตัวแทน
· กลุ่ม C เนื้อหมักไม่เสียบไม้ 9 รายการ — ต้องเพิ่มสาขาของแผนภูมิที่ข้ามขั้นตอนที่ 12
สิ่งที่เหลือของใบนี้จึงเป็นการตัดสินเชิงเอกสาร ไม่ใช่การรอข้อมูลจากหน้างานอีกต่อไป',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-014';
