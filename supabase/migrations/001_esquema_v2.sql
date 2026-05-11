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
