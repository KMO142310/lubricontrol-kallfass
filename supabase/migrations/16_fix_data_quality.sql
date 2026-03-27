-- ============================================================
-- 16. CORRECCIÓN DE CALIDAD DE DATOS
-- ============================================================

-- 1. Corregir descripción de Pos 80 (tenía markdown en el campo)
UPDATE public.machines
SET description = 'Transportador de Medición'
WHERE position_code = 'Pos 80'
  AND description LIKE '%###%';

-- 2. Asignar gramajes estándar por grupo Kallfass donde grammage_g es NULL
-- Fuente: Plan Maestro Lubricación Kallfass — valores típicos de campo
-- Group I (aceite cadenas): aplicar con aceitera, ~10 ml/punto → no grammage
-- Group V (grasa rodamientos): estándar 5g por palancazo, chumacera 3-5g
-- QSS-700L husillo (Group IV / SKF LGLT 2): 5 cm³ por rodamiento

-- Actualizar puntos con lubricante LITH EP 2 o LITHPLUS EP 2 sin gramaje
UPDATE public.lubrication_points lp
SET grammage_g = 5
WHERE lp.grammage_g IS NULL
  AND lp.volume_ml IS NULL
  AND lp.task_type = 'lubrication'
  AND EXISTS (
    SELECT 1 FROM public.lubricants l
    WHERE l.id = lp.lubricant_id
      AND l.type = 'grease'
      AND l.product_name NOT IN ('LGLT 2')
  );

-- Puntos con SKF LGLT 2: usar volumen en lugar de gramaje (ya configurado)
-- Si aún está NULL, establecer 5 cm³
UPDATE public.lubrication_points lp
SET volume_ml = 5
WHERE lp.grammage_g IS NULL
  AND lp.volume_ml IS NULL
  AND EXISTS (
    SELECT 1 FROM public.lubricants l
    WHERE l.id = lp.lubricant_id
      AND l.product_name = 'LGLT 2'
  );

-- 3. Asegurar que los puntos tengan num_points >= 1
UPDATE public.lubrication_points
SET num_points = 1
WHERE num_points IS NULL OR num_points = 0;

-- 4. Agregar imágenes de manuales a las máquinas (URLs de PDFs en /manuals/)
-- Solo si no existen ya
INSERT INTO public.machine_images (machine_id, image_url, image_type, description, page_number)
SELECT m.id, '/manuals/' || mi.pdf_file, 'diagram', 'Manual de Lubricación ' || m.position_code, 1
FROM public.machines m
JOIN (VALUES
  ('Pos 80',    'Lubrication_Measuring_conveyor_520685_en.pdf'),
  ('Pos 85',    'Lubrication_instruction_VLT-600_520378_en.pdf'),
  ('Pos 115',   'Lubrication_instruction_VFW-600_520379_en.pdf'),
  ('Pos 120',   'Lubrication_P-700_en.pdf'),
  ('Pos 125',   'Lubrication_QSS-700L_en.pdf'),
  ('Pos 130',   'Lubrication_520391_BR-610JR_en.pdf'),
  ('Pos 135',   'Lubrication_CT-100_en.pdf'),
  ('Pos 140',   'Lubrication_instruction_520394_Feed_work_500A_en.pdf'),
  ('Pos 160',   'Lubrication_HDSV-700_en.pdf'),
  ('Pos 180.1', 'Lubrication_Roll_conveyor_520595_en.pdf'),
  ('Pos 180.2', 'Lubrication_Side_conveyor_520542_en.pdf'),
  ('Pos 180.3', 'Lubrication_Roll_conveyor_520632_en.pdf'),
  ('Pos 180.4', 'Lubrication_Belt_conveyor_520721_en.pdf'),
  ('Pos 180.5', 'Lubrication_Roll_conveyor_520651_en.pdf'),
  ('Pos 180.6', 'Lubrication_Side_conveyor_520581_en.pdf'),
  ('Pos 190.1', 'Lubrication_Side_conveyor_520774_en.pdf'),
  ('Pos 190.2', 'Lubrication_Belt_conveyor_520860_en.pdf'),
  ('Pos 190.3', 'Lubrication_Rooftop_520715_en.pdf'),
  ('Pos 200.1', 'Lubrication_Belt_conveyor_520677_en.pdf'),
  ('Pos 200.2', 'Lubrication_Rooftop_520718_en.pdf')
) AS mi(pos, pdf_file) ON m.position_code = mi.pos
WHERE NOT EXISTS (
  SELECT 1 FROM public.machine_images mi2
  WHERE mi2.machine_id = m.id AND mi2.image_type = 'diagram'
);

-- 5. Reporte final
SELECT
  (SELECT COUNT(*) FROM machines) AS total_machines,
  (SELECT COUNT(*) FROM lubrication_points) AS total_points,
  (SELECT COUNT(*) FROM lubrication_points WHERE grammage_g IS NOT NULL) AS points_with_grammage,
  (SELECT COUNT(*) FROM daily_tasks WHERE scheduled_date = CURRENT_DATE) AS today_tasks,
  (SELECT COUNT(*) FROM machine_images) AS machine_images;
