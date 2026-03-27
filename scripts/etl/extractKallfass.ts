/* eslint-disable @typescript-eslint/no-explicit-any */
import fs from 'fs';
import path from 'path';

// Parse the markdown line by line
const MOCK_FILE = path.join(__dirname, '../../../PLAN_MAESTRO_LUBRICACION_KALLFASS.md');
const OUT_FILE = path.join(__dirname, 'machines_data.json');

async function main() {
  const content = fs.readFileSync(MOCK_FILE, 'utf-8');
  const lines = content.split('\n');

  const machines: any[] = [];
  let currentMachine: any = null;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();

    // Match Machine Header: ### Pos 115 — VFW-600 (Alimentador de Trozos) | Doc. 520379
    const machineMatch = line.match(/^### Pos (\d+) — ([\w-]+)\s*\(([^)]+)\)\s*\|\s*Doc\.\s*(.+)$/);
    if (machineMatch) {
      if (currentMachine) machines.push(currentMachine);
      currentMachine = {
        positionCode: `Pos ${machineMatch[1]}`,
        modelName: machineMatch[2],
        description: machineMatch[3],
        docReference: machineMatch[4],
        points: []
      };
      continue;
    }

    // Match alternative format without doc reference: ### Pos 230 — Transportador
    const simpleMatch = line.match(/^### Pos (\d+) — ([^-]+)\s*-\s*(.+)$/);
    if (!machineMatch && simpleMatch && !line.includes('| Doc.')) {
        if (currentMachine) machines.push(currentMachine);
        currentMachine = {
          positionCode: `Pos ${simpleMatch[1]}`,
          modelName: simpleMatch[2].trim(),
          description: simpleMatch[3].trim(),
          docReference: null,
          points: []
        };
        continue;
    }
    
    // Fallback for general headings
    if (line.startsWith('### Pos ')) {
       const parts = line.replace('###', '').split('—').map(s => s.trim());
       if (parts.length >= 2 && !machineMatch && !simpleMatch) {
         if (currentMachine) machines.push(currentMachine);
         currentMachine = {
             positionCode: parts[0],
             modelName: parts[1].split('(')[0]?.trim() || parts[1],
             description: line,
             points: []
         };
       }
    }

    if (!currentMachine) continue;

    // Detect Multiply sides marker
    if (line.includes('Multiplicar ×2 para la máquina completa')) {
      currentMachine.multiplySides = 2;
    }

    // Match Table Row
    // | 1x/semana | Bloque corredera (plinto) | 4 | 4 | Group V | LUBRAX LITH EP 2 |
    if (line.startsWith('|') && !line.includes('|---') && !line.includes('| Frecuencia |')) {
      const cols = line.split('|').map(s => s.trim()).filter(s => s.length > 0);
      
      if (cols.length >= 6) {
        const freq = cols[0];
        const desc = cols[1];
        const itemNumber = parseInt(cols[2], 10) || cols[2];
        const numPoints = parseInt(cols[3], 10) || 1;
        const group = cols[4];
        const product = cols[5];
        const note = cols[6] || '';

        // Determine if manual
        const isManual = note.includes('(M)') || product.includes('Manual (M)') || freq.toLowerCase().includes('manual');
        
        // Extract grammage if present (e.g. 5g, 10g, 10 cm³)
        let grammage = null;
        const gMatch = product.match(/(\d+(?:[.,]\d+)?)\s*g/i) || note.match(/(\d+(?:[.,]\d+)?)\s*g/i);
        if (gMatch) grammage = parseFloat(gMatch[1].replace(',', '.'));
        
        // Extract volume for SKF
        let volumeMl = null;
        const vMatch = product.match(/(\d+(?:[.,]\d+)?)\s*cm³/i) || note.match(/(\d+(?:[.,]\d+)?)\s*cm³/i);
        if (vMatch) volumeMl = parseFloat(vMatch[1].replace(',', '.'));

        // Extrapolate Task Type
        let taskType = 'lubrication';
        if (desc.toLowerCase().includes('verificar fugas') || desc.toLowerCase().includes('limpieza') || product.toLowerCase().includes('limpieza') || product.toLowerCase().includes('inspección')) {
          taskType = 'inspection';
        }
        
        currentMachine.points.push({
          frequency: freq,
          description: desc,
          itemNumber,
          numPoints,
          kallfassGroup: group,
          productESMAX: product,
          note,
          isManual,
          grammage,
          volumeMl,
          taskType
        });
      }
    }
  }

  if (currentMachine) machines.push(currentMachine);

  fs.writeFileSync(OUT_FILE, JSON.stringify(machines, null, 2));
  console.log(`✅ Extracción exitosa. ${machines.length} máquinas extraídas con un total de ${machines.reduce((acc, m) => acc + m.points.length, 0)} puntos de lubricación.`);
  console.log(`Guardado en: ${OUT_FILE}`);
}

main().catch(console.error);
