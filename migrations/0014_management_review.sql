-- Migration 0014: Management Review — meeting log + tracked actions.
-- KPIs themselves are computed live from source records (no stored/fake KPI,
-- rule 14). These two tables hold the review meeting record and the tracked
-- actions that management decisions must become.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0014_management_review.sql --remote

CREATE TABLE IF NOT EXISTS management_reviews (
  id             TEXT PRIMARY KEY,
  reviewDate     TEXT,
  period         TEXT,
  chairperson    TEXT,
  attendees      TEXT,
  agendaCovered  TEXT,          -- which standing agenda items were reviewed
  foodSafetySummary TEXT,
  decisions      TEXT,
  resourceNeeds  TEXT,
  nextReviewDate TEXT,
  status         TEXT DEFAULT 'Open', -- Open | Closed
  closedBy       TEXT,
  closedAt       TEXT,
  notes          TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_mr_date ON management_reviews(reviewDate);

CREATE TABLE IF NOT EXISTS management_review_actions (
  id             TEXT PRIMARY KEY,
  raisedDate     TEXT,
  reviewRef      TEXT,          -- management_reviews.id
  topic          TEXT,          -- KPI / agenda item the action came from
  action         TEXT,
  decisionType   TEXT,          -- CORRECTIVE | IMPROVEMENT | RESOURCE | POLICY
  owner          TEXT,
  dueDate        TEXT,
  priority       TEXT,          -- High | Medium | Low
  status         TEXT DEFAULT 'Open', -- Open | In Progress | Completed
  completedDate  TEXT,
  evidence       TEXT,
  notes          TEXT,
  created        TEXT DEFAULT CURRENT_TIMESTAMP,
  modified       TEXT
);
CREATE INDEX IF NOT EXISTS idx_mra_status ON management_review_actions(status);
CREATE INDEX IF NOT EXISTS idx_mra_date   ON management_review_actions(raisedDate);
