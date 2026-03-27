@AGENTS.md

# BITACORA — Sistema de Lubricación Industrial Kallfass

## Contexto del Proyecto

PWA offline-first para lubricadores en aserradero Kallfass (Chile). Los lubricadores trabajan 8h sin WiFi. La app permite descargar ruta, trabajar offline, registrar gramajes, reportar anomalías con foto/video y sincronizar automáticamente al volver a zona con conexión.

**Stack:** Next.js 16.2.1 (App Router) · React 19 · TypeScript · Tailwind 4 · Supabase · Zustand · Serwist PWA · IndexedDB

## Reglas de Código

- Siempre TypeScript estricto, sin `any`
- Tailwind utility-first, no CSS módulos
- Async/await, no `.then()` chains
- Server Components por defecto; `'use client'` solo cuando necesario
- Zustand para estado global; React state para local
- Todas las queries Supabase con manejo de error explícito
- Offline-first: toda escritura va primero a IndexedDB, luego sync

## Arquitectura

```
src/
├── app/                    # Rutas Next.js (App Router)
│   ├── page.tsx            # Landing
│   ├── login/page.tsx      # Auth
│   ├── dashboard/page.tsx  # Lubricador (50% implementado)
│   └── dashboard/supervisor/page.tsx  # Supervisor (VACÍO)
├── components/             # UI reutilizable
├── lib/
│   ├── auth/               # Supabase Auth + Context
│   ├── data/               # Queries + IndexedDB
│   ├── sync/               # Sync Engine offline→online
│   ├── store/              # Zustand stores
│   └── supabase/           # Cliente Supabase
└── types/database.ts       # Schema 14 tablas (fuente de verdad)
```

## Base de Datos (14 tablas)

`profiles` · `areas` · `machines` · `machine_components` · `lubricants` · `kallfass_groups` · `frequencies` · `lubrication_points` · `shifts` · `daily_tasks` · `completion_logs` · `anomaly_reports` · `consumption_logs` · `machine_images`

## Roles

- `lubricator` — ve y completa sus propias tareas
- `supervisor` — ve equipo asignado, KPIs, anomalías
- `admin` — acceso total

## Grupos Kallfass → Lubricantes ESMAX

| Grupo | Aplicación | Lubricante |
|-------|-----------|-----------|
| Group I | Cadenas, piñones (diario) | LUBRAX HYDRA XP 32 |
| Group II | Rodillos fábrica | LUBRAX HYDRA XP 68 |
| Group III | Motorreductores SEW | LUBRAX GEAR 150/220 |
| Group IV | Husillo sierra QSS-700L | **SKF LGLT 2** (sin equiv. ESMAX) |
| Group V | Rodamientos, chumaceras (semanal) | LUBRAX LITH EP 2 |

## Máquinas

**Kallfass (20):** Pos 80–200.2 — completamente documentadas con manuales PDF en `../01 Lubrication/`
**Bruks (~7):** Pos 400–490 — solo datos parciales en Excel
**SORSA (1):** Pos 110 Enzunchadora — 13 puntos en Excel

## Bugs Críticos Conocidos

- **BUG-001:** Supabase BD vacía → app no muestra nada. Prioridad #1.
- **BUG-003:** `src/lib/data/tasks.ts` línea 18-23 turnos hardcodeados martes-sábado. Debe consultar tabla `shifts`.
- **BUG-004:** RLS no configurado → cualquier usuario ve datos de otros.
- **BUG-005:** TaskCard permite marcar completo sin gramaje.
- **BUG-006:** Anomaly reports no suben fotos a Supabase Storage.
- **BUG-007:** Middleware no protege `/dashboard/supervisor`.

## Antes de Leer Next.js

Antes de escribir código Next.js, leer `node_modules/next/dist/docs/` para verificar APIs actuales (versión 16, hay breaking changes).
