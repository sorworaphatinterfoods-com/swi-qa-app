-- 0053_fix_supplier_material_codes.sql
-- Repair the material codes 0052 wrote. My import, my bug.
--
-- The sheet abbreviates a run of codes: "PD0025,26" means PD0025 and PD0026.
-- 0052 split on commas and kept the bare numbers, so seven suppliers ended up
-- carrying codes like "26" and "2" that identify nothing. Worse, the de-dupe ran
-- on those bare numbers across different prefixes, so "6" arriving from PG0006
-- suppressed the later PK0006 — SP0022 silently lost PK0006 and PK0016.
--
-- Now expanded properly: a bare number inherits the prefix and width of the last
-- full code before it, and de-dupe happens after expansion. Every result is
-- checked against the actual id list in materials / ingredients / packaging /
-- chemicals, not against a numeric range — the range was the reason the first
-- attempt looked clean when it was not.
--
-- FOUR codes in the sheet have no record in any item master and are therefore
-- NOT written. They are listed here because they are worth someone's attention
-- rather than a silent drop:
--
--   PK0039  SP0023 (เจเนอรัล เรคคอร์ด) — กล่องลูกฟูก 5 ชั้น. The packaging
--           master runs PK0038 then PK0040. Either the box was never registered
--           or the sheet has a typo.
--   PG0007  SP0027 (วี-ริน) — คลอรีนน้ำ 10%
--   PG0008  SP0028 (เอ็นริช) — น้ำยาล้างภาชนะ
--   PG0017  SP0029 (ฟลุสสิค) — ผลิตภัณฑ์ฆ่าเชื้ออเนกประสงค์
--           All three chemicals are registered under CM codes (CM0002, CM0003,
--           CM0006) which is what these suppliers already carried. The sheet
--           files them as PG. Two coding systems for the same three items is a
--           master-data question, not something to settle by merging both.
--
-- Nothing else from 0052 is touched — address, contact, email, documents and
-- notes all landed correctly.

UPDATE suppliers SET materialCode = 'RM0001, RM0002', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0001';
UPDATE suppliers SET materialCode = 'RM0004', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0002';
UPDATE suppliers SET materialCode = 'RM0001, RM0002', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0003';
UPDATE suppliers SET materialCode = 'RM0004, RM0005', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0004';
UPDATE suppliers SET materialCode = 'RM0001, RM0002', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0005';
UPDATE suppliers SET materialCode = 'RM0006', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0006';
UPDATE suppliers SET materialCode = 'PD0006, PD0025, PD0026, PD0022, PD0027, PD0028, PD0034, PD0035, PD0010, PD0024, PD0029, PD0031, PD0033, PD0038', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0007';
UPDATE suppliers SET materialCode = 'PD0001, PD0003, PD0004, PD0005', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0008';
UPDATE suppliers SET materialCode = 'PD0002', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0009';
UPDATE suppliers SET materialCode = 'PD0019', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0010';
UPDATE suppliers SET materialCode = 'PD0018', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0011';
UPDATE suppliers SET materialCode = 'PD0017', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0012';
UPDATE suppliers SET materialCode = 'PD0007', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0013';
UPDATE suppliers SET materialCode = 'PD0008', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0014';
UPDATE suppliers SET materialCode = 'PD0009', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0015';
UPDATE suppliers SET materialCode = 'PD0011', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0016';
UPDATE suppliers SET materialCode = 'PD0012, PD0013, PD0014, PD0015, PD0016, PD0030', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0017';
UPDATE suppliers SET materialCode = 'PD0030', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0018';
UPDATE suppliers SET materialCode = 'PD0032', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0019';
UPDATE suppliers SET materialCode = 'PD0008', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0020';
UPDATE suppliers SET materialCode = 'PD0020, PD0021', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0021';
UPDATE suppliers SET materialCode = 'PG0001, PG0002, PG0003, PG0004, PG0005, PG0006, PG0015, PG0016, PK0005, PK0006, PK0007, PK0009, PK0011, PK0012, PK0013, PK0014, PK0015, PK0016, PK0018, PK0026, PK0027, PK0028', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0022';
UPDATE suppliers SET materialCode = 'PK0001, PK0002, PK0038', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0023';
UPDATE suppliers SET materialCode = 'PK0010', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0024';
UPDATE suppliers SET materialCode = 'PK0019, PK0020, PK0021, PK0022, PK0029', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0025';
UPDATE suppliers SET materialCode = 'PK0040', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0026';
UPDATE suppliers SET materialCode = 'CM0002', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0027';
UPDATE suppliers SET materialCode = 'CM0003', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0028';
UPDATE suppliers SET materialCode = 'CM0006', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0029';
UPDATE suppliers SET materialCode = 'PG0012, PG0013, PG0014', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0032';
UPDATE suppliers SET materialCode = 'RM0001, RM0002', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0034';
UPDATE suppliers SET materialCode = 'RM0001, RM0002', modified = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = 'SP0036';