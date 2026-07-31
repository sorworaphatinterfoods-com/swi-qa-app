-- 0037_fg_k013_tops_raw.sql
-- New FG: ไก่แดงดิบโบราณ Tops — the RAW chicken line for Tops.
--
-- Distinct from FG - ก007 "Tops ไก่แดงโบราณพร้อมทาน", which is the ready-to-eat
-- version. Same recipe, different state, so they are separate SKUs: raw and
-- cooked cannot share IPQC weight limits, shelf life, or a label.
--
-- Id written as "FG - ก013" (spaces around the dash) to match ก001–ก012. The
-- retail codes use the newer unspaced FG-RT… scheme, but this is an addition to
-- the existing ก series and an unspaced id would sort away from its siblings.
--
-- shelfLife and the weight limits are left NULL, as with the retail SKUs in 0033:
-- per-stick limits decide the IPQC verdict and shelf life prints the expiry date.
-- Copying ก008's 52–54 g would look sourced but nothing would stand behind it —
-- and that row is a retired retail pack, not this product. QA fills them in.

INSERT OR IGNORE INTO finished_goods (id, name, type, storageTemp, status) VALUES
  ('FG - ก013', 'ไก่แดงดิบโบราณ Tops', 'Chicken Marinated', '-18', 'Active');
