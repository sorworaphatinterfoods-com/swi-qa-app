-- Migration 0026: link the in-process metal-detector CCP check to the CCP module.
-- When an in-process inspection (FM-QA-34) records the metal-detection process, the
-- app mirrors it into metal_detector_verifications and (on fail) raises a CCP
-- deviation + hold + NC. These columns make the two-way link persist through sync.
-- Safe: ADD COLUMN is additive.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0026_ccp_inprocess_link.sql --remote

ALTER TABLE metal_detector_verifications ADD COLUMN ipRef     TEXT;  -- source in-process record
ALTER TABLE inprocess_inspections        ADD COLUMN mdvRef    TEXT;  -- mirrored MD verification
ALTER TABLE inprocess_inspections        ADD COLUMN ccpDevRef TEXT;  -- CCP deviation raised (on fail)
ALTER TABLE inprocess_inspections        ADD COLUMN holdRef   TEXT;  -- product hold raised (on fail)
ALTER TABLE ccp_deviations               ADD COLUMN ipRef     TEXT;  -- source in-process record
