# SWI Foods — Smart QA Department System (เวอร์ชันใช้งานได้จริง)

ระบบ QA ของโรงงานสรวรพัฒน์อินเตอร์ฟู้ดส์ — เปลี่ยนจากเว็บ static เป็นแอปจริงที่ทุกฟีเจอร์ทำงานได้

**🆕 v2.0** — โหลดข้อมูล Master Data จริงจาก `QA_Master_DATA.xlsx` ครบ 12 ตาราง (รวม **402 records**)

## ภาพรวม

แทนที่หน้า `/operations` เดิมของ www.sorworaphatinterfoods.net ด้วยระบบเต็มรูปแบบ ครอบคลุม **21 modules + Dashboard + KPI + รายงาน**:

### Master Data (12 ตาราง — 402 records จริงจาก QA_Master_DATA.xlsx)

| Module | จำนวน | คำอธิบาย |
|---|---:|---|
| 🏢 ซัพพลายเออร์ | 33 | RM/DM/PM/CM พร้อม CoA, Halal, GMP, audit date |
| 📦 วัตถุดิบ (Material) | 109 | RM/DM/PM/CM รวมทุกประเภท |
| 🌶️ เครื่องปรุง (Ingredients) | 38 | Seasoning / Ingredient / Additive |
| 📦 บรรจุภัณฑ์ (Packaging) | 60 | ถุง กล่อง สติ๊กเกอร์ ไม้เสียบ |
| 🧪 สารเคมี (Chemicals) | 6 | Cleaning & Sanitizing |
| 🍗 สินค้าสำเร็จรูป (FG) | 32 | หมู ไก่ ลูกชิ้น ไส้กรอก ข้าว |
| ⚙️ กระบวนการ (Processes) | 25 | PC0001 - PC0025 ครบทุกขั้นตอน |
| 📏 พารามิเตอร์ (Parameters) | 32 | PR0001 - PR0032 พร้อม spec |
| 🔧 เครื่องมือวัด (Equipment) | 32 | Scale, Thermometer, pH, Refractometer ฯลฯ |
| 🎯 CCP Master | 7 | จุดวิกฤต PC0008, PC0010, PC0012 |
| 🔗 Process ↔ Parameter Map | 21 | จับคู่ขั้นตอนกับตัวแปรตรวจ |
| 🏭 เครื่องจักร (Machines) | 7 | Cutter, Mixer, Skewer, Metal Detector ฯลฯ |

### Operations & QA (9 modules — ใส่ข้อมูลใหม่)

| Module | คำอธิบาย |
|---|---|
| ✓ ตรวจรับวัตถุดิบ (RM) | **🆕 v2** รถขนส่ง (ทะเบียน+อุณหภูมิ 0-4°C) + วัตถุดิบหลายชนิด (ปุ่ม +) + แกนกลาง 3 ซ้ำ (0-7°C) + MFG/EXP + auto-NC + A4 |
| 🔬 ตรวจระหว่างผลิต (FM-QA-32) | **🆕** Process → Parameter → จุดตรวจ (วัดซ้ำได้) · auto PASS/FAIL · พิมพ์ A4 |
| 🍗 ตรวจ FG | Weight check + Metal detector + Sensory |
| 📦 ตรวจบรรจุภัณฑ์ | Dimensions + Food-grade cert |
| 🚛 ตรวจรถขนส่ง (FM-TS-01) | **🆕** Checklist 5 จุด + อุณหภูมิ ≤4°C + ร.น./ร.3 + auto-NC + พิมพ์ A4 |
| 🌡️ HACCP / CCP Monitoring | Auto-NC เมื่อเกินขีดจำกัด |
| ⚠️ NC / CAPA | Root cause, corrective, preventive, effectiveness |
| 🌡️ Environmental | Temperature, Humidity, ATP, Microorganism |
| 🐀 ควบคุมสัตว์พาหะ (FM-EN-02) | **🆕** กล่องดักหนู / เครื่องดักแมลงวัน / บ้านแมลงสาบ (ปุ่ม +) + auto-NC เมื่อพบ + A4 |
| 👥 Training | Records, assessment, effectiveness |
| 🔍 Traceability | Forward/Backward, RM lots → batch → customer |
| 📋 Customer Complaints | Channel, severity, investigation, response |

