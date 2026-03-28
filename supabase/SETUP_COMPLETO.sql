-- ============================================================
-- Lubrication System — Initial Schema Migration
-- 14 Tables | Supabase (PostgreSQL 15+)
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. PROFILES (extends Supabase auth.users)
-- ============================================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL DEFAULT '',
  role TEXT NOT NULL DEFAULT 'lubricator' CHECK (role IN ('lubricator', 'supervisor', 'admin')),
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: Users can read their own profile; supervisors/admins read all
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Admins can view all profiles" ON profiles FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role IN ('supervisor', 'admin'))
);
CREATE POLICY "Admins can update profiles" ON profiles FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- ============================================================
-- 2. AREAS
-- ============================================================
CREATE TABLE areas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,        -- 'Kallfass', 'Bruks', 'SORSA'
  description TEXT
);

INSERT INTO areas (name, description) VALUES
  ('Línea Principal Aserradero', 'Línea principal de aserradero (Máquinas Kallfass) — 20 posiciones'),
  ('Bruks', 'Zona de astillado y transporte de corteza — Códigos 400-490'),
  ('SORSA', 'Enzunchadora automática — Código 110');

-- ============================================================
-- 3. MACHINES
-- ============================================================
CREATE TABLE machines (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  area_id UUID NOT NULL REFERENCES areas(id) ON DELETE CASCADE,
  position_code TEXT NOT NULL,       -- 'Pos 80', 'Pos 125'
  model_name TEXT NOT NULL,          -- 'VFW-600', 'QSS-700L'
  description TEXT NOT NULL DEFAULT '',
  doc_reference TEXT,                -- '520379', 'QSS-700L'
  image_url TEXT,
  qr_code TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 4. MACHINE COMPONENTS
-- ============================================================
CREATE TABLE machine_components (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  machine_id UUID NOT NULL REFERENCES machines(id) ON DELETE CASCADE,
  name TEXT NOT NULL,                -- 'Eje cardán', 'Chumacera lado transmisión'
  component_type TEXT NOT NULL DEFAULT 'other'
    CHECK (component_type IN ('bearing', 'gearmotor', 'chain', 'cylinder', 'spindle', 'roller', 'guide', 'other'))
);

-- ============================================================
-- 5. MACHINE IMAGES
-- ============================================================
CREATE TABLE machine_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  machine_id UUID NOT NULL REFERENCES machines(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  image_type TEXT NOT NULL DEFAULT 'diagram'
    CHECK (image_type IN ('diagram', 'photo', 'schematic')),
  description TEXT,
  page_number INTEGER
);

-- ============================================================
-- 6. LUBRICANTS (Catálogo ESMAX + SKF)
-- ============================================================
CREATE TABLE lubricants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  brand TEXT NOT NULL,               -- 'ESMAX LUBRAX', 'SKF'
  product_name TEXT NOT NULL,        -- 'LITH EP 2', 'LGLT 2'
  type TEXT NOT NULL CHECK (type IN ('grease', 'oil')),
  kallfass_group TEXT,               -- 'Group I', 'Group V'
  viscosity TEXT,
  presentation TEXT,
  notes TEXT
);

-- Seed ESMAX catalog
INSERT INTO lubricants (brand, product_name, type, kallfass_group, viscosity, presentation, notes) VALUES
  ('ESMAX LUBRAX', 'HYDRA XP 32', 'oil', 'Group I', 'ISO 32', 'Tambor 208 Lt', 'Aceite de cadena, penetración'),
  ('ESMAX LUBRAX', 'HYDRA XP 68', 'oil', 'Group II', 'ISO 68', 'Tambor 208 Lt', 'Aceite hidráulico multiuso, rodillos'),
  ('ESMAX LUBRAX', 'GL-5 80W/90', 'oil', NULL, '80W-90', 'Tambor 208 Lt', 'Aceite de transmisión'),
  ('ESMAX LUBRAX', 'GEAR 150', 'oil', 'Group III', 'ISO 150', 'Tambor 208 Lt', 'Motorreductores SEW (verificar placa)'),
  ('ESMAX LUBRAX', 'LITH EP 2', 'grease', 'Group V', 'NLGI 2', 'Tambor 181 Kg', 'Grasa EP base litio uso general'),
  ('ESMAX LUBRAX', 'LITHPLUS EP 2', 'grease', 'Group V', 'NLGI 2', 'Tambor 170 Kg', 'Grasa EP complejo de litio, alta exigencia'),
  ('SKF', 'LGLT 2', 'grease', 'Group IV', 'NLGI 2 (PAO)', 'Balde 1 Kg', 'CRÍTICA: Grasa sintética alta velocidad para husillos. SIN EQUIVALENTE ESMAX.');

