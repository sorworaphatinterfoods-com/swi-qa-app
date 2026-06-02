/**
 * SWI Foods — Smart QA Department System
 * Cloudflare Worker (Hono) backend with D1 + KV
 * 
 * Bindings (configure in wrangler.toml):
 *   - DB         : D1 Database (qa-factory-db)
 *   - CACHE      : KV namespace (optional caching)
 *   - SESSION    : KV namespace for auth sessions
 *   - JWT_SECRET : env var
 * 
 * Endpoints (REST):
 *   GET    /api/health
 *   POST   /api/auth/login
 *   POST   /api/auth/logout
 *   GET    /api/me
 *   GET    /api/:table                     ← list (supports ?q=&status=&limit=&offset=)
 *   GET    /api/:table/:id                 ← detail
 *   POST   /api/:table                     ← create
 *   PUT    /api/:table/:id                 ← update
 *   DELETE /api/:table/:id                 ← delete
 *   GET    /api/dashboard/kpi              ← computed KPI metrics
 *   GET    /api/dashboard/trends?days=30   ← trend data
 *   GET    /api/reports/summary?from=&to=  ← per-module counts in a date range
 *   GET    /api/reports/:table?from=&to=   ← rows for one module in a date range
 *   POST   /api/sync                       ← bulk sync from client (full snapshot)
 *   GET    /api/export                     ← full DB export as JSON
 *   POST   /api/contact                    ← contact form submission
 * 
 * Frontend can set API_BASE_URL in operations.html to enable server sync.
 */

import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';

const app = new Hono();

app.use('*', logger());
app.use('*', cors({
  origin: (origin) => {
    // Allow: known domains, any localhost, file:// (null), and any *.sorworaphatinterfoods.net/.workers.dev/.pages.dev
    if (!origin) return '*';  // file:// or curl
    if (/^https?:\/\/(www\.)?sorworaphatinterfoods\.(net|com)$/.test(origin)) return origin;
    if (/^https?:\/\/localhost(:\d+)?$/.test(origin)) return origin;
    if (/^http:\/\/127\.0\.0\.1(:\d+)?$/.test(origin)) return origin;
    if (/\.workers\.dev$/.test(new URL(origin).hostname)) return origin;
    if (/\.pages\.dev$/.test(new URL(origin).hostname)) return origin;
    return origin; // permissive — this is an internal QA tool, not a public API
  },
  allowMethods: ['GET','POST','PUT','DELETE','OPTIONS'],
  allowHeaders: ['Content-Type','Authorization'],
  credentials: false  // using Bearer tokens, not cookies
}));

/* ---------------- WHITELISTED TABLES ---------------- */
const TABLES = {
  // Master data (12 tables)
  suppliers:             { idPrefix: 'SP',  search: ['name','contact','email','materialCode'] },
  materials:             { idPrefix: 'MT',  search: ['name','subCategory','supplier'] },
  ingredients:           { idPrefix: 'PD',  search: ['name','category'] },
  packaging:             { idPrefix: 'PK',  search: ['name'] },
  chemicals:             { idPrefix: 'CM',  search: ['name'] },
  finished_goods:        { idPrefix: 'FG',  search: ['name','type'] },
  processes:             { idPrefix: 'PC',  search: ['name','description','area'] },
  parameters:            { idPrefix: 'PR',  search: ['name','description','category','spec'] },
  equipment:             { idPrefix: 'EQ',  search: ['name','type','usage'] },
  ccps:                  { idPrefix: 'CCP', search: ['name','processId','criticalLimit'] },
  process_parameter_map: { idPrefix: 'MAP', search: ['processName','parameterId'] },
  machines:              { idPrefix: 'MC',  search: ['name','type','processId'] },
  // Transactional (10 tables)
  rm_inspections:        { idPrefix: 'RMI', search: ['supplier','material','lotNo','inspector'] },
  fg_inspections:        { idPrefix: 'FGI', search: ['product','batch','inspector'] },
  pkg_inspections:       { idPrefix: 'PKI', search: ['material','inspector'] },
  inprocess_inspections: { idPrefix: 'IPI', search: ['productName','batch','line','inspector'], jsonCols: ['processes'] },
  transport_inspections: { idPrefix: 'TS',  search: ['plateNo','driver','destination','product','invoiceNo','inspector'] },
  haccp_records:         { idPrefix: 'HC',  search: ['ccpName','operator'] },
  nc_capa:               { idPrefix: 'NC',  search: ['description','owner','type'] },
  environmental:         { idPrefix: 'ENV', search: ['area','operator','parameter'] },
  training:              { idPrefix: 'TR',  search: ['title','trainer','category'] },
  traceability:          { idPrefix: 'TRC', search: ['batch','product','customer'] },
  complaints:            { idPrefix: 'CC',  search: ['customer','subject','product'] }
};

