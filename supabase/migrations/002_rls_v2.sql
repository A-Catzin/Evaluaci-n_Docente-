-- =============================================================
-- Migración 002: Políticas RLS Centralizadas v2
-- =============================================================

-- Helper function para obtener el rol del usuario autenticado
CREATE OR REPLACE FUNCTION public.rol_usuario(uid uuid)
RETURNS VARCHAR(20)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT rol FROM public.usuarios WHERE id = uid;
$$;

-- =============================================================
-- POLÍTICAS POR TABLA
-- =============================================================

-- cuatrimestres: lectura pública autenticados, admin gestiona
ALTER TABLE cuatrimestres ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura cuatrimestres" ON cuatrimestres FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona cuatrimestres" ON cuatrimestres FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

-- licenciaturas
ALTER TABLE licenciaturas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura licenciaturas" ON licenciaturas FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona licenciaturas" ON licenciaturas FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

-- docentes
ALTER TABLE docentes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura docentes" ON docentes FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona docentes" ON docentes FOR ALL USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Docente lee su perfil" ON docentes FOR SELECT USING (
    EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docentes.id AND u.rol = 'docente')
);

-- asignaturas
ALTER TABLE asignaturas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura asignaturas" ON asignaturas FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona asignaturas" ON asignaturas FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

-- grupos
ALTER TABLE grupos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura grupos" ON grupos FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona grupos" ON grupos FOR ALL USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));

-- estudiantes
ALTER TABLE estudiantes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura estudiantes" ON estudiantes FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona estudiantes" ON estudiantes FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');
CREATE POLICY "Estudiante lee su perfil" ON estudiantes FOR SELECT USING (
    EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = estudiantes.id AND u.rol = 'estudiante')
);

-- inscripciones
ALTER TABLE inscripciones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura inscripciones" ON inscripciones FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona inscripciones" ON inscripciones FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

-- usuarios
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuario lee su perfil" ON usuarios FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Admin gestiona usuarios" ON usuarios FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

-- encuesta_estudiantil_respuestas (ANÓNIMA: no expone quién respondió)
ALTER TABLE encuesta_estudiantil_respuestas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Estudiante inserta respuesta anónima" ON encuesta_estudiantil_respuestas
    FOR INSERT WITH CHECK (public.rol_usuario(auth.uid()) = 'estudiante');
CREATE POLICY "Staff lee respuestas" ON encuesta_estudiantil_respuestas
    FOR SELECT USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Docente lee respuestas de sus grupos" ON encuesta_estudiantil_respuestas
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM grupos g JOIN usuarios u ON u.id = auth.uid()
                WHERE g.id = encuesta_estudiantil_respuestas.grupo_id AND g.docente_id = u.entidad_id AND u.rol = 'docente')
    );

-- encuesta_control_envio (PRIVADA: solo el estudiante ve si ya respondió)
ALTER TABLE encuesta_control_envio ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Estudiante inserta control" ON encuesta_control_envio
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = estudiante_id AND u.rol = 'estudiante')
    );
CREATE POLICY "Estudiante lee su control" ON encuesta_control_envio
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = estudiante_id AND u.rol = 'estudiante')
    );
CREATE POLICY "Staff lee control" ON encuesta_control_envio
    FOR SELECT USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));

-- evaluacion_coordinacion
ALTER TABLE evaluacion_coordinacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Coordinador inserta evaluación" ON evaluacion_coordinacion
    FOR INSERT WITH CHECK (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Coordinador lee sus evaluaciones" ON evaluacion_coordinacion
    FOR SELECT USING (coordinador_id = auth.uid() OR public.rol_usuario(auth.uid()) = 'superadmin');
CREATE POLICY "Docente lee su evaluación" ON evaluacion_coordinacion
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente')
    );

-- evaluacion_planeacion
ALTER TABLE evaluacion_planeacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Evaluador inserta planeación" ON evaluacion_planeacion
    FOR INSERT WITH CHECK (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Staff lee planeación" ON evaluacion_planeacion
    FOR SELECT USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Docente lee su planeación" ON evaluacion_planeacion
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente')
    );

-- observacion_clase
ALTER TABLE observacion_clase ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Observador inserta observación" ON observacion_clase
    FOR INSERT WITH CHECK (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Staff lee observaciones" ON observacion_clase
    FOR SELECT USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Docente lee su observación" ON observacion_clase
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente')
    );

-- autoevaluacion_docente
ALTER TABLE autoevaluacion_docente ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Docente inserta autoevaluación" ON autoevaluacion_docente
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente')
    );
CREATE POLICY "Docente lee su autoevaluación" ON autoevaluacion_docente
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente')
    );
CREATE POLICY "Staff lee autoevaluaciones" ON autoevaluacion_docente
    FOR SELECT USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));

-- calificacion_final_docente
ALTER TABLE calificacion_final_docente ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff lee calificaciones" ON calificacion_final_docente
    FOR SELECT USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Docente lee su calificación" ON calificacion_final_docente
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente')
    );
CREATE POLICY "Admin gestiona calificaciones" ON calificacion_final_docente
    FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');