## ฟีเจอร์หลักที่ใช้งานได้จริง

✅ **CRUD ครบทุก module** — เพิ่ม/แก้ไข/ลบ/ค้นหา ทุกตาราง
✅ **Auto-NC trigger** — เมื่อตรวจ FAIL หรือ CCP เกินขีดจำกัด ระบบสร้างใบ NC อัตโนมัติ
✅ **KPI คำนวณจริง** — Receiving Compliance, CCP Rate, CAPA Effectiveness ฯลฯ
✅ **Dashboard + Charts** — Chart.js แสดง trend 30 วัน, สัดส่วน risk
✅ **Persistence 2 ชั้น** — localStorage (ออฟไลน์ใช้ได้) + sync Cloudflare D1 (ออนไลน์)
✅ **Login + 3 roles** — admin / qa / inspector (password = `1234`)
✅ **Export/Import** — สำรองข้อมูลเป็น JSON, ดาวน์โหลด CSV รายตาราง
✅ **Multi-device** — Responsive, ใช้บนมือถือได้
✅ **PWA (Progressive Web App)** — ติดตั้งเป็นแอปจริงบนมือถือ/แท็บเล็ต/เดสก์ท็อป
✅ **Offline-first** — Service Worker cache ทำงานได้แม้ไม่มีเน็ต
✅ **iOS Safe Area** — รองรับ notch บน iPhone / Dynamic Island

---

## 📷 Barcode / QR Scanner (สแกนผ่านกล้อง)

ใช้ในฟอร์มตรวจรับวัตถุดิบ (RM), ตรวจ FG, ตรวจบรรจุภัณฑ์ และตรวจระหว่างผลิต — กดปุ่มกล้องข้างช่องกรอก:

### การทำงาน
- ฟิลด์ที่สแกนได้จะมี **ปุ่มกล้องสีเขียว** อยู่ข้างๆ (ซัพพลายเออร์, วัตถุดิบ, Lot, Batch, สินค้า FG, บรรจุภัณฑ์)
- กดแล้วเปิดกล้องหลังเต็มจอ → วางบาร์โค้ด/QR ในกรอบ → ระบบอ่านอัตโนมัติ + สั่นแจ้งเตือน
- รองรับ **QR Code + บาร์โค้ด 1D** (EAN, Code128, UPC ฯลฯ) ผ่านไลบรารี html5-qrcode
- มี **ปุ่มพิมพ์เอง** สำรองหากกล้องไม่พร้อม/ถูกปฏิเสธสิทธิ์

### Smart Matching (เติมข้อมูลอัจฉริยะ)
| ประเภทฟิลด์ | สแกนได้ | ผลลัพธ์ |
|---|---|---|
| ซัพพลายเออร์/วัตถุดิบ/FG/บรรจุภัณฑ์ | `SP0001`, `RM0001` | match ตาม id แล้วเลือกให้อัตโนมัติ |
| (กรณีไม่เจอ id) | ชื่อบางส่วน | match ตามชื่อ |
| (QR แบบรวม) | `SP0002\|ชื่อบริษัท` | แยกเอา id ตัวแรก |
| Lot / Batch | ข้อความใดๆ | กรอกค่าดิบลงช่อง |

### ตัวอย่างการพิมพ์ QR ติดวัตถุดิบ
แนะนำให้พิมพ์ QR ที่ encode **รหัส master data ตรงๆ** เช่น `SP0001`, `RM0001`, `FG0001`
หรือแบบรวม `SP0001|เบทาโกร` ก็ได้ ระบบจะ match ให้อัตโนมัติ

> ⚠️ กล้องต้องเปิดผ่าน **HTTPS** เท่านั้น (Cloudflare Pages ให้อัตโนมัติ) — เปิดผ่าน `file://` หรือ `http://` กล้องจะไม่ทำงาน ให้ใช้ปุ่มพิมพ์เองแทน