// Helper: introspect a table's real columns (cached) so we never try to INSERT
// a key that has no matching column. Uses the pragma_table_info() table-valued
// function (works via D1 prepared statements; the bare `PRAGMA table_info`
// statement form is not reliably supported on D1). Returns null on any failure
// so callers fall back to inserting all keys instead of throwing the whole request.
const _colCache = {};
async function tableColumns(db, table) {
  if (_colCache[table]) return _colCache[table];
  try {
    const r = await db.prepare(`SELECT name FROM pragma_table_info('${table}')`).all();
    const names = (r.results || []).map(x => x.name).filter(Boolean);
    if (names.length) { const cols = new Set(names); _colCache[table] = cols; return cols; }
  } catch (e) { /* fall through */ }
  return null; // unknown → caller inserts all keys (legacy behaviour)
}

// Helper: re-hydrate JSON columns (e.g. processes[]) when reading rows back out
function deserializeRow(t, row) {
  if (!row) return row;
  const jc = TABLES[t]?.jsonCols;
  if (jc) {
    for (const col of jc) {
      if (typeof row[col] === 'string' && row[col]) {
        try { row[col] = JSON.parse(row[col]); } catch { /* leave as-is */ }
      }
    }
  }
  return row;
}

/* ---------------- HEALTH ---------------- */
app.get('/api/health', c => c.json({ ok: true, ts: new Date().toISOString(), service: 'swi-qa-api' }));

/* ---------------- AUTH ---------------- */
app.post('/api/auth/login', async c => {
  const { username, password } = await c.req.json();
  if (!username || !password) return c.json({ error: 'missing credentials' }, 400);

  const user = await c.env.DB.prepare(
    'SELECT username, name, role, dept FROM users WHERE username = ? AND password_hash = ?'
  ).bind(username, await sha256(password + (c.env.JWT_SECRET || 'swi-default-salt'))).first();

  if (!user) return c.json({ error: 'invalid credentials' }, 401);

  const token = crypto.randomUUID();
  await c.env.SESSION.put(`session:${token}`, JSON.stringify(user), { expirationTtl: 86400 * 7 });
  return c.json({ token, user });
});

app.post('/api/auth/logout', async c => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '');
  if (token) await c.env.SESSION.delete(`session:${token}`);
  return c.json({ ok: true });
});

app.get('/api/me', async c => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return c.json({ error: 'unauthorized' }, 401);
  const data = await c.env.SESSION.get(`session:${token}`);
  if (!data) return c.json({ error: 'session expired' }, 401);
  return c.json({ user: JSON.parse(data) });
});

/* ---------------- AUTH MIDDLEWARE (optional) ---------------- */
async function requireAuth(c, next) {
  const token = c.req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return c.json({ error: 'unauthorized' }, 401);
  const data = await c.env.SESSION.get(`session:${token}`);
  if (!data) return c.json({ error: 'session expired' }, 401);
  c.set('user', JSON.parse(data));
  await next();
}
// Enable to lock down all writes:
// app.use('/api/:table/*', requireAuth);

// Reserved sub-paths under /api that are NOT tables (handled by specific routes).
// Guards the generic /api/:table handlers from swallowing these.
const RESERVED = new Set(['sync', 'export', 'contact', 'dashboard', 'auth', 'me', 'health', 'reports']);

