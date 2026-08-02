-- 0050_amarc_and_tosh_reports.sql
-- Record the two external reports supplied for NC 016 and NC 018.
--
-- Neither is quite what it was asked for, and both matter more than expected.
--
-- ── AMARC 25-167419 (16/09/2025) ────────────────────────────────────────────
-- Supplied as the lab result behind the shelf-life finding. It is not a
-- shelf-life study: it is a single-timepoint conformity test that CP AXTRA ran
-- on a retail sample of our product, one sample, one date, no timepoint series
-- and no protocol. It cannot establish a 12-month life on its own.
--
-- It is still the strongest shelf-life evidence in the building. The pack was
-- MFG 29/04/25 / EXP 29/04/26 and was collected 07/09/2025 — 131 days, about
-- 36% of the claimed life, aged in the real frozen supply chain rather than a
-- cabinet. Everything passed with room to spare: TPC 1.2×10⁵ against a limit of
-- 1×10⁶, every pathogen not detected, lead <0.01 against ≤0.1, beta-agonists and
-- six antibiotic assays not detected.
--
-- So conclusion is INCONCLUSIVE, not PASS. The product is demonstrably sound at
-- four months; the label says twelve. establishedShelfLife stays NULL because
-- nothing here establishes it. Recording it as PASS would answer the auditor's
-- question with a number this document does not contain.
--
-- ── TOSH 2569/004 (ตรวจวัด 09/06/2569) ───────────────────────────────────────
-- Supplied as the work-environment report behind NC 018, and it does close that
-- finding: the measurement was made, by an accredited body, with an annual plan
-- behind it. But the result is 11 pass / 13 FAIL out of 24 points, and 12 of the
-- 13 failures are task-specific lighting.
--
-- That is not an HR footnote. Lighting at task points is where visual inspection
-- for foreign matter happens; Codex GHP requires adequate lighting for exactly
-- that reason, and the September surveillance audit covers GHP. A closed NC 018
-- with this report attached and nothing done about the 13 failures invites the
-- obvious question. NCR-256908-002 is raised so the question has an answer that
-- is already in progress rather than one improvised at the table.
--
-- Only page 1 of 14 (the summary) was supplied, so per-point values are not
-- recorded — the environmental rows carry the counts the summary states and say
-- so. The detail pages would let each failing point be located and fixed.

-- ── 0. nc_capa has never had a notes column ─────────────────────────────────
-- Every other register here carries one — supplier_scars, ccps, recalls,
-- shelf_life_studies — and the first version of this migration used it on
-- nc_capa without checking. D1 rejected the whole file, which is the behaviour
-- you want: nothing landed, and the rows below are written once against a table
-- that can hold them.
--
-- The column is not decoration. A finding needs somewhere to say why it was
-- graded the way it was, what an attached document does and does not prove, and
-- what changed when better information arrived — none of which belongs in
-- description (the finding), rootCause (the cause) or effectivenessCheck (the
-- verification). The closeout page renders it, so it is read rather than filed.
ALTER TABLE nc_capa ADD COLUMN notes TEXT;

-- ── 1. AMARC report into the shelf-life register ────────────────────────────
INSERT OR IGNORE INTO shelf_life_studies
  (id, studyDate, product, productLot, studyType, storageCondition, storageTempTarget,
   packaging, claimedShelfLife, protocolRef, paramsTested, timepoints, acceptanceCriteria,
   establishedShelfLife, storageInstruction, conclusion, ncRef, status, studiedBy,
   notes, created, modified)
