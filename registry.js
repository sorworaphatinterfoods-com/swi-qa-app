/* ============================================================================
 * registry.js — SINGLE SOURCE OF TRUTH for the synced table registry.
 *
 * Loaded by BOTH runtimes from this one physical file:
 *   - Browser  : operations.html via  <script src="./registry.js">
 *   - Worker   : worker.js        via  import './registry.js'
 * It assigns globalThis.SWI_REGISTRY (works in both the browser and the
 * Cloudflare Workers isolate), so there is no ES `export` keyword that would
 * break the classic browser <script> load.
 *
 * Add a synced module ONCE here and everything downstream is derived:
 *   client (operations.html) : SEED keys check + SERVER_TABLE
 *   worker (worker.js)       : TABLES + CLIENT_KEYMAP + DATE_COL
 * No more 5-place manual sync — the drift that kept breaking D1 is gone.
 *
 * Entry shape:
 *   { key, table, prefix, search?, jsonCols?, dateCol? }
 *     key      client-side collection key (DB[key], camelCase)
 *     table    D1 table name (snake_case)
 *     prefix   id prefix for nextId() (e.g. 'SP' -> SP0001)
 *     search   columns the worker LIKE-searches on ?q=
 *     jsonCols columns stored as JSON (serialized on write, parsed on read)
 *     dateCol  date column used for report date-range filtering
 *
 * After editing, run:  node scripts/check-registry.mjs
 * ==========================================================================*/