// Date column used for range-filtering each transactional table.
const DATE_COL = {
  rm_inspections: 'date', fg_inspections: 'date', pkg_inspections: 'date',
  inprocess_inspections: 'date', transport_inspections: 'date',
  haccp_records: 'timestamp', nc_capa: 'date', environmental: 'date',
  training: 'date', traceability: 'date', complaints: 'date'
};
function isTable(t) { return !RESERVED.has(t) && !!TABLES[t]; }

/* ---------------- REPORTS (date-range) ---------------- */
// GET /api/reports/summary?from=YYYY-MM-DD&to=YYYY-MM-DD
// Returns per-module counts within the date range (inclusive) for printable reports.
app.get('/api/reports/summary', async c => {
  const from = (c.req.query('from') || '0000-01-01').slice(0, 10);
  const to   = (c.req.query('to')   || '9999-12-31').slice(0, 10);
  const db = c.env.DB;
  const counts = {};
  for (const [tbl, dcol] of Object.entries(DATE_COL)) {
    try {
      const r = await db.prepare(
        `SELECT COUNT(*) as n FROM ${tbl} WHERE substr(${dcol},1,10) BETWEEN ? AND ?`
      ).bind(from, to).first();
      counts[tbl] = r?.n || 0;
    } catch (e) { counts[tbl] = null; }
  }
  return c.json({ from, to, counts, ts: new Date().toISOString() });
});

// GET /api/reports/:table?from=&to=  — full rows for one module within a date range
app.get('/api/reports/:table', async c => {
  const t = c.req.param('table');
  if (!isTable(t) || !DATE_COL[t]) return c.json({ error: 'unknown or non-dated table' }, 404);
  const from = (c.req.query('from') || '0000-01-01').slice(0, 10);
  const to   = (c.req.query('to')   || '9999-12-31').slice(0, 10);
  const dcol = DATE_COL[t];
  try {
    const r = await c.env.DB.prepare(
      `SELECT * FROM ${t} WHERE substr(${dcol},1,10) BETWEEN ? AND ? ORDER BY ${dcol} DESC`
    ).bind(from, to).all();
    const rows = (r.results || []).map(row => deserializeRow(t, row));
    return c.json({ table: t, from, to, count: rows.length, data: rows });
  } catch (e) {
    return c.json({ error: e.message }, 500);
  }
});

/* ---------------- SYNC (full snapshot from client) ----------------
   IMPORTANT: must be registered BEFORE the generic /api/:table routes,
   otherwise POST /api/sync is captured by /api/:table (table='sync' is a
   reserved name) and returns 404 — which silently broke all client sync. */
app.post('/api/sync', async c => {
  const data = await c.req.json();
  const keyMap = {
    suppliers: 'suppliers', materials: 'materials', ingredients: 'ingredients',
    packaging: 'packaging', chemicals: 'chemicals', finishedGoods: 'finished_goods',
    processes: 'processes', parameters: 'parameters', equipment: 'equipment',
    ccps: 'ccps', processParamMap: 'process_parameter_map', machines: 'machines',
    rmInspections: 'rm_inspections', fgInspections: 'fg_inspections',
    pkgInspections: 'pkg_inspections', inprocessInspections: 'inprocess_inspections',
    transportInspections: 'transport_inspections',
    haccpRecords: 'haccp_records', ncCapa: 'nc_capa',
    environmental: 'environmental', training: 'training', traceability: 'traceability',
    complaints: 'complaints'
  };
  const summary = {};
  const errors = [];
  for (const [clientKey, dbTable] of Object.entries(keyMap)) {
    const items = data[clientKey] || [];
    if (!items.length) { summary[dbTable] = 0; continue; }
    // upsert each row — only bind keys that map to a real column, otherwise the
    // whole INSERT throws and the row silently never reaches D1.
    let allCols = null;
    try { allCols = await tableColumns(c.env.DB, dbTable); } catch { allCols = null; }
    let n = 0;
    for (const item of items) {
      try {
        const cols = Object.keys(item).filter(k => k !== 'modified' && (!allCols || allCols.has(k)));
        if (!cols.includes('id')) { errors.push(`${dbTable}: row missing id`); continue; }
        const placeholders = cols.map(() => '?').join(', ');
        const update = cols.filter(k => k !== 'id').map(k => `${k} = excluded.${k}`).join(', ');
        await c.env.DB.prepare(
          `INSERT INTO ${dbTable} (${cols.join(', ')}) VALUES (${placeholders})
           ON CONFLICT(id) DO UPDATE SET ${update}`
        ).bind(...cols.map(k => normalize(item[k]))).run();
        n++;
      } catch (e) {
        console.error(`sync ${dbTable} ${item.id}:`, e.message);
        errors.push(`${dbTable}/${item.id}: ${e.message}`);
      }
    }
    summary[dbTable] = n;
  }
  return c.json({
    ok: errors.length === 0,
    synced: summary,
    errorCount: errors.length,
    errors: errors.slice(0, 20),
    ts: new Date().toISOString()
  });
});

