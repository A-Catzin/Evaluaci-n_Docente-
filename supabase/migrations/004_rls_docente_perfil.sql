-- Migración 004: RLS para autodiagnóstico docente
-- Permite que los docentes creen y actualicen su propio perfil

CREATE POLICY "Docente inserta su perfil" ON public.docentes
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.usuarios u WHERE u.id = auth.uid() AND u.rol = 'docente')
  );

CREATE POLICY "Docente actualiza su perfil" ON public.docentes
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docentes.id AND u.rol = 'docente')
  );
