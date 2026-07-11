# Smart QA Factory System — สรุประบบ (System Overview)

ระบบบริหารคุณภาพและความปลอดภัยอาหาร (QA/QC) สำหรับโรงงานแปรรูปเนื้อสัตว์และอาหารแช่แข็ง
บริษัท ศ.วรภัทร อินเตอร์ ฟู้ดส์ จำกัด

> เอกสารนี้เป็นภาพรวมระดับสถาปัตยกรรมและการใช้งาน สำหรับทีม QA, ผู้ดูแลระบบ และการเตรียมตรวจประเมิน (Audit Readiness)

---

## 1. ภาพรวม

- **ระบบเดียวครอบคลุมทั้ง HACCP + GHPs + QA Operations + Traceability + Management Review**
- ใช้งานได้ **offline** บนแท็บเล็ต/มือถือหน้างาน (PWA) แล้ว sync ขึ้น cloud อัตโนมัติ
- ภาษาไทยเป็นหลัก + คำศัพท์เทคนิคภาษาอังกฤษ
- **57 โมดูลที่ sync กับฐานข้อมูล** + Dashboard เฉพาะทาง 9 หน้า
- สอดคล้อง: GHPs, HACCP (Codex), ISO 22000 / FSSC 22000, GMP กรมปศุสัตว์, ข้อกำหนด อย.

## 2. สถาปัตยกรรม (Architecture)

| ชั้น | เทคโนโลยี |
|---|---|
| Frontend | `operations.html` — Single-Page App (vanilla JS, Tailwind), mobile-first, offline PWA (`sw.js`) |
| Backend API | `worker.js` — Cloudflare Worker (Hono), REST `/api/*` |
| Database | Cloudflare **D1** (`qa-factory-db`, SQLite) — normalized, referential |
| File Storage | Cloudflare **R2** (`swi-qa-coa`) — รูป COA / หลักฐาน |
| Deploy | Cloudflare Pages (หน้าเว็บ) + GitHub Action `deploy-worker.yml` (Worker) — auto CI/CD |

### รากฐานสำคัญ: Single-Source Registry
- `registry.js` = **แหล่งความจริงเดียว** ของทุกตารางที่ sync (client key ↔ D1 table ↔ prefix ↔ jsonCols ↔ dateCol)
- โหลดทั้งฝั่ง browser และ Worker → `SERVER_TABLE` / `SEED` / `TABLES` / `CLIENT_KEYMAP` / `DATE_COL` **derive จากที่เดียว** (ไม่มี drift)
- `scripts/check-registry.mjs` (`npm run check`) กันไม่ให้ตารางไม่มี migration หรือ map ค้าง หลุดขึ้น production
- **เพิ่มโมดูลใหม่ = แก้ registry 1 บรรทัด + 1 CREATE TABLE migration** เท่านั้น

### รูปแบบ Data (Schema-driven)
- ทุกโมดูลนิยามด้วย `SCHEMA[key]` (fields + validation + `onFail` + `validate` hooks)
- `onFail(rec)` → สร้าง NC/HOLD/Deviation/CAPA อัตโนมัติเมื่อผลไม่ผ่าน
- `validate(rec)` → กฎ business (เช่น ปิด CAPA ไม่ได้ถ้ายังไม่ EFFECTIVE) ทำงานทั้งตอนสร้างและแก้ไข
- ฟอร์มยาวจัดกลุ่มด้วย section header

### การ Sync & Offline
- localStorage เป็น cache หน้างาน → `saveDB()` เขียน local + push `/api/sync` (ทั้ง DB) ขึ้น D1
- `pullFromServer()` ดึง `/api/snapshot` มา merge (เก็บ local, tombstone กันข้อมูลลบแล้วกลับมา)
- ถ้า localStorage เต็ม → เตือน + ยัง push ขึ้น D1 (ข้อมูลไม่หาย)

