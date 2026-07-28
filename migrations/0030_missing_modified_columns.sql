-- Migration 0030: add the missing `modified` column to every synced table.
--
-- The sync resolves conflicts last-write-wins on COALESCE(modified, created).
-- 22 registry tables never had a `modified` column, so an edited record could only
-- ever compare on its (immutable) `created` value: the client's stale copy tied
-- with the server's corrected one and pushed itself back. That is the same
-- "an old value came back after I edited it" failure that was fixed for the other
-- tables — these were simply never covered.
--
-- Adding the column lets a genuine edit win in both directions, and lets an
-- out-of-band correction (applied directly to D1) survive the next client push.
-- Safe: ADD COLUMN is additive; existing rows get NULL and fall back to `created`.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0030_missing_modified_columns.sql --remote

ALTER TABLE ccps                 ADD COLUMN modified TEXT;
ALTER TABLE chemicals            ADD COLUMN modified TEXT;
ALTER TABLE complaints           ADD COLUMN modified TEXT;
ALTER TABLE environmental        ADD COLUMN modified TEXT;
ALTER TABLE fg_inspections       ADD COLUMN modified TEXT;
ALTER TABLE finished_goods       ADD COLUMN modified TEXT;
ALTER TABLE haccp_records        ADD COLUMN modified TEXT;
ALTER TABLE incoming_inspections ADD COLUMN modified TEXT;
ALTER TABLE ingredients          ADD COLUMN modified TEXT;
ALTER TABLE lot_genealogy        ADD COLUMN modified TEXT;
ALTER TABLE machines             ADD COLUMN modified TEXT;
ALTER TABLE nc_capa              ADD COLUMN modified TEXT;
ALTER TABLE packaging            ADD COLUMN modified TEXT;
ALTER TABLE parameters           ADD COLUMN modified TEXT;
ALTER TABLE pkg_inspections      ADD COLUMN modified TEXT;
ALTER TABLE process_parameter_map ADD COLUMN modified TEXT;
ALTER TABLE processes            ADD COLUMN modified TEXT;
ALTER TABLE product_labels       ADD COLUMN modified TEXT;
ALTER TABLE rm_inspections       ADD COLUMN modified TEXT;
ALTER TABLE traceability         ADD COLUMN modified TEXT;
ALTER TABLE training             ADD COLUMN modified TEXT;
ALTER TABLE transport_inspections ADD COLUMN modified TEXT;
