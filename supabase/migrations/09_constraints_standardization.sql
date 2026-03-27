-- = ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- 09. CONSTRAINTS & STANDARDIZATION
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-- 1. Añadir restricción UNICA a position_code para permitir ON CONFLICT
-- Primero eliminamos duplicados si existieran (basado en el código más reciente)
DELETE FROM machines a USING machines b 
WHERE a.id < b.id AND a.position_code = b.position_code;

ALTER TABLE machines ADD CONSTRAINT machines_position_code_key UNIQUE (position_code);

-- 2. Estandarizar códigos (quitar el .0 innecesario para match con Manuales)
UPDATE machines SET position_code = 'Pos 180.1' WHERE position_code IN ('Pos 180.01', 'Pos 180.1');
UPDATE machines SET position_code = 'Pos 180.2' WHERE position_code IN ('Pos 180.02', 'Pos 180.2');
UPDATE machines SET position_code = 'Pos 180.3' WHERE position_code IN ('Pos 180.03', 'Pos 180.3');
UPDATE machines SET position_code = 'Pos 180.4' WHERE position_code IN ('Pos 180.04', 'Pos 180.4');
UPDATE machines SET position_code = 'Pos 180.5' WHERE position_code IN ('Pos 180.05', 'Pos 180.5');
UPDATE machines SET position_code = 'Pos 180.6' WHERE position_code IN ('Pos 180.06', 'Pos 180.6');
UPDATE machines SET position_code = 'Pos 180.7' WHERE position_code IN ('Pos 180.07', 'Pos 180.7');

-- 3. Limpiar puntos de lubricación huérfanos o duplicados antes de re-sembrar
-- (Opcional, pero recomendado para evitar basura en desarrollo)
DELETE FROM lubrication_points WHERE machine_id IN (
  SELECT id FROM machines WHERE position_code LIKE 'Pos 180%' 
  OR position_code LIKE 'Pos 190%' 
  OR position_code LIKE 'Pos 200%'
);