---

## 🚛 โมดูลตรวจรถขนส่ง (FM-TS-01) — Vehicle Inspection & Transportation Record

ออกแบบตามเกณฑ์การตรวจประเมินหมวดการขนส่ง (4.6) ของ GHPs/HACCP และข้อกำหนดลูกค้ารายใหญ่ (เช่น CP Axtra)

### ครอบคลุมข้อกำหนด
| ข้อ | เกณฑ์ | ในฟอร์ม |
|---|---|---|
| 4.6.1 | ตรวจสอบสภาพรถก่อนโหลด | บันทึกทุกครั้ง + เลขทะเบียน (สแกนได้) |
| 4.6.2 | ควบคุมผู้รับเหมาช่วง | ฟิลด์ประเภทรถ (บริษัท/Outsource) |
| 4.6.3 | ควบคุมอุณหภูมิ | ช่องอุณหภูมิ + วิธีวัด (ปืน/Logger) — เนื้อสัตว์สด ≤4°C |
| 4.6.4 | ความปลอดภัยผลิตภัณฑ์ | Checklist 5 จุด (สะอาด/สัตว์พาหะ/วัตถุอันตราย/สนิม/การจัดเรียง) |
| Traceability | เอกสารบังคับ | เช็ก ใบ ร.น. + ใบ ร.3 + Lot/Invoice/ปลายทาง |

### Auto-NC อัจฉริยะ
เมื่อผลเป็น FAIL ระบบสร้าง NC อัตโนมัติ พร้อม**ระบุสาเหตุที่ไม่ผ่าน**โดยอัตโนมัติ เช่น
"อุณหภูมิเกิน (8°C > 4°C), ขาดเอกสาร ร.น." — severity High, type Transportation

### เชื่อมกับ FM-QA-31
ตามคำแนะนำ สามารถเชื่อมการตรวจขนส่งเข้ากับการรับเข้าวัตถุดิบ โดยเช็ก ร.น./ร.3
ควบคู่การตรวจสภาพรถ ปิดความเสี่ยง CAR หมวดสอบย้อนกลับ

---

## 🔬 โมดูลตรวจระหว่างผลิต (FM-QA-32) — In-Process Inspection

ออกแบบตามโครงสร้าง **1 บันทึก → หลายกระบวนการ → หลายพารามิเตอร์ → หลายจุดตรวจ** เพื่อความยืดหยุ่นสูงสุด:

### การใช้งาน
1. กด **"+ บันทึกตรวจระหว่างผลิต"** → กรอกหัวเอกสาร (วันที่, สินค้า, Batch, สายการผลิต, กะ, ผู้ตรวจ)
2. กด **"+ เพิ่มกระบวนการ (Process)"** → เลือกกระบวนการ (เช่น PC0010 การให้ความร้อน)
   - ระบบจะ **โหลดพารามิเตอร์ควบคุมอัตโนมัติ** จาก process-parameter map (เช่น อุณหภูมิแกนกลาง ≥75°C)
   - กระบวนการที่เป็น CCP จะมี **ป้าย ⚠️CCP** กำกับ
3. แต่ละพารามิเตอร์ กด **"+ เพิ่มจุดตรวจ (วัดซ้ำ)"** ได้ไม่จำกัด — สำหรับพารามิเตอร์ที่ต้องตรวจหลายครั้ง/หลายเวลา
4. กรอกเวลา + ค่าที่วัดได้ → ระบบ **ประเมิน PASS/FAIL อัตโนมัติ** เทียบกับ spec มาตรฐาน
5. เพิ่มพารามิเตอร์เอง หรือเพิ่มกระบวนการอื่นๆ ได้ตามต้องการ

### Auto-evaluation (ประเมินผลอัตโนมัติ)
ระบบอ่าน spec จาก master data และตัดสินผลให้:

| รูปแบบ Spec | ตัวอย่าง | การประเมิน |
|---|---|---|
| ช่วง | `0 - 4`, `5.5 - 5.8` | ค่าต้องอยู่ในช่วง |
| ค่าต่ำสุด | `≥ 75` | ค่าต้อง ≥ เกณฑ์ |
| ค่าสูงสุด | `≤ 12`, `≤ -18` | ค่าต้อง ≤ เกณฑ์ |
| ช่วงติดลบ | `(-4) - 4` | รองรับค่าติดลบ |
| Metal detector | `ø 1.0` | กรอก "ผ่าน"/"ไม่ผ่าน" |

- เจอค่า **FAIL แม้แต่จุดเดียว** → ผลรวมเป็น FAIL + **สร้าง NC อัตโนมัติ** (ถ้าเป็น CCP จะตั้ง severity = High)

### พิมพ์รายงาน A4
- กดปุ่ม **🖨** ที่รายการ หรือ **"👁 ดูตัวอย่าง A4"** ในฟอร์ม
- รายงานจัดรูปแบบ **A4 portrait** ตามมาตรฐาน QMS:
  - หัวเอกสาร: โลโก้บริษัท, เลขที่เอกสาร FM-QA-32, revision, page
  - ข้อมูลการตรวจ: เลขที่บันทึก, วันที่, สินค้า, batch, สายการผลิต, กะ, ผู้ตรวจ
  - ตารางหลัก: ลำดับ, กระบวนการ (+CCP), พารามิเตอร์, เกณฑ์, เวลา, ค่าที่วัด, ผล (สี)
  - สรุปผลรวม + **ช่องลงนามผู้ตรวจ + ผู้ทวนสอบ (QA)**
- ใช้ `@page { size: A4 portrait }` พิมพ์ผ่านเบราว์เซอร์ได้ตรงขนาดกระดาษ

---



ระบบนี้ใช้ **PWA** แทน React Native เพราะเหมาะกับโจทย์มากกว่า:

| ปัจจัย | PWA ✅ | React Native ❌ |
|---|---|---|
| ติดตั้งได้บน iOS + Android | ✅ ทันที | ✅ แต่ต้อง build แยก |
| ขึ้น App Store / Play Store | ❌ ไม่ต้อง | ✅ ต้อง (เสียเงิน + รออนุมัติ) |
| Apple Developer License ($99/ปี) | ❌ ไม่ต้อง | ✅ ต้องจ่าย |
| อัพเดทเวอร์ชันใหม่ | ทันที (refresh) | รอ Store review 1-7 วัน |
| ใช้ codebase เดียวกัน | ✅ HTML/JS เดียวกัน | ❌ ต้องเขียนใหม่ |
| ออฟไลน์ได้ | ✅ Service Worker | ✅ AsyncStorage |
| Push Notifications | ✅ (Android เต็ม / iOS 16.4+) | ✅ |
| กล้อง/บาร์โค้ด | ✅ Web APIs | ✅ Native APIs |
| ขนาดไฟล์ | ~200 KB | 30-50 MB |
| สำหรับ internal QA tool | ⭐ เหมาะที่สุด | overkill |

> สำหรับโรงงานที่มีผู้ใช้ภายในเป็นหลัก PWA ตอบโจทย์ **ใช้งานเหมือนแอป + ไม่ต้องผ่าน Store + รวดเร็วในการอัปเดต**

---

## โครงสร้างไฟล์

```
swi-foods-qa/
├── operations.html         ← Frontend SPA + PWA shell
├── manifest.webmanifest    ← 🆕 PWA manifest (ชื่อแอป, ไอคอน, shortcuts)
├── sw.js                   ← 🆕 Service Worker (offline cache)
├── icon-192.png            ← 🆕 PWA icon 192×192
├── icon-512.png            ← 🆕 PWA icon 512×512
├── icon-512-maskable.png   ← 🆕 Android adaptive icon
├── icon-180-apple.png      ← 🆕 iOS apple-touch-icon
├── favicon-32.png          ← 🆕 Browser favicon
├── favicon-64.png          ← 🆕 Browser favicon (Retina)
├── worker.js               ← Cloudflare Worker (Hono) backend
├── schema.sql              ← D1 database migration (23 tables, 402 records)
├── wrangler.toml           ← Worker config
├── package.json
└── README.md
```

