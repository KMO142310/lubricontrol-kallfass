-- ============================================================
-- 05. SEED NEW AREAS & MACHINES
-- As per Audit Priorities for International Quality standard
-- Adds Sub-Suelo, Clasificación, Stacker, Baño Anti-Manchas
-- ============================================================

-- 1. INSERT/UPDATE AREAS
INSERT INTO areas (name, description) VALUES
  ('Sub-Suelo', 'Zona debajo de línea principal aserradero'),
  ('Clasificación', 'Área de singularizado, corte transversal y clasificación'),
  ('Stacker', 'Área de apilado automátizado de madera'),
  ('Baño Anti-Manchas', 'Tratamiento químico de paquetes de madera')
ON CONFLICT (name) DO NOTHING;

-- Also ensure Aserradero covers Kallfass properly if needed
-- We assume area 'Línea Principal Aserradero' from 01_initial_schema handles the Canter, etc.

DO $$
DECLARE
  area_aserradero UUID;
  area_subsuelo UUID;
  area_clasificacion UUID;
  area_stacker UUID;
  area_bano UUID;
BEGIN
  -- Get Area IDs
  SELECT id INTO area_aserradero FROM areas WHERE name = 'Línea Principal Aserradero' LIMIT 1;
  SELECT id INTO area_subsuelo FROM areas WHERE name = 'Sub-Suelo' LIMIT 1;
  SELECT id INTO area_clasificacion FROM areas WHERE name = 'Clasificación' LIMIT 1;
  SELECT id INTO area_stacker FROM areas WHERE name = 'Stacker' LIMIT 1;
  SELECT id INTO area_bano FROM areas WHERE name = 'Baño Anti-Manchas' LIMIT 1;

  -- ==========================================
  -- A. ASERRADERO ADDITIONAL MACHINES
  -- ==========================================
  -- 75=Barredor, 50=Mesa ingreso, 60=Stepfeeder...
  -- Using ON CONFLICT logic is tricky without a unique constraint, so we just insert blindly
  -- In a real prod migration we'd check existence, but for seed we assume it's fresh.
  
  INSERT INTO machines (area_id, position_code, model_name, description) VALUES
  (area_aserradero, 'Pos 75', 'Barredor', 'Barredor de corteza'),
  (area_aserradero, 'Pos 50', 'Mesa', 'Mesa de ingreso'),
  (area_aserradero, 'Pos 60', 'Stepfeeder', 'Stepfeeder / Dag'),
  (area_aserradero, 'Pos 70', 'Transportador', 'Primera cadena'),
  (area_aserradero, 'Pos 80', 'Transportador', 'Segunda cadena'),
  (area_aserradero, 'Pos 85', 'Giradores', 'Giradores de trozos'),
  (area_aserradero, 'Pos 90', 'Neumáticos', 'Neumáticos cargadores cadena (anterior Canter)'),
  (area_aserradero, 'Pos 100', 'Canter', 'Canter principal'),
  (area_aserradero, 'Pos 115', 'Rodillos', 'Rodillos de entrada perfiladora'),
  (area_aserradero, 'Pos 120', 'Perfiladora', 'Unidad de perfilado / fresado'),
  (area_aserradero, 'Pos 125', 'Sierra Doble', 'Sierras perfiladora'),
  (area_aserradero, 'Pos 130', 'Rodillos', 'Rodillos cargador cadena (separador laterales)'),
  (area_aserradero, 'Pos 135', 'Volteador', 'Volteador'),
  (area_aserradero, 'Pos 140', 'Rodillos', 'Rodillos entrada múltiple'),
  (area_aserradero, 'Pos 150', 'Sierra Múltiple', 'Sierra múltiple vertical'),
  (area_aserradero, 'Pos 160', 'Sierra Horizontal', 'Sierras horizontales'),
  (area_aserradero, 'Pos 170.01', 'Central Hidráulica', 'Central hidráulica 1'),
  (area_aserradero, 'Pos 170.02', 'Central Hidráulica', 'Central hidráulica 2'),
  (area_aserradero, 'Pos 170.03', 'Central Hidráulica', 'Central hidráulica 3'),
  (area_aserradero, 'Pos 170.04', 'Central Hidráulica', 'Central hidráulica 4'),
  (area_aserradero, 'Pos 180.01', 'Conveyor', 'Sistema de retorno 1'),
  (area_aserradero, 'Pos 180.02', 'Conveyor', 'Sistema de retorno 2'),
  (area_aserradero, 'Pos 180.03', 'Conveyor', 'Sistema de retorno 3'),
  (area_aserradero, 'Pos 180.04', 'Conveyor', 'Sistema de retorno 4'),
  (area_aserradero, 'Pos 180.05', 'Conveyor', 'Sistema de retorno 5'),
  (area_aserradero, 'Pos 180.06', 'Conveyor', 'Sistema de retorno 6'),
  (area_aserradero, 'Pos 180.07', 'Conveyor', 'Sistema de retorno 7'),
  (area_aserradero, 'Pos 190', 'Transportador', 'Transporte laterales a clasificación'),
  (area_aserradero, 'Pos 200', 'Transportador', 'Transporte centrales a clasificación');

  -- ==========================================
  -- B. SUB-SUELO MACHINES
  -- ==========================================
  INSERT INTO machines (area_id, position_code, model_name, description) VALUES
  (area_subsuelo, 'Pos 400', 'Vibratorio', 'Transportador vibratorio'),
  (area_subsuelo, 'Pos 410', 'Detector', 'Detector de metales'),
  (area_subsuelo, 'Pos 420', 'Astilladora', 'Astilladora de tambor'),
  (area_subsuelo, 'Pos 430', 'Harnero', 'Harnero/criba de viruta'),
  (area_subsuelo, 'Pos 440', 'Cadenas', 'Transporte cadena bajo línea aserradero'),
  (area_subsuelo, 'Pos 460', 'Cadenas', 'Transporte cadena salida astilladora'),
  (area_subsuelo, 'Pos 470', 'Cinta', 'Cinta retorno hacia astilladora'),
  (area_subsuelo, 'Pos 480', 'Cinta', 'Cinta aserrín hacia trinchera'),
  (area_subsuelo, 'Pos 490', 'Cinta', 'Cinta chip hacia trinchera');

  -- ==========================================
  -- C. CLASIFICACIÓN MACHINES
  -- ==========================================
  INSERT INTO machines (area_id, position_code, model_name, description) VALUES
  (area_clasificacion, 'Pos 600', 'Mesa', 'Mesa transporte laterales'),
  (area_clasificacion, 'Pos 610', 'Mesa', 'Mesa transporte centrales'),
  (area_clasificacion, 'Pos 620', 'Singularizador', 'Singularizador centrales'),
  (area_clasificacion, 'Pos 630', 'Singularizador', 'Singularizador laterales'),
  (area_clasificacion, 'Pos 615', 'Flap', 'Flap separador'),
  (area_clasificacion, 'Pos 640', 'Rodillos', 'Rodillos helicoidales'),
  (area_clasificacion, 'Pos 645', 'Corte', 'Corte transversal'),
  (area_clasificacion, 'Pos 650.01', 'Cadena', 'Cadena alimentación unitizador'),
  (area_clasificacion, 'Pos 650.02', 'Cinta', 'Cinta posterior a unitizador'),
  (area_clasificacion, 'Pos 660', 'Rotador', 'Rotador de tablas'),
  (area_clasificacion, 'Pos 670', 'Transportador', 'Transporte cadena con aditamentos'),
  (area_clasificacion, 'Pos 681', 'Cinta', 'Cinta transportadora despuntado'),
  (area_clasificacion, 'Pos 690', 'Transportador', 'Transportador de clasificación'),
  (area_clasificacion, 'Pos 695', 'Central Hidráulica', 'Central hidráulica de clasificación');

  -- ==========================================
  -- D. STACKER MACHINES
  -- ==========================================
  INSERT INTO machines (area_id, position_code, model_name, description) VALUES
  (area_stacker, 'Pos 700', 'Transportador', 'Transporte transversal bajo buzones'),
  (area_stacker, 'Pos 710', 'Transportador', 'Transporte transversal anterior a dosificación'),
  (area_stacker, 'Pos 720', 'Dosificador', 'Dosificador escalonado'),
  (area_stacker, 'Pos 730', 'Singularizador', 'Singularizador stacker'),
  (area_stacker, 'Pos 731', 'Transportador', 'Transportador transversal'),
  (area_stacker, 'Pos 732', 'Unitizador', 'Unitizador de piezas'),
  (area_stacker, 'Pos 733', 'Rodillos', 'Rodillos helicoidales de alineación'),
  (area_stacker, 'Pos 735', 'Sierra Doble', 'Sierra despuntadora doble'),
  (area_stacker, 'Pos 736', 'Cinta', 'Cinta transportadora'),
  (area_stacker, 'Pos 737', 'Cadenas', 'Cadena transversal con aditamentos'),
  (area_stacker, 'Pos 738', 'Cadenas', 'Transportadora transversal con flap clasificación'),
  (area_stacker, 'Pos 740.01', 'Apilador', 'Apilador de tablas 1'),
  (area_stacker, 'Pos 740.02', 'Apilador', 'Apilador de tablas 2'),
  (area_stacker, 'Pos 740.03', 'Apilador', 'Apilador de tablas 3'),
  (area_stacker, 'Pos 740.04', 'Apilador', 'Apilador de tablas 4'),
  (area_stacker, 'Pos 741', 'Magazine', 'Magazine de palillos'),
  (area_stacker, 'Pos 750', 'Transportador', 'Transporte transversal de paquetes');

  -- ==========================================
  -- E. BAÑO ANTI-MANCHAS MACHINES
  -- ==========================================
  INSERT INTO machines (area_id, position_code, model_name, description) VALUES
  (area_bano, 'Pos 205', 'Cama', 'Cama-tijera'),
  (area_bano, 'Pos 206', 'Recibidor', 'Recibidor de paquetes desde stacker'),
  (area_bano, 'Pos 207', 'Rodillos', 'Rodillos traslado a tornamesa'),
  (area_bano, 'Pos 208', 'Tornamesa', 'Tornamesa'),
  (area_bano, 'Pos 209', 'Mesa', 'Mesa rodillos de traslado'),
  (area_bano, 'Pos 210', 'Rodillos', 'Rodillos entrada enzunchadora'),
  (area_bano, 'Pos 211', 'Transportador', 'Salida auxiliar'),
  (area_bano, 'Pos 25',  'Mesa', 'Salida enzunchadora'),
  (area_bano, 'Pos 30',  'Cadena', 'Cadena entrada baño'),
  (area_bano, 'Pos 40',  'Rodillos', 'Rodillos entrada de baño'),
  (area_bano, 'Pos 50',  'Entrada', 'Entrada paquetes a baño / salida sin bañar'),
  (area_bano, 'Pos 60',  'Baño', 'Baño anti-manchas principal'),
  (area_bano, 'Pos 70',  'Cadena', 'Cadena salida baño'),
  (area_bano, 'Pos 80',  'Mesa', 'Mesa rodillos salida baño'),
  (area_bano, 'Pos 90',  'Escurridor', 'Escurridor derecho 1'),
  (area_bano, 'Pos 100', 'Escurridor', 'Escurridor izquierdo'),
  (area_bano, 'Pos 110', 'Escurridor', 'Escurridor derecho 2'),
  (area_bano, 'Pos 120', 'Mesa', 'Mesa de rodillos recta'),
  (area_bano, 'Pos 130', 'Mesa', 'Mesa cadena salida'),
  (area_bano, 'Pos 140', 'Mesa', 'Mesa rodillos final');

END $$;
