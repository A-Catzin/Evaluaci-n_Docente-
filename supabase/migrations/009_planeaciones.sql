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
