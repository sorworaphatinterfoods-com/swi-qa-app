-- Migration 0022: Shelf-Life Study — validate the stated shelf-life & storage
-- instruction of a finished product (Real-time / Accelerated ASLT / Challenge test).
-- Supports GHP/HACCP/Codex & Thai FDA label-claim substantiation: microbiological,
-- chemical (TVB-N/pH/PV/Aw) and sensory results captured per time-point (JSON), with
-- an established shelf-life + storage instruction conclusion. FAIL → NC (client hook).
-- Safe: CREATE IF NOT EXISTS only. timepoints is a JSON array (jsonCols in registry).
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0022_shelf_life_studies.sql --remote

CREATE TABLE IF NOT EXISTS shelf_life_studies (
  id                   TEXT PRIMARY KEY,
  studyDate            TEXT,          -- study start date
  product              TEXT,          -- finished_goods.id (ref)
  productLot           TEXT,          -- lot under study (optional)
  studyType            TEXT,          -- REALTIME | ASLT | CHALLENGE
  storageCondition     TEXT,          -- FROZEN | CHILLED | AMBIENT
  storageTempTarget    TEXT,          -- e.g. "<= -18 C"
  packaging            TEXT,          -- pack format / material
  claimedShelfLife     TEXT,          -- the label claim being validated (e.g. "12 เดือน")
  protocolRef          TEXT,          -- protocol / standard reference
  paramsTested         TEXT,          -- summary of parameters covered
  timepoints           TEXT,          -- JSON array: [{day,tpc,coliform,pathogen,tvbn,ph,pv,sensory,result}]
  acceptanceCriteria   TEXT,          -- limits used to judge each time-point
  establishedShelfLife TEXT,          -- conclusion: validated shelf-life (days/months)
  storageInstruction   TEXT,          -- conclusion: on-label storage statement
  conclusion           TEXT,          -- PASS | FAIL | INCONCLUSIVE
  ncRef                TEXT,          -- NC raised when conclusion = FAIL
  status               TEXT DEFAULT 'Ongoing', -- Ongoing | Completed | Aborted
  studiedBy            TEXT,
  approvedBy           TEXT,
  approvedDate         TEXT,
  notes                TEXT,
  created              TEXT DEFAULT CURRENT_TIMESTAMP,
  modified             TEXT
);
CREATE INDEX IF NOT EXISTS idx_sls_product ON shelf_life_studies(product, status);
CREATE INDEX IF NOT EXISTS idx_sls_date    ON shelf_life_studies(studyDate);