(function (root) {
  const REGISTRY = [
    // ── Master data ──
    { key:'suppliers',       table:'suppliers',             prefix:'SP',   search:['name','contact','email','materialCode'] },
    { key:'materials',       table:'materials',             prefix:'MT',   search:['name','subCategory','supplier'] },
    { key:'ingredients',     table:'ingredients',           prefix:'PD',   search:['name','category'] },
    { key:'packaging',       table:'packaging',             prefix:'PK',   search:['name'] },
    { key:'chemicals',       table:'chemicals',             prefix:'CM',   search:['name'] },
    { key:'finishedGoods',   table:'finished_goods',        prefix:'FG',   search:['name','type'] },
    { key:'processes',       table:'processes',             prefix:'PC',   search:['name','description','area'] },
    { key:'parameters',      table:'parameters',            prefix:'PR',   search:['name','description','category','spec'] },
    { key:'equipment',       table:'equipment',             prefix:'EQ',   search:['name','type','usage'] },
    { key:'ccps',            table:'ccps',                  prefix:'CCP',  search:['name','processId','criticalLimit'] },
    { key:'processParamMap', table:'process_parameter_map', prefix:'MAP',  search:['processName','parameterId'] },
    { key:'machines',        table:'machines',              prefix:'MC',   search:['name','type','processId'] },

    // ── Transactional ──
    { key:'rmInspections',        table:'rm_inspections',         prefix:'RMI',  search:['supplier','material','lotNo','inspector'], dateCol:'date' },
    { key:'rmReceiving',          table:'rm_receiving',           prefix:'RCV',  search:['supplier','truckPlate','inspector'], jsonCols:['materials'], dateCol:'date' },
    { key:'fgInspections',        table:'fg_inspections',         prefix:'FGI',  search:['product','batch','inspector'], dateCol:'date' },
    { key:'pkgInspections',       table:'pkg_inspections',        prefix:'PKI',  search:['material','inspector'], dateCol:'date' },
    { key:'inprocessInspections', table:'inprocess_inspections',  prefix:'IPI',  search:['productName','batch','line','inspector'], jsonCols:['processes'], dateCol:'date' },
    { key:'transportInspections', table:'transport_inspections',  prefix:'TS',   search:['plateNo','driver','destination','product','invoiceNo','inspector'], jsonCols:['products'], dateCol:'date' },
    { key:'pestControl',          table:'pest_control',           prefix:'PST',  search:['area','inspector'], jsonCols:['points'], dateCol:'date' },
    { key:'haccpRecords',         table:'haccp_records',          prefix:'HC',   search:['ccpName','operator'], dateCol:'timestamp' },
    { key:'ncCapa',               table:'nc_capa',                prefix:'NC',   search:['description','owner','type'], dateCol:'date' },
    { key:'capa',                 table:'capa',                   prefix:'CA',   search:['ncId','rootCause','correctiveAction','owner','capaType','status'], dateCol:'date' },
    { key:'environmental',        table:'environmental',          prefix:'ENV',  search:['area','operator','parameter'], dateCol:'date' },
    { key:'training',             table:'training',               prefix:'TR',   search:['title','trainer','category'], dateCol:'date' },
    { key:'traceability',         table:'traceability',           prefix:'TRC',  search:['batch','product','customer'], dateCol:'date' },
    { key:'complaints',           table:'complaints',             prefix:'CC',   search:['customer','subject','product'], dateCol:'date' },
    { key:'productLabels',        table:'product_labels',         prefix:'LBL',  search:['brand','nameTh','nameEn','fdaNumber'] },
    { key:'lotGenealogy',         table:'lot_genealogy',          prefix:'LG',   search:['fgProduct','fgLot','operator','machine'], jsonCols:['rmLots','ingredientLots','packagingLots','distribution'] },
    { key:'incomingInspection',   table:'incoming_inspections',   prefix:'IQS',  search:['supplierName','truckPlate','inspector'], jsonCols:['items'] },
    { key:'incomingSeasoning',    table:'incoming_seasoning',     prefix:'IQD',  search:['supplierName','truckPlate','inspector'], jsonCols:['items'] },
    { key:'incomingPackaging',    table:'incoming_packaging',     prefix:'IQP',  search:['supplierName','truckPlate','inspector'], jsonCols:['items'] },
    { key:'ipqcChecks',           table:'ipqc_checks',            prefix:'IPQC', search:['process','lot','inspector','product'], jsonCols:['weightSamples','tempSamples'] },
    { key:'ipqcHolds',            table:'inprocess_hold_records', prefix:'HOLD', search:['lotNo','product','reason','issuedBy'] },
    { key:'ipqcDeviations',       table:'inprocess_deviation_logs', prefix:'DEV', search:['lotNo','product','deviationType','description'] },
    // ── Finished Goods Release (FG Release) ──
    { key:'fgLots',               table:'fg_lots',                prefix:'FGL',  search:['fgLot','product','productCode','productionLot','line','status'], dateCol:'productionDate' },
    { key:'fgReleaseInspections', table:'fg_release_inspections', prefix:'FGR',  search:['fgLot','product','productionLot','inspector','overallResult','releaseStatus'], jsonCols:['tempSamples','weightSamples'], dateCol:'inspectDate' },
    { key:'fgHolds',              table:'fg_hold_records',        prefix:'FGH',  search:['fgLot','product','reason','holdBy','status'], dateCol:'holdDate' },
    { key:'fgReleaseDecisions',   table:'fg_release_decisions',   prefix:'FGD',  search:['fgLot','product','decision','decidedBy'], dateCol:'decisionDate' },
    // ── CCP / Metal Detector Verification (the plant's single CCP before packing) ──
    { key:'mdVerifications',      table:'metal_detector_verifications', prefix:'MDV', search:['machine','line','productionLot','product','inspector','overallResult'], dateCol:'verifyDate' },
    { key:'ccpDeviations',        table:'ccp_deviations',         prefix:'CCPD', search:['ccpName','productionLot','product','deviationType','status'], dateCol:'deviationDate' },
    // ── Supplier Approval & Evaluation ──
    { key:'supplierEvaluations',  table:'supplier_evaluations',   prefix:'SEV',  search:['supplier','grade','decision','evaluator'], dateCol:'evalDate' },
    { key:'supplierScars',        table:'supplier_scars',         prefix:'SCAR', search:['supplier','issue','severity','status'], dateCol:'scarDate' },
    { key:'supplierAudits',       table:'supplier_audits',        prefix:'SAU',  search:['supplier','auditType','result','auditor'], dateCol:'auditDate' },
  ];

  // ---- Derived maps (built once, shared by both runtimes) ----
  // client key -> D1 table   (operations SERVER_TABLE, worker CLIENT_KEYMAP)
  const CLIENT_KEYMAP = {};
  // D1 table -> { idPrefix, search, jsonCols? }   (worker TABLES)
  const TABLES = {};
  // D1 table -> date column   (worker DATE_COL, report range filtering)
  const DATE_COL = {};
  for (const r of REGISTRY) {
    CLIENT_KEYMAP[r.key] = r.table;
    const meta = { idPrefix: r.prefix, search: r.search || [] };
    if (r.jsonCols) meta.jsonCols = r.jsonCols;
    TABLES[r.table] = meta;
    if (r.dateCol) DATE_COL[r.table] = r.dateCol;
  }

  root.SWI_REGISTRY = { REGISTRY, CLIENT_KEYMAP, TABLES, DATE_COL };
})(typeof globalThis !== 'undefined' ? globalThis : this);
