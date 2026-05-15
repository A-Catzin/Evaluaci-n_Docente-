-- Migración 016: Limpiar entidad_id al cambiar de rol + desactivar docente

-- 1. Marcar docentes como inactivos si el usuario ya no es docente
UPDATE docentes SET activo = false
WHERE id IN (SELECT entidad_id FROM usuarios WHERE rol != 'docente' AND entidad_id IS NOT NULL);

-- 2. Limpiar entidad_id de usuarios que ya no son docentes
UPDATE usuarios SET entidad_id = NULL WHERE rol != 'docente' AND entidad_id IS NOT NULL;

-- 3. Trigger: al cambiar rol, limpiar entidad_id y desactivar docente
CREATE OR REPLACE FUNCTION limpiar_entidad_al_cambiar_rol()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF NEW.rol != 'docente' AND OLD.rol = 'docente' AND OLD.entidad_id IS NOT NULL THEN
    UPDATE docentes SET activo = false WHERE id = OLD.entidad_id;
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