---

## 📲 วิธีติดตั้งเป็นแอปบนมือถือ

> ⚠️ **PWA ต้อง host บน HTTPS** — ใช้ Cloudflare Pages, Netlify, Vercel, หรือ HTTPS server อื่นๆ
> เปิดเป็น `file://` หรือ `http://` Service Worker จะไม่ทำงาน

### iPhone / iPad (Safari)

1. เปิด URL แอปใน **Safari** (ไม่ใช่ Chrome เพราะ iOS จำกัด)
2. กดปุ่ม **Share** (📤 กล่องลูกศรขึ้น) ด้านล่าง
3. เลื่อนหา **"Add to Home Screen"** / **"เพิ่มสู่หน้าจอหลัก"**
4. กด **"Add"** / **"เพิ่ม"** ตรงมุมขวาบน
5. ไอคอน **SWI QA** จะปรากฏบนหน้าจอหลัก เปิดได้เหมือนแอปจริง (ไม่มีแถบ URL)

### Android (Chrome / Edge / Samsung Internet)

1. เปิด URL แอปใน **Chrome** (หรือ browser ใดๆ ที่รองรับ)
2. แอปจะแสดง **banner สีเขียว** "ติดตั้งแอปลงเครื่อง" — กด **"ติดตั้ง"**
3. หรือกดเมนู ⋮ → **"Install app"** / **"ติดตั้งแอป"**
4. ไอคอนจะถูกเพิ่มลงหน้าจอหลัก + drawer แอป

### Desktop (Chrome / Edge บน Windows/Mac)

1. เปิด URL ใน Chrome หรือ Edge
2. จะเห็นไอคอน **📥 install** ในแถบ URL ด้านขวา
3. กดเพื่อ install — เปิดได้จาก Start Menu / Launchpad

### หลังติดตั้งแล้ว

- เปิดได้แบบ standalone (ไม่มี browser UI)
- ทำงานออฟไลน์ได้ (Service Worker)
- มี shortcut ลัด: ตรวจรับวัตถุดิบ, HACCP, NC, Dashboard (long-press ที่ไอคอน)
- อัปเดตเวอร์ชันใหม่อัตโนมัติ มี banner แจ้งเมื่อมีของใหม่

---

## โครงสร้างไฟล์ — เพิ่มเติม PWA

---

## วิธี Deploy

### ทางเลือก A — Cloudflare Pages (แนะนำ — PWA ทำงานเต็มที่)

> **เหมาะสุด** เพราะ Cloudflare Pages ให้ HTTPS อัตโนมัติ + CDN global + custom domain ฟรี

#### ผ่าน Wrangler (CLI)

```bash
cd swi-foods-qa
# ลบ node_modules + ไฟล์ backend ออกก่อน (เหลือเฉพาะ static)
npx wrangler pages deploy . --project-name=swi-qa-app
```

ครั้งแรกจะถาม:
- Project name: `swi-qa-app` (หรือชื่อใดๆ)
- Production branch: `main`

จะได้ URL คล้าย `https://swi-qa-app.pages.dev` — เปิด URL นี้บนมือถือแล้วติดตั้งได้เลย

#### ผ่าน Dashboard

1. เข้า https://dash.cloudflare.com → **Pages** → **Create a project**
2. เลือก **Direct Upload** → ลากโฟลเดอร์ `swi-foods-qa/` (ลบ `worker.js`, `schema.sql`, `node_modules` ออกก่อน)
3. กด **Deploy**
4. (Optional) **Custom domains** → ผูก `qa.sorworaphatinterfoods.net` หรืออื่นๆ

#### ผูก subdomain ของบริษัท (ถ้ามี)

ใน Pages settings → **Custom domains** → Add:
- `qa.sorworaphatinterfoods.net` (subdomain)
- หรือ `app.sorworaphatinterfoods.net`

