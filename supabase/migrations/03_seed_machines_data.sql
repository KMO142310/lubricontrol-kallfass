-- ==========================================================
-- Seeding 9 Machines and 99 Points from machines_data.json
-- Generated: 2026-03-27T12:15:23.053Z
-- ==========================================================

-- Pos 80 — Measure Conveyor
INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, 'Pos 80', 'Measure Conveyor', '### Pos 80 — Measure Conveyor (Transportador de Medición) | Doc. 520685', NULL
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = 'Pos 80');

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 80' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'HYDRA XP 32' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/día' LIMIT 1),
  1, 'Cadena transportadora', 'lubrication',
  1, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 80' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  2, 'Rodamiento', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 80' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  3, 'Chumacera con brida', 'lubrication',
  8, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 80' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  4, 'Chumacera con brida', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 80' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  5, 'Motorreductor SEW', 'lubrication',
  1, NULL, NULL,
  false, NULL
);

-- Pos 85 — VLT-600
INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, 'Pos 85', 'VLT-600', 'Volteador de Trozos', '520378'
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = 'Pos 85');

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 85' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  1, 'Rodillo con púas, rodamiento', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 85' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  2, 'Rodillo con púas, nipple', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 85' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  3, 'Brazo centrador, rodamiento', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 85' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  4, 'Barra paralela, oreja', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 85' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  5, 'Barra paralela, oreja', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 85' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  6, 'Soporte cilindro', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 85' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  7, 'Soporte cilindro', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 85' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  8, 'Eje guía, nipple', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 85' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  9, 'Motorreductor SEW', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

-- Pos 115 — VFW-600
INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, 'Pos 115', 'VFW-600', 'Alimentador de Trozos', '520379'
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = 'Pos 115');

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'HYDRA XP 32' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/día' LIMIT 1),
  1, 'Riel de presión de cadena', 'lubrication',
  1, NULL, NULL,
  true, 'Manual (M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'HYDRA XP 32' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  2, 'Piñón dentado', 'lubrication',
  1, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  3, 'Eje cardán', 'lubrication',
  6, NULL, NULL,
  true, 'Manual (M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  4, 'Bloque corredera (plinto)', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  5, 'Bloque corredera (nipple)', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  6, 'Rodamiento piñón (plinto)', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  7, 'Chumacera rodillos (plinto)', 'lubrication',
  8, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  8, 'Chumacera riel de presión', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  9, 'Nariz de riel de presión', 'lubrication',
  1, NULL, NULL,
  true, 'Manual (M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  10, 'Bloque rodamiento servo cilindro', 'lubrication',
  8, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  11, 'Oreja vástago pistón servo', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  12, 'Oreja vástago pistón cilindro', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  13, 'Bloque rodamiento cilindro', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  14, 'Motorreductor SEW (×1)', 'lubrication',
  1, NULL, NULL,
  true, 'Manual (M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 115' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  15, 'Motorreductor SEW (×2)', 'lubrication',
  2, NULL, NULL,
  true, 'Manual (M)'
);

