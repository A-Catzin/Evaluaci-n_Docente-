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