Cloudflare จะตั้งค่า DNS + SSL ให้อัตโนมัติ

---

### ทางเลือก B — ใช้แบบ **Offline เท่านั้น** (ทดสอบเฉพาะที่)

---

### ทางเลือก B — เชื่อม Cloudflare D1 (production, multi-device sync)

#### 1. ติดตั้ง wrangler และ login

```bash
npm install -g wrangler
wrangler login
```

#### 2. ตรวจสอบ database ที่มีอยู่ (qa-factory-db)

```bash
wrangler d1 list
```

จด `database_id` แล้วใส่ใน `wrangler.toml`:

```toml
[[d1_databases]]
binding       = "DB"
database_name = "qa-factory-db"
database_id   = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  ← ใส่ตรงนี้
```

#### 3. สร้าง KV namespaces สำหรับ session

```bash
wrangler kv namespace create SESSION
wrangler kv namespace create CACHE
```

จด ID แล้วใส่ใน `wrangler.toml`

#### 4. สร้างตารางในฐานข้อมูล (รัน schema)

```bash
cd swi-foods-qa
npm install
npm run db:init
```

#### 5. ตั้ง JWT secret

```bash
wrangler secret put JWT_SECRET
# → ใส่รหัสลับยาวๆ ของคุณ เช่น openssl rand -hex 32
```

#### 6. Deploy Worker

```bash
npm run deploy
```

จะได้ URL คล้าย `https://swi-qa-api.<your-account>.workers.dev`

#### 7. เชื่อม Frontend กับ Backend

เปิด `operations.html` แก้บรรทัดบนๆ ของ `<script>`:

```javascript
const API_BASE_URL = 'https://swi-qa-api.<your-account>.workers.dev';
```

ทุกครั้งที่บันทึก จะ sync ขึ้น D1 ให้อัตโนมัติ

---

### ทางเลือก C — เปลี่ยน /operations บน www.sorworaphatinterfoods.net (Cloudflare Pages)

ถ้าต้องการแทน operations เดิมในเว็บ:

1. สร้าง Cloudflare Pages project
2. Push `operations.html` (และไฟล์อื่นๆ ที่ B12 export ให้) เข้า Git
3. ผูก custom domain → `www.sorworaphatinterfoods.net` (เลิกใช้ B12 hosting)
4. หรือทำให้เป็น subdomain เช่น `app.sorworaphatinterfoods.net`

**หมายเหตุ:** ตอนนี้โดเมนเดินอยู่บน B12 (Astro) — ถ้าจะแทนทั้งเว็บ ต้องย้าย DNS หรือใช้ subdomain ก่อน

---

## บัญชีทดสอบ

| Username | Password | Role |
|---|---|---|
| `admin` | `1234` | ผู้ดูแลระบบ |
| `qa` | `1234` | หัวหน้า QA |
| `inspector` | `1234` | เจ้าหน้าที่ QA |

> ⚠️ **เปลี่ยนรหัสผ่านก่อนใช้งานจริง** — แก้ในไฟล์ `operations.html` ที่ object `SEED.users` หรือใส่ผ่าน D1 console

---

## REST API (สำหรับนักพัฒนา)

ตัวอย่างเรียก:

```bash
# Health check
curl https://swi-qa-api.swifoods.workers.dev/api/health

# List suppliers
curl https://swi-qa-api.swifoods.workers.dev/api/suppliers?q=เบทาโกร

# Dashboard KPIs
curl https://swi-qa-api.swifoods.workers.dev/api/dashboard/kpi

# Create supplier
curl -X POST https://swi-qa-api.swifoods.workers.dev/api/suppliers \
  -H "Content-Type: application/json" \
  -d '{"name":"ทดสอบ จำกัด","type":"DM","risk":"LOW","status":"Approved"}'
```

### In-Process Inspection (FM-QA-32) — nested payload

ตาราง `inprocess_inspections` เก็บ `processes` เป็น JSON (process → parameter → rounds) Worker จะ
serialize/deserialize ให้อัตโนมัติ และ **สร้าง NC อัตโนมัติฝั่ง server** เมื่อ `overallResult = FAIL`

