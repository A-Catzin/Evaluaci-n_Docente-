-- Permitir que usuarios actualicen su propio perfil (entidad_id, etc.)

CREATE POLICY "Usuario actualiza su perfil" ON public.usuarios
  FOR UPDATE USING (auth.uid() = id);
