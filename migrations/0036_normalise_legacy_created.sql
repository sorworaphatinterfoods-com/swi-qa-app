-- 0036_normalise_legacy_created.sql
-- 140 rows imported early on carry `created` as "DD/MM/YY HH:MM" instead of ISO
-- (30 in finished_goods, 110 in materials).
--
-- Last-write-wins compares these timestamps as TEXT. "27/05/26 04:14" sorts ABOVE
-- every ISO "2026-..." value, because '7' > '0' at the second character. Any client
-- copy of one of these rows therefore won every conflict no matter how stale, and
-- server-side corrections were silently reverted on the next sync -- observed when
-- a retired FG came back Active minutes after being retired.
--
-- Rewrites the value in place to the ISO form the comparison expects. Same instant,
-- same information: "27/05/26 04:14" -> "2026-05-27T04:14:00.000Z".
--
-- Matched by length + separator positions rather than a GLOB pattern: D1 rejects
-- a character-class pattern this long with "LIKE or GLOB pattern too complex".
-- Only the legacy shape matches, so the statement is safe to re-run.

UPDATE finished_goods
   SET created = '20' || substr(created, 7, 2) || '-' || substr(created, 4, 2) || '-'
              || substr(created, 1, 2) || 'T' || substr(created, 10, 5) || ':00.000Z'
 WHERE length(created) = 14 AND instr(created, '/') = 3 AND substr(created, 6, 1) = '/';

UPDATE materials
   SET created = '20' || substr(created, 7, 2) || '-' || substr(created, 4, 2) || '-'
              || substr(created, 1, 2) || 'T' || substr(created, 10, 5) || ':00.000Z'
 WHERE length(created) = 14 AND instr(created, '/') = 3 AND substr(created, 6, 1) = '/';
