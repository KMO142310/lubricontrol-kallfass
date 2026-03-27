-- ============================================================
-- 08. SEED CONVEYORS POINTS (Pos 180.1 to 200.2)
-- Based on PLAN_MAESTRO_LUBRICACION_KALLFASS.md
-- ============================================================

DO $$
DECLARE
  v_area_id UUID;
  v_lub_xp32 UUID;
  v_lub_ep2 UUID;
  v_lub_gear150 UUID;
  v_freq_daily UUID;
  v_freq_weekly UUID;
  v_freq_monthly UUID;
BEGIN
  -- 1. Setup common IDs
  SELECT id INTO v_area_id FROM areas WHERE name = 'Línea Principal Aserradero' LIMIT 1;
  SELECT id INTO v_lub_xp32 FROM lubricants WHERE product_name = 'HYDRA XP 32' LIMIT 1;
  SELECT id INTO v_lub_ep2 FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1;
  SELECT id INTO v_lub_gear150 FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1;
  SELECT id INTO v_freq_daily FROM frequencies WHERE label = '1x/día' LIMIT 1;
  SELECT id INTO v_freq_weekly FROM frequencies WHERE label = '1x/semana' LIMIT 1;
  SELECT id INTO v_freq_monthly FROM frequencies WHERE label = '1x/mes' LIMIT 1;

  -- ========================================================
  -- SEEDING HELPER: Insert or update machine, then points
  -- ========================================================
  
  -- 180.1 — Roll Conveyor 520595
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 180.1', 'Roll Conveyor', 'Roll Conveyor 520595')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_ep2, v_freq_weekly, 1, 'Rodamiento', 4, 'lubrication'
  FROM machines WHERE position_code = 'Pos 180.1';

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_gear150, v_freq_monthly, 2, 'Motorreductor SEW', 1, 'inspection'
  FROM machines WHERE position_code = 'Pos 180.1';

  -- 180.2 — Side Conveyor 520542
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 180.2', 'Side Conveyor', 'Side Conveyor 520542')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 3, 'lubrication'
  FROM machines WHERE position_code = 'Pos 180.2';

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_ep2, v_freq_weekly, 2, 'Rodamiento', 4, 'lubrication'
  FROM machines WHERE position_code = 'Pos 180.2';

  -- 180.3 — Roll Conveyor 520632
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 180.3', 'Roll Conveyor', 'Roll Conveyor 520632')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_ep2, v_freq_weekly, 1, 'Rodamiento', 4, 'lubrication'
  FROM machines WHERE position_code = 'Pos 180.3';

  -- 180.4 — Belt Conveyor 520721
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 180.4', 'Belt Conveyor', 'Belt Conveyor (Correa) 520721')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_ep2, v_freq_weekly, 1, 'Rodamiento (Motriz/Cola)', 8, 'lubrication'
  FROM machines WHERE position_code = 'Pos 180.4';

  -- 180.5 — Roll Conveyor 520651
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 180.5', 'Roll Conveyor', 'Roll Conveyor 520651')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_ep2, v_freq_weekly, 1, 'Rodamiento', 4, 'lubrication'
  FROM machines WHERE position_code = 'Pos 180.5';

  -- 180.6 — Side Conveyor 520581
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 180.6', 'Side Conveyor', 'Side Conveyor 520581')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 3, 'lubrication'
  FROM machines WHERE position_code = 'Pos 180.6';

  -- 190.1 — Side Conveyor 520774
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 190.1', 'Side Conveyor', 'Side Conveyor 520774')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 5, 'lubrication'
  FROM machines WHERE position_code = 'Pos 190.1';

  -- 190.2 — Rembana (Belt Conveyor) 520860
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 190.2', 'Belt Conveyor', 'Rembana (Belt Conveyor) 520860')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_ep2, v_freq_weekly, 1, 'Rodamiento (Motriz/Cola)', 8, 'lubrication'
  FROM machines WHERE position_code = 'Pos 190.2';

  -- 190.3 — Rooftop 520715
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 190.3', 'Rooftop', 'Rooftop 520715')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 5, 'lubrication'
  FROM machines WHERE position_code = 'Pos 190.3';

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_ep2, v_freq_weekly, 2, 'Rodamiento (item 2)', 12, 'lubrication'
  FROM machines WHERE position_code = 'Pos 190.3';

  -- 200.1 — Rembana (Belt Conveyor) 520677
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 200.1', 'Belt Conveyor', 'Rembana (Belt Conveyor) 520677')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_ep2, v_freq_weekly, 1, 'Rodamiento', 4, 'lubrication'
  FROM machines WHERE position_code = 'Pos 200.1';

  -- 200.2 — Rooftop 520718
  INSERT INTO machines (area_id, position_code, model_name, description)
  VALUES (v_area_id, 'Pos 200.2', 'Rooftop', 'Rooftop 520718')
  ON CONFLICT (position_code) DO UPDATE SET description = EXCLUDED.description;

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 5, 'lubrication'
  FROM machines WHERE position_code = 'Pos 200.2';

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  SELECT id, v_lub_ep2, v_freq_weekly, 2, 'Rodamiento (item 2)', 12, 'lubrication'
  FROM machines WHERE position_code = 'Pos 200.2';

END $$;
