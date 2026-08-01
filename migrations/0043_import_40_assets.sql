-- 0043_import_40_assets.sql
-- Import the factory's real 40-asset register from swi-maint-db.maint_assets,
-- the database behind the existing repair app, rather than re-typing it from
-- screenshots. Codes, names, risk levels, owning team and control links all come
-- from that source unchanged.
--
-- id = asset_code (BELT1, MD01, SL1 …) on purpose. Those are the codes on the
-- machines and in the repair app, so a work order for BELT1 means the same thing
-- in both systems. Generated MC0001 keys would have needed a lookup table nobody
-- would maintain.
--
-- ccp_oprp_link arrives as tokens from the maintenance app (CCP001_METAL_DETECTOR,
-- OPRP_TEMP_CONTROL, PRP_EQUIPMENT_SANITATION) that do not match ccps.id here.
-- They are kept verbatim in controlLink; ccpLink stays empty for QA to map, since
-- the one metal detector serves CCP-01 in RTC and CCP-02 in Par-cooked and no
-- single reference can say that.
--
-- The 7 seeded machines (MC001-MC007) carried generic English names nobody uses.
-- MC005 is retired but not deleted: 10 metal detector verifications point at it,
-- and those are CCP records. They are repointed to MD01, the same physical
-- machine under its real code, so the history follows the asset.
--
-- MC005 also sat at status 'Maintenance' while its CCP checks were passing daily.
-- The source register has the detector active; the stale placeholder status goes
-- with the placeholder row.

ALTER TABLE machines ADD COLUMN systemGroup     TEXT;  -- กลุ่มระบบตามทะเบียนซ่อมบำรุง
ALTER TABLE machines ADD COLUMN responsibleTeam TEXT;  -- ทีมที่รับผิดชอบ
ALTER TABLE machines ADD COLUMN controlLink     TEXT;  -- CCP/OPRP/PRP token จากระบบต้นทาง

