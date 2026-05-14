-- =============================================================
-- Migración 002: Trigger de Usuario Automático
-- =============================================================
-- Propósito: Insertar automáticamente un registro en la tabla
-- `usuarios` cuando se crea un nuevo usuario en `auth.users`.
--
-- Comportamiento:
--   1. Se dispara AFTER INSERT en auth.users
--   2. Inserta en public.usuarios con rol 'alumno' por defecto
--   3. Ejecuta con SECURITY DEFINER para evitar RLS
--
-- Dependencias:
--   - Tabla usuarios (001_esquema_core.sql)
-- =============================================================

-- Función del trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.usuarios (id, email, rol)
    VALUES (NEW.id, NEW.email, 'alumno');
    RETURN NEW;
END;
$$;

-- Trigger sobre auth.users
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
