-- 0035_column_drift.sql
-- Three form fields had no column declared in schema.sql/migrations.
--
-- ipqc_checks.skewerMethod is the serious one: it was missing from the live
-- database as well, so every IPQC record saved since the machine-vs-hand field
-- shipped had its value dropped on sync. Because pullFromServer merges the
-- server copy back over local state, the choice did not survive a refresh
-- either -- and it is the field that decides whether per-set lots are derived
-- (H1/H2/H3/H4) or the run carries one lot end to end. Silent data loss on a
-- traceability input.
--
-- transport_inspections.products and training.attendeeNames already exist on
-- the live database -- they were added straight to D1 and never written into a
-- migration, so a database rebuilt from this repo would come up missing them.
-- Declared here so the migrations reproduce production.
--
-- ADD COLUMN is not idempotent in SQLite; the runner treats "duplicate column"
-- as already-applied, which is how the two existing columns are handled.

ALTER TABLE ipqc_checks           ADD COLUMN skewerMethod  TEXT;
ALTER TABLE transport_inspections ADD COLUMN products      TEXT;
ALTER TABLE training              ADD COLUMN attendeeNames TEXT;
