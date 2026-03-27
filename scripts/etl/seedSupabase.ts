/* eslint-disable @typescript-eslint/no-require-imports */
import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';

require('dotenv').config({ path: path.join(__dirname, '../../.env.local') });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY; // Requires service role to bypass RLS for seeding

if (!supabaseUrl || !supabaseKey) {
  console.error("❌ Faltan credenciales de Supabase en .env.local");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);
const DATA_FILE = path.join(__dirname, 'machines_data.json');

async function seed() {
  console.log("🚀 Iniciando Seeding de Kallfass en Supabase...");
  const data = JSON.parse(fs.readFileSync(DATA_FILE, 'utf-8'));

  // 1. Obtener el ID del Área "Línea Principal Aserradero"
  const { data: area, error: areaErr } = await supabase
    .from('areas')
    .select('id')
    .eq('name', 'Línea Principal Aserradero')
    .single();

  if (areaErr || !area) {
     console.error("❌ Área 'Línea Principal Aserradero' no encontrada. ¿Corriste el 01_initial_schema.sql en Supabase?");
     process.exit(1);
  }

  // 2. Obtener Diccionarios Maestros (Lubricantes y Frecuencias)
  const { data: lubricants } = await supabase.from('lubricants').select('id, product_name');
  const { data: frequencies } = await supabase.from('frequencies').select('id, label');

  if (!lubricants || !frequencies) {
    console.error("❌ Catálogos vacíos. Revisa el initial_schema.");
    process.exit(1);
  }

  let totalPoints = 0;

  // 3. Insertar Máquina por Máquina
  for (const machine of data) {
    console.log(`\n⚙️  Procesando: ${machine.positionCode} - ${machine.modelName}`);

    const { data: mData, error: mErr } = await supabase
      .from('machines')
      .upsert({
         area_id: area.id,
         position_code: machine.positionCode,
         model_name: machine.modelName,
         description: machine.description,
         doc_reference: machine.docReference || null
      }, { onConflict: 'position_code' })
      .select('id')
      .single();

    if (mErr || !mData) {
       console.error(`❌ Error insertando máquina ${machine.positionCode}:`, mErr);
       continue;
    }

    const machineId = mData.id;

    // 4. Insertar Puntos de Lubricación para esta máquina
    for (const p of machine.points) {
       // Buscar ID de Frecuencia
       const freqMatch = frequencies.find(f => f.label === p.frequency);
       // Buscar ID de Lubricante (Heurística simple)
       let lubId = lubricants.find(l => p.productESMAX.includes(l.product_name))?.id;
       
       // Fallbacks para SKF o nombres genéricos
       if (p.productESMAX.includes('SKF') || p.productESMAX.includes('LGLT')) {
         lubId = lubricants.find(l => l.product_name.includes('LGLT'))?.id;
       }
       if (p.productESMAX.includes('limpieza') || p.productESMAX.includes('Aricur')) {
          // Asigno un lubricante por defecto o permito null si el schema lo admite
          // El schema exige lubricant_id NOT NULL. Asignamos LITH EP 2 por defecto si es inspección o creamos un dummy.
          // Mejor buscar el primero por defecto para no romper constraints, ya que es "inspection".
          lubId = lubId || lubricants[0].id; 
       }

       if (!freqMatch || !lubId) {
          console.warn(`⚠️ Omitiendo Punto ${p.itemNumber} en ${machine.positionCode}: Frec/Lubricante no matchea exacto.`);
          continue;
       }

       const { error: pErr } = await supabase.from('lubrication_points').insert({
          machine_id: machineId,
          lubricant_id: lubId,
          frequency_id: freqMatch.id,
          item_number: p.itemNumber,
          description: p.description,
          task_type: p.taskType,
          num_points: p.numPoints,
          grammage_g: p.grammage,
          volume_ml: p.volumeMl,
          is_manual: p.isManual,
          notes: p.note
       });

       if (pErr) {
          console.error(`❌ Error en punto ${p.itemNumber}:`, pErr.message);
       } else {
          totalPoints++;
       }
    }
  }

  console.log(`\n✅ ¡Seed completado! ${totalPoints} puntos insertados en la nube de Supabase exitosamente.`);
}

seed().catch(console.error);
