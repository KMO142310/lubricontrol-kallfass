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
