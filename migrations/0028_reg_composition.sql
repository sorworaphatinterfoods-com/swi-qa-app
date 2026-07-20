-- Migration 0028: FDA product register — declared formula (สูตรส่วนประกอบ).
-- Stores the composition as % by weight (totalling 100%) with each ingredient's
-- source (FDA serial no., or COA / Specification when the material has no อย. number).
-- composition is a JSON array (jsonCols in registry); compositionNote is free text.
-- Safe: ADD COLUMN is additive.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0028_reg_composition.sql --remote

ALTER TABLE reg_products ADD COLUMN composition     TEXT;  -- JSON [{name,percent,sourceType,sourceRef}]
ALTER TABLE reg_products ADD COLUMN compositionNote TEXT;
