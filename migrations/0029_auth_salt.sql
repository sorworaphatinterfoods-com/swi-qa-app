-- Migration 0029: real password hashing for the users table.
-- The stored password_hash values did not match what the login endpoint computed
-- (20 chars vs a 64-char sha256 hex), so server-side login could never succeed and
-- the app fell back to a client-side check — which is not authentication at all.
-- Passwords now use PBKDF2-HMAC-SHA256 (100k iterations) with a per-user random
-- salt, so this adds the salt column. Hashes are seeded separately (never in git).
-- Safe: ADD COLUMN is additive.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0029_auth_salt.sql --remote

ALTER TABLE users ADD COLUMN salt TEXT;