/* ---------------- EXPORT ---------------- */
app.get('/api/export', async c => {
  const out = {};
  for (const t of Object.keys(TABLES)) {
    const r = await c.env.DB.prepare(`SELECT * FROM ${t}`).all();
    out[t] = r.results;
  }
  out.meta = { exported: new Date().toISOString(), version: '1.0.0' };
  return c.json(out);
});

/* ---------------- CONTACT FORM ---------------- */
app.post('/api/contact', async c => {
  const body = await c.req.json();
  const required = ['company','name','position','phone','email'];
  for (const k of required) if (!body[k]) return c.json({ error: `missing ${k}` }, 400);
  body.id = 'CT' + Date.now();
  body.created = new Date().toISOString();
  // Only insert keys that exist as real columns (schema may not have company/position).
  const allCols = await tableColumns(c.env.DB, 'contact_submissions');
  const cols = allCols ? Object.keys(body).filter(k => allCols.has(k)) : Object.keys(body);
  const placeholders = cols.map(() => '?').join(', ');
  try {
    await c.env.DB.prepare(
      `INSERT INTO contact_submissions (${cols.join(', ')}) VALUES (${placeholders})`
    ).bind(...cols.map(k => normalize(body[k]))).run();
    return c.json({ ok: true, id: body.id });
  } catch (e) {
    return c.json({ error: e.message }, 500);
  }
});

/* ---------------- GENERIC LIST ---------------- */
app.get('/api/:table', async c => {
  const t = c.req.param('table');
  if (!isTable(t)) return c.json({ error: 'unknown table' }, 404);
  const url = new URL(c.req.url);
  const q = url.searchParams.get('q');
  const status = url.searchParams.get('status');
  const limit = Math.min(parseInt(url.searchParams.get('limit') || '100'), 500);
  const offset = parseInt(url.searchParams.get('offset') || '0');

  let sql = `SELECT * FROM ${t}`;
  const where = [];
  const params = [];
  if (q && TABLES[t].search.length) {
    where.push('(' + TABLES[t].search.map(c => `${c} LIKE ?`).join(' OR ') + ')');
    TABLES[t].search.forEach(() => params.push(`%${q}%`));
  }
  if (status) { where.push('status = ?'); params.push(status); }
  if (where.length) sql += ' WHERE ' + where.join(' AND ');
  sql += ` ORDER BY id DESC LIMIT ${limit} OFFSET ${offset}`;

  try {
    const result = await c.env.DB.prepare(sql).bind(...params.map(String)).all();
    const rows = (result.results || []).map(r => deserializeRow(t, r));
    return c.json({ data: rows, count: rows.length });
  } catch (e) {
    return c.json({ error: e.message, sql }, 500);
  }
});

/* ---------------- GENERIC DETAIL ---------------- */
app.get('/api/:table/:id', async c => {
  const t = c.req.param('table');
  if (!isTable(t)) return c.json({ error: 'unknown table' }, 404);
  const row = await c.env.DB.prepare(`SELECT * FROM ${t} WHERE id = ?`).bind(c.req.param('id')).first();
  if (!row) return c.json({ error: 'not found' }, 404);
  return c.json(deserializeRow(t, row));
});