-- ============================================================
-- 7. KALLFASS GROUPS (Mapeo)
-- ============================================================
CREATE TABLE kallfass_groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_number INTEGER NOT NULL UNIQUE CHECK (group_number BETWEEN 1 AND 5),
  group_name TEXT NOT NULL,
  application TEXT NOT NULL,
  lubricant_id UUID NOT NULL REFERENCES lubricants(id)
);

-- ============================================================
-- 8. FREQUENCIES
-- ============================================================
CREATE TABLE frequencies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  label TEXT NOT NULL UNIQUE,        -- '1x/día', '1x/semana', 'c/375 hrs'
  interval_hours INTEGER,            -- 8, 56, 375, 2800
  interval_days INTEGER,             -- 1, 7, 14, 30, 90, 365
  description TEXT
);

INSERT INTO frequencies (label, interval_days, interval_hours, description) VALUES
  ('1x/día', 1, 8, 'Diaria — cada turno de 8 horas'),
  ('1x/semana', 7, 56, 'Semanal'),
  ('2x/mes', 15, NULL, 'Quincenal'),
  ('1x/mes', 30, NULL, 'Mensual'),
  ('c/375 hrs', NULL, 375, 'Cada 375 horas de operación (~47 días en 1 turno)'),
  ('c/2800 hrs', NULL, 2800, 'Cada 2.800 horas de operación (~350 días en 1 turno)'),
  ('Trimestral', 90, NULL, 'Cada 3 meses'),
  ('Anual', 365, NULL, 'Anual o cada 4.000 horas'),
  ('c/7 semanas', 49, NULL, 'Cada 7 semanas (~350 horas en 1 turno)'),
  ('Al cambiar sierras', NULL, NULL, 'Evento: cuando se reemplazan las sierras'),
  ('Según placa', NULL, NULL, 'Según instrucciones del fabricante (motor ABB)');

-- ============================================================
-- 9. LUBRICATION POINTS (el corazón del sistema)
-- ============================================================
CREATE TABLE lubrication_points (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  machine_id UUID NOT NULL REFERENCES machines(id) ON DELETE CASCADE,
  component_id UUID REFERENCES machine_components(id),
  lubricant_id UUID NOT NULL REFERENCES lubricants(id),
  frequency_id UUID NOT NULL REFERENCES frequencies(id),
  item_number INTEGER NOT NULL,
  description TEXT NOT NULL,
  task_type TEXT NOT NULL DEFAULT 'lubrication'
    CHECK (task_type IN ('lubrication', 'inspection', 'cleaning')),
  num_points INTEGER NOT NULL DEFAULT 1,
  grammage_g DECIMAL,               -- NULL = 'Estándar' (usar fórmula SKF)
  volume_ml DECIMAL,                -- For SKF LGLT 2 (cm³)
  pumps_approx INTEGER,
  is_manual BOOLEAN NOT NULL DEFAULT false,
  x_coord DECIMAL,
  y_coord DECIMAL,
  notes TEXT,
  multiply_sides INTEGER DEFAULT 1   -- 2 for QSS-700L
);

-- ============================================================
-- 10. SHIFTS (Turnos A/B)
-- ============================================================
CREATE TABLE shifts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shift_type TEXT NOT NULL CHECK (shift_type IN ('A', 'B')),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT false
);