## 3. โมดูลทั้งหมด (จัดกลุ่มตาม Navigation)

### Master Data
Suppliers (+ Approval/Evaluation), Materials, Finished Goods, Processes, Parameters, Equipment, CCP Master, Machines, Ingredients, Packaging, Chemicals, Process↔Parameter Map

### Operations & QA
- **ตรวจรับวัตถุดิบ** — FM-QA-31 ของสด (wizard) / FM-QA-32 เครื่องปรุง / FM-QA-33 บรรจุภัณฑ์
- **ตรวจระหว่างผลิต** — FM-QA-34 ละเอียด (wizard) + **IPQC** เช็คเร็ว (Dashboard/Checks/Hold/Deviation)
- **CCP / Metal Detector** — Verification (Fe Ø1.0 / Non-Fe Ø1.5 / SUS Ø2.0) + CCP Deviations + Dashboard
- **FG Release** — Dashboard / FG Lots / ตรวจปล่อย / Hold / Release Queue
- ตรวจ FG, ตรวจบรรจุภัณฑ์, ตรวจรถขนส่ง (FM-TS-01), HACCP/CCP Monitoring
- **NC** + **CAPA (9-stage)** + CAPA Dashboard
- สิ่งแวดล้อม, ควบคุมสัตว์พาหะ, ฝึกอบรม
- **Traceability & Recall** (Trace 1-Up/1-Down + Mock Recall) + Lot Genealogy
- ร้องเรียนลูกค้า, ฉลาก/ขอเลข อย.

### GHP Foundation
Dashboard + สุขลักษณะบุคคล, ทำความสะอาด&ฆ่าเชื้อ, คุณภาพน้ำ, สารก่อภูมิแพ้, แก้ว/พลาสติกแข็งเปราะ, การจัดการของเสีย

### Regulatory / FDA (อย.)
Dashboard (ต่ออายุใบอนุญาต RAG ≤90 วัน + drill-down) + **ทะเบียนผลิตภัณฑ์** (เลขสารบบอาหาร/สถานะใบอนุญาต/กรมปศุสัตว์/ส่งออก), **วัตถุเจือปนอาหาร** (INS/ML/ADI — เกินเกณฑ์/ต้องห้าม → auto NC), **ตรวจฉลาก** (checklist 12 องค์ประกอบบังคับ — ไม่ผ่าน → auto NC), **ยื่น/ต่ออายุ อย.** (workflow + license expiry), **ควบคุมการเปลี่ยนแปลง (RA)** (impact — เปลี่ยนสูตร/ฉลากต้องแจ้ง อย.?)

### Document Control
เชื่อมออกไปยัง **ระบบ DCC เฉพาะทาง** (worker `dcs-document-control` + DB `dcs_document_control`) — MDL / DAR / อนุมัติ / e-Stamp / แจกจ่าย เป็นแหล่งข้อมูลหลักเพียงที่เดียว (แอป QA ไม่เก็บสำเนาซ้ำ)

### Reports
**Management Review (KPI)** + Review Actions + บันทึกการประชุม + รายงาน & KPI + ตั้งค่าระบบ

## 4. กฎด้านความปลอดภัยอาหารที่ระบบบังคับ (Enforced Rules)