```bash
curl -X POST https://swi-qa-api.swifoods.workers.dev/api/inprocess_inspections \
  -H "Content-Type: application/json" \
  -d '{
    "date":"2026-05-30","productName":"หมูปิ้ง","batch":"B-001",
    "line":"Line 1","shift":"เช้า","inspector":"QA","overallResult":"FAIL",
    "processes":[
      {"processId":"PC0010","processName":"การให้ความร้อน","isCCP":true,
       "parameters":[{"parameterId":"PR0003","parameterName":"อุณหภูมิแกนกลาง",
                      "spec":"≥ 75","unit":"°C",
                      "rounds":[{"time":"09:00","value":"78"},{"time":"11:00","value":"72"}]}]}
    ]
  }'
# → ระบบจะตรวจพบ 72 < 75 = FAIL และสร้าง NC อัตโนมัติ (severity High เพราะเป็น CCP)
```

GET กลับมาจะได้ `processes` เป็น array พร้อม nesting ครบ (ไม่ใช่ string)

### Endpoints ทั้งหมด

| Method | Path | หน้าที่ |
|---|---|---|
| GET | `/api/health` | health check |
| POST | `/api/auth/login` | เข้าสู่ระบบ (KV session) |
| GET | `/api/:table` | list (รองรับ `?q=` `?status=` `?limit=` `?offset=`) |
| GET | `/api/:table/:id` | detail (deserialize JSON cols) |
| POST | `/api/:table` | create (auto-NC trigger) |
| PUT | `/api/:table/:id` | update |
| DELETE | `/api/:table/:id` | delete |
| POST | `/api/sync` | sync ทั้ง snapshot จาก client (22 tables) |
| GET | `/api/dashboard/kpi` | KPI รวม |
| GET | `/api/dashboard/trends?days=30` | แนวโน้ม |
| GET | `/api/export` | export ทุกตาราง |

> ตาราง (22): master data 12 + transactional 10 รวม `inprocess_inspections` ตรวจสอบใน whitelist `TABLES` ที่ worker.js

ดูรายละเอียดทั้งหมดใน `worker.js`

---

## Custom & Extend

- **เพิ่ม field ใน module**: แก้ `SCHEMA[<key>].fields` ใน `operations.html` และ `schema.sql` ตามลำดับ
- **เพิ่ม module ใหม่**: เพิ่ม entry ใน `SCHEMA`, `PAGES`, nav, และ table ใน schema.sql
- **เปลี่ยนสี/Logo**: แก้ `tailwind.config.colors.brand` และ HTML header
- **เพิ่ม role/permission**: เช็คใน `currentUser.role` ก่อน render ปุ่ม/route
- **เปิด require auth ทั้ง API**: ปลดล็อก comment ใน `worker.js`: `app.use('/api/:table/*', requireAuth)`

---

## ติดต่อ / สนับสนุน

ระบบนี้ออกแบบสำหรับ **บริษัท สรวรพัฒน์ อินเตอร์ฟู้ดส์ จำกัด** โดยเฉพาะ — รองรับมาตรฐาน GHPs, HACCP, CODEX และ ISO 17025/GLP

หากต้องการเพิ่มเติม:
- เชื่อม Google Sheets / Excel sync
- พิมพ์ PDF ผ่าน Cloudflare Browser Rendering
- เชื่อม IoT sensors (อุณหภูมิห้องเย็น, metal detector)
- ✅ ~~Mobile native app~~ → **เปลี่ยนเป็น PWA แล้ว** (รองรับ iOS/Android/Desktop ในไฟล์เดียว)
- Push Notifications (แจ้งเตือน NC, CCP deviation)
- ✅ ~~Barcode/QR scanner~~ → **ทำแล้ว** (สแกนผ่านกล้องใน RM/FG/Packaging/In-Process)

ขอแก้เพิ่มได้เลยครับ — โครงสร้าง modular พร้อมขยาย