/* ---------------- GENERIC CREATE ---------------- */
app.post('/api/:table', async c => {
  const t = c.req.param('table');
  if (!isTable(t)) return c.json({ error: 'unknown table' }, 404);
  const body = await c.req.json();
  const id = body.id || await nextId(c.env.DB, t, TABLES[t].idPrefix);
  body.id = id;
  body.created = body.created || new Date().toISOString();

  const allCols = await tableColumns(c.env.DB, t);
  const cols = allCols ? Object.keys(body).filter(k => allCols.has(k)) : Object.keys(body);
  const dropped = allCols ? Object.keys(body).filter(k => !allCols.has(k)) : [];
  const placeholders = cols.map(() => '?').join(', ');
  const sql = `INSERT INTO ${t} (${cols.join(', ')}) VALUES (${placeholders})`;
  try {
    await c.env.DB.prepare(sql).bind(...cols.map(k => normalize(body[k]))).run();
    // auto-NC trigger
    await maybeAutoNC(c.env.DB, t, body);
    return c.json({ id, ok: true, dropped: dropped.length ? dropped : undefined });
  } catch (e) {
    return c.json({ error: e.message, sql }, 500);
  }
});

/* ---------------- GENERIC UPDATE ---------------- */
app.put('/api/:table/:id', async c => {
  const t = c.req.param('table');
  if (!isTable(t)) return c.json({ error: 'unknown table' }, 404);
  const id = c.req.param('id');
  const body = await c.req.json();
  body.modified = new Date().toISOString();
  delete body.id;
  const allCols = await tableColumns(c.env.DB, t);
  const cols = allCols ? Object.keys(body).filter(k => allCols.has(k)) : Object.keys(body);
  if (!cols.length) return c.json({ error: 'no valid columns to update' }, 400);
  const sql = `UPDATE ${t} SET ${cols.map(k => `${k} = ?`).join(', ')} WHERE id = ?`;
  try {
    await c.env.DB.prepare(sql).bind(...cols.map(k => normalize(body[k])), id).run();
    return c.json({ id, ok: true });
  } catch (e) {
    return c.json({ error: e.message }, 500);
  }
});

/* ---------------- GENERIC DELETE ---------------- */
app.delete('/api/:table/:id', async c => {
  const t = c.req.param('table');
  if (!isTable(t)) return c.json({ error: 'unknown table' }, 404);
  try {
    await c.env.DB.prepare(`DELETE FROM ${t} WHERE id = ?`).bind(c.req.param('id')).run();
    return c.json({ ok: true });
  } catch (e) {
    return c.json({ error: e.message }, 500);
  }
});

/* ---------------- DASHBOARD KPI ---------------- */
app.get('/api/dashboard/kpi', async c => {
  const db = c.env.DB;
  const q = async (s, ...p) => (await db.prepare(s).bind(...p).first()) || {};

  const rm = await q(`SELECT COUNT(*) as total, SUM(CASE WHEN result='PASS' THEN 1 ELSE 0 END) as passed FROM rm_inspections`);
  const ccp = await q(`SELECT COUNT(*) as total, SUM(CASE WHEN status='IN_LIMIT' THEN 1 ELSE 0 END) as inLimit FROM haccp_records`);
  const nc = await q(`SELECT
    COUNT(*) as total,
    SUM(CASE WHEN status='Open' THEN 1 ELSE 0 END) as open,
    SUM(CASE WHEN status='Closed' THEN 1 ELSE 0 END) as closed FROM nc_capa`);
  const sup = await q(`SELECT COUNT(*) as total, AVG(score) as avgScore, SUM(CASE WHEN status='Approved' THEN 1 ELSE 0 END) as approved FROM suppliers`);
  const cc = await q(`SELECT COUNT(*) as total, SUM(CASE WHEN status!='Closed' THEN 1 ELSE 0 END) as open FROM complaints`);

  const pct = (a, b) => b > 0 ? +((a / b) * 100).toFixed(1) : 100;
  return c.json({
    receiving_compliance: pct(rm.passed, rm.total),
    ccp_compliance: pct(ccp.inLimit, ccp.total),
    capa_closed_rate: pct(nc.closed, nc.total),
    open_nc: nc.open || 0,
    supplier_avg_score: +(sup.avgScore || 0).toFixed(1),
    supplier_approved: sup.approved || 0,
    supplier_total: sup.total || 0,
    open_complaints: cc.open || 0,
    ts: new Date().toISOString()
  });
});

