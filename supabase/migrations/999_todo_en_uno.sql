-- =============================================================
-- Migración v2: Esquema Completo SED-360
-- =============================================================
-- Adaptado para PostgreSQL + Supabase Auth
-- Cuatrimestre de referencia: 26-1
-- =============================================================

-- ⚠️ Eliminar tablas v1 si existen (solo en desarrollo)
DROP TABLE IF EXISTS evaluaciones CASCADE;
DROP TABLE IF EXISTS cargas_academicas CASCADE;
DROP TABLE IF EXISTS periodos CASCADE;
DROP MATERIALIZED VIEW IF EXISTS resultados_agregados;

-- =============================================================
-- 1. TABLAS CATÁLOGO
-- =============================================================

-- 1.1 Cuatrimestres
CREATE TABLE cuatrimestres (
    id              SERIAL PRIMARY KEY,
    clave           VARCHAR(10) NOT NULL UNIQUE,
    nombre          VARCHAR(50) NOT NULL,
    fecha_inicio    DATE NOT NULL,
    fecha_fin       DATE NOT NULL,
    activo          BOOLEAN DEFAULT TRUE,
    cerrado         BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.2 Licenciaturas
CREATE TABLE licenciaturas (
    id              SERIAL PRIMARY KEY,
    clave           VARCHAR(10) NOT NULL UNIQUE,
    nombre          VARCHAR(100) NOT NULL,
    facultad        VARCHAR(100),
    activa          BOOLEAN DEFAULT TRUE
);

-- 1.3 Docentes
CREATE TABLE docentes (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(100) NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    num_empleado    VARCHAR(20) UNIQUE,
    licenciatura_id INT REFERENCES licenciaturas(id),
    foto_url        VARCHAR(255),
    activo          BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.4 Asignaturas
CREATE TABLE asignaturas (
    id              SERIAL PRIMARY KEY,
    clave           VARCHAR(20) NOT NULL UNIQUE,
    nombre          VARCHAR(150) NOT NULL,
    licenciatura_id INT REFERENCES licenciaturas(id),
    cuatrimestre_num INT,
    creditos        INT DEFAULT 5,
    activa          BOOLEAN DEFAULT TRUE
);

-- 1.5 Grupos
CREATE TABLE grupos (
    id              SERIAL PRIMARY KEY,
    clave           VARCHAR(20) NOT NULL,
    asignatura_id   INT REFERENCES asignaturas(id),
    docente_id      INT REFERENCES docentes(id),
    cuatrimestre_id INT REFERENCES cuatrimestres(id),
    num_alumnos     INT DEFAULT 0,
    activo          BOOLEAN DEFAULT TRUE
);

-- 1.6 Estudiantes
CREATE TABLE estudiantes (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(100) NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    matricula       VARCHAR(20) UNIQUE NOT NULL,
    licenciatura_id INT REFERENCES licenciaturas(id),
    cuatrimestre_actual INT,
    activo          BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.7 Inscripciones (estudiante ↔ grupo)
CREATE TABLE inscripciones (
    id              SERIAL PRIMARY KEY,
    estudiante_id   INT REFERENCES estudiantes(id),
    grupo_id        INT REFERENCES grupos(id),
    cuatrimestre_id INT REFERENCES cuatrimestres(id),
    fecha           DATE DEFAULT CURRENT_DATE,
    UNIQUE(estudiante_id, grupo_id)
);

-- =============================================================
-- 2. USUARIOS (sincronizado con auth.users de Supabase)
-- =============================================================

-- Modificar tabla usuarios existente (si existe de v1, se recrea)
DROP TABLE IF EXISTS usuarios CASCADE;
CREATE TABLE usuarios (
    id              UUID REFERENCES auth.users PRIMARY KEY,
    email           TEXT UNIQUE NOT NULL,
    rol             VARCHAR(20) CHECK (rol IN ('superadmin','coordinador','docente','estudiante')) NOT NULL,
    entidad_id      INT,  -- FK a docentes.id o estudiantes.id según rol
    activo          BOOLEAN DEFAULT TRUE,
    ultimo_acceso   TIMESTAMP,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger: crear usuario automáticamente al registrarse en auth.users
CREATE OR REPLACE FUNCTION public.crear_usuario_nuevo()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.usuarios (id, email, rol)
    VALUES (NEW.id, NEW.email, 'estudiante');
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.crear_usuario_nuevo();

-- =============================================================
-- 3. INSTRUMENTOS DE EVALUACIÓN
-- =============================================================

-- 3.1 Instrumento 1: Encuesta Estudiantil (EE) — 40%
CREATE TABLE encuesta_estudiantil_respuestas (
    id                  SERIAL PRIMARY KEY,
    docente_id          INT REFERENCES docentes(id),
    grupo_id            INT REFERENCES grupos(id),
    cuatrimestre_id     INT REFERENCES cuatrimestres(id),
    fecha_respuesta     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Calidad general (1-6)
    calidad_general     SMALLINT NOT NULL CHECK (calidad_general BETWEEN 1 AND 6),
    -- 18 ítems Likert (1-4)
    item_plan_estudio          SMALLINT CHECK (item_plan_estudio BETWEEN 1 AND 4),
    item_trato_respeto         SMALLINT CHECK (item_trato_respeto BETWEEN 1 AND 4),
    item_asistencia            SMALLINT CHECK (item_asistencia BETWEEN 1 AND 4),
    item_puntualidad           SMALLINT CHECK (item_puntualidad BETWEEN 1 AND 4),
    item_participacion         SMALLINT CHECK (item_participacion BETWEEN 1 AND 4),
    item_dominio_materia       SMALLINT CHECK (item_dominio_materia BETWEEN 1 AND 4),
    item_plataforma_moodle     SMALLINT CHECK (item_plataforma_moodle BETWEEN 1 AND 4),
    item_pensamiento_critico   SMALLINT CHECK (item_pensamiento_critico BETWEEN 1 AND 4),
    item_desafio_intelectual   SMALLINT CHECK (item_desafio_intelectual BETWEEN 1 AND 4),
    item_claridad_objetivos    SMALLINT CHECK (item_claridad_objetivos BETWEEN 1 AND 4),
    item_lecturas_aprendizaje  SMALLINT CHECK (item_lecturas_aprendizaje BETWEEN 1 AND 4),
    item_respeto_reglas        SMALLINT CHECK (item_respeto_reglas BETWEEN 1 AND 4),
    item_interes_materia       SMALLINT CHECK (item_interes_materia BETWEEN 1 AND 4),
    item_apoyos_didacticos     SMALLINT CHECK (item_apoyos_didacticos BETWEEN 1 AND 4),
    item_actitudes_valores     SMALLINT CHECK (item_actitudes_valores BETWEEN 1 AND 4),
    item_retroalimentacion     SMALLINT CHECK (item_retroalimentacion BETWEEN 1 AND 4),
    item_criterios_evaluacion  SMALLINT CHECK (item_criterios_evaluacion BETWEEN 1 AND 4),
    item_receptividad          SMALLINT CHECK (item_receptividad BETWEEN 1 AND 4),
    comentario_abierto         TEXT,
    clasificacion_comentario   VARCHAR(20) DEFAULT 'neutro'
        CHECK (clasificacion_comentario IN ('excelente','neutro','a_mejorar','critico','foco_rojo')),
    anonimo                    BOOLEAN DEFAULT TRUE
);

-- 3.1b Tabla de control de envío (anónimo — solo registra QUE respondió)
CREATE TABLE encuesta_control_envio (
    id              SERIAL PRIMARY KEY,
    estudiante_id   INT REFERENCES estudiantes(id),
    grupo_id        INT REFERENCES grupos(id),
    cuatrimestre_id INT REFERENCES cuatrimestres(id),
    fecha_envio     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(estudiante_id, grupo_id, cuatrimestre_id)
);

-- 3.2 Instrumento 2: Evaluación por Coordinación (CA) — 25%
CREATE TABLE evaluacion_coordinacion (
    id                  SERIAL PRIMARY KEY,
    docente_id          INT REFERENCES docentes(id),
    coordinador_id      UUID REFERENCES usuarios(id),
    cuatrimestre_id     INT REFERENCES cuatrimestres(id),
    fecha_evaluacion    DATE NOT NULL,
    puntos_obtenidos    DECIMAL(5,2) NOT NULL CHECK (puntos_obtenidos BETWEEN 0 AND 75),
    categoria           VARCHAR(20) NOT NULL
        CHECK (categoria IN ('excelente','buena','aceptable','deficiente','insuficiente')),
    dim_planificacion   DECIMAL(4,2),
    dim_estrategias     DECIMAL(4,2),
    dim_evaluacion      DECIMAL(4,2),
    dim_clima_aula      DECIMAL(4,2),
    dim_comunicacion    DECIMAL(4,2),
    dim_cumplimiento    DECIMAL(4,2),
    observaciones       TEXT,
    score_normalizado   DECIMAL(5,2) GENERATED ALWAYS AS ((puntos_obtenidos / 75.0) * 100) STORED,
    UNIQUE(docente_id, cuatrimestre_id, coordinador_id)
);

-- 3.3 Instrumento 3: Planeación Docente (PD) — 15%
CREATE TABLE evaluacion_planeacion (
    id                      SERIAL PRIMARY KEY,
    docente_id              INT REFERENCES docentes(id),
    evaluador_id            UUID REFERENCES usuarios(id),
    cuatrimestre_id         INT REFERENCES cuatrimestres(id),
    asignatura_id           INT REFERENCES asignaturas(id),
    fecha_evaluacion        DATE NOT NULL,
    criterio_elementos_curriculares   SMALLINT CHECK (criterio_elementos_curriculares BETWEEN 0 AND 2),
    criterio_fase_inicio              SMALLINT CHECK (criterio_fase_inicio BETWEEN 0 AND 2),
    criterio_fase_desarrollo          SMALLINT CHECK (criterio_fase_desarrollo BETWEEN 0 AND 2),
    criterio_fase_cierre              SMALLINT CHECK (criterio_fase_cierre BETWEEN 0 AND 2),
    criterio_caracteristicas_act      SMALLINT CHECK (criterio_caracteristicas_act BETWEEN 0 AND 2),
    criterio_estrategias_didacticas   SMALLINT CHECK (criterio_estrategias_didacticas BETWEEN 0 AND 2),
    criterio_recursos_didacticos      SMALLINT CHECK (criterio_recursos_didacticos BETWEEN 0 AND 2),
    criterio_organizacion_grupo       SMALLINT CHECK (criterio_organizacion_grupo BETWEEN 0 AND 2),
    criterio_estrategias_evaluacion   SMALLINT CHECK (criterio_estrategias_evaluacion BETWEEN 0 AND 2),
    criterio_productos                SMALLINT CHECK (criterio_productos BETWEEN 0 AND 2),
    criterio_bibliografia             SMALLINT CHECK (criterio_bibliografia BETWEEN 0 AND 2),
    puntos_totales          SMALLINT GENERATED ALWAYS AS (
        COALESCE(criterio_elementos_curriculares,0) + COALESCE(criterio_fase_inicio,0) +
        COALESCE(criterio_fase_desarrollo,0) + COALESCE(criterio_fase_cierre,0) +
        COALESCE(criterio_caracteristicas_act,0) + COALESCE(criterio_estrategias_didacticas,0) +
        COALESCE(criterio_recursos_didacticos,0) + COALESCE(criterio_organizacion_grupo,0) +
        COALESCE(criterio_estrategias_evaluacion,0) + COALESCE(criterio_productos,0) +
        COALESCE(criterio_bibliografia,0)
    ) STORED,
    categoria               VARCHAR(20) CHECK (categoria IN ('excelente','bueno','regular','insuficiente')),
    comentarios             TEXT,
    score_normalizado       DECIMAL(5,2) GENERATED ALWAYS AS (
        (COALESCE(criterio_elementos_curriculares,0) + COALESCE(criterio_fase_inicio,0) +
         COALESCE(criterio_fase_desarrollo,0) + COALESCE(criterio_fase_cierre,0) +
         COALESCE(criterio_caracteristicas_act,0) + COALESCE(criterio_estrategias_didacticas,0) +
         COALESCE(criterio_recursos_didacticos,0) + COALESCE(criterio_organizacion_grupo,0) +
         COALESCE(criterio_estrategias_evaluacion,0) + COALESCE(criterio_productos,0) +
         COALESCE(criterio_bibliografia,0)) / 22.0 * 100
    ) STORED,
    UNIQUE(docente_id, cuatrimestre_id, asignatura_id, evaluador_id)
);

-- 3.4 Instrumento 4: Observación de Clase (OC) — 15%
CREATE TABLE observacion_clase (
    id                  SERIAL PRIMARY KEY,
    docente_id          INT REFERENCES docentes(id),
    observador_id       UUID REFERENCES usuarios(id),
    cuatrimestre_id     INT REFERENCES cuatrimestres(id),
    grupo_id            INT REFERENCES grupos(id),
    fecha_observacion   DATE NOT NULL,
    hora_inicio         TIME,
    hora_fin            TIME,
    puntuacion_total    DECIMAL(4,2) NOT NULL CHECK (puntuacion_total BETWEEN 0 AND 10),
    dim_inicio_clase    DECIMAL(3,2),
    dim_desarrollo      DECIMAL(3,2),
    dim_cierre          DECIMAL(3,2),
    dim_clima_aula      DECIMAL(3,2),
    dim_uso_recursos    DECIMAL(3,2),
    categoria           VARCHAR(20) NOT NULL CHECK (categoria IN ('ejemplar','eficaz','por_validar')),
    observaciones       TEXT,
    recomendaciones     TEXT,
    score_normalizado   DECIMAL(5,2) GENERATED ALWAYS AS (puntuacion_total * 10) STORED,
    UNIQUE(docente_id, cuatrimestre_id, grupo_id, observador_id)
);

-- 3.5 Instrumento 5: Auto-evaluación Docente (AE) — 5%
CREATE TABLE autoevaluacion_docente (
    id                  SERIAL PRIMARY KEY,
    docente_id          INT REFERENCES docentes(id),
    cuatrimestre_id     INT REFERENCES cuatrimestres(id),
    fecha_respuesta     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ae_planificacion_clases      SMALLINT CHECK (ae_planificacion_clases BETWEEN 1 AND 3),
    ae_dominio_contenido         SMALLINT CHECK (ae_dominio_contenido BETWEEN 1 AND 3),
    ae_estrategias_didacticas    SMALLINT CHECK (ae_estrategias_didacticas BETWEEN 1 AND 3),
    ae_retroalimentacion         SMALLINT CHECK (ae_retroalimentacion BETWEEN 1 AND 3),
    ae_puntualidad_asistencia    SMALLINT CHECK (ae_puntualidad_asistencia BETWEEN 1 AND 3),
    ae_uso_plataforma            SMALLINT CHECK (ae_uso_plataforma BETWEEN 1 AND 3),
    ae_trato_estudiantes         SMALLINT CHECK (ae_trato_estudiantes BETWEEN 1 AND 3),
    ae_cumplimiento_programa     SMALLINT CHECK (ae_cumplimiento_programa BETWEEN 1 AND 3),
    ae_actualizacion_profesional SMALLINT CHECK (ae_actualizacion_profesional BETWEEN 1 AND 3),
    ae_evaluacion_aprendizaje    SMALLINT CHECK (ae_evaluacion_aprendizaje BETWEEN 1 AND 3),
    score_normalizado   DECIMAL(5,2) GENERATED ALWAYS AS (
        (COALESCE(ae_planificacion_clases,1) + COALESCE(ae_dominio_contenido,1) +
         COALESCE(ae_estrategias_didacticas,1) + COALESCE(ae_retroalimentacion,1) +
         COALESCE(ae_puntualidad_asistencia,1) + COALESCE(ae_uso_plataforma,1) +
         COALESCE(ae_trato_estudiantes,1) + COALESCE(ae_cumplimiento_programa,1) +
         COALESCE(ae_actualizacion_profesional,1) + COALESCE(ae_evaluacion_aprendizaje,1)) / 30.0 * 100
    ) STORED,
    categoria           VARCHAR(20) CHECK (categoria IN ('muy_bueno','bueno','no_aplico')),
    reflexion_personal  TEXT,
    UNIQUE(docente_id, cuatrimestre_id)
);

-- =============================================================
-- 4. CALIFICACIÓN FINAL
-- =============================================================

CREATE TABLE calificacion_final_docente (
    id                  SERIAL PRIMARY KEY,
    docente_id          INT REFERENCES docentes(id),
    cuatrimestre_id     INT REFERENCES cuatrimestres(id),
    score_encuesta_estudiantil   DECIMAL(5,2),
    score_coordinacion           DECIMAL(5,2),
    score_planeacion             DECIMAL(5,2),
    score_observacion            DECIMAL(5,2),
    score_autoevaluacion         DECIMAL(5,2),
    calificacion_final  DECIMAL(5,2) GENERATED ALWAYS AS (
        COALESCE(score_encuesta_estudiantil, 0) * 0.40 +
        COALESCE(score_coordinacion, 0) * 0.25 +
        COALESCE(score_planeacion, 0) * 0.15 +
        COALESCE(score_observacion, 0) * 0.15 +
        COALESCE(score_autoevaluacion, 0) * 0.05
    ) STORED,
    categoria_final     VARCHAR(20),
    tiene_comentarios_foco_rojo  BOOLEAN DEFAULT FALSE,
    tiene_comentarios_criticos   BOOLEAN DEFAULT FALSE,
    num_instrumentos_completados SMALLINT DEFAULT 0,
    calculado_en        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(docente_id, cuatrimestre_id)
);

-- =============================================================
-- 5. ÍNDICES
-- =============================================================

CREATE INDEX idx_grupos_docente ON grupos(docente_id);
CREATE INDEX idx_grupos_cuatrimestre ON grupos(cuatrimestre_id);
CREATE INDEX idx_inscripciones_estudiante ON inscripciones(estudiante_id);
CREATE INDEX idx_encuesta_respuestas_docente ON encuesta_estudiantil_respuestas(docente_id);
CREATE INDEX idx_encuesta_respuestas_grupo ON encuesta_estudiantil_respuestas(grupo_id);
CREATE INDEX idx_evaluacion_coordinacion_docente ON evaluacion_coordinacion(docente_id);
CREATE INDEX idx_evaluacion_planeacion_docente ON evaluacion_planeacion(docente_id);
CREATE INDEX idx_observacion_clase_docente ON observacion_clase(docente_id);
CREATE INDEX idx_autoevaluacion_docente_id ON autoevaluacion_docente(docente_id);
CREATE INDEX idx_calificacion_final_docente ON calificacion_final_docente(docente_id);

-- =============================================================
-- 6. SEED DATA MÍNIMO
-- =============================================================

INSERT INTO cuatrimestres (clave, nombre, fecha_inicio, fecha_fin, activo) VALUES
    ('26-1', 'Enero–Abril 2026', '2026-01-13', '2026-04-30', true)
ON CONFLICT (clave) DO NOTHING;
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
-- =============================================================
-- Migración 003: Autodiagnóstico Docente
-- =============================================================
-- Modifica tabla docentes (campos de perfil)
-- Crea tabla autodiagnosticos (24 reactivos Likert 1-5)
-- =============================================================

-- 1. Agregar columnas de perfil a docentes
ALTER TABLE docentes
  ADD COLUMN IF NOT EXISTS apellido_paterno VARCHAR(100),
  ADD COLUMN IF NOT EXISTS apellido_materno VARCHAR(100),
  ADD COLUMN IF NOT EXISTS campus VARCHAR(100),
  ADD COLUMN IF NOT EXISTS turno VARCHAR(50),
  ADD COLUMN IF NOT EXISTS oferta_academica TEXT;

-- Migrar datos existentes: split apellidos en paterno/materno
UPDATE docentes
SET apellido_paterno = SPLIT_PART(apellidos, ' ', 1),
    apellido_materno = CASE
      WHEN array_length(string_to_array(apellidos, ' '), 1) > 1
      THEN array_to_string((string_to_array(apellidos, ' '))[2:], ' ')
      ELSE NULL
    END
WHERE apellido_paterno IS NULL AND apellidos IS NOT NULL;

-- 2. Tabla de autodiagnósticos
CREATE TABLE IF NOT EXISTS autodiagnosticos (
  id                SERIAL PRIMARY KEY,
  docente_id        INT REFERENCES docentes(id),
  cuatrimestre_id   INT REFERENCES cuatrimestres(id),
  -- 24 reactivos (1-5)
  r1  SMALLINT CHECK (r1  BETWEEN 1 AND 5),
  r2  SMALLINT CHECK (r2  BETWEEN 1 AND 5),
  r3  SMALLINT CHECK (r3  BETWEEN 1 AND 5),
  r4  SMALLINT CHECK (r4  BETWEEN 1 AND 5),
  r5  SMALLINT CHECK (r5  BETWEEN 1 AND 5),
  r6  SMALLINT CHECK (r6  BETWEEN 1 AND 5),
  r7  SMALLINT CHECK (r7  BETWEEN 1 AND 5),
  r8  SMALLINT CHECK (r8  BETWEEN 1 AND 5),
  r9  SMALLINT CHECK (r9  BETWEEN 1 AND 5),
  r10 SMALLINT CHECK (r10 BETWEEN 1 AND 5),
  r11 SMALLINT CHECK (r11 BETWEEN 1 AND 5),
  r12 SMALLINT CHECK (r12 BETWEEN 1 AND 5),
  r13 SMALLINT CHECK (r13 BETWEEN 1 AND 5),
  r14 SMALLINT CHECK (r14 BETWEEN 1 AND 5),
  r15 SMALLINT CHECK (r15 BETWEEN 1 AND 5),
  r16 SMALLINT CHECK (r16 BETWEEN 1 AND 5),
  r17 SMALLINT CHECK (r17 BETWEEN 1 AND 5),
  r18 SMALLINT CHECK (r18 BETWEEN 1 AND 5),
  r19 SMALLINT CHECK (r19 BETWEEN 1 AND 5),
  r20 SMALLINT CHECK (r20 BETWEEN 1 AND 5),
  r21 SMALLINT CHECK (r21 BETWEEN 1 AND 5),
  r22 SMALLINT CHECK (r22 BETWEEN 1 AND 5),
  r23 SMALLINT CHECK (r23 BETWEEN 1 AND 5),
  r24 SMALLINT CHECK (r24 BETWEEN 1 AND 5),
  -- Calculado
  puntaje_total     SMALLINT GENERATED ALWAYS AS (
    COALESCE(r1,0)+COALESCE(r2,0)+COALESCE(r3,0)+COALESCE(r4,0)+
    COALESCE(r5,0)+COALESCE(r6,0)+COALESCE(r7,0)+COALESCE(r8,0)+
    COALESCE(r9,0)+COALESCE(r10,0)+COALESCE(r11,0)+COALESCE(r12,0)+
    COALESCE(r13,0)+COALESCE(r14,0)+COALESCE(r15,0)+COALESCE(r16,0)+
    COALESCE(r17,0)+COALESCE(r18,0)+COALESCE(r19,0)+COALESCE(r20,0)+
    COALESCE(r21,0)+COALESCE(r22,0)+COALESCE(r23,0)+COALESCE(r24,0)
  ) STORED,
  nivel_desempeno   VARCHAR(20),
  comentarios       TEXT,
  fecha_respuesta   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(docente_id, cuatrimestre_id)
);

-- 3. RLS
ALTER TABLE autodiagnosticos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Docente inserta su autodiagnóstico" ON autodiagnosticos
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente')
  );

CREATE POLICY "Docente lee su autodiagnóstico" ON autodiagnosticos
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente')
  );

CREATE POLICY "Staff lee autodiagnósticos" ON autodiagnosticos
  FOR SELECT USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
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
-- Permitir que usuarios actualicen su propio perfil (entidad_id, etc.)

CREATE POLICY "Usuario actualiza su perfil" ON public.usuarios
  FOR UPDATE USING (auth.uid() = id);
-- Migración 006: Catálogo de Ofertas Académicas
-- Tabla reutilizable en todos los formularios

CREATE TABLE IF NOT EXISTS ofertas_academicas (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(100) NOT NULL UNIQUE,
  activa  BOOLEAN DEFAULT TRUE
);

ALTER TABLE ofertas_academicas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura ofertas" ON ofertas_academicas FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona ofertas" ON ofertas_academicas FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

-- Seed data: las 15 carreras del documento
INSERT INTO ofertas_academicas (nombre) VALUES
  ('Arquitectura'), ('Administración de Empresas'), ('Administración de Empresas Turísticas'),
  ('Mercadotecnia'), ('Sistemas Computacionales'), ('Enfermería'), ('Nutrición'),
  ('Contaduría'), ('Derecho'), ('Pedagogía'), ('Criminología'), ('Comercio Internacional'),
  ('Diseño Gráfico Digital'), ('Inglés'), ('Otros')
ON CONFLICT (nombre) DO NOTHING;
-- Migración 007: Catálogos de Campus y Turnos

CREATE TABLE IF NOT EXISTS campus (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(100) NOT NULL UNIQUE,
  activo  BOOLEAN DEFAULT TRUE
);

ALTER TABLE campus ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura campus" ON campus FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona campus" ON campus FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

INSERT INTO campus (nombre) VALUES
  ('Tecnológico Universitario Tuxtla'),
  ('Tecnológico Universitario Playacar'),
  ('Facultad de Ciencias de la Salud')
ON CONFLICT (nombre) DO NOTHING;

-- Turnos
CREATE TABLE IF NOT EXISTS turnos (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(50) NOT NULL UNIQUE,
  activo  BOOLEAN DEFAULT TRUE
);

ALTER TABLE turnos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura turnos" ON turnos FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Admin gestiona turnos" ON turnos FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');

INSERT INTO turnos (nombre) VALUES
  ('Matutino'), ('Vespertino'), ('Mixto'), ('Virtual')
ON CONFLICT (nombre) DO NOTHING;
-- =============================================================
-- Migración 008: Observación de Clase (Formulario Coordinador)
-- 43 reactivos en 8 secciones (A-H)
-- =============================================================

CREATE TABLE IF NOT EXISTS observaciones (
  id                SERIAL PRIMARY KEY,
  docente_id        INT REFERENCES docentes(id),
  evaluador_id      UUID REFERENCES usuarios(id),
  oferta_academica  VARCHAR(100) NOT NULL,
  cuatrimestre_grupo VARCHAR(20) NOT NULL,
  ciclo             VARCHAR(10) NOT NULL,
  campus            VARCHAR(100) NOT NULL,
  -- Sección A: Cognitivas (7 reactivos CCO)
  cco1 SMALLINT, cco2 SMALLINT, cco3 SMALLINT, cco4 SMALLINT, cco5 SMALLINT, cco6 SMALLINT, cco7 SMALLINT,
  obs_cognitivas    TEXT,
  -- Sección B: Metacognitivas (9 reactivos CME)
  cme1 SMALLINT, cme2 SMALLINT, cme3 SMALLINT, cme4 SMALLINT, cme5 SMALLINT, cme6 SMALLINT, cme7 SMALLINT, cme8 SMALLINT, cme9 SMALLINT,
  obs_metacognitivas TEXT,
  -- Sección C: Comunicativas (4 reactivos CCOM)
  ccom1 SMALLINT, ccom2 SMALLINT, ccom3 SMALLINT, ccom4 SMALLINT,
  obs_comunicativas TEXT,
  -- Sección D: Sociales (4 reactivos CSO)
  cso1 SMALLINT, cso2 SMALLINT, cso3 SMALLINT, cso4 SMALLINT,
  obs_sociales      TEXT,
  -- Sección E: Gestión de la Enseñanza (7 reactivos CGE)
  cge1 SMALLINT, cge2 SMALLINT, cge3 SMALLINT, cge4 SMALLINT, cge5 SMALLINT, cge6 SMALLINT, cge7 SMALLINT,
  obs_gestion       TEXT,
  -- Sección F: Afectivas (2 reactivos CAF)
  caf1 SMALLINT, caf2 SMALLINT,
  obs_afectivas     TEXT,
  -- Sección G: Tecno-Pedagógicas (7 reactivos CTE-PE)
  ctepe1 SMALLINT, ctepe2 SMALLINT, ctepe3 SMALLINT, ctepe4 SMALLINT, ctepe5 SMALLINT, ctepe6 SMALLINT, ctepe7 SMALLINT,
  obs_tecno         TEXT,
  -- Sección H: Normativa (5 reactivos CNO)
  cno1 SMALLINT, cno2 SMALLINT, cno3 SMALLINT, cno4 SMALLINT, cno5 SMALLINT,
  obs_normativa     TEXT,
  -- Cierre
  comentario_docente     TEXT,
  comentario_evaluador   TEXT,
  fecha_observacion      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(docente_id, evaluador_id, ciclo)
);

-- RLS
ALTER TABLE observaciones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Coordinador inserta observación" ON observaciones
  FOR INSERT WITH CHECK (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Staff lee observaciones" ON observaciones
  FOR SELECT USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Docente lee sus observaciones" ON observaciones
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente')
  );
-- =============================================================
-- Migración 009: Asignaturas por carrera + Planeaciones
-- =============================================================

-- 1. Vincular asignaturas con ofertas académicas
ALTER TABLE asignaturas ADD COLUMN IF NOT EXISTS oferta_academica_id INT REFERENCES ofertas_academicas(id);

-- 2. Tabla de planeaciones
CREATE TABLE IF NOT EXISTS planeaciones (
  id SERIAL PRIMARY KEY,
  docente_id INT REFERENCES docentes(id),
  cuatrimestre_id INT REFERENCES cuatrimestres(id),
  asignatura_id INT REFERENCES asignaturas(id),
  campus TEXT, turno TEXT, modalidad TEXT,
  grupo TEXT NOT NULL,
  proyecto BOOLEAN DEFAULT false,
  laboratorio VARCHAR(10) DEFAULT 'No aplica',
  visitas VARCHAR(10) DEFAULT 'No aplica',
  url_pdf TEXT NOT NULL,
  nombre_archivo TEXT,
  comentario_docente TEXT,
  -- Evaluación del coordinador
  criterio_alineacion SMALLINT CHECK (criterio_alineacion BETWEEN 1 AND 5),
  criterio_secuencia SMALLINT CHECK (criterio_secuencia BETWEEN 1 AND 5),
  criterio_recursos SMALLINT CHECK (criterio_recursos BETWEEN 1 AND 5),
  criterio_evaluacion SMALLINT CHECK (criterio_evaluacion BETWEEN 1 AND 5),
  puntaje_promedio DECIMAL(4,2),
  estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente','Aprobado','Corrección')),
  comentario_retroalimentacion TEXT,
  comentario_interno TEXT,
  fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_evaluacion TIMESTAMP,
  UNIQUE(docente_id, cuatrimestre_id, asignatura_id)
);

-- 3. RLS
ALTER TABLE planeaciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Docente gestiona sus planeaciones" ON planeaciones FOR ALL
  USING (EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente'));

CREATE POLICY "Staff lee y evalúa planeaciones" ON planeaciones FOR ALL
  USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));

-- Corregir: DECIMAL(5,2) permite 100.00
ALTER TABLE planeaciones ALTER COLUMN puntaje_promedio TYPE DECIMAL(5,2);
-- =============================================================
-- Migración 010: Evaluación por Coordinación Académica (CA)
-- 15 reactivos en 5 categorías (A-E), escala 1-5, total máx 75
-- =============================================================

-- La tabla evaluacion_coordinacion ya existe (001). La adaptamos.
-- Si ya tiene datos viejos, los limpiamos.
DROP TABLE IF EXISTS evaluacion_coordinacion CASCADE;

CREATE TABLE evaluacion_coordinacion (
  id SERIAL PRIMARY KEY,
  docente_id INT REFERENCES docentes(id),
  evaluador_id UUID REFERENCES usuarios(id),
  cuatrimestre_id INT REFERENCES cuatrimestres(id),
  ciclo VARCHAR(10) NOT NULL,
  campus VARCHAR(100) NOT NULL,
  -- Categoría A: Cumplimiento Académico (3 ítems)
  a1 SMALLINT CHECK (a1 BETWEEN 1 AND 5), a2 SMALLINT CHECK (a2 BETWEEN 1 AND 5), a3 SMALLINT CHECK (a3 BETWEEN 1 AND 5),
  -- Categoría B: Gestión y Organización (3 ítems)
  b1 SMALLINT CHECK (b1 BETWEEN 1 AND 5), b2 SMALLINT CHECK (b2 BETWEEN 1 AND 5), b3 SMALLINT CHECK (b3 BETWEEN 1 AND 5),
  -- Categoría C: Desempeño Profesional (3 ítems)
  c1 SMALLINT CHECK (c1 BETWEEN 1 AND 5), c2 SMALLINT CHECK (c2 BETWEEN 1 AND 5), c3 SMALLINT CHECK (c3 BETWEEN 1 AND 5),
  -- Categoría D: Innovación y Mejora (3 ítems)
  d1 SMALLINT CHECK (d1 BETWEEN 1 AND 5), d2 SMALLINT CHECK (d2 BETWEEN 1 AND 5), d3 SMALLINT CHECK (d3 BETWEEN 1 AND 5),
  -- Categoría E: Compromiso y Ética (3 ítems)
  e1 SMALLINT CHECK (e1 BETWEEN 1 AND 5), e2 SMALLINT CHECK (e2 BETWEEN 1 AND 5), e3 SMALLINT CHECK (e3 BETWEEN 1 AND 5),
  -- Calculados
  puntos_obtenidos SMALLINT GENERATED ALWAYS AS (
    COALESCE(a1,0)+COALESCE(a2,0)+COALESCE(a3,0)+
    COALESCE(b1,0)+COALESCE(b2,0)+COALESCE(b3,0)+
    COALESCE(c1,0)+COALESCE(c2,0)+COALESCE(c3,0)+
    COALESCE(d1,0)+COALESCE(d2,0)+COALESCE(d3,0)+
    COALESCE(e1,0)+COALESCE(e2,0)+COALESCE(e3,0)
  ) STORED,
  score_normalizado DECIMAL(5,2) GENERATED ALWAYS AS (
    (COALESCE(a1,0)+COALESCE(a2,0)+COALESCE(a3,0)+COALESCE(b1,0)+COALESCE(b2,0)+COALESCE(b3,0)+COALESCE(c1,0)+COALESCE(c2,0)+COALESCE(c3,0)+COALESCE(d1,0)+COALESCE(d2,0)+COALESCE(d3,0)+COALESCE(e1,0)+COALESCE(e2,0)+COALESCE(e3,0)) / 75.0 * 100
  ) STORED,
  categoria VARCHAR(20) GENERATED ALWAYS AS (
    CASE
      WHEN (COALESCE(a1,0)+COALESCE(a2,0)+COALESCE(a3,0)+COALESCE(b1,0)+COALESCE(b2,0)+COALESCE(b3,0)+COALESCE(c1,0)+COALESCE(c2,0)+COALESCE(c3,0)+COALESCE(d1,0)+COALESCE(d2,0)+COALESCE(d3,0)+COALESCE(e1,0)+COALESCE(e2,0)+COALESCE(e3,0)) >= 60 THEN 'excelente'
      WHEN (COALESCE(a1,0)+COALESCE(a2,0)+COALESCE(a3,0)+COALESCE(b1,0)+COALESCE(b2,0)+COALESCE(b3,0)+COALESCE(c1,0)+COALESCE(c2,0)+COALESCE(c3,0)+COALESCE(d1,0)+COALESCE(d2,0)+COALESCE(d3,0)+COALESCE(e1,0)+COALESCE(e2,0)+COALESCE(e3,0)) >= 45 THEN 'buena'
      WHEN (COALESCE(a1,0)+COALESCE(a2,0)+COALESCE(a3,0)+COALESCE(b1,0)+COALESCE(b2,0)+COALESCE(b3,0)+COALESCE(c1,0)+COALESCE(c2,0)+COALESCE(c3,0)+COALESCE(d1,0)+COALESCE(d2,0)+COALESCE(d3,0)+COALESCE(e1,0)+COALESCE(e2,0)+COALESCE(e3,0)) >= 30 THEN 'aceptable'
      ELSE 'deficiente'
    END
  ) STORED,
  comentarios TEXT,
  fecha_evaluacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(docente_id, evaluador_id, cuatrimestre_id)
);

ALTER TABLE evaluacion_coordinacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Coordinador inserta evaluación" ON evaluacion_coordinacion FOR INSERT
  WITH CHECK (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Staff lee evaluaciones" ON evaluacion_coordinacion FOR SELECT
  USING (public.rol_usuario(auth.uid()) IN ('superadmin','coordinador'));
CREATE POLICY "Docente lee su evaluación" ON evaluacion_coordinacion FOR SELECT
  USING (EXISTS (SELECT 1 FROM usuarios u WHERE u.id = auth.uid() AND u.entidad_id = docente_id AND u.rol = 'docente'));

CREATE INDEX idx_ec_docente ON evaluacion_coordinacion(docente_id);
-- Migración 011: Tabla de preguntas editables para instrumentos
CREATE TABLE IF NOT EXISTS instrumento_preguntas (
  id SERIAL PRIMARY KEY,
  instrumento VARCHAR(50) NOT NULL, -- 'autodiagnostico','observacion','coordinacion','planeacion','encuesta'
  seccion VARCHAR(10),              -- 'A','B', etc. o NULL
  orden SMALLINT NOT NULL,
  texto TEXT NOT NULL,
  escala_min SMALLINT DEFAULT 1,
  escala_max SMALLINT DEFAULT 5,
  activa BOOLEAN DEFAULT TRUE,
  UNIQUE(instrumento, orden)
);

ALTER TABLE instrumento_preguntas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff gestiona preguntas" ON instrumento_preguntas FOR ALL USING (public.rol_usuario(auth.uid()) = 'superadmin');
CREATE POLICY "Todos leen preguntas" ON instrumento_preguntas FOR SELECT USING (auth.uid() IS NOT NULL);

-- Seed: preguntas de autodiagnóstico (24 reactivos)
INSERT INTO instrumento_preguntas (instrumento, seccion, orden, texto) VALUES
('autodiagnostico',NULL,1,'Domino los conceptos para la construcción del aprendizaje en los cursos o programas académicos que imparto.'),
('autodiagnostico',NULL,2,'Expongo, organizo, desarrollo y vinculo los contenidos en forma clara.'),
('autodiagnostico',NULL,3,'Adapto los contenidos a los diversos estilos y necesidades de los estudiantes.'),
('autodiagnostico',NULL,4,'Organizo espacios de reflexión antes, durante y después de las actividades de aprendizaje.'),
('autodiagnostico',NULL,5,'Incluyo actividades en clase que promueven el aprendizaje autónomo en los estudiantes.'),
('autodiagnostico',NULL,6,'Propongo ejercicios para promover la metacognición en su ambiente de aprendizaje.'),
('autodiagnostico',NULL,7,'Propongo nuevas estrategias para mejorar los resultados obtenidos en el desempeño de los estudiantes.'),
('autodiagnostico',NULL,8,'Me comunico con claridad y precisión.'),
('autodiagnostico',NULL,9,'Escucho activamente a mis estudiantes.'),
('autodiagnostico',NULL,10,'Fomento la participación y el diálogo respetuoso.'),
('autodiagnostico',NULL,11,'Mantengo un trato respetuoso con mis estudiantes.'),
('autodiagnostico',NULL,12,'Atiendo situaciones grupales con sensibilidad y objetividad.'),
('autodiagnostico',NULL,13,'Organizo los objetivos y contenidos de manera coherente con el modelo educativo.'),
('autodiagnostico',NULL,14,'Implemento diversas estrategias para inducir el aprendizaje significativo.'),
('autodiagnostico',NULL,15,'Considero saberes previos, intereses y experiencias de sus estudiantes.'),
('autodiagnostico',NULL,16,'Genero oportunidades de desarrollo del pensamiento crítico y creativo.'),
('autodiagnostico',NULL,17,'Motivo al aprendizaje, la indagación y la búsqueda de conocimiento.'),
('autodiagnostico',NULL,18,'Ofrezco retroalimentación oportuna, pertinente y cálida a los estudiantes.'),
('autodiagnostico',NULL,19,'Promuevo un ambiente de confianza y respeto.'),
('autodiagnostico',NULL,20,'Manejo mis emociones de forma profesional en clase.'),
('autodiagnostico',NULL,21,'Utilizo herramientas tecnológicas para enriquecer mi enseñanza.'),
('autodiagnostico',NULL,22,'Integro recursos digitales de forma adecuada a los contenidos.'),
('autodiagnostico',NULL,23,'Conozco y aplico la normatividad institucional.'),
('autodiagnostico',NULL,24,'Respeto el reglamento y lineamientos académicos.')
ON CONFLICT (instrumento, orden) DO NOTHING;
-- Migración 012: Mejorar editor de preguntas con tipo de respuesta y opciones
ALTER TABLE instrumento_preguntas ADD COLUMN IF NOT EXISTS tipo_respuesta VARCHAR(20) DEFAULT 'cerrada' CHECK (tipo_respuesta IN ('abierta','cerrada','opcion_multiple'));
ALTER TABLE instrumento_preguntas ADD COLUMN IF NOT EXISTS opciones JSONB DEFAULT '[]';
-- Seed: Preguntas para Observación de Clase (45 reactivos, secciones A-H)
INSERT INTO instrumento_preguntas (instrumento, seccion, orden, texto) VALUES
('observacion','A',1,'Expone, organiza, desarrolla y vincula los contenidos en forma clara.'),
('observacion','A',2,'Relaciona los contenidos con situaciones reales o casos prácticos del entorno profesional.'),
('observacion','A',3,'Adapta los contenidos a los diversos estilos y necesidades de los estudiantes.'),
('observacion','A',4,'Explica conceptos complejos utilizando analogías, ejemplos claros y lenguaje accesible.'),
('observacion','A',5,'Clarifica términos técnicos o especializados según el nivel académico del grupo.'),
('observacion','A',6,'Facilita la apropiación del conocimiento mediante explicaciones estructuradas.'),
('observacion','A',7,'Promueve el razonamiento crítico y la resolución de problemas durante la clase.'),
('observacion','B',8,'Organiza espacios de reflexión antes, durante y después de las actividades.'),
('observacion','B',9,'Orienta a los estudiantes para que identifiquen sus fortalezas y áreas de oportunidad.'),
('observacion','B',10,'Incluye actividades en clase que promueven el aprendizaje autónomo.'),
('observacion','B',11,'Propone ejercicios para promover la metacognición.'),
('observacion','B',12,'Propone nuevas estrategias para mejorar los resultados obtenidos.'),
('observacion','B',13,'Favorece la transferencia de conocimientos a nuevas situaciones o contextos.'),
('observacion','B',14,'Promueve la formulación de preguntas y el pensamiento reflexivo en el aula.'),
('observacion','B',15,'Invita a los estudiantes a seleccionar estrategias de estudio.'),
('observacion','B',16,'Integra momentos de análisis sobre los errores como oportunidades de mejora.'),
('observacion','C',17,'Se comunica con un lenguaje oral y escrito apropiado y de respeto.'),
('observacion','C',18,'Se comunica con un lenguaje no verbal (corporal) apropiado y de respeto.'),
('observacion','C',19,'Comunica los propósitos, procedimientos y resultados esperados.'),
('observacion','C',20,'Diseña actividades que desarrollen la expresión escrita y oral de los estudiantes.'),
('observacion','D',21,'Procura relaciones empáticas y de respeto dentro de la praxis docente.'),
('observacion','D',22,'Proporciona igualdad de oportunidades de participación.'),
('observacion','D',23,'Promueve compromiso y solidaridad entre los estudiantes.'),
('observacion','D',24,'Establece un clima de relaciones interpersonales respetuosas y empáticas.'),
('observacion','E',25,'Organiza los objetivos y contenidos de manera coherente con el modelo TUP.'),
('observacion','E',26,'Implementa diversas estrategias para inducir el aprendizaje significativo.'),
('observacion','E',27,'Considera saberes previos, intereses y experiencias de sus estudiantes.'),
('observacion','E',28,'Genera oportunidades de desarrollo del pensamiento crítico y creativo.'),
('observacion','E',29,'Motiva al aprendizaje, la indagación y la búsqueda de conocimiento.'),
('observacion','E',30,'Integra recursos tecnológicos, didácticos y materiales complementarios.'),
('observacion','E',31,'Ofrece retroalimentación oportuna, pertinente y cálida a sus estudiantes.'),
('observacion','F',32,'Genera un ambiente propicio para el aprendizaje basado en confianza y respeto.'),
('observacion','F',33,'Identifica las fortalezas de sus estudiantes, las destaca y ofrece espacios.'),
('observacion','G',34,'Diseña tareas integradoras de proyectos utilizando las NTIC.'),
('observacion','G',35,'Promueve el empoderamiento y participación del estudiante en el uso de NTIC.'),
('observacion','G',36,'Muestra dominio en el uso de la tecnología como recurso para la enseñanza.'),
('observacion','G',37,'Aplica métodos y técnicas pertinentes a la didáctica de su campo.'),
('observacion','G',38,'Identifica estrategias de enseñanza y dificultades recurrentes.'),
('observacion','G',39,'Promueve el uso responsable, ético y seguro de las tecnologías.'),
('observacion','G',40,'Genera situaciones de aprendizaje adecuadas a los niveles de desarrollo.'),
('observacion','H',41,'Inicia puntualmente su sesión.'),
('observacion','H',42,'Entrega en tiempo y forma la planeación docente correspondiente.'),
('observacion','H',43,'Desarrolla el tema correspondiente a la semana o unidad establecida.'),
('observacion','H',44,'Registra la asistencia, evaluaciones y avances en medios institucionales.'),
('observacion','H',45,'Concluye su sesión en el tiempo señalado.')
ON CONFLICT (instrumento, orden) DO NOTHING;

-- Coordinación Académica (15 reactivos, secciones A-E)
INSERT INTO instrumento_preguntas (instrumento, seccion, orden, texto) VALUES
('coordinacion','A',1,'Cumplimiento del programa, planeación y avance académico.'),
('coordinacion','A',2,'Organización y conducción de sesiones (presenciales, virtuales o ejecutivas).'),
('coordinacion','A',3,'Uso y disponibilidad de materiales didácticos o recursos en plataforma.'),
('coordinacion','B',4,'Entrega de calificaciones en tiempo y forma.'),
('coordinacion','B',5,'Puntualidad, asistencia y cumplimiento administrativo.'),
('coordinacion','B',6,'Uso adecuado de plataformas institucionales (Moodle, Saeko, sistemas).'),
('coordinacion','C',7,'Comunicación clara, oportuna y profesional con estudiantes y coordinación.'),
('coordinacion','C',8,'Trabajo colaborativo con docentes y áreas institucionales.'),
('coordinacion','C',9,'Participación en reuniones, actividades y procesos institucionales.'),
('coordinacion','D',10,'Implementación de estrategias didácticas innovadoras.'),
('coordinacion','D',11,'Participación en procesos de capacitación o actualización docente.'),
('coordinacion','D',12,'Aplicación de mejoras en su práctica docente.'),
('coordinacion','E',13,'Cumplimiento de normatividad institucional.'),
('coordinacion','E',14,'Trato respetuoso, ético y profesional.'),
('coordinacion','E',15,'Representación institucional adecuada en entornos presenciales o digitales.')
ON CONFLICT (instrumento, orden) DO NOTHING;

-- Planeación Docente (4 criterios)
INSERT INTO instrumento_preguntas (instrumento, seccion, orden, texto) VALUES
('planeacion',NULL,1,'Alineación Curricular — Coherencia con el plan de estudios y perfil de egreso.'),
('planeacion',NULL,2,'Secuencia Didáctica — Estructura lógica de las actividades de aprendizaje.'),
('planeacion',NULL,3,'Recursos y Materiales (NTIC) — Uso de tecnología y materiales didácticos.'),
('planeacion',NULL,4,'Sistemas de Evaluación — Instrumentos y criterios de evaluación claros.')
ON CONFLICT (instrumento, orden) DO NOTHING;
-- Migración 014: Modalidad en docentes
ALTER TABLE docentes ADD COLUMN IF NOT EXISTS modalidad TEXT DEFAULT 'Escolarizado';
-- Seed: Observación Virtual (20 reactivos)
INSERT INTO instrumento_preguntas (instrumento, seccion, orden, texto) VALUES
('observacion_virtual','A',1,'Organización y vinculación de contenidos con recursos digitales.'),
('observacion_virtual','A',2,'Uso de ejemplos y casos contextualizados al entorno en línea.'),
('observacion_virtual','A',3,'Adaptación ante limitaciones tecnológicas del grupo.'),
('observacion_virtual','A',4,'Uso de apoyos visuales (gráficas, pizarras virtuales) para clarificar conceptos.'),
('observacion_virtual','A',5,'Clarificación de términos técnicos con herramientas digitales.'),
('observacion_virtual','A',6,'Promoción del razonamiento crítico (breakout rooms, debates).'),
('observacion_virtual','B',1,'Generación de reflexión mediante foros o chats.'),
('observacion_virtual','B',2,'Orientación sobre fortalezas y áreas de oportunidad.'),
('observacion_virtual','B',3,'Fomento del aprendizaje autónomo y gestión propia en línea.'),
('observacion_virtual','B',4,'Actividades de recapitulación o autoevaluaciones digitales.'),
('observacion_virtual','C',1,'Claridad en voz, dicción, ritmo y volumen.'),
('observacion_virtual','C',2,'Manejo respetuoso de chats y turnos de voz.'),
('observacion_virtual','C',3,'Explicación de dinámicas con lenguaje accesible.'),
('observacion_virtual','C',4,'Comunicación de propósitos y resultados esperados.'),
('observacion_virtual','C',5,'Verificación de comprensión (encuestas, reacciones).'),
('observacion_virtual','D',1,'Clima de respeto, participación equitativa y manejo de imprevistos técnicos.'),
('observacion_virtual','D',2,'Ambiente de confianza y manejo cálido de la baja participación.'),
('observacion_virtual','E',1,'Alineación con la planeación y uso de estrategias activas (Kahoot, Jamboard).'),
('observacion_virtual','E',2,'Dominio de la plataforma virtual y promoción del uso ético de la tecnología.'),
('observacion_virtual','F',1,'Inicio puntual, desarrollo conforme al calendario y respeto a la duración.')
ON CONFLICT (instrumento, orden) DO NOTHING;

-- Seed: Observación Ejecutiva (17 reactivos)
INSERT INTO instrumento_preguntas (instrumento, seccion, orden, texto) VALUES
('observacion_ejecutivo','A',1,'Claridad, síntesis y precisión en la explicación de contenidos clave.'),
('observacion_ejecutivo','A',2,'Vinculación de aprendizajes previos con temas actuales.'),
('observacion_ejecutivo','A',3,'Integración efectiva de contenidos de Moodle con la sesión presencial.'),
('observacion_ejecutivo','A',4,'Aclaración de conceptos esenciales para el trabajo autónomo semanal.'),
('observacion_ejecutivo','B',1,'Reflexión sobre los avances logrados durante la semana previa.'),
('observacion_ejecutivo','B',2,'Orientación sobre estrategias de organización para el trabajo independiente.'),
('observacion_ejecutivo','B',3,'Retroalimentación sobre errores comunes detectados en plataforma.'),
('observacion_ejecutivo','B',4,'Propuesta de momentos de autoevaluación del progreso.'),
('observacion_ejecutivo','C',1,'Comunicación clara, ordenada y con secuencia lógica.'),
('observacion_ejecutivo','C',2,'Claridad en las instrucciones de tareas y actividades en Moodle.'),
('observacion_ejecutivo','C',3,'Apertura del ambiente para la expresión de dudas.'),
('observacion_ejecutivo','C',4,'Verificación de comprensión antes de finalizar bloques temáticos.'),
('observacion_ejecutivo','D',1,'Reconocimiento de la carga laboral del estudiante ejecutivo y participación inclusiva.'),
('observacion_ejecutivo','D',2,'Clima de empatía, motivación al proceso independiente y reconocimiento de avances.'),
('observacion_ejecutivo','E',1,'Administración óptima del tiempo en bloques compactos y alineación con Moodle.'),
('observacion_ejecutivo','E',2,'Manejo de Moodle como herramienta central y retroalimentación mediante plataforma.'),
('observacion_ejecutivo','E',3,'Puntualidad sabatina, desarrollo según programa ejecutivo y registro de evidencias.')
ON CONFLICT (instrumento, orden) DO NOTHING;
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
-- Migración 017: Limpieza manual de docente tup7433
UPDATE docentes SET activo = false WHERE email = 'tup7433@tecplayacar.edu.mx';
UPDATE usuarios SET entidad_id = NULL WHERE email = 'tup7433@tecplayacar.edu.mx';
-- Migración 018: Actualizar fórmula de ponderación 35/20/15/25/5 + documentación
-- Nueva fórmula: EE(35) + CA(20) + PD(15) + OC(25) + AE(5)

-- Recrear la columna GENERATED de calificacion_final con los nuevos pesos
ALTER TABLE calificacion_final_docente DROP COLUMN IF EXISTS calificacion_final;
ALTER TABLE calificacion_final_docente ADD COLUMN calificacion_final DECIMAL(5,2) GENERATED ALWAYS AS (
    COALESCE(score_encuesta_estudiantil, 0) * 0.35 +
    COALESCE(score_coordinacion, 0) * 0.20 +
    COALESCE(score_planeacion, 0) * 0.15 +
    COALESCE(score_observacion, 0) * 0.25 +
    COALESCE(score_autoevaluacion, 0) * 0.05
) STORED;
-- =============================================================
-- Migración 019: Consolidado Final — Fórmula + Limpieza
-- Ejecutar esta ÚNICA migración para dejar todo actualizado
-- =============================================================

-- 1. Actualizar fórmula de ponderación: EE(35) + CA(20) + PD(15) + OC(25) + AE(5)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='calificacion_final_docente' AND column_name='calificacion_final') THEN
    ALTER TABLE calificacion_final_docente DROP COLUMN calificacion_final;
  END IF;
END $$;

ALTER TABLE calificacion_final_docente ADD COLUMN calificacion_final DECIMAL(5,2) GENERATED ALWAYS AS (
    COALESCE(score_encuesta_estudiantil, 0) * 0.35 +
    COALESCE(score_coordinacion, 0) * 0.20 +
    COALESCE(score_planeacion, 0) * 0.15 +
    COALESCE(score_observacion, 0) * 0.25 +
    COALESCE(score_autoevaluacion, 0) * 0.05
) STORED;

-- 2. Marcar docente inactivo al cambiar rol + limpiar entidad_id
CREATE OR REPLACE FUNCTION limpiar_entidad_al_cambiar_rol()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
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
CREATE TRIGGER trg_limpiar_entidad BEFORE UPDATE ON usuarios FOR EACH ROW EXECUTE FUNCTION limpiar_entidad_al_cambiar_rol();

-- 3. Limpiar datos existentes (usuarios que no son docentes pero tienen entidad_id)
UPDATE docentes SET activo = false WHERE id IN (SELECT entidad_id FROM usuarios WHERE rol != 'docente' AND entidad_id IS NOT NULL);
UPDATE usuarios SET entidad_id = NULL WHERE rol != 'docente' AND entidad_id IS NOT NULL;

-- 4. Solo mostrar docentes activos en queries (política existente se mantiene)
-- Las queries ya filtran por activo = true desde src/services/docentes.ts

-- ✅ Listo. Todos los cambios aplicados.

-- =============================================================
-- Storage: Bucket planeaciones (crear bucket manualmente después)
-- =============================================================
CREATE POLICY "Subir a planeaciones" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'planeaciones');
CREATE POLICY "Leer planeaciones" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'planeaciones');