INSERT OR REPLACE INTO machines
  (id, assetCode, name, type, systemGroup, riskLevel, responsibleTeam, controlLink, backupAvailable, status) VALUES
 -- ── CCP / Foreign Body Control ──────────────────────────────────────────
 ('MD01','MD01','Metal Detector','inspection_machine','CCP / Foreign Body Control','CRITICAL','แผนกซ่อมบำรุง','CCP001_METAL_DETECTOR','no','Active'),
 ('MD01C','MD01C','Metal Detector Controler','inspection_machine','CCP / Foreign Body Control','CRITICAL','แผนกซ่อมบำรุง','CCP001_METAL_DETECTOR','no','Active'),
 -- ── Production Contact / Physical Hazard ────────────────────────────────
 ('BELT1','BELT1','สายพานลำเลียงหมู L','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','yes','Active'),
 ('BELT2','BELT2','สายพานลำเลียงหมู S (สำรอง)','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','yes','Active'),
 ('INP1','INP1','เครื่องป้อนหมูบด 1','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','yes','Active'),
 ('INP2','INP2','เครื่องป้อนหมูบด 2','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','yes','Active'),
 ('MOLD1','MOLD1','เครื่องขึ้นรูปหมูบด L','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','no','Active'),
 ('MOLD2','MOLD2','เครื่องขึ้นรูปหมูบด S','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','no','Active'),
 ('MOLDMB','MOLDMB','เครื่องขึ้นรูปลูกชิ้น','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','no','Active'),
 ('SL1','SL1','เครื่องสไลด์วัตถุดิบ พร้อมใบมีด 1','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','yes','Active'),
 ('SL2','SL2','เครื่องสไลด์วัตถุดิบ พร้อมใบมีด 2','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','yes','Active'),
 ('SL3','SL3','เครื่องสไลด์วัตถุดิบ พร้อมใบมีด 3','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','yes','Active'),
 ('SL4','SL4','เครื่องสไลด์วัตถุดิบ พร้อมใบมีด 4','processing_machine','Production Contact / Physical Hazard','HIGH','แผนกซ่อมบำรุง','OPRP_EQUIPMENT_INTEGRITY','yes','Active'),
 -- ── Temperature Control / Cold Chain ────────────────────────────────────
 ('FZ1','FZ1','ห้องแช่แข็ง FG 1.1','freezing_machine','Temperature Control / Cold Chain','HIGH','แผนกซ่อมบำรุง/ CKY','OPRP_TEMP_CONTROL','no','Active'),
 ('FZ2','FZ2','ห้องแช่แข็ง FG 1','freezing_machine','Temperature Control / Cold Chain','HIGH','แผนกซ่อมบำรุง/ CKY','OPRP_TEMP_CONTROL','no','Active'),
 ('FZ3','FZ3','ห้องแช่แข็ง FG 2','freezing_machine','Temperature Control / Cold Chain','HIGH','แผนกซ่อมบำรุง/ CKY','OPRP_TEMP_CONTROL','no','Active'),
 ('FZ4','FZ4','ห้องแช่แข็ง FG 3','freezing_machine','Temperature Control / Cold Chain','HIGH','แผนกซ่อมบำรุง/ เทอร์โม','OPRP_TEMP_CONTROL','no','Active'),
 ('SF1','SF1','ตู้แช่แข็ง -18 °C ชนิดฝาเปิด (บน)','freezing_machine','Temperature Control / Cold Chain','HIGH','แผนกซ่อมบำรุง','OPRP_TEMP_CONTROL','no','Active'),
 ('TCH1','TCH1','ห้อง RM -6 °C','freezing_machine','Temperature Control / Cold Chain','HIGH','แผนกซ่อมบำรุง/ CKY','OPRP_TEMP_CONTROL','no','Active'),
 ('TCH2','TCH2','ห้องหมัก-ผสม 16 °C','freezing_machine','Temperature Control / Cold Chain','HIGH','แผนกซ่อมบำรุง/ เทอร์โม','OPRP_TEMP_CONTROL','no','Active'),
 ('TCH4','TCH4','ห้องผลิต 16 °C','freezing_machine','Temperature Control / Cold Chain','HIGH','แผนกซ่อมบำรุง/ เทอร์โม','OPRP_TEMP_CONTROL','no','Active'),
 -- ── Packaging Integrity ─────────────────────────────────────────────────
 ('SEAL1','SEAL1','เครื่องซีลถุง 1','packing_machine','Packaging Integrity','HIGH','แผนกซ่อมบำรุง / เอ.ที.แพ็คกิ้ง','OPRP_PACKAGING_INTEGRITY','yes','Active'),
 ('SEAL2','SEAL2','เครื่องซีลถุง 2','packing_machine','Packaging Integrity','HIGH','แผนกซ่อมบำรุง / เอ.ที.แพ็คกิ้ง','OPRP_PACKAGING_INTEGRITY','yes','Active'),
 ('SEAL3','SEAL3','เครื่องซีลพลาสติก Auto ชนิดเท้าเหยียบ','packing_machine','Packaging Integrity','HIGH','แผนกซ่อมบำรุง / เอ.ที.แพ็คกิ้ง','OPRP_PACKAGING_INTEGRITY','no','Active'),
 ('VACUUM1','VACUUM1','เครื่องซีลถุงสุญญากาศ 1 ปั๊ม','packing_machine','Packaging Integrity','HIGH','แผนกซ่อมบำรุง / เอ.ที.แพ็คกิ้ง','OPRP_PACKAGING_INTEGRITY','yes','Active'),
 ('VACUUM1_02','VACUUM1_02','เครื่องซีลถุงสุญญากาศ 1 ปั๊ม (สำรอง)','packing_machine','Packaging Integrity','HIGH','แผนกซ่อมบำรุง / เอ.ที.แพ็คกิ้ง','OPRP_PACKAGING_INTEGRITY','yes','Active'),
 ('VACUUM3','VACUUM3','เครื่องซีลถุงสุญญากาศ 2 ปั๊ม','packing_machine','Packaging Integrity','HIGH','แผนกซ่อมบำรุง / เอ.ที.แพ็คกิ้ง','OPRP_PACKAGING_INTEGRITY','no','Active'),
 -- ── Thermal Process / Utility ───────────────────────────────────────────
 ('GAS1','GAS1','หัวเตาแก๊สแรงดันสูง','cooking_machine','Thermal Process / Utility','HIGH','แผนกซ่อมบำรุง','OPRP_THERMAL_PROCESS','no','Active'),
 ('GAS26','GAS26','ถังแก๊ส 15 ลิตร','cooking_machine','Thermal Process / Utility','HIGH','แผนกซ่อมบำรุง','OPRP_THERMAL_PROCESS','no','Active'),
 ('STEAM1','STEAM1','ตู้นึ่ง ชนิดแรงดันไอน้ำ 1','cooking_machine','Thermal Process / Utility','HIGH','แผนกซ่อมบำรุง','OPRP_THERMAL_PROCESS','yes','Active'),
 ('STEAM2','STEAM2','ตู้นึ่ง ชนิดแรงดันไอน้ำ 2','cooking_machine','Thermal Process / Utility','HIGH','แผนกซ่อมบำรุง','OPRP_THERMAL_PROCESS','yes','Active'),
 -- ── Mixing / Food Contact ───────────────────────────────────────────────
 ('BD1','BD1','เครื่องปั่นเครื่องเทศ 1','processing_machine','Mixing / Food Contact','MEDIUM','แผนกซ่อมบำรุง','PRP_EQUIPMENT_SANITATION','yes','Active'),
 ('BD2','BD2','เครื่องปั่นผสมเครื่องปรุง 2','processing_machine','Mixing / Food Contact','MEDIUM','แผนกซ่อมบำรุง','PRP_EQUIPMENT_SANITATION','yes','Active'),
 ('MIX1','MIX1','เครื่องผสมวัตถุดิบสด 1','processing_machine','Mixing / Food Contact','MEDIUM','แผนกซ่อมบำรุง','PRP_EQUIPMENT_SANITATION','yes','Active'),
 ('MIX2','MIX2','เครื่องผสมวัตถุดิบสด 2 (สำรอง)','processing_machine','Mixing / Food Contact','MEDIUM','แผนกซ่อมบำรุง','PRP_EQUIPMENT_SANITATION','yes','Active'),
 ('MIXMB','MIXMB','เครื่องปั่นผสมลูกชิ้น','processing_machine','Mixing / Food Contact','MEDIUM','แผนกซ่อมบำรุง','PRP_EQUIPMENT_SANITATION','no','Active'),
 ('SS1','SS1','เครื่องยัดไส้กรอก','processing_machine','Mixing / Food Contact','MEDIUM','แผนกซ่อมบำรุง','PRP_EQUIPMENT_SANITATION','no','Active'),
 -- ── Production Equipment / Utility ──────────────────────────────────────
 ('TCH3','TCH3','ห้องพักหมู -4 °C','freezing_machine','Production Equipment','MEDIUM','แผนกซ่อมบำรุง/ เทอร์โม','PRP_EQUIPMENT','no','Active'),
 ('PUMP1','PUMP1','เครื่องปั๊มลม 1','utility','Utility','MEDIUM','แผนกซ่อมบำรุง','PRP_UTILITY','yes','Active'),
 ('PUMP2','PUMP2','เครื่องปั๊มลม 2','utility','Utility','MEDIUM','แผนกซ่อมบำรุง','PRP_UTILITY','yes','Active');

-- The 10 CCP verifications recorded against the placeholder follow the real asset.
UPDATE metal_detector_verifications SET machine='MD01', modified=datetime('now')
 WHERE machine='MC005';

-- Retire the seeded placeholders. Kept, not deleted: they are what earlier records
-- were written against, and a register that quietly loses rows cannot be audited.
-- 'Obsolete', not 'Out of Service': a machine that is down still needs work orders
-- raised against it and must stay pickable. These rows are not assets at all.
UPDATE machines
   SET status='Obsolete',
       notes=COALESCE(notes||' · ','')||'แถวตั้งต้นของระบบ — แทนที่ด้วยทะเบียนจริง 40 เครื่อง (0043)',
       modified=datetime('now')
 WHERE id IN ('MC001','MC002','MC003','MC004','MC005','MC006','MC007');
