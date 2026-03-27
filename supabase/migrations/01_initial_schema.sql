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