-- Pos 120 — P-700
INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, 'Pos 120', 'P-700', 'Perfiladora', 'P-700'
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = 'Pos 120');

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'HYDRA XP 32' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/día' LIMIT 1),
  1, 'Cadena transportadora', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  2, 'Chumacera lado transmisión', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  3, 'Chumacera rodillo con púas', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  4, 'Chumacera inferior, brazos centradores', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  5, 'Chumacera rodillos', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  6, 'Unidad rodamiento, brazos centradores', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  7, 'Chumacera rodillo con púas', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  8, 'Unidad rodamiento, rueda cadena', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  9, 'Soporte cilindro', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'HYDRA XP 32' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/día' LIMIT 1),
  10, 'Cadena rodillo con púas', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  11, 'Soporte cilindro', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  12, 'Soporte cilindro', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  13, 'Soporte barra paralela', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  14, 'Motorreductores SEW (×6)', 'lubrication',
  6, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'c/375 hrs' LIMIT 1),
  15, 'Rodamiento sup. cuchilla-lámina preening (LN4)', 'lubrication',
  1, 5, NULL,
  true, '(M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'c/375 hrs' LIMIT 1),
  16, 'Rodamiento inf. cuchilla-lámina preening (LN6)', 'lubrication',
  1, 5, NULL,
  true, '(M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'c/375 hrs' LIMIT 1),
  18, 'Rodamiento inf. cuchilla-lámina preening (LN6)', 'lubrication',
  1, 5, NULL,
  true, '(M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'c/375 hrs' LIMIT 1),
  19, 'Tapa rodamiento superior splines', 'lubrication',
  1, 5, NULL,
  true, '(M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'c/375 hrs' LIMIT 1),
  20, 'Tapa rodamiento inferior splines', 'lubrication',
  1, 5, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'c/375 hrs' LIMIT 1),
  21, 'Tapa rodamiento inferior', 'lubrication',
  1, 5, NULL,
  true, '(M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'c/375 hrs' LIMIT 1),
  15, 'Rodamiento sup. cuchilla-lámina preening (LN5)', 'lubrication',
  2, 10, NULL,
  true, '(M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'Según placa' LIMIT 1),
  22, 'Motor eléctrico ABB cortadores', 'lubrication',
  3, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE brand = 'ESMAX LUBRAX' AND type = 'grease' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  23, 'Ejes estriados — limpieza', 'inspection',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 120' LIMIT 1),
  (SELECT id FROM lubricants WHERE brand = 'ESMAX LUBRAX' AND type = 'grease' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  24, 'Guías — limpieza', 'inspection',
  4, NULL, NULL,
  false, NULL
);

-- Pos 125 — QSS-700L
INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, 'Pos 125', 'QSS-700L', 'Sierra Doble', 'QSS-700L'
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = 'Pos 125');

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '2x/mes' LIMIT 1),
  1, 'Bloques correderas', 'lubrication',
  26, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '2x/mes' LIMIT 1),
  2, 'Husillo de bolas / tornillo', 'lubrication',
  2, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '2x/mes' LIMIT 1),
  3, 'Soporte cilindro', 'lubrication',
  8, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '2x/mes' LIMIT 1),
  4, 'Soporte vástago pistón', 'lubrication',
  2, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  5, 'Rodamiento rodillo no accionado', 'lubrication',
  1, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  6, 'Motorreductor SEW', 'lubrication',
  2, NULL, NULL,
  false, '—'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'c/7 semanas' LIMIT 1),
  7, 'Motor husillo, lado transmisión', 'lubrication',
  2, 100, NULL,
  false, '100g / rodamiento'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'Anual' LIMIT 1),
  7, 'Motor husillo, lado ventilador', 'lubrication',
  2, 60, NULL,
  false, '60g / rodamiento'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'Trimestral' LIMIT 1),
  8, 'Motor de corte ABB', 'lubrication',
  2, 40, NULL,
  false, '40g / rodamiento'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  9, 'Bloques correderas, cubierta', 'lubrication',
  4, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'Al cambiar sierras' LIMIT 1),
  10, 'Unidad rodamiento husillo', 'lubrication',
  2, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 125' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LGLT 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'c/2800 hrs' LIMIT 1),
  11, 'Rodamiento husillo de sierra', 'lubrication',
  1, NULL, 10,
  false, '10 cm³'
);

-- Pos 130 — BR-610JR
INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, 'Pos 130', 'BR-610JR', 'Transportador de Tablas + Riel Central', '520391'
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = 'Pos 130');

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'HYDRA XP 32' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/día' LIMIT 1),
  1, 'Cadena', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  2, 'Chumacera brida, lado transmisión', 'lubrication',
  3, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  3, 'Chumacera brida, rodillo con púas', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  4, 'Chumacera brida inferior, brazos centradores', 'lubrication',
  8, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  5, 'Chumacera brida, rodillos', 'lubrication',
  16, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  6, 'Unidad rodamiento, brazos centradores', 'lubrication',
  8, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  7, 'Chumacera brida, rodillo con púas', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  8, 'Unidad rodamiento, rueda cadena', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  9, 'Soporte cilindro', 'lubrication',
  1, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'HYDRA XP 32' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/día' LIMIT 1),
  10, 'Cadena rodillo con púas', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  11, 'Soporte cilindro', 'lubrication',
  3, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  12, 'Soporte cilindro', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  13, 'Soporte barra paralela', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 130' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  14, 'Motorreductores SEW (×6)', 'lubrication',
  6, NULL, NULL,
  false, NULL
);

