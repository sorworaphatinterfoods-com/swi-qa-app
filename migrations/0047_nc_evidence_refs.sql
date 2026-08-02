-- 0047_nc_evidence_refs.sql
-- Let an NC point at the records that prove it was fixed.
--
-- The 14/05/69 audit findings on traceability and recall were reported as "not
-- done" when the work had in fact been done and recorded: RCL0001 (mock recall,
-- 12 มิ.ย., PASS, 100% reconciliation, 135 min against a 240 min target) and
-- TR-20260628-001 (forward trace, complete with mass balance). Both sat in
-- their own modules with nothing tying them to the findings they answered, so
-- from the NC screen the work looked undone.
--
-- That is the same weakness the batch CSV closure had, seen from the other
-- side: closure and evidence were never connected in either direction. One
-- column fixes both — the NC now names its evidence, and "what did you close
-- this with?" has an answer on the record instead of in someone's memory.
--
-- Stored as a JSON array of record IDs, e.g. ["RCL0001","TR-20260628-001"].
-- TEXT rather than a jsonCol so it round-trips unchanged through /api/sync;
-- the client parses it at the edges.

ALTER TABLE nc_capa ADD COLUMN evidenceRefs TEXT;