-- ============================================================
-- 11. DAILY TASKS (Dual-Task Engine)
-- ============================================================
CREATE TABLE daily_tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lubrication_point_id UUID NOT NULL REFERENCES lubrication_points(id) ON DELETE CASCADE,
  assigned_user_id UUID NOT NULL REFERENCES profiles(id),
  shift_id UUID REFERENCES shifts(id),
  scheduled_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'completed', 'skipped', 'anomaly')),
  completed_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ              -- NULL until synced from offline
);

CREATE INDEX idx_daily_tasks_user_date ON daily_tasks (assigned_user_id, scheduled_date);
CREATE INDEX idx_daily_tasks_status ON daily_tasks (status, scheduled_date);

-- ============================================================
-- 12. COMPLETION LOGS
-- ============================================================
CREATE TABLE completion_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lubrication_point_id UUID NOT NULL REFERENCES lubrication_points(id),
  user_id UUID NOT NULL REFERENCES profiles(id),
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  grammage_used_g DECIMAL,
  status TEXT NOT NULL CHECK (status IN ('completed', 'skipped', 'anomaly')),
  anomaly_report_id UUID,
  synced_at TIMESTAMPTZ
);

CREATE INDEX idx_completion_logs_point ON completion_logs (lubrication_point_id, completed_at DESC);

-- ============================================================
-- 13. ANOMALY REPORTS
-- ============================================================
CREATE TABLE anomaly_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lubrication_point_id UUID NOT NULL REFERENCES lubrication_points(id),
  user_id UUID NOT NULL REFERENCES profiles(id),
  anomaly_type TEXT NOT NULL CHECK (anomaly_type IN ('leak', 'noise', 'vibration', 'temperature', 'other')),
  description TEXT,
  media_url TEXT,                    -- Supabase Storage path
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved BOOLEAN NOT NULL DEFAULT false,
  synced_at TIMESTAMPTZ
);

-- Add FK from completion_logs to anomaly_reports
ALTER TABLE completion_logs
  ADD CONSTRAINT fk_anomaly_report
  FOREIGN KEY (anomaly_report_id) REFERENCES anomaly_reports(id);

-- ============================================================
-- 14. CONSUMPTION LOGS
-- ============================================================
CREATE TABLE consumption_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lubricant_id UUID NOT NULL REFERENCES lubricants(id),
  area_id UUID REFERENCES areas(id),
  quantity_kg DECIMAL,
  quantity_liters DECIMAL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  recorded_by UUID NOT NULL REFERENCES profiles(id),
  notes TEXT
);

-- ============================================================
-- RLS POLICIES (for key operational tables)
-- ============================================================

-- Daily Tasks: lubricators see only their own tasks
ALTER TABLE daily_tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lubricators see own tasks" ON daily_tasks FOR SELECT USING (
  assigned_user_id = auth.uid()
  OR EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role IN ('supervisor', 'admin'))
);
CREATE POLICY "Lubricators can update own tasks" ON daily_tasks FOR UPDATE USING (assigned_user_id = auth.uid());
CREATE POLICY "Supervisors can insert tasks" ON daily_tasks FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role IN ('supervisor', 'admin'))
);

-- Completion Logs: lubricators can insert, supervisors can read all
ALTER TABLE completion_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users insert own logs" ON completion_logs FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "All can read logs" ON completion_logs FOR SELECT USING (
  user_id = auth.uid()
  OR EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role IN ('supervisor', 'admin'))
);

-- Anomaly Reports
ALTER TABLE anomaly_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users insert own anomalies" ON anomaly_reports FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "All can read anomalies" ON anomaly_reports FOR SELECT USING (true);

-- Read-only tables for everyone
ALTER TABLE areas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read areas" ON areas FOR SELECT USING (true);

ALTER TABLE machines ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read machines" ON machines FOR SELECT USING (true);

ALTER TABLE lubricants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read lubricants" ON lubricants FOR SELECT USING (true);

ALTER TABLE frequencies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read frequencies" ON frequencies FOR SELECT USING (true);

