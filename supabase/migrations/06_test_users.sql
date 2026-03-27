-- SCRIPT: CREACIÓN DE USUARIOS DE PRUEBA (EJECUTAR EN SQL EDITOR DE SUPABASE)
-- NOTA: Este script crea las entradas en auth.users y perfiles asociados.
-- La contraseña para todos es: lubricontrol2026

DO $$
DECLARE
  uid_admin CONSTANT uuid := gen_random_uuid();
  uid_supervisor CONSTANT uuid := gen_random_uuid();
  uid_lubricador CONSTANT uuid := gen_random_uuid();
BEGIN
  -- 1. Crear Usuario Admin
  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, confirmation_token)
  VALUES (
    uid_admin, 
    'admin@planta.local', 
    crypt('lubricontrol2026', gen_salt('bf')), 
    now(), 
    '{"provider":"email","providers":["email"]}', 
    '{"full_name":"Administrador de Planta"}', 
    now(), 
    now(), 
    'authenticated', 
    ''
  ) ON CONFLICT (email) DO NOTHING;

  -- 2. Crear Usuario Supervisor
  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, confirmation_token)
  VALUES (
    uid_supervisor, 
    'supervisor1@planta.local', 
    crypt('lubricontrol2026', gen_salt('bf')), 
    now(), 
    '{"provider":"email","providers":["email"]}', 
    '{"full_name":"Supervisor de Turno A"}', 
    now(), 
    now(), 
    'authenticated', 
    ''
  ) ON CONFLICT (email) DO NOTHING;

  -- 3. Crear Usuario Lubricador
  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, confirmation_token)
  VALUES (
    uid_lubricador, 
    'lubricador1@planta.local', 
    crypt('lubricontrol2026', gen_salt('bf')), 
    now(), 
    '{"provider":"email","providers":["email"]}', 
    '{"full_name":"Juan Pérez (Lubricador)"}', 
    now(), 
    now(), 
    'authenticated', 
    ''
  ) ON CONFLICT (email) DO NOTHING;

  -- Nota: El trigger 'on_auth_user_created' (si ya fue ejecutado el archivo 04_auth_trigger.sql)
  -- creará automáticamente los registros en la tabla 'public.profiles'.
  -- Si el trigger no existe o falla, los insertamos manualmente aquí para asegurar:

  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES 
    (uid_admin, 'admin@planta.local', 'Administrador de Planta', 'admin'),
    (uid_supervisor, 'supervisor1@planta.local', 'Supervisor de Turno A', 'supervisor'),
    (uid_lubricador, 'lubricador1@planta.local', 'Juan Pérez (Lubricador)', 'lubricator')
  ON CONFLICT (id) DO UPDATE SET role = EXCLUDED.role;

END $$;
