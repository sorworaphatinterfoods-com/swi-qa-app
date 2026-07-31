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

// 2b) every form field has a column -----------------------------------------
// A field with no column is dropped by /api/sync without erroring, and because
// pullFromServer merges the server row back over local state the value does not
// survive a refresh either. That is how ipqc_checks.skewerMethod was lost. The
// CREATE TABLE check above cannot see it: the table existed, the column did not.
const declared = {};           // table -> Set(column)
{
  // strip -- comments so a commented-out "-- foo TEXT" is not read as a column
  const clean = sql.replace(/--[^\n]*/g, '');
  const re = /CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?["'`]?([A-Za-z0-9_]+)["'`]?\s*\(/gi;
  let m;
  while ((m = re.exec(clean))) {
    const t = m[1];
    let i = re.lastIndex, depth = 1, body = '';
    while (i < clean.length && depth > 0) {
      const c = clean[i];
      if (c === '(') depth++;
      else if (c === ')') { depth--; if (!depth) break; }
      body += c; i++;
    }
    const set = declared[t] = declared[t] || new Set();
    let d = 0, cur = '';
    const parts = [];
    for (const c of body) {
      if (c === '(') d++;
      if (c === ')') d--;
      if (c === ',' && d === 0) { parts.push(cur); cur = ''; } else cur += c;
    }
    parts.push(cur);
    for (const p of parts) {
      const s = p.trim();
      if (!s || /^(PRIMARY|FOREIGN|UNIQUE|CHECK|CONSTRAINT)\b/i.test(s)) continue;
      const cm = s.match(/^["'`]?([A-Za-z0-9_]+)["'`]?/);
      if (cm) set.add(cm[1]);
    }
  }
  for (const mm of sql.matchAll(/ALTER\s+TABLE\s+["'`]?([A-Za-z0-9_]+)["'`]?\s+ADD\s+COLUMN\s+["'`]?([A-Za-z0-9_]+)["'`]?/gi)) {
    (declared[mm[1]] = declared[mm[1]] || new Set()).add(mm[2]);
  }
}
// Remove `prop:[ … ]` regions (balanced) from a source slice.
function stripNested(src, props) {
  let out = src;
  for (const prop of props) {
    for (;;) {
      const at = out.search(new RegExp(`\\b${prop}\\s*:\\s*\\[`));
      if (at < 0) break;
      let i = out.indexOf('[', at), depth = 0, end = -1;
      for (; i < out.length; i++) {
        const c = out[i];
        if (c === '[') depth++;
        else if (c === ']') { depth--; if (!depth) { end = i; break; } }
      }
      if (end < 0) break;
      out = out.slice(0, at) + out.slice(end + 1);
    }
  }
  return out;
}

// SCHEMA lives inside operations.html; pull each module's field keys out of the
// `key: { … fields: [ … ] }` block textually rather than executing the page.
{
  const html = read('operations.html');
  // Scope to the SCHEMA object. `ipqcChecks: {` also appears in PAGES and elsewhere,
  // and anchoring on the first match silently pointed the scan at the wrong object —
  // which is why an earlier version of this check passed while skewerMethod was absent.
  const schemaAt = html.search(/^const SCHEMA = \{/m);
  if (schemaAt < 0) fail('could not locate `const SCHEMA = {` in operations.html');
  let si = html.indexOf('{', schemaAt), sd = 0, schemaEnd = html.length;
  for (let i = si; i < html.length; i++) {
    const c = html[i];
    if (c === '{') sd++;
    else if (c === '}') { sd--; if (!sd) { schemaEnd = i; break; } }
  }
  const schemaSrc = html.slice(si, schemaEnd);
  let checked = 0;
  for (const r of REGISTRY) {
    const rel = schemaSrc.search(new RegExp(`\\n  ${r.key}:\\s*\\{`));
    if (rel < 0) continue;                         // module has no SCHEMA entry
    const start = rel;
    const fIdx = schemaSrc.indexOf('fields:', start);
    if (fIdx < 0) continue;                        // no fields block for this module
    let i = schemaSrc.indexOf('[', fIdx), depth = 0, end = i;
    for (; i < schemaSrc.length; i++) {
      const c = schemaSrc[i];
      if (c === '[') depth++;
      else if (c === ']') { depth--; if (!depth) { end = i; break; } }
    }
    // `sub:` (list rows) and `idCols:` (grid identity columns) describe keys INSIDE
    // a JSON column, not columns of their own — drop those regions before matching.
    const block = stripNested(schemaSrc.slice(fIdx, end), ['sub', 'idCols']);
    const have = declared[r.table];
    if (!have) continue;                           // CREATE TABLE check reports this
    checked++;
    for (const km of block.matchAll(/\bk:\s*'([A-Za-z0-9_]+)'/g)) {
      if (!have.has(km[1]))
        fail(`${r.table} (key ${r.key}) form field "${km[1]}" has no column in schema.sql/migrations`);
    }
  }
  // A silent zero here would mean the scan matched nothing and proved nothing.
  if (checked < 40) fail(`field/column check only scanned ${checked} modules — extraction is broken`);
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
