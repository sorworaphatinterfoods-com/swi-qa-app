-- 0045_maintenance_work_category.sql
-- Align the maintenance module with the vocabulary the repair app already uses
-- (swi-maint-db.maint_requests): a work category alongside the asset, and the
-- P1–P4 priority scale that carries a response time rather than an adjective.
--
-- The two systems describe the same repairs. Left alone they would have drifted
-- into two vocabularies for one factory — "URGENT" here against "P1" there —
-- and neither report would reconcile with the other.
--
-- Work category answers what the asset field cannot. 33 of the 81 imported
-- events are water, electrical, doors and trolleys: real repair work, 40% of the
-- load, against things that are not machines and never will be in an asset
-- register. Categorising the work lets them be counted and owned without
-- inventing asset codes for "the water system".
--
-- Priority moves from LOW/MEDIUM/HIGH/URGENT to P1–P4. The source scale states a
-- target response — P1 12 hours, P2 24 hours, P3 3 days — so "how urgent" has an
-- answer that can be measured instead of argued. No existing row carries a
-- priority (the 81 imported ones were left null rather than guessed), so nothing
-- needs remapping.

ALTER TABLE ghp_maintenance ADD COLUMN workCategory TEXT;  -- UTILITY|MACHINE|BUILDING|COOLING|IT|OTHER

-- Backfill from what each imported row was already identified as. Rows that map
-- to an asset are machine work by definition; the rest are read off the reason
-- recorded when they could not be pinned to a unit.
UPDATE ghp_maintenance SET workCategory = 'MACHINE'  WHERE asset IS NOT NULL;
UPDATE ghp_maintenance SET workCategory = 'UTILITY'  WHERE workCategory IS NULL AND (notes LIKE '%ระบบน้ำ%' OR notes LIKE '%ระบบไฟ%');
UPDATE ghp_maintenance SET workCategory = 'BUILDING' WHERE workCategory IS NULL AND notes LIKE '%ประตู/โครงสร้าง%';
UPDATE ghp_maintenance SET workCategory = 'COOLING'  WHERE workCategory IS NULL AND notes LIKE '%ห้องเย็น%';
UPDATE ghp_maintenance SET workCategory = 'MACHINE'  WHERE workCategory IS NULL AND (notes LIKE '%เครื่องซีล%' OR notes LIKE '%เครื่องสไลด์%' OR notes LIKE '%เครื่องหมัก%' OR notes LIKE '%เครื่องชั่ง%');
-- Trolleys and anything still unidentified: OTHER rather than forced into MACHINE,
-- which would overstate how much of the load is machine breakdown.
UPDATE ghp_maintenance SET workCategory = 'OTHER'    WHERE workCategory IS NULL AND id LIKE 'MNT00%';
