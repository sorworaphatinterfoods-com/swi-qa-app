-- 0068_due_dates_before_surveillance.sql
--
-- QA set 09/09/2569 (2026-09-09) as the completion target for the findings
-- raised in the 15/08/26 document review, ahead of the mid-September
-- surveillance audit.
--
-- Written in ISO form, not 09/09/69, and that is not a style preference. The
-- overdue calculation compares dueDate against today's ISO date as plain
-- strings. Any DD/MM/YY value sorts below "2026-…" on the first character, so
-- a date written that way reads as overdue no matter how far in the future it
-- is. Seventeen legacy rows already carry 14/06/26 and are counted overdue —
-- correctly, but by accident rather than by arithmetic. Those are normalised
-- here too, so the count is right for the right reason.

UPDATE nc_capa SET
  dueDate = '2026-09-09',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE date = '2026-08-15' AND (dueDate IS NULL OR dueDate = '');

-- 14/06/26 → 2026-06-14. Guarded on the exact shape so nothing else is touched.
UPDATE nc_capa SET
  dueDate = '20' || substr(dueDate,7,2) || '-' || substr(dueDate,4,2) || '-' || substr(dueDate,1,2),
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE dueDate LIKE '__/__/__'
  AND substr(dueDate,3,1) = '/' AND substr(dueDate,6,1) = '/';

-- ── the two that will not make the date ─────────────────────────────────────
-- Both carry the target QA set. The concern is recorded on the findings rather
-- than acted on unilaterally: an overdue CAPA at a surveillance audit is itself
-- a finding, so a target that is known to be unreachable costs more than a
-- later one honestly set.
UPDATE nc_capa SET
  notes = COALESCE(notes,'') || '

[15/08/26 — กำหนดเสร็จ 09/09/2569 ตามที่ QA กำหนด · ข้อสังเกตเรื่องความเป็นไปได้]
ขอบเขตของใบนี้คือการวิเคราะห์อันตราย 14 ขั้นตอนที่ยังไม่ได้ทำ ซึ่งเป็นงานของคณะทำงานทั้งคณะ ไม่ใช่งานที่ QA ทำคนเดียวได้
· การประชุมวิเคราะห์เฉพาะขั้นตอนที่ 8 และ 15 ทำได้ทันภายในกำหนด และเป็นสองขั้นตอนที่สำคัญที่สุด
· แต่การวิเคราะห์ให้ครบทั้ง 14 ขั้นตอนภายใน 09/09/2569 มีโอกาสไม่ทันสูง
· <b>ข้อบกพร่องที่เลยกำหนดในวันตรวจ เป็นข้อบกพร่องซ้อนอีกชั้น</b> — ผู้ตรวจอ่านว่าระบบ CAPA ไม่ทำงาน ซึ่งหนักกว่าการมีข้อบกพร่องที่ยังไม่ถึงกำหนด
· ทางที่ปลอดภัยกว่าคือแบ่งเป็นสองระยะในใบเดียวกัน: ระยะที่ 1 ขั้นตอนที่ 8 และ 15 ภายใน 09/09/2569 · ระยะที่ 2 ขั้นตอนที่เหลือภายในวันที่กำหนดหลังการตรวจ พร้อมแสดงความคืบหน้าให้เห็น
· ยังไม่ปรับกำหนดเอง รอ QA ตัดสิน',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-005';

UPDATE nc_capa SET
  notes = COALESCE(notes,'') || '

[15/08/26 — กำหนดเสร็จ 09/09/2569 ตามที่ QA กำหนด · ข้อสังเกตเรื่องความเป็นไปได้]
ขนาดงานของใบนี้ยังไม่ทราบ เพราะขึ้นกับผลการวิเคราะห์ความเสี่ยงว่าจะเหลือ OPRP กี่จุด
· ถ้าคะแนนออกมาแล้วบางขั้นตอนต่ำกว่า 6 เกณฑ์ในข้อ 2 อนุญาตให้ควบคุมด้วย PRP ซึ่งจะลดจำนวนแผนควบคุมที่ต้องเขียนลงมาก
· ถ้ายังเหลือ 8 จุด ต้องเขียนแผนควบคุมเพิ่ม 7 ชุด พร้อมเฝ้าระวังและบันทึกจริงทุกจุด ซึ่งไม่น่าทันภายใน 09/09/2569
· ใบนี้ผูกกับ NCR-256908-005 โดยตรง — วิเคราะห์เสร็จเมื่อไหร่จึงจะประเมินขนาดงานของใบนี้ได้
· ยังไม่ปรับกำหนดเอง รอ QA ตัดสิน',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256908-004';