| กฎ | การบังคับในระบบ |
|---|---|
| ทุก FAIL ต้องมี Action | `onFail` สร้าง NC/HOLD/CAPA อัตโนมัติทุกโมดูล |
| CCP Failure → ควบคุมผลิตภัณฑ์ | Metal Detector FAIL → CCP Deviation + HOLD ช่วงเวลาที่กระทบ + CAPA + ต้อง QA review |
| ทุก HOLD ต้องมี Disposition | Hold record ปิดไม่ได้ถ้าไม่มีการตัดสิน |
| ห้ามปล่อยของถ้ามี HOLD/Deviation | FG Release readiness gate อ่าน CCP/Hold จริง — block เมื่อยังไม่เคลียร์ |
| Action Completed ≠ CAPA Effective | ปิด CAPA ไม่ได้ถ้า effectiveness ≠ EFFECTIVE (validate hook) |
| ห้าม "Human Error" เป็น root cause สุดท้าย | validate hook บล็อกการปิด CAPA |
| Purchasing อนุมัติ Supplier เองไม่ได้ | ตั้ง Approved ไม่ได้ถ้ายังไม่ผ่าน QA Review |
| KPI ต้อง drill-down ได้จริง | Management Review คำนวณสดจาก source + ปุ่มดู record |
| Traceability Supplier→FG→Customer | Lot Genealogy + Trace tool 1-Up/1-Down + Quantity Reconciliation |
| ห้าม Hard Delete controlled record | tombstone + สถานะ VOID/Closed แทนการลบ |

## 5. Traceability Chain

```
Supplier → Supplier Lot → Internal RM Lot → Production Lot
   → In-Process / IPQC → CCP (Metal Detector) → FG Lot
   → FG Release Decision → Distribution → Customer
```
Trace Tool (หน้า Traceability & Recall): พิมพ์ FG Lot เห็นต้นทาง+ลูกค้า / พิมพ์ RM Lot เห็น FG ที่กระทบ + ลูกค้าที่ต้องแจ้ง

## 6. Database Migrations

| # | เนื้อหา |
|---|---|
| 0001–0003 | โครงเดิม + rm_receiving + pest_control |
| 0004–0007 | lot genealogy, incoming/IPQC, split เครื่องปรุง/บรรจุ, backfill capa/labels |
| 0008 | FG Release (fg_lots, fg_release_inspections, fg_hold_records, fg_release_decisions) |
| 0009 | CCP / Metal Detector (metal_detector_verifications, ccp_deviations) |
| 0010 | CAPA 9-stage (ALTER capa + 26 คอลัมน์ — safe) |
| 0011 | Supplier Approval (ALTER suppliers + 3 ตาราง) |
| 0012 | GHP Foundation (6 ตาราง) |
| 0013 | Recalls |
| 0014 | Management Review + Tracked Actions |
| 0015 | Regulatory / FDA (reg_products, reg_additives, reg_label_compliance, reg_submissions, reg_changes) |

> ทุก migration เป็น **safe** (CREATE IF NOT EXISTS / ADD COLUMN) — ไม่ลบ/ไม่ rename ตารางเดิม ข้อมูลเก่าคงอยู่

## 7. การเพิ่มโมดูลใหม่ (สำหรับผู้พัฒนา)

1. เพิ่ม 1 entry ใน `registry.js` → `{ key, table, prefix, search, jsonCols?, dateCol? }`
2. เพิ่ม 1 `CREATE TABLE` ใน `migrations/00XX_*.sql` แล้วรันบน D1
3. เพิ่ม `SCHEMA[key]` (fields + onFail/validate) + `PAGES[key]` + nav item ใน `operations.html`
4. `npm run check` ต้องผ่าน (กัน drift) → commit → push
5. Worker redeploy อัตโนมัติ (registry.js อยู่ใน deploy trigger)

## 8. หมายเหตุการ Deploy

- **หน้าเว็บ** (operations.html, registry.js, sw.js): Cloudflare Pages auto-deploy จาก main
- **Worker** (worker.js + registry.js): GitHub Action `deploy-worker.yml` → `wrangler deploy` (ต้องมี secret `CLOUDFLARE_API_TOKEN`)
- อัปเดตหน้าเว็บ: refresh แรงๆ (Ctrl+Shift+R) — service worker cache version bump ทุกครั้ง

---
*อัปเดตล่าสุด: ระบบครบ build order หลัก (RM Receiving → In-Process → CCP → FG Release → CAPA → Supplier → GHP → Traceability → Management Review). เหลือ: DCC เต็มรูป + Regulatory/FDA.*
