-- Migration 0010: extend the existing `capa` table to a full 9-stage CAPA
-- workflow (Correction -> Containment -> Investigation -> RCA -> Corrective ->
-- Preventive -> Implementation -> Effectiveness Verification -> QA Closure).
-- SAFE MIGRATION: ADD COLUMN only. The table is NOT renamed, no PK change, no
-- existing column dropped — the 43 existing CAPA rows are preserved and remain
-- backward-compatible. SQLite errors harmlessly if a column already exists.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0010_capa_workflow_extend.sql --remote

ALTER TABLE capa ADD COLUMN problemDescription   TEXT;
ALTER TABLE capa ADD COLUMN severity             TEXT;
ALTER TABLE capa ADD COLUMN immediateCorrection  TEXT;
ALTER TABLE capa ADD COLUMN correctionBy         TEXT;
ALTER TABLE capa ADD COLUMN correctionDate       TEXT;
ALTER TABLE capa ADD COLUMN containment          TEXT;
ALTER TABLE capa ADD COLUMN containmentRef       TEXT;
ALTER TABLE capa ADD COLUMN investigation        TEXT;
ALTER TABLE capa ADD COLUMN rcaMethod            TEXT;
ALTER TABLE capa ADD COLUMN correctiveBy         TEXT;
ALTER TABLE capa ADD COLUMN correctiveDue        TEXT;
ALTER TABLE capa ADD COLUMN preventiveBy         TEXT;
ALTER TABLE capa ADD COLUMN preventiveDue        TEXT;
ALTER TABLE capa ADD COLUMN implementationDate   TEXT;
ALTER TABLE capa ADD COLUMN implementedBy        TEXT;
ALTER TABLE capa ADD COLUMN implementationEvidence TEXT;
ALTER TABLE capa ADD COLUMN effectivenessMethod  TEXT;
ALTER TABLE capa ADD COLUMN effectivenessDueDate TEXT;
ALTER TABLE capa ADD COLUMN effectivenessResult  TEXT;
ALTER TABLE capa ADD COLUMN effectivenessDate    TEXT;
ALTER TABLE capa ADD COLUMN capaStage            TEXT;
ALTER TABLE capa ADD COLUMN escalationLevel      TEXT;
ALTER TABLE capa ADD COLUMN reopenCount          TEXT;
ALTER TABLE capa ADD COLUMN closedBy             TEXT;
ALTER TABLE capa ADD COLUMN closedAt             TEXT;
ALTER TABLE capa ADD COLUMN modified             TEXT;
