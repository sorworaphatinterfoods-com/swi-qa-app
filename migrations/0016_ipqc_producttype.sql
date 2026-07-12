-- Migration 0016: IPQC quick-check — add productType for SD-QA-08 §6.1 sampling plan.
-- Records which product-type column of the SD-QA-08 sampling plan applies
-- (40 ไม้/แพ็ก / 50 ไม้/แพ็ก / ไก่เสียบไม้ 100kg/Batch).
-- Safe: ADD COLUMN only — existing rows keep NULL.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0016_ipqc_producttype.sql --remote

ALTER TABLE ipqc_checks ADD COLUMN productType TEXT;
