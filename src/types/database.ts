/* ============================================================
 *  Database Types — Lubrication System (14 tables)
 *  Auto-generated stub. Replace with `supabase gen types` later.
 * ============================================================ */

export type UserRole = 'lubricator' | 'supervisor' | 'admin';
export type TaskType = 'lubrication' | 'inspection' | 'cleaning';
export type TaskStatus = 'completed' | 'skipped' | 'anomaly';
export type AnomalyType = 'leak' | 'noise' | 'vibration' | 'temperature' | 'other';
export type ShiftType = 'A' | 'B';

export interface Profile {
  id: string;
  email: string;
  full_name: string;
  role: UserRole;
  avatar_url?: string;
  created_at: string;
}

export interface Area {
  id: string;
  name: string; // 'Línea Principal Aserradero', 'Bruks', 'SORSA'
  description?: string;
}

export interface Machine {
  id: string;
  area_id: string;
  position_code: string;   // 'Pos 115', 'Pos 125'
  model_name: string;      // 'VFW-600', 'QSS-700L'
  description: string;     // 'Alimentador de Trozos'
  doc_reference: string;   // '520379', 'QSS-700L'
  image_url?: string;      // Main diagram from Kallfass PDF
  qr_code?: string;        // '/m/115'
  created_at: string;
}

export interface MachineComponent {
  id: string;
  machine_id: string;
  name: string;            // 'Eje cardán', 'Chumacera lado transmisión'
  component_type: string;  // 'bearing', 'gearmotor', 'chain', 'cylinder', 'spindle'
}

export interface Lubricant {
  id: string;
  brand: string;           // 'ESMAX LUBRAX', 'SKF'
  product_name: string;    // 'LITH EP 2', 'LGLT 2'
  type: 'grease' | 'oil';
  kallfass_group?: string;  // 'Group I', 'Group V'
  viscosity?: string;       // 'ISO 68', 'NLGI 2'
  presentation?: string;    // 'Tambor 208 Lt', 'Balde 1 Kg'
  notes?: string;
}

export interface KallfassGroup {
  id: string;
  group_number: number;    // 1, 2, 3, 4, 5
  group_name: string;      // 'Group I'
  application: string;     // 'Cadenas transportadoras'
  lubricant_id: string;    // FK -> lubricants
}

export interface Frequency {
  id: string;
  label: string;           // '1x/día', '1x/semana', 'c/375 hrs'
  interval_hours?: number; // 8, 56, 375, 2800
  interval_days?: number;  // 1, 7, 14, 30
  description?: string;
}

export interface LubricationPoint {
  id: string;
  machine_id: string;
  component_id?: string;
  lubricant_id: string;
  frequency_id: string;
  item_number: number;     // Item from Kallfass manual
  description: string;     // 'Cadena transportadora'
  task_type: TaskType;     // 'lubrication', 'inspection', 'cleaning'
  num_points: number;      // Number of physical nipples
  grammage_g?: number;     // Exact grams (null = 'Estándar')
  volume_ml?: number;      // cm³ (for SKF LGLT 2)
  pumps_approx?: number;   // Approximate pump strokes
  is_manual: boolean;      // (M) points
  x_coord?: number;        // Hotspot X on diagram
  y_coord?: number;        // Hotspot Y on diagram
  notes?: string;          // 'Retirar tapón, instalar nipple temporal'
  multiply_sides?: number; // 2 for QSS-700L (×2 lados)
}

export interface Shift {
  id: string;
  shift_type: ShiftType;
  start_date: string;
  end_date: string;
  is_active: boolean;
}

export interface DailyTask {
  id: string;
  lubrication_point_id: string;
  assigned_user_id: string;
  shift_id: string;
  scheduled_date: string;
  status: TaskStatus | 'pending';
  completed_at?: string;
  synced_at?: string;       // NULL until synced (offline support)
}

export interface CompletionLog {
  id: string;
  lubrication_point_id: string;
  user_id: string;
  completed_at: string;
  grammage_used_g?: number;
  status: TaskStatus;
  anomaly_report_id?: string;
  synced_at?: string;
}

export interface AnomalyReport {
  id: string;
  lubrication_point_id: string;
  user_id: string;
  anomaly_type: AnomalyType;
  description?: string;
  media_url?: string;       // Supabase Storage URL (photo/video)
  created_at: string;
  resolved: boolean;
  synced_at?: string;
}

export interface ConsumptionLog {
  id: string;
  lubricant_id: string;
  area_id?: string;
  quantity_kg?: number;
  quantity_liters?: number;
  recorded_at: string;
  recorded_by: string;
  notes?: string;
}

export interface MachineImage {
  id: string;
  machine_id: string;
  image_url: string;        // Supabase Storage path
  image_type: 'diagram' | 'photo' | 'schematic';
  description?: string;
  page_number?: number;     // Page from PDF
}

// Supabase Database type (for typed client)
export interface Database {
  public: {
    Tables: {
      profiles: { Row: Profile; Insert: Partial<Profile>; Update: Partial<Profile> };
      areas: { Row: Area; Insert: Partial<Area>; Update: Partial<Area> };
      machines: { Row: Machine; Insert: Partial<Machine>; Update: Partial<Machine> };
      machine_components: { Row: MachineComponent; Insert: Partial<MachineComponent>; Update: Partial<MachineComponent> };
      lubricants: { Row: Lubricant; Insert: Partial<Lubricant>; Update: Partial<Lubricant> };
      kallfass_groups: { Row: KallfassGroup; Insert: Partial<KallfassGroup>; Update: Partial<KallfassGroup> };
      frequencies: { Row: Frequency; Insert: Partial<Frequency>; Update: Partial<Frequency> };
      lubrication_points: { Row: LubricationPoint; Insert: Partial<LubricationPoint>; Update: Partial<LubricationPoint> };
      shifts: { Row: Shift; Insert: Partial<Shift>; Update: Partial<Shift> };
      daily_tasks: { Row: DailyTask; Insert: Partial<DailyTask>; Update: Partial<DailyTask> };
      completion_logs: { Row: CompletionLog; Insert: Partial<CompletionLog>; Update: Partial<CompletionLog> };
      anomaly_reports: { Row: AnomalyReport; Insert: Partial<AnomalyReport>; Update: Partial<AnomalyReport> };
      consumption_logs: { Row: ConsumptionLog; Insert: Partial<ConsumptionLog>; Update: Partial<ConsumptionLog> };
      machine_images: { Row: MachineImage; Insert: Partial<MachineImage>; Update: Partial<MachineImage> };
    };
  };
}
