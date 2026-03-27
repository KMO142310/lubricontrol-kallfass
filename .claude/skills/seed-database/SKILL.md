---
name: seed-database
description: Plan para migrar datos del PLAN_MAESTRO a Supabase. Invocar cuando se vaya a poblar la base de datos.
user-invocable: false
---

## Seed Database — Plan de Implementación

**Bloqueador #1 del proyecto.** Sin datos, la app no muestra nada.

### Fuentes de datos disponibles

| Fuente | Contenido | Calidad |
|--------|-----------|---------|
| `../PLAN_MAESTRO_LUBRICACION_KALLFASS.md` | 20 máquinas, 344+ puntos, gramajes, grupos | ✅ Excelente |
| `../Plan de mantenimiento nuevo aserradero.xlsx` | Bruks, SORSA, tareas adicionales | ⚠️ Parcial |
| `../01 Lubrication/*.pdf` | Manuales técnicos Kallfass | ✅ Completo |

### Orden de inserción (FK constraints)

```
1. lubricants           (sin FK)
2. frequencies          (sin FK)
3. areas                (sin FK)
4. machines             → area_id
5. machine_components   → machine_id
6. lubrication_points   → machine_id, lubricant_id, frequency_id, kallfass_group_id
7. kallfass_groups      → lubricant_id
8. shifts               (sin FK)
9. profiles (demo)      → area_id
```

### Datos críticos: Lubricantes

| Código | Nombre | Tipo | Grupo | Flag Especial |
|--------|--------|------|-------|--------------|
| `LUB-I` | LUBRAX HYDRA XP 32 | Aceite | Group I | - |
| `LUB-II` | LUBRAX HYDRA XP 68 | Aceite | Group II | - |
| `LUB-III-150` | LUBRAX GEAR 150 | Aceite CLP | Group III | - |
| `LUB-III-220` | LUBRAX GEAR 220 | Aceite CLP | Group III | - |
| `LUB-IV` | **SKF LGLT 2** | Grasa sintética PAO | Group IV | `requires_specific_brand: true` ⚠️ |
| `LUB-V-EP2` | LUBRAX LITH EP 2 | Grasa litio | Group V | - |
| `LUB-V-XHP` | LUBRAX LITHPLUS EP 2 | Grasa litio EP | Group V | - |

### Datos críticos: Máquinas Kallfass

| QR Code | Pos | Modelo | Tipo | PDF Manual |
|---------|-----|--------|------|-----------|
| POS-080 | 80 | Measure Conveyor | Transportador | 520685_en.pdf |
| POS-085 | 85 | VLT-600 | Volteador | 520378_en.pdf |
| POS-115 | 115 | VFW-600 | Alimentador | 520379_en.pdf |
| POS-120 | 120 | P-700 | Perfiladora | P-700_en.pdf |
| POS-125 | 125 | QSS-700L | Sierra Doble ⚠️ | QSS-700L_en.pdf |
| POS-130 | 130 | BR-610JR | Transportador | 520391_en.pdf |
| POS-135 | 135 | CT-100 | Cross Transfer | CT-100_en.pdf |
| POS-140 | 140 | 500A Feed Work | Alimentador | 520394_en.pdf |
| POS-160 | 160 | HDSV-700W | Sierra Doble | HDSV-700_en.pdf |
| POS-180-1 | 180.1 | Roll Conveyor | Transportador | 520595_en.pdf |
| POS-180-2 | 180.2 | Side Conveyor | Transportador | 520542_en.pdf |
| POS-180-3 | 180.3 | Roll Conveyor | Transportador | 520632_en.pdf |
| POS-180-4 | 180.4 | Belt Conveyor | Transportador | 520721_en.pdf |
| POS-180-5 | 180.5 | Roll Conveyor | Transportador | 520651_en.pdf |
| POS-180-6 | 180.6 | Side Conveyor | Transportador | 520581_en.pdf |
| POS-190-1 | 190.1 | Side Conveyor | Transportador | 520774_en.pdf |
| POS-190-2 | 190.2 | Belt Conveyor Rembana | Transportador | 520860_en.pdf |
| POS-190-3 | 190.3 | Rooftop | Transportador | 520715_en.pdf |
| POS-200-1 | 200.1 | Belt Conveyor Rembana | Transportador | 520677_en.pdf |
| POS-200-2 | 200.2 | Rooftop | Transportador | 520718_en.pdf |

⚠️ QSS-700L (POS-125): rodamiento husillo usa Group IV (SKF LGLT 2). Requiere alerta en UI.

### Datos pendientes de terreno (NO bloquean seed inicial)

- Viscosidad exacta motorreductores SEW (CLP 150 vs CLP 220 vs CLP 460) → fotografiar placa
- Gramajes "estándar" → calibrar: pesar 1 palancazo en engrasadora = ?g
- Bruks pos 400–490 → solicitar manuales o datos al fabricante
- SORSA pos 110 → fotografiar puntos en terreno

### Implementación cuando se apruebe

```
scripts/seed.ts — TypeScript con @supabase/supabase-js
Ejecutar: SUPABASE_SERVICE_ROLE_KEY=xxx npx ts-node scripts/seed.ts
```
Usar `service_role` key (no anon key) para bypass RLS durante seed.
