-- 0038_ipqc_weight_method.sql
-- ipqc_checks.weightMethod — records HOW the weights in a check were taken:
--   STICK = each stick weighed individually
--   BULK  = the whole set weighed together and divided out
--
-- The form used to show three entry tables at once (per-stick grid, bulk weighing,
-- frequency table) with nothing to say which applied. A QC could fill two, and the
-- summary pooled a 50-stick batch with 10 individual sticks as if both were one
-- reading -- the "13 ไม้" defect. The field drives which single table is shown.
--
-- Left NULL on existing rows on purpose. Nobody chose a method for those records, and
-- writing one now would put a claim in the record that no inspector made. The form
-- falls back to showing whichever table actually holds rows, so every existing record
-- still displays exactly the measurements it was saved with.

ALTER TABLE ipqc_checks ADD COLUMN weightMethod TEXT;
