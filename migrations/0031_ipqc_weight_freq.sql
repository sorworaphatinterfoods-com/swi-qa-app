-- Migration 0031: frequency-table weight recording for IPQC.
-- On the line ten sticks usually land on three or four distinct weights, so QA
-- records "36 g x 5" instead of keying ten near-identical numbers. Stored as a JSON
-- array [{set,worker,weight,count}] (jsonCols in registry) and rendered as a dot
-- plot on the printed record.
-- Safe: ADD COLUMN is additive.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0031_ipqc_weight_freq.sql --remote

ALTER TABLE ipqc_checks ADD COLUMN weightFreq TEXT;
