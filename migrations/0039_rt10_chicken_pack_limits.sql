-- 0039_rt10_chicken_pack_limits.sql
-- Pack (net weight) limits for the seven 10-stick chicken retail packs. They had
-- per-stick limits but none per pack, so the SD-QA-08 net-weight check (5 แพ็ก/ชม.)
-- had no criterion to judge against and evalSpec returned NA.
--
-- Derived as sticks x per-stick limits, which is the convention QA already applied
-- to every comparable SKU -- the ratio is exact in all eight:
--   FG-RT10-P001  50-52  -> 500-520   (10x)
--   FG-RT10-P002  35-37  -> 350-370   (10x)
--   FG-RT10-P004  50-52  -> 500-520   (10x)
--   FG-RT20-P001  25-26  -> 500-520   (20x)
--   FG-RT20-P002  16-18  -> 320-360   (20x)
--   FG-RT20-P003  30-32  -> 600-640   (20x)
--   FG - ก011     58-60  -> 2900-3000 (50x)
--   FG - ก012     58-60  -> 580-600   (10x)
--
-- FG-RT10-C007 is the same product as FG - ก012 (บั้นท้ายไก่แดง, 10 sticks, 58-60 g),
-- so its 580-600 is copied from an existing approved row rather than derived.
--
-- PROVISIONAL. Requested so the check can be exercised on the line; the figures are
-- arithmetic from the per-stick limits, not measurements. Declared net weight need
-- not equal the sum of the sticks -- the skewer is included in a pack weighing but
-- not in a per-stick one, and declared weight is usually set below actual to leave
-- headroom. Confirm against real weighings before treating these as the approved
-- spec, and expect the lower bound in particular to move.
--
-- Only fills rows where the pack limits are still empty, so a value QA has since
-- entered by hand is never overwritten.

UPDATE finished_goods SET minPack = 520, maxPack = 540, modified = datetime('now')
 WHERE id IN ('FG-RT10-C001','FG-RT10-C002','FG-RT10-C003',
              'FG-RT10-C004','FG-RT10-C005','FG-RT10-C006')
   AND minPack IS NULL AND maxPack IS NULL;

UPDATE finished_goods SET minPack = 580, maxPack = 600, modified = datetime('now')
 WHERE id = 'FG-RT10-C007'
   AND minPack IS NULL AND maxPack IS NULL;
