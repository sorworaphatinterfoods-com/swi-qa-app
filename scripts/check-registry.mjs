#!/usr/bin/env node
/* ============================================================================
 * check-registry.mjs — guards the single source of truth (registry.js).
 *
 * Catches the drift that used to break D1 silently:
 *   1. registry.js loads and every entry is well-formed
 *   2. every registry table has a CREATE TABLE in schema.sql or migrations/*.sql
 *      (the exact "table missing on D1" bug)
 *   3. worker.js and operations.html consume the registry (no stale hardcoded
 *      CLIENT_KEYMAP / TABLES / SERVER_TABLE literals left behind)
 *   4. worker.js and registry.js are syntactically valid
 *
 * Usage:  node scripts/check-registry.mjs      (exit 1 on any failure)
 * ==========================================================================*/
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const read = f => fs.readFileSync(path.join(root, f), 'utf8');
const fails = [];
const fail = m => fails.push(m);

// 1) load registry.js -------------------------------------------------------
await import(path.join(root, 'registry.js'));
const reg = globalThis.SWI_REGISTRY;
if (!reg || !Array.isArray(reg.REGISTRY)) {
  fail('registry.js did not set globalThis.SWI_REGISTRY.REGISTRY');
  report();
}
const { REGISTRY } = reg;

// entry shape + uniqueness
const seenKey = new Set(), seenTable = new Set(), seenPrefix = new Set();
for (const r of REGISTRY) {
  if (!r.key || !r.table || !r.prefix) fail(`entry missing key/table/prefix: ${JSON.stringify(r)}`);
  if (seenKey.has(r.key))       fail(`duplicate key: ${r.key}`);
  if (seenTable.has(r.table))   fail(`duplicate table: ${r.table}`);
  if (seenPrefix.has(r.prefix)) fail(`duplicate prefix: ${r.prefix}`);
  seenKey.add(r.key); seenTable.add(r.table); seenPrefix.add(r.prefix);
}

// 2) every table has a CREATE TABLE somewhere in the SQL --------------------
let sql = '';
try { sql += read('schema.sql'); } catch {}
const migDir = path.join(root, 'migrations');
if (fs.existsSync(migDir)) {
  for (const f of fs.readdirSync(migDir)) if (f.endsWith('.sql')) sql += '\n' + read(path.join('migrations', f));
}
const created = new Set(
  [...sql.matchAll(/CREATE TABLE (?:IF NOT EXISTS )?([a-zA-Z_][a-zA-Z0-9_]*)/g)].map(m => m[1])
);
for (const r of REGISTRY) {
  if (!created.has(r.table)) fail(`table "${r.table}" (key ${r.key}) has no CREATE TABLE in schema.sql/migrations`);
}

// 3) both consumers reference the registry, no stale literals ---------------
const worker = read('worker.js');
const ops = read('operations.html');
if (!/globalThis\.SWI_REGISTRY/.test(worker))       fail('worker.js does not read globalThis.SWI_REGISTRY');
if (!/import ['"]\.\/registry\.js['"]/.test(worker)) fail('worker.js does not import ./registry.js');
if (/const CLIENT_KEYMAP = \{/.test(worker))         fail('worker.js still has a hardcoded CLIENT_KEYMAP literal');
if (/const TABLES = \{[\s\S]*idPrefix/.test(worker)) fail('worker.js still has a hardcoded TABLES literal');
if (!/globalThis\.SWI_REGISTRY/.test(ops))           fail('operations.html does not read globalThis.SWI_REGISTRY');
if (!/<script src="\.\/registry\.js">/.test(ops))    fail('operations.html does not load ./registry.js');
if (/const SERVER_TABLE = \{/.test(ops))             fail('operations.html still has a hardcoded SERVER_TABLE literal');

// 4) syntax ------------------------------------------------------------------
for (const f of ['registry.js', 'worker.js']) {
  try { execSync(`node --check "${path.join(root, f)}"`, { stdio: 'pipe' }); }
  catch (e) { fail(`syntax error in ${f}: ${String(e.stderr || e).slice(0, 200)}`); }
}

report();

function report() {
  if (fails.length) {
    console.error('✗ registry check FAILED:');
    fails.forEach(m => console.error('  - ' + m));
    process.exit(1);
  }
  console.log(`✓ registry check passed — ${REGISTRY.length} modules, all tables have CREATE TABLE, both consumers wired.`);
}
