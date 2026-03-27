-- ============================================================
-- Lubrication System — Seed Machines & Points (Phase 1)
-- Populates the first 4 critical Kallfass machines & points
-- ============================================================

DO $$
DECLARE
  v_area_kallfass UUID;
  v_mach_pos85 UUID;
  v_mach_pos115 UUID;
  v_mach_pos120 UUID;
  v_mach_pos125 UUID;
  
  -- Lubricants
  v_lub_ep2 UUID;
  v_lub_plus2 UUID;
  v_lub_lglt2 UUID;
  v_lub_xp32 UUID;
  v_lub_gear150 UUID;
  
  -- Frequencies
  v_freq_daily UUID;
  v_freq_weekly UUID;
  v_freq_monthly UUID;
  v_freq_375h UUID;
  v_freq_2800h UUID;

BEGIN
  -- 1. Get Area IDs
  SELECT id INTO v_area_kallfass FROM areas WHERE name = 'Línea Principal Aserradero';

  -- 2. Get Lubricant IDs
  SELECT id INTO v_lub_ep2 FROM lubricants WHERE product_name = 'LITH EP 2';
  SELECT id INTO v_lub_plus2 FROM lubricants WHERE product_name = 'LITHPLUS EP 2';
  SELECT id INTO v_lub_lglt2 FROM lubricants WHERE product_name = 'LGLT 2';
  SELECT id INTO v_lub_xp32 FROM lubricants WHERE product_name = 'HYDRA XP 32';
  SELECT id INTO v_lub_gear150 FROM lubricants WHERE product_name = 'GEAR 150';

  -- 3. Get Frequency IDs
  SELECT id INTO v_freq_daily FROM frequencies WHERE label = '1x/día';
  SELECT id INTO v_freq_weekly FROM frequencies WHERE label = '1x/semana';
  SELECT id INTO v_freq_monthly FROM frequencies WHERE label = '1x/mes';
  SELECT id INTO v_freq_375h FROM frequencies WHERE label = 'c/375 hrs';
  SELECT id INTO v_freq_2800h FROM frequencies WHERE label = 'c/2800 hrs';

  -- ==========================================
  -- INSERT MACHINES
  -- ==========================================
  
  INSERT INTO machines (id, area_id, position_code, model_name, description, doc_reference)
  VALUES (uuid_generate_v4(), v_area_kallfass, 'Pos 85', 'VLT-600', 'Volteador de Trozos', '520378')
  RETURNING id INTO v_mach_pos85;

  INSERT INTO machines (id, area_id, position_code, model_name, description, doc_reference)
  VALUES (uuid_generate_v4(), v_area_kallfass, 'Pos 115', 'VFW-600', 'Alimentador de Trozos', '520379')
  RETURNING id INTO v_mach_pos115;

  INSERT INTO machines (id, area_id, position_code, model_name, description, doc_reference)
  VALUES (uuid_generate_v4(), v_area_kallfass, 'Pos 120', 'P-700', 'Perfiladora', 'P-700')
  RETURNING id INTO v_mach_pos120;

  INSERT INTO machines (id, area_id, position_code, model_name, description, doc_reference)
  VALUES (uuid_generate_v4(), v_area_kallfass, 'Pos 125', 'QSS-700L', 'Sierra Doble', 'QSS-700L')
  RETURNING id INTO v_mach_pos125;

  -- ==========================================
  -- INSERT LUBRICATION POINTS (Sample critical points)
  -- ==========================================

  -- Pos 115 (Alimentador)
  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, is_manual, task_type) VALUES
  (v_mach_pos115, v_lub_xp32, v_freq_daily, 1, 'Riel de presión de cadena', 1, true, 'lubrication'),
  (v_mach_pos115, v_lub_ep2, v_freq_weekly, 3, 'Eje cardán', 6, true, 'lubrication'),
  (v_mach_pos115, v_lub_ep2, v_freq_weekly, 7, 'Chumacera rodillos (plinto)', 8, false, 'lubrication'),
  (v_mach_pos115, v_lub_gear150, v_freq_monthly, 14, 'Motorreductor SEW', 1, true, 'inspection');

  -- Pos 120 (Perfiladora)
  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, is_manual, task_type, grammage_g) VALUES
  (v_mach_pos120, v_lub_xp32, v_freq_daily, 1, 'Cadena transportadora', 2, false, 'lubrication', NULL),
  (v_mach_pos120, v_lub_ep2, v_freq_weekly, 2, 'Chumacera lado transmisión', 2, false, 'lubrication', NULL),
  (v_mach_pos120, v_lub_plus2, v_freq_375h, 15, 'Rodamiento sup. cuchilla-lámina (LN4)', 1, true, 'lubrication', 5.0),
  (v_mach_pos120, v_lub_plus2, v_freq_375h, 17, 'Rodamiento sup. cuchilla-lámina (LN5)', 2, true, 'lubrication', 10.0);

  -- Pos 125 (Sierra Doble - Lado CRÍTICO)
  INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, num_points, is_manual, task_type, volume_ml, multiply_sides) VALUES
  (v_mach_pos125, v_lub_ep2, v_freq_monthly, 1, 'Bloques correderas', 26, false, 'lubrication', NULL, 2),
  (v_mach_pos125, v_lub_lglt2, v_freq_2800h, 11, 'Rodamiento husillo de sierra (CRÍTICO)', 2, true, 'lubrication', 10.0, 2);

END $$;
