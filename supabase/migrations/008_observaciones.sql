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
