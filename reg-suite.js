/* ============================================================================
 * reg-suite.js — the Regulatory / FDA (อย.) module.
 *
 * Lifted out of operations.html when QA asked for the อย. work to live in its
 * own app. Loaded ONLY by regulatory.html; the QA app no longer carries it.
 * Both apps still share registry.js, the same Cloudflare Worker and the same
 * D1 database, so a product registered here is the same row the QA app links
 * to from a label or a traceability record — one copy of the data, two doors
 * into it.
 *
 * The field definitions, validation rules and the dashboard below are the ones
 * that were in service, moved verbatim rather than rewritten, so nothing about
 * how a record behaves changes on the day it moves house.
 * ==========================================================================*/
(function (root) {
'use strict';

// Cross-record lookups: a field that must point at an existing record elsewhere
// rather than hold typed-in text, so the reference cannot drift.
const LK_REGSUB  = [['regSubmissions','id'],['regSubmissions','refNo'],['regSubmissions','resultNumber']];
const LK_FDANO   = [['regProducts','fdaNumber'],['productLabels','fdaNumber']];

// Label-checklist option sets (shared by the regLabels fields)
const LBL_CHK    = [['ok','✅ มี/ถูกต้อง'],['missing','❌ ขาด/ไม่ถูกต้อง']];
const LBL_CHK_NA = [['ok','✅ มี/ถูกต้อง'],['missing','❌ ขาด/ไม่ถูกต้อง'],['na','— ไม่เกี่ยวข้อง']];

const REG_SCHEMA = {
  regProducts: {
    prefix:'RP', label:'ทะเบียนผลิตภัณฑ์', printFn:'printItem',
    cols:['id','fdaNumber','nameTh','foodCategory','licenseStatus','expiryDate'],
    fields:[
      { section:'ข้อมูลผลิตภัณฑ์ (Product)' },
      { k:'product', label:'สินค้า (จาก Master FG)', type:'ref', refKey:'finishedGoods', refLabel:'name' },
      { k:'nameTh', label:'ชื่อผลิตภัณฑ์ (ไทย)', type:'text', required:true },
      { k:'nameEn', label:'ชื่อผลิตภัณฑ์ (อังกฤษ)', type:'text' },
      { k:'brand', label:'แบรนด์/ตรา', type:'text' },
      { k:'foodCategory', label:'ประเภทอาหาร (ตามบัญชี อย.)', type:'select', default:()=>'อาหารแปรรูปบางชนิด', options:[
        ['อาหารแปรรูปบางชนิด','อาหารแปรรูปบางชนิด'],
        ['อาหารในภาชนะบรรจุที่ปิดสนิท','อาหารในภาชนะบรรจุที่ปิดสนิท'],
        ['เนื้อสัตว์แปรรูป','เนื้อสัตว์แปรรูป'],
        ['อาหารพร้อมปรุง','อาหารพร้อมปรุง (Ready-to-Cook)'],
        ['อาหารพร้อมบริโภค','อาหารพร้อมบริโภค (Ready-to-Eat)'],
        ['อื่นๆ','อื่นๆ'] ] },
      { k:'productionMethod', label:'กรรมวิธีการผลิต', type:'select', default:()=>'แช่เยือกแข็ง', options:[
        ['แช่เยือกแข็ง','แช่เยือกแข็ง (Frozen)'],
        ['ทำให้เย็น','ทำให้เย็น (Chilled)'],
        ['ผ่านความร้อน','ผ่านความร้อน / ฆ่าเชื้อ (Cooked/Heat-treated)'],
        ['ทำแห้ง','ทำแห้ง (Dried)'],
        ['รมควัน','รมควัน (Smoked)'],
        ['หมัก/ดอง','หมัก / ดอง (Fermented)'],
        ['อื่นๆ','อื่นๆ'] ] },
      { section:'สูตรส่วนประกอบ (ร้อยละของน้ำหนัก · รวม 100%) + แหล่งที่มาวัตถุดิบ' },
      { k:'composition', label:'สูตรส่วนประกอบ', type:'list', addLabel:'+ เพิ่มส่วนประกอบ', default:()=>[{}], sub:[
        { k:'name',       label:'วัตถุดิบ/ส่วนประกอบ' },
        { k:'percent',    label:'ร้อยละ (%)', type:'number', w:'90px' },
        { k:'sourceType', label:'แหล่งที่มา', type:'select', w:'130px', options:[['FDA','เลข อย.'],['COA','COA'],['SPEC','Specification'],['OTHER','อื่นๆ']] },
        { k:'sourceRef',  label:'อ้างอิง (เลข อย./COA/Spec)' }
      ]},
      { k:'compositionNote', label:'หมายเหตุสูตร (กรณีวัตถุดิบไม่มีเลข อย. ให้ใช้ COA / Specification)', type:'textarea' },
      { section:'การขึ้นทะเบียน (อย. / FDA)' },
      { k:'fdaNumber', label:'เลขสารบบอาหาร 13 หลัก', type:'text', placeholder:'xx-x-xxxxx-x-xxxx' },
      { k:'registrationType', label:'ประเภทการขึ้นทะเบียน', type:'select', options:[
        ['จดทะเบียนอาหาร','จดทะเบียนอาหาร (สบ.5)'],
        ['แจ้งรายละเอียดอาหาร','แจ้งรายละเอียดอาหาร (สบ.6)'],
        ['ขออนุญาตใช้ฉลาก','ขออนุญาตใช้ฉลากอาหาร (สบ.3/สบ.7)'] ] },
      { k:'licenseStatus', label:'สถานะใบอนุญาต', type:'select', required:true, default:()=>'Pending', options:[
        ['Registered','✅ ขึ้นทะเบียนแล้ว (Registered)'],
        ['Pending','⏳ รอดำเนินการ (Pending)'],
        ['Expired','⛔ หมดอายุ (Expired)'],
        ['Suspended','🛑 ถูกระงับ (Suspended)'] ] },
      { k:'approvedDate', label:'วันที่อนุมัติ/ขึ้นทะเบียน', type:'date' },
      { k:'expiryDate', label:'วันหมดอายุใบอนุญาต (ถ้ามี)', type:'date' },
      { section:'หน่วยงานกำกับอื่น & ส่งออก' },
      { k:'dldEstablishmentNo', label:'เลขทะเบียนโรงงาน กรมปศุสัตว์', type:'text', placeholder:'Establishment No.' },
      { k:'exportEligible', label:'มีสิทธิ์ส่งออก', type:'select', options:[['no','ไม่'],['yes','ใช่']] },
      { k:'exportCountries', label:'ประเทศที่ส่งออก', type:'text' },
      { k:'halalCert', label:'มีใบรับรองฮาลาล', type:'select', options:[['no','ไม่'],['yes','ใช่']] },
      { k:'halalExpiry', label:'วันหมดอายุฮาลาล', type:'date' },
      { section:'เอกสารอ้างอิง' },
      { k:'specSheetRef', label:'อ้างอิงเอกสารข้อกำหนด (Spec Sheet)', type:'text' },
      { k:'notes', label:'หมายเหตุ', type:'textarea' }
    ],
    // No "Registered" without a real serial number (rule: no fake compliance status).
    // And the declared formula must total 100% by weight (FDA requirement).
    validate:(rec)=>{
      if (rec.licenseStatus==='Registered' && !String(rec.fdaNumber||'').trim())
        return 'ตั้งสถานะ "ขึ้นทะเบียนแล้ว" ไม่ได้: ต้องกรอกเลขสารบบอาหาร (อย.) ก่อน';
      const comp = (rec.composition||[]).filter(c => c && (c.name||c.percent!=null&&c.percent!==''));
      if (comp.length) {
        const total = comp.reduce((a,c)=>a + (parseFloat(c.percent)||0), 0);
        if (Math.abs(total - 100) > 0.5)
          return `สูตรส่วนประกอบต้องรวมเป็น 100% — ขณะนี้รวมได้ ${total.toFixed(1)}% (ปรับให้ครบ 100 ก่อนบันทึก)`;
      }
      return null;
    }
  },

  regAdditives: {
    prefix:'RAD', label:'วัตถุเจือปนอาหาร', printFn:'printItem',
    cols:['id','product','additiveName','insNumber','usedLevel','maxLevel','result'],
    fields:[
      { section:'ผลิตภัณฑ์ & วัตถุเจือปน' },
      { k:'product', label:'ผลิตภัณฑ์ (ทะเบียน อย.)', type:'ref', refKey:'regProducts', refLabel:'nameTh', required:true },
      { k:'additiveName', label:'ชื่อวัตถุเจือปนอาหาร', type:'text', required:true, placeholder:'เช่น โซเดียมไนไตรต์' },
      { k:'insNumber', label:'เลข INS', type:'text', placeholder:'เช่น INS 250' },
      { k:'functionClass', label:'หน้าที่ (Function Class)', type:'select', options:[
        ['วัตถุกันเสีย','วัตถุกันเสีย (Preservative)'],
        ['สารควบคุมความเป็นกรด','สารควบคุมความเป็นกรด'],
        ['สารให้ความคงตัว','สารให้ความคงตัว/ความข้นหนืด'],
        ['อิมัลซิไฟเออร์','อิมัลซิไฟเออร์'],
        ['วัตถุแต่งกลิ่นรส','วัตถุแต่งกลิ่นรส'],
        ['สารกันการจับตัวเป็นก้อน','สารกันการจับตัวเป็นก้อน'],
        ['สี','สีผสมอาหาร'],
        ['อื่นๆ','อื่นๆ'] ] },
      { section:'เกณฑ์ & การใช้จริง' },
      { k:'limitBasis', label:'เกณฑ์การใช้', type:'select', required:true, default:()=>'ML', options:[
        ['ML','มีปริมาณสูงสุดกำหนด (Maximum Level)'],
        ['GMP','ปริมาณที่เหมาะสมตาม GMP (Quantum Satis)'] ] },
      { k:'maxLevel', label:'ปริมาณสูงสุดที่อนุญาต (ML)', type:'text', placeholder:'เช่น 80' },
      { k:'usedLevel', label:'ปริมาณที่ใช้จริง', type:'text', placeholder:'เช่น 60' },
      { k:'unit', label:'หน่วย', type:'text', default:()=>'mg/kg' },
      { k:'adi', label:'ADI (ค่าความปลอดภัย)', type:'text' },
      { section:'ผลการประเมิน' },
      { k:'result', label:'ผลการประเมิน', type:'select', required:true, options:[
        ['PASS','✅ ผ่านเกณฑ์ (Compliant)'],
        ['OVER_LIMIT','❌ เกินเกณฑ์ ML (Over Limit)'],
        ['NOT_PERMITTED','🛑 ไม่อนุญาตให้ใช้ในอาหารนี้'] ] },
      { k:'assessor', label:'ผู้ประเมิน (RA/QA)', type:'text' },
      { k:'notes', label:'หมายเหตุ', type:'textarea' }
    ],
    // Cannot mark PASS when the used level exceeds the declared Maximum Level.
    validate:(rec)=>{
      if (rec.result==='PASS' && rec.limitBasis==='ML') {
        const mx=parseFloat(rec.maxLevel), us=parseFloat(rec.usedLevel);
        if (!isNaN(mx) && !isNaN(us) && us>mx)
          return `ตั้งผล "ผ่านเกณฑ์" ไม่ได้: ปริมาณที่ใช้ (${us}) เกินเกณฑ์สูงสุด (${mx} ${rec.unit||'mg/kg'})`;
      }
      return null;
    },
    // Over-limit / not-permitted additive = compliance NC (auto).
    onFail:(rec)=>{
      if (rec.result==='OVER_LIMIT' || rec.result==='NOT_PERMITTED') {
        const sev = rec.result==='NOT_PERMITTED' ? 'Critical' : 'Major';
        const desc = `วัตถุเจือปนไม่เป็นไปตามข้อกำหนด — ${rec.additiveName||''} ${rec.insNumber||''} (${rec.result==='NOT_PERMITTED'?'ไม่อนุญาตให้ใช้':'ใช้เกินเกณฑ์ ML '+(rec.usedLevel||'')+'>'+(rec.maxLevel||'')+' '+(rec.unit||'')})`;
        rec.ncRef = regRaiseNc(rec, 'Regulatory', desc, sev, rec.assessor);
      }
    }
  },

  regLabels: {
    prefix:'RLB', label:'ตรวจฉลาก', printFn:'printItem',
    cols:['id','product','labelVersion','checkDate','result'],
    fields:[
      { section:'ข้อมูลการตรวจฉลาก' },
      { k:'product', label:'ผลิตภัณฑ์ (ทะเบียน อย.)', type:'ref', refKey:'regProducts', refLabel:'nameTh', required:true },
      { k:'labelVersion', label:'เวอร์ชันฉลาก/Artwork Rev', type:'text', placeholder:'เช่น Rev 03' },
      { k:'checkDate', label:'วันที่ตรวจ', type:'date', required:true, default:()=>nowISO().slice(0,10) },
      { k:'inspector', label:'ผู้ตรวจ', type:'text' },
      { section:'องค์ประกอบฉลากบังคับ (ประกาศฉลากอาหาร)' },
      { k:'elName', label:'1. ชื่ออาหาร', type:'select', options:LBL_CHK, default:()=>'ok' },
      { k:'elFdaNo', label:'2. เลขสารบบอาหาร (อย.)', type:'select', options:LBL_CHK, default:()=>'ok' },
      { k:'elIngredients', label:'3. ส่วนประกอบเรียงตาม % จากมากไปน้อย', type:'select', options:LBL_CHK, default:()=>'ok' },
      { k:'elAllergen', label:'4. ข้อมูลสำหรับผู้แพ้อาหาร', type:'select', options:LBL_CHK, default:()=>'ok' },
      { k:'elAdditive', label:'5. วัตถุเจือปนอาหาร (ชื่อ/หน้าที่/INS)', type:'select', options:LBL_CHK, default:()=>'ok' },
      { k:'elNetWeight', label:'6. น้ำหนัก/ปริมาตรสุทธิ', type:'select', options:LBL_CHK, default:()=>'ok' },
      { k:'elMfgExp', label:'7. วันเดือนปีที่ผลิต/หมดอายุ', type:'select', options:LBL_CHK, default:()=>'ok' },
      { k:'elStorage', label:'8. คำแนะนำการเก็บรักษา', type:'select', options:LBL_CHK, default:()=>'ok' },
      { k:'elManufacturer', label:'9. ชื่อ-ที่อยู่ผู้ผลิต', type:'select', options:LBL_CHK, default:()=>'ok' },
      { k:'elNutrition', label:'10. ฉลากโภชนาการ/GDA (ถ้าต้องมี)', type:'select', options:LBL_CHK_NA, default:()=>'na' },
      { k:'elBarcode', label:'11. บาร์โค้ด', type:'select', options:LBL_CHK_NA, default:()=>'ok' },
      { k:'elWarning', label:'12. คำเตือน (เช่น ต้องปรุงสุกก่อนบริโภค)', type:'select', options:LBL_CHK_NA, default:()=>'ok' },
      { section:'สรุปผล' },
      { k:'result', label:'ผลการตรวจฉลาก', type:'select', required:true, options:[['PASS','✅ ผ่าน (Compliant)'],['FAIL','❌ ไม่ผ่าน (มีองค์ประกอบขาด/ผิด)']] },
      { k:'correctiveAction', label:'การแก้ไข (ถ้าไม่ผ่าน)', type:'textarea' },
      { k:'notes', label:'หมายเหตุ', type:'textarea' }
    ],
    // No fake pass: cannot mark PASS while any mandatory element is missing.
    validate:(rec)=>{
      const mand = ['elName','elFdaNo','elIngredients','elAllergen','elAdditive','elNetWeight','elMfgExp','elStorage','elManufacturer'];
      const missing = mand.filter(k => rec[k]==='missing');
      if (rec.result==='PASS' && missing.length)
        return 'ตั้งผล "ผ่าน" ไม่ได้: ยังมีองค์ประกอบฉลากบังคับที่ขาด/ไม่ถูกต้อง ('+missing.length+' รายการ)';
      return null;
    },
    onFail:(rec)=>{
      if (rec.result==='FAIL')
        rec.ncRef = regRaiseNc(rec, 'Regulatory', 'ฉลากไม่เป็นไปตามข้อกำหนด — '+(rec.labelVersion||'')+' (ผลิตภัณฑ์ '+(_regProdName(rec.product)||rec.product||'')+')', 'Major', rec.inspector);
    }
  },

  regSubmissions: {
    prefix:'RSB', label:'คำขอ อย.', printFn:'printItem',
    cols:['id','submissionType','product','refNo','status','licenseExpiry'],
    fields:[
      { section:'คำขอ (Submission)' },
      { k:'submissionType', label:'ประเภทคำขอ', type:'select', required:true, options:[
        ['จดทะเบียนอาหารใหม่','จดทะเบียนอาหารใหม่'],
        ['แจ้งรายละเอียดอาหาร','แจ้งรายละเอียดอาหาร'],
        ['ขอใช้ฉลาก','ขออนุญาตใช้ฉลากอาหาร'],
        ['ต่ออายุใบอนุญาต','ต่ออายุใบอนุญาต'],
        ['แก้ไขทะเบียน','แก้ไขรายการทะเบียน'],
        ['ขออนุญาตผลิต','ขออนุญาตผลิต (อ.2)'] ] },
      { k:'product', label:'ผลิตภัณฑ์ (ถ้าระบุได้)', type:'ref', refKey:'regProducts', refLabel:'nameTh' },
      { k:'refNo', label:'เลขที่คำขอ / e-Submission', type:'text' },
      { k:'authority', label:'หน่วยงาน', type:'select', default:()=>'อย.', options:[['อย.','อย. (FDA)'],['กรมปศุสัตว์','กรมปศุสัตว์ (DLD)'],['อื่นๆ','อื่นๆ']] },
      { section:'สถานะการดำเนินการ' },
      { k:'status', label:'สถานะ', type:'select', required:true, default:()=>'Preparing', options:[
        ['Preparing','เตรียมเอกสาร'],
        ['Submitted','ยื่นแล้ว'],
        ['Under Review','ระหว่างพิจารณา'],
        ['Info Requested','ขอข้อมูลเพิ่มเติม'],
        ['Approved','อนุมัติแล้ว'],
        ['Rejected','ไม่อนุมัติ'] ] },
      { k:'submitDate', label:'วันที่ยื่น', type:'date' },
      { k:'approvedDate', label:'วันที่อนุมัติ', type:'date' },
      { k:'resultNumber', label:'เลขที่ได้รับ (เช่น เลขสารบบ)', type:'text' },
      { k:'licenseExpiry', label:'วันหมดอายุใบอนุญาต (ถ้ามี)', type:'date' },
      { k:'owner', label:'ผู้รับผิดชอบ (RA/DCC)', type:'text' },
      { section:'เอกสารแนบ & หมายเหตุ' },
      { k:'docsAttached', label:'เอกสารแนบ', type:'textarea', placeholder:'สูตร, ฉลาก, ผลวิเคราะห์, GMP ...' },
      { k:'notes', label:'หมายเหตุ', type:'textarea' }
    ],
    // Approved requires the resulting serial/number to be recorded.
    validate:(rec)=>{
      if (rec.status==='Approved' && !String(rec.resultNumber||'').trim())
        return 'ตั้งสถานะ "อนุมัติแล้ว" ไม่ได้: ต้องกรอกเลขที่ได้รับ (เช่น เลขสารบบ) ก่อน';
      return null;
    }
  },

  regChanges: {
    prefix:'RCH', label:'ควบคุมการเปลี่ยนแปลง (RA)', printFn:'printItem',
    cols:['id','product','changeType','notifyRequired','status'],
    fields:[
      { section:'รายละเอียดการเปลี่ยนแปลง' },
      { k:'product', label:'ผลิตภัณฑ์ (ทะเบียน อย.)', type:'ref', refKey:'regProducts', refLabel:'nameTh', required:true },
      { k:'changeType', label:'ประเภทการเปลี่ยนแปลง', type:'select', required:true, options:[
        ['สูตร/ส่วนประกอบ','สูตร/ส่วนประกอบ (Formula)'],
        ['ฉลาก','ฉลาก (Label)'],
        ['บรรจุภัณฑ์','บรรจุภัณฑ์ (Packaging)'],
        ['วัตถุเจือปน','วัตถุเจือปนอาหาร (Additive)'],
        ['กระบวนการผลิต','กระบวนการผลิต (Process)'],
        ['ชื่อ/แบรนด์','ชื่อ/แบรนด์ (Name/Brand)'],
        ['สถานที่ผลิต','สถานที่ผลิต (Site)'] ] },
      { k:'description', label:'รายละเอียด', type:'textarea', required:true },
      { k:'requestedBy', label:'ผู้ร้องขอ', type:'text' },
      { k:'requestDate', label:'วันที่ร้องขอ', type:'date', default:()=>nowISO().slice(0,10) },
      { section:'การประเมินผลกระทบทางกฎหมาย (Regulatory Impact)' },
      { k:'affectsLabel', label:'กระทบฉลาก', type:'select', options:[['no','ไม่'],['yes','ใช่']] },
      { k:'affectsRegistration', label:'กระทบทะเบียน อย.', type:'select', options:[['no','ไม่'],['yes','ใช่']] },
      { k:'notifyRequired', label:'ต้องแจ้ง/ยื่น อย. หรือไม่', type:'select', required:true, default:()=>'กำลังประเมิน', options:[
        ['ต้องแจ้ง อย.','ต้องแจ้ง อย.'],
        ['ต้องยื่นแก้ทะเบียน','ต้องยื่นแก้ทะเบียน'],
        ['ไม่ต้องแจ้ง','ไม่ต้องแจ้ง (ภายใน)'],
        ['กำลังประเมิน','กำลังประเมิน'] ] },
      { k:'linkedSubmissionRef', label:'อ้างอิงเลขที่คำขอ (Submission)', type:'lookup', from:LK_REGSUB },
      { section:'การอนุมัติ' },
      { k:'assessedBy', label:'ผู้ประเมิน (RA/QA)', type:'text' },
      { k:'status', label:'สถานะ', type:'select', required:true, default:()=>'Open', options:[
        ['Open','เปิด'],
        ['Under Assessment','กำลังประเมิน'],
        ['Approved','อนุมัติ'],
        ['Implemented','ดำเนินการแล้ว'],
        ['Rejected','ไม่อนุมัติ'] ] },
      { k:'approvedBy', label:'ผู้อนุมัติ', type:'text' },
      { k:'effectiveDate', label:'วันที่มีผล', type:'date' },
      { k:'notes', label:'หมายเหตุ', type:'textarea' }
    ],
    // Cannot implement a change that requires FDA notification without a linked submission.
    validate:(rec)=>{
      const needsSub = rec.notifyRequired==='ต้องแจ้ง อย.' || rec.notifyRequired==='ต้องยื่นแก้ทะเบียน';
      const closing = rec.status==='Approved' || rec.status==='Implemented';
      if (needsSub && closing && !String(rec.linkedSubmissionRef||'').trim())
        return 'อนุมัติ/ดำเนินการไม่ได้: การเปลี่ยนแปลงนี้ต้องแจ้ง/ยื่น อย. — ต้องอ้างอิงเลขที่คำขอ (Submission) ก่อน';
      return null;
    }
  }
};

/* ---- pages this app serves ---- */
const REG_PAGES = {
  regDashboard:   { title: 'Regulatory / FDA (อย.) Dashboard', subtitle: 'ภาพรวมการขึ้นทะเบียน — ต่ออายุใบอนุญาต / คำขอ อย. / ฉลาก / วัตถุเจือปน / การเปลี่ยนแปลง', render: () => renderRegDashboard() },
  regProducts:    { title: 'ทะเบียนผลิตภัณฑ์ (อย.)', subtitle: 'Product Regulatory Master — เลขสารบบอาหาร / สถานะใบอนุญาต / ต่ออายุ / ส่งออก', render: () => renderTable('regProducts') },
  regAdditives:   { title: 'วัตถุเจือปนอาหาร (Additive Compliance)', subtitle: 'INS / ปริมาณสูงสุด (ML) / ADI — เกินเกณฑ์หรือต้องห้าม → auto NC', render: () => renderTable('regAdditives') },
  regLabels:      { title: 'ตรวจฉลาก (Label Compliance)', subtitle: 'Checklist องค์ประกอบฉลากบังคับตามประกาศฉลากอาหาร — ไม่ผ่าน → auto NC', render: () => renderTable('regLabels') },
  regSubmissions: { title: 'ยื่น/ต่ออายุ อย. (FDA Submission & License)', subtitle: 'คำขอ/ต่ออายุ + workflow + วันหมดอายุใบอนุญาต (แจ้งเตือนต่ออายุ)', render: () => renderTable('regSubmissions') },
  regChanges:     { title: 'ควบคุมการเปลี่ยนแปลง (Regulatory Change Control)', subtitle: 'ประเมินผลกระทบทางกฎหมาย — เปลี่ยนสูตร/ฉลาก/บรรจุ ต้องแจ้ง อย. หรือไม่', render: () => renderTable('regChanges') }
};
// ฉลากสินค้า (productLabels) ยังอยู่ในระบบ QA เพราะผูกกับการพิมพ์ฉลากที่นั่น
// ลิงก์ข้ามแอปแทนการย้าย — ข้อมูลอยู่ฐานเดียวกัน เปิดจากที่ไหนก็เป็นแถวเดียวกัน
const QA_APP_LINKS = [['productLabels','🖨 ฉลาก/พิมพ์ยื่น อย. (อยู่ในระบบ QA)']];

/* ---- helpers + dashboard (moved verbatim) ---- */
function regRaiseNc(rec, type, desc, severity, owner) {
  const ncId = nextId('NC','ncCapa', rec.date);
  addNc({
    id: ncId, date: rec.checkDate || rec.requestDate || nowISO().slice(0,10), type: type || 'Regulatory',
    description: desc, source: rec.id || '', status: 'Open', severity: severity || 'Major',
    rootCause: '', correctiveAction: rec.correctiveAction || '', preventiveAction: '',
    dueDate: '', owner: owner || rec.assessor || rec.inspector || '', created: nowISO()
  });
  toast('ไม่เป็นไปตามข้อกำหนดกฎหมาย — สร้าง NC อัตโนมัติ', 'error');
  return ncId;
}
function _regProdName(id) {
  if (!id) return '';
  const p = (DB.regProducts||[]).find(x => x.id === id);
  return p ? (p.nameTh || p.nameEn || p.id) : id;
}
function renderRegDashboard() {
  const pc = document.getElementById('pageContent');
  if (!pc) return;
  const prods = (DB.regProducts||[]), subs = (DB.regSubmissions||[]);
  const adds = (DB.regAdditives||[]), labels = (DB.regLabels||[]), changes = (DB.regChanges||[]);

  const registered = prods.filter(p => p.licenseStatus==='Registered').length;
  const openSubs = subs.filter(s => !['Approved','Rejected'].includes(s.status)).length;
  const addViol = adds.filter(a => a.result==='OVER_LIMIT' || a.result==='NOT_PERMITTED');
  const labelFail = labels.filter(l => l.result==='FAIL');
  const openChanges = changes.filter(c => ['Open','Under Assessment'].includes(c.status));

  // Expiry monitor — reg_products.expiryDate + reg_submissions.licenseExpiry within 90 days (or past)
  const expRows = [];
  prods.forEach(p => { const du=_daysUntil(p.expiryDate); if (du!==null && du<=90) expRows.push({ page:'regProducts', id:p.id, name:(p.nameTh||p.id), lbl:'ใบอนุญาตผลิตภัณฑ์', date:p.expiryDate, du }); });
  prods.forEach(p => { const du=_daysUntil(p.halalExpiry); if (du!==null && du<=90) expRows.push({ page:'regProducts', id:p.id, name:(p.nameTh||p.id), lbl:'ฮาลาล', date:p.halalExpiry, du }); });
  subs.forEach(s => { const du=_daysUntil(s.licenseExpiry); if (du!==null && du<=90) expRows.push({ page:'regSubmissions', id:s.id, name:(_regProdName(s.product)||s.refNo||s.id), lbl:s.submissionType||'ใบอนุญาต', date:s.licenseExpiry, du }); });
  expRows.sort((a,b) => a.du - b.du);
  const expiredN = expRows.filter(r => r.du < 0).length;

  const kpis = [
    { icon:'✅', val: registered, label:'ผลิตภัณฑ์ขึ้นทะเบียนแล้ว', bg:'bg-green-50', color:'text-green-700', page:'regProducts' },
    { icon:'⏳', val: expRows.length, label:'ใบอนุญาตใกล้/หมดอายุ (≤90 วัน)', bg:expRows.length?'bg-amber-50':'bg-slate-50', color:expRows.length?'text-amber-700':'text-slate-600' },
    { icon:'📨', val: openSubs, label:'คำขอ อย. ที่ยังไม่จบ', bg:'bg-blue-50', color:'text-blue-700', page:'regSubmissions' },
    { icon:'⚗️', val: addViol.length, label:'วัตถุเจือปนเกิน/ต้องห้าม', bg:addViol.length?'bg-red-50':'bg-slate-50', color:addViol.length?'text-red-700':'text-slate-600', page:'regAdditives' },
    { icon:'🏷️', val: labelFail.length, label:'ฉลากไม่ผ่าน', bg:labelFail.length?'bg-red-50':'bg-slate-50', color:labelFail.length?'text-red-700':'text-slate-600', page:'regLabels' },
    { icon:'🔁', val: openChanges.length, label:'การเปลี่ยนแปลงรอประเมิน', bg:openChanges.length?'bg-amber-50':'bg-slate-50', color:openChanges.length?'text-amber-700':'text-slate-600', page:'regChanges' }
  ];
  let html = '<div class="grid grid-cols-2 md:grid-cols-3 gap-3 mb-5">';
  kpis.forEach(k => { html += `<div class="rounded-xl border p-3 flex flex-col items-center gap-1 ${k.bg} ${k.page?'cursor-pointer hover:shadow-sm':''}" ${k.page?`onclick="navigateTo('${k.page}')"`:''}>
    <span class="text-xl">${k.icon}</span><span class="text-2xl font-bold ${k.color}">${k.val}</span>
    <span class="text-xs text-center text-slate-500">${k.label}</span></div>`; });
  html += '</div>';

  // Expiry / renewal monitor
  html += '<div class="rounded-xl border border-slate-200 overflow-hidden mb-4">';
  html += `<div class="px-4 py-2 bg-slate-50 border-b text-xs font-semibold text-slate-600">📆 การต่ออายุใบอนุญาต (≤90 วัน หรือหมดอายุแล้ว)${expiredN?` — <span class="text-red-600 font-bold">หมดอายุแล้ว ${expiredN}</span>`:''}</div>`;
  if (!expRows.length) {
    html += '<div class="px-4 py-6 text-center text-xs text-slate-400">ไม่มีใบอนุญาตใกล้หมดอายุ</div>';
  } else {
    html += '<table class="w-full text-xs"><thead><tr class="bg-slate-50 text-slate-500">';
    ['ผลิตภัณฑ์/คำขอ','ประเภท','วันหมดอายุ','คงเหลือ',''].forEach(h=>html+=`<th class="px-3 py-2 text-left font-medium">${h}</th>`);
    html += '</tr></thead><tbody>';
    expRows.slice(0,15).forEach(r => {
      const tag = r.du<0 ? `<span class="text-red-600 font-bold">หมดอายุ ${Math.abs(r.du)} วัน</span>` : (r.du<=30 ? `<span class="text-red-600 font-semibold">${r.du} วัน</span>` : `<span class="text-amber-600">${r.du} วัน</span>`);
      html += `<tr class="border-t border-slate-100 hover:bg-slate-50">
        <td class="px-3 py-2 font-medium">${r.name}</td>
        <td class="px-3 py-2 text-slate-500">${r.lbl}</td>
        <td class="px-3 py-2">${r.date||'-'}</td>
        <td class="px-3 py-2">${tag}</td>
        <td class="px-3 py-2 text-right"><button class="px-2 py-0.5 rounded-lg border border-brand text-brand" onclick="viewItem('${r.page}','${r.id}')">ดู →</button></td>
      </tr>`;
    });
    html += '</tbody></table>';
  }
  html += '</div>';

  // Compliance issues drill-down (additive violations + label fails)
  if (addViol.length || labelFail.length) {
    html += '<div class="rounded-xl border border-red-200 overflow-hidden mb-4">';
    html += '<div class="px-4 py-2 bg-red-50 border-b border-red-200 text-xs font-semibold text-red-700">⚠️ รายการไม่เป็นไปตามข้อกำหนด (ออก NC อัตโนมัติแล้ว)</div>';
    html += '<div class="divide-y divide-red-100">';
    addViol.slice(0,8).forEach(a => { html += `<div class="px-4 py-2 text-xs flex items-center justify-between cursor-pointer hover:bg-red-50/50" onclick="viewItem('regAdditives','${a.id}')">
      <span>⚗️ ${a.additiveName||''} ${a.insNumber||''} — ${_regProdName(a.product)} <span class="text-red-600 font-semibold">${a.result==='NOT_PERMITTED'?'ต้องห้าม':'เกินเกณฑ์'}</span></span><span class="text-brand">ดู →</span></div>`; });
    labelFail.slice(0,8).forEach(l => { html += `<div class="px-4 py-2 text-xs flex items-center justify-between cursor-pointer hover:bg-red-50/50" onclick="viewItem('regLabels','${l.id}')">
      <span>🏷️ ฉลากไม่ผ่าน — ${_regProdName(l.product)} ${l.labelVersion||''}</span><span class="text-brand">ดู →</span></div>`; });
    html += '</div></div>';
  }

  // Quick links
  html += '<div class="grid grid-cols-2 md:grid-cols-3 gap-2">';
  [['regProducts','🧾 ทะเบียนผลิตภัณฑ์'],['regAdditives','⚗️ วัตถุเจือปน (INS/ML)'],['regLabels','🏷️ ตรวจฉลาก'],['regSubmissions','📨 ยื่น/ต่ออายุ อย.'],['regChanges','🔁 ควบคุมการเปลี่ยนแปลง']].forEach(([pg,lbl]) => {
    html += `<button class="rounded-xl border border-slate-200 px-3 py-2 text-xs text-left hover:border-brand hover:text-brand" onclick="navigateTo('${pg}')">${lbl} →</button>`;
  });
  QA_APP_LINKS.forEach(([pg,lbl]) => {
    html += `<a href="./operations.html#${pg}" class="rounded-xl border border-dashed border-slate-300 px-3 py-2 text-xs text-left hover:border-brand hover:text-brand block">${lbl} →</a>`;
  });
  html += '</div>';
  pc.innerHTML = html;
}

root.SWI_REG = { REG_SCHEMA, REG_PAGES, QA_APP_LINKS, LBL_CHK, LBL_CHK_NA,
                 renderRegDashboard, regRaiseNc, _regProdName };
})(typeof globalThis !== 'undefined' ? globalThis : this);
