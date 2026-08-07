#!/usr/bin/env node
/* ============================================================================
 * build-wi-pdf.mjs — render docs/WI-QA-modules.html to a printable PDF.
 *
 * The WI set is a document an auditor asks for on paper. The HTML is the
 * source; this produces the artefact that gets printed, signed and filed, with
 * page numbers in the footer and the draft marker on every page.
 *
 * Thai needs a Thai font. The page asks for Noto Serif Thai (the app's family)
 * and a machine without it silently falls back to something else, which is the
 * kind of difference nobody notices until the printed copy looks wrong. So the
 * font is fetched and installed if it is missing, and the run fails loudly if
 * it still cannot be resolved.
 *
 * Usage:  node scripts/build-wi-pdf.mjs
 * ==========================================================================*/
import { execSync } from 'child_process';
import http from 'http';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Playwright is not a dependency of this project — it is whatever the machine
// has. Try the bare specifier first so a normal `npm i -D playwright` works,
// then fall back to a global install.
async function loadChromium() {
  for (const spec of ['playwright', '/opt/node22/lib/node_modules/playwright/index.mjs']) {
    try { return (await import(spec)).chromium; } catch { /* next */ }
  }
  throw new Error('playwright not found — install it (npm i -D playwright) or provide a global one');
}

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const SRC  = 'docs/WI-QA-modules.html';
const OUT  = path.join(ROOT, 'docs/WI-QA-modules.pdf');
const FONT_DIR = '/usr/share/fonts/truetype/nsthai';
const CSS_URL = 'https://fonts.googleapis.com/css2?family=Noto+Serif+Thai:wght@400;500;600;700&display=swap';

async function ensureFont() {
  let have = '';
  try { have = execSync('fc-list', { encoding: 'utf8' }); } catch { return; }   // no fontconfig: trust the system
  if (/Noto Serif Thai/i.test(have)) return;
  console.log('· Noto Serif Thai not installed — fetching');
  const css = await (await fetch(CSS_URL, { headers: { 'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64)' } })).text();
  fs.mkdirSync(FONT_DIR, { recursive: true });
  for (const block of css.split('@font-face')) {
    const w = block.match(/font-weight:\s*(\d+)/);
    const u = block.match(/url\((https:\/\/[^)]+)\)/);
    if (!w || !u) continue;
    const buf = Buffer.from(await (await fetch(u[1])).arrayBuffer());
    fs.writeFileSync(path.join(FONT_DIR, `NotoSerifThai-${w[1]}.ttf`), buf);
  }
  execSync('fc-cache -f', { stdio: 'ignore' });
  if (!/Noto Serif Thai/i.test(execSync('fc-list', { encoding: 'utf8' })))
    throw new Error('Noto Serif Thai still unavailable after install — refusing to render Thai in a fallback font');
}

const server = http.createServer((req, res) => {
  const p = path.join(ROOT, decodeURIComponent(req.url.split('?')[0]));
  if (p.startsWith(ROOT) && fs.existsSync(p) && fs.statSync(p).isFile()) {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    fs.createReadStream(p).pipe(res);
  } else { res.writeHead(404); res.end('not found'); }
});

await ensureFont();
await new Promise(r => server.listen(0, r));
const port = server.address().port;

const chromium = await loadChromium();
// The sandbox ships Chromium at a fixed path with PLAYWRIGHT_BROWSERS_PATH set;
// elsewhere Playwright resolves its own. Only pass the path if it is there.
const exe = '/opt/pw-browsers/chromium';
const browser = await chromium.launch(fs.existsSync(exe) ? { executablePath: exe } : {});
const page = await browser.newPage();
// The family is installed locally, so the Google Fonts request is dead weight —
// stub it rather than let a slow or blocked CDN stall the render.
await page.route('**/*', r => /^https:/.test(r.request().url())
  ? r.fulfill({ status: 200, contentType: 'text/css', body: '' })
  : r.continue());
await page.goto(`http://127.0.0.1:${port}/${SRC}`, { waitUntil: 'networkidle' });
await page.emulateMedia({ media: 'print' });

const footer = `<div style="font-family:'Noto Serif Thai',serif;font-size:8px;color:#5A6478;width:100%;padding:0 14mm;display:flex;justify-content:space-between">
<span>วิธีปฏิบัติงาน QA/QC รายโมดูล · ฉบับร่าง ยังไม่ผ่านการควบคุมเอกสาร</span>
<span>หน้า <span class="pageNumber"></span> / <span class="totalPages"></span></span></div>`;

await page.pdf({
  path: OUT, format: 'A4', printBackground: true,
  displayHeaderFooter: true, headerTemplate: '<div></div>', footerTemplate: footer,
  margin: { top: '14mm', bottom: '16mm', left: '0mm', right: '0mm' }
});
await browser.close();
server.close();

const kb = Math.round(fs.statSync(OUT).size / 1024);
console.log(`✓ ${path.relative(ROOT, OUT)} — ${kb} KB`);