/* ---------------- DASHBOARD TRENDS ---------------- */
app.get('/api/dashboard/trends', async c => {
  const days = parseInt(c.req.query('days') || '30');
  const since = new Date(Date.now() - days * 86400000).toISOString().slice(0,10);

  const rm = await c.env.DB.prepare(
    `SELECT substr(date,1,10) as day, COUNT(*) as n,
     SUM(CASE WHEN result='PASS' THEN 1 ELSE 0 END) as pass
     FROM rm_inspections WHERE substr(date,1,10) >= ? GROUP BY day ORDER BY day`
  ).bind(since).all();

  const ccp = await c.env.DB.prepare(
    `SELECT substr(timestamp,1,10) as day, COUNT(*) as n,
     SUM(CASE WHEN status='OUT_OF_LIMIT' THEN 1 ELSE 0 END) as deviations
     FROM haccp_records WHERE substr(timestamp,1,10) >= ? GROUP BY day ORDER BY day`
  ).bind(since).all();

  const nc = await c.env.DB.prepare(
    `SELECT substr(date,1,10) as day, COUNT(*) as n FROM nc_capa WHERE substr(date,1,10) >= ? GROUP BY day ORDER BY day`
  ).bind(since).all();

  return c.json({
    rm_inspections: rm.results,
    haccp_records: ccp.results,
    nc_capa: nc.results,
    since
  });
});

/* ---------------- HELPERS ---------------- */
async function nextId(db, table, prefix) {
  const r = await db.prepare(`SELECT id FROM ${table} ORDER BY id DESC LIMIT 1`).first();
  let n = 0;
  if (r?.id) {
    const m = String(r.id).match(/(\d+)$/);
    if (m) n = parseInt(m[1]);
  }
  return prefix + String(n + 1).padStart(4, '0');
}
function normalize(v) {
  if (v === undefined || v === null) return null;
  if (typeof v === 'boolean') return v ? 1 : 0;
  if (typeof v === 'object') return JSON.stringify(v);
  return v;
}
async function sha256(s) {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(s));
  return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2,'0')).join('');
}
async function maybeAutoNC(db, table, rec) {
  // Auto-create NC for failures across modules
  let desc, type, severity;
  if (table === 'rm_inspections' && rec.result === 'FAIL') {
    desc = `วัตถุดิบไม่ผ่านการตรวจรับ — ${rec.material} (Lot ${rec.lotNo || rec.lot_no})`;
    type = 'Raw Material'; severity = 'Medium';
  } else if (table === 'fg_inspections' && rec.result === 'FAIL') {
    desc = `FG ไม่ผ่านการตรวจ — ${rec.product} (Batch ${rec.batch})`;
    type = 'Finished Goods'; severity = 'High';
  } else if (table === 'haccp_records' && rec.status === 'OUT_OF_LIMIT') {
    desc = `CCP เกินขีดจำกัด — ${rec.ccpName || rec.ccp_name} (วัดได้ ${rec.measuredValue || rec.measured_value}, CL ${rec.criticalLimit || rec.critical_limit})`;
    type = 'CCP Deviation'; severity = 'Critical';
  } else if (table === 'inprocess_inspections' && rec.overallResult === 'FAIL') {
    // processes may arrive as object (POST body) or JSON string (already serialized)
    let procs = rec.processes;
    if (typeof procs === 'string') { try { procs = JSON.parse(procs); } catch { procs = []; } }
    const fails = [];
    let hasCCP = false;
    (procs || []).forEach(p => {
      if (p.isCCP) hasCCP = true;
      (p.parameters || []).forEach(pr =>
        (pr.rounds || []).forEach(r => {
          if (evalSpecWorker(pr.spec, r.value) === 'FAIL')
            fails.push(`${p.processName}/${pr.parameterName}=${r.value}`);
        })
      );
    });
    desc = `พบค่าไม่ผ่านเกณฑ์ระหว่างผลิต (${rec.id}): ${fails.join('; ')}`;
    type = 'In-Process'; severity = hasCCP ? 'High' : 'Medium';
  } else if (table === 'transport_inspections' && rec.result === 'FAIL') {
    const issues = [];
    if (!rec.chkClean) issues.push('กระบะไม่สะอาด');
    if (!rec.chkPest) issues.push('พบร่องรอยสัตว์พาหะ');
    if (!rec.chkHazard) issues.push('พบวัตถุอันตราย');
    if (!rec.chkRust) issues.push('ตู้มีสนิม');
    if (!rec.chkStack) issues.push('จัดเรียงเสี่ยงโค่นล้ม');
    if (rec.tempCold != null && rec.tempCold !== '' && Number(rec.tempCold) > 4 && rec.tempMethod !== 'na') issues.push(`อุณหภูมิเกิน (${rec.tempCold}°C)`);
    if (!rec.docRoNo) issues.push('ขาดเอกสาร ร.น.');
    if (!rec.docRo3) issues.push('ขาดเอกสาร ร.3');
    desc = `รถขนส่งไม่ผ่านการตรวจ — ทะเบียน ${rec.plateNo} (${rec.destination})${issues.length?': '+issues.join(', '):''}`;
    type = 'Transportation'; severity = 'High';
  } else return;

  const ncId = await nextId(db, 'nc_capa', 'NC');
  await db.prepare(
    `INSERT INTO nc_capa (id, date, type, description, severity, status, source, owner, created)
     VALUES (?, ?, ?, ?, ?, 'Open', ?, ?, ?)`
  ).bind(ncId, rec.date || rec.timestamp || new Date().toISOString(), type, desc, severity, rec.id, rec.inspector || null, new Date().toISOString()).run();
}