VALUES (
  'SLS0002', '2025-09-08', 'FG - ม006', 'MFG 29/04/25 · EXP 29/04/26',
  'REALTIME', 'FROZEN', '≤ -18 °C',
  'ถุงพลาสติกปิดผนึกสนิท 950 g/ถุง x 2 ถุง',
  '365 วัน (12 เดือน) ตามที่ระบุบนฉลาก MFG 29/04/25 – EXP 29/04/26',
  'AMARC Report of Analysis No. 25-167419 (Request 25-73483) ลว. 16/09/2025 — ห้องปฏิบัติการรับรอง ISO/IEC 17025 (DMSc 1124/50, ilac-MRA)',
  'จุลชีววิทยา: Total Plate Count · Bacillus cereus · Clostridium perfringens · Escherichia coli · Staphylococcus aureus · Salmonella spp. · Vibrio cholerae | เคมี: ตะกั่ว (Pb) · สารกลุ่ม Beta-agonist (Clenbuterol, Salbutamol, Cimaterol, Ractopamine) · ยาปฏิชีวนะตกค้าง 6 ชุดทดสอบ',
  '[{"day":131,"tpc":"1.2 x 10^5 CFU/g","coliform":"E. coli < 3.0 MPN/g","pathogen":"Salmonella / V. cholerae — Not Detected · B. cereus < 10 · C. perfringens < 10 · S. aureus < 10 CFU/g","sensory":"ได้รับตัวอย่างในสภาพแช่แข็ง สภาพดี","result":"PASS"}]',
  'TPC < 1x10^6 CFU/g · B. cereus < 1x10^3 · C. perfringens < 1x10^3 · E. coli < 1x10^2 MPN/g · S. aureus <= 1x10^2 · Salmonella / V. cholerae ไม่พบใน 25 g · Pb <= 0.1 mg/kg · Beta-agonist และยาปฏิชีวนะ ไม่พบ',
  NULL,
  'เก็บรักษาที่อุณหภูมิแช่แข็ง ≤ -18 °C',
  'INCONCLUSIVE', 'NCR-256905-016', 'Completed', 'AMARC (ห้องปฏิบัติการภายนอก)',
  'ไม่ใช่การศึกษาอายุการเก็บรักษาที่ออกแบบไว้ — เป็นผลตรวจยืนยันความสอดคล้อง (conformity) จุดเวลาเดียว ที่ลูกค้า CP AXTRA เป็นผู้สุ่มตัวอย่างสินค้าหน้าร้าน (สาขาเทพารักษ์) ส่งตรวจเอง | ตัวอย่างเก็บ 07/09/2025 เวลา 12:47 · รับเข้า 08/09/2025 · ทดสอบ 08–15/09/2025 | อายุตัวอย่าง ณ วันเก็บ = 131 วัน หรือประมาณ 36% ของอายุที่ระบุบนฉลาก | ผ่านทุกรายการโดยมีระยะห่างจากเกณฑ์มาก (TPC 1.2x10^5 จากเกณฑ์ 1x10^6) | ⚠ สรุปเป็น INCONCLUSIVE เพราะจุดเวลาเดียวที่ 4 เดือน ไม่สามารถยืนยันอายุ 12 เดือนได้ และไม่มีการตรวจ ณ ช่วงปลายอายุ — ยังต้องมีการศึกษาตามระเบียบ QP-QA-17 ที่ออกใหม่ จึงจะตอบได้ว่าอายุบนฉลากอ้างอิงผลใด | สินค้าอ้างอิง: ARO หมูปิ้งนมสดแช่แข็ง 25 ก. x 40 ไม้ (Article 235409 · Supplier Code 93346)',
  strftime('%Y-%m-%dT%H:%M:%fZ','now'), strftime('%Y-%m-%dT%H:%M:%fZ','now')
);

