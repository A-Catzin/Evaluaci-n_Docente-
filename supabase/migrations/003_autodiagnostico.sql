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
