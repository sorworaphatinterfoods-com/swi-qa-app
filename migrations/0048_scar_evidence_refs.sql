-- 0048_scar_evidence_refs.sql
-- The same column on supplier_scars, for the same reason.
--
-- A SCAR already refuses to close until effectiveness reads EFFECTIVE, which
-- asks the right question and then accepts any answer: the word EFFECTIVE in a
-- dropdown is not evidence that the supplier fixed anything. What proves it is
-- the next delivery passing incoming inspection, or a re-evaluation, or an
-- on-site audit report — records this system already holds, with nothing tying
-- them to the SCAR they answer.
--
-- Two of the four open SCARs are the same missing ร.น. against the same
-- supplier, raised eleven days apart. The first was closed. Whatever was
-- accepted as proof that it was fixed is not recorded anywhere, and the problem
-- came back — which is exactly the question a surveillance auditor asks when
-- they see a repeat finding.
--
-- Same shape as nc_capa.evidenceRefs: a JSON array of record IDs, TEXT so it
-- round-trips through /api/sync unchanged.

ALTER TABLE supplier_scars ADD COLUMN evidenceRefs TEXT;
