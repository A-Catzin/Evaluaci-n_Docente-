-- =============================================================
-- Migración Inicial: Esquema Core SED-360
-- =============================================================
-- Propósito: Crear las tablas base del Sistema de Evaluación
-- Docente 360° siguiendo el blueprint técnico v2.0.
--
-- Tablas:
--   1. usuarios — Perfiles sincronizados con auth.users
--   2. cargas_academicas — Nexo docente-materia-periodo
--   3. evaluaciones — Captura de evaluaciones con unique_vote
--
-- Restricciones de negocio:
--   - Voto único por evaluador, carga y tipo de actor
--   - Roles validados por CHECK constraint
-- =============================================================

-- 1. Usuarios y Roles (Sincronizado con Auth de Supabase)
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID REFERENCES auth.users PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    rol VARCHAR(50) CHECK (rol IN ('alumno', 'docente', 'coordinador', 'tecnico', 'calidad', 'admin'))
);

-- Política RLS: Usuarios solo pueden leer su propio perfil
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden leer su propio perfil"
    ON usuarios
    FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Solo admin puede insertar/actualizar usuarios"
    ON usuarios
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM usuarios u
            WHERE u.id = auth.uid() AND u.rol = 'admin'
        )
    );

-- 2. Cargas Académicas (El Nexo Central)
-- Relaciona al docente con la materia en un periodo específico
CREATE TABLE IF NOT EXISTS cargas_academicas (
    id_carga SERIAL PRIMARY KEY,
    id_docente UUID REFERENCES usuarios(id),
    id_materia TEXT NOT NULL,
    id_periodo TEXT NOT NULL,
    UNIQUE (id_docente, id_materia, id_periodo)
);

-- Política RLS: Lectura pública para usuarios autenticados
ALTER TABLE cargas_academicas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios autenticados pueden leer cargas"
    ON cargas_academicas
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Solo admin puede gestionar cargas"
    ON cargas_academicas
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM usuarios u
            WHERE u.id = auth.uid() AND u.rol = 'admin'
        )
    );

-- 3. Captura de Evaluaciones (Normalizada para Escalabilidad)
CREATE TABLE IF NOT EXISTS evaluaciones (
    id_evaluacion SERIAL PRIMARY KEY,
    id_evaluador UUID REFERENCES usuarios(id),
    id_carga INT REFERENCES cargas_academicas(id_carga),
    tipo_actor VARCHAR(20) CHECK (tipo_actor IN ('ALUMNO', 'COORDINADOR', 'TECNICO', 'CALIDAD', 'AUTO')),
    puntaje_promedio DECIMAL(5,2),
    comentario TEXT,
    marcado_inapropiado BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Regla de integridad: Voto único por evaluador, carga y tipo de actor
    CONSTRAINT unique_vote UNIQUE (id_evaluador, id_carga, tipo_actor)
);

-- Política RLS: Evaluador inserta su propia evaluación
ALTER TABLE evaluaciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Evaluador puede insertar su propia evaluación"
    ON evaluaciones
    FOR INSERT
    WITH CHECK (auth.uid() = id_evaluador);

CREATE POLICY "Evaluador puede leer sus propias evaluaciones"
    ON evaluaciones
    FOR SELECT
    USING (auth.uid() = id_evaluador);

CREATE POLICY "Admin y coordinador pueden leer todas las evaluaciones"
    ON evaluaciones
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM usuarios u
            WHERE u.id = auth.uid() AND u.rol IN ('admin', 'coordinador', 'calidad')
        )
    );

-- Índices para optimizar consultas de agregación
CREATE INDEX IF NOT EXISTS idx_evaluaciones_id_carga
    ON evaluaciones(id_carga);

CREATE INDEX IF NOT EXISTS idx_evaluaciones_tipo_actor
    ON evaluaciones(tipo_actor);

CREATE INDEX IF NOT EXISTS idx_evaluaciones_fecha
    ON evaluaciones(fecha_creacion);
