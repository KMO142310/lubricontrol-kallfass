/* eslint-disable @typescript-eslint/no-explicit-any, @typescript-eslint/no-unused-vars */
import fs from 'fs';
import path from 'path';

const JSON_FILE = path.join(__dirname, 'machines_data.json');
const SQL_FILE = path.join(__dirname, '../../supabase/migrations/03_seed_machines_data.sql');

const data = JSON.parse(fs.readFileSync(JSON_FILE, 'utf-8'));

// Universal sanitizer: strip ALL markdown, then escape for SQL
const strip = (v: any): string => String(v ?? '').replace(/\*\*/g, '').replace(/\*/g, '').trim();
const esc = (v: any): string => { 
  if (v === null || v === undefined) return 'NULL';
  const s = strip(v);
  if (s === '' || s === 'NULL') return 'NULL';
  return `'${s.replace(/'/g, "''")}'`;
};
const num = (v: any): string => {
  if (v === null || v === undefined) return 'NULL';
  const s = strip(v);
  const n = parseFloat(s);
  return isNaN(n) ? 'NULL' : String(n);
};
const bool = (v: any): string => v ? 'true' : 'false';

const mapFreq = (raw: any): string => {
  const s = strip(raw).toLowerCase();
  if (s.includes('4.000') || s.includes('año') || s.includes('anual')) return 'Anual';
  if (s.includes('3 meses') || s.includes('trimest')) return 'Trimestral';
  if (s.includes('2.800') || s.includes('2800')) return 'c/2800 hrs';
  if (s.includes('llenado') || s.includes('placa')) return 'Según placa';
  return strip(raw);
};

let sql = `-- ==========================================================
-- Seeding 9 Machines and 99 Points from machines_data.json
-- Generated: ${new Date().toISOString()}
-- ==========================================================

`;

for (const machine of data) {
  sql += `-- ${strip(machine.positionCode)} — ${strip(machine.modelName)}\n`;
  sql += `INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, ${esc(machine.positionCode)}, ${esc(machine.modelName)}, ${esc(machine.description)}, ${esc(machine.docReference)}
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = ${esc(machine.positionCode)});\n\n`;

  for (const p of machine.points) {
    // Lubricant lookup
    let lubWhere: string;
    const prod = strip(p.productESMAX);
    if (prod.includes('Aricur') || prod.includes('limpieza')) {
      lubWhere = `brand = 'ESMAX LUBRAX' AND type = 'grease'`;
    } else if (prod.includes('SKF') || prod.includes('LGLT')) {
      lubWhere = `product_name = 'LGLT 2'`;
    } else if (prod.includes('HYDRA XP 32')) {
      lubWhere = `product_name = 'HYDRA XP 32'`;
    } else if (prod.includes('HYDRA XP 68')) {
      lubWhere = `product_name = 'HYDRA XP 68'`;
    } else if (prod.includes('GEAR')) {
      lubWhere = `product_name = 'GEAR 150'`;
    } else if (prod.includes('LITHPLUS')) {
      lubWhere = `product_name = 'LITHPLUS EP 2'`;
    } else if (prod.includes('LITH')) {
      lubWhere = `product_name = 'LITH EP 2'`;
    } else if (prod.includes('GL-5') || prod.includes('80W')) {
      lubWhere = `product_name = 'GL-5 80W/90'`;
    } else {
      lubWhere = `product_name = 'LITH EP 2'`; // safe default
    }

    const cleanFreq = mapFreq(p.frequency);

    sql += `INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = ${esc(machine.positionCode)} LIMIT 1),
  (SELECT id FROM lubricants WHERE ${lubWhere} LIMIT 1),
  (SELECT id FROM frequencies WHERE label = ${esc(cleanFreq)} LIMIT 1),
  ${num(p.itemNumber)}, ${esc(p.description)}, ${esc(p.taskType)},
  ${num(p.numPoints)}, ${num(p.grammage)}, ${num(p.volumeMl)},
  ${bool(p.isManual)}, ${esc(p.note)}
);\n\n`;
  }
}

fs.writeFileSync(SQL_FILE, sql);

// Quick validation: scan the output for any remaining ** characters
const output = fs.readFileSync(SQL_FILE, 'utf-8');
const badLines = output.split('\n').filter((l, i) => l.includes('**') && !l.startsWith('--'));
if (badLines.length > 0) {
  console.error(`❌ ALERTA: Aún hay ${badLines.length} líneas con ** markdown:`);
  badLines.forEach(l => console.error(`  → ${l.trim()}`));
} else {
  console.log(`✅ SQL limpio generado. 0 errores de markdown. Archivo: ${SQL_FILE}`);
}