ALTER TABLE lubrication_points ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read lubrication points" ON lubrication_points FOR SELECT USING (true);

ALTER TABLE machine_components ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read components" ON machine_components FOR SELECT USING (true);

ALTER TABLE machine_images ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read images" ON machine_images FOR SELECT USING (true);

ALTER TABLE kallfass_groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read groups" ON kallfass_groups FOR SELECT USING (true);

ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read shifts" ON shifts FOR SELECT USING (true);

ALTER TABLE consumption_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users insert own consumption" ON consumption_logs FOR INSERT WITH CHECK (recorded_by = auth.uid());
CREATE POLICY "All can read consumption" ON consumption_logs FOR SELECT USING (true);
-- ============================================================
-- 04. AUTH TRIGGER
-- Automatically creates a profile when a new user signs up in Supabase Auth
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    new.id, 
    new.email, 
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    COALESCE(new.raw_user_meta_data->>'role', 'lubricator')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger the function every time a user is created
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
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
-- ============================================================
-- 07. FIX AUTH USERS (v2)
-- Ejecutar este script en el SQL EDITOR de Supabase
-- ============================================================

-- 1. Limpiar usuarios previos para evitar conflictos
DELETE FROM auth.users WHERE email IN ('admin@planta.local', 'supervisor1@planta.local', 'lubricador1@planta.local');

DO $$
DECLARE
  uid_admin uuid := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
  uid_supervisor uuid := 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12';
  uid_lubricador uuid := 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13';
BEGIN
  -- 2. Insertar Usuario Admin
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, 
    email_confirmed_at, recovery_sent_at, last_sign_in_at, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at, 
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES (
    uid_admin, 'authenticated', 'authenticated', 
    'admin@planta.local', crypt('lubricontrol2026', gen_salt('bf')), 
    now(), NULL, now(), 
    '{"provider":"email","providers":["email"]}', '{"full_name":"Administrador de Planta"}', 
    now(), now(), '', '', '', ''
  );

  -- 3. Insertar Usuario Supervisor
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, 
    email_confirmed_at, recovery_sent_at, last_sign_in_at, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at, 
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES (
    uid_supervisor, 'authenticated', 'authenticated', 
    'supervisor1@planta.local', crypt('lubricontrol2026', gen_salt('bf')), 
    now(), NULL, now(), 
    '{"provider":"email","providers":["email"]}', '{"full_name":"Supervisor de Turno A"}', 
    now(), now(), '', '', '', ''
  );

  -- 4. Insertar Usuario Lubricador
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, 
    email_confirmed_at, recovery_sent_at, last_sign_in_at, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at, 
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES (
    uid_lubricador, 'authenticated', 'authenticated', 
    'lubricador1@planta.local', crypt('lubricontrol2026', gen_salt('bf')), 
    now(), NULL, now(), 
    '{"provider":"email","providers":["email"]}', '{"full_name":"Juan Pérez (Lubricador)"}', 
    now(), now(), '', '', '', ''
  );

  -- 5. Asegurar perfiles en public.profiles
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES 
    (uid_admin, 'admin@planta.local', 'Administrador de Planta', 'admin'),
    (uid_supervisor, 'supervisor1@planta.local', 'Supervisor de Turno A', 'supervisor'),
    (uid_lubricador, 'lubricador1@planta.local', 'Juan Pérez (Lubricador)', 'lubricator')
  ON CONFLICT (id) DO UPDATE SET role = EXCLUDED.role;

END $$;
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
--- GENERAR TAREAS HOY ---
SELECT generate_daily_tasks(CURRENT_DATE) AS tareas_generadas_hoy;
SELECT
  (SELECT COUNT(*) FROM machines) AS maquinas,
  (SELECT COUNT(*) FROM lubrication_points) AS puntos,
  (SELECT COUNT(*) FROM daily_tasks WHERE scheduled_date = CURRENT_DATE) AS tareas_hoy,
  (SELECT COUNT(*) FROM profiles) AS usuarios;
