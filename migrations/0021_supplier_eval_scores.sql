-- Migration 0021: add the two new weighted-evaluation criteria to supplier_evaluations
-- Formula (FM supplier evaluation): Quality 25 · Food Safety 30 · Delivery 15 ·
-- Documentation 10 · Audit 10 · Responsiveness 10 → Overall (auto) + grade.
-- qualityScore/deliveryScore/docScore/responseScore/totalScore/grade already exist
-- (migration 0011); this only adds the missing foodSafetyScore + auditScore so the
-- worker (which introspects columns and silently drops unknown keys) persists them.
-- Safe: ADD COLUMN is additive; existing rows get NULL. TEXT to match the table.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0021_supplier_eval_scores.sql --remote

ALTER TABLE supplier_evaluations ADD COLUMN foodSafetyScore TEXT;
ALTER TABLE supplier_evaluations ADD COLUMN auditScore      TEXT;
