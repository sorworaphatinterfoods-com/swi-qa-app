-- 0042_machine_asset_register.sql
-- Turn `machines` into a maintenance asset register.
--
-- QA reports 40 machines on site. The table holds 7, with generic English names
-- (meat_cutter, marinade_mixer, skewer_machine …) that nobody on the floor uses --
-- seven months of the repair group call them เครื่องเสียบ L, SL-03, เครื่องเล็ก.
-- A register nobody can match a machine to cannot receive a work order.
--
-- Extending `machines` rather than filling maintenance_assets, which exists on D1
-- from an early import but is empty, in no registry, and wired to nothing. Two
-- asset registers would split the history the moment either was used, and the
-- work-order module already references machines.asset.
--
-- The added columns are what a maintenance and food-safety audit actually asks:
-- what the floor calls it, where it is, whether it serves a control point, how
-- badly a breakdown hurts, and when it is next due for planned maintenance.
--
-- No machine rows are created here. Naming and coding 40 assets is the factory's
-- to state; deriving them from chat messages would put invented codes in a
-- register that work orders and CCP links then point at.

ALTER TABLE machines ADD COLUMN assetCode       TEXT;  -- รหัสที่ใช้เรียกหน้างาน เช่น SL-03
ALTER TABLE machines ADD COLUMN area            TEXT;  -- ห้อง/พื้นที่ติดตั้ง
ALTER TABLE machines ADD COLUMN brand           TEXT;
ALTER TABLE machines ADD COLUMN model           TEXT;
ALTER TABLE machines ADD COLUMN serialNo        TEXT;
ALTER TABLE machines ADD COLUMN riskLevel       TEXT;  -- LOW | MEDIUM | HIGH | CRITICAL
ALTER TABLE machines ADD COLUMN ccpLink         TEXT;  -- ccps.id — จุดควบคุมที่เครื่องนี้รองรับ
ALTER TABLE machines ADD COLUMN backupAvailable TEXT;  -- yes | no — มีเครื่องสำรองหรือไม่
ALTER TABLE machines ADD COLUMN pmFreqMonths    TEXT;  -- ความถี่ PM (เดือน)
ALTER TABLE machines ADD COLUMN nextPmDue       TEXT;
ALTER TABLE machines ADD COLUMN notes           TEXT;
