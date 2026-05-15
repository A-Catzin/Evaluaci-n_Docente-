-- Migración 016: Limpiar entidad_id al cambiar de rol
-- Si un usuario ya no es docente, desvincular su entidad_id

-- 1. Limpiar datos existentes
UPDATE usuarios SET entidad_id = NULL WHERE rol != 'docente' AND entidad_id IS NOT NULL;

-- 2. Trigger: al cambiar rol, limpiar entidad_id si no es docente
CREATE OR REPLACE FUNCTION limpiar_entidad_al_cambiar_rol()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF NEW.rol != 'docente' AND NEW.entidad_id IS NOT NULL THEN
    NEW.entidad_id = NULL;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_limpiar_entidad ON usuarios;
CREATE TRIGGER trg_limpiar_entidad
  BEFORE UPDATE ON usuarios
  FOR EACH ROW
  EXECUTE FUNCTION limpiar_entidad_al_cambiar_rol();
