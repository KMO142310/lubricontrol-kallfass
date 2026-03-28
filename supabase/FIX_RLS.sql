-- ============================================================
-- FIX CRÍTICO: Recursive RLS en profiles/daily_tasks
-- PEGA ESTO en Supabase > SQL Editor > Run
-- ============================================================

-- 1. Función helper que lee el rol SIN activar RLS (SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.get_auth_role()
RETURNS TEXT LANGUAGE SQL SECURITY DEFINER STABLE SET search_path = public AS $$
  SELECT COALESCE(role::text, 'lubricator') FROM public.profiles WHERE id = auth.uid()
$$;

-- 2. Eliminar políticas recursivas en profiles
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update profiles" ON profiles;
DROP POLICY IF EXISTS "supervisors_admins_view_all_profiles" ON profiles;
DROP POLICY IF EXISTS "admin_update_any_profile" ON profiles;
DROP POLICY IF EXISTS "user_update_own_profile" ON profiles;

-- 3. Nuevas políticas sin recursión
CREATE POLICY "view_own_or_supervisor" ON profiles
  FOR SELECT USING (id = auth.uid() OR get_auth_role() IN ('supervisor', 'admin'));

CREATE POLICY "admin_update_profile" ON profiles
  FOR UPDATE USING (get_auth_role() = 'admin');

CREATE POLICY "self_update_profile" ON profiles
  FOR UPDATE USING (id = auth.uid());

-- 4. Eliminar políticas recursivas en daily_tasks
DROP POLICY IF EXISTS "Lubricators see own tasks" ON daily_tasks;
DROP POLICY IF EXISTS "Supervisors can insert tasks" ON daily_tasks;
DROP POLICY IF EXISTS "view_own_or_supervisor_tasks" ON daily_tasks;
DROP POLICY IF EXISTS "supervisor_insert_tasks" ON daily_tasks;
DROP POLICY IF EXISTS "update_own_or_supervisor_tasks" ON daily_tasks;
DROP POLICY IF EXISTS "Lubricators can update own tasks" ON daily_tasks;

-- 5. Nuevas políticas sin recursión en daily_tasks
CREATE POLICY "view_tasks" ON daily_tasks
  FOR SELECT USING (
    assigned_user_id = auth.uid() OR get_auth_role() IN ('supervisor', 'admin')
  );

CREATE POLICY "insert_tasks" ON daily_tasks
  FOR INSERT WITH CHECK (get_auth_role() IN ('supervisor', 'admin'));

CREATE POLICY "update_tasks" ON daily_tasks
  FOR UPDATE USING (
    assigned_user_id = auth.uid() OR get_auth_role() IN ('supervisor', 'admin')
  );

-- 6. Eliminar políticas recursivas en completion_logs
DROP POLICY IF EXISTS "All can read logs" ON completion_logs;
DROP POLICY IF EXISTS "view_own_or_supervisor_logs" ON completion_logs;

CREATE POLICY "view_logs" ON completion_logs
  FOR SELECT USING (
    user_id = auth.uid() OR get_auth_role() IN ('supervisor', 'admin')
  );

-- 7. Verificar que funciona
SELECT
  (SELECT COUNT(*) FROM machines) AS maquinas,
  (SELECT COUNT(*) FROM lubrication_points) AS puntos_lubricacion,
  (SELECT COUNT(*) FROM profiles) AS perfiles,
  (SELECT COUNT(*) FROM daily_tasks WHERE scheduled_date = CURRENT_DATE) AS tareas_hoy;
