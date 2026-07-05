-- Migration 0012: GHP Foundation Programs (Prerequisite / GHPs).
-- Adds the missing food-safety prerequisite programs as controlled daily
-- inspection records that link to NC/CAPA/HOLD (rule 3). Existing GHP-ish
-- modules (pest_control, environmental, chemicals) are untouched.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0012_ghp_foundation.sql --remote

CREATE TABLE IF NOT EXISTS ghp_personnel_hygiene (
  id TEXT PRIMARY KEY, date TEXT, shift TEXT, area TEXT, inspector TEXT,
  uniformClean TEXT, handWash TEXT, nailsShort TEXT, noJewelry TEXT, hairCover TEXT,
  maskGloves TEXT, footwear TEXT, woundCover TEXT, noIllness TEXT, noPersonalItems TEXT,
  numChecked TEXT, numFail TEXT, nonConformers TEXT, result TEXT, correctiveAction TEXT,
  ncRef TEXT, notes TEXT, created TEXT DEFAULT CURRENT_TIMESTAMP, modified TEXT
);
CREATE INDEX IF NOT EXISTS idx_ghy_date ON ghp_personnel_hygiene(date);

CREATE TABLE IF NOT EXISTS ghp_cleaning_sanitation (
  id TEXT PRIMARY KEY, date TEXT, area TEXT, equipment TEXT, cleaningType TEXT,
  chemicalUsed TEXT, concentration TEXT, contactTime TEXT, visualClean TEXT, atpResult TEXT,
  swabResult TEXT, verifiedBy TEXT, result TEXT, correctiveAction TEXT, ncRef TEXT, notes TEXT,
  created TEXT DEFAULT CURRENT_TIMESTAMP, modified TEXT
);
CREATE INDEX IF NOT EXISTS idx_gcl_date ON ghp_cleaning_sanitation(date);

CREATE TABLE IF NOT EXISTS ghp_water_quality (
  id TEXT PRIMARY KEY, date TEXT, samplePoint TEXT, ph TEXT, freeChlorine TEXT, coliform TEXT,
  hardness TEXT, appearance TEXT, tester TEXT, result TEXT, correctiveAction TEXT, ncRef TEXT, notes TEXT,
  created TEXT DEFAULT CURRENT_TIMESTAMP, modified TEXT
);
CREATE INDEX IF NOT EXISTS idx_gwq_date ON ghp_water_quality(date);

CREATE TABLE IF NOT EXISTS ghp_allergen_control (
  id TEXT PRIMARY KEY, date TEXT, line TEXT, allergenType TEXT, changeoverFrom TEXT, changeoverTo TEXT,
  cleaningVerified TEXT, segregation TEXT, labelCheck TEXT, swabProtein TEXT, result TEXT,
  correctiveAction TEXT, ncRef TEXT, inspector TEXT, notes TEXT,
  created TEXT DEFAULT CURRENT_TIMESTAMP, modified TEXT
);
CREATE INDEX IF NOT EXISTS idx_gal_date ON ghp_allergen_control(date);

CREATE TABLE IF NOT EXISTS ghp_glass_control (
  id TEXT PRIMARY KEY, date TEXT, checkType TEXT, location TEXT, item TEXT, condition TEXT,
  action TEXT, productAffected TEXT, holdRef TEXT, result TEXT, inspector TEXT, ncRef TEXT, notes TEXT,
  created TEXT DEFAULT CURRENT_TIMESTAMP, modified TEXT
);
CREATE INDEX IF NOT EXISTS idx_ggl_date ON ghp_glass_control(date);

CREATE TABLE IF NOT EXISTS ghp_waste_control (
  id TEXT PRIMARY KEY, date TEXT, area TEXT, wasteType TEXT, quantity TEXT, unit TEXT,
  disposalMethod TEXT, contractor TEXT, segregation TEXT, storageOk TEXT, result TEXT,
  correctiveAction TEXT, ncRef TEXT, recordedBy TEXT, notes TEXT,
  created TEXT DEFAULT CURRENT_TIMESTAMP, modified TEXT
);
CREATE INDEX IF NOT EXISTS idx_gwm_date ON ghp_waste_control(date);
