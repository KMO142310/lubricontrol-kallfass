---
name: lubrication-conventions
description: Convenciones del proyecto BITACORA. Aplicar automáticamente al escribir o revisar código en este proyecto.
user-invocable: false
---

## Convenciones de Nomenclatura

- Componentes React: PascalCase → `TaskCard`, `MachineDetailSheet`
- Hooks: camelCase con prefijo `use` → `useRouteStore`, `useAuth`
- Archivos: camelCase → `syncEngine.ts`, `localDb.ts`
- Constantes: UPPER_SNAKE_CASE → `SUPABASE_URL`
- Tipos Supabase: extraer de `src/types/database.ts` (fuente de verdad)

## Patrones de Código

```typescript
// ✅ Queries Supabase siempre con destructuring de error
const { data, error } = await supabase.from('machines').select('*')
if (error) throw new Error(`machines query failed: ${error.message}`)

// ✅ Offline-first: escribir a IndexedDB primero
await localDb.savePendingLog(log)        // 1. Guardar local
syncEngine.syncFull(userId).catch(noop)  // 2. Intentar sync (no bloquear)

// ✅ Server Components por defecto
// Solo agregar 'use client' si se necesita: useState, useEffect, event handlers

// ✅ Zustand: acciones en el store, no en componentes
const { completeTask } = useRouteStore()
await completeTask(taskId, { grammage, completedAt: new Date() })

// ❌ Prohibido
const x: any = ...          // sin any
console.log(...)            // sin logs en producción
fetch('/api/...')           // usar supabase client, no fetch directo
```

## Offline-First Rules

1. Toda acción del usuario que modifica datos → primero a IndexedDB
2. Sync con Supabase en background (nunca bloquear UI)
3. Estado de sync visible al usuario (header indicator)
4. Si falla sync → quedar en cola, reintentar automático

## Grupos de Lubricación Kallfass

Siempre referirse a grupos como: `group_i`, `group_ii`, `group_iii`, `group_iv`, `group_v`
Group IV = SKF LGLT 2 = requiere alerta especial en UI (no tiene equivalente ESMAX)

## Roles y RLS

- `lubricator`: solo sus propias tareas (`user_id = auth.uid()`)
- `supervisor`: su área asignada (`area_id IN (SELECT area_id FROM profiles WHERE id = auth.uid())`)
- `admin`: sin restricciones

## Stack Específico

- Animaciones: Framer Motion (no CSS transitions para micro-interacciones)
- Iconos: Lucide React (no FontAwesome, no heroicons)
- Toast/notificaciones: implementar con Framer Motion (no instalar librería adicional)
- Modal/Sheet: componente propio (ver `MachineDetailSheet.tsx` como patrón)
