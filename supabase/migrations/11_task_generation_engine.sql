-- ============================================================
-- 11. TASK GENERATION ENGINE
-- Function to automate daily route creation
-- ============================================================

-- 1. Actualizar estimaciones de días para frecuencias basadas en horas
UPDATE frequencies SET interval_days = 47 WHERE label = 'c/375 hrs' AND interval_days IS NULL;
UPDATE frequencies SET interval_days = 350 WHERE label = 'c/2800 hrs' AND interval_days IS NULL;
UPDATE frequencies SET interval_days = 365 WHERE label = 'Anual' AND interval_days IS NULL;

-- 2. Función Principal de Generación
CREATE OR REPLACE FUNCTION generate_daily_tasks(p_date DATE DEFAULT CURRENT_DATE)
RETURNS INTEGER AS $$
DECLARE
  v_point RECORD;
  v_last_completion DATE;
  v_lubricator_id UUID;
  v_tasks_created INTEGER := 0;
BEGIN
  -- Obtener el primer lubricador disponible para asignación automática
  SELECT id INTO v_lubricator_id FROM profiles WHERE role = 'lubricator' LIMIT 1;
  
  IF v_lubricator_id IS NULL THEN
    RAISE EXCEPTION 'No se encontró ningún usuario con rol "lubricator" para asignar tareas.';
  END IF;

  FOR v_point IN 
    SELECT lp.id, f.interval_days 
    FROM lubrication_points lp
    JOIN frequencies f ON lp.frequency_id = f.id
  LOOP
    -- 1. Verificar si ya existe la tarea para hoy (evitar duplicados)
    IF EXISTS (
      SELECT 1 FROM daily_tasks 
      WHERE lubrication_point_id = v_point.id 
      AND scheduled_date = p_date
    ) THEN
      CONTINUE;
    END IF;

    -- 2. Lógica por Frecuencia
    IF v_point.interval_days = 1 THEN
      -- Diaria: Siempre se crea (podría añadirse lógica de fines de semana aquí)
      INSERT INTO daily_tasks (lubrication_point_id, assigned_user_id, scheduled_date, status)
      VALUES (v_point.id, v_lubricator_id, p_date, 'pending');
      v_tasks_created := v_tasks_created + 1;
    ELSE
      -- Periódica: Verificar última completación
      SELECT MAX(completed_at)::DATE INTO v_last_completion 
      FROM completion_logs 
      WHERE lubrication_point_id = v_point.id AND status = 'completed';

      -- Si nunca se ha hecho, o si ya pasó el intervalo
      IF v_last_completion IS NULL OR (p_date - v_last_completion) >= v_point.interval_days THEN
        INSERT INTO daily_tasks (lubrication_point_id, assigned_user_id, scheduled_date, status)
        VALUES (v_point.id, v_lubricator_id, p_date, 'pending');
        v_tasks_created := v_tasks_created + 1;
      END IF;
    END IF;
  END LOOP;

  RETURN v_tasks_created;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso: SELECT generate_daily_tasks('2026-03-28');