-- ── 2. TOSH measurements into the environmental register ────────────────────
-- The register was empty. These are the summary counts from page 1 of 14.
INSERT OR IGNORE INTO environmental (id, date, area, parameter, value, "limit", result, action, operator, created, modified) VALUES
 ('ENV0001','2026-06-09','ทั่วโรงงาน (7 จุดตรวจวัด)','ความเข้มของแสงสว่าง — แบบพื้นที่','ผ่าน 6 จุด · ไม่ผ่าน 1 จุด','ประกาศกรมสวัสดิการและคุ้มครองแรงงาน เรื่องมาตรฐานความเข้มของแสงสว่าง ลว. 27 พ.ย. 2560','FAIL','ออก NCR-256908-002 — ต้องระบุจุดที่ไม่ผ่านจากรายงานหน้า 2–14 และปรับปรุงแสงสว่าง',NULL,strftime('%Y-%m-%dT%H:%M:%fZ','now'),strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 ('ENV0002','2026-06-09','ทั่วโรงงาน (13 จุดตรวจวัด)','ความเข้มของแสงสว่าง — แบบใช้สายตามองเฉพาะจุด','ผ่าน 1 จุด · ไม่ผ่าน 12 จุด','ประกาศกรมสวัสดิการและคุ้มครองแรงงาน เรื่องมาตรฐานความเข้มของแสงสว่าง ลว. 27 พ.ย. 2560','FAIL','ออก NCR-256908-002 — จุดใช้สายตาเฉพาะจุดคือจุดที่ตรวจพินิจสิ่งแปลกปลอม กระทบทั้งอาชีวอนามัยและ GHP',NULL,strftime('%Y-%m-%dT%H:%M:%fZ','now'),strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 ('ENV0003','2026-06-09','ทั่วโรงงาน (3 จุดตรวจวัด)','ระดับเสียงเฉลี่ยตลอดระยะเวลาการทำงาน (TWA)','ผ่าน 3 จุด · ไม่ผ่าน 0 จุด','ประกาศกรมสวัสดิการและคุ้มครองแรงงาน เรื่องมาตรฐานระดับเสียง ลว. 13 ธ.ค. 2560 ข้อ 3','PASS',NULL,NULL,strftime('%Y-%m-%dT%H:%M:%fZ','now'),strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 ('ENV0004','2026-06-09','ทั่วโรงงาน (1 จุดตรวจวัด)','ระดับความร้อน','ผ่าน 1 จุด · ไม่ผ่าน 0 จุด','กฎกระทรวงกำหนดมาตรฐานในการบริหาร จัดการ และดำเนินการด้านความปลอดภัย อาชีวอนามัย และสภาพแวดล้อมในการทำงานเกี่ยวกับความร้อน แสงสว่าง และเสียง พ.ศ. 2559 หมวด 1','PASS',NULL,NULL,strftime('%Y-%m-%dT%H:%M:%fZ','now'),strftime('%Y-%m-%dT%H:%M:%fZ','now'));

-- ── 3. The lighting failures are their own finding ──────────────────────────
-- NC 018 was "no measurement was made". That is now corrected. This is the
-- separate finding the measurement uncovered, and it cannot ride inside a
-- closed NC.
INSERT OR IGNORE INTO nc_capa
  (id, date, type, description, severity, source, rootCause, correctiveAction,
   preventiveAction, owner, dueDate, verifiedBy, effectivenessCheck, status,
   evidenceRefs, created, modified)
VALUES (
  'NCR-256908-002', '2026-08-02', 'Regulatory',
  'ความเข้มของแสงสว่างต่ำกว่าเกณฑ์กฎหมาย 13 จุดจาก 24 จุดตรวจวัด ตามรายงานผลการตรวจวัดและวิเคราะห์สภาวะการทำงาน สสปท. เลขที่ขอรับบริการ 2569/004 (ตรวจวัด 9 มิ.ย. 2569) — แสงสว่างแบบใช้สายตามองเฉพาะจุด ไม่ผ่าน 12 จุดจาก 13 จุด และแบบพื้นที่ ไม่ผ่าน 1 จุดจาก 7 จุด (เสียงและความร้อนผ่านทั้งหมด)',
  'Major', 'รายงานผลตรวจวัดสภาวะการทำงาน สสปท. 2569/004',
  NULL,
  NULL,
  NULL,
  'HR / MN', NULL, NULL, NULL, 'Open',
  '["ENV0001","ENV0002"]',
  strftime('%Y-%m-%dT%H:%M:%fZ','now'), strftime('%Y-%m-%dT%H:%M:%fZ','now')
);

-- Root cause, actions and a due date are the owner's to write — this record
-- exists so the finding is visible and owned, not so it looks answered. The
-- grading is provisional and stated as such.
UPDATE nc_capa SET notes = 'บันทึกจากรายงาน สสปท. 2569/004 — ยังไม่ได้วิเคราะห์สาเหตุรากและกำหนดมาตรการแก้ไข รอ QA/HR ดำเนินการ · ยังไม่ได้กำหนดวันแล้วเสร็จ
เหตุผลที่จัดระดับเป็น Major (รอ QA ยืนยัน): (1) เป็นการไม่เป็นไปตามกฎหมาย — กฎกระทรวงฯ พ.ศ. 2559 และประกาศกรมสวัสดิการและคุ้มครองแรงงาน ลว. 27 พ.ย. 2560 (2) จุดที่ไม่ผ่านเกือบทั้งหมดเป็นจุดใช้สายตามองเฉพาะจุด ซึ่งเป็นจุดที่พนักงานตรวจพินิจสิ่งแปลกปลอมและข้อบกพร่องของสินค้า แสงไม่พอที่จุดเหล่านี้กระทบความสามารถในการตรวจจับ จึงเป็นประเด็น GHP ไม่ใช่เฉพาะอาชีวอนามัย (3) สัดส่วนที่ไม่ผ่านสูง 12 จาก 13 จุด
ขั้นถัดไป: ขอรายงานหน้า 2–14 จาก สสปท. เพื่อระบุว่าจุดใดบ้างที่ไม่ผ่านและค่าที่วัดได้เท่าใด จึงจะวางแผนปรับปรุงแสงสว่างรายจุดได้'
WHERE id = 'NCR-256908-002';

-- ── 4. Point the two original findings at what actually arrived ─────────────
UPDATE nc_capa SET
  evidenceRefs = '["SLS0001","SLS0002"]',
  notes = COALESCE(notes,'') || 'ปิดเมื่อ 02/08/69 โดยอ้างผลตรวจจากห้องปฏิบัติการ — หลักฐานที่ได้รับคือ AMARC 25-167419 ซึ่งเป็นผลตรวจจุดเวลาเดียวที่อายุ 131 วัน (SLS0002 · สรุป INCONCLUSIVE) ร่วมกับ SLS0001 ที่ยังอยู่ระหว่างศึกษา ⚠ ทั้งสองรายการยังไม่ยืนยันอายุ 12 เดือนบนฉลาก และยังไม่มีการตรวจ ณ ช่วงปลายอายุ ถ้าผู้ตรวจถามว่าอายุบนฉลากอ้างอิงผลใด คำตอบยังไม่สมบูรณ์ — ควรเดินการศึกษาตาม QP-QA-17 ให้ครบก่อนการตรวจกลางเดือนกันยายน',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256905-016';

UPDATE nc_capa SET
  evidenceRefs = '["ENV0001","ENV0002","ENV0003","ENV0004"]',
  notes = COALESCE(notes,'') || 'ปิดเมื่อ 02/08/69 — การตรวจวัดสภาวะการทำงานได้ดำเนินการจริงแล้วโดย สสปท. (หน่วยงานที่ได้รับการรับรอง) เมื่อ 9 มิ.ย. 2569 พร้อมมีแผนตรวจประจำปีรองรับ ข้อบกพร่องเดิม (ไม่ได้ตรวจ) จึงได้รับการแก้ไข ⚠ แต่ผลการตรวจเองไม่ผ่าน 13 จุดจาก 24 จุด — ยกเป็นข้อบกพร่องใหม่ NCR-256908-002 ไม่รวมอยู่ในการปิดใบนี้',
  modified = strftime('%Y-%m-%dT%H:%M:%fZ','now')
WHERE id = 'NCR-256905-018';