-- Pos 135 — CT-100
INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, 'Pos 135', 'CT-100', 'Cross Transfer', 'CT-100'
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = 'Pos 135');

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 135' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'HYDRA XP 68' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'Según placa' LIMIT 1),
  1, 'Rodillo', 'lubrication',
  1, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 135' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  2, 'Soporte cilindro', 'lubrication',
  3, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 135' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  3, 'Rodamiento', 'lubrication',
  2, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 135' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  4, 'Rodamiento', 'lubrication',
  1, NULL, NULL,
  false, NULL
);

-- Pos 140 — 500A
INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, 'Pos 140', '500A', 'Feed Work / Rodillos de Avance', '520394'
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = 'Pos 140');

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 140' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  1, 'Rodillos de avance, rodamiento', 'lubrication',
  8, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 140' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  2, 'Guías de eje', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 140' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  3, 'Brazo paralelo, rodamiento', 'lubrication',
  4, NULL, NULL,
  false, NULL
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 140' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  4, 'Cilindro hidráulico/servo, bloque rodamiento', 'lubrication',
  4, NULL, NULL,
  true, '(M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 140' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  5, 'Cilindro neumático, soporte medio', 'lubrication',
  4, NULL, NULL,
  true, '(M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 140' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  7, 'Cilindro neumático, rodamiento articulación', 'lubrication',
  2, NULL, NULL,
  true, '(M)'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 140' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  6, 'Motorreductores SEW (×4)', 'lubrication',
  4, NULL, NULL,
  true, '(M)'
);

-- Pos 160 — HDSV-700W
INSERT INTO machines (area_id, position_code, model_name, description, doc_reference)
SELECT id, 'Pos 160', 'HDSV-700W', 'Sierra de Doble Eje', 'HDSV-700W'
FROM areas WHERE name = 'Línea Principal Aserradero'
AND NOT EXISTS (SELECT 1 FROM machines WHERE position_code = 'Pos 160');

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 160' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/semana' LIMIT 1),
  1, 'Bloques correderas', 'lubrication',
  10, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 160' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  2, 'Eje cardán', 'lubrication',
  6, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 160' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  3, 'Cajas de rodamientos', 'lubrication',
  4, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 160' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  4, 'Rodamiento de pie (plummer block)', 'lubrication',
  2, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 160' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  5, 'Soporte cilindro', 'lubrication',
  1, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 160' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  6, 'Oreja vástago pistón', 'lubrication',
  1, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 160' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITH EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = '1x/mes' LIMIT 1),
  7, 'Buje de rodamiento', 'lubrication',
  2, NULL, NULL,
  false, 'Estándar'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 160' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'LITHPLUS EP 2' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'Anual' LIMIT 1),
  8, 'Motor eléctrico', 'lubrication',
  2, 100, NULL,
  false, '100g lado transmisión / 60g lado ventilador'
);

INSERT INTO lubrication_points (machine_id, lubricant_id, frequency_id, item_number, description, task_type, num_points, grammage_g, volume_ml, is_manual, notes)
VALUES (
  (SELECT id FROM machines WHERE position_code = 'Pos 160' LIMIT 1),
  (SELECT id FROM lubricants WHERE product_name = 'GEAR 150' LIMIT 1),
  (SELECT id FROM frequencies WHERE label = 'Anual' LIMIT 1),
  9, 'Motorreductor SEW', 'lubrication',
  2, NULL, NULL,
  false, '—'
);