/* Spec evaluator — mirror of frontend evalSpec(), used for server-side auto-NC */
function evalSpecWorker(spec, value) {
  if (value === '' || value === null || value === undefined) return 'NA';
  const s = String(spec || '').trim();
  if (!s || s === '-') return 'NA';
  const norm = s.replace(/[()]/g, '').replace(/[–—]/g, '-');
  const num = parseFloat(String(value).replace(/[^0-9.\-]/g, ''));
  let m;
  if ((m = norm.match(/^[≥>]=?\s*(-?\d+\.?\d*)/))) return isNaN(num) ? 'NA' : (num >= parseFloat(m[1]) ? 'PASS' : 'FAIL');
  if ((m = norm.match(/^[≤<]=?\s*(-?\d+\.?\d*)/))) return isNaN(num) ? 'NA' : (num <= parseFloat(m[1]) ? 'PASS' : 'FAIL');
  if ((m = norm.match(/(-?\d+\.?\d*)\s*-\s*(-?\d+\.?\d*)/))) {
    if (isNaN(num)) return 'NA';
    const lo = Math.min(parseFloat(m[1]), parseFloat(m[2])), hi = Math.max(parseFloat(m[1]), parseFloat(m[2]));
    return (num >= lo && num <= hi) ? 'PASS' : 'FAIL';
  }
  if (/ø/.test(s)) {
    const v = String(value).toLowerCase().trim();
    if (/ผ่าน|pass|ok|ไม่พบ|none|ปกติ/.test(v)) return 'PASS';
    if (/ไม่ผ่าน|fail|พบ|detect|reject/.test(v)) return 'FAIL';
    return 'NA';
  }
  if ((m = norm.match(/^(-?\d+\.?\d*)$/))) return isNaN(num) ? 'NA' : (num === parseFloat(m[1]) ? 'PASS' : 'FAIL');
  return 'NA';
}

/* ---------------- ROOT ---------------- */
app.get('/', c => c.json({
  service: 'SWI Foods — Smart QA Department System API',
  version: '1.0.0',
  endpoints: Object.keys(TABLES).map(t => `/api/${t}`),
  docs: 'See README.md'
}));

app.notFound(c => c.json({ error: 'not found' }, 404));
app.onError((err, c) => { console.error(err); return c.json({ error: err.message }, 500); });

export default app;
