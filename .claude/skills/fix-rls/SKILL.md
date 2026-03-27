---
name: fix-rls
description: Plan para implementar políticas RLS en Supabase. Invocar cuando se vaya a configurar seguridad de la BD.
user-invocable: false
---

## RLS (Row Level Security) — Plan de Implementación

**Riesgo actual:** Sin RLS, cualquier usuario autenticado puede leer datos de otros usuarios.

### Archivo a crear cuando se implemente

`supabase/migrations/YYYYMMDD_rls_policies.sql`

### Resumen de políticas por rol

| Tabla | lubricator | supervisor | admin |
|-------|-----------|-----------|-------|
| `profiles` | Solo el propio | Su área | Todo |
| `daily_tasks` | Solo asignadas a él | Su área | Todo |
| `completion_logs` | Solo los propios | Su área | Todo |
| `anomaly_reports` | Solo los propios | Lee todos | Todo |
| `machines` | Solo lectura | Lectura + edita su área | Todo |
| `lubrication_points` | Solo lectura | Lectura | Todo |
| `lubricants` | Solo lectura | Lectura | Todo |

### Patrón de política lubricator

```sql
-- usuario ve solo sus propios registros
CREATE POLICY "own_records" ON {tabla}
  FOR ALL USING (user_id = auth.uid());
```

### Patrón de política supervisor

```sql
-- supervisor ve registros de su área
CREATE POLICY "supervisor_area" ON {tabla}
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles p
      JOIN machines m ON m.area_id = p.area_id
      WHERE p.id = auth.uid()
      AND p.role = 'supervisor'
      AND m.id = {tabla}.machine_id
    )
  );
```

### Patrón admin (bypass total)

```sql
CREATE POLICY "admin_bypass" ON {tabla}
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
```

### Tablas sin RLS necesario (datos maestros, solo lectura)

`machines`, `lubrication_points`, `lubricants`, `frequencies`, `kallfass_groups`, `areas`
→ `FOR SELECT USING (auth.role() = 'authenticated')` (cualquier usuario autenticado puede leer)

### Testing de RLS

Probar con 3 usuarios demo:
1. Lubricador A → solo ve tareas asignadas a él
2. Supervisor → ve todas las tareas de su área, no de otras áreas
3. Admin → ve absolutamente todo

### Consideración para seed

Durante el seed inicial, usar `SUPABASE_SERVICE_ROLE_KEY` que bypasea RLS automáticamente.
