-- ============================================================
-- 13. MASTER DATA REINFORCEMENT (Fidelidad 100% Manuales)
-- Correcting gaps in Pos 85, 125 and adding consolidated data
-- ============================================================

DO $$
DECLARE
  v_area_id UUID;
  v_lub_xp32 UUID;
  v_lub_ep2 UUID;
  v_lub_plus2 UUID;
  v_lub_skf_lglt2 UUID;
  v_lub_gear150 UUID;
  v_freq_daily UUID;
  v_freq_weekly UUID;
  v_freq_monthly UUID;
  v_freq_biweekly UUID;
  v_freq_quarterly UUID;
  v_freq_annual UUID;
  v_freq_hours_2800 UUID;
BEGIN
  -- 1. Setup IDs
  SELECT id INTO v_area_id FROM areas WHERE name = 'Línea Principal Aserradero' LIMIT 1;
  SELECT id INTO v_lub_xp32 FROM lubricants WHERE product_name = 'HYDRA XP 32' LIMIT 1;
  SELECT id INTO v_lub_ep2 FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1;
  SELECT id INTO v_lub_plus2 FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1;
  SELECT id INTO v_lub_gear150 FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1;
  
  -- Ensure SKF LGLT 2 exists
  INSERT INTO lubricants (product_name, type, brand, description)
  VALUES ('SKF LGLT 2', 'grasa', 'SKF', 'Grasa sintética de alta velocidad (PAO). CRÍTICA para husillos QSS-700L.')
  ON CONFLICT (product_name) DO NOTHING;
  SELECT id INTO v_lub_skf_lglt2 FROM lubricants WHERE product_name = 'SKF LGLT 2' LIMIT 1;

  -- Ensure frequencies
  SELECT id INTO v_freq_daily FROM frequencies WHERE label = '1x/día' LIMIT 1;
  SELECT id INTO v_freq_weekly FROM frequencies WHERE label = '1x/semana' LIMIT 1;
  SELECT id INTO v_freq_monthly FROM frequencies WHERE label = '1x/mes' LIMIT 1;
  
  INSERT INTO frequencies (label, interval_days) VALUES ('2x/mes', 15) ON CONFLICT (label) DO NOTHING;
  SELECT id INTO v_freq_biweekly FROM frequencies WHERE label = '2x/mes' LIMIT 1;
  
  INSERT INTO frequencies (label, interval_days) VALUES ('1x/3 meses', 90) ON CONFLICT (label) DO NOTHING;
  SELECT id INTO v_freq_quarterly FROM frequencies WHERE label = '1x/3 meses' LIMIT 1;

  INSERT INTO frequencies (label, interval_days) VALUES ('1x/año', 365) ON CONFLICT (label) DO NOTHING;
  SELECT id INTO v_freq_annual FROM frequencies WHERE label = '1x/año' LIMIT 1;

  INSERT INTO frequencies (label, interval_days) VALUES ('c/2.800 hrs', 350) ON CONFLICT (label) DO NOTHING; -- Aprox 350 días en 1 turno
  SELECT id INTO v_freq_hours_2800 FROM frequencies WHERE label = 'c/2.800 hrs' LIMIT 1;

  -- ========================================================
  -- REINFORCING POS 85 — VLT-600 (Items 4-9 missing)
  -- ========================================================
  DELETE FROM lubrication_points WHERE machine_id = (SELECT id FROM machines WHERE position_code = 'Pos 85');
  
  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type)
  VALUES 
    ((SELECT id FROM machines WHERE position_code='Pos 85'), v_lub_ep2, v_freq_weekly, 1, 'Rodillo con púas, rodamiento', 2, 'lubrication'),
    ((SELECT id FROM machines WHERE position_code='Pos 85'), v_lub_ep2, v_freq_weekly, 2, 'Rodillo con púas, nipple', 2, 'lubrication'),
    ((SELECT id FROM machines WHERE position_code='Pos 85'), v_lub_ep2, v_freq_weekly, 3, 'Brazo centrador, rodamiento', 2, 'lubrication'),
    ((SELECT id FROM machines WHERE position_code='Pos 85'), v_lub_ep2, v_freq_weekly, 4, 'Barra paralela, oreja', 2, 'lubrication'),
    ((SELECT id FROM machines WHERE position_code='Pos 85'), v_lub_ep2, v_freq_weekly, 5, 'Barra paralela, oreja', 2, 'lubrication'),
    ((SELECT id FROM machines WHERE position_code='Pos 85'), v_lub_ep2, v_freq_weekly, 6, 'Soporte cilindro', 4, 'lubrication'),
    ((SELECT id FROM machines WHERE position_code='Pos 85'), v_lub_ep2, v_freq_weekly, 7, 'Soporte cilindro', 2, 'lubrication'),
    ((SELECT id FROM machines WHERE position_code='Pos 85'), v_lub_ep2, v_freq_weekly, 8, 'Eje guía, nipple', 4, 'lubrication'),
    ((SELECT id FROM machines WHERE position_code='Pos 85'), v_lub_gear150, v_freq_monthly, 9, 'Motorreductor SEW', 2, 'inspection');

  -- ========================================================
  -- REINFORCING POS 125 — QSS-700L (Critical SKF LGLT 2)
  -- ========================================================
  -- Updating machine description for safety
  UPDATE machines SET description = ' sierra Doble (QSS-700L). REQUIERE SKF LGLT 2 EN HUSILLO.' WHERE position_code = 'Pos 125';

  DELETE FROM lubrication_points WHERE machine_id = (SELECT id FROM machines WHERE position_code = 'Pos 125');

  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type, grammage_g)
  VALUES 
    -- Lado 1 (Multiplicar x2 se hará por num_points o por items duplicados; aquí usaremos num_points x2 para simplicidad de ruta)
    ((SELECT id FROM machines WHERE position_code='Pos 125'), v_lub_ep2, v_freq_biweekly, 1, 'Bloques correderas (Máquina Completa)', 52, 'lubrication', 5),
    ((SELECT id FROM machines WHERE position_code='Pos 125'), v_lub_ep2, v_freq_biweekly, 2, 'Husillo de bolas / tornillo', 4, 'lubrication', 10),
    ((SELECT id FROM machines WHERE position_code='Pos 125'), v_lub_ep2, v_freq_biweekly, 3, 'Soporte cilindro', 16, 'lubrication', 5),
    ((SELECT id FROM machines WHERE position_code='Pos 125'), v_lub_ep2, v_freq_biweekly, 4, 'Soporte vástago pistón', 4, 'lubrication', 5),
    ((SELECT id FROM machines WHERE position_code='Pos 125'), v_lub_plus2, v_freq_monthly, 7, 'Motor husillo, lado transmisión', 4, 'lubrication', 100),
    ((SELECT id FROM machines WHERE position_code='Pos 125'), v_lub_plus2, v_freq_annual, 71, 'Motor husillo, lado ventilador', 4, 'lubrication', 60),
    ((SELECT id FROM machines WHERE position_code='Pos 125'), v_lub_plus2, v_freq_quarterly, 8, 'Motor de corte ABB', 4, 'lubrication', 40),
    -- EL PUNTO CRÍTICO
    ((SELECT id FROM machines WHERE position_code='Pos 125'), v_lub_skf_lglt2, v_freq_hours_2800, 11, 'Rodamiento husillo de sierra (SKF LGLT 2 EXCLUSIVO)', 4, 'lubrication', 10);

  -- ========================================================
  -- ADDING DAILY CHAIN POINTS (Consolidado de 31 puntos)
  -- ========================================================
  -- Pos 80 Chain (Item 1)
  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type, is_manual)
  VALUES ((SELECT id FROM machines WHERE position_code='Pos 80'), v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 1, 'lubrication', true)
  ON CONFLICT DO NOTHING;

  -- Pos 115 Chain (Item 1)
  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type, is_manual)
  VALUES ((SELECT id FROM machines WHERE position_code='Pos 115'), v_lub_xp32, v_freq_daily, 1, 'Riel de presión de cadena', 1, 'lubrication', true)
  ON CONFLICT DO NOTHING;

  -- Pos 120 Chain (Item 1 & 10)
  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type, is_manual)
  VALUES 
    ((SELECT id FROM machines WHERE position_code='Pos 120'), v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 2, 'lubrication', true),
    ((SELECT id FROM machines WHERE position_code='Pos 120'), v_lub_xp32, v_freq_daily, 10, 'Cadena rodillo con púas', 2, 'lubrication', true)
  ON CONFLICT DO NOTHING;

  -- Pos 130 Chain (Item 1 & 10)
  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type, is_manual)
  VALUES 
    ((SELECT id FROM machines WHERE position_code='Pos 130'), v_lub_xp32, v_freq_daily, 1, 'Cadena', 2, 'lubrication', true),
    ((SELECT id FROM machines WHERE position_code='Pos 130'), v_lub_xp32, v_freq_daily, 10, 'Cadena rodillo con púas', 2, 'lubrication', true)
  ON CONFLICT DO NOTHING;

  -- Pos 180.2, 180.6, 190.1, 190.3, 200.2
  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, task_type, is_manual)
  VALUES 
    ((SELECT id FROM machines WHERE position_code='Pos 180.2'), v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 3, 'lubrication', true),
    ((SELECT id FROM machines WHERE position_code='Pos 180.6'), v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 3, 'lubrication', true),
    ((SELECT id FROM machines WHERE position_code='Pos 190.1'), v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 5, 'lubrication', true),
    ((SELECT id FROM machines WHERE position_code='Pos 190.3'), v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 5, 'lubrication', true),
    ((SELECT id FROM machines WHERE position_code='Pos 200.2'), v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 5, 'lubrication', true)
  ON CONFLICT DO NOTHING;

END $$;
