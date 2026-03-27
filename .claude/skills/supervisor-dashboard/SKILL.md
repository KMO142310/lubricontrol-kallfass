---
name: supervisor-dashboard
description: Plan de implementación del dashboard supervisor. Invocar cuando se vaya a construir la vista de supervisor.
user-invocable: false
---

## Dashboard Supervisor — Plan de Implementación

**Ruta:** `src/app/dashboard/supervisor/page.tsx` (actualmente vacía)
**Rol requerido:** `supervisor` o `admin`

### 5 Vistas a Implementar

#### Vista 1: KPIs del Día (pantalla principal)
```
┌──────────────────────────────────────────────────────┐
│  Cumplimiento hoy: 87%   │  Anomalías abiertas: 3   │
│  Puntos completados: 298 │  Consumo vs teórico: 94% │
└──────────────────────────────────────────────────────┘
```
- Query: `completion_logs` WHERE date = today, GROUP BY machine
- Actualización: cada 5 min (o real-time con Supabase subscriptions)

#### Vista 2: Estado por Máquina (mapa visual)
- Grid de tarjetas, una por máquina (20 Kallfass + Bruks + SORSA)
- Color semáforo: 🟢 completada / 🟡 en progreso / 🔴 pendiente / ⚫ sin asignar
- Click → detalle de puntos completados vs pendientes

#### Vista 3: Anomalías Abiertas
- Lista chronológica de `anomaly_reports` no resueltas
- Filtro por máquina, tipo, fecha
- Botón "Marcar resuelta" con campo de acción tomada
- Si hay foto/video → miniatura expandible

#### Vista 4: Consumo de Lubricantes
- Tabla: lubricante / consumo real / consumo teórico / diferencia %
- Alerta si diferencia > 20% (posible fuga o error de registro)
- Período: semana / mes / trimestre (selector)

#### Vista 5: Asignación de Rutas
- Selector de fecha + lubricador
- Arrastrar/soltar máquinas entre lubricadores
- Guardar en `daily_tasks`

### Componentes a crear

```
src/components/supervisor/
├── KpiCard.tsx              # Tarjeta KPI individual
├── MachineStatusGrid.tsx    # Grid semáforo de máquinas
├── AnomalyList.tsx          # Lista anomalías con media
├── ConsumptionChart.tsx     # Gráfico consumo (recharts o native SVG)
└── RouteAssigner.tsx        # Asignador de rutas drag-drop
```

### Librerías necesarias (evaluar si agregar)

- `recharts` — gráficos consumo (lightweight, compatible con React 19)
- `@dnd-kit/core` — drag-drop para asignación de rutas
- O implementar con CSS nativo para no agregar dependencias

### Flujo de datos

```
Supabase (real-time) → Server Component → Client Component (Zustand supervisor store)
                     → Cache invalidation cada 5 min si no hay real-time
```
