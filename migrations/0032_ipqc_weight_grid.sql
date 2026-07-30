-- Migration 0032: grid weight entry for IPQC.
-- Ten sticks per person is ten readings that belong together; entered as ten rows
-- they cost ten taps and scroll away, so they are now typed across one row per sample
-- set. Stored as [{set,worker,time,w:[...],avg,n}] (jsonCols in registry).
-- Safe: ADD COLUMN is additive.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0032_ipqc_weight_grid.sql --remote

ALTER TABLE ipqc_checks ADD COLUMN weightGrid TEXT;
