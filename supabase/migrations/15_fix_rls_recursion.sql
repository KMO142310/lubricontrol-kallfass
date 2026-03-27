-- ============================================================
-- 15. FIX CRÍTICO: INFINITE RECURSION EN RLS PROFILES
--
-- Problema: políticas en 'profiles' hacen sub-query a 'profiles'
-- causando bucle infinito al intentar acceder a daily_tasks,
-- profiles, completion_logs, etc.
--
-- Solución: función SECURITY DEFINER que evalúa el rol sin RLS.
-- ============================================================

-- 1. Función helper: lee el rol del usuario actual sin activar RLS
CREATE OR REPLACE FUNCTION public.get_auth_role()
RETURNS TEXT
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT COALESCE(role::text, 'lubricator')
  FROM public.profiles
  WHERE id = auth.uid()
$$;

-- ============================================================
-- 2. PROFILES — Eliminar políticas recursivas y reemplazar
-- ============================================================
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update profiles" ON profiles;
-- Mantener: "Users can view own profile" (no es recursiva, usa auth.uid() = id)

CREATE POLICY "supervisors_admins_view_all_profiles" ON profiles
  FOR SELECT USING (
    id = auth.uid() OR get_auth_role() IN ('supervisor', 'admin')
  );

CREATE POLICY "admin_update_any_profile" ON profiles
  FOR UPDATE USING (get_auth_role() = 'admin');

CREATE POLICY "user_update_own_profile" ON profiles
  FOR UPDATE USING (id = auth.uid());

-- ============================================================
-- 3. DAILY_TASKS — Eliminar políticas recursivas
-- ============================================================
DROP POLICY IF EXISTS "Lubricators see own tasks" ON daily_tasks;
DROP POLICY IF EXISTS "Supervisors can insert tasks" ON daily_tasks;

CREATE POLICY "view_own_or_supervisor_tasks" ON daily_tasks
  FOR SELECT USING (
    assigned_user_id = auth.uid()
    OR get_auth_role() IN ('supervisor', 'admin')
  );

CREATE POLICY "supervisor_insert_tasks" ON daily_tasks
  FOR INSERT WITH CHECK (
    get_auth_role() IN ('supervisor', 'admin')
  );

CREATE POLICY "update_own_or_supervisor_tasks" ON daily_tasks
  FOR UPDATE USING (
    assigned_user_id = auth.uid()
    OR get_auth_role() IN ('supervisor', 'admin')
  );

-- ============================================================
-- 4. COMPLETION_LOGS — Eliminar política recursiva
-- ============================================================
DROP POLICY IF EXISTS "All can read logs" ON completion_logs;

CREATE POLICY "view_own_or_supervisor_logs" ON completion_logs
  FOR SELECT USING (
    user_id = auth.uid()
    OR get_auth_role() IN ('supervisor', 'admin')
  );

-- ============================================================
-- 5. generate_daily_tasks — Convertir a SECURITY DEFINER
--    para que pueda leer profiles sin restricción de RLS
-- ============================================================
CREATE OR REPLACE FUNCTION public.generate_daily_tasks(p_date DATE DEFAULT CURRENT_DATE)
RETURNS INTEGER AS $$
DECLARE
  v_point       RECORD;
  v_last_date   DATE;
  v_lubricator  UUID;
  v_created     INTEGER := 0;
BEGIN
  -- Tomar el primer lubricador (sin RLS, es SECURITY DEFINER)
  SELECT id INTO v_lubricator
  FROM public.profiles
  WHERE role = 'lubricator'
  LIMIT 1;

  IF v_lubricator IS NULL THEN
    RAISE NOTICE 'generate_daily_tasks: No lubricator found. Skipping.';
    RETURN 0;
  END IF;

  FOR v_point IN
    SELECT lp.id, COALESCE(f.interval_days, 7) AS interval_days
    FROM public.lubrication_points lp
    JOIN public.frequencies f ON lp.frequency_id = f.id
  LOOP
    -- Evitar duplicados
    IF EXISTS (
      SELECT 1 FROM public.daily_tasks
      WHERE lubrication_point_id = v_point.id
        AND scheduled_date = p_date
    ) THEN
      CONTINUE;
    END IF;

    IF v_point.interval_days <= 1 THEN
      -- Diaria: siempre crear
      INSERT INTO public.daily_tasks (lubrication_point_id, assigned_user_id, scheduled_date, status)
      VALUES (v_point.id, v_lubricator, p_date, 'pending');
      v_created := v_created + 1;
    ELSE
      -- Periódica: crear si pasó el intervalo desde la última completación
      SELECT MAX(completed_at)::DATE INTO v_last_date
      FROM public.completion_logs
      WHERE lubrication_point_id = v_point.id AND status = 'completed';

      IF v_last_date IS NULL OR (p_date - v_last_date) >= v_point.interval_days THEN
        INSERT INTO public.daily_tasks (lubrication_point_id, assigned_user_id, scheduled_date, status)
        VALUES (v_point.id, v_lubricator, p_date, 'pending');
        v_created := v_created + 1;
      END IF;
    END IF;
  END LOOP;

  RETURN v_created;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 6. Generar tareas para HOY (ejecutar una sola vez)
-- ============================================================
SELECT generate_daily_tasks(CURRENT_DATE) AS tareas_creadas;
