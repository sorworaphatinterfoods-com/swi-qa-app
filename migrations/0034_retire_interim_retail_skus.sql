-- 0034_retire_interim_retail_skus.sql
-- Retire the five interim retail codes now superseded by the official SKUs
-- registered in 0033. QA confirmed the mapping:
--
--   FG - ก008  Retail ไก่แดงดิบสูตรโบราณ x 10 ไม้  ->  FG-RT10-C001
--   FG - ก009  Retail ไก่ปิ้งนมสด x 10 ไม้         ->  FG-RT10-C003
--   FG - ก010  Retail ไก่ปิ้งพริกไทยดำ x 10 ไม้     ->  FG-RT10-C002
--   FG - ม030  Retail หมูปิ้งเสียบไม้ Size L x 10   ->  FG-RT10-P001
--   FG - ม031  Retail หมูปิ้งเสียบไม้ Size S x 20   ->  FG-RT20-P001
--
-- All five carry zero referencing records (ipqc_checks, fg_inspections, fg_lots,
-- traceability, reg_products, shelf_life_studies), so nothing is orphaned.
--
-- FG - ก012 is deliberately NOT retired: it is referenced by one reg_products
-- row (an อย. registration), and retiring a product under active registration is
-- a regulatory decision, not a cleanup.
--
-- Status flip, not DELETE — the row stays for audit trail and stays resolvable if
-- any record is ever found pointing at it.

UPDATE finished_goods
   SET status   = 'Inactive',
       modified = datetime('now')
 WHERE id IN ('FG - ก008', 'FG - ก009', 'FG - ก010', 'FG - ม030', 'FG - ม031');
