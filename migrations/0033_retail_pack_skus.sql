-- 0033_retail_pack_skus.sql
-- Register the official retail SKU codes for the 10-stick and 20-stick packs,
-- plus the 300 g / 250 g marinated retail packs, as supplied by QA.
--
-- Additive only. Six rows already in finished_goods describe what looks like the
-- same physical product under interim codes (FG - ก008/ก009/ก010/ก012/ม030/ม031).
-- They are NOT renamed or deleted here: deciding which interim row a new code
-- supersedes is a master-data call for QA, and deactivating the wrong one would
-- hide a live product from every dropdown in the app.
--
-- shelfLife / minWeight / maxWeight / minPack / maxPack are deliberately left
-- NULL. Per-stick weight limits drive the IPQC pass/fail verdict and shelf life
-- drives the printed expiry date; inventing either would manufacture a spec that
-- no study or approval stands behind. QA fills them in via the FG master screen.

INSERT OR IGNORE INTO finished_goods (id, name, type, storageTemp, status) VALUES
  -- ── ไก่เสียบไม้ · แพ็ก 10 ไม้ ──
  ('FG-RT10-C001',   'ไก่แดงโบราณ แพ็ก 10 ไม้',              'Chicken Marinated', '-18', 'Active'),
  ('FG-RT10-C002',   'ไก่พริกไทยดำ แพ็ก 10 ไม้',             'Chicken Marinated', '-18', 'Active'),
  ('FG-RT10-C003',   'ไก่ปิ้งนมสด แพ็ก 10 ไม้',              'Chicken Marinated', '-18', 'Active'),
  ('FG-RT10-C004',   'ไก่เทอริยากิ แพ็ก 10 ไม้',             'Chicken Marinated', '-18', 'Active'),
  ('FG-RT10-C005',   'ไก่หม่าล่า แพ็ก 10 ไม้',               'Chicken Marinated', '-18', 'Active'),
  ('FG-RT10-C006',   'ไก่บาร์บีคิว แพ็ก 10 ไม้',             'Chicken Marinated', '-18', 'Active'),
  ('FG-RT10-C007',   'บั้นท้ายไก่แดงโบราณ แพ็ก 10 ไม้',      'Chicken Marinated', '-18', 'Active'),

  -- ── ไก่หมัก (ไม่เสียบไม้) · 300 g ──
  ('FG-RT300-CM001', 'ไก่หมักแดงโบราณ 300g',                 'Chicken Marinated', '-18', 'Active'),
  ('FG-RT300-CM002', 'ไก่หมักพริกไทยดำ 300g',                'Chicken Marinated', '-18', 'Active'),
  ('FG-RT300-CM003', 'ไก่หมักนมสด 300g',                     'Chicken Marinated', '-18', 'Active'),
  ('FG-RT300-CM004', 'ไก่หมักเทอริยากิ 300g',                'Chicken Marinated', '-18', 'Active'),
  ('FG-RT300-CM005', 'ไก่หมักหม่าล่า 300g',                  'Chicken Marinated', '-18', 'Active'),
  ('FG-RT300-CM006', 'ไก่หมักบาร์บีคิว 300g',                'Chicken Marinated', '-18', 'Active'),
  ('FG-RT300-CM007', 'บั้นท้ายไก่หมักแดงโบราณ 300g',         'Chicken Marinated', '-18', 'Active'),

  -- ── หมูเสียบไม้ · แพ็ก 10 ไม้ ──
  ('FG-RT10-P001',   'หมูปิ้งนมสดเสียบไม้ Size L แพ็ก 10 ไม้', 'Pork Marinated',  '-18', 'Active'),
  ('FG-RT10-P002',   'หมูแดดเดียว แพ็ก 10 ไม้',               'Pork Marinated',   '-18', 'Active'),
  ('FG-RT10-P003',   'หมูปิ้งรสหม่าล่า แพ็ก 10 ไม้',          'Pork Marinated',   '-18', 'Active'),
  -- Listed in orange on QA's sheet — flagged to QA to confirm whether this pure-pork
  -- variant is live or still a draft code. Seeded Active so it is selectable; QA
  -- flips it to Inactive if the SKU has not been released.
  ('FG-RT10-P004',   'หมูปิ้งนมสดเสียบไม้ Size L (หมูล้วน)',  'Pork Marinated',   '-18', 'Active'),

  -- ── หมูเสียบไม้ · แพ็ก 20 ไม้ ──
  ('FG-RT20-P001',   'หมูปิ้งนมสดเสียบไม้ Size S แพ็ก 20 ไม้', 'Pork Marinated',  '-18', 'Active'),
  ('FG-RT20-P002',   'หมูปิ้งโบราณ Size S แพ็ก 20 ไม้',       'Pork Marinated',   '-18', 'Active'),
  ('FG-RT20-P003',   'หมูสะเต๊ะ แพ็ก 20 ไม้',                 'Pork Marinated',   '-18', 'Active'),

  -- ── หมูหมัก (ไม่เสียบไม้) · 250 g ──
  ('FG-RT250-PM001', 'หมูแดดเดียวหมัก 250g',                  'Pork Marinated',   '-18', 'Active');
